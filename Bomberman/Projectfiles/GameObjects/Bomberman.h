//
//  Bomberman.h
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "kobold2d.h"
#import "GameObject.h"

static NSString * const BombermanAnimPrefix = @"Bomberman";

@interface Bomberman : GameObject

+ (CCSpriteBatchNode *)spriteBatchNode;

@end
