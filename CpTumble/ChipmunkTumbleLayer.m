//
//  ChipmunkTumbleLayer.m
//  BasicCocos2D
//
//  Created by Ian Fan on 19/08/12.
//
//

#import "ChipmunkTumbleLayer.h"

#define GRABABLE_MASK_BIT (1<<31)
#define NOT_GRABABLE_MASK (~GRABABLE_MASK_BIT)

static NSString *borderType = @"borderType";
static NSString *cpSpriteType = @"cpSpriteType";

//enum {
//  kTagParentNode = 1,
//};

@implementation ChipmunkTumbleLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	ChipmunkTumbleLayer *layer = [ChipmunkTumbleLayer node];
	[scene addChild: layer];
  
	return scene;
}

#pragma mark -
#pragma mark Update

-(void)update:(ccTime)dt {
  [_space step:dt];
  
  boxBody.angle += boxBody.angVel;
  
  boxSprite.position = boxBody.pos;
  boxSprite.rotation = -CC_RADIANS_TO_DEGREES(boxBody.angle);
  
  for (OCpSprite *cpS in self.children) {
    if ([_space contains:cpS]) [cpS updateCpSprite];
  }
}

#pragma mark -
#pragma mark Init

-(void)setChipmunkObjects {
  CGSize winSize = [CCDirector sharedDirector].winSize;
  
  //Box:
  //box sprite
  boxSprite = [CCSprite spriteWithFile:@"box.png"];
  boxSprite.position = ccp(winSize.width/2, winSize.height/2);
  boxSprite.color = ccc3(CCRANDOM_0_1()*255, CCRANDOM_0_1()*255, CCRANDOM_0_1()*255);
  boxSprite.scale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 1.0:0.5;
  [self addChild:boxSprite];
  
  //box chipmunkBody
  boxBody = [ChipmunkBody bodyWithMass:INFINITY andMoment:INFINITY];
  [boxBody setPos:cpv(winSize.width/2, winSize.height/2)];
  boxBody.angVel = 0.01;
  
  //box chipmunkShape
  float margin = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 200: 100;;
  float thickness = 40;
  float elas = 1.0;
  float fric = 0.5;
  
  ChipmunkShape *shape;
  cpVect verts1[] = { cpv(-margin-thickness, -margin), cpv(margin+thickness, -margin), cpv(margin+thickness, -margin-thickness), cpv(-margin-thickness, -margin-thickness) };
  cpVect verts2[] = { cpv(margin, margin+thickness), cpv(margin+thickness, margin+thickness), cpv(margin+thickness, -margin-thickness), cpv(margin, -margin-thickness) };
  cpVect verts3[] = { cpv(-margin-thickness, margin+thickness), cpv(margin+thickness, margin+thickness), cpv(margin+thickness, margin), cpv(-margin-thickness, margin) };
	cpVect verts4[] = { cpv(-margin-thickness, margin), cpv(-margin, margin), cpv(-margin, -margin), cpv(-margin-thickness, -margin) };
  
  shape = [ChipmunkPolyShape polyWithBody:boxBody count:4 verts:verts1 offset:cpvzero];
  [_space add:shape];
  shape.elasticity = elas;
  shape.friction = fric;
  
  shape = [ChipmunkPolyShape polyWithBody:boxBody count:4 verts:verts2 offset:cpvzero];
  [_space add:shape];
  shape.elasticity = elas;
  shape.friction = fric;
  
  shape = [ChipmunkPolyShape polyWithBody:boxBody count:4 verts:verts3 offset:cpvzero];
  [_space add:shape];
  shape.elasticity = elas;
  shape.friction = fric;
  
  shape = [ChipmunkPolyShape polyWithBody:boxBody count:4 verts:verts4 offset:cpvzero];
  [_space add:shape];
  shape.elasticity = elas;
  shape.friction = fric;
  
  //CpSprite
  float size = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 100: 50;
  for (int i=0; i<2; i++) {
    for (int j=0; j<2; j++) {
      [self addNewSpriteAtPosition:ccp(winSize.width/2+margin-size*0.5-size*i, winSize.height/2-margin+size*0.5+size*j)];
    }
  }
  
}

-(void)addNewSpriteAtPosition:(CGPoint)position {
  float size = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 100: 50;
  
  OCpSprite *cpSprite = [OCpSprite spriteWithFile:@"square.png"];
  cpSprite.position = position;
  cpSprite.scale = 1;
  [cpSprite setChipmunkObjectsWithShapeStyle:ShapeStylePoly mass:1.0 sizeWidth:size sizeHeight:size positionX:position.x positionY:position.y elasticity:0.1 friction:0.5 collisionType:cpSpriteType];
  
  [self addChild:cpSprite];
  [_space add:cpSprite];
}

#pragma mark -
#pragma mark Touch Event

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
  for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
    [_multiGrab beginLocation:point];
  }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
  for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
    [_multiGrab updateLocation:point];
  }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
    [_multiGrab endLocation:point];
  }
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
  [self ccTouchEnded:touch withEvent:event];
}

#pragma mark -
#pragma mark ChipmunkMultiGrab

-(void)setMultiGrab {
  cpFloat grabForce = 1e5;
  cpFloat smoothing = cpfpow(0.3,60);
  
  _multiGrab = [[ChipmunkMultiGrab alloc]initForSpace:_space withSmoothing:smoothing withGrabForce:grabForce];
  _multiGrab.layers = GRABABLE_MASK_BIT;
  _multiGrab.grabFriction = grabForce*0.1;
  _multiGrab.grabRotaryFriction = 1e3;
  _multiGrab.grabRadius = 20.0;
  _multiGrab.pushMass = 1.0;
  _multiGrab.pushFriction = 0.7;
  _multiGrab.pushMode = FALSE;
}

#pragma mark -
#pragma mark ChipmunkSpace

-(void)setSpace {
  CGSize winSize = [CCDirector sharedDirector].winSize;
  
  _space = [[ChipmunkSpace alloc]init];
  [_space addBounds:CGRectMake(0, 0, winSize.width, winSize.height) thickness:60.0 elasticity:1.0 friction:0.2 layers:NOT_GRABABLE_MASK group:nil collisionType:nil];
  _space.gravity = cpv(0, -600);
  _space.iterations = 30;
}

/*
 Target:
 Put some squares in a box, keep the box rotating and keep the squares tumbling.
 
 1. Set ChipmunkSpace, ChipmunkMultiGrab.
 2. Set ChipmunkObjects, including some squares and a box.
 3. Update the box's angleVel.
 */

#pragma mark -
#pragma mark Init

-(id) init {
	if((self = [super init])) {
    [self setSpace];
    
    [self setMultiGrab];
    
    [self setChipmunkObjects];
    
    [self schedule:@selector(update:)];
    
    self.isTouchEnabled = YES;
	}
  
	return self;
}

- (void) dealloc {
  [_space release];
  [_multiGrab release];
  
	[super dealloc];
}

@end
