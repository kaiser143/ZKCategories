//
//  UIVisualEffectView+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2025/2/26.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UIVisualEffectView+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "CALayer+ZKAdd.h"
#import "ZKCGUtilities.h"

@interface UIView (VisualEffectView)

// 为了方便，这个属性声明在 UIView 里，但实际上只有两个私有的 Visual View 会用到
@property(nonatomic, assign) BOOL kai_keepHidden;
@end

@interface UIVisualEffectView ()

@property(nonatomic, strong) CALayer *kai_foregroundLayer;
@property(nonatomic, assign, readonly) BOOL kai_showsForegroundLayer;

@end

@implementation UIVisualEffectView (ZKAdd)

- (void)setKai_foregroundLayer:(CALayer *)layer {
    [self setAssociateValue:layer withKey:@selector(kai_foregroundLayer)];
}

- (CALayer *)kai_foregroundLayer {
    return [self associatedValueForKey:_cmd];;
}

- (void)setKai_foregroundColor:(UIColor *)foregroundColor {
    [self setAssociateValue:foregroundColor withKey:@selector(kai_foregroundColor)];

    if (foregroundColor && !self.kai_foregroundLayer) {
        self.kai_foregroundLayer = [CALayer layer];
        [self.kai_foregroundLayer removeDefaultAnimations];
        [self.layer addSublayer:self.kai_foregroundLayer];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIAccessibilityReduceTransparencyStatusDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReduceTransparencyStatusDidChangeNotification:) name:UIAccessibilityReduceTransparencyStatusDidChangeNotification object:nil];
    }
    if (self.kai_foregroundLayer) {
        if (UIAccessibilityIsReduceTransparencyEnabled()) {
            foregroundColor = [foregroundColor colorWithAlphaComponent:1];
        }
        self.kai_foregroundLayer.backgroundColor = foregroundColor.CGColor;
        self.kai_foregroundLayer.hidden = !foregroundColor;
        [self kai_updateSubviews];
        [self setNeedsLayout];
    }
}

- (UIColor *)kai_foregroundColor {
    return [self associatedValueForKey:_cmd];
}

- (BOOL)kai_showsForegroundLayer {
    return self.kai_foregroundLayer && !self.kai_foregroundLayer.hidden;
}

- (void)kai_updateSubviews {
    if (self.kai_foregroundLayer) {
        
        // 先放在最背后，然后在遇到磨砂的 backdropLayer 时再放到它前面，因为有些情况下可能不存在 backdropLayer（例如 effect = nil 或者 effect 为 UIVibrancyEffect）
        [self.layer sendSublayerToBack:self.kai_foregroundLayer];
        for (NSInteger i = 0; i < self.layer.sublayers.count; i++) {
            CALayer *sublayer = self.layer.sublayers[i];
            if ([NSStringFromClass(sublayer.class) isEqualToString:@"UICABackdropLayer"]) {
                [self.layer insertSublayer:self.kai_foregroundLayer above:sublayer];
                break;
            }
        }
        
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *className = NSStringFromClass(subview.class);
            if ([className isEqualToString:@"_UIVisualEffectSubview"] || [className isEqualToString:@"_UIVisualEffectFilterView"]) {
                subview.kai_keepHidden = !self.kai_foregroundLayer.hidden;
            }
        }];
    }
}

- (void)handleReduceTransparencyStatusDidChangeNotification:(NSNotification *)notification {
    if (self.kai_foregroundColor) {
        self.kai_foregroundColor = self.kai_foregroundColor;
    }
}

@end


@implementation UIView (VisualEffectView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation(NSClassFromString(@"_UIVisualEffectSubview"), @selector(setHidden:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, BOOL firstArgv) {
                
                if (selfObject.kai_keepHidden) {
                    firstArgv = YES;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

- (void)setKai_keepHidden:(BOOL)keepHidden {
    [self setAssociateValue:@(keepHidden) withKey:@selector(kai_keepHidden)];
    // 从语义来看，当 keepHidden = NO 时，并不意味着 hidden 就一定要为 NO，但为了方便添加了 foregroundColor 后再去除 foregroundColor 时做一些恢复性质的操作，这里就实现成 keepHidden = NO 时 hidden = NO
    self.hidden = keepHidden;
}

- (BOOL)kai_keepHidden {
    return [[self associatedValueForKey:_cmd] boolValue];
}

@end
