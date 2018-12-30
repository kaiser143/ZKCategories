//
//  UINavigationController+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/6/28.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import "UINavigationController+ZKAdd.h"

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
