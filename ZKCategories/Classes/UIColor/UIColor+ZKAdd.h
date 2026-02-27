//
//  UIColor+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/9/25.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN void ZK_RGB2HSL(CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *l);

UIKIT_EXTERN void ZK_HSL2RGB(CGFloat h, CGFloat s, CGFloat l, CGFloat *r, CGFloat *g, CGFloat *b);

UIKIT_EXTERN void ZK_RGB2HSB(CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *v);

UIKIT_EXTERN void ZK_HSB2RGB(CGFloat h, CGFloat s, CGFloat v, CGFloat *r, CGFloat *g, CGFloat *b);

UIKIT_EXTERN void ZK_RGB2CMYK(CGFloat r, CGFloat g, CGFloat b, CGFloat *c, CGFloat *m, CGFloat *y, CGFloat *k);

UIKIT_EXTERN void ZK_CMYK2RGB(CGFloat c, CGFloat m, CGFloat y, CGFloat k, CGFloat *r, CGFloat *g, CGFloat *b);

UIKIT_EXTERN void ZK_HSB2HSL(CGFloat h, CGFloat s, CGFloat b, CGFloat *hh, CGFloat *ss, CGFloat *ll);

UIKIT_EXTERN void ZK_HSL2HSB(CGFloat h, CGFloat s, CGFloat l, CGFloat *hh, CGFloat *ss, CGFloat *bb);

/*
 使用十六进制字符串创建 UIColor。
 示例：UIColorHex(0xF0F)、UIColorHex(66ccff)、UIColorHex(#66CCFF88)
 合法格式：#RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB ...，可不带 `#` 或 "0x"。
 */
#ifndef UIColorHex
#define UIColorHex(_hex_) [UIColor colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif

@interface UIColor (ZKAdd)

/*!
 *    @brief 用于调试的随机颜色
 */
+ (UIColor *)randomColor NS_SWIFT_NAME(random());

#pragma mark - 创建 UIColor
///=============================================================================
/// @name 创建 UIColor
///=============================================================================

/**
 使用 HSL 分量和透明度创建颜色对象。

 @param hue        色相 (0.0~1.0)。
 @param saturation 饱和度 (0.0~1.0)。
 @param lightness  亮度 (0.0~1.0)。
 @param alpha      透明度 (0.0~1.0)。
 @return 颜色对象，对应设备 RGB 色彩空间。
 */
+ (UIColor *)colorWithHue:(CGFloat)hue
               saturation:(CGFloat)saturation
                lightness:(CGFloat)lightness
                    alpha:(CGFloat)alpha;

/**
 使用 CMYK 分量和透明度创建颜色对象。

 @param cyan    青 (0.0~1.0)。
 @param magenta 品红 (0.0~1.0)。
 @param yellow  黄 (0.0~1.0)。
 @param black   黑 (0.0~1.0)。
 @param alpha   透明度 (0.0~1.0)。
 @return 颜色对象，对应设备 RGB 色彩空间。
 */
+ (UIColor *)colorWithCyan:(CGFloat)cyan
                   magenta:(CGFloat)magenta
                    yellow:(CGFloat)yellow
                     black:(CGFloat)black
                     alpha:(CGFloat)alpha;

/**
 使用十六进制 RGB 值创建颜色（如 0x66ccff）。

 @param rgbValue RGB 值。
 @return 颜色对象，对应设备 RGB 色彩空间。
 */
+ (UIColor *)colorWithRGB:(uint32_t)rgbValue;

/**
 使用十六进制 RGBA 值创建颜色（如 0x66ccffff）。

 @param rgbaValue RGBA 值。
 @return 颜色对象，对应设备 RGB 色彩空间。
 */
+ (UIColor *)colorWithRGBA:(uint32_t)rgbaValue;

/**
 使用十六进制 RGB 和透明度创建颜色。

 @param rgbValue RGB 值，如 0x66CCFF。
 @param alpha    透明度 (0.0~1.0)。
 @return 颜色对象，对应设备 RGB 色彩空间。
 */
+ (UIColor *)colorWithRGB:(uint32_t)rgbValue alpha:(CGFloat)alpha;

/**
 从十六进制字符串创建颜色对象。

 @discussion 合法格式：#RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB ...，可不带 # 或 "0x"。
 无 alpha 时默认为 1.0。解析失败返回 nil。示例：@"0xF0F", @"66ccff", @"#66CCFF88"

 @param string 十六进制字符串。
 @return 颜色对象，失败返回 nil。
 */
+ (nullable UIColor *)colorWithHexString:(NSString *)string NS_SWIFT_NAME(hex(_:));

/**
 将当前颜色与另一颜色按混合模式混合，返回新颜色。

 @param add       要叠加的颜色。
 @param blendMode 混合模式。
 */
- (UIColor *)colorByAddColor:(UIColor *)add blendMode:(CGBlendMode)blendMode;

/**
 按分量偏移量生成新颜色。

 @param hueDelta        色相偏移 (-1.0~1.0)，0 表示不变。
 @param saturationDelta 饱和度偏移 (-1.0~1.0)，0 表示不变。
 @param brightnessDelta  亮度偏移 (-1.0~1.0)，0 表示不变。
 @param alphaDelta      透明度偏移 (-1.0~1.0)，0 表示不变。
 */
- (UIColor *)colorByChangeHue:(CGFloat)hueDelta
                   saturation:(CGFloat)saturationDelta
                   brightness:(CGFloat)brightnessDelta
                        alpha:(CGFloat)alphaDelta NS_SWIFT_NAME(change(hue:saturation:brightness:alpha:));

#pragma mark - 颜色的描述
///=============================================================================
/// @name 颜色的描述
///=============================================================================

/**
 返回 RGB 的十六进制值，如 0x66ccff。
 */
- (uint32_t)rgbValue;

/**
 返回 RGBA 的十六进制值，如 0x66ccffff。
 */
- (uint32_t)rgbaValue;

/**
 返回 RGB 的小写十六进制字符串，如 @"0066cc"。非 RGB 色彩空间时返回 nil。
 */
- (nullable NSString *)hexString;

/**
 返回 RGBA 的小写十六进制字符串，如 @"0066ccff"。非 RGBA 色彩空间时返回 nil。
 */
- (nullable NSString *)hexStringWithAlpha;

#pragma mark - 获取颜色信息
///=============================================================================
/// @name 获取颜色信息
///=============================================================================

/**
 返回颜色在 HSL 色彩空间中的分量（0.0~1.0）。通过指针输出。

 @param hue        色相。
 @param saturation 饱和度。
 @param lightness  亮度。
 @param alpha      透明度。
 @return 能转换返回 YES，否则 NO。
 */
- (BOOL)getHue:(CGFloat *)hue
    saturation:(CGFloat *)saturation
     lightness:(CGFloat *)lightness
         alpha:(CGFloat *)alpha;

/**
 返回颜色在 CMYK 色彩空间中的分量（0.0~1.0）。通过指针输出。

 @param cyan    青。
 @param magenta 品红。
 @param yellow  黄。
 @param black   黑。
 @param alpha   透明度。
 @return 能转换返回 YES，否则 NO。
 */
- (BOOL)getCyan:(CGFloat *)cyan
        magenta:(CGFloat *)magenta
         yellow:(CGFloat *)yellow
          black:(CGFloat *)black
          alpha:(CGFloat *)alpha;

/**
 RGB 色彩空间中的红色分量，范围 0.0~1.0。
 */
@property (nonatomic, readonly) CGFloat red;

/**
 RGB 色彩空间中的绿色分量，范围 0.0~1.0。
 */
@property (nonatomic, readonly) CGFloat green;

/**
 RGB 色彩空间中的蓝色分量，范围 0.0~1.0。
 */
@property (nonatomic, readonly) CGFloat blue;

/**
 HSB 色彩空间中的色相分量，范围 0.0~1.0。
 */
@property (nonatomic, readonly) CGFloat hue;

/**
 HSB 色彩空间中的饱和度分量，范围 0.0~1.0。
 */
@property (nonatomic, readonly) CGFloat saturation;

/**
 HSB 色彩空间中的亮度分量，范围 0.0~1.0。
 */
@property (nonatomic, readonly) CGFloat brightness;

/**
 透明度分量，范围 0.0~1.0。
 */
@property (nonatomic, readonly) CGFloat alpha;

/**
 色彩空间模型。
 */
@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;

/**
 色彩空间的可读字符串描述。
 */
@property (nullable, nonatomic, readonly) NSString *colorSpaceString;

@end

NS_ASSUME_NONNULL_END
