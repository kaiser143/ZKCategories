//
//  UIViewController+ZKAdd.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2018/12/25.
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
    [self swizzleMethod:@selector(viewWillAppear:) withMethod:@selector(__viewWillAppear:)];
    [self swizzleMethod:@selector(viewDidDisappear:) withMethod:@selector(__viewDidDisappear:)];
}

- (void)__viewWillAppear:(BOOL)animated {
    [self __registerForKeyboardNotifications];
    [self __viewWillAppear:animated];
}

- (void)__viewDidDisappear:(BOOL)animated {
    [self __unregisterForKeyboardNotifications];
    [self __viewDidDisappear:animated];
}

- (void)__setWillShowAnimationBlock:(ZKKeyboardFrameAnimationBlock)willShowBlock {
    objc_setAssociatedObject(self, kWillShowBlockKey, willShowBlock, OBJC_ASSOCIATION_COPY);
}

- (ZKKeyboardFrameAnimationBlock)__willShowAnimationBlock {
    return (ZKKeyboardFrameAnimationBlock)objc_getAssociatedObject(self, kWillShowBlockKey);
}

- (void)__setWillHideAnimationBlock:(ZKKeyboardFrameAnimationBlock)willHideBlock {
    objc_setAssociatedObject(self, kWillHideBlockKey, willHideBlock, OBJC_ASSOCIATION_COPY);
}

- (ZKKeyboardFrameAnimationBlock)__willHideAnimationBlock {
    return (ZKKeyboardFrameAnimationBlock)objc_getAssociatedObject(self, kWillHideBlockKey);
}

- (void)__setDidShowActionBlock:(ZKKeyboardFrameAnimationBlock)didShowBlock {
    objc_setAssociatedObject(self, kDidShowBlockKey, didShowBlock, OBJC_ASSOCIATION_COPY);
}

- (ZKKeyboardFrameAnimationBlock)__didShowActionBlock {
    return (ZKKeyboardFrameAnimationBlock)objc_getAssociatedObject(self, kDidShowBlockKey);
}

- (void)__setDidHideActionBlock:(ZKKeyboardFrameAnimationBlock)didHideBlock {
    objc_setAssociatedObject(self, kDidHideBlockKey, didHideBlock, OBJC_ASSOCIATION_COPY);
}

- (ZKKeyboardFrameAnimationBlock)__didHideActionBlock {
    return (ZKKeyboardFrameAnimationBlock)objc_getAssociatedObject(self, kDidHideBlockKey);
}

- (void)__setNotificationsOn:(BOOL)notificationsOn {
    objc_setAssociatedObject(self, kNotificationsOnKey, @(notificationsOn), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)__areNotificationsOn {
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
    if ([self __areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevWillShowBlock = [self __willShowAnimationBlock];
        
        if (!showBlock && prevWillShowBlock)
            [self unregisterWillShowNotification];
        else if (showBlock && !prevWillShowBlock)
            [self registerWillShowNotification];
    }
    
    [self __setWillShowAnimationBlock:showBlock];
}

- (void)setKeyboardWillHideAnimationBlock:(ZKKeyboardFrameAnimationBlock)hideBlock {
    if ([self __areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevWillHideBlock = [self __willHideAnimationBlock];
        
        if (!hideBlock && prevWillHideBlock)
            [self unregisterWillHideNotification];
        else if (hideBlock && !prevWillHideBlock)
            [self registerWillHideNotification];
    }
    
    [self __setWillHideAnimationBlock:hideBlock];
}

- (void)setKeyboardDidShowActionBlock:(ZKKeyboardFrameAnimationBlock)didShowBlock {
    if ([self __areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevDidShowBlock = [self __didShowActionBlock];
        
        if (!didShowBlock && prevDidShowBlock)
            [self unregisterDidShowNotification];
        else if (didShowBlock && !prevDidShowBlock)
            [self registerDidShowNotification];
    }
    
    [self __setDidShowActionBlock:didShowBlock];
}

- (void)setKeyboardDidHideActionBlock:(ZKKeyboardFrameAnimationBlock)didHideBlock {
    if ([self __areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevDidHideBlock = [self __didHideActionBlock];
        
        if (!didHideBlock && prevDidHideBlock)
            [self unregisterDidHideNotification];
        else if (didHideBlock && !prevDidHideBlock)
            [self registerDidHideNotification];
    }
    
    [self __setDidHideActionBlock:didHideBlock];
}

#pragma mark - registering notifications

- (void)__registerForKeyboardNotifications {
    [self __setNotificationsOn:YES];
    
    if ([self __willShowAnimationBlock])
        [self registerWillShowNotification];
    
    if ([self __willHideAnimationBlock])
        [self registerWillHideNotification];
    
    if ([self __didShowActionBlock])
        [self registerDidShowNotification];
    
    if ([self __didHideActionBlock])
        [self registerDidHideNotification];
}

- (void)registerWillShowNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)registerWillHideNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)registerDidShowNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)registerDidHideNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)__unregisterForKeyboardNotifications {
    [self __setNotificationsOn:NO];
    
    if ([self __willShowAnimationBlock])
        [self unregisterWillShowNotification];
    
    if ([self __willHideAnimationBlock])
        [self unregisterWillHideNotification];
    
    if ([self __didShowActionBlock])
        [self unregisterDidShowNotification];
    
    if ([self __didHideActionBlock])
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

- (void)__keyboardWillShow:(NSNotification *)notification {
    [self __performAnimationBlock:[self __willShowAnimationBlock]
                   withNotification:notification];
}

- (void)__keyboardWillHide:(NSNotification *)notification {
    [self __performAnimationBlock:[self __willHideAnimationBlock]
                   withNotification:notification];
}

- (void)__keyboardDidShow:(NSNotification *)notification {
    [self __performAnimationBlock:[self __didShowActionBlock]
                   withNotification:notification];
}

- (void)__keyboardDidHide:(NSNotification *)notification {
    [self __performAnimationBlock:[self __didHideActionBlock]
                   withNotification:notification];
}

- (void)__performAnimationBlock:(ZKKeyboardFrameAnimationBlock)animationBlock withNotification:(NSNotification *)notification {
    if (!animationBlock)
        return;
    
    NSDictionary *info = [notification userInfo];
    
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger curve                  = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] << 16;
    CGRect keyboardFrame             = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    ZKKeyboardStatus status          = [self __keyboardStatusForNotification:notification];
    
    if (!(status != ZKKeyboardStatusDidHide && [self __isIllogicalKeyboardStatus:status])) {
        self.keyboardStatus = status;
    }
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:curve|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{ animationBlock(keyboardFrame); }
                     completion:nil];
}

- (ZKKeyboardStatus)__keyboardStatusForNotification:(NSNotification *)notification {
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
