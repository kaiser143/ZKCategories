//
//  UIBarButtonItem+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/9/26.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (ZKAdd)

+ (instancetype)itemWithImage:(UIImage *)image target:(nullable id)target action:(nullable SEL)action;

/**
 点击该 item 时调用的 block。block 捕获的对象会被 BarButtonItem 持有。
 
 @discussion 此属性与 `target`、`action` 互斥；设置后会将 `target` 和 `action` 指向内部对象。
 */
@property (nullable, nonatomic, copy) void (^actionBlock)(id);

@end

NS_ASSUME_NONNULL_END
