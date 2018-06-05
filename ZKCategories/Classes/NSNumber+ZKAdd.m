//
//  NSNumber+ZKAdd.m
//  kuaisong
//
//  Created by Kaiser on 2016/11/22.
//  Copyright © 2016年 zhiqiyun. All rights reserved.
//

#import "NSNumber+ZKAdd.h"

@implementation NSNumber (ZKAdd)

- (CGFloat)CGFloatValue {
#if (CGFLOAT_IS_DOUBLE == 1)
    CGFloat result = [self doubleValue];
#else
    CGFloat result = [self floatValue];
#endif
    return result;
}

- (instancetype)initWithValue:(CGFloat)value {
#if (CGFLOAT_IS_DOUBLE == 1)
    self = [self initWithDouble:value];
#else
    self = [self initWithFloat:value];
#endif
    return self;
}

+ (NSNumber *)numberWithValue:(CGFloat)value {
    NSNumber *returnValue = [[NSNumber alloc] initWithValue:value];
    return returnValue;
}

- (NSString *)stringWithDecimals:(NSInteger)decimals {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.locale = [NSLocale currentLocale];
    formatter.maximumFractionDigits = decimals;
    formatter.minimumFractionDigits = decimals;
    return [formatter stringFromNumber:self];
}

- (NSString *)roundBankerValue {
    NSString *stringValue;
    
    @autoreleasepool {
        if ([self isMemberOfClass:[NSDecimalNumber class]]) {
            NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                                                                                              scale:2
                                                                                                   raiseOnExactness:NO
                                                                                                    raiseOnOverflow:NO
                                                                                                   raiseOnUnderflow:NO
                                                                                                raiseOnDivideByZero:YES];
            NSDecimalNumber *roundedOunces = [(NSDecimalNumber *)self decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
            stringValue = roundedOunces.stringValue;
        } else {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setPositiveFormat:@"###,##0.00;"];
            stringValue = [formatter stringFromNumber:self];
        };
    }
    
    return stringValue;
}

@end
