//
//  UIViewController+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/25.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIViewController+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "UINavigationController+ZKAdd.h"

@implementation UIViewController (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(viewWillAppear:) withMethod:@selector(kai_viewWillAppear:)];
    [self swizzleMethod:@selector(viewDidDisappear:) withMethod:@selector(kai_viewDidDisappear:)];
}

- (void)kai_viewWillAppear:(BOOL)animated {
    [self kai_viewWillAppear:animated];

    UITableView *tableView = self.kai_prefersTableViewDeselectRowWhenViewWillAppear;
    if (tableView) {
        NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
        if (selectedIndexPath != nil) {
            id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
            if (coordinator != nil) {
                [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    [tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
                }
                    completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                        if (context.cancelled) {
                            [tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                        }
                    }];
            } else {
                [tableView deselectRowAtIndexPath:selectedIndexPath animated:animated];
            }
        }
    }
}

- (void)kai_viewDidDisappear:(BOOL)animated {
    [self kai_viewDidDisappear:animated];
}

- (void)kai_setNotificationsOn:(BOOL)notificationsOn {
    [self setAssociateValue:@(notificationsOn) withKey:@selector(kai_areNotificationsOn)];
}

- (BOOL)kai_areNotificationsOn {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation completion:(nonnull dispatch_block_t)completion {
    [self setAssociateValue:@(interfaceOrientation) withKey:@selector(interfaceOrientation)];
    
    if (@available(iOS 16.0, *)) {
        UIWindowScene *windowScene = self.view.window.windowScene;
        if (!windowScene) {
            return;
        }
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
        UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] init];
        geometryPreferences.interfaceOrientations                = interfaceOrientation;
        [windowScene requestGeometryUpdateWithPreferences:geometryPreferences
                                             errorHandler:^(NSError *_Nonnull error) {
                                                 //业务代码
                                                 ZKLog(@"menglc errorHandler error %@", error);
                                             }];
    } else if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = interfaceOrientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
    !completion ?: completion();
}

- (UIInterfaceOrientation)interfaceOrientation {
    NSNumber *value = [self associatedValueForKey:_cmd];
    if (!value) {
        value = @([UIDevice currentDevice].orientation);
        [self setAssociateValue:value withKey:@selector(interfaceOrientation)];
    }
    
    return [value integerValue];
}

#pragma mark - :. Back

- (void)setKai_prefersPopViewControllerInjectBlock:(void (^)(UIViewController * _Nonnull))block {
    self.kai_interactivePopDisabled = block != nil;
    
    [self setAssociateCopyValue:block withKey:@selector(kai_prefersPopViewControllerInjectBlock)];
}

- (void (^)(UIViewController * _Nonnull))kai_prefersPopViewControllerInjectBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)kai_pushViewController:(UIViewController *)viewController {
    [self kai_pushViewController:viewController animated:YES];
}

- (void)kai_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self kai_pushViewController:viewController backTitle:@"" animated:animated];
}

- (void)kai_pushViewController:(UIViewController *)viewController backTitle:(NSString *)title animated:(BOOL)animated {
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:nil];
    backBarButtonItem.stringProperty = @"__KAIExtra";
    self.navigationController.topViewController.navigationItem.backBarButtonItem = backBarButtonItem;
    [self.navigationController pushViewController:viewController animated:animated];
}

- (void)kai_popViewControllerAnimated {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)kai_popToRootViewControllerAnimated {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)kai_presentViewController:(UIViewController *)newViewController {
    [self kai_presentViewController:newViewController animated:YES];
}

- (void)kai_presentViewController:(UIViewController *)newViewController animated:(BOOL)animated {
    if (self.parentViewController)
        [self.parentViewController presentViewController:newViewController animated:animated completion:nil];
    else {
        UIViewController *rootViewController = [[UIApplication sharedApplication].windows firstObject].rootViewController;
        while (rootViewController.presentedViewController) {
            rootViewController = rootViewController.presentedViewController;
        }
        [rootViewController presentViewController:newViewController animated:animated completion:nil];
    }
}

- (void)animateAlongsideTransition:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))animation
                        completion:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))completion {
    if (self.transitionCoordinator) {
        BOOL animationQueuedToRun = [self.transitionCoordinator animateAlongsideTransition:animation completion:completion];
        // 某些情况下传给 animateAlongsideTransition 的 animation 不会被执行，这时候要自己手动调用一下
        // 但即便如此，completion 也会在动画结束后才被调用，因此这样写不会导致 completion 比 animation block 先调用
        // 某些情况包含：从 B 手势返回 A 的过程中，取消手势，animation 不会被调用
        // https://github.com/Tencent/QMUI_iOS/issues/692
        if (!animationQueuedToRun && animation) {
            animation(nil);
        }
    } else {
        if (animation) animation(nil);
        if (completion) completion(nil);
    }
}

@end

@implementation UINavigationController (__KAINavigationBackItemInjection)

+ (void)load {
    [self swizzleMethod:@selector(navigationBar:shouldPopItem:) withMethod:@selector(_kai_navigationBar:shouldPopItem:)];
}

// 修复Xcode11 iOS13 `navigationBar:shouldPopItem:` 不运行的问题
- (BOOL)_kai_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.topViewController.navigationItem != item) return YES;
    
    // Should pop. It appears called the pop view controller methods. We should pop items directly.
    if ([[self valueForKey:@"_isTransitioning"] boolValue]) return YES;
    
    UIView *barBackIndicatorView = navigationBar.subviews.lastObject;
    barBackIndicatorView.alpha = 1;
    
    UIViewController *topViewController = self.topViewController;
    void (^callback)(UIViewController *) = topViewController.kai_prefersPopViewControllerInjectBlock;
    if (!callback) [self popViewControllerAnimated:YES];
    else callback(topViewController);
    
    return NO;
}

@end

@implementation UIViewController (ZKInteractiveTransitionTableViewDeselection)

- (UITableView *)kai_prefersTableViewDeselectRowWhenViewWillAppear {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_prefersTableViewDeselectRowWhenViewWillAppear:(UITableView *)kai_prefersTableViewDeselectRowWhenViewWillAppear {
    [self setAssociateWeakValue:kai_prefersTableViewDeselectRowWhenViewWillAppear withKey:@selector(kai_prefersTableViewDeselectRowWhenViewWillAppear)];
}

@end

@implementation UIViewController (ZKRuntime)

- (BOOL)kai_hasOverrideUIKitMethod:(SEL)selector {
    // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
    NSMutableArray<Class> *viewControllerSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                               [UIImagePickerController class],
                                               [UINavigationController class],
                                               [UITableViewController class],
                                               [UICollectionViewController class],
                                               [UITabBarController class],
                                               [UISplitViewController class],
                                               [UIPageViewController class],
                                               [UIViewController class],
                                               nil];
    
    if (NSClassFromString(@"UIAlertController")) {
        [viewControllerSuperclasses addObject:[UIAlertController class]];
    }
    if (NSClassFromString(@"UISearchController")) {
        [viewControllerSuperclasses addObject:[UISearchController class]];
    }
    for (NSInteger i = 0, l = viewControllerSuperclasses.count; i < l; i++) {
        Class superclass = viewControllerSuperclasses[i];
        if ([self kai_hasOverrideMethod:selector ofSuperclass:superclass]) {
            return YES;
        }
    }
    return NO;
}

@end
