//
//  NSNotificationCenter+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (ZKAdd)

/**
 在主线程向接收者派发指定通知。
 若当前已是主线程则同步派发，否则异步派发。

 @param notification 要派发的通知，为 nil 会抛异常。
 */
- (void)postNotificationOnMainThread:(NSNotification *)notification;

/**
 在主线程向接收者派发指定通知。

 @param notification 要派发的通知，为 nil 会抛异常。
 @param wait 是否阻塞当前线程直到主线程派发完成。YES 阻塞，NO 则立即返回。
 */
- (void)postNotificationOnMainThread:(NSNotification *)notification
                       waitUntilDone:(BOOL)wait;

/**
 根据指定名称和发送者创建通知，并在主线程向接收者派发。
 若当前已是主线程则同步派发，否则异步派发。

 @param name   通知名称。
 @param object 发送通知的对象。
 */
- (void)postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object;

/**
 根据指定名称、发送者和 userInfo 创建通知，并在主线程向接收者派发。
 若当前已是主线程则同步派发，否则异步派发。

 @param name     通知名称。
 @param object   发送通知的对象。
 @param userInfo 通知附加信息，可为 nil。
 */
- (void)postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object
                                    userInfo:(nullable NSDictionary *)userInfo;

/**
 根据指定名称、发送者和 userInfo 创建通知，并在主线程向接收者派发。

 @param name     通知名称。
 @param object   发送通知的对象。
 @param userInfo 通知附加信息，可为 nil。
 @param wait     是否阻塞当前线程直到主线程派发完成。YES 阻塞，NO 则立即返回。
 */
- (void)postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object
                                    userInfo:(nullable NSDictionary *)userInfo
                               waitUntilDone:(BOOL)wait;

@end

NS_ASSUME_NONNULL_END
