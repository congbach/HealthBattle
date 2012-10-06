//
//  Bomberman.m
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Bomberman.h"

@interface Bomberman ()

@end

@implementation Bomberman

+ (CCSpriteBatchNode *)spriteBatchNode
{
    return [CCSpriteBatchNode batchNodeWithFile:GAME_OBJECT_SPRITE_BATCH_NODE_WITH_PREFIX(BombermanAnimPrefix) capacity:GameObjectSpriteBatchNodeRow * GameObjectSpriteBatchNodeCol];
}


-(id) init
{
	if (self = [super initWithAnimPrefix:BombermanAnimPrefix])
	{
        
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
