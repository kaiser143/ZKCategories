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
    [self swizzleMethod:@selector(sizeThatFits:) withMethod:@selector(kai_sizeThatFits:)];
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

- (CGSize)kai_sizeThatFits:(CGSize)size {
    CGSize returnValue = [self kai_sizeThatFits:size];
    
    UIEdgeInsets insets = [self textContainerInset];
    returnValue.width += (insets.left + insets.right);
    returnValue.height += (insets.top + insets.bottom);
    return returnValue;
}

@end
