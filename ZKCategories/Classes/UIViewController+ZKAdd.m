//
//  UIViewController+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/25.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIViewController+ZKAdd.h"
#import <objc/runtime.h>
#import "NSObject+ZKAdd.h"

static void * const kWillShowBlockKey   = (void*)&kWillShowBlockKey;
static void * const kWillHideBlockKey   = (void*)&kWillHideBlockKey;
static void * const kDidShowBlockKey    = (void*)&kDidShowBlockKey;
static void * const kDidHideBlockKey    = (void*)&kDidHideBlockKey;
static void * const kNotificationsOnKey = (void*)&kNotificationsOnKey;

@implementation UIViewController (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(viewWillAppear:) withMethod:@selector(kai_viewWillAppear:)];
    [self swizzleMethod:@selector(viewDidDisappear:) withMethod:@selector(kai_viewDidDisappear:)];
}

- (void)kai_viewWillAppear:(BOOL)animated {
    [self kai_registerForKeyboardNotifications];
    [self kai_viewWillAppear:animated];
}

- (void)kai_viewDidDisappear:(BOOL)animated {
    [self kai_unregisterForKeyboardNotifications];
    [self kai_viewDidDisappear:animated];
}

- (void)kai_setWillShowAnimationBlock:(ZKKeyboardFrameAnimationBlock)willShowBlock {
    objc_setAssociatedObject(self, kWillShowBlockKey, willShowBlock, OBJC_ASSOCIATION_COPY);
}

- (ZKKeyboardFrameAnimationBlock)kai_willShowAnimationBlock {
    return (ZKKeyboardFrameAnimationBlock)objc_getAssociatedObject(self, kWillShowBlockKey);
}

- (void)kai_setWillHideAnimationBlock:(ZKKeyboardFrameAnimationBlock)willHideBlock {
    objc_setAssociatedObject(self, kWillHideBlockKey, willHideBlock, OBJC_ASSOCIATION_COPY);
}

- (ZKKeyboardFrameAnimationBlock)kai_willHideAnimationBlock {
    return (ZKKeyboardFrameAnimationBlock)objc_getAssociatedObject(self, kWillHideBlockKey);
}

- (void)kai_setDidShowActionBlock:(ZKKeyboardFrameAnimationBlock)didShowBlock {
    objc_setAssociatedObject(self, kDidShowBlockKey, didShowBlock, OBJC_ASSOCIATION_COPY);
}

- (ZKKeyboardFrameAnimationBlock)kai_didShowActionBlock {
    return (ZKKeyboardFrameAnimationBlock)objc_getAssociatedObject(self, kDidShowBlockKey);
}

- (void)kai_setDidHideActionBlock:(ZKKeyboardFrameAnimationBlock)didHideBlock {
    objc_setAssociatedObject(self, kDidHideBlockKey, didHideBlock, OBJC_ASSOCIATION_COPY);
}

- (ZKKeyboardFrameAnimationBlock)kai_didHideActionBlock {
    return (ZKKeyboardFrameAnimationBlock)objc_getAssociatedObject(self, kDidHideBlockKey);
}

- (void)kai_setNotificationsOn:(BOOL)notificationsOn {
    objc_setAssociatedObject(self, kNotificationsOnKey, @(notificationsOn), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)kai_areNotificationsOn {
    return [(NSNumber *)objc_getAssociatedObject(self, kNotificationsOnKey) boolValue];
}

- (void)setKeyboardStatus:(ZKKeyboardStatus)keyboardStatus {
    objc_setAssociatedObject(self, _cmd, @(keyboardStatus), OBJC_ASSOCIATION_RETAIN);
}

- (ZKKeyboardStatus)keyboardStatus {
    ZKKeyboardStatus status = [objc_getAssociatedObject(self, @selector(setKeyboardStatus:)) unsignedIntegerValue];
    return status;
}

- (void)setKeyboardWillShowAnimationBlock:(ZKKeyboardFrameAnimationBlock)showBlock {
    if ([self kai_areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevWillShowBlock = [self kai_willShowAnimationBlock];
        
        if (!showBlock && prevWillShowBlock)
            [self unregisterWillShowNotification];
        else if (showBlock && !prevWillShowBlock)
            [self registerWillShowNotification];
    }
    
    [self kai_setWillShowAnimationBlock:showBlock];
}

- (void)setKeyboardWillHideAnimationBlock:(ZKKeyboardFrameAnimationBlock)hideBlock {
    if ([self kai_areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevWillHideBlock = [self kai_willHideAnimationBlock];
        
        if (!hideBlock && prevWillHideBlock)
            [self unregisterWillHideNotification];
        else if (hideBlock && !prevWillHideBlock)
            [self registerWillHideNotification];
    }
    
    [self kai_setWillHideAnimationBlock:hideBlock];
}

- (void)setKeyboardDidShowActionBlock:(ZKKeyboardFrameAnimationBlock)didShowBlock {
    if ([self kai_areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevDidShowBlock = [self kai_didShowActionBlock];
        
        if (!didShowBlock && prevDidShowBlock)
            [self unregisterDidShowNotification];
        else if (didShowBlock && !prevDidShowBlock)
            [self registerDidShowNotification];
    }
    
    [self kai_setDidShowActionBlock:didShowBlock];
}

- (void)setKeyboardDidHideActionBlock:(ZKKeyboardFrameAnimationBlock)didHideBlock {
    if ([self kai_areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevDidHideBlock = [self kai_didHideActionBlock];
        
        if (!didHideBlock && prevDidHideBlock)
            [self unregisterDidHideNotification];
        else if (didHideBlock && !prevDidHideBlock)
            [self registerDidHideNotification];
    }
    
    [self kai_setDidHideActionBlock:didHideBlock];
}

#pragma mark - registering notifications

- (void)kai_registerForKeyboardNotifications {
    [self kai_setNotificationsOn:YES];
    
    if ([self kai_willShowAnimationBlock])
        [self registerWillShowNotification];
    
    if ([self kai_willHideAnimationBlock])
        [self registerWillHideNotification];
    
    if ([self kai_didShowActionBlock])
        [self registerDidShowNotification];
    
    if ([self kai_didHideActionBlock])
        [self registerDidHideNotification];
}

- (void)registerWillShowNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kai_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)registerWillHideNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kai_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)registerDidShowNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kai_keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)registerDidHideNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kai_keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)kai_unregisterForKeyboardNotifications {
    [self kai_setNotificationsOn:NO];
    
    if ([self kai_willShowAnimationBlock])
        [self unregisterWillShowNotification];
    
    if ([self kai_willHideAnimationBlock])
        [self unregisterWillHideNotification];
    
    if ([self kai_didShowActionBlock])
        [self unregisterDidShowNotification];
    
    if ([self kai_didHideActionBlock])
        [self unregisterDidHideNotification];
}

- (void)unregisterWillShowNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)unregisterWillHideNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterDidShowNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (void)unregisterDidHideNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}


#pragma mark - notification callbacks

- (void)kai_keyboardWillShow:(NSNotification *)notification {
    [self kai_performAnimationBlock:[self kai_willShowAnimationBlock]
                   withNotification:notification];
}

- (void)kai_keyboardWillHide:(NSNotification *)notification {
    [self kai_performAnimationBlock:[self kai_willHideAnimationBlock]
                   withNotification:notification];
}

- (void)kai_keyboardDidShow:(NSNotification *)notification {
    [self kai_performAnimationBlock:[self kai_didShowActionBlock]
                   withNotification:notification];
}

- (void)kai_keyboardDidHide:(NSNotification *)notification {
    [self kai_performAnimationBlock:[self kai_didHideActionBlock]
                   withNotification:notification];
}

- (void)kai_performAnimationBlock:(ZKKeyboardFrameAnimationBlock)animationBlock withNotification:(NSNotification *)notification {
    if (!animationBlock)
        return;
    
    NSDictionary *info = [notification userInfo];
    
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger curve                  = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] << 16;
    CGRect keyboardFrame             = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    ZKKeyboardStatus status          = [self kai_keyboardStatusForNotification:notification];
    
    if (!(status != ZKKeyboardStatusDidHide && [self __isIllogicalKeyboardStatus:status])) {
        self.keyboardStatus = status;
    }
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:curve|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{ animationBlock(keyboardFrame); }
                     completion:nil];
}

- (ZKKeyboardStatus)kai_keyboardStatusForNotification:(NSNotification *)notification {
    NSString *name = notification.name;
    
    if ([name isEqualToString:UIKeyboardWillShowNotification]) {
        return ZKKeyboardStatusWillShow;
    }
    if ([name isEqualToString:UIKeyboardDidShowNotification]) {
        return ZKKeyboardStatusDidShow;
    }
    if ([name isEqualToString:UIKeyboardWillHideNotification]) {
        return ZKKeyboardStatusWillHide;
    }
    if ([name isEqualToString:UIKeyboardDidHideNotification]) {
        return ZKKeyboardStatusDidHide;
    }
    return -1;
}

- (BOOL)__isIllogicalKeyboardStatus:(ZKKeyboardStatus)newStatus {
    if ((self.keyboardStatus == ZKKeyboardStatusDidHide && newStatus == ZKKeyboardStatusWillShow) ||
        (self.keyboardStatus == ZKKeyboardStatusWillShow && newStatus == ZKKeyboardStatusDidShow) ||
        (self.keyboardStatus == ZKKeyboardStatusDidShow && newStatus == ZKKeyboardStatusWillHide) ||
        (self.keyboardStatus == ZKKeyboardStatusWillHide && newStatus == ZKKeyboardStatusDidHide)) {
        return NO;
    }
    return YES;
}

@end
