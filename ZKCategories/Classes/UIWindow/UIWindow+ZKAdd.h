//
//  UIWindow+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (ZKAdd)

/**
 * 从当前 window 起递归查找视图层级中的第一响应者。
 */
- (__kindof UIView *)findFirstResponder;

/**
 * 从 topView 起递归查找视图层级中的第一响应者。
 */
- (__kindof UIView *)findFirstResponderInView:(UIView *)topView;

@end

NS_ASSUME_NONNULL_END
