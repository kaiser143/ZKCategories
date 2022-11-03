//
//  UIViewController+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/25.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKKeyboardStatus) {
    ZKKeyboardStatusDidHide,
    ZKKeyboardStatusWillShow,
    ZKKeyboardStatusDidShow,
    ZKKeyboardStatusWillHide
};

typedef void (^ZKKeyboardFrameAnimationBlock)(CGRect keyboardFrame);

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

@end


@interface UIViewController (ZKInteractiveTransitionTableViewDeselection)

@property (nonatomic, weak) UITableView *kai_prefersTableViewDeselectRowWhenViewWillAppear;

@end


@interface UIViewController (ZKKeyboard)

@property (nonatomic, readonly) ZKKeyboardStatus keyboardStatus;

#pragma mark - Keyboard

- (void)setKeyboardWillShowAnimationBlock:(ZKKeyboardFrameAnimationBlock)willShowBlock;
- (void)setKeyboardWillHideAnimationBlock:(ZKKeyboardFrameAnimationBlock)willHideBlock;

- (void)setKeyboardDidShowActionBlock:(ZKKeyboardFrameAnimationBlock)didShowBlock;
- (void)setKeyboardDidHideActionBlock:(ZKKeyboardFrameAnimationBlock)didHideBlock;

@end

NS_ASSUME_NONNULL_END
