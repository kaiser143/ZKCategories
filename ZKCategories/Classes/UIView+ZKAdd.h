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

@interface UIView (ZKAutoLayout)

/**
 Animates the view's constraints by calling layoutIfNeeded.
 
 @param bounce YES if the animation should use spring damping and velocity to give a bouncy effect to animations.
 @param options A mask of options indicating how you want to perform the animations.
 @param animations An additional block for custom animations.
 */
- (void)animateLayoutIfNeededWithBounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^ __nullable)(void))animations;

- (void)animateLayoutIfNeededWithBounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion;

/**
 Animates the view's constraints by calling layoutIfNeeded.
 
 @param duration The total duration of the animations, measured in seconds.
 @param bounce YES if the animation should use spring damping and velocity to give a bouncy effect to animations.
 @param options A mask of options indicating how you want to perform the animations.
 @param animations An additional block for custom animations.
 */
- (void)animateLayoutIfNeededWithDuration:(NSTimeInterval)duration bounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

/**
 Returns the view constraints matching a specific layout attribute (top, bottom, left, right, leading, trailing, etc.)
 
 @param attribute The layout attribute to use for searching.
 @return An array of matching constraints.
 */
- (nullable NSArray *)constraintsForAttribute:(NSLayoutAttribute)attribute;

/**
 Returns a layout constraint matching a specific layout attribute and relationship between 2 items, first and second items.
 
 @param attribute The layout attribute to use for searching.
 @param first The first item in the relationship.
 @param second The second item in the relationship.
 @return A layout constraint.
 */
- (nullable NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute firstItem:(id __nullable)first secondItem:(id __nullable)second;

@end

NS_ASSUME_NONNULL_END
