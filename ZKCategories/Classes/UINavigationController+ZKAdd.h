//
//  UINavigationController+ZKAdd.h
//  Pods
//
//  Created by Kaiser on 2017/6/28.
//
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
