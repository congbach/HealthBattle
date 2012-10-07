//
//  GamePreLoadLayer.m
//  Bomberman
//
//  Created by Ken on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GamePreLoadLayer.h"

@interface GamePreLoadLayer ()
@end

@implementation GamePreLoadLayer

-(id) init
{
	self = [super init];
	if (self)
	{
        
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
