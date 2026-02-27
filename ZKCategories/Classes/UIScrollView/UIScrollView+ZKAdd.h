//
//  UIScrollView+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKScrollDirection) {
    ZKScrollDirectionUndefine,
    ZKScrollDirectionUp,
    ZKScrollDirectionDown,
    ZKScrollDirectionLeft,
    ZKScrollDirectionRight,
};

/**
 为 `UIScrollView` 提供扩展。
 */
@interface UIScrollView (ZKAdd)

@property (nonatomic, assign) CGFloat contentInsetTop;
@property (nonatomic, assign) CGFloat contentInsetBottom;
@property (nonatomic, assign) CGFloat contentInsetLeft;
@property (nonatomic, assign) CGFloat contentInsetRight;

@property (nonatomic, assign) CGFloat contentOffsetX;
@property (nonatomic, assign) CGFloat contentOffsetY;

@property (nonatomic, assign) CGFloat contentSizeWidth;
@property (nonatomic, assign) CGFloat contentSizeHeight;

- (ZKScrollDirection)scrollDirection;

/**
 * 判断当前的scrollView内容是否足够滚动
 * @warning 避免与<i>scrollEnabled</i>混淆
 */
- (BOOL)canScroll;

/**
 带动画滚动到顶部。
 */
- (void)scrollToTop;

/**
 带动画滚动到底部。
 */
- (void)scrollToBottom;

/**
 带动画滚动到左侧。
 */
- (void)scrollToLeft;

/**
 带动画滚动到右侧。
 */
- (void)scrollToRight;

/**
 滚动到顶部。
 
 @param animated 是否使用动画
 */
- (void)scrollToTopAnimated:(BOOL)animated;

/**
 滚动到底部。
 
 @param animated 是否使用动画
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

/**
 滚动到左侧。
 
 @param animated 是否使用动画
 */
- (void)scrollToLeftAnimated:(BOOL)animated;

/**
 滚动到右侧。
 
 @param animated 是否使用动画
 */
- (void)scrollToRightAnimated:(BOOL)animated;

- (NSInteger)pages;
- (NSInteger)currentPage;
- (CGFloat)scrollPercent;

- (CGFloat)pagesY;
- (CGFloat)pagesX;
- (CGFloat)currentPageY;
- (CGFloat)currentPageX;
- (void)setPageY:(CGFloat)page;
- (void)setPageX:(CGFloat)page;
- (void)setPageY:(CGFloat)page animated:(BOOL)animated;
- (void)setPageX:(CGFloat)page animated:(BOOL)animated;

#pragma mark -
#pragma mark :. ZKkeyboardControl

typedef void (^KeyboardWillBeDismissedBlock)(void);
typedef void (^KeyboardDidHideBlock)(void);
typedef void (^KeyboardDidShowBlock)(BOOL didShowed);
typedef void (^KeyboardDidScrollToPointBlock)(CGPoint point);
typedef void (^KeyboardWillSnapBackToPointBlock)(CGPoint point);

typedef void (^KeyboardWillChangeBlock)(CGRect keyboardRect, UIViewAnimationOptions options, double duration, BOOL showKeyboard);

@property (nonatomic, weak) UIView *keyboardView;

/**
 *  根据是否需要手势控制键盘消失注册键盘的通知
 *
 *  @param isPanGestured 手势的需要与否
 */
- (void)setupPanGestureControlKeyboardHide:(BOOL)isPanGestured;

/**
 *  不需要根据是否需要手势控制键盘消失remove键盘的通知，因为注册的时候，已经固定了这里是否需要释放手势对象了
 *
 *  @param isPanGestured 根据注册通知里面的YES or NO来进行设置，千万别搞错了
 */
- (void)disSetupPanGestureControlKeyboardHide:(BOOL)isPanGestured;

/**
 *  手势控制的时候，将要开始消失了，意思在UIView动画里面的animation里面，告诉键盘也需要跟着移动了，顺便需要移动inputView的位置啊！
 */
@property (nonatomic, copy) KeyboardWillBeDismissedBlock keyboardWillBeDismissed;

/**
 *  键盘刚好隐藏
 */
@property (nonatomic, copy) KeyboardDidHideBlock keyboardDidHide;

/**
 *  键盘刚好变换完成
 */
@property (nonatomic, copy) KeyboardDidShowBlock keyboardDidChange;

/**
 *  手势控制键盘，滑动到某一点的回调
 */
@property (nonatomic, copy) KeyboardDidScrollToPointBlock keyboardDidScrollToPoint;

/**
 *  手势控制键盘，滑动到键盘以下的某个位置，然后又想撤销隐藏的手势，告诉键盘又要显示出来啦！顺便需要移动inputView的位置啊！
 */
@property (nonatomic, copy) KeyboardWillSnapBackToPointBlock keyboardWillSnapBackToPoint;

/**
 *  键盘状态改变的回调
 */
@property (nonatomic, copy) KeyboardWillChangeBlock keyboardWillChange;

/**
 *  手势控制键盘的偏移量
 */
@property (nonatomic, assign) CGFloat messageInputBarHeight;

/**
 *  截长图
 */
- (void)snapshotImageWithBlock:(void(^)(UIImage *_Nullable image))block;

@end

NS_ASSUME_NONNULL_END
