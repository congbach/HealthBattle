//
//  Projectile.h
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "kobold2d.h"
#import "GameCommon.h"

static NSString * const ProjectileAnimPrefix = @"Projectile";

typedef enum { kProjectileNormal, kProjectileDoubleDamage } ProjectileType;

@interface Projectile : CCSprite

@property (nonatomic, readonly, assign) ProjectileType projectileType;
@property (nonatomic, readonly, assign) Direction direction;

+ (CCSpriteBatchNode *)spriteBatchNode;

- (id)initWithType:(ProjectileType)projectileType direction:(Direction)direction;

@end
