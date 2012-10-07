//
//  GameObject.h
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "kobold2d.h"
#import "GameCommon.h"

static const CGSize GameObjectSize = { 40, 50 };
static const int GameObjectSpriteBatchNodeRow = 4;
static const int GameObjectSpriteBatchNodeCol = 4;

typedef enum { kGameObjectSideAlly, kGameObjectSideEnemy } GameObjectSide;

@interface GameObject : CCSprite

- (id)initWithAnimPrefix:(NSString *)prefix side:(GameObjectSide)side;
- (void)playMovingAnimWithDirection:(Direction)direction;
- (void)stopMovingAnim;

@property (nonatomic, readonly, assign) GameObjectSide side;
@property (nonatomic, readonly, assign) Direction facingDirection;
@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, assign) int hp;

@end
