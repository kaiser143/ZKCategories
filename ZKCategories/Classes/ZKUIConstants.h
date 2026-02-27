//
//  ZKUIConstants.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/5/18.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#ifndef ZKUIConstants_h
#define ZKUIConstants_h

/**
 根据当前无障碍内容尺寸类别返回对应的字号差值。
 
 @param category 内容尺寸类别常量字符串。
 @return 字号差值（浮点常量）。
 */
__unused static CGFloat ZKPointSizeDifferenceForCategory(NSString *category)
{
    if ([category isEqualToString:UIContentSizeCategoryExtraSmall])                         return -3.0;
    if ([category isEqualToString:UIContentSizeCategorySmall])                              return -2.0;
    if ([category isEqualToString:UIContentSizeCategoryMedium])                             return -1.0;
    if ([category isEqualToString:UIContentSizeCategoryLarge])                              return 0.0;
    if ([category isEqualToString:UIContentSizeCategoryExtraLarge])                         return 2.0;
    if ([category isEqualToString:UIContentSizeCategoryExtraExtraLarge])                    return 4.0;
    if ([category isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge])               return 6.0;
    if ([category isEqualToString:UIContentSizeCategoryAccessibilityMedium])                return 8.0;
    if ([category isEqualToString:UIContentSizeCategoryAccessibilityLarge])                 return 10.0;
    if ([category isEqualToString:UIContentSizeCategoryAccessibilityExtraLarge])            return 11.0;
    if ([category isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraLarge])       return 12.0;
    if ([category isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge])  return 13.0;
    return 0;
}

#endif /* ZKUIConstants_h */
