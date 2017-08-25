//
//  UINavigationController+ZKAdd.m
//  Pods
//
//  Created by Kaiser on 2017/6/28.
//
//

#import "UINavigationController+ZKAdd.h"

@implementation UINavigationController (ZKAdd)

- (UIViewController *) viewControllerForClass:(Class)cls {
    for (UIViewController *each in self.viewControllers) {
        if ([each isKindOfClass:cls] == YES) {
            return each;
        }
    }
    
    return nil;
}

- (NSArray *) popToViewControllerClass:(Class)aClass animated:(BOOL)animated {
    UIViewController *controller = [self viewControllerForClass:aClass];
    
    return [self popToViewController:controller animated:animated];
}

- (UIViewController *) popThenPushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *controller = [self popViewControllerAnimated:NO];
    
    [self pushViewController:viewController animated:animated];
    
    return controller;
}

@end
