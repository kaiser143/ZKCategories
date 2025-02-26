//
//  UIBlurEffect+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2025/2/26.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBlurEffect (ZKAdd)

/**
 创建一个指定模糊半径的磨砂效果，注意这种方式创建的磨砂对象的 style 属性是无意义的（可以理解为系统的磨砂有两个维度：style、radius）。
 */
+ (instancetype)kai_effectWithBlurRadius:(CGFloat)radius;

/**
 获取当前 UIBlurEffect 的 style，前提是该 UIBlurEffect 对象是通过 effectWithStyle: 方式创建的。如果是通过指定 radius 方式创建的，则 qmui_style 会返回一个无意义的值。
 */
@property(nonatomic, assign, readonly) UIBlurEffectStyle kai_style;

@end

NS_ASSUME_NONNULL_END
