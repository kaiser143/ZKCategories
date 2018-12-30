//
//  UINavigationController+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/6/28.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (ZKAdd)

/**
 * pop to the first object is kind of aClass and return poped viewControllers
 */
- (NSArray *)popToViewControllerClass:(Class)cls animated:(BOOL)animated;

/*
 * pop and then push
 *
 * http://stackoverflow.com/questions/410471/how-can-i-pop-a-view-from-a-uinavigationcontroller-and-replace-it-with-another-i
 */
- (UIViewController *)popThenPushViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
