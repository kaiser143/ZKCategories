//
//  UIResponder+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/5/18.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIResponder+ZKAdd.h"

static __weak id ___currentFirstResponder;

@implementation UIResponder (ZKAdd)

/**
 Based on Jakob Egger's answer in http://stackoverflow.com/a/14135456/590010
 */
+ (instancetype)currentFirstResponder {
    ___currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    
    return ___currentFirstResponder;
}

- (void)findFirstResponder:(id)sender {
    ___currentFirstResponder = self;
}

- (void)routerWithEventName:(NSString *)eventName userInfo:(nullable NSDictionary *)userInfo {
    [self.nextResponder routerWithEventName:eventName userInfo:userInfo];
}

@end
