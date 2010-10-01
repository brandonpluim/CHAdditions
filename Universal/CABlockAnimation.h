//
//  CABlockAnimation.h
//  FadingTouchView
//
//  Created by Dave DeLong on 9/17/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef void(^CABlockAnimationStart)(void);
typedef void(^CABlockAnimationFinish)(BOOL);

@interface CABlockAnimation : CABasicAnimation {
	
}

@property (nonatomic, copy) CABlockAnimationStart startBlock;
@property (nonatomic, copy) CABlockAnimationFinish finishBlock;

@end
