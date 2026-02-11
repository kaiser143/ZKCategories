//
//  UIView+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/10/12.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZKAdd)

/**
 * 查找第一个属于指定类的后代视图（包括自身）。
 */
- (nullable __kindof UIView *)descendantOrSelfWithClass:(Class)cls;

/**
 * 查找第一个属于指定类的祖先视图（包括自身）。
 */
- (nullable __kindof UIView *)ancestorOrSelfWithClass:(Class)cls;

/**
 创建完整视图层级的快照图片。
 */
- (nullable UIImage *)snapshotImage;

/**
 创建完整视图层级的快照图片。
 @discussion 比 "snapshotImage" 更快，但可能触发屏幕更新。详见 -[UIView drawViewHierarchyInRect:afterScreenUpdates:]。
 */
- (nullable UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

/**
 创建完整视图层级的快照 PDF。
 */
- (nullable NSData *)snapshotPDF;

/**
 快捷设置 view.layer 的阴影
 
 @param color  阴影颜色
 @param offset 阴影偏移
 @param radius 阴影圆角半径
 */
- (void)setLayerShadow:(nullable UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

/**
 移除所有子视图。
 
 @warning 切勿在视图的 drawRect: 方法内调用此方法。
 */
- (void)removeAllSubviews;

/**
 返回该视图所在的视图控制器（可能为 nil）。
 */
@property (nullable, nonatomic, readonly) UIViewController *viewController;

/**
 返回在屏幕上的可见透明度（会考虑父视图和窗口）。
 */
@property (nonatomic, readonly) CGFloat visibleAlpha;

/**
 将点从接收者坐标系转换到指定视图或窗口的坐标系。
 
 @param point 在接收者本地坐标系（bounds）中的点。
 @param view  目标视图或窗口。若 view 为 nil，则转换到窗口基础坐标系。
 @return 转换到 view 坐标系后的点。
 */
- (CGPoint)convertPoint:(CGPoint)point toViewOrWindow:(nullable UIView *)view;

/**
 将点从指定视图或窗口的坐标系转换到接收者坐标系。
 
 @param point 在 view 本地坐标系（bounds）中的点。
 @param view  包含该点的视图或窗口。若 view 为 nil，则从窗口基础坐标系转换。
 @return 转换到接收者本地坐标系（bounds）后的点。
 */
- (CGPoint)convertPoint:(CGPoint)point fromViewOrWindow:(nullable UIView *)view;

/**
 将矩形从接收者坐标系转换到另一视图或窗口的坐标系。
 
 @param rect 在接收者本地坐标系（bounds）中的矩形。
 @param view 转换目标视图或窗口。若 view 为 nil，则转换到窗口基础坐标系。
 @return 转换后的矩形。
 */
- (CGRect)convertRect:(CGRect)rect toViewOrWindow:(nullable UIView *)view;

/**
 将矩形从另一视图或窗口的坐标系转换到接收者坐标系。
 
 @param rect 在 view 本地坐标系（bounds）中的矩形。
 @param view 包含该矩形的视图或窗口。若 view 为 nil，则从窗口基础坐标系转换。
 @return 转换后的矩形。
 */
- (CGRect)convertRect:(CGRect)rect fromViewOrWindow:(nullable UIView *)view;

@property (nonatomic) CGFloat left;    ///< frame.origin.x 的快捷方式。
@property (nonatomic) CGFloat top;     ///< frame.origin.y 的快捷方式。
@property (nonatomic) CGFloat right;   ///< frame.origin.x + frame.size.width 的快捷方式。
@property (nonatomic) CGFloat bottom;  ///< frame.origin.y + frame.size.height 的快捷方式。
@property (nonatomic) CGFloat width;   ///< frame.size.width 的快捷方式。
@property (nonatomic) CGFloat height;  ///< frame.size.height 的快捷方式。
@property (nonatomic) CGFloat centerX; ///< center.x 的快捷方式。
@property (nonatomic) CGFloat centerY; ///< center.y 的快捷方式。
@property (nonatomic) CGPoint origin;  ///< frame.origin 的快捷方式。
@property (nonatomic) CGSize size;     ///< frame.size 的快捷方式。

@property (nonatomic, copy) void(^didSubviewLayoutBlock)(UIView *view);

@end

@interface UIView (ZKActionHandlers)

/**
 为接收者绑定单击时执行的 block。
 @param block 要执行的 block。
 */
- (void)setTapActionWithBlock:(void (^)(void))block NS_SWIFT_NAME(setTapAction(block:));

/**
 为接收者绑定长按时执行的 block。
 @param block 要执行的 block。
 */
- (void)setLongPressActionWithBlock:(void (^)(void))block NS_SWIFT_NAME(setLongPressAction(block:));

@end

@interface UIView (ZKDebug)

/**
 @name 主线程检查
 */

/**
 开启或关闭对 UIView 若干方法的主线程检查。
 
 当前会对以下方法进行 swizzle 并检查：
 
 - setNeedsDisplay
 - setNeedsDisplayInRect:
 - setNeedsLayout
 
 这些方法会由 UIView 中多种方法触发（如 setBackgroundColor），因此无需 swizzle 所有方法。
 */
+ (void)toggleViewMainThreadChecking;

/**
 当 UIView 的某个重要方法不在主队列上调用时会被调用。
 
 使用 <toggleViewMainThreadChecking> 开启/关闭。在 -[UIView methodCalledNotFromMainThread:] 处断点可在调试器中捕获。
 @param methodName 被调用方法的符号名
 */
- (void)methodCalledNotFromMainThread:(NSString *)methodName;

@end

@interface UIView (ZKAutoLayout)

/**
 通过调用 layoutIfNeeded 对视图的约束进行动画。
 
 @param bounce YES 表示使用弹簧阻尼和速度实现弹性动画效果。
 @param options 动画选项掩码。
 @param animations 自定义动画的额外 block。
 */
- (void)animateLayoutIfNeededWithBounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^__nullable)(void))animations;

- (void)animateLayoutIfNeededWithBounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^__nullable)(BOOL finished))completion;

/**
 通过调用 layoutIfNeeded 对视图的约束进行动画。
 
 @param duration 动画总时长（秒）。
 @param bounce YES 表示使用弹簧阻尼和速度实现弹性动画效果。
 @param options 动画选项掩码。
 @param animations 自定义动画的额外 block。
 */
- (void)animateLayoutIfNeededWithDuration:(NSTimeInterval)duration bounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

/**
 返回与指定布局属性（top、bottom、left、right、leading、trailing 等）匹配的约束数组。
 
 @param attribute 用于查找的布局属性。
 @return 匹配的约束数组。
 */
- (nullable NSArray *)constraintsForAttribute:(NSLayoutAttribute)attribute;

/**
 返回与指定布局属性及两个 item（first、second）之间关系匹配的布局约束。
 
 @param attribute 用于查找的布局属性。
 @param first 关系中的第一个 item。
 @param second 关系中的第二个 item。
 @return 布局约束。
 */
- (nullable NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute firstItem:(id __nullable)first secondItem:(id __nullable)second;

@end


/*
 * @code
 - (id)initWithFrame:(CGRect)frame {
 if (self = [super initWithFrame:frame]) {
 [self loadContentsFromNib];
 [self awakeFromNib];
 }
 
 return self;
 }
 * @code
 */
@interface UIView (ZKNibLoading)

- (void)loadContentsFromNibNamed:(NSString *)nibName bundle:(NSBundle *)bundle;
- (void)loadContentsFromNibNamed:(NSString *)nibName;

// 便捷方法，加载与类名同名的 nib。
- (void)loadContentsFromNib;

// 用于放置 nib 中全部内容的视图。
- (UIView *)contentViewForNib;

@end

NS_ASSUME_NONNULL_END


#if __has_include("Masonry.h") || __has_include(<Masonry/Masonry.h>)

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

@interface UIView (Masonry)

- (id _Nonnull)kai_safeAreaLayoutGuideTop;
- (id _Nonnull)kai_safeAreaLayoutGuideBottom;
- (id _Nonnull)kai_safeAreaLayoutGuideLeft;
- (id _Nonnull)kai_safeAreaLayoutGuideRight;

@end

#endif
