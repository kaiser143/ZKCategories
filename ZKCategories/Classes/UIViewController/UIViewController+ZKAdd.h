//
//  UIViewController+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/25.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ZKAdd)

@property (nonatomic, assign, readonly) UIInterfaceOrientation interfaceOrientation;

/*!
 *  @brief    设置屏幕方向
 *  @param     interfaceOrientation     设备方向
 *  @param     completion     设置后，可以追加一些操作(是否隐藏导航栏等)
 *
 *  e.g.
 - (BOOL)shouldAutorotate {
     return YES;
 }

 - (UIInterfaceOrientationMask)supportedInterfaceOrientations {
     return UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskLandscapeRight;
 }

 - (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
     return UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight;
 }
 */
- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation completion:(dispatch_block_t)completion;

#pragma mark - :. 转场

/// push 操作，返回按钮无文字, 长按返回按钮去掉menu
- (void)kai_pushViewController:(UIViewController *)viewController;
- (void)kai_pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)kai_pushViewController:(UIViewController *)viewController backTitle:(NSString *)title animated:(BOOL)animated;

/// pop
- (void)kai_popViewControllerAnimated;
- (void)kai_popToRootViewControllerAnimated;

#pragma mark :. presentViewController

- (void)kai_presentViewController:(UIViewController *)newViewController;
- (void)kai_presentViewController:(UIViewController *)newViewController animated:(BOOL)animated;

/*!
 *  @brief    拦截返回按钮的action
 */
@property (nonatomic, copy) void(^kai_prefersPopViewControllerInjectBlock)(UIViewController * _Nonnull controller);

/// 可用于对  View 执行一些操作， 如果此时处于转场过渡中，这些操作会跟随转场进度以动画的形式展示过程
/// @param animation 要执行的操作
/// @param completion 转场完成或取消后的回调
/// @note 如果处于非转场过程中，也会执行 animation ，随后执行 completion，业务无需关心是否处于转场过程中。
- (void)animateAlongsideTransition:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))animation
                        completion:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))completion;

@end


@interface UIViewController (ZKInteractiveTransitionTableViewDeselection)

@property (nonatomic, weak) UITableView *kai_prefersTableViewDeselectRowWhenViewWillAppear;

@end


@interface UIViewController (ZKRuntime)

/**
 *  判断当前类是否有重写某个指定的 UIViewController 的方法
 *  @param selector 要判断的方法
 *  @return YES 表示当前类重写了指定的方法，NO 表示没有重写，使用的是 UIViewController 默认的实现
 */
- (BOOL)kai_hasOverrideUIKitMethod:(_Nonnull SEL)selector;
@end

NS_ASSUME_NONNULL_END
