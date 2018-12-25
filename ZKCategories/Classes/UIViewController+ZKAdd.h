//
//  UIViewController+ZKAdd.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2018/12/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZKKeyboardFrameAnimationBlock)(CGRect keyboardFrame);

@interface UIViewController (KeyboardNotifications)

#pragma mark - Keyboard

- (void)setKeyboardWillShowAnimationBlock:(ZKKeyboardFrameAnimationBlock)willShowBlock;
- (void)setKeyboardWillHideAnimationBlock:(ZKKeyboardFrameAnimationBlock)willHideBlock;

- (void)setKeyboardDidShowActionBlock:(ZKKeyboardFrameAnimationBlock)didShowBlock;
- (void)setKeyboardDidHideActionBlock:(ZKKeyboardFrameAnimationBlock)didHideBlock;

@end

NS_ASSUME_NONNULL_END
