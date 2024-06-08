//
//  UIButton+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UIButton+ZKAdd.h"
#import "NSObject+ZKAdd.h"

@implementation UIButton (ZKAdd)

- (UIEdgeInsets)outsideEdge {
    return [[self associatedValueForKey:_cmd] UIEdgeInsetsValue];
}


- (void)setOutsideEdge:(UIEdgeInsets)touchAreaInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:touchAreaInsets];
    [self setAssociateValue:value withKey:@selector(outsideEdge)];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (!UIEdgeInsetsEqualToEdgeInsets(self.outsideEdge, UIEdgeInsetsZero)
        && self.alpha > 0.01
        && !self.hidden
        && !CGRectIsEmpty(self.frame)) {
        CGRect rect = UIEdgeInsetsInsetRect(self.bounds, self.outsideEdge);
        BOOL result = CGRectContainsPoint(rect, point);
        return result;
    }
    
    return [super pointInside:point withEvent:event];
}

- (void)kai_setTitle:(NSString *)title {
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
}

- (void)setTitleColor:(UIColor *)color {
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateHighlighted];
}

@end
