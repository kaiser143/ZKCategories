//
//  UIBlurEffect+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2025/2/26.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UIBlurEffect+ZKAdd.h"
#import "NSObject+ZKAdd.h"

@implementation UIBlurEffect (ZKAdd)

+ (instancetype)kai_effectWithBlurRadius:(CGFloat)radius {
    // -[UIBlurEffect effectWithBlurRadius:]
    UIBlurEffect *effect = [self safePerform:NSSelectorFromString(@"effectWithBlurRadius:") withArguments:&radius, nil];
    return effect;
}

- (UIBlurEffectStyle)kai_style {
    UIBlurEffectStyle style;
    // -[UIBlurEffect _style]
    [self safePerform:NSSelectorFromString(@"_style") withPrimitiveReturnValue:&style arguments:nil];
    return style;
}

@end
