//
//  UINavigationController+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/6/28.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import "NSObject+ZKAdd.h"
#import "UINavigationBar+ZKAdd.h"
#import "UINavigationController+ZKAdd.h"
#import "UIViewController+ZKAdd.h"
#import "ZKCGUtilities.h"

@interface _KAIFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation _KAIFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }

    // Ignore when the active view controller doesn't allow interactive pop.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.kai_interactivePopDisabled) {
        return NO;
    }

    // Ignore when the beginning location is beyond max allowed initial distance to left edge.
    CGPoint beginningLocation         = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.kai_interactivePopMaxAllowedInitialDistanceToLeftEdge;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }

    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }

    // Prevent calling the handler when the gesture begins in an opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    BOOL isLeftToRight  = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
    CGFloat multiplier  = isLeftToRight ? 1 : -1;
    if ((translation.x * multiplier) <= 0) {
        return NO;
    }

    return YES;
}

@end

@interface UINavigationController ()

@property (nonatomic, strong) NSMutableArray<ZKNavigationActionDidChangeBlock> *kai_navigationActionDidChangeBlocks;

@end

@implementation UINavigationController (ZKAdd)

- (UIViewController *)viewControllerForClass:(Class)cls {
    for (UIViewController *each in self.viewControllers) {
        if ([each isKindOfClass:cls] == YES) {
            return each;
        }
    }

    return nil;
}

- (NSArray *)popToViewControllerClass:(Class)aClass animated:(BOOL)animated {
    UIViewController *controller = [self viewControllerForClass:aClass];
    if (!controller) {
        return nil;
    }

    return [self popToViewController:controller animated:animated];
}

- (UIViewController *)popThenPushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *controller = [self popViewControllerAnimated:NO];

    [self pushViewController:viewController animated:animated];

    return controller;
}

- (void)setKai_navigationAction:(ZKNavigationAction)navigationAction
                       animated:(BOOL)animated
        appearingViewController:(UIViewController *)appearingViewController
    disappearingViewControllers:(NSArray<UIViewController *> *)disappearingViewControllers {
    BOOL valueChanged = self.kai_navigationAction != navigationAction;
    [self setAssociateValue:@(navigationAction) withKey:@selector(kai_navigationAction)];
    if (valueChanged && self.kai_navigationActionDidChangeBlocks.count) {
        [self.kai_navigationActionDidChangeBlocks enumerateObjectsUsingBlock:^(ZKNavigationActionDidChangeBlock _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            obj(navigationAction, animated, self, appearingViewController, disappearingViewControllers);
        }];
    }
}

- (ZKNavigationAction)kai_navigationAction {
    return [[self associatedValueForKey:_cmd] unsignedIntegerValue];
}

- (void)setKai_navigationActionDidChangeBlocks:(NSMutableArray<ZKNavigationActionDidChangeBlock> *)navigationActionDidChangeBlocks {
    [self setAssociateValue:navigationActionDidChangeBlocks withKey:@selector(kai_navigationActionDidChangeBlocks)];
}

- (NSMutableArray<ZKNavigationActionDidChangeBlock> *)kai_navigationActionDidChangeBlocks {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_alwaysInvokeAppearanceMethods:(BOOL)alwaysInvokeAppearanceMethods {
    [self setAssociateValue:@(alwaysInvokeAppearanceMethods) withKey:@selector(kai_alwaysInvokeAppearanceMethods)];
}

- (BOOL)kai_alwaysInvokeAppearanceMethods {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setKai_isPushing:(BOOL)kai_isPushing {
    [self setAssociateValue:@(kai_isPushing) withKey:@selector(kai_isPushing)];
}

- (BOOL)kai_isPushing {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setKai_isPopping:(BOOL)kai_isPopping {
    [self setAssociateValue:@(kai_isPopping) withKey:@selector(kai_isPopping)];
}

- (BOOL)kai_isPopping {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (nullable UIViewController *)kai_rootViewController {
    return self.viewControllers.firstObject;
}

@end

@implementation UINavigationController (KAIFullscreenPopGesture)

// Helper method to update gesture recognizer state for iOS 26+
- (void)kai_updatePopGestureState {
    if (@available(iOS 26, *)) {
        UIViewController *topVC = self.topViewController;
        if (topVC) {
            BOOL disabled                                       = topVC.kai_interactivePopDisabled;
            self.interactivePopGestureRecognizer.enabled        = !disabled;
            self.interactiveContentPopGestureRecognizer.enabled = !disabled;
        }
    }
}

+ (void)load {
    // Inject "-pushViewController:animated:"
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(pushViewController:animated:) withMethod:@selector(_kai_pushViewController:animated:)];
        [self swizzleMethod:NSSelectorFromString(@"_updateInteractiveTransition:") withMethod:@selector(_kai_updateInteractiveTransition:)];

#pragma mark - pushViewController:animated:
        OverrideImplementation([UINavigationController class], @selector(pushViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
                BOOL shouldInvokeAppearanceMethod = NO;

                if (selfObject.isViewLoaded && !selfObject.view.window) {
                    ZKLog(@"push 的时候 navigationController 不可见（例如上面盖着一个 present vc，或者切到别的 tab，可能导致 vc 的生命周期方法或者 UINavigationControllerDelegate 不会被调用");
                    if (selfObject.kai_alwaysInvokeAppearanceMethods) {
                        shouldInvokeAppearanceMethod = YES;
                    }
                }

                if ([selfObject.viewControllers containsObject:viewController]) {
                    NSAssert(NO, @"UINavigationController (ZKAdd)", @"不允许重复 push 相同的 viewController 实例，会产生 crash。当前 viewController：%@", viewController);
                    return;
                }

                // call super
                void (^callSuperBlock)(void) = ^void(void) {
                    void (*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, UIViewController *, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, viewController, animated);
                };

                BOOL willPushActually = viewController && ![viewController isKindOfClass:UITabBarController.class] && ![selfObject.viewControllers containsObject:viewController];

                if (!willPushActually) {
                    NSAssert(NO, @"UINavigationController (ZKAdd)", @"调用了 pushViewController 但实际上没 push 成功，viewController：%@", viewController);
                    callSuperBlock();
                    return;
                }

                UIViewController *appearingViewController                = viewController;
                NSArray<UIViewController *> *disappearingViewControllers = selfObject.topViewController ? @[selfObject.topViewController] : nil;

                [selfObject setKai_navigationAction:ZKNavigationActionWillPush animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

                if (shouldInvokeAppearanceMethod) {
                    [disappearingViewControllers.lastObject beginAppearanceTransition:NO animated:animated];
                    [appearingViewController beginAppearanceTransition:YES animated:animated];
                }

                callSuperBlock();

                [selfObject setKai_navigationAction:ZKNavigationActionDidPush animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

                [selfObject animateAlongsideTransition:nil
                                            completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
                                                [selfObject setKai_navigationAction:ZKNavigationActionPushCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                                                [selfObject setKai_navigationAction:ZKNavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];

                                                if (shouldInvokeAppearanceMethod) {
                                                    [disappearingViewControllers.lastObject endAppearanceTransition];
                                                    [appearingViewController endAppearanceTransition];
                                                }

                                                // Update gesture state for iOS 26+
                                                [selfObject kai_updatePopGestureState];
                                            }];
            };
        });
    });

#pragma mark - popViewControllerAnimated:
    OverrideImplementation([UINavigationController class], @selector(popViewControllerAnimated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
        return ^UIViewController *(UINavigationController *selfObject, BOOL animated) {
            // call super
            UIViewController * (^callSuperBlock)(void) = ^UIViewController *(void) {
                UIViewController *(*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP        = (UIViewController * (*)(id, SEL, BOOL)) originalIMPProvider();
                UIViewController *result = originSelectorIMP(selfObject, originCMD, animated);
                return result;
            };

            ZKNavigationAction action = selfObject.kai_navigationAction;
            if (action != ZKNavigationActionUnknow) {
                ZKLog(@"popViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop, viewControllers = %@", selfObject.viewControllers);
            }
            BOOL willPopActually = selfObject.viewControllers.count > 1 && action == ZKNavigationActionUnknow; // 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做

            if (!willPopActually) {
                return callSuperBlock();
            }

            BOOL shouldInvokeAppearanceMethod = NO;

            if (selfObject.isViewLoaded && !selfObject.view.window) {
                ZKLog(@"pop 的时候 navigationController 不可见（例如上面盖着一个 present vc，或者切到别的 tab，可能导致 vc 的生命周期方法或者 UINavigationControllerDelegate 不会被调用");
                if (selfObject.kai_alwaysInvokeAppearanceMethods) {
                    shouldInvokeAppearanceMethod = YES;
                }
            }

            UIViewController *appearingViewController                = selfObject.viewControllers[selfObject.viewControllers.count - 2];
            NSArray<UIViewController *> *disappearingViewControllers = selfObject.viewControllers.lastObject ? @[selfObject.viewControllers.lastObject] : nil;

            [selfObject setKai_navigationAction:ZKNavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

            if (shouldInvokeAppearanceMethod) {
                [disappearingViewControllers.lastObject beginAppearanceTransition:NO animated:animated];
                [appearingViewController beginAppearanceTransition:YES animated:animated];
            }

            UIViewController *result = callSuperBlock();

            // UINavigationController 不可见时 return 值可能为 nil
            // https://github.com/Tencent/QMUI_iOS/issues/1180
            NSAssert(result && disappearingViewControllers && disappearingViewControllers.firstObject == result, @"UINavigationController (ZKAdd)", @"ZKCategories 认为 popViewController 会成功，但实际上失败了，result = %@, disappearingViewControllers = %@", result, disappearingViewControllers);
            disappearingViewControllers = result ? @[result] : disappearingViewControllers;

            [selfObject setKai_navigationAction:ZKNavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

            void (^transitionCompletion)(void) = ^void(void) {
                [selfObject setKai_navigationAction:ZKNavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                [selfObject setKai_navigationAction:ZKNavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];

                if (shouldInvokeAppearanceMethod) {
                    [disappearingViewControllers.lastObject endAppearanceTransition];
                    [appearingViewController endAppearanceTransition];
                }

                // Update gesture state for iOS 26+
                [selfObject kai_updatePopGestureState];
            };
            if (!result) {
                // 如果系统的 pop 没有成功，实际上提交给 animateAlongsideTransition:completion: 的 completion 并不会被执行，所以这里改为手动调用
                if (transitionCompletion) {
                    transitionCompletion();
                }
            } else {
                [selfObject animateAlongsideTransition:nil
                                            completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
                                                if (transitionCompletion) {
                                                    transitionCompletion();
                                                }
                                            }];
            }

            return result;
        };
    });

#pragma mark - popToViewController:animated:
    OverrideImplementation([UINavigationController class], @selector(popToViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
        return ^NSArray<UIViewController *> *(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {

            // call super
            NSArray<UIViewController *> * (^callSuperBlock)(void) = ^NSArray<UIViewController *> *(void) {
                NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                originSelectorIMP                                  = (NSArray<UIViewController *> * (*)(id, SEL, UIViewController *, BOOL)) originalIMPProvider();
                NSArray<UIViewController *> *poppedViewControllers = originSelectorIMP(selfObject, originCMD, viewController, animated);
                return poppedViewControllers;
            };

            ZKNavigationAction action = selfObject.kai_navigationAction;
            if (action != ZKNavigationActionUnknow) {
                ZKLog(@"popToViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop, currentViewControllers = %@, viewController = %@", selfObject.viewControllers, viewController);
            }
            BOOL willPopActually = selfObject.viewControllers.count > 1 && [selfObject.viewControllers containsObject:viewController] && selfObject.topViewController != viewController && action == ZKNavigationActionUnknow; // 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做

            if (!willPopActually) {
                return callSuperBlock();
            }

            UIViewController *appearingViewController                = viewController;
            NSArray<UIViewController *> *disappearingViewControllers = nil;
            NSUInteger index                                         = [selfObject.viewControllers indexOfObject:appearingViewController];
            if (index != NSNotFound) {
                disappearingViewControllers = [selfObject.viewControllers subarrayWithRange:NSMakeRange(index + 1, selfObject.viewControllers.count - index - 1)];
            }

            [selfObject setKai_navigationAction:ZKNavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

            NSArray<UIViewController *> *result = callSuperBlock();

            NSAssert(!(selfObject.isViewLoaded && selfObject.view.window) || [result isEqualToArray:disappearingViewControllers], @"UINavigationController (ZKAdd)", @"ZKCategories 计算得到的 popToViewController 结果和系统的不一致");
            disappearingViewControllers = result ?: disappearingViewControllers;

            [selfObject setKai_navigationAction:ZKNavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

            [selfObject animateAlongsideTransition:nil
                                        completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
                                            [selfObject setKai_navigationAction:ZKNavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                                            [selfObject setKai_navigationAction:ZKNavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];

                                            // Update gesture state for iOS 26+
                                            [selfObject kai_updatePopGestureState];
                                        }];

            return result;
        };
    });

#pragma mark - popToRootViewControllerAnimated:
    OverrideImplementation([UINavigationController class], @selector(popToRootViewControllerAnimated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
        return ^NSArray<UIViewController *> *(UINavigationController *selfObject, BOOL animated) {

            // call super
            NSArray<UIViewController *> * (^callSuperBlock)(void) = ^NSArray<UIViewController *> *(void) {
                NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP                   = (NSArray<UIViewController *> * (*)(id, SEL, BOOL)) originalIMPProvider();
                NSArray<UIViewController *> *result = originSelectorIMP(selfObject, originCMD, animated);
                return result;
            };

            ZKNavigationAction action = selfObject.kai_navigationAction;
            if (action != ZKNavigationActionUnknow) {
                ZKLog(@"popToRootViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop, viewControllers = %@", selfObject.viewControllers);
            }
            BOOL willPopActually = selfObject.viewControllers.count > 1 && action == ZKNavigationActionUnknow;

            if (!willPopActually) {
                return callSuperBlock();
            }

            UIViewController *appearingViewController                = selfObject.kai_rootViewController;
            NSArray<UIViewController *> *disappearingViewControllers = [selfObject.viewControllers subarrayWithRange:NSMakeRange(1, selfObject.viewControllers.count - 1)];

            [selfObject setKai_navigationAction:ZKNavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

            NSArray<UIViewController *> *result = callSuperBlock();

            // UINavigationController 不可见时 return 值可能为 nil
            // https://github.com/Tencent/QMUI_iOS/issues/1180
            NSAssert(!(selfObject.isViewLoaded && selfObject.view.window) || [result isEqualToArray:disappearingViewControllers], @"UINavigationController (ZKAdd)", @"ZKCategories 计算得到的 popToRootViewController 结果和系统的不一致");
            disappearingViewControllers = result ?: disappearingViewControllers;

            [selfObject setKai_navigationAction:ZKNavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

            [selfObject animateAlongsideTransition:nil
                                        completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
                                            [selfObject setKai_navigationAction:ZKNavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                                            [selfObject setKai_navigationAction:ZKNavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];

                                            // Update gesture state for iOS 26+
                                            [selfObject kai_updatePopGestureState];
                                        }];

            return result;
        };
    });

#pragma mark - setViewControllers:animated:
    OverrideImplementation([UINavigationController class], @selector(setViewControllers:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
        return ^(UINavigationController *selfObject, NSArray<UIViewController *> *viewControllers, BOOL animated) {
            if (viewControllers.count != [NSSet setWithArray:viewControllers].count) {
                NSAssert(NO, @"UINavigationController (ZKAdd)", @"setViewControllers 数组里不允许出现重复元素：%@", viewControllers);
                viewControllers = [NSOrderedSet orderedSetWithArray:viewControllers].array; // 这里会保留该 vc 第一次出现的位置不变
            }

            UIViewController *appearingViewController                       = selfObject.topViewController != viewControllers.lastObject ? viewControllers.lastObject : nil; // setViewControllers 执行前后 topViewController 没有变化，则赋值为 nil，表示没有任何界面有“重新显示”，这个 nil 的值也用于在 ZKNavigationController 里实现 viewControllerKeepingAppearWhenSetViewControllersWithAnimated:
            NSMutableArray<UIViewController *> *disappearingViewControllers = selfObject.viewControllers.mutableCopy;
            [disappearingViewControllers removeObjectsInArray:viewControllers];
            disappearingViewControllers = disappearingViewControllers.count ? disappearingViewControllers : nil;

            [selfObject setKai_navigationAction:ZKNavigationActionWillSet animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

            // call super
            void (*originSelectorIMP)(id, SEL, NSArray<UIViewController *> *, BOOL);
            originSelectorIMP = (void (*)(id, SEL, NSArray<UIViewController *> *, BOOL))originalIMPProvider();
            originSelectorIMP(selfObject, originCMD, viewControllers, animated);

            [selfObject setKai_navigationAction:ZKNavigationActionDidSet animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

            [selfObject animateAlongsideTransition:nil
                                        completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
                                            [selfObject setKai_navigationAction:ZKNavigationActionSetCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                                            [selfObject setKai_navigationAction:ZKNavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];

                                            // Update gesture state for iOS 26+
                                            [selfObject kai_updatePopGestureState];
                                        }];
        };
    });
}

- (void)_kai_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES;
    }

    if (@available(iOS 26, *)) {
    } else if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.kai_fullscreenPopGestureRecognizer]) {
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.kai_fullscreenPopGestureRecognizer];

        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets                         = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget                                = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction                               = NSSelectorFromString(@"handleNavigationTransition:");
        self.kai_fullscreenPopGestureRecognizer.delegate = self.kai_popGestureRecognizerDelegate;
        [self.kai_fullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];

        // Disable the onboard gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = NO;
    }

    // Forward to primary implementation.
    if (![self.viewControllers containsObject:viewController]) {
        [self _kai_pushViewController:viewController animated:animated];
    }
}

- (void)_kai_updateInteractiveTransition:(CGFloat)percentComplete {
    [self _kai_updateInteractiveTransition:percentComplete];
}

- (_KAIFullscreenPopGestureRecognizerDelegate *)kai_popGestureRecognizerDelegate {
    _KAIFullscreenPopGestureRecognizerDelegate *delegate = [self associatedValueForKey:_cmd];

    if (!delegate) {
        delegate                      = [[_KAIFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;

        [self setAssociateValue:delegate withKey:_cmd];
    }
    return delegate;
}

- (UIPanGestureRecognizer *)kai_fullscreenPopGestureRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = [self associatedValueForKey:_cmd];

    if (!panGestureRecognizer) {
        panGestureRecognizer                        = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;

        [self setAssociateValue:panGestureRecognizer withKey:_cmd];
    }
    return panGestureRecognizer;
}

- (BOOL)kai_viewControllerBasedNavigationBarAppearanceEnabled {
    NSNumber *number = [self associatedValueForKey:_cmd];
    if (number) {
        return number.boolValue;
    }
    self.kai_viewControllerBasedNavigationBarAppearanceEnabled = YES;
    return YES;
}

- (void)setKai_viewControllerBasedNavigationBarAppearanceEnabled:(BOOL)enabled {
    SEL key = @selector(kai_viewControllerBasedNavigationBarAppearanceEnabled);
    [self setAssociateValue:@(enabled) withKey:key];
}

- (BOOL)isKai_grTransitioning {
    NSNumber *number = [self associatedValueForKey:_cmd];
    return number.boolValue;
}

- (void)setKai_grTransitioning:(BOOL)kai_grTransitioning {
    [self setAssociateValue:@(kai_grTransitioning) withKey:@selector(isKai_grTransitioning)];
}

@end

@implementation UIViewController (KAIFullscreenPopGesture)

- (BOOL)kai_interactivePopDisabled {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setKai_interactivePopDisabled:(BOOL)disabled {
    [self setAssociateValue:@(disabled) withKey:@selector(kai_interactivePopDisabled)];

    // For iOS 26+, update system gesture recognizers dynamically
    if (@available(iOS 26, *)) {
        UINavigationController *navigationController = self.navigationController;
        if (navigationController) {
            // Update immediately if this is the top view controller
            if (navigationController.topViewController == self) {
                navigationController.interactivePopGestureRecognizer.enabled        = !disabled;
                navigationController.interactiveContentPopGestureRecognizer.enabled = !disabled;
            }
            // Also schedule an update on next run loop in case we're called during transition
            dispatch_async_on_main_queue(^{
                if (navigationController.topViewController == self) {
                    navigationController.interactivePopGestureRecognizer.enabled        = !disabled;
                    navigationController.interactiveContentPopGestureRecognizer.enabled = !disabled;
                }
            });
        }
    }
}

- (BOOL)kai_prefersNavigationBarHidden {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setKai_prefersNavigationBarHidden:(BOOL)hidden {
    [self setAssociateValue:@(hidden) withKey:@selector(kai_prefersNavigationBarHidden)];
}

- (CGFloat)kai_interactivePopMaxAllowedInitialDistanceToLeftEdge {
#if CGFLOAT_IS_DOUBLE
    return [[self associatedValueForKey:_cmd] doubleValue];
#else
    return [[self associatedValueForKey:_cmd] floatValue];
#endif
}

- (void)setKai_interactivePopMaxAllowedInitialDistanceToLeftEdge:(CGFloat)distance {
    SEL key = @selector(kai_interactivePopMaxAllowedInitialDistanceToLeftEdge);
    [self setAssociateValue:@(MAX(0, distance)) withKey:key];
}

@end
