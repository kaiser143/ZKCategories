//
//  UIWindow+ZKAdd.h
//  Pods
//
//  Created by Kaiser on 2016/12/14.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (ZKAdd)

/**
 * Searches the view hierarchy recursively for the first responder, starting with this window.
 */
- (UIView *)findFirstResponder;

/**
 * Searches the view hierarchy recursively for the first responder, starting with topView.
 */
- (UIView *)findFirstResponderInView:(UIView *)topView;

@end

NS_ASSUME_NONNULL_END
