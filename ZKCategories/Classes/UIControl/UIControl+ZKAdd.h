//
//  UIControl+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (ZKAdd)

/**
 Removes all targets and actions for a particular event (or events)
 from an internal dispatch table.
 */
- (void)removeAllTargets;

/**
 Adds or replaces a target and action for a particular event (or events)
 to an internal dispatch table.

 @param target         The target object—that is, the object to which the
 action message is sent. If this is nil, the responder
 chain is searched for an object willing to respond to the
 action message.

 @param action         A selector identifying an action message. It cannot be NULL.

 @param controlEvents  A bitmask specifying the control events for which the
 action message is sent.
 */
- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/**
 Adds a block for a particular event (or events) to an internal dispatch table.
 It will cause a strong reference to @a block.

 @param block          The block which is invoked then the action message is
 sent  (cannot be nil). The block is retained.

 @param controlEvents  A bitmask specifying the control events for which the
 action message is sent.
 */
- (void)addBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(__kindof UIControl *sender))block;

/**
 Adds or replaces a block for a particular event (or events) to an internal
 dispatch table. It will cause a strong reference to @a block.

 @param block          The block which is invoked then the action message is
 sent (cannot be nil). The block is retained.

 @param controlEvents  A bitmask specifying the control events for which the
 action message is sent.
 */
- (void)setBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(__kindof UIControl *sender))block;

/**
 Removes all blocks for a particular event (or events) from an internal
 dispatch table.

 @param controlEvents  A bitmask specifying the control events for which the
 action message is sent.
 */
- (void)removeAllBlocksForControlEvents:(UIControlEvents)controlEvents;

/*!
 *  @brief
 *  UIControl 被放在 UIScrollView 上时的点击体验。系统默认行为下，UIControl 在 UIScrollView 上会有300毫秒的延迟，当你快速点击某个 UIControl 时，将不会看到 setHighlighted 的效果。
 *  当置为 YES，会使用自己的一套计算方式去判断触发 setHighlighted 的时机，从而保证既不影响 UIScrollView 的滚动，又能让 UIControl 在被快速点击时也能立马看到 setHighlighted 的效果。
 */
@property (nonatomic, assign) BOOL automaticallyAdjustTouchHighlightedInScrollView;

/*!
 *  @brief  当置为 YES 时，连续的快速点击只有第一次会触发
 *  @warning 不能与 @c automaticallyAdjustTouchHighlightedInScrollView 同时开启。
 */
@property (nonatomic, assign) BOOL preventsRepeatedTouchUpInsideEvent;

@end

NS_ASSUME_NONNULL_END
