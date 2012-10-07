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
#import "Bomb.h"
#import "Projectile.h"

static NSString * const GKSessionID = @"HealthPlay";
static const CGSize GridSize = { 32, 32 };
static const int TileMapZOrder = 0;
static const int BatchNodeZOrder = 1;
static const int OverlayZOrder = 2;
static const CGFloat GameObjectMovingVelocity = 1.0f;
static NSString * const DemoMap = @"Demo.tmx";
static NSString * const TileMapBackgroundLayerName = @"Background";
static NSString * const TileMapPowerUpsLayerName = @"PowerUps";
static UIEdgeInsets GameObjectEdgeInsets = { 3, 3, 3, 3 };
static const CGFloat ProjectileVelocity = 2.0f;


#pragma mark - PlayerAction

@interface PlayerAction : NSObject<NSCoding>

@property (nonatomic, readwrite, assign) Direction joystickDirection;
@property (nonatomic, readwrite, assign) BOOL padButtonActive;

- (id)initWithJoystickDirection:(Direction)direction padButtonActive:(BOOL)padButtonActive;

@end


@implementation PlayerAction

@synthesize joystickDirection = _joystickDirection;
@synthesize padButtonActive = _padButtonActive;

- (id)initWithJoystickDirection:(Direction)direction padButtonActive:(BOOL)padButtonActive
{
    if (self = [super init])
    {
        self.joystickDirection = direction;
        self.padButtonActive = padButtonActive;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        self.joystickDirection = [decoder decodeIntForKey:@"joystickDirection"];
        self.padButtonActive = [decoder decodeBoolForKey:@"padButtonActive"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:(int)self.joystickDirection forKey:@"joystickDirection"];
    [encoder encodeBool:self.padButtonActive forKey:@"padButtonActive"];
}

@end


#pragma mark - GameLayer

@interface GameLayer () <GKPeerPickerControllerDelegate, GKSessionDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) GKSession *gkSession;
@property (nonatomic, strong) SneakyInputLayer *sneakyInputLayer;
@property (nonatomic, strong) CCTMXTiledMap *tileMap;
@property (nonatomic, strong) CCTMXLayer *tileMapBackgroundLayer;
@property (nonatomic, strong) CCTMXLayer *tileMapPowerUpsLayer;
@property (nonatomic, strong) CCSpriteBatchNode *bombermanBatchNode;
@property (nonatomic, strong) CCSpriteBatchNode *bombBatchNode;
@property (nonatomic, strong) CCSpriteBatchNode *projectileBatchNode;
@property (nonatomic, strong) Bomberman *bomberman;
@property (nonatomic, strong) Bomberman *enemyBomberman;
@property (nonatomic, strong) NSMutableDictionary *bombs;
@property (nonatomic, strong) NSMutableArray *allies;
@property (nonatomic, strong) NSMutableArray *enemies;
@property (nonatomic, strong) NSMutableArray *alliesProjectiles;
@property (nonatomic, strong) NSMutableArray *enemiesProjectiles;
@property (nonatomic, strong) PlayerAction *clientPlayerAction;
@property (nonatomic, assign) Direction lastJoystickDirection;


- (void)preloadResources;
- (void)loadTileMap;
- (void)loadBatchNodes;
- (void)createSneakyInputLayer;
- (void)createBomberman;

- (void)addGameObject:(GameObject *)gameObject;
- (BOOL)moveGameObject:(GameObject *)gameObject direction:(Direction)direction isPlayer:(BOOL)isPlayer;
- (BOOL)addBombAtTileCoord:(CGPoint)tileCoord;
- (BOOL)shootProjectileFromGameObject:(GameObject *)gameObject direction:(Direction)direction;

- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (CGPoint)unitVelocityWithDirection:(Direction)direction;

@end

@implementation GameLayer

@synthesize gkSession = _gkSession;
@synthesize sneakyInputLayer = _sneakyInputLayer;
@synthesize tileMap = _tileMap;
@synthesize tileMapBackgroundLayer = _tileMapBackgroundLayer;
@synthesize tileMapPowerUpsLayer = _tileMapPowerUpsLayer;
@synthesize bombermanBatchNode = _bombermanBatchNode;
@synthesize bombBatchNode = _bombBatchNode;
@synthesize projectileBatchNode = _projectileBatchNode;
@synthesize bomberman = _bomberman;
@synthesize enemyBomberman = _enemyBomberman;
@synthesize bombs = _bombs;
@synthesize allies = _allies;
@synthesize enemies = _enemies;
@synthesize alliesProjectiles = alliesProjectiles;
@synthesize enemiesProjectiles = _enemiesProjectiles;
@synthesize clientPlayerAction = _clientPlayerAction;
@synthesize lastJoystickDirection = _lastJoystickDirection;

-(id) init
{
	self = [super init];
	if (self)
	{
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Network" message:@"Please choose an option" delegate:self cancelButtonTitle:@"Host" otherButtonTitles:@"Join", nil];
        [alerView show];
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
    if (self.gkSession.sessionMode == GKSessionModeServer)
    {
        Direction joystickDirection = self.sneakyInputLayer.joystickDirection;
        if (joystickDirection != kNoDirection)
            [self.bomberman playMovingAnimWithDirection:joystickDirection];
        else
            [self.bomberman stopMovingAnim];
        
        [self moveGameObject:self.bomberman direction:joystickDirection isPlayer:YES];
        
        if (self.sneakyInputLayer.padButtonActive)
            //[self addBombAtTileCoord:[self tileCoordForPosition:self.bomberman.position]];
            [self shootProjectileFromGameObject:self.bomberman direction:self.bomberman.facingDirection];
        
        if (self.clientPlayerAction)
        {
            joystickDirection = self.clientPlayerAction.joystickDirection;
            if (joystickDirection != kNoDirection)
                [self.enemyBomberman playMovingAnimWithDirection:joystickDirection];
            else
                [self.enemyBomberman stopMovingAnim];
            
            [self moveGameObject:self.enemyBomberman direction:joystickDirection isPlayer:YES];
            
            if (self.clientPlayerAction.padButtonActive)
            {
                //[self addBombAtTileCoord:[self tileCoordForPosition:self.bomberman.position]];
                [self shootProjectileFromGameObject:self.bomberman direction:self.bomberman.facingDirection];
                self.clientPlayerAction.padButtonActive = NO;
            }
        }
        
        
        NSMutableArray *toBeDestroyedProjectiles = [NSMutableArray array];
        for (Projectile *projectile in self.alliesProjectiles)
        {
            CGPoint unitVelocity = [self unitVelocityWithDirection:projectile.direction];
            CGPoint tileCoord = [self tileCoordForPosition:projectile.position];
            CGPoint nextTileCoord = CGPointMake(tileCoord.x + unitVelocity.x, tileCoord.y - unitVelocity.y);
            int tileGid = [self.tileMapBackgroundLayer tileGIDAt:nextTileCoord];
            if (tileGid && CGRectIntersectsRect([self tileBoundingBoxAtTileCoord:nextTileCoord], [projectile boundingBox]))
                [toBeDestroyedProjectiles addObject:projectile];
        }
        [self.alliesProjectiles removeObjectsInArray:toBeDestroyedProjectiles];
        while (toBeDestroyedProjectiles.count)
        {
            [self.projectileBatchNode removeChild:[toBeDestroyedProjectiles lastObject] cleanup:YES];
            [toBeDestroyedProjectiles removeLastObject];
        }
        
        for (Projectile *projectile in self.alliesProjectiles)
        {
            CGPoint unitVelocity = [self unitVelocityWithDirection:projectile.direction];
            CGPoint tileCoord = [self tileCoordForPosition:projectile.position];
            CGPoint nextTileCoord = CGPointMake(tileCoord.x + unitVelocity.x, tileCoord.y - unitVelocity.y);
            int tileGid = [self.tileMapBackgroundLayer tileGIDAt:nextTileCoord];
            if (tileGid && CGRectIntersectsRect([self tileBoundingBoxAtTileCoord:nextTileCoord], [projectile boundingBox]))
                [toBeDestroyedProjectiles addObject:projectile];
        }
        [self.enemiesProjectiles removeObjectsInArray:toBeDestroyedProjectiles];
        while (toBeDestroyedProjectiles.count)
        {
            [self.projectileBatchNode removeChild:[toBeDestroyedProjectiles lastObject] cleanup:YES];
            [toBeDestroyedProjectiles removeLastObject];
        }
    }
    else
    {
        Direction joystickDirection = self.sneakyInputLayer.joystickDirection;
        if (joystickDirection != self.lastJoystickDirection || self.sneakyInputLayer.padButtonActive)
        {
            PlayerAction *playAction = [[PlayerAction alloc] initWithJoystickDirection:joystickDirection padButtonActive:self.sneakyInputLayer.padButtonActive];
            [self sendDataToServer:[NSKeyedArchiver archivedDataWithRootObject:playAction]];
        }
        self.lastJoystickDirection = joystickDirection;
    }
}

- (void)createBomberman
{
    self.bomberman = [[Bomberman alloc] initWithSide:kGameObjectSideAlly];
    [self addGameObject:self.bomberman];
    
    CGSize mapSize = self.tileMap.mapSize;
    CGSize tileSize = self.tileMap.tileSize;
    
    CGPoint startingCoordinate;
    
    if (self.gkSession.sessionMode == GKSessionModeServer)
        startingCoordinate = CGPointMake(1, mapSize.height - 2);
    else
        startingCoordinate = CGPointMake(mapSize.width - 2, 1);
    
    [self.bomberman setPosition:CGPointMake((startingCoordinate.x + 0.5f) * tileSize.width,
                                            (startingCoordinate.y + 0.5f) * tileSize.height)];
    
    self.enemyBomberman = [[Bomberman alloc] initWithSide:kGameObjectSideEnemy];
    [self addGameObject:self.enemyBomberman];
    if (self.gkSession.sessionMode != GKSessionModeServer)
        startingCoordinate = CGPointMake(1, mapSize.height - 2);
    else
        startingCoordinate = CGPointMake(mapSize.width - 2, 1);
    
    [self.enemyBomberman setPosition:CGPointMake((startingCoordinate.x + 0.5f) * tileSize.width,
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
    
    self.bombBatchNode = [Bomb spriteBatchNode];
    [self addChild:self.bombBatchNode z:BatchNodeZOrder];
    
    self.projectileBatchNode = [Projectile spriteBatchNode];
    [self addChild:self.projectileBatchNode z:BatchNodeZOrder];
}

- (void)loadTileMap
{
    self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:DemoMap];
    [self addChild:self.tileMap z:TileMapZOrder];
    
    self.tileMapBackgroundLayer = [self.tileMap layerNamed:TileMapBackgroundLayerName];
    self.tileMapPowerUpsLayer = [self.tileMap layerNamed:TileMapPowerUpsLayerName];
}

- (void)preloadResources
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:PLIST_WITH_NAME(BombermanAnimPrefix) textureFilename:SPRITE_BATCH_NODE_WITH_NAME(BombermanAnimPrefix)];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:PLIST_WITH_NAME(BombAnimPrefix) textureFilename:SPRITE_BATCH_NODE_WITH_NAME(BombAnimPrefix)];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:PLIST_WITH_NAME(ProjectileAnimPrefix) textureFilename:SPRITE_BATCH_NODE_WITH_NAME(ProjectileAnimPrefix)];
}

- (BOOL)moveGameObject:(GameObject *)gameObject direction:(Direction)direction isPlayer:(BOOL)isPlayer
{
    if (direction == kNoDirection)
        return YES;
    
    CGPoint unitVelocity = [self unitVelocityWithDirection:direction];
    NSMutableArray *tilesToCheck = [NSMutableArray array];
    CGPoint tileCoord = [self tileCoordForPosition:gameObject.position];
    [tilesToCheck addObject:[NSValue valueWithCGPoint:CGPointMake(tileCoord.x + unitVelocity.x, tileCoord.y - unitVelocity.y)]];
    
    // We also have to check the tile right next to the next tile (in perpendicular direction)
//    CGSize tileSize = self.tileMap.tileSize;
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
            if (CGRectIntersectsRect([self tileBoundingBoxAtTileCoord:tileToCheckCoord], gameObjBoundingBox))
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
                
                return NO;
            }
    }
    
    CGPoint position = gameObject.position;
    position.x += unitVelocity.x * GameObjectMovingVelocity;
    position.y += unitVelocity.y * GameObjectMovingVelocity;
    gameObject.position = position;
    
    if (isPlayer)
    {
        tileCoord = [self tileCoordForPosition:gameObject.position];
        int powerUpTileGid = [self.tileMapPowerUpsLayer tileGIDAt:tileCoord];
        if (powerUpTileGid)
        {
            NSDictionary *powerUpProperties = [self.tileMap propertiesForGID:powerUpTileGid];
            [self.tileMapPowerUpsLayer removeTileAt:tileCoord];
        }
    }
    return YES;
}

- (void)addGameObject:(GameObject *)gameObject
{
    if ([gameObject isKindOfClass:[Bomberman class]])
        [self.bombermanBatchNode addChild:gameObject];
    
    if (gameObject.side == kGameObjectSideAlly)
        [self.allies addObject:gameObject];
    else
        [self.enemies addObject:gameObject];
}

- (BOOL)addBombAtTileCoord:(CGPoint)tileCoord
{
    NSValue *bombKey = [NSValue valueWithCGPoint:tileCoord];
    if ([self.bombs objectForKey:bombKey])
        return NO;
    
    Bomb *bomb = [[Bomb alloc] init];
    bomb.position = [self positionForTileCoord:tileCoord];
    [self.bombBatchNode addChild:bomb];
    [self.bombs setObject:bomb forKey:bombKey];
    
    return YES;
}

- (BOOL)shootProjectileFromGameObject:(GameObject *)gameObject direction:(Direction)direction
{
    CGPoint unitVelocity = [self unitVelocityWithDirection:direction];
    
    Projectile *projectile = [[Projectile alloc] initWithType:kProjectileNormal direction:direction];
    projectile.position = gameObject.position;
    [self.projectileBatchNode addChild:projectile];
    
    if (gameObject.side == kGameObjectSideAlly)
        [self.alliesProjectiles addObject:projectile];
    else
        [self.enemiesProjectiles addObject:projectile];
    
    CCMoveBy *moveAction = [CCMoveBy actionWithDuration:0.02f position:CGPointMake(unitVelocity.x * ProjectileVelocity, unitVelocity.y * ProjectileVelocity)];
    [projectile runAction:[CCRepeatForever actionWithAction:moveAction]];
    
    return YES;
}

- (CGPoint)unitVelocityWithDirection:(Direction)direction
{
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
            break;
    }
    
    return unitVelocity;
}


#pragma mark TileMapManimupation

- (CGRect)tileBoundingBoxAtTileCoord:(CGPoint)tileCoord
{
    CGSize mapSize = self.tileMap.mapSize;
    CGSize tileSize = self.tileMap.tileSize;
    return CGRectMake(tileCoord.x * tileSize.width, (mapSize.height - 1 - tileCoord.y) * tileSize.height, tileSize.width, tileSize.height);
}

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


#pragma mark - GKPeerPickerControllerDelegate

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    self.gkSession = session;
    session.delegate = self;
    
    picker.delegate = nil;
    [picker dismiss];
}


#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state) {
        case GKPeerStateAvailable:
			NSLog(@"didChangeState: peer %@ available", [session displayNameForPeer:peerID]);
            
            if (session.sessionMode == GKSessionModeClient)
                [session connectToPeer:peerID withTimeout:5];
            break;
            
        case GKPeerStateConnected:
			NSLog(@"didChangeState: peer %@ connected", [session displayNameForPeer:peerID]);
            
            [session setDataReceiveHandler:self withContext:nil];
            
            [self preloadResources];
            [self loadTileMap];
            [self createSneakyInputLayer];
            [self loadBatchNodes];
            [self createBomberman];
            
            self.bombs = [NSMutableDictionary dictionary];
            self.allies = [NSMutableArray array];
            self.enemies = [NSMutableArray array];
            self.alliesProjectiles = [NSMutableArray array];
            self.enemiesProjectiles = [NSMutableArray array];
            self.lastJoystickDirection = kNoDirection;
            
            [self scheduleUpdate];
            break;
            
        case GKPeerStateDisconnected:
			NSLog(@"didChangeState: peer %@ disconnected", [session displayNameForPeer:peerID]);
            break;
            
        case GKPeerStateUnavailable:
			NSLog(@"didChangeState: peer %@ unavailable", [session displayNameForPeer:peerID]);
            break;
            
        case GKPeerStateConnecting:
			NSLog(@"didChangeState: peer %@ connecting", [session displayNameForPeer:peerID]);
            break;
            
        default:
            break;
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	NSLog(@"didReceiveConnectionRequestFromPeer: %@", [session displayNameForPeer:peerID]);
    
    [session acceptConnectionFromPeer:peerID error:nil];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	NSLog(@"connectionWithPeerFailed: peer: %@, error: %@", [session displayNameForPeer:peerID], error);    
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	NSLog(@"didFailWithError: error: %@", error);
}


#pragma - GKSession Send/Receive data

- (void)sendDataToServer:(NSData *)data
{
    if (self.gkSession && self.gkSession.sessionMode == GKSessionModeClient)
        [self.gkSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

- (void)broadcastDataToClients:(NSData *)data
{
    
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    if (self.gkSession.sessionMode == GKSessionModeServer)
    {
        self.clientPlayerAction = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        
    }
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
//    GKPeerPickerController *gkPeerPicker = [[GKPeerPickerController alloc] init];
//    gkPeerPicker.delegate = self;
//    gkPeerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
//    
//    [gkPeerPicker show];
    
    GKSessionMode sessionMode = buttonIndex ? GKSessionModeClient : GKSessionModeServer;
    self.gkSession = [[GKSession alloc] initWithSessionID:GKSessionID displayName:GKSessionID sessionMode:sessionMode];
    self.gkSession.delegate = self;
    self.gkSession.available = YES;
}

@end
