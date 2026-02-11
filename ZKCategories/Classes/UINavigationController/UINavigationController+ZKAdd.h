//
//  UINavigationController+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/6/28.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import "ZKCategoriesMacro.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZKNavigationAction) {
    ZKNavigationActionUnknow, // 初始、各种动作的 completed 之后都会立即转入 unknown 状态，此时的 appearing、disappearingViewController 均为 nil

    ZKNavigationActionWillPush,      // push 方法被触发，但尚未进行真正的 push 动作
    ZKNavigationActionDidPush,       // 系统的 push 已经执行完，viewControllers 已被刷新
    ZKNavigationActionPushCompleted, // push 动画结束（如果没有动画，则在 did push 后立即进入 completed）

    ZKNavigationActionWillPop,      // pop 方法被触发，但尚未进行真正的 pop 动作
    ZKNavigationActionDidPop,       // 系统的 pop 已经执行完，viewControllers 已被刷新（注意可能有 pop 失败的情况）
    ZKNavigationActionPopCompleted, // pop 动画结束（如果没有动画，则在 did pop 后立即进入 completed）

    ZKNavigationActionWillSet,      // setViewControllers 方法被触发，但尚未进行真正的 set 动作
    ZKNavigationActionDidSet,       // 系统的 setViewControllers 已经执行完，viewControllers 已被刷新
    ZKNavigationActionSetCompleted, // setViewControllers 动画结束（如果没有动画，则在 did set 后立即进入 completed）
};

typedef void (^ZKNavigationActionDidChangeBlock)(ZKNavigationAction action, BOOL animated, __kindof UINavigationController *_Nullable weakNavigationController, __kindof UIViewController *_Nullable appearingViewController, NSArray<__kindof UIViewController *> *_Nullable disappearingViewControllers);

@interface UINavigationController (ZKAdd)

@property (nonatomic, assign, readonly) ZKNavigationAction kai_navigationAction;

/**
 添加一个 block 用于监听当前 UINavigationController 的 push/pop/setViewControllers 操作，在即将进行、已经进行、动画已完结等各种状态均会回调。
 block 参数里的 appearingViewController 表示即将显示的界面。
 disappearingViewControllers 表示即将消失的界面，数组形式是因为可能一次性 pop 掉多个（例如 popToRootViewController、setViewControllers），此时只有 disappearingViewControllers.lastObject 可以看到 pop 动画。由于 pop 可能失败，所以 will 动作里的 disappearingViewControllers 最终不一定真的会被移除。
 weakNavigationController 是便于你引用 self 而避免循环引用（因为这个方法会令 self retain 你传进来的 block，而 block 内部如果直接用 self，就会 retain self，产生循环引用，所以这里给一个参数规避这个问题）。
 @note 无法添加一个只监听某个 ZKNavigationAction 的 block，每一个添加的 block 在任何一个 action 变化时都会被调用，需要 block 内部自己区分当前的 action。
 */
- (void)kai_addNavigationActionDidChangeBlock:(ZKNavigationActionDidChangeBlock _Nullable)block;

/// 系统的设定是当 UINavigationController 不可见时（例如上面盖着一个 present vc，或者切到别的 tab），push/pop 操作均不会调用 vc 的生命周期方法（viewDidLoad 也是在 nav 恢复可视时才触发），所以提供这个属性用于当你希望这种情况下依然调用生命周期方法时，你可以打开它。默认为 NO。
/// @warning 由于强制在 push/pop 时触发生命周期方法，所以会导致 vc 的 viewDidLoad 等方法比系统默认的更早调用，知悉即可。
@property (nonatomic, assign) BOOL kai_alwaysInvokeAppearanceMethods;

/// 是否在 push 的过程中
@property (nonatomic, readonly) BOOL kai_isPushing;

/// 是否在 pop 的过程中，包括手势、以及代码触发的 pop
@property (nonatomic, readonly) BOOL kai_isPopping;

/// 获取<b>rootViewController</b>
@property (nullable, nonatomic, readonly) UIViewController *kai_rootViewController;

/**
 * 一直 pop 直到栈顶是 aClass 类型的控制器，并返回被 pop 掉的 viewControllers
 */
- (NSArray *_Nullable)popToViewControllerClass:(Class _Nullable)cls animated:(BOOL)animated;

/*
 * 先 pop 再 push（用于替换当前栈顶控制器）
 *
 * http://stackoverflow.com/questions/410471/how-can-i-pop-a-view-from-a-uinavigationcontroller-and-replace-it-with-another-i
 */
- (UIViewController *_Nullable)popThenPushViewController:(UIViewController *_Nullable)viewController animated:(BOOL)animated;

@end

@interface UINavigationController (ZKFullscreenPopGesture)

/// 实际处理交互式返回的手势识别器。
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *_Nonnull kai_fullscreenPopGestureRecognizer;

/// 允许单个视图控制器自行控制导航栏显隐（通过 `kai_prefersNavigationBarHidden`），
/// 而非全局统一。默认为 YES；若不需要此行为可设为 NO。
@property (nonatomic, assign) BOOL kai_viewControllerBasedNavigationBarAppearanceEnabled ZK_API_DEPRECATED(ZKNavigationBarConfigureStyle);

@end

/// 允许任意视图控制器禁用全屏交互式返回手势；当该控制器自身需要处理滑动手势时可使用。
@interface UIViewController (ZKFullscreenPopGesture)

/// 当处于导航栈中时，是否禁用交互式返回手势。
@property (nonatomic, assign) BOOL kai_interactivePopDisabled;

/// 表示该视图控制器是否希望隐藏导航栏；在启用“按控制器控制导航栏外观”时生效。
/// 默认为 NO，即导航栏默认显示。
@property (nonatomic, assign) BOOL kai_prefersNavigationBarHidden ZK_API_DEPRECATED(ZKNavigationBarConfigureStyle);

/// 开始交互式返回手势时，允许的距左边缘的最大初始距离。默认为 0，表示不限制。
@property (nonatomic, assign) CGFloat kai_interactivePopMaxAllowedInitialDistanceToLeftEdge;

@end
