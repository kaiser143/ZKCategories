//
//  UIResponder+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/5/18.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIResponder (ZKAdd)

/**
 Returns the current first responder object.
 
 @return A UIResponder instance.
 */
+ (nullable instancetype)currentFirstResponder;

/*!
 *  @brief    发送事件
 *  @param    eventName    事件名
 */
- (void)sendEventWithName:(nonnull NSString *)eventName userInfo:(nullable id)userInfo;


/*!
 *  @brief    在需要响应的位置重写该方法
 *  @param    eventName    事件名
 *  @return    是否继续往next responder派发事件
 */
- (BOOL)responderDidReceiveEvent:(nonnull NSString *)eventName userInfo:(nullable id)userInfo;

/*!
 *  @brief  响应者链
 *  @return  响应者链
 */
- (nullable NSString *)responderChainDescription;

@end
