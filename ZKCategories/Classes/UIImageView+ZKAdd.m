//
//  UIImageView+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIImageView+ZKAdd.h"
#import <objc/runtime.h>
#import "NSObject+ZKAdd.h"

const char kProcessedImage;

@interface UIImageView ()

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) UIRectCorner corner;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) UIColor *borderColor;
@property (nonatomic, assign) BOOL hadAddObserver;
@property (nonatomic, assign, getter=isRounding) BOOL rounding;

@end

@implementation UIImageView (ZKAdd)

+ (void)load {
    [self swizzleMethod:NSSelectorFromString(@"dealloc") withMethod:@selector(__dealloc)];
    [self swizzleMethod:@selector(layoutSubviews) withMethod:@selector(__layoutSubviews)];
}

- (instancetype)initWithCornerRadius:(CGFloat)radius rectCorner:(UIRectCorner)rectCorner {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self setCornerRadius:radius rectCorner:rectCorner];
    
    return self;
}

- (instancetype)initWithRoundingRectImageView {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self setCornerRadiusRoundingRect];
    
    return self;
}

#pragma mark -
#pragma mark - :. KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        UIImage *newImage = change[NSKeyValueChangeNewKey];
        if ([newImage isMemberOfClass:[NSNull class]]) {
            return;
        } else if ([objc_getAssociatedObject(newImage, &kProcessedImage) intValue] == 1) {
            return;
        }
    
        if (self.isRounding) {
            [self updateImage:newImage withRadius:CGRectGetWidth(self.frame)/2 withCorner:UIRectCornerAllCorners];
        } else if (0 != self.radius && 0 != self.corner && nil != self.image) {
            [self updateImage:newImage withRadius:self.radius withCorner:self.corner];
        }
    }
}

#pragma mark -
#pragma mark :. Public methods

- (void)setBorderWidth:(CGFloat)width color:(UIColor *)color {
    self.borderWidth = width;
    self.borderColor = color;
}

- (void)setCornerRadiusRoundingRect {
    self.rounding = YES;
    
    if (!self.hadAddObserver) {
        [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        self.hadAddObserver = YES;
    }
    
    [self layoutIfNeeded];
}

#pragma mark -
#pragma mark :. Private methods

- (void)setCornerRadius:(CGFloat)radius rectCorner:(UIRectCorner)rectCorner {
    self.radius = radius;
    self.corner = rectCorner;
    self.rounding = NO;
    if (!self.hadAddObserver) {
        [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        self.hadAddObserver = YES;
    }
    
    [self layoutIfNeeded];
}

- (void)updateImage:(UIImage *)image withRadius:(CGFloat)radius withCorner:(UIRectCorner)corner {
    CGSize size = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize resultSize = CGSizeMake(radius, radius);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (nil == currentContext) {
        return;
    }
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                     byRoundingCorners:corner
                                                           cornerRadii:resultSize];
    [cornerPath addClip];
    [self.layer renderInContext:currentContext];
    [self drawBorder:cornerPath];
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (processedImage) {
        objc_setAssociatedObject(processedImage, &kProcessedImage, @(1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    self.image = processedImage;
}

- (void)drawBorder:(UIBezierPath *)path {
    if (0 != self.borderWidth && nil != self.borderColor) {
        [path setLineWidth:2 * self.borderWidth];
        [self.borderColor setStroke];
        [path stroke];
    }
}

- (void)__dealloc {
    if (self.hadAddObserver) {
        [self removeObserver:self forKeyPath:@"image"];
    }
    
    [self __dealloc];
}

- (void)__layoutSubviews {
    [self __layoutSubviews];
    
    if (self.isRounding) {
        [self updateImage:self.image withRadius:CGRectGetWidth(self.frame)/2 withCorner:UIRectCornerAllCorners];
    } else if (0 != self.radius && 0 != self.corner && nil != self.image) {
        [self updateImage:self.image withRadius:self.radius withCorner:self.corner];
    }
}

#pragma mark - getters and setters

- (CGFloat)borderWidth {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    objc_setAssociatedObject(self, @selector(borderWidth), @(borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)borderColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBorderColor:(UIColor *)borderColor {
    objc_setAssociatedObject(self, @selector(borderColor), borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hadAddObserver {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setHadAddObserver:(BOOL)hadAddObserver {
    objc_setAssociatedObject(self, @selector(hadAddObserver), @(hadAddObserver), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isRounding {
    objc_getAssociatedObject(self, _cmd);
}

- (void)setRounding:(BOOL)rounding {
    objc_setAssociatedObject(self, @selector(isRounding), @(rounding), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIRectCorner)corner {
    return [objc_getAssociatedObject(self, _cmd) unsignedLongValue];
}

- (void)setCorner:(UIRectCorner)corner {
    objc_setAssociatedObject(self, @selector(corner), @(corner), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)radius {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setRadius:(CGFloat)radius {
    objc_setAssociatedObject(self, @selector(radius), @(radius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
