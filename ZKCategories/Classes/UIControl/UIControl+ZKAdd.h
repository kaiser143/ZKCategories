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

/**
 是否优化 UIControl 被放在 UIScrollView 上时的点击体验。系统默认行为下，UIControl 在 UIScrollView 上会有 300 毫秒的延迟，当你快速点击某个 UIControl 时，将不会看到 setHighlighted 的效果。

 此时可以将该属性置为 YES，会使用自己的一套计算方式去判断触发 setHighlighted 的时机：
 - 手指按下后未满 300ms：不因 touchesBegan 进入高亮，避免拖动滚动时控件误高亮，从而不影响 UIScrollView 滚动；
 - 按住超过 300ms 且未移动：进入高亮；
 - 快速点击（抬起时仍在控件内）：在 touchesEnded 时短暂高亮，保证能看到点击反馈。

 @warning 使用了这个属性则不需要设置 UIScrollView.delaysContentTouches。因为如果将 UIScrollView.delaysContentTouches 置为 NO 来取消这个延迟，则系统无法判断 touch 时是要点击还是要滚动，你就会观察到当你想要滚动 UIScrollView 时，手指触摸到的那个 UIControl 会呈现出 highlighted 的效果，但通常这并不符合预期。
 */
@property (nonatomic, assign) BOOL automaticallyAdjustTouchHighlightedInScrollView;

/**
 当快速重复点击某个 UIControl 时，系统的默认行为是每次点击都会触发一次 UIControlEventTouchUpInside 事件，但通常这并不是我们想要的，可能会导致某段逻辑被重复触发。因此提供这个属性，当置为 YES 时，连续的快速点击只有第一次会触发 UIControlEventTouchUpInside，当停止 300ms 后再重新点击，才会重新触发一次 UIControlEventTouchUpInside。该属性对非 UIControlEventTouchUpInside 的事件无效。

 @warning 不能与 @c automaticallyAdjustTouchHighlightedInScrollView 同时开启。
 */
@property (nonatomic, assign) BOOL preventsRepeatedTouchUpInsideEvent;

@end

NS_ASSUME_NONNULL_END
