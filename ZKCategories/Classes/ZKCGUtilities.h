//
//  ZKCGUtilities.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "NSMethodSignature+ZKAdd.h"
#import "ZKCategoriesMacro.h"

NS_ASSUME_NONNULL_BEGIN

/// 创建 `ARGB` 位图上下文。出错时返回 NULL。
///
/// @discussion 与 UIGraphicsBeginImageContextWithOptions() 类似，
/// 但不会将上下文压入 UIGraphic，因此可保留上下文以便复用。
CGContextRef _Nullable ZKCGContextCreateARGBBitmapContext(CGSize size, BOOL opaque, CGFloat scale);

/// 创建 `DeviceGray` 位图上下文。出错时返回 NULL。
CGContextRef _Nullable ZKCGContextCreateGrayBitmapContext(CGSize size, CGFloat scale);



/// 获取主屏 scale。
CGFloat ZKScreenScale(void);

/// 获取主屏尺寸（竖屏下高度大于宽度）。
CGSize ZKScreenSize(void);



/// 角度转弧度。
CG_INLINE CGFloat DegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

/// 弧度转角度。
CG_INLINE CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}



/// 获取变换的旋转角。
/// @return 弧度 [-PI,PI]（即 [-180°,180°]）
CG_INLINE CGFloat CGAffineTransformGetRotation(CGAffineTransform transform) {
    return atan2(transform.b, transform.a);
}

/// 获取变换的 scale.x
CG_INLINE CGFloat CGAffineTransformGetScaleX(CGAffineTransform transform) {
    return  sqrt(transform.a * transform.a + transform.c * transform.c);
}

/// 获取变换的 scale.y
CG_INLINE CGFloat CGAffineTransformGetScaleY(CGAffineTransform transform) {
    return sqrt(transform.b * transform.b + transform.d * transform.d);
}

/// 获取变换的 translate.x
CG_INLINE CGFloat CGAffineTransformGetTranslateX(CGAffineTransform transform) {
    return transform.tx;
}

/// 获取变换的 translate.y
CG_INLINE CGFloat CGAffineTransformGetTranslateY(CGAffineTransform transform) {
    return transform.ty;
}

/**
 若有三对点被同一 CGAffineTransform 变换：
 p1 (transform->) q1
 p2 (transform->) q2
 p3 (transform->) q3
 本方法根据这三对点还原出原始变换矩阵。
 
 @see http://stackoverflow.com/questions/13291796/calculate-values-for-a-cgaffinetransform-from-three-points-in-each-of-two-uiview
 */
CGAffineTransform ZKCGAffineTransformGetFromPoints(CGPoint before[_Nullable 3], CGPoint after[_Nullable 3]);

/// 获取将点从一个视图坐标系转换到另一视图坐标系的变换。
CGAffineTransform ZKCGAffineTransformGetFromViews(UIView *from, UIView *to);

/// 创建错切变换。
CG_INLINE CGAffineTransform CGAffineTransformMakeSkew(CGFloat x, CGFloat y){
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform.c = -x;
    transform.b = y;
    return transform;
}

/// 将 CALayer 的 gravity 字符串转换为 UIViewContentMode。
UIViewContentMode ZKCAGravityToUIViewContentMode(NSString *gravity);

/// 将 UIViewContentMode 转换为 CALayer 的 gravity 字符串。
NSString *ZKUIViewContentModeToCAGravity(UIViewContentMode contentMode);



/**
 根据指定 content mode 在 rect 内适配内容，返回适配后的矩形。
 
 @param rect 约束矩形
 @param size 内容尺寸
 @param mode 内容模式
 @return 适配后的矩形
 @discussion UIViewContentModeRedraw 按 UIViewContentModeScaleToFill 处理。
 */
CGRect ZKCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode);

/// 返回矩形的中心点。
CG_INLINE CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

/// 返回矩形面积。
CG_INLINE CGFloat CGRectGetArea(CGRect rect) {
    if (CGRectIsNull(rect)) return 0;
    rect = CGRectStandardize(rect);
    return rect.size.width * rect.size.height;
}

/// 返回两点之间的距离。
CG_INLINE CGFloat CGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

/// 返回点到矩形的最短距离。
CG_INLINE CGFloat CGPointGetDistanceToRect(CGPoint p, CGRect r) {
    r = CGRectStandardize(r);
    if (CGRectContainsPoint(r, p)) return 0;
    CGFloat distV, distH;
    if (CGRectGetMinY(r) <= p.y && p.y <= CGRectGetMaxY(r)) {
        distV = 0;
    } else {
        distV = p.y < CGRectGetMinY(r) ? CGRectGetMinY(r) - p.y : p.y - CGRectGetMaxY(r);
    }
    if (CGRectGetMinX(r) <= p.x && p.x <= CGRectGetMaxX(r)) {
        distH = 0;
    } else {
        distH = p.x < CGRectGetMinX(r) ? CGRectGetMinX(r) - p.x : p.x - CGRectGetMaxX(r);
    }
    return MAX(distV, distH);
}


/// 检测某个数值如果为 NaN 则将其转换为 0，避免布局中出现 crash
CG_INLINE CGFloat CGFloatSafeValue(CGFloat value) {
    return isnan(value) ? 0 : value;
}

/// 点转像素。
CG_INLINE CGFloat CGFloatToPixel(CGFloat value) {
    return value * ZKScreenScale();
}

/// 像素转点。
CG_INLINE CGFloat CGFloatFromPixel(CGFloat value) {
    return value / ZKScreenScale();
}

/// 向下取整到像素对齐
CG_INLINE CGFloat CGFloatPixelFloor(CGFloat value) {
    CGFloat scale = ZKScreenScale();
    return floor(value * scale) / scale;
}

/**
 *  某些地方可能会将 CGFLOAT_MIN 作为一个数值参与计算（但其实 CGFLOAT_MIN 更应该被视为一个标志位而不是数值），可能导致一些精度问题，所以提供这个方法快速将 CGFLOAT_MIN 转换为 0
 */
CG_INLINE CGFloat removeFloatMin(CGFloat floatValue) {
    return floatValue == CGFLOAT_MIN ? 0 : floatValue;
}

/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整。若指定倍数为0，则表示以当前设备的屏幕倍数为准。
 *
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */
CG_INLINE CGFloat flatSpecificScale(CGFloat floatValue, CGFloat scale) {
    floatValue = removeFloatMin(floatValue);
    scale = scale ?: ZKScreenScale();
    CGFloat flattedValue = ceil(floatValue * scale) / scale;
    return flattedValue;
}

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */
CG_INLINE CGFloat flat(CGFloat floatValue) {
    return flatSpecificScale(floatValue, 0);
}

/// 四舍五入到像素对齐
CG_INLINE CGFloat CGFloatPixelRound(CGFloat value) {
    CGFloat scale = ZKScreenScale();
    return round(value * scale) / scale;
}

/// 向上取整到像素对齐
CG_INLINE CGFloat CGFloatPixelCeil(CGFloat value) {
    CGFloat scale = ZKScreenScale();
    return ceil(value * scale) / scale;
}

/// 取整到半像素，用于路径描边（奇数线宽像素对齐）
CG_INLINE CGFloat CGFloatPixelHalf(CGFloat value) {
    CGFloat scale = ZKScreenScale();
    return (floor(value * scale) + 0.5) / scale;
}

/// 点坐标向下取整到像素对齐
CG_INLINE CGPoint CGPointPixelFloor(CGPoint point) {
    CGFloat scale = ZKScreenScale();
    return CGPointMake(floor(point.x * scale) / scale,
                       floor(point.y * scale) / scale);
}

/// 点坐标四舍五入到像素对齐
CG_INLINE CGPoint CGPointPixelRound(CGPoint point) {
    CGFloat scale = ZKScreenScale();
    return CGPointMake(round(point.x * scale) / scale,
                       round(point.y * scale) / scale);
}

/// 点坐标向上取整到像素对齐
CG_INLINE CGPoint CGPointPixelCeil(CGPoint point) {
    CGFloat scale = ZKScreenScale();
    return CGPointMake(ceil(point.x * scale) / scale,
                       ceil(point.y * scale) / scale);
}

/// 点坐标取整到半像素，用于路径描边（奇数线宽像素对齐）
CG_INLINE CGPoint CGPointPixelHalf(CGPoint point) {
    CGFloat scale = ZKScreenScale();
    return CGPointMake((floor(point.x * scale) + 0.5) / scale,
                       (floor(point.y * scale) + 0.5) / scale);
}



/// 尺寸向下取整到像素对齐
CG_INLINE CGSize CGSizePixelFloor(CGSize size) {
    CGFloat scale = ZKScreenScale();
    return CGSizeMake(floor(size.width * scale) / scale,
                      floor(size.height * scale) / scale);
}

/// 尺寸四舍五入到像素对齐
CG_INLINE CGSize CGSizePixelRound(CGSize size) {
    CGFloat scale = ZKScreenScale();
    return CGSizeMake(round(size.width * scale) / scale,
                      round(size.height * scale) / scale);
}

/// 尺寸向上取整到像素对齐
CG_INLINE CGSize CGSizePixelCeil(CGSize size) {
    CGFloat scale = ZKScreenScale();
    return CGSizeMake(ceil(size.width * scale) / scale,
                      ceil(size.height * scale) / scale);
}

/// 尺寸取整到半像素，用于路径描边（奇数线宽像素对齐）
CG_INLINE CGSize CGSizePixelHalf(CGSize size) {
    CGFloat scale = ZKScreenScale();
    return CGSizeMake((floor(size.width * scale) + 0.5) / scale,
                      (floor(size.height * scale) + 0.5) / scale);
}

#pragma mark - CGRect

/// 判断一个 CGRect 是否存在 NaN
CG_INLINE BOOL CGRectIsNaN(CGRect rect) {
    return isnan(rect.origin.x) || isnan(rect.origin.y) || isnan(rect.size.width) || isnan(rect.size.height);
}

/// 系统提供的 CGRectIsInfinite 接口只能判断 CGRectInfinite 的情况，而该接口可以用于判断 INFINITY 的值
CG_INLINE BOOL CGRectIsInf(CGRect rect) {
    return isinf(rect.origin.x) || isinf(rect.origin.y) || isinf(rect.size.width) || isinf(rect.size.height);
}

/// 判断一个 CGSize 是否为空（宽或高为0）
CG_INLINE BOOL CGSizeIsEmpty(CGSize size) {
    return size.width <= 0 || size.height <= 0;
}

/// 判断一个 CGRect 是否合法（例如不带无穷大的值、不带非法数字）
CG_INLINE BOOL CGRectIsValidated(CGRect rect) {
    return !CGRectIsNull(rect) && !CGRectIsInfinite(rect) && !CGRectIsNaN(rect) && !CGRectIsInf(rect);
}

/// 检测某个 CGRect 如果存在数值为 NaN 的则将其转换为 0，避免布局中出现 crash
CG_INLINE CGRect CGRectSafeValue(CGRect rect) {
    return CGRectMake(CGFloatSafeValue(CGRectGetMinX(rect)), CGFloatSafeValue(CGRectGetMinY(rect)), CGFloatSafeValue(CGRectGetWidth(rect)), CGFloatSafeValue(CGRectGetHeight(rect)));
}

/// 创建一个像素对齐的CGRect
CG_INLINE CGRect CGRectPixelFloor(CGRect rect) {
    CGPoint origin = CGPointPixelCeil(rect.origin);
    CGPoint corner = CGPointPixelFloor(CGPointMake(rect.origin.x + rect.size.width,
                                                   rect.origin.y + rect.size.height));
    CGRect ret = CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
    if (ret.size.width < 0) ret.size.width = 0;
    if (ret.size.height < 0) ret.size.height = 0;
    return ret;
}

/// 矩形四舍五入到像素对齐
CG_INLINE CGRect CGRectPixelRound(CGRect rect) {
    CGPoint origin = CGPointPixelRound(rect.origin);
    CGPoint corner = CGPointPixelRound(CGPointMake(rect.origin.x + rect.size.width,
                                                   rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// 矩形向上取整到像素对齐
CG_INLINE CGRect CGRectPixelCeil(CGRect rect) {
    CGPoint origin = CGPointPixelFloor(rect.origin);
    CGPoint corner = CGPointPixelCeil(CGPointMake(rect.origin.x + rect.size.width,
                                                  rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// 对CGRect的x/y、width/height都调用一次flat，以保证像素对齐
CG_INLINE CGRect CGRectFlatted(CGRect rect) {
    return CGRectMake(flat(rect.origin.x), flat(rect.origin.y), flat(rect.size.width), flat(rect.size.height));
}

/// 矩形取整到半像素，用于路径描边（奇数线宽像素对齐）
CG_INLINE CGRect CGRectPixelHalf(CGRect rect) {
    CGPoint origin = CGPointPixelHalf(rect.origin);
    CGPoint corner = CGPointPixelHalf(CGPointMake(rect.origin.x + rect.size.width,
                                                  rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// 传入size，返回一个x/y为0的CGRect
CG_INLINE CGRect CGRectMakeWithSize(CGSize size) {
    return CGRectMake(0, 0, size.width, size.height);
}

CG_INLINE CGRect CGRectSetX(CGRect rect, CGFloat x) {
    rect.origin.x = flat(x);
    return rect;
}

CG_INLINE CGRect CGRectSetY(CGRect rect, CGFloat y) {
    rect.origin.y = flat(y);
    return rect;
}

CG_INLINE CGRect CGRectSetXY(CGRect rect, CGFloat x, CGFloat y) {
    rect.origin.x = flat(x);
    rect.origin.y = flat(y);
    return rect;
}

CG_INLINE CGRect CGRectSetWidth(CGRect rect, CGFloat width) {
    if (width < 0) {
        return rect;
    }
    rect.size.width = flat(width);
    return rect;
}

CG_INLINE CGRect CGRectSetHeight(CGRect rect, CGFloat height) {
    if (height < 0) {
        return rect;
    }
    rect.size.height = flat(height);
    return rect;
}

/// 用于居中运算
CG_INLINE CGFloat CGFloatGetCenter(CGFloat parent, CGFloat child) {
    return flat((parent - child) / 2.0);
}

#pragma mark - UIEdgeInsets

/// 将两个UIEdgeInsets合并为一个
CG_INLINE UIEdgeInsets UIEdgeInsetsConcat(UIEdgeInsets insets1, UIEdgeInsets insets2) {
    insets1.top += insets2.top;
    insets1.left += insets2.left;
    insets1.bottom += insets2.bottom;
    insets1.right += insets2.right;
    return insets1;
}

/// 对 UIEdgeInsets 取反。
CG_INLINE UIEdgeInsets UIEdgeInsetsInvert(UIEdgeInsets insets) {
    return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}

/// UIEdgeInsets 向下取整到像素对齐
CG_INLINE UIEdgeInsets UIEdgeInsetPixelFloor(UIEdgeInsets insets) {
    insets.top = CGFloatPixelFloor(insets.top);
    insets.left = CGFloatPixelFloor(insets.left);
    insets.bottom = CGFloatPixelFloor(insets.bottom);
    insets.right = CGFloatPixelFloor(insets.right);
    return insets;
}

/// UIEdgeInsets 向上取整到像素对齐
CG_INLINE UIEdgeInsets UIEdgeInsetPixelCeil(UIEdgeInsets insets) {
    insets.top = CGFloatPixelCeil(insets.top);
    insets.left = CGFloatPixelCeil(insets.left);
    insets.bottom = CGFloatPixelCeil(insets.bottom);
    insets.right = CGFloatPixelCeil(insets.right);
    return insets;
}

CG_INLINE UIEdgeInsets UIEdgeInsetsRemoveFloatMin(UIEdgeInsets insets) {
    UIEdgeInsets result = UIEdgeInsetsMake(removeFloatMin(insets.top), removeFloatMin(insets.left), removeFloatMin(insets.bottom), removeFloatMin(insets.right));
    return result;
}

/// 获取UIEdgeInsets在水平方向上的值
CG_INLINE CGFloat UIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

/// 获取UIEdgeInsets在垂直方向上的值
CG_INLINE CGFloat UIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

/** 设置投影 **/
CG_INLINE void kai_view_shadow(UIView *view, UIColor *color, CGSize offset, CGFloat opacity, CGFloat radius) {
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOffset = offset;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowRadius = radius;
}

/** view 圆角 */
CG_INLINE void kai_view_radius(UIView *view, CGFloat radius) {
    [view.layer setCornerRadius:radius];
    [view.layer setMasksToBounds:YES];
}

/** view 边框 */
CG_INLINE void kai_view_border(UIView *view, CGFloat width, UIColor *color) {
    [view.layer setBorderWidth:(width)];
    [view.layer setBorderColor:[color CGColor]];
}

/** view 圆角 边框 */
CG_INLINE void kai_view_border_radius(UIView *view, CGFloat radius, CGFloat width, UIColor *color) {
    kai_view_radius(view, radius);
    kai_view_border(view, width, color);
}

/**
 view 单个圆角
 
 @param view 试图
 @param angle 某个圆角
 * UIRectCornerTopLeft
 * UIRectCornerTopRight
 * UIRectCornerBottomLeft
 * UIRectCornerBottomRight
 * UIRectCornerAllCorners
 @param radius 圆角度
 */
CG_INLINE void kai_view_singleFillet(UIView *view, UIRectCorner angle, CGFloat radius) {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:angle
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}


// 主屏 scale
#ifndef kScreenScale
#define kScreenScale ZKScreenScale()
#endif

// 主屏尺寸（竖屏）
#ifndef kScreenSize
#define kScreenSize ZKScreenSize()
#endif

// 主屏宽度（竖屏）
#ifndef kScreenWidth
#define kScreenWidth ZKScreenSize().width
#endif

// 主屏高度（竖屏）
#ifndef kScreenHeight
#define kScreenHeight ZKScreenSize().height
#endif

CG_INLINE BOOL HasOverrideSuperclassMethod(Class targetClass, SEL targetSelector) {
    Method method = class_getInstanceMethod(targetClass, targetSelector);
    if (!method) return NO;
    
    Method methodOfSuperclass = class_getInstanceMethod(class_getSuperclass(targetClass), targetSelector);
    if (!methodOfSuperclass) return YES;
    
    return method != methodOfSuperclass;
}

/**
 *  用 block 重写某个 class 的指定方法
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做
 *  @param implementationBlock 该 block 必须返回一个 block，返回的 block 将被当成 targetSelector 的新实现，所以要在内部自己处理对 super 的调用，以及对当前调用方法的 self 的 class 的保护判断（因为如果 targetClass 的 targetSelector 是继承自父类的，targetClass 内部并没有重写这个方法，则我们这个函数最终重写的其实是父类的 targetSelector，所以会产生预期之外的 class 的影响，例如 targetClass 传进来  UIButton.class，则最终可能会影响到 UIView.class），implementationBlock 的参数里第一个为你要修改的 class，也即等同于 targetClass，第二个参数为你要修改的 selector，也即等同于 targetSelector，第三个参数是一个 block，用于获取 targetSelector 原本的实现，由于 IMP 可以直接当成 C 函数调用，所以可利用它来实现“调用 super”的效果，但由于 targetSelector 的参数个数、参数类型、返回值类型，都会影响 IMP 的调用写法，所以这个调用只能由业务自己写。
 */
CG_INLINE BOOL OverrideImplementation(Class targetClass, SEL targetSelector, id (^implementationBlock)(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void))) {
    Method originMethod = class_getInstanceMethod(targetClass, targetSelector);
    IMP imp = method_getImplementation(originMethod);
    BOOL hasOverride = HasOverrideSuperclassMethod(targetClass, targetSelector);
    
    // 以 block 的方式达到实时获取初始方法的 IMP 的目的，从而避免先 swizzle 了 subclass 的方法，再 swizzle superclass 的方法，会发现前者调用时不会触发后者 swizzle 后的版本的 bug。
    IMP (^originalIMPProvider)(void) = ^IMP(void) {
        IMP result = NULL;
        if (hasOverride) {
            result = imp;
        } else {
            // 如果 superclass 里依然没有实现，则会返回一个 objc_msgForward 从而触发消息转发的流程
            // https://github.com/Tencent/QMUI_iOS/issues/776
            Class superclass = class_getSuperclass(targetClass);
            result = class_getMethodImplementation(superclass, targetSelector);
        }
        
        // 这只是一个保底，这里要返回一个空 block 保证非 nil，才能避免用小括号语法调用 block 时 crash
        // 空 block 虽然没有参数列表，但在业务那边被转换成 IMP 后就算传多个参数进来也不会 crash
        if (!result) {
            result = imp_implementationWithBlock(^(id selfObject){
                ZKLog(@"%@ 没有初始实现，%@\n%@", NSStringFromSelector(targetSelector), selfObject, [NSThread callStackSymbols]);
            });
        }
        
        return result;
    };
    
    if (hasOverride) {
        method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)));
    } else {
        const char *typeEncoding = method_getTypeEncoding(originMethod) ?: [targetClass instanceMethodSignatureForSelector:targetSelector].kai_typeEncoding;
        class_addMethod(targetClass, targetSelector, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)), typeEncoding);
    }
    
    return YES;
}

CG_INLINE BOOL ExtendImplementationOfVoidMethodWithoutArguments(Class targetClass, SEL targetSelector, void (^implementationBlock)(__kindof NSObject *selfObject)) {
    return OverrideImplementation(targetClass, targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
        void (^block)(__unsafe_unretained __kindof NSObject *selfObject) = ^(__unsafe_unretained __kindof NSObject *selfObject) {

            void (*originSelectorIMP)(id, SEL);
            originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
            originSelectorIMP(selfObject, originCMD);

            implementationBlock(selfObject);
        };
#if __has_feature(objc_arc)
        return block;
#else
        return [block copy];
#endif
    });
}

NS_ASSUME_NONNULL_END
