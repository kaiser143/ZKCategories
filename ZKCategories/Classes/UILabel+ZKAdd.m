//
//  UILabel+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UILabel+ZKAdd.h"
#import "NSObject+ZKAdd.h"

@implementation UILabel (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(drawTextInRect:) withMethod:@selector(drawAutomaticWritingTextInRect:)];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [self setAssociateValue:[NSValue valueWithUIEdgeInsets:textContainerInset] withKey:@selector(textContainerInset)];
}

- (UIEdgeInsets)textContainerInset {
    NSValue *edgeInsetsValue = [self associatedValueForKey:_cmd];
    if (edgeInsetsValue) {
        return edgeInsetsValue.UIEdgeInsetsValue;
    }
    
    edgeInsetsValue = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero];
    [self setTextContainerInset:edgeInsetsValue.UIEdgeInsetsValue];
    return edgeInsetsValue.UIEdgeInsetsValue;
}

- (void)drawAutomaticWritingTextInRect:(CGRect)rect {
    [self drawAutomaticWritingTextInRect:UIEdgeInsetsInsetRect(rect, self.textContainerInset)];
}

@end
