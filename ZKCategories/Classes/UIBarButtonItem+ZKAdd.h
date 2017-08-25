//
//  UIBarButtonItem+ZKAdd.h
//  shandiansong
//
//  Created by Kaiser on 2016/9/26.
//  Copyright © 2016年 zhiqiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (ZKAdd)

+ (instancetype)itemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

+ (instancetype)itemWithImage:(UIImage *)image target:(id)target action:(SEL)action;

@end
