//
//  UIImage+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/8.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ZKAdd)

/*!
 *    @brief    压缩图片质量达到指定大小
 *    @param    maxLength     压缩后图片大小小于这个值单位字节 1024 -> 1kb
 */
- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength NS_SWIFT_NAME(compressQuality(maxLength:));

/*!
 *    @brief    通过压缩图片尺寸来达到图片指定大小
 *    @param    maxLength     压缩后图片大小小于这个值单位字节 1024 -> 1kb
 */
- (NSData *)compressBySizeWithMaxLength:(NSUInteger)maxLength NS_SWIFT_NAME(compressBySize(maxLength:));

/*!
 *    @brief    获取当前图片的均色，原理是将图片绘制到1px*1px的矩形内，再从当前区域取色，得到图片的均色。
 *    @link http://www.bobbygeorgescu.com/2011/08/finding-average-color-of-uiimage/ @/link
 *
 *    @return 代表图片平均颜色的UIColor对象
 */
- (UIColor *)averageColor;

#pragma mark - Create image
///=============================================================================
/// @name 创建图片
///=============================================================================

/**
 从 GIF 数据创建动图。创建后可通过 .images 属性访问各帧。若非动图，效果同 [UIImage imageWithData:data scale:scale]。

 @discussion 显示性能较好，但占用内存较大（宽×高×帧数 字节）。仅适合小动图（如表情）。大动图可参考 `YYImage`。

 @param data  GIF 数据。
 @param scale 缩放因子。
 @return 从 GIF 创建的新图片，失败返回 nil。
 */
+ (nullable UIImage *)imageWithSmallGIFData:(NSData *)data scale:(CGFloat)scale;

/**
 判断数据是否为动图 GIF。

 @param data 图片数据。
 @return 仅当为 GIF 且多于一帧时返回 YES，否则 NO。
 */
+ (BOOL)isAnimatedGIFData:(NSData *)data;

/**
 判断指定路径文件是否为 GIF。

 @param path 绝对文件路径。
 @return 是 GIF 返回 YES，否则 NO。
 */
+ (BOOL)isAnimatedGIFFile:(NSString *)path;

/**
 从 PDF 数据或路径创建图片。

 @discussion 多页 PDF 仅取第一页。图片 scale 等于当前屏幕 scale，尺寸与 PDF 原始尺寸一致。

 @param dataOrPath `NSData` 形式的 PDF 或 `NSString` 形式的路径。
 @return 从 PDF 创建的新图片，失败返回 nil。
 */
+ (nullable UIImage *)imageWithPDF:(id)dataOrPath;

/**
 从 PDF 数据或路径创建指定尺寸的图片。

 @discussion 多页 PDF 仅取第一页。图片 scale 等于当前屏幕 scale，内容按需拉伸。

 @param dataOrPath PDF 数据或路径。
 @param size       目标图片尺寸。
 @return 从 PDF 创建的新图片，失败返回 nil。
 */
+ (nullable UIImage *)imageWithPDF:(id)dataOrPath size:(CGSize)size;

/**
 从 Apple 表情字符创建方形图片。

 @discussion 图片 scale 等于当前屏幕 scale。`AppleColorEmoji` 字体中原始表情为 160×160 像素。

 @param emoji 单个表情，如 @"😄"。
 @param size  图片尺寸。
 @return 从表情生成的图片，失败返回 nil。
 */
+ (nullable UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size;

/**
 创建并返回 1×1 点、指定颜色的图片。

 @param color 颜色。
 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color;

/**
 创建并返回指定颜色和尺寸的纯色图。

 @param color 颜色。
 @param size  图片尺寸。
 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 使用自定义绘制代码创建并返回图片。

 @param size      图片尺寸。
 @param drawBlock 绘制 block。
 @return 新图片。
 */
+ (nullable UIImage *)imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock;

/*!
 *  @brief    根据字符串生成二维码
 *  @param    data    字符串内容
 *  @param    size    生成的二维码图片大小
 */
+ (nullable UIImage *)generateQuickResponseCodeWithSize:(CGSize)size dataValue:(NSString *)data centerImage:(nullable UIImage *)image NS_AVAILABLE_IOS(7_0);
+ (nullable UIImage *)generateQuickResponseCodeWithSize:(CGSize)size dataValue:(NSString *)data centerImage:(nullable UIImage *)image centerImageSize:(CGSize)centerImgSize NS_AVAILABLE_IOS(7_0);

#pragma mark - Image Info
///=============================================================================
/// @name 图片信息
///=============================================================================

/**
 图片是否包含 alpha 通道。
 */
- (BOOL)hasAlphaChannel;

#pragma mark - Modify Image
///=============================================================================
/// @name 修改图片
///=============================================================================

/**
 在指定矩形内绘制整张图片，按 contentMode 摆放内容。

 @discussion 在当前图形上下文中绘制，会考虑图片方向。默认坐标系下图片在矩形原点右下方。会受当前图形上下文变换影响。

 @param rect        绘制区域。
 @param contentMode 内容模式。
 @param clips       是否裁切到矩形内。
 */
- (void)drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;

/**
 将图片缩放到指定尺寸，按需拉伸。

 @param size 目标尺寸，应为正数。
 @return 缩放后的新图片。
 */
- (nullable UIImage *)imageByResizeToSize:(CGSize)size NS_SWIFT_NAME(resize(to:));

/**
 将图片按 contentMode 缩放到指定尺寸。

 @param size        目标尺寸，应为正数。
 @param contentMode 内容模式。
 @return 缩放后的新图片。
 */
- (nullable UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode NS_SWIFT_NAME(resize(to:contentMode:));

/**
 从本图裁剪出指定矩形区域的新图。

 @param rect 图片内矩形区域。
 @return 新图片，失败返回 nil。
 */
- (nullable UIImage *)imageByCropToRect:(CGRect)rect NS_SWIFT_NAME(crop(to:));

/**
 对图片边缘做内嵌（或负值外扩），用指定颜色填充扩展区域。

 @param insets 各边内嵌值，负值表示外扩。
 @param color  扩展区域填充色，nil 表示透明。
 @return 新图片，失败返回 nil。
 */
- (nullable UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(nullable UIColor *)color;

/**
 生成圆角图片。

 @param radius 圆角半径，超过宽高一半时会被限制为一半。
 */
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius NS_SWIFT_NAME(roundCorner(radius:));

/**
 生成带边框的圆角图片。

 @param radius      圆角半径。
 @param borderWidth 边框线宽。
 @param borderColor 边框颜色，nil 表示透明。
 */
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(nullable UIColor *)borderColor NS_SWIFT_NAME(roundCorner(radius:borderWidth:borderColor:));

/**
 对指定角做圆角，生成新图。

 @param radius        圆角半径。
 @param corners        要圆角的角（位掩码）。
 @param borderWidth   边框线宽。
 @param borderColor   边框颜色，nil 表示透明。
 @param borderLineJoin 边框线连接方式。
 */
- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                       corners:(UIRectCorner)corners
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(nullable UIColor *)borderColor
                                borderLineJoin:(CGLineJoin)borderLineJoin NS_SWIFT_NAME(roundCorner(radius:corners:borderWidth:borderColor:borderLineJoin:));

/**
 绕中心旋转，返回新图。

 @param radians 逆时针旋转弧度。⟲
 @param fitSize YES：新图尺寸扩展以容纳全部内容；NO：尺寸不变，内容可能被裁切。
 */
- (nullable UIImage *)imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize NS_SWIFT_NAME(rotate(radians:fitSize:));

/**
 逆时针旋转 90°，宽高互换。⤺
 */
- (nullable UIImage *)imageByRotateLeft90 NS_SWIFT_NAME(rotateLeft90());

/**
 顺时针旋转 90°，宽高互换。⤼
 */
- (nullable UIImage *)imageByRotateRight90 NS_SWIFT_NAME(rotateRight90());

/**
 旋转 180°。↻
 */
- (nullable UIImage *)imageByRotate180 NS_SWIFT_NAME(rotate180());

/**
 垂直翻转。⥯
 */
- (nullable UIImage *)imageByFlipVertical NS_SWIFT_NAME(flipVertical());

/**
 水平翻转。⇋
 */
- (nullable UIImage *)imageByFlipHorizontal NS_SWIFT_NAME(flipHorizontal());

#pragma mark - Image Effect
///=============================================================================
/// @name 图片效果
///=============================================================================

/**
 用给定颜色在 alpha 通道对图像着色。

 @param color 着色颜色。
 */
- (nullable UIImage *)imageByTintColor:(UIColor *)color NS_SWIFT_NAME(tint(color:));

/**
 返回灰度图。
 */
- (nullable UIImage *)imageByGrayscale NS_SWIFT_NAME(grayscale());

/**
 对图片应用模糊效果，适用于任意内容。
 */
- (nullable UIImage *)imageByBlurSof NS_SWIFT_NAME(blurSof());

/**
 对图片应用模糊效果，适用于非纯白内容（类似 iOS 控制中心）。
 */
- (nullable UIImage *)imageByBlurLight NS_SWIFT_NAME(blurLight());

/**
 对图片应用模糊效果，适于在其上显示黑色文字（类似 iOS 导航栏白底）。
 */
- (nullable UIImage *)imageByBlurExtraLight NS_SWIFT_NAME(blurExtraLight());

/**
 对图片应用模糊效果，适于在其上显示白色文字（类似 iOS 通知中心）。
 */
- (nullable UIImage *)imageByBlurDark NS_SWIFT_NAME(blurDark());

/**
 对图片应用模糊并叠加 tint 颜色。

 @param tintColor 叠加颜色。
 */
- (nullable UIImage *)imageByBlurWithTint:(UIColor *)tintColor NS_SWIFT_NAME(blur(tint:));

/**
 对图片应用模糊、tint 和饱和度调整，可限定在 maskImage 指定区域内。

 @param blurRadius    模糊半径（点），0 表示无模糊。
 @param tintColor     与模糊/饱和度结果混合的颜色，alpha 决定强度，nil 表示不 tint。
 @param tintBlendMode tint 的混合模式，默认 kCGBlendModeNormal (0)。
 @param saturation    1.0 不变，<1.0 降饱和度，>1.0 提高饱和度，0 为灰度。
 @param maskImage     若指定，仅在 mask 定义区域内生效，须为图像 mask 或满足 CGContextClipToMask 的 mask 要求。
 @return 应用效果后的图片，失败（如内存不足）返回 nil。
 */
- (nullable UIImage *)imageByBlurRadius:(CGFloat)blurRadius
                              tintColor:(nullable UIColor *)tintColor
                               tintMode:(CGBlendMode)tintBlendMode
                             saturation:(CGFloat)saturation
                              maskImage:(nullable UIImage *)maskImage NS_SWIFT_NAME(blur(radius:tintColor:tintMode:saturation:maskImage:));

@end

NS_ASSUME_NONNULL_END
