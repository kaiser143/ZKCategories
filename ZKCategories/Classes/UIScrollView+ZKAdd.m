//
//  UIScrollView+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIScrollView+ZKAdd.h"
#import "ZKCategoriesMacro.h"
#import "NSObject+ZKAdd.h"

ZKSYNTH_DUMMY_CLASS(UIScrollView_ZKAdd)

@implementation UIScrollView (ZKAdd)

- (void)setContentInsetTop:(CGFloat)contentInsetTop {
    UIEdgeInsets inset = self.contentInset;
    inset.top = contentInsetTop;
    self.contentInset = inset;
}

- (CGFloat)contentInsetTop {
    return self.contentInset.top;
}

- (void)setContentInsetBottom:(CGFloat)contentInsetBottom {
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = contentInsetBottom;
    self.contentInset = inset;
}

- (CGFloat)contentInsetBottom {
    return self.contentInset.bottom;
}

- (void)setContentInsetLeft:(CGFloat)contentInsetLeft {
    UIEdgeInsets inset = self.contentInset;
    inset.left = contentInsetLeft;
    self.contentInset = inset;
}

- (CGFloat)contentInsetLeft {
    return self.contentInset.left;
}

- (void)setContentInsetRight:(CGFloat)contentInsetRight {
    UIEdgeInsets inset = self.contentInset;
    inset.right = contentInsetRight;
    self.contentInset = inset;
}

- (CGFloat)contentInsetRight {
    return self.contentInset.right;
}

- (void)setContentOffsetX:(CGFloat)contentOffsetX {
    CGPoint offset = self.contentOffset;
    offset.x = contentOffsetX;
    self.contentOffset = offset;
}

- (CGFloat)contentOffsetX {
    return self.contentOffset.x;
}

- (void)setContentOffsetY:(CGFloat)contentOffsetY {
    CGPoint offset = self.contentOffset;
    offset.y = contentOffsetY;
    self.contentOffset = offset;
}

- (CGFloat)contentOffsetY {
    return self.contentOffset.y;
}

- (void)setContentSizeWidth:(CGFloat)contentSizeWidth {
    CGSize size = self.contentSize;
    size.width = contentSizeWidth;
    self.contentSize = size;
}

- (CGFloat)contentSizeWidth {
    return self.contentSize.width;
}

- (void)setContentSizeHeight:(CGFloat)contentSizeHeight {
    CGSize size = self.contentSize;
    size.height = contentSizeHeight;
    self.contentSize = size;
}

- (CGFloat)contentSizeHeight {
    return self.contentSize.height;
}

- (ZKScrollDirection)scrollDirection {
    ZKScrollDirection direction = ZKScrollDirectionUndefine;
    CGPoint point = [self.panGestureRecognizer translationInView:self.superview];
    if (point.y > 0.0f) {
        direction = ZKScrollDirectionUp;
    } else if (point.y < 0.0f) {
        direction = ZKScrollDirectionDown;
    } else if (point.x < 0.0f) {
        direction = ZKScrollDirectionLeft;
    } else if (point.x > 0.0f) {
        direction = ZKScrollDirectionRight;
    }
    
    return direction;
}

- (void)scrollToTop {
    [self scrollToTopAnimated:YES];
}

- (void)scrollToBottom {
    [self scrollToBottomAnimated:YES];
}

- (void)scrollToLeft {
    [self scrollToLeftAnimated:YES];
}

- (void)scrollToRight {
    [self scrollToRightAnimated:YES];
}

- (void)scrollToTopAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = 0 - self.contentInset.top;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToLeftAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = 0 - self.contentInset.left;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToRightAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
    [self setContentOffset:off animated:animated];
}

@end

