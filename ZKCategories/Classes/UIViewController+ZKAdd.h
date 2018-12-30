//
//  UIViewController+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/25.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKKeyboardStatus) {
    ZKKeyboardStatusDidHide,
    ZKKeyboardStatusWillShow,
    ZKKeyboardStatusDidShow,
    ZKKeyboardStatusWillHide
};

typedef void(^ZKKeyboardFrameAnimationBlock)(CGRect keyboardFrame);

@interface UIViewController (KeyboardNotifications)

@property (nonatomic, readonly) ZKKeyboardStatus keyboardStatus;

#pragma mark - Keyboard

- (void)setKeyboardWillShowAnimationBlock:(ZKKeyboardFrameAnimationBlock)willShowBlock;
- (void)setKeyboardWillHideAnimationBlock:(ZKKeyboardFrameAnimationBlock)willHideBlock;

- (void)setKeyboardDidShowActionBlock:(ZKKeyboardFrameAnimationBlock)didShowBlock;
- (void)setKeyboardDidHideActionBlock:(ZKKeyboardFrameAnimationBlock)didHideBlock;

@end

NS_ASSUME_NONNULL_END
