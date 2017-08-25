//
//  UIBarButtonItem+ZKAdd.m
//  shandiansong
//
//  Created by Kaiser on 2016/9/26.
//  Copyright © 2016年 zhiqiyun. All rights reserved.
//

#import "UIBarButtonItem+ZKAdd.h"
//#import "ZKThemesMacro.h"

@implementation UIBarButtonItem (ZKAdd)

+ (instancetype)itemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [button setTitle:title forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button setTitleColor:ZKCommonSubtitleTextColor forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    return [[self alloc] initWithCustomView:button];
}

+ (instancetype)itemWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    return [[self alloc] initWithCustomView:button];
}

@end
