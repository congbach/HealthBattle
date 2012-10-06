//
//  GameObject.h
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "kobold2d.h"
#import "GameCommon.h"

#define GAME_OBJECT_SPRITE_BATCH_NODE_WITH_PREFIX(prefix) \
    [NSString stringWithFormat:@"%@.png", prefix]
#define GAME_OBJECT_PLIST_WITH_PREFIX(prefix) \
    [NSString stringWithFormat:@"%@.plist", prefix]

static const CGSize GameObjectSize = { 40, 50 };
static const int GameObjectSpriteBatchNodeRow = 4;
static const int GameObjectSpriteBatchNodeCol = 4;

@interface GameObject : CCSprite

- (id)initWithAnimPrefix:(NSString *)prefix;
- (void)playMovingAnimWithDirection:(Direction)direction;
- (void)stopMovingAnimation;

@end
