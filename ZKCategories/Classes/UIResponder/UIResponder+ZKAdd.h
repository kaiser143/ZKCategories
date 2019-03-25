//
//  UIResponder+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/5/18.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (ZKAdd)

/**
 Returns the current first responder object.
 
 @return A UIResponder instance.
 */
+ (nullable instancetype)currentFirstResponder;

@end
