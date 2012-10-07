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
static const CGFloat GameObjectMovingVelocity = 1.0f;
static NSString * const DemoMap = @"Demo.tmx";
static NSString * const TileMapBackgroundLayerName = @"Background";
static UIEdgeInsets GameObjectEdgeInsets = { 3, 3, 3, 3 };

@interface GameLayer ()

@property (nonatomic, strong) SneakyInputLayer *sneakyInputLayer;
@property (nonatomic, strong) CCTMXTiledMap *tileMap;
@property (nonatomic, strong) CCTMXLayer *tileMapBackgroundLayer;
@property (nonatomic, strong) CCSpriteBatchNode *bombermanBatchNode;
@property (nonatomic, strong) Bomberman *bomberman;


- (void)preloadResources;
- (void)loadTileMap;
- (void)loadBatchNodes;
- (void)createSneakyInputLayer;
- (void)createBomberman;

- (void)moveGameObject:(GameObject *)gameObject direction:(Direction)direction;

- (CGPoint)tileCoordForPosition:(CGPoint)position;

@end

@implementation GameLayer

@synthesize sneakyInputLayer = _sneakyInputLayer;
@synthesize tileMap = _tileMap;
@synthesize tileMapBackgroundLayer = _tileMapBackgroundLayer;
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
    
    [self moveGameObject:self.bomberman direction:joystickDirection];
}

- (void)createBomberman
{
    self.bomberman = [[Bomberman alloc] init];
    [self.bombermanBatchNode addChild:self.bomberman];
    
    CGSize mapSize = self.tileMap.mapSize;
    CGSize tileSize = self.tileMap.tileSize;
    
    CGPoint startingCoordinate = CGPointMake(1, mapSize.height - 2);
    
    [self.bomberman setPosition:CGPointMake((startingCoordinate.x + 0.5f) * tileSize.width,
                                            (startingCoordinate.y + 0.5f) * tileSize.height)];
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
    
    self.tileMapBackgroundLayer = [self.tileMap layerNamed:TileMapBackgroundLayerName];
}

- (void)preloadResources
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:GAME_OBJECT_PLIST_WITH_PREFIX(BombermanAnimPrefix) textureFilename:GAME_OBJECT_SPRITE_BATCH_NODE_WITH_PREFIX(BombermanAnimPrefix)];
}

- (void)moveGameObject:(GameObject *)gameObject direction:(Direction)direction
{
    if (direction == kNoDirection)
        return;
    
    CGPoint unitVelocity = CGPointZero;
    
    switch (direction) {
        case kDirectionUp:
            unitVelocity.y = 1;
            break;
            
        case kDirectionDown:
            unitVelocity.y = -1;
            break;
            
        case kDirectionLeft:
            unitVelocity.x = -1;
            break;
            
        case kDirectionRight:
            unitVelocity.x = 1;
            break;
            
        case kNoDirection:
        default:
            // Should not happen
            break;
    }
    
    BOOL canMoveObject = YES;
    NSMutableArray *tilesToCheck = [NSMutableArray array];
    CGPoint tileCoord = [self tileCoordForPosition:gameObject.position];
    [tilesToCheck addObject:[NSValue valueWithCGPoint:CGPointMake(tileCoord.x + unitVelocity.x, tileCoord.y - unitVelocity.y)]];
    
    // We also have to check the tile right next to the next tile (in perpendicular direction)
    CGSize tileSize = self.tileMap.tileSize;
//    if (direction == kDirectionLeft || direction == kDirectionRight)
//    {
//        CGFloat gameObjYInTile = gameObject.position.y - floorf(gameObject.position.y / tileSize.height) * tileSize.height;
//        [tilesToCheck addObject:[NSValue valueWithCGPoint:CGPointMake(tileCoord.x + unitVelocity.x, tileCoord.y - (gameObjYInTile <= tileSize.height / 2 ? -1 : 1))]];
//    }
//    else
//    {
//        CGFloat gameObjXInTile = gameObject.position.x - floorf(gameObject.position.x / tileSize.width) * tileSize.width;
//        [tilesToCheck addObject:[NSValue valueWithCGPoint:CGPointMake(tileCoord.x + (gameObjXInTile <= tileSize.width / 2 ? -1 : 1), tileCoord.y + unitVelocity.y)]];
//    }
    
    CGRect gameObjBoundingBox = gameObject.boundingBox;
    gameObjBoundingBox.origin.x += GameObjectEdgeInsets.left;
    gameObjBoundingBox.origin.y += GameObjectEdgeInsets.bottom;
    gameObjBoundingBox.size.width -= GameObjectEdgeInsets.left + GameObjectEdgeInsets.right;
    gameObjBoundingBox.size.height -= GameObjectEdgeInsets.bottom + GameObjectEdgeInsets.top;
    
    for (NSValue *tileToCheckCoordNSValue in tilesToCheck)
    {
        CGPoint tileToCheckCoord = [tileToCheckCoordNSValue CGPointValue];
        int tileToCheckGid = [self.tileMapBackgroundLayer tileGIDAt:tileToCheckCoord];
        if (tileToCheckGid)
        {
            CGSize mapSize = self.tileMap.mapSize;
            CGRect tileToCheckBoundingBox = CGRectMake(tileToCheckCoord.x * tileSize.width, (mapSize.height - 1 - tileToCheckCoord.y) * tileSize.height, tileSize.width, tileSize.height);
            if (CGRectIntersectsRect(tileToCheckBoundingBox, gameObjBoundingBox))
            {
                CGPoint position = gameObject.position;
                CGPoint tileCoordPosition = [self positionForTileCoord:tileCoord];
                if (direction == kDirectionLeft)
                    position.x = fminf(tileCoordPosition.x, position.x);
                else if (direction == kDirectionRight)
                    position.x = fmaxf(tileCoordPosition.x, position.x);
                else if (direction == kDirectionUp)
                    position.y = fmaxf(tileCoordPosition.y, position.y);
                else
                    position.y = fminf(tileCoordPosition.y, position.y);
                gameObject.position = position;
                canMoveObject = NO;
                break;
            }
        }
    }
    
    if (canMoveObject)
    {
        CGPoint position = gameObject.position;
        position.x += unitVelocity.x * GameObjectMovingVelocity;
        position.y += unitVelocity.y * GameObjectMovingVelocity;
        gameObject.position = position;
    }
}


#pragma mark TileMapManimupation

- (CGPoint)tileCoordForPosition:(CGPoint)position
{
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

- (CGPoint)positionForTileCoord:(CGPoint)tileCoord
{
    CGSize mapSize = self.tileMap.mapSize;
    CGSize tileSize = self.tileMap.tileSize;
    return CGPointMake((tileCoord.x + 0.5f) * tileSize.width, (mapSize.height - tileCoord.y - 0.5f) * tileSize.height);
}

@end
