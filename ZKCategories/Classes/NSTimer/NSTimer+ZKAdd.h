//
//  NSTimer+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (ZKAdd)

/**
 *  @brief  暂停NSTimer
 */
- (void)pauseTimer;

/**
 *  @brief  开始NSTimer
 */
- (void)resumeTimer;

/**
 *  @brief  延迟开始NSTimer
 */
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;

/**
 创建并返回新的 NSTimer，并以默认 mode 加入当前 run loop。
 
 @discussion 经过 seconds 秒后定时器触发，执行 block。
 
 @param seconds 定时器触发间隔（秒）。若小于等于 0.0，则使用 0.1 毫秒。
 
 @param block   定时器触发时调用的 block。定时器会强引用该 block 直至 invalidate。
 @param repeats YES 表示重复触发直到 invalidate；NO 表示触发一次后自动 invalidate。
 
 @return 根据参数配置好的新 NSTimer 对象。
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;

/**
 使用指定 block 创建并返回新的 NSTimer 对象。
 
 @discussion 需自行通过 addTimer:forMode: 将定时器加入 run loop。
 经过 seconds 秒后定时器触发并调用 block。（若为重复定时器，无需再次加入 run loop。）
 
 @param seconds 定时器触发间隔（秒）。若小于等于 0.0，则使用 0.1 毫秒。
 
 @param block   定时器触发时调用的 block，需在 block 内强引用所需参数。
 
 @param repeats YES 表示重复触发直到 invalidate；NO 表示触发一次后自动 invalidate。
 
 @return 根据参数配置好的新 NSTimer 对象。
 */
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;

@end

NS_ASSUME_NONNULL_END
