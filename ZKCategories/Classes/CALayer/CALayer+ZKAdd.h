//
//  CALayer+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 为 `CALayer` 提供扩展。
 */
@interface CALayer (ZKAdd)

/**
 不应用变换截取快照，图片尺寸等于 bounds。
 */
- (nullable UIImage *)snapshotImage;

/**
 不应用变换截取快照，PDF 页面尺寸等于 bounds。
 */
- (nullable NSData *)snapshotPDF;

/**
 快捷设置 layer 的阴影
 
 @param color  阴影颜色
 @param offset 阴影偏移
 @param radius 阴影圆角半径
 */
- (void)setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;

/**
 移除所有子 layer。
 */
- (void)removeAllSublayers;

@property (nonatomic) CGFloat left;        ///< frame.origin.x 的快捷方式
@property (nonatomic) CGFloat top;         ///< frame.origin.y 的快捷方式
@property (nonatomic) CGFloat right;       ///< frame.origin.x + frame.size.width 的快捷方式
@property (nonatomic) CGFloat bottom;      ///< frame.origin.y + frame.size.height 的快捷方式
@property (nonatomic) CGFloat width;       ///< frame.size.width 的快捷方式
@property (nonatomic) CGFloat height;      ///< frame.size.height 的快捷方式
@property (nonatomic) CGPoint center;      ///< center 的快捷方式
@property (nonatomic) CGFloat centerX;     ///< center.x 的快捷方式
@property (nonatomic) CGFloat centerY;     ///< center.y 的快捷方式
@property (nonatomic) CGPoint origin;      ///< frame.origin 的快捷方式
@property (nonatomic, getter=frameSize, setter=setFrameSize:) CGSize  size; ///< frame.size 的快捷方式


@property (nonatomic) CGFloat transformRotation;     ///< key path "tranform.rotation"
@property (nonatomic) CGFloat transformRotationX;    ///< key path "tranform.rotation.x"
@property (nonatomic) CGFloat transformRotationY;    ///< key path "tranform.rotation.y"
@property (nonatomic) CGFloat transformRotationZ;   ///< key path "tranform.rotation.z"
@property (nonatomic) CGFloat transformScale;        ///< key path "tranform.scale"
@property (nonatomic) CGFloat transformScaleX;       ///< key path "tranform.scale.x"
@property (nonatomic) CGFloat transformScaleY;       ///< key path "tranform.scale.y"
@property (nonatomic) CGFloat transformScaleZ;       ///< key path "tranform.scale.z"
@property (nonatomic) CGFloat transformTranslationX; ///< key path "tranform.translation.x"
@property (nonatomic) CGFloat transformTranslationY; ///< key path "tranform.translation.y"
@property (nonatomic) CGFloat transformTranslationZ; ///< key path "tranform.translation.z"

/**
 transform.m34 的快捷方式，-1/1000 为常用值。
 应在其他 transform 快捷方式之前设置。
 */
@property (nonatomic) CGFloat transformDepth;

/**
 `contentsGravity` 属性的封装。
 */
@property (nonatomic) UIViewContentMode contentMode;

/**
 当 layer 的 contents 变化时添加淡入淡出动画。
 
 @param duration 动画时长
 @param curve    动画曲线
 */
- (void)addFadeAnimationWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve;

/**
 取消通过 "-addFadeAnimationWithDuration:curve:" 添加的淡入淡出动画。
 */
- (void)removePreviousFadeAnimation;

/**
 *  把某个 sublayer 移动到当前所有 sublayers 的最后面
 *  @param sublayer 要被移动的 layer
 *  @warning 要被移动的 sublayer 必须已经添加到当前 layer 上
 */
- (void)sendSublayerToBack:(CALayer *)sublayer;

/**
 * 移除 CALayer（包括 CAShapeLayer 和 CAGradientLayer）所有支持动画的属性的默认动画，方便需要一个不带动画的 layer 时使用。
 */
- (void)removeDefaultAnimations;

@end

NS_ASSUME_NONNULL_END
