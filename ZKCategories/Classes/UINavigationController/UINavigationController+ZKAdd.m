//
//  UINavigationController+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/6/28.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import "UINavigationController+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "UINavigationBar+ZKAdd.h"

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
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
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
    BOOL isLeftToRight = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
    CGFloat multiplier = isLeftToRight ? 1 : - 1;
    if ((translation.x * multiplier) <= 0) {
        return NO;
    }
    
    return YES;
}

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

@end

@implementation UINavigationController (KAIFullscreenPopGesture)

+ (void)load {
    // Inject "-pushViewController:animated:"
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(pushViewController:animated:) withMethod:@selector(_kai_pushViewController:animated:)];
        [self swizzleMethod:NSSelectorFromString(@"_updateInteractiveTransition:") withMethod:@selector(_kai_updateInteractiveTransition:)];
    });
}

- (void)_kai_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.kai_fullscreenPopGestureRecognizer]) {
        
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.kai_fullscreenPopGestureRecognizer];
        
        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
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
        delegate = [[_KAIFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        
        [self setAssociateValue:delegate withKey:_cmd];
    }
    return delegate;
}

- (UIPanGestureRecognizer *)kai_fullscreenPopGestureRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = [self associatedValueForKey:_cmd];
    
    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
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
