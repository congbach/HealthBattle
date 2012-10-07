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
static const int TileMapZOrder = 0;
static const int BatchNodeZOrder = 1;
static const int OverlayZOrder = 2;
static const CGFloat JoystickVelocityMultiplier = 1;
static NSString * const DemoMap = @"Demo.tmx";

@interface GameLayer ()

@property (nonatomic, strong) SneakyInputLayer *sneakyInputLayer;
@property (nonatomic, strong) CCTMXTiledMap *tileMap;
@property (nonatomic, strong) CCSpriteBatchNode *bombermanBatchNode;
@property (nonatomic, strong) Bomberman *bomberman;


- (void)preloadResources;
- (void)loadTileMap;
- (void)loadBatchNodes;
- (void)createSneakyInputLayer;
- (void)createBomberman;


@end

@implementation GameLayer

@synthesize sneakyInputLayer = _sneakyInputLayer;
@synthesize tileMap = _tileMap;
@synthesize bombermanBatchNode = _bombermanBatchNode;
@synthesize bomberman = _bomberman;

-(id) init
{
	self = [super init];
	if (self)
	{
        [self preloadResources];
        [self loadTileMap];
        [self createSneakyInputLayer];
        [self loadBatchNodes];
        [self createBomberman];
        
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
    // Move bomerman
    Direction joystickDirection = self.sneakyInputLayer.joystickDirection;
    if (joystickDirection != kNoDirection)
        [self.bomberman playMovingAnimWithDirection:joystickDirection];
    else
        [self.bomberman stopMovingAnim];
    
    CGPoint joystickVelocity = self.sneakyInputLayer.joystickVelocity;
    CGPoint bombermanPosition = self.bomberman.position;
    bombermanPosition.x += JoystickVelocityMultiplier * joystickVelocity.x;
    bombermanPosition.y += JoystickVelocityMultiplier * joystickVelocity.y;
    self.bomberman.position = bombermanPosition;
}

- (void)createBomberman
{
    self.bomberman = [[Bomberman alloc] init];
    [self.bombermanBatchNode addChild:self.bomberman];
    
    [self.bomberman setPosition:CGPointMake(240, 160)];
    
}

- (void)createSneakyInputLayer
{
    self.sneakyInputLayer = [[SneakyInputLayer alloc] init];
    [self addChild:self.sneakyInputLayer z:OverlayZOrder];
}

- (void)loadBatchNodes
{
    self.bombermanBatchNode = [Bomberman spriteBatchNode];
    [self addChild:self.bombermanBatchNode z:BatchNodeZOrder];
}

- (void)loadTileMap
{
    self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:DemoMap];
    [self addChild:self.tileMap z:TileMapZOrder];
}

- (void)preloadResources
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:GAME_OBJECT_PLIST_WITH_PREFIX(BombermanAnimPrefix) textureFilename:GAME_OBJECT_SPRITE_BATCH_NODE_WITH_PREFIX(BombermanAnimPrefix)];
}

@end
