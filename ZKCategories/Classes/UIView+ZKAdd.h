//
//  UIView+ZKAdd.h
//  shandiansong
//
//  Created by Kaiser on 2016/10/12.
//  Copyright © 2016年 zhiqiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZKAdd)

/**
 * Finds the first descendant view (including this view) that is a member of a particular class.
 */
- (nullable UIView *)descendantOrSelfWithClass:(Class)cls;

/**
 * Finds the first ancestor view (including this view) that is a member of a particular class.
 */
- (nullable UIView *)ancestorOrSelfWithClass:(Class)cls;

// AutoLayout
- (void)animateConstraintsWithDuration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
