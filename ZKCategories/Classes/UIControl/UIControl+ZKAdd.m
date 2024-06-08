//
//  UIControl+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIControl+ZKAdd.h"
#import "NSObject+ZKAdd.h"

@interface _KAIUIControlBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);
@property (nonatomic, assign) UIControlEvents events;

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events;
- (void)invoke:(id)sender;

@end

@implementation _KAIUIControlBlockTarget

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events {
    self = [super init];
    if (self) {
        _block  = [block copy];
        _events = events;
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end

@interface UIControl ()

@property (nonatomic,assign) BOOL canSetHighlighted;
@property (nonatomic,assign) NSInteger touchEndCount;

@end

@implementation UIControl (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(sendAction:to:forEvent:) withMethod:@selector(kai_sendAction:to:forEvent:)];
    [self swizzleMethod:@selector(touchesBegan:withEvent:) withMethod:@selector(kai_touchesBegan:withEvent:)];
    [self swizzleMethod:@selector(touchesMoved:withEvent:) withMethod:@selector(kai_touchesMoved:withEvent:)];
    [self swizzleMethod:@selector(touchesEnded:withEvent:) withMethod:@selector(kai_touchesEnded:withEvent:)];
    [self swizzleMethod:@selector(touchesCancelled:withEvent:) withMethod:@selector(kai_touchesCancelled:withEvent:)];
}

- (void)removeAllTargets {
    [[self allTargets] enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
        [self removeTarget:object action:NULL forControlEvents:UIControlEventAllEvents];
    }];
    [[self kai_allUIControlBlockTargets] removeAllObjects];
}

- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (!target || !action || !controlEvents) return;
    NSSet *targets = [self allTargets];
    for (id currentTarget in targets) {
        NSArray *actions = [self actionsForTarget:currentTarget forControlEvent:controlEvents];
        for (NSString *currentAction in actions) {
            [self removeTarget:currentTarget
                          action:NSSelectorFromString(currentAction)
                forControlEvents:controlEvents];
        }
    }
    [self addTarget:target action:action forControlEvents:controlEvents];
}

- (void)addBlockForControlEvents:(UIControlEvents)controlEvents
                           block:(void (^)(__kindof UIControl *sender))block {
    if (!controlEvents) return;
    _KAIUIControlBlockTarget *target = [[_KAIUIControlBlockTarget alloc] initWithBlock:block events:controlEvents];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
    NSMutableArray *targets = [self kai_allUIControlBlockTargets];
    [targets addObject:target];
}

- (void)setBlockForControlEvents:(UIControlEvents)controlEvents
                           block:(void (^)(__kindof UIControl *sender))block {
    [self removeAllBlocksForControlEvents:UIControlEventAllEvents];
    [self addBlockForControlEvents:controlEvents block:block];
}

- (void)removeAllBlocksForControlEvents:(UIControlEvents)controlEvents {
    if (!controlEvents) return;

    NSMutableArray *targets = [self kai_allUIControlBlockTargets];
    NSMutableArray *removes = [NSMutableArray array];
    for (_KAIUIControlBlockTarget *target in targets) {
        if (target.events & controlEvents) {
            UIControlEvents newEvent = target.events & (~controlEvents);
            if (newEvent) {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                target.events = newEvent;
                [self addTarget:target action:@selector(invoke:) forControlEvents:target.events];
            } else {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                [removes addObject:target];
            }
        }
    }
    [targets removeObjectsInArray:removes];
}

- (NSMutableArray *)kai_allUIControlBlockTargets {
    NSMutableArray *targets = [self associatedValueForKey:_cmd];
    if (!targets) {
        targets = [NSMutableArray array];
        [self setAssociateValue:targets withKey:_cmd];
    }
    return targets;
}

- (void)setAutomaticallyAdjustTouchHighlightedInScrollView:(BOOL)automaticallyAdjustTouchHighlightedInScrollView {
    [self setAssociateValue:@(automaticallyAdjustTouchHighlightedInScrollView) withKey:@selector(automaticallyAdjustTouchHighlightedInScrollView)];
}

- (BOOL)automaticallyAdjustTouchHighlightedInScrollView {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setPreventsRepeatedTouchUpInsideEvent:(BOOL)preventsRepeatedTouchUpInsideEvent {
    [self setAssociateValue:@(preventsRepeatedTouchUpInsideEvent) withKey:@selector(preventsRepeatedTouchUpInsideEvent)];
}

- (BOOL)preventsRepeatedTouchUpInsideEvent {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setCanSetHighlighted:(BOOL)canSetHighlighted {
    [self setAssociateValue:@(canSetHighlighted) withKey:@selector(canSetHighlighted)];
}

- (BOOL)canSetHighlighted {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setTouchEndCount:(NSInteger)touchEndCount {
    [self setAssociateValue:@(touchEndCount) withKey:@selector(touchEndCount)];
}

- (NSInteger)touchEndCount {
    return [[self associatedValueForKey:_cmd] integerValue];
}

//@property (nonatomic,assign) BOOL canSetHighlighted;
//@property (nonatomic,assign) NSInteger touchEndCount;

- (void)kai_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (self.preventsRepeatedTouchUpInsideEvent) {
        NSArray<NSString *> *actions = [self actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
        if (!actions) {
            // iOS 10 UIBarButtonItem 里的 UINavigationButton 点击事件用的是 UIControlEventPrimaryActionTriggered
            actions = [self actionsForTarget:target forControlEvent:UIControlEventPrimaryActionTriggered];
        }
        if ([actions containsObject:NSStringFromSelector(action)]) {
            UITouch *touch = event.allTouches.anyObject;
            if (touch.tapCount > 1) {
                return;
            }
        }
    }

    [self kai_sendAction:action to:target forEvent:event];
}

// 参考 QMUI
// 这段代码需要以一个独立的方法存在，因为一旦有坑，外面可以直接通过runtime调用这个方法
// 但，不要开放到.h文件里，理论上外面不应该用到它
- (void)sendActionsForAllTouchEventsIfCan {
    self.touchEndCount += 1;
    if (self.touchEndCount == 1) {
        [self sendActionsForControlEvents:UIControlEventAllTouchEvents];
    }
}

- (void)kai_touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.touchEndCount = 0;
    if (self.automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = YES;
        [self kai_touchesBegan:touches withEvent:event];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.canSetHighlighted) {
                [self setHighlighted:YES];
            }
        });
    } else {
        [self kai_touchesBegan:touches withEvent:event];
    }
}

- (void)kai_touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = NO;
    }
    
    [self kai_touchesMoved:touches withEvent:event];
}

- (void)kai_touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = NO;
        if (self.touchInside) {
            [self setHighlighted:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self sendActionsForAllTouchEventsIfCan];
                if (self.highlighted) {
                    [self setHighlighted:NO];
                }
            });
        } else {
            [self setHighlighted:NO];
        }
        return;
    }
    [self kai_touchesEnded:touches withEvent:event];
}

- (void)kai_touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = NO;
        [self kai_touchesCancelled:touches withEvent:event];
        if (self.highlighted) {
            [self setHighlighted:NO];
        }
        return;
    }
    [self kai_touchesCancelled:touches withEvent:event];
}

@end
