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
 Provides extensions for `CALayer`.
 */
@interface CALayer (ZKAdd)

/**
 Take snapshot without transform, image's size equals to bounds.
 */
- (nullable UIImage *)snapshotImage;

/**
 Take snapshot without transform, PDF's page size equals to bounds.
 */
- (nullable NSData *)snapshotPDF;

/**
 Shortcut to set the layer's shadow
 
 @param color  Shadow Color
 @param offset Shadow offset
 @param radius Shadow radius
 */
- (void)setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;

/**
 Remove all sublayers.
 */
- (void)removeAllSublayers;

@property (nonatomic) CGFloat left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGPoint center;      ///< Shortcut for center.
@property (nonatomic) CGFloat centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint origin;      ///< Shortcut for frame.origin.
@property (nonatomic, getter=frameSize, setter=setFrameSize:) CGSize  size; ///< Shortcut for frame.size.


@property (nonatomic) CGFloat transformRotation;     ///< key path "tranform.rotation"
@property (nonatomic) CGFloat transformRotationX;    ///< key path "tranform.rotation.x"
@property (nonatomic) CGFloat transformRotationY;    ///< key path "tranform.rotation.y"
@property (nonatomic) CGFloat transformRotationZ;    ///< key path "tranform.rotation.z"
@property (nonatomic) CGFloat transformScale;        ///< key path "tranform.scale"
@property (nonatomic) CGFloat transformScaleX;       ///< key path "tranform.scale.x"
@property (nonatomic) CGFloat transformScaleY;       ///< key path "tranform.scale.y"
@property (nonatomic) CGFloat transformScaleZ;       ///< key path "tranform.scale.z"
@property (nonatomic) CGFloat transformTranslationX; ///< key path "tranform.translation.x"
@property (nonatomic) CGFloat transformTranslationY; ///< key path "tranform.translation.y"
@property (nonatomic) CGFloat transformTranslationZ; ///< key path "tranform.translation.z"

/**
 Shortcut for transform.m34, -1/1000 is a good value.
 It should be set before other transform shortcut.
 */
@property (nonatomic) CGFloat transformDepth;

/**
 Wrapper for `contentsGravity` property.
 */
@property (nonatomic) UIViewContentMode contentMode;

/**
 Add a fade animation to layer's contents when the contents is changed.
 
 @param duration Animation duration
 @param curve    Animation curve.
 */
- (void)addFadeAnimationWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve;

/**
 Cancel fade animation which is added with "-addFadeAnimationWithDuration:curve:".
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
