//
//  UIView+ZKAdd.h
//  shandiansong
//
//  Created by Kaiser on 2016/10/12.
//  Copyright © 2016年 zhiqiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZKAdd)

/**
 * Finds the first descendant view (including this view) that is a member of a particular class.
 */
- (nullable UIView *)descendantOrSelfWithClass:(Class)cls;

/**
 * Finds the first ancestor view (including this view) that is a member of a particular class.
 */
- (nullable UIView *)ancestorOrSelfWithClass:(Class)cls;

// AutoLayout
- (void)animateConstraintsWithDuration:(NSTimeInterval)duration;

@end


@interface UIView (ZKActionHandlers)

/**
 Attaches the given block for a single tap action to the receiver.
 @param block The block to execute.
 */
- (void)setTapActionWithBlock:(void (^)(void))block;

/**
 Attaches the given block for a long press action to the receiver.
 @param block The block to execute.
 */
- (void)setLongPressActionWithBlock:(void (^)(void))block;

@end

@interface UIView (ZKDebug)

/**
@name Main Thread Checking
*/

/**
 Toggles on/off main thread checking on several methods of UIView.
 
 Currently the following methods are swizzeled and checked:
 
 - setNeedsDisplay
 - setNeedsDisplayInRect:
 - setNeedsLayout
 
 Those are triggered by a variety of methods in UIView, e.g. setBackgroundColor and thus it is not necessary to swizzle all of them.
 */
+ (void)toggleViewMainThreadChecking;

/**
 Method that gets called if one of the important methods of UIView is not being called on a main queue.
 
 Toggle this on/off with <toggleViewMainThreadChecking>. Break on -[UIView methodCalledNotFromMainThread:] to catch it in debugger.
 @param methodName Symbolic name of the method being called
 */
- (void)methodCalledNotFromMainThread:(NSString *)methodName;

@end

NS_ASSUME_NONNULL_END
