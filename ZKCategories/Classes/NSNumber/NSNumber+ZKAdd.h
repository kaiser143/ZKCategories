//
//  NSNumber+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/11/22.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (ZKAdd)

- (CGFloat)CGFloatValue;

- (instancetype)initWithValue:(CGFloat)value;

+ (NSNumber *)numberWithValue:(CGFloat)value;

- (NSString *)stringWithDecimals:(NSInteger)decimals;

/**
 Creates and returns an NSNumber object from a string.
 Valid format: @"12", @"12.345", @" -0xFF", @" .23e99 "...
 
 @param string  The string described an number.
 
 @return an NSNumber when parse succeed, or nil if an error occurs.
 */
+ (nullable NSNumber *)numberWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
