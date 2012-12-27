//
//  ChipmunkTumbleLayer.h
//  BasicCocos2D
//
//  Created by Ian Fan on 19/08/12.
//
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "OCpSprite.h"

@interface ChipmunkTumbleLayer : CCLayer
{
  ChipmunkSpace *_space;
  ChipmunkMultiGrab *_multiGrab;
  CCSprite *boxSprite;
  ChipmunkBody *boxBody;
}

+(CCScene *) scene;

@end
