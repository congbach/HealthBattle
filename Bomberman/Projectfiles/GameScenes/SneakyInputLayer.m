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
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "ColoredCircleSprite.h"

static NSString * const JoystickImage = @"Joystick.png";
static NSString * const PadButtonImage = @"GamePadButton.png";

@interface SneakyInputLayer ()

@property (nonatomic, strong) SneakyJoystick *joystick;
@property (nonatomic, strong) SneakyButton *padButton;

@property (nonatomic, strong) NSMutableArray *heartSprites;

@end

@implementation SneakyInputLayer

@synthesize joystick = _joystick;
@synthesize padButton = _padButton;
@synthesize heartSprites = _heartSprites;

-(id) init
{
	self = [super init];
	if (self)
	{
        SneakyJoystickSkinnedBase *joystick = [[SneakyJoystickSkinnedBase alloc] init];
		joystick.position = ccp(64, 64);
		joystick.backgroundSprite = [CCSprite spriteWithFile:JoystickImage];
        joystick.backgroundSprite.opacity = 128;
		joystick.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0, 0, joystick.backgroundSprite.size.width, joystick.backgroundSprite.size.height)];
        joystick.joystick.isDPad = YES;
		[self addChild:joystick];
        self.joystick = joystick.joystick;
        
        SneakyButtonSkinnedBase *padButton = [[SneakyButtonSkinnedBase alloc] init];
		padButton.position = ccp(430, 56);
		padButton.defaultSprite = [CCSprite spriteWithFile:PadButtonImage];
        padButton.activatedSprite = [CCSprite spriteWithFile:PadButtonImage];
        padButton.pressSprite = [CCSprite spriteWithFile:PadButtonImage];
        padButton.defaultSprite.opacity = 128;
		padButton.button = [[SneakyButton alloc] initWithRect:CGRectMake(0, 0, padButton.defaultSprite.size.width, padButton.defaultSprite.size.height)];
		self.padButton = padButton.button;
		[self addChild:padButton];
        
        self.heartSprites = [NSMutableArray array];
	}
	return self;
}

- (void)updatePlayerHp:(int)hp
{
    for (int i = self.heartSprites.count; i < hp; i++)
    {
        CCSprite *heartSprite = [CCSprite spriteWithFile:@"Heart.png"];
        heartSprite.position = CGPointMake(30 + i * 50, 290);
        //heartSprite.opacity = 128;
        [self addChild:heartSprite];
        [self.heartSprites addObject:heartSprite];
    }
    
    while ((int)self.heartSprites.count > hp)
    {
        [self removeChild:[self.heartSprites lastObject] cleanup:NO];
        [self.heartSprites removeLastObject];
    }

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

- (BOOL)padButtonActive
{
    return self.padButton.active;
}

@end
