//
//  UIView+ZKAdd.m
//  shandiansong
//
//  Created by Kaiser on 2016/10/12.
//  Copyright © 2016年 zhiqiyun. All rights reserved.
//

#import "UIView+ZKAdd.h"

@implementation UIView (ZKAdd)

- (UIView *)descendantOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls])
        return self;
    
    for (UIView *child in self.subviews) {
        UIView* it = [child descendantOrSelfWithClass:cls];
        if (it)
            return it;
    }
    
    return nil;
}

- (UIView *)ancestorOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls]) {
        return self;
        
    } else if (self.superview) {
        return [self.superview ancestorOrSelfWithClass:cls];
        
    } else {
        return nil;
    }
}

- (void)animateConstraintsWithDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration
                     animations:^{
                         [self layoutIfNeeded];
                     }];
}

@end
