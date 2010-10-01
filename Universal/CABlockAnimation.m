//
//  CABlockAnimation.m
//  FadingTouchView
//
//  Created by Dave DeLong on 9/17/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "CABlockAnimation.h"

@interface CABlockAnimationDelegate : NSObject
{
	CABlockAnimationStart startBlock;
	CABlockAnimationFinish finishBlock;
}

@property (nonatomic, copy) CABlockAnimationStart startBlock;
@property (nonatomic, copy) CABlockAnimationFinish finishBlock;

@end

@implementation CABlockAnimationDelegate
@synthesize startBlock, finishBlock;

- (void) dealloc {
	[startBlock release];
	[finishBlock release];
	[super dealloc];
}

- (void) animationDidStart:(CAAnimation *)anim {
	if (startBlock) {
		startBlock();
	}
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if (finishBlock) {
		finishBlock(flag);
	}
}

@end



@implementation CABlockAnimation

- (id) init {
	if (self = [super init]) {
		[self setDelegate:[[[CABlockAnimationDelegate alloc] init] autorelease]];
	}
	return self;
}

- (CABlockAnimationStart) startBlock {
	if ([[self delegate] respondsToSelector:@selector(startBlock)]) {
		return [[self delegate] startBlock];
	}
	return nil;
}

- (CABlockAnimationFinish) finishBlock {
	if ([[self delegate] respondsToSelector:@selector(finishBlock)]) {
		return [[self delegate] finishBlock];
	}
	return nil;
}

- (void) setStartBlock:(CABlockAnimationStart)start {
	if ([[self delegate] respondsToSelector:@selector(setStartBlock:)]) {
		[[self delegate] setStartBlock:start];
	}
}

- (void) setFinishBlock:(CABlockAnimationFinish)finish {
	if ([[self delegate] respondsToSelector:@selector(setFinishBlock:)]) {
		[[self delegate] setFinishBlock:finish];
	}
}

@end
