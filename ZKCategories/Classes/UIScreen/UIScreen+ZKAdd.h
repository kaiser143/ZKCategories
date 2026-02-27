//
//  UIScreen+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 为 `UIScreen` 提供扩展。
 */
@interface UIScreen (ZKAdd)

/**
 主屏的 scale。
 
 @return 主屏 scale
 */
+ (CGFloat)screenScale;

/**
 返回当前设备方向下的屏幕边界。
 
 @return 表示屏幕边界的矩形。
 @see    boundsForOrientation:
 */
- (CGRect)currentBounds NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 返回指定设备方向下的屏幕边界。
 `UIScreen` 的 `bounds` 始终返回竖屏下的边界。
 
 @param orientation 用于获取屏幕边界的方向。
 @return 表示屏幕边界的矩形。
 @see  currentBounds
 */
- (CGRect)boundsForOrientation:(UIInterfaceOrientation)orientation;

/**
 屏幕的像素尺寸（宽度恒小于高度）。
 在未知设备或模拟器上可能不够准确。例如 (768,1024)。
 */
@property (nonatomic, readonly) CGSize sizeInPixel;

/**
 屏幕 PPI（每英寸像素）。
 在未知设备或模拟器上可能不够准确，默认 96。
 */
@property (nonatomic, readonly) CGFloat pixelsPerInch;

@end

NS_ASSUME_NONNULL_END
