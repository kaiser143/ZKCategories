//
//  UIBarButtonItem+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/9/26.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UIBarButtonItem+ZKAdd.h"
#import "NSObject+ZKAdd.h"

@interface _ZKUIBarButtonItemBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);

- (id)initWithBlock:(void (^)(id sender))block;
- (void)invoke:(id)sender;

@end

@implementation _ZKUIBarButtonItemBlockTarget

- (id)initWithBlock:(void (^)(id sender))block{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (self.block) self.block(sender);
}

@end

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

- (void)setActionBlock:(void (^)(id sender))block {
    _ZKUIBarButtonItemBlockTarget *target = [[_ZKUIBarButtonItemBlockTarget alloc] initWithBlock:block];
    [self setAssociateValue:target withKey:_cmd];
    
    [self setTarget:target];
    [self setAction:@selector(invoke:)];
}

- (void (^)(id))actionBlock {
    _ZKUIBarButtonItemBlockTarget *target = [self associatedValueForKey:@selector(setActionBlock:)];
    return target.block;
}

@end
