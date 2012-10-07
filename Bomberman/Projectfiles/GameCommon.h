//
//  GameCommon.h
//  Bomberman
//
//  Created by Ken on 10/6/12.
//
//

typedef enum { kNoDirection, kDirectionLeft, kDirectionRight, kDirectionUp, kDirectionDown } Direction;

#define DirectionName(direction) (direction == kDirectionLeft ? @"Left" : direction == kDirectionRight ? @"Right" : direction == kDirectionUp ? @"Up" : direction == kDirectionDown ? @"Down" : @"NoDirection")

#define SPRITE_BATCH_NODE_WITH_NAME(prefix) \
    [NSString stringWithFormat:@"%@.png", prefix]
#define PLIST_WITH_NAME(prefix) \
    [NSString stringWithFormat:@"%@.plist", prefix]