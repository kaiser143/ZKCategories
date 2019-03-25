//
//  UIGestureRecognizer+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIGestureRecognizer+ZKAdd.h"
#import "ZKCategoriesMacro.h"
#import "NSObject+ZKAdd.h"

@interface _ZKUIGestureRecognizerBlockTarget : NSObject

@property (nonatomic, copy) void(^block)(id sender);

- (id)initWithBlock:(void(^)(id sender))block;
- (void)invoke:(id)sender;

@end

@implementation _ZKUIGestureRecognizerBlockTarget

- (id)initWithBlock:(void (^)(id sender))block{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end




@implementation UIGestureRecognizer (ZKAdd)

- (instancetype)initWithActionBlock:(void (^)(id sender))block {
    self = [self init];
    [self addActionBlock:block];
    return self;
}

- (void)addActionBlock:(void (^)(id sender))block {
    _ZKUIGestureRecognizerBlockTarget *target = [[_ZKUIGestureRecognizerBlockTarget alloc] initWithBlock:block];
    [self addTarget:target action:@selector(invoke:)];
    NSMutableArray *targets = [self kai_allUIGestureRecognizerBlockTargets];
    [targets addObject:target];
}

- (void)removeAllActionBlocks{
    NSMutableArray *targets = [self kai_allUIGestureRecognizerBlockTargets];
    [targets enumerateObjectsUsingBlock:^(id target, NSUInteger idx, BOOL *stop) {
        [self removeTarget:target action:@selector(invoke:)];
    }];
    [targets removeAllObjects];
}

- (NSMutableArray *)kai_allUIGestureRecognizerBlockTargets {
    NSMutableArray *targets = [self associatedValueForKey:_cmd];
    if (!targets) {
        targets = [NSMutableArray array];
        [self setAssociateValue:targets withKey:_cmd];
    }
    return targets;
}

@end
