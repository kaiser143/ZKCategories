//
//  UIView+ZKAdd.m
//  shandiansong
//
//  Created by Kaiser on 2016/10/12.
//  Copyright © 2016年 zhiqiyun. All rights reserved.
//

#import "UIView+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import <objc/runtime.h>

@implementation UIView (ZKAdd)

- (UIView *)descendantOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls])
        return self;
    
    for (UIView *child in self.subviews) {
        UIView* it = [child descendantOrSelfWithClass:cls];
        if (it)
            return it;
    }
    
    return nil;
}

- (UIView *)ancestorOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls]) {
        return self;
        
    } else if (self.superview) {
        return [self.superview ancestorOrSelfWithClass:cls];
        
    } else {
        return nil;
    }
}

@end

static char kZKActionHandlerTapBlockKey;
static char kZKActionHandlerTapGestureKey;
static char kZKActionHandlerLongPressBlockKey;
static char kZKActionHandlerLongPressGestureKey;

@implementation UIView (ZKActionHandlers)

- (void)setTapActionWithBlock:(void (^)(void))block {
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &kZKActionHandlerTapGestureKey);
    
    if (!gesture) {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kZKActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &kZKActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)__handleActionForTapGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        void(^action)(void) = objc_getAssociatedObject(self, &kZKActionHandlerTapBlockKey);
        
        if (action)
        {
            action();
        }
    }
}

- (void)setLongPressActionWithBlock:(void (^)(void))block {
    UILongPressGestureRecognizer *gesture = objc_getAssociatedObject(self, &kZKActionHandlerLongPressGestureKey);
    
    if (!gesture) {
        gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(__handleActionForLongPressGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kZKActionHandlerLongPressGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &kZKActionHandlerLongPressBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)__handleActionForLongPressGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        void(^action)(void) = objc_getAssociatedObject(self, &kZKActionHandlerLongPressBlockKey);
        
        if (action) {
            action();
        }
    }
}

@end

@implementation UIView (ZKDebug)

- (void)methodCalledNotFromMainThread:(NSString *)methodName {
}

- (void)_setNeedsLayout_MainThreadCheck {
    if (![NSThread isMainThread]) {
        [self methodCalledNotFromMainThread:NSStringFromSelector(_cmd)];
    }
    
    // not really an endless loop, this calls the original
    [self _setNeedsLayout_MainThreadCheck];
}

- (void)_setNeedsDisplay_MainThreadCheck {
    if (![NSThread isMainThread]) {
        [self methodCalledNotFromMainThread:NSStringFromSelector(_cmd)];
    }
    
    // not really an endless loop, this calls the original
    [self _setNeedsDisplay_MainThreadCheck];
}

- (void)_setNeedsDisplayInRect_MainThreadCheck:(CGRect)rect {
    if (![NSThread isMainThread]) {
        [self methodCalledNotFromMainThread:NSStringFromSelector(_cmd)];
    }
    
    // not really an endless loop, this calls the original
    [self _setNeedsDisplayInRect_MainThreadCheck:rect];
}

+ (void)toggleViewMainThreadChecking {
    [UIView swizzleMethod:@selector(setNeedsLayout) withMethod:@selector(_setNeedsLayout_MainThreadCheck)];
    [UIView swizzleMethod:@selector(setNeedsDisplay) withMethod:@selector(_setNeedsDisplay_MainThreadCheck)];
    [UIView swizzleMethod:@selector(setNeedsDisplayInRect:) withMethod:@selector(_setNeedsDisplayInRect_MainThreadCheck:)];
}

@end

@implementation UIView (ZKAutoLayout)

- (void)animateLayoutIfNeededWithBounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations {
    [self animateLayoutIfNeededWithBounce:bounce options:options animations:animations completion:NULL];
}

- (void)animateLayoutIfNeededWithBounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    NSTimeInterval duration = bounce ? 0.65 : 0.2;
    [self animateLayoutIfNeededWithDuration:duration bounce:bounce options:options animations:animations completion:completion];
}

- (void)animateLayoutIfNeededWithDuration:(NSTimeInterval)duration bounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    if (bounce) {
        [UIView animateWithDuration:duration
                              delay:0.0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.7
                            options:options
                         animations:^{
                             [self layoutIfNeeded];
                             
                             if (animations) {
                                 animations();
                             }
                         }
                         completion:completion];
    }
    else {
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:options
                         animations:^{
                             [self layoutIfNeeded];
                             
                             if (animations) {
                                 animations();
                             }
                         }
                         completion:completion];
    }
}

- (NSArray *)constraintsForAttribute:(NSLayoutAttribute)attribute {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d", attribute];
    return [self.constraints filteredArrayUsingPredicate:predicate];
}

- (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute firstItem:(id)first secondItem:(id)second {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d AND firstItem = %@ AND secondItem = %@", attribute, first, second];
    return [[self.constraints filteredArrayUsingPredicate:predicate] firstObject];
}

@end
