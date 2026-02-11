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
 从内部派发表中移除指定事件（或事件组合）的所有 target 和 action。
 */
- (void)removeAllTargets;

/**
 为指定事件（或事件组合）设置或替换 target 和 action。

 @param target        接收 action 的目标对象；nil 时在响应链中查找能响应该 action 的对象。
 @param action        要执行的 selector，不能为 NULL。
 @param controlEvents 触发该 action 的控件事件掩码。
 */
- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/**
 为指定事件（或事件组合）添加一个 block。会对 block 强引用。

 @param block         事件触发时调用的 block（不能为 nil），会被持有。
 @param controlEvents 触发该 block 的控件事件掩码。
 */
- (void)addBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(__kindof UIControl *sender))block;

/**
 为指定事件（或事件组合）设置或替换 block。会对 block 强引用。

 @param block         事件触发时调用的 block（不能为 nil），会被持有。
 @param controlEvents 触发该 block 的控件事件掩码。
 */
- (void)setBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(__kindof UIControl *sender))block;

/**
 从内部派发表中移除指定事件（或事件组合）的所有 block。

 @param controlEvents 控件事件掩码。
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
