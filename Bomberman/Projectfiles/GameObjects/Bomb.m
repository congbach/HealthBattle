//
//  Bomb.m
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Bomb.h"

static NSString * const BombTickAnimName = @"Tick";
static const NSInteger BombTickAnimTag = 8888;
static const int BombTickAnimFramesCount = 3;
static NSString * const BombExplodeAnimName = @"Explode";
static const NSInteger BombExplodeAnimTag = 7777;
static const int BombExplodeAnimFramesCount = 3;

@interface Bomb ()

- (void)playTickAnim;
- (void)playExplodeAnim;

@end

@implementation Bomb

+ (CCSpriteBatchNode *)spriteBatchNode
{
    return [CCSpriteBatchNode batchNodeWithFile:GAME_OBJECT_SPRITE_BATCH_NODE_WITH_PREFIX(BombAnimPrefix) capacity:GameObjectSpriteBatchNodeRow * GameObjectSpriteBatchNodeCol];
}

-(id) init
{
	self = [super initWithSpriteFrameName:[NSString stringWithFormat:@"%@_%@_01", BombAnimPrefix, BombTickAnimName]];
	if (self)
	{
        [self playTickAnim];
	}
	return self;
}

-(void) onEnter
{
	[super onEnter];
}

-(void) cleanup
{
	[super cleanup];
}

-(void) dealloc
{\
	NSLog(@"dealloc: %@", self);
}

-(void) update:(ccTime)delta
{
    
}

- (void)playTickAnim
{
    [self playAnimLoopedWithFormat:[NSString stringWithFormat:@"%@_%@_%@", BombAnimPrefix, BombTickAnimName, @"%.2i"] numFrames:BombTickAnimFramesCount firstIndex:1 delay:0.2f animateTag:BombTickAnimTag];
}

- (void)playExplodeAnim
{
    
}

@end
