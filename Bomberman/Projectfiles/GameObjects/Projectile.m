//
//  Projectile.m
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Projectile.h"
#import "GameCommon.h"

static const int ProjectileAnimFramesCount = 4;
static const NSInteger ProjectileAnimTag = 9999;

@interface Projectile ()

@property (nonatomic, readwrite, assign) ProjectileType projectileType;
@property (nonatomic, readwrite, assign) Direction direction;

+ (NSString *)animNameWithType:(ProjectileType)projectTileType;
+ (NSString *)animFormatWithType:(ProjectileType)projectileType direction:(Direction)direction;

@end

@implementation Projectile

@synthesize projectileType = _projectileType;
@synthesize direction = _direction;

+ (NSString *)animNameWithType:(ProjectileType)projectTileType
{
    return @"Normal";
}

+ (NSString *)animFormatWithType:(ProjectileType)projectileType direction:(Direction)direction
{
//    return [NSString stringWithFormat:@"%@_%@_%@_%@", ProjectileAnimPrefix, [Projectile animNameWithType:projectileType], DirectionName(direction), @"%.2i"];
    return [NSString stringWithFormat:@"%@_%@_%@", ProjectileAnimPrefix, [Projectile animNameWithType:projectileType], @"%.2i"];
}

+ (CCSpriteBatchNode *)spriteBatchNode
{
    return [CCSpriteBatchNode batchNodeWithFile:SPRITE_BATCH_NODE_WITH_NAME(ProjectileAnimPrefix)];
}

-(id) initWithType:(ProjectileType)projectileType direction:(Direction)direction
{
	self = [super initWithSpriteFrameName:[NSString stringWithFormat:[Projectile animFormatWithType:projectileType direction:direction], 1]];
    
    switch (direction) {
        case kDirectionDown:
            self.rotation = -90;
            break;
            
        case kDirectionUp:
            self.rotation = 90;
            break;
            
        case kDirectionRight:
            self.scaleX = -1;
            break;
            
        case kDirectionLeft:
        case kNoDirection:
        default:
            break;
    }
    
	if (self)
	{
        self.projectileType = projectileType;
        self.direction = direction;
        //[self playAnimLoopedWithFormat:[Projectile animFormatWithType:projectileType] numFrames:ProjectileAnimFramesCount firstIndex:01 delay:0.2f animateTag:ProjectileAnimTag];
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
