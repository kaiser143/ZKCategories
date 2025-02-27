//
//  NSAttributedString+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2025/2/27.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "NSAttributedString+ZKAdd.h"
#import "ZKCGUtilities.h"

@implementation NSAttributedString (ZKAdd)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self safety_NSAttributedString];
    });
}

+ (void)safety_NSAttributedString {
    id (^initWithStringBlock)(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) = ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
        return ^id (id selfObject, NSString *str) {
            
            str = str ?: @"";
            
            // call super
            id(*originSelectorIMP)(id, SEL, NSString *);
            originSelectorIMP = (id (*)(id, SEL, NSString *))originalIMPProvider();
            id result = originSelectorIMP(selfObject, originCMD, str);
            
            return result;
        };
    };
    
    id (^initWithStringAttributesBlock)(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) = ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
        return ^id (id selfObject, NSString *str, NSDictionary<NSString *, id> *attrs) {
            
            str = str ?: @"";
            
            // call super
            id(*originSelectorIMP)(id, SEL, NSString *, NSDictionary<NSString *, id> *);
            originSelectorIMP = (id (*)(id, SEL, NSString *, NSDictionary<NSString *, id> *))originalIMPProvider();
            id result = originSelectorIMP(selfObject, originCMD, str, attrs);
            
            return result;
        };
    };
    
    // 类簇对不同的 init 方法对应不同的私有 class，所以要用实例来得到真正的class
    OverrideImplementation([[[NSAttributedString alloc] initWithString:@""] class], @selector(initWithString:), initWithStringBlock);
    OverrideImplementation([[[NSMutableAttributedString alloc] initWithString:@""] class], @selector(initWithString:), initWithStringBlock);
    OverrideImplementation([[[NSAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), initWithStringAttributesBlock);
    OverrideImplementation([[[NSMutableAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), initWithStringAttributesBlock);
}

@end
