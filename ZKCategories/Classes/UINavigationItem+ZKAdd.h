//
//  UINavigationItem+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationItem (ZKAdd)

@property(nonatomic, assign) CGFloat leftMargin;
@property(nonatomic, assign) CGFloat rightMargin;

+ (CGFloat)systemMargin;

@end

NS_ASSUME_NONNULL_END
