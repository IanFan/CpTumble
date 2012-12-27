//
//  OCpSprite.m
//  BasicCocos2D
//
//  Created by Ian Fan on 13/08/12.
//
//

#import "OCpSprite.h"

@implementation OCpSprite

@synthesize chipmunkObjects,chipmunkBody,chipmunkShape,touchedShapes;

-(void)setChipmunkObjectsWithShapeStyle:(CpShapeStyle)shapeSty mass:(float)mas sizeWidth:(int)sizeW sizeHeight:(int)sizeH positionX:(float)posX positionY:(float)posY elasticity:(float)elas friction:(float)fric collisionType:(NSString*)colliType {
  chipmunkBodyWidth = sizeW;
  chipmunkBodyHeight = sizeH;
  ChipmunkBody *body;
  ChipmunkShape *shape;
  cpFloat moment;
  
  switch (shapeSty) {
    case ShapeStyleCircle:{
      moment = cpMomentForCircle(mas, 0, sizeH, cpv(0.0f, 0.0f));
      body = [[ChipmunkBody alloc] initWithMass:mas andMoment:moment];
      shape = [ChipmunkCircleShape circleWithBody:body radius:(0.5*sizeW) offset:CGPointMake(0, 0)];
      break;
    }
    case ShapeStylePoly:{
      moment = cpMomentForBox(mas, 0, sizeH);
      body = [[ChipmunkBody alloc]initWithMass:mas andMoment:moment];
      shape = [ChipmunkPolyShape boxWithBody:body width:sizeW height:sizeH];
      break;
    }
      /*
    case ShapeStyleStaticCircle:{
//      moment = cpMomentForCircle(mas, sizeW, sizeH, cpv(0.0f, 0.0f));
      body = [[ChipmunkBody alloc]initStaticBody];
      shape = [ChipmunkStaticCircleShape circleWithBody:body radius:0.5*sizeW offset:CGPointZero];
      break;
    }
       */
      
    default:
      break;
  }
  
  [body setPos:cpv(posX, posY)];
  [shape setElasticity:elas];
  [shape setFriction:fric];
  [shape setCollisionType:colliType];
  [shape setData:self];
  
  NSArray *cpArray = [[NSArray alloc]initWithObjects:body,shape, nil];
  
  self.chipmunkObjects = cpArray;
  self.chipmunkBody = body;
  self.chipmunkShape = shape;
  
  self.position = ccp(posX, posY);
  self.scaleX = 1.0*(chipmunkBodyWidth/self.boundingBox.size.width);
  self.scaleY = 1.0*(chipmunkBodyHeight/self.boundingBox.size.height);
  
  [body release];
  [cpArray release];
}

-(void)updateCpSprite {
  self.position = chipmunkBody.pos;
  self.rotation = -CC_RADIANS_TO_DEGREES(chipmunkBody.angle);
}

-(id)init
{
  if ((self = [super init])) {
  }
  
  return self;
}

-(void)dealloc {
  self.chipmunkBody = nil;
  self.chipmunkShape = nil;
  self.chipmunkObjects = nil;
  
  [super dealloc];
}

@end
