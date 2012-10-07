//
//  SneakyInputLayer.m
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SneakyInputLayer.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"
#import "ColoredCircleSprite.h"

static NSString * const JoystickImage = @"Joystick.png";

@interface SneakyInputLayer ()

@property (nonatomic, strong) SneakyJoystick *joystick;

@end

@implementation SneakyInputLayer

@synthesize joystick = _joystick;

-(id) init
{
	self = [super init];
	if (self)
	{
        SneakyJoystickSkinnedBase *leftJoy = [[SneakyJoystickSkinnedBase alloc] init];
		leftJoy.position = ccp(64,64);
		leftJoy.backgroundSprite = [CCSprite spriteWithFile:JoystickImage];
        leftJoy.backgroundSprite.opacity = 128;
		leftJoy.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0, 0, leftJoy.backgroundSprite.size.width, leftJoy.backgroundSprite.size.height)];
        leftJoy.joystick.isDPad = YES;
		[self addChild:leftJoy];
        self.joystick = leftJoy.joystick;
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

- (Direction)joystickDirection
{
    if (! roundf(self.joystick.velocity.x))
        return self.joystick.velocity.y == 1 ? kDirectionUp : self.joystick.velocity.y == -1 ? kDirectionDown : kNoDirection;
    else
        return self.joystick.velocity.x == 1 ? kDirectionRight : kDirectionLeft;
}

@end
