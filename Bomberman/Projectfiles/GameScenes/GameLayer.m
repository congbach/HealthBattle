//
//  GameLayer.m
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "SneakyInputLayer.h"
#import "Bomberman.h"

static const CGSize GridSize = { 32, 32 };
static const int BatchNodeZOrder = 0;
static const int OverlayZOrder = 1;

@interface GameLayer ()

@property (nonatomic, strong) SneakyInputLayer *sneakyInputLayer;
@property (nonatomic, strong) CCSpriteBatchNode *bombermanBatchNode;
@property (nonatomic, strong) Bomberman *bomberman;


- (void)preloadResources;
- (void)loadBatchNodes;

@end

@implementation GameLayer

@synthesize bombermanBatchNode = _bombermanBatchNode;
@synthesize bomberman = _bomberman;
@synthesize sneakyInputLayer = _sneakyInputLayer;

-(id) init
{
	self = [super init];
	if (self)
	{
        [self preloadResources];
        
        self.sneakyInputLayer = [[SneakyInputLayer alloc] init];
        [self addChild:self.sneakyInputLayer z:OverlayZOrder];
        
        [self loadBatchNodes];
        self.bomberman = [[Bomberman alloc] init];
        [self.bombermanBatchNode addChild:self.bomberman];
        
        [self.bomberman setPosition:CGPointMake(100, 100)];
        
        [self scheduleUpdate];
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

- (void)loadBatchNodes
{
    self.bombermanBatchNode = [Bomberman spriteBatchNode];
    [self addChild:self.bombermanBatchNode z:BatchNodeZOrder];
}

- (void)preloadResources
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:GAME_OBJECT_PLIST_WITH_PREFIX(BombermanAnimPrefix) textureFilename:GAME_OBJECT_SPRITE_BATCH_NODE_WITH_PREFIX(BombermanAnimPrefix)];
}

@end
