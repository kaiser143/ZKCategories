//
//  UIGestureRecognizer+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 为 `UIGestureRecognizer` 提供扩展。
 */
@interface UIGestureRecognizer (ZKAdd)

/**
 使用一个 action block 初始化已分配的手势识别器。
 
 @param block  处理接收者识别到的手势的 action block。不能为 nil，由手势持有。
 
 @return 初始化后的 UIGestureRecognizer 子类实例，初始化失败时返回 nil。
 */
- (instancetype)initWithActionBlock:(void (^)(__kindof UIGestureRecognizer *sender))block;

/**
 为手势识别器添加一个 action block，由手势持有。
 
 @param block 手势触发时调用的 block，不能为 nil。
 */
- (void)addActionBlock:(void (^)(__kindof UIGestureRecognizer *sender))block;

/**
 移除所有 action block。
 */
- (void)removeAllActionBlocks;

@end

NS_ASSUME_NONNULL_END
