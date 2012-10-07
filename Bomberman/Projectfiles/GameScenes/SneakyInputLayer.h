//
//  SneakyInputLayer.h
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "kobold2d.h"
#import "GameCommon.h"

@interface SneakyInputLayer : CCLayer

@property (nonatomic, readonly) Direction joystickDirection;
@property (nonatomic, readonly) BOOL padButtonActive;

- (void)updatePlayerHp:(int)hp;

@end
