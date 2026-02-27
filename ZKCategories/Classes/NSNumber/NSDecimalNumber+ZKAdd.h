//
//  NSDecimalNumber+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/6/28.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

// Rounding policies :
// Original
//    value 1.2  1.21  1.25  1.35  1.27

// Plain    1.2  1.2   1.3   1.4   1.3
// Down     1.2  1.2   1.2   1.3   1.2
// Up       1.2  1.3   1.3   1.4   1.3
// Bankers  1.2  1.2   1.2   1.4   1.3

@interface NSDecimalNumber (ZKAdd)

/**
 *  @brief  四舍五入 NSRoundPlain
 *
 *  @param decimals 限制位数
 *
 *  @return 返回结果
 */
- (NSDecimalNumber *)decimalNumberWithDecimals:(NSUInteger)decimals;

/**
 *  @brief  四舍五入
 *
 *  @param decimals        限制位数
 *  @param roundingMode NSRoundingMode
 *
 *  @return 返回结果
 */
- (NSDecimalNumber *)decimalNumberWithDecimals:(NSUInteger)decimals mode:(NSRoundingMode)roundingMode;

/**
 *  @brief  按百分比计算，返回 self × percent（如 percent 为 0.5 表示 50%）
 *
 *  @param percent 百分比系数（0～1，如 0.85 表示 85%）
 *  @return 计算后的 NSDecimalNumber
 */
- (NSDecimalNumber *)decimalNumberWithPercentage:(float)percent;

/**
 *  @brief  按折扣百分比计算折后价，即 self - self × (discountPercentage/100)
 *  @param discountPercentage 折扣百分比（如 15 表示 85 折，即 15%  off）
 *  @return 折后价
 */
- (NSDecimalNumber *)decimalNumberWithDiscountPercentage:(NSDecimalNumber *)discountPercentage;

/**
 *  @brief  按折扣百分比计算折后价，并保留指定小数位
 *  @param discountPercentage 折扣百分比
 *  @param decimals 保留的小数位数
 *  @return 折后价
 */
- (NSDecimalNumber *)decimalNumberWithDiscountPercentage:(NSDecimalNumber *)discountPercentage decimals:(NSUInteger)decimals;

/**
 *  @brief  根据原价计算当前值对应的折扣百分比，即 (baseValue - self) / baseValue × 100
 *  @param baseValue 原价（基准值）
 *  @return 折扣百分比（如 15 表示 15% off）
 */
- (NSDecimalNumber *)discountPercentageWithBaseValue:(NSDecimalNumber *)baseValue;

/**
 *  @brief  根据原价计算折扣百分比，并保留指定小数位
 *  @param baseValue 原价（基准值）
 *  @param decimals 保留的小数位数
 *  @return 折扣百分比
 */
- (NSDecimalNumber *)discountPercentageWithBaseValue:(NSDecimalNumber *)baseValue decimals:(NSUInteger)decimals;

@end
