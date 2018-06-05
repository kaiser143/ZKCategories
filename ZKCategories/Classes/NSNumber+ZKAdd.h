//
//  NSNumber+ZKAdd.h
//  kuaisong
//
//  Created by Kaiser on 2016/11/22.
//  Copyright © 2016年 zhiqiyun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (ZKAdd)

- (CGFloat)CGFloatValue;

- (instancetype)initWithValue:(CGFloat)value;

+ (NSNumber *)numberWithValue:(CGFloat)value;

- (NSString *)stringWithDecimals:(NSInteger)decimals;

@end

NS_ASSUME_NONNULL_END
