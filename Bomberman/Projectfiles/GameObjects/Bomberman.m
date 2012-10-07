//
//  Bomberman.m
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Bomberman.h"

static const int BombermanHp = 5;

@interface Bomberman ()

@end

@implementation Bomberman

+ (CCSpriteBatchNode *)spriteBatchNode
{
    return [CCSpriteBatchNode batchNodeWithFile:SPRITE_BATCH_NODE_WITH_NAME(BombermanAnimPrefix) capacity:GameObjectSpriteBatchNodeRow * GameObjectSpriteBatchNodeCol];
}


-(id) initWithSide:(GameObjectSide)side
{
	if (self = [super initWithAnimPrefix:BombermanAnimPrefix side:side])
	{
        self.hp = BombermanHp;
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
{
	NSLog(@"dealloc: %@", self);
}

-(void) update:(ccTime)delta
{
    
}

@end
