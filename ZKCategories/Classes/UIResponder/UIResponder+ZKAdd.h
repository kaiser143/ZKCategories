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
 *  @brief    借助responder chain构成的一个响应者链，通过递归的思想来将响应者事件层层传递，可以在响应者链末尾调用该方法将事件和值进行传递，
 *  在响应者链的某一层重写该方法可以截获事件，并且对事件和值进行过滤或者操作，感觉可以替代delegate和block。
 *
 *  @param    eventName    当前发生事件的名称
 *  @param    userInfo    传递消息时携带的数据，数据传递过程中会有新的数据添加。
 */
- (void)routerWithEventName:(nonnull NSString *)eventName userInfo:(nullable NSDictionary *)userInfo;


@end
