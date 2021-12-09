//
//  UINavigationBar+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UINavigationBar+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "UIView+ZKAdd.h"
#import <objc/runtime.h>

@implementation UINavigationBar (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(layoutSubviews) withMethod:@selector(kai_layoutSubviews)];
}

#pragma mark -
#pragma mark :. Awesome

- (void)kai_layoutSubviews {
    [self kai_layoutSubviews];
    if (@available(iOS 13.0, *)) {
    } else if (@available(iOS 11.0, *)) {
        self.layoutMargins = UIEdgeInsetsZero;
        for (UIView *view in self.subviews) {
            if ([NSStringFromClass(view.classForCoder) containsString:@"ContentView"]) {
                view.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 10);
            }
        }
    }
}

@end
