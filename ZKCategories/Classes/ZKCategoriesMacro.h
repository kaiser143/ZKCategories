//
//  ZKCategoriesMacro.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/26.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sys/time.h>
#import <objc/runtime.h>
#import <pthread.h>
#import "ZKHelper.h"

#ifndef ZKCategoriesMacro_h
#define ZKCategoriesMacro_h

#ifdef __cplusplus
#define ZK_EXTERN_C_BEGIN  extern "C" {
#define ZK_EXTERN_C_END  }
#else
#define ZK_EXTERN_C_BEGIN
#define ZK_EXTERN_C_END
#endif


#if !defined(ZKAuto)
#if defined(__cplusplus)
#define ZKAuto auto
#else
#define ZKAuto __auto_type
#endif
#endif


#ifdef DEBUG
    #define ZKLog(format, ...)      NSLog(@"%s(%d): " format, ((strrchr(__FILE__, '/') ? : __FILE__- 1) + 1), __LINE__, ##__VA_ARGS__)
    #define ZKLogForRect(aRect)     ZKLog(@"[%s] x: %f, y: %f, width: %f, height: %f", #aRect, aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height)
    #define ZKLogForRange(aRange)   ZKLog(@"[%s] location: %lu; length: %lu", #aRange, aRange.location, aRange.length)
#else
    #define ZKLog(xx, ...)          ((void)0)
    #define ZKLogForRect(aRect)     ((void)0)
    #define ZKLogForRange(aRange)   ((void)0)
#endif


// 方法废弃
// Example
#define ZK_API_DEPRECATED(instead) DEPRECATED_MSG_ATTRIBUTE(" Use " # instead " instead")

ZK_EXTERN_C_BEGIN

#ifndef ZK_CLAMP // return the clamped value
#define ZK_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

#ifndef ZK_SWAP // swap two value
#define ZK_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif


#define ZKAssertNil(condition, description, ...) NSAssert(!(condition), (description), ##__VA_ARGS__)
#define ZKCAssertNil(condition, description, ...) NSCAssert(!(condition), (description), ##__VA_ARGS__)

#define ZKAssertNotNil(condition, description, ...) NSAssert((condition), (description), ##__VA_ARGS__)
#define ZKCAssertNotNil(condition, description, ...) NSCAssert((condition), (description), ##__VA_ARGS__)

#define ZKAssertMainThread() NSAssert([NSThread isMainThread], @"This method must be called on the main thread")
#define ZKCAssertMainThread() NSCAssert([NSThread isMainThread], @"This method must be called on the main thread")


/**
 在每个 category 实现前使用此宏，可避免对仅包含 category、无类的静态库使用
 -all_load 或 -force_load 来加载目标文件。
 更多说明：http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html
 *******************************************************************************
 示例：
    ZKSYNTH_DUMMY_CLASS(NSString_ZKAdd)
 */
#ifndef ZKSYNTH_DUMMY_CLASS
#define ZKSYNTH_DUMMY_CLASS(_name_) \
@interface ZKSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation ZKSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif


/**
 在 @implementation 作用域内合成动态对象属性。
 用于在 category 中为已有类添加自定义属性。
 
 @param association  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
 @warning 需 #import <objc/runtime.h>
 *******************************************************************************
 示例：
    @interface NSObject (MyAdd)
    @property (nonatomic, retain) UIColor *myColor;
    @end
 
    #import <objc/runtime.h>
    @implementation NSObject (MyAdd)
    ZKSYNTH_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor, RETAIN, UIColor *)
    @end
 */
#ifndef ZKSYNTH_DYNAMIC_PROPERTY_OBJECT
#define ZKSYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
    [self willChangeValueForKey:@#_getter_]; \
    objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
    [self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
    return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif


/**
 在 @implementation 作用域内合成动态 C 类型属性。
 用于在 category 中为已有类添加自定义属性。
 
 @warning 需 #import <objc/runtime.h>
 *******************************************************************************
 示例：
    @interface NSObject (MyAdd)
    @property (nonatomic, retain) CGPoint myPoint;
    @end
 
    #import <objc/runtime.h>
    @implementation NSObject (MyAdd)
    ZKSYNTH_DYNAMIC_PROPERTY_CTYPE(myPoint, setMyPoint, CGPoint)
    @end
 */
#ifndef ZKSYNTH_DYNAMIC_PROPERTY_CTYPE
#define ZKSYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
- (void)_setter_ : (_type_)object { \
    [self willChangeValueForKey:@#_getter_]; \
    NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
    objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
    [self didChangeValueForKey:@#_getter_]; \
} \
- (type)_getter_ { \
    _type_ cValue = { 0 }; \
    NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
    [value getValue:&cValue]; \
    return cValue; \
}
#endif


#ifndef rac_weakify_
#define rac_weakify_(INDEX, CONTEXT, VAR) \
    CONTEXT __typeof__(VAR) metamacro_concat(VAR, _weak_) = (VAR);
#endif

#ifndef rac_strongify_
#define rac_strongify_(INDEX, VAR) \
    __strong __typeof__(VAR) VAR = metamacro_concat(VAR, _weak_);
#endif

#ifndef ext_weakify_
#define ext_weakify_(INDEX, CONTEXT, VAR) \
    CONTEXT __typeof__(VAR) metamacro_concat(VAR, _weak_) = (VAR);
#endif

#ifndef ext_strongify_
#define ext_strongify_(INDEX, VAR) \
    __strong __typeof__(VAR) VAR = metamacro_concat(VAR, _weak_);
#endif

#ifndef metamacro_concat_
#define metamacro_concat_(A, B) A ## B
#endif


#ifndef metamacro_concat
/**
 * 在宏完全展开后将 A 与 B 拼接。
 */
#define metamacro_concat(A, B) \
    metamacro_concat_(A, B)
#endif

#ifndef metamacro_head_
#define metamacro_head_(FIRST, ...) FIRST
#endif

#ifndef metamacro_tail_
#define metamacro_tail_(FIRST, ...) __VA_ARGS__
#endif

#ifndef metamacro_foreach_iter
#define metamacro_foreach_iter(INDEX, MACRO, ARG) MACRO(INDEX, ARG)
#endif

#ifndef metamacro_expand_
#define metamacro_expand_(...) __VA_ARGS__
#endif


#ifndef metamacro_head
/**
 * 返回传入的第一个参数。至少需要传入一个参数。
 *
 * 在实现可变参数宏时有用，例如只有一个可变参数且无法直接取到
 *（因 \c ... 至少匹配一个参数）。
 *
 * @code
 #define varmacro(...) \
 metamacro_head(__VA_ARGS__)
 * @endcode
 */
#define metamacro_head(...) \
    metamacro_head_(__VA_ARGS__, 0)

#define metamacro_at0(...) metamacro_head(__VA_ARGS__)
#define metamacro_at1(_0, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at2(_0, _1, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at3(_0, _1, _2, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at4(_0, _1, _2, _3, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at5(_0, _1, _2, _3, _4, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at6(_0, _1, _2, _3, _4, _5, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at7(_0, _1, _2, _3, _4, _5, _6, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at8(_0, _1, _2, _3, _4, _5, _6, _7, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at9(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, ...) metamacro_head(__VA_ARGS__)
#define metamacro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) metamacro_head(__VA_ARGS__)

#define metamacro_foreach_cxt0(MACRO, SEP, CONTEXT)
#define metamacro_foreach_cxt1(MACRO, SEP, CONTEXT, _0) MACRO(0, CONTEXT, _0)

#define metamacro_foreach_cxt2(MACRO, SEP, CONTEXT, _0, _1) \
    metamacro_foreach_cxt1(MACRO, SEP, CONTEXT, _0) \
    SEP \
    MACRO(1, CONTEXT, _1)

#define metamacro_foreach_cxt3(MACRO, SEP, CONTEXT, _0, _1, _2) \
    metamacro_foreach_cxt2(MACRO, SEP, CONTEXT, _0, _1) \
    SEP \
    MACRO(2, CONTEXT, _2)

#define metamacro_foreach_cxt4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
    metamacro_foreach_cxt3(MACRO, SEP, CONTEXT, _0, _1, _2) \
    SEP \
    MACRO(3, CONTEXT, _3)

#define metamacro_foreach_cxt5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
    metamacro_foreach_cxt4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
    SEP \
    MACRO(4, CONTEXT, _4)

#define metamacro_foreach_cxt6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
    metamacro_foreach_cxt5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
    SEP \
    MACRO(5, CONTEXT, _5)

#define metamacro_foreach_cxt7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
    metamacro_foreach_cxt6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
    SEP \
    MACRO(6, CONTEXT, _6)

#define metamacro_foreach_cxt8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
    metamacro_foreach_cxt7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
    SEP \
    MACRO(7, CONTEXT, _7)

#define metamacro_foreach_cxt9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
    metamacro_foreach_cxt8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
    SEP \
    MACRO(8, CONTEXT, _8)

#define metamacro_foreach_cxt10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
    metamacro_foreach_cxt9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
    SEP \
    MACRO(9, CONTEXT, _9)

#define metamacro_foreach_cxt11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
    metamacro_foreach_cxt10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
    SEP \
    MACRO(10, CONTEXT, _10)

#define metamacro_foreach_cxt12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
    metamacro_foreach_cxt11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
    SEP \
    MACRO(11, CONTEXT, _11)

#define metamacro_foreach_cxt13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
    metamacro_foreach_cxt12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
    SEP \
    MACRO(12, CONTEXT, _12)

#define metamacro_foreach_cxt14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
    metamacro_foreach_cxt13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
    SEP \
    MACRO(13, CONTEXT, _13)

#define metamacro_foreach_cxt15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
    metamacro_foreach_cxt14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
    SEP \
    MACRO(14, CONTEXT, _14)

#define metamacro_foreach_cxt16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
    metamacro_foreach_cxt15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
    SEP \
    MACRO(15, CONTEXT, _15)

#define metamacro_foreach_cxt17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
    metamacro_foreach_cxt16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
    SEP \
    MACRO(16, CONTEXT, _16)

#define metamacro_foreach_cxt18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
    metamacro_foreach_cxt17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
    SEP \
    MACRO(17, CONTEXT, _17)

#define metamacro_foreach_cxt19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
    metamacro_foreach_cxt18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
    SEP \
    MACRO(18, CONTEXT, _18)

#define metamacro_foreach_cxt20(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19) \
    metamacro_foreach_cxt19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
    SEP \
    MACRO(19, CONTEXT, _19)
#endif


#ifndef metamacro_at
/**
 * 返回第 N 个可变参数（从 0 起）。至少需传入 N+1 个参数，N 为 0～20。
 */
#define metamacro_at(N, ...) \
    metamacro_concat(metamacro_at, N)(__VA_ARGS__)
#endif

#ifndef metamacro_dec
/**
 * 将 VAL 减一，VAL 须为 0～20 的整数。
 *
 * 主要用于元编程中的索引与计数。
 */
#define metamacro_dec(VAL) \
    metamacro_at(VAL, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19)
#endif

#ifndef metamacro_if_eq
/**
 * 若 A 等于 B 则展开下一组参数，否则展开再下一组。A、B 须为 0～20 的整数，且 B >= A。
 *
 * @code
 // 展开为 true
 metamacro_if_eq(0, 0)(true)(false)
 // 展开为 false
 metamacro_if_eq(0, 1)(true)(false)
 * @endcode
 *
 * 主要用于元编程中的索引与计数。
 */
#define metamacro_if_eq(A, B) \
    metamacro_concat(metamacro_if_eq, A)(B)

// metamacro_if_eq expansions
#define metamacro_if_eq0(VALUE) \
    metamacro_concat(metamacro_if_eq0_, VALUE)

#define metamacro_if_eq0_0(...) __VA_ARGS__ metamacro_consume_
#define metamacro_if_eq0_1(...) metamacro_expand_
#define metamacro_if_eq0_2(...) metamacro_expand_
#define metamacro_if_eq0_3(...) metamacro_expand_
#define metamacro_if_eq0_4(...) metamacro_expand_
#define metamacro_if_eq0_5(...) metamacro_expand_
#define metamacro_if_eq0_6(...) metamacro_expand_
#define metamacro_if_eq0_7(...) metamacro_expand_
#define metamacro_if_eq0_8(...) metamacro_expand_
#define metamacro_if_eq0_9(...) metamacro_expand_
#define metamacro_if_eq0_10(...) metamacro_expand_
#define metamacro_if_eq0_11(...) metamacro_expand_
#define metamacro_if_eq0_12(...) metamacro_expand_
#define metamacro_if_eq0_13(...) metamacro_expand_
#define metamacro_if_eq0_14(...) metamacro_expand_
#define metamacro_if_eq0_15(...) metamacro_expand_
#define metamacro_if_eq0_16(...) metamacro_expand_
#define metamacro_if_eq0_17(...) metamacro_expand_
#define metamacro_if_eq0_18(...) metamacro_expand_
#define metamacro_if_eq0_19(...) metamacro_expand_
#define metamacro_if_eq0_20(...) metamacro_expand_

#define metamacro_if_eq1(VALUE) metamacro_if_eq0(metamacro_dec(VALUE))
#define metamacro_if_eq2(VALUE) metamacro_if_eq1(metamacro_dec(VALUE))
#define metamacro_if_eq3(VALUE) metamacro_if_eq2(metamacro_dec(VALUE))
#define metamacro_if_eq4(VALUE) metamacro_if_eq3(metamacro_dec(VALUE))
#define metamacro_if_eq5(VALUE) metamacro_if_eq4(metamacro_dec(VALUE))
#define metamacro_if_eq6(VALUE) metamacro_if_eq5(metamacro_dec(VALUE))
#define metamacro_if_eq7(VALUE) metamacro_if_eq6(metamacro_dec(VALUE))
#define metamacro_if_eq8(VALUE) metamacro_if_eq7(metamacro_dec(VALUE))
#define metamacro_if_eq9(VALUE) metamacro_if_eq8(metamacro_dec(VALUE))
#define metamacro_if_eq10(VALUE) metamacro_if_eq9(metamacro_dec(VALUE))
#define metamacro_if_eq11(VALUE) metamacro_if_eq10(metamacro_dec(VALUE))
#define metamacro_if_eq12(VALUE) metamacro_if_eq11(metamacro_dec(VALUE))
#define metamacro_if_eq13(VALUE) metamacro_if_eq12(metamacro_dec(VALUE))
#define metamacro_if_eq14(VALUE) metamacro_if_eq13(metamacro_dec(VALUE))
#define metamacro_if_eq15(VALUE) metamacro_if_eq14(metamacro_dec(VALUE))
#define metamacro_if_eq16(VALUE) metamacro_if_eq15(metamacro_dec(VALUE))
#define metamacro_if_eq17(VALUE) metamacro_if_eq16(metamacro_dec(VALUE))
#define metamacro_if_eq18(VALUE) metamacro_if_eq17(metamacro_dec(VALUE))
#define metamacro_if_eq19(VALUE) metamacro_if_eq18(metamacro_dec(VALUE))
#define metamacro_if_eq20(VALUE) metamacro_if_eq19(metamacro_dec(VALUE))

#endif


#ifndef metamacro_argcount
/**
 * 返回传入宏的参数个数（最多二十个）。至少需传入一个参数。
 *
 * 参考 P99: http://p99.gforge.inria.fr
 */
#define metamacro_argcount(...) \
    metamacro_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)
#endif


#ifndef metamacro_foreach_cxt
/**
 * 对每个连续的可变参数（最多二十个）调用 MACRO，传入当前参数从 0 起的索引、
 * CONTEXT 和参数本身。相邻 MACRO 调用的结果用 SEP 分隔。
 *
 * 参考 P99: http://p99.gforge.inria.fr
 */
#define metamacro_foreach_cxt(MACRO, SEP, CONTEXT, ...) \
    metamacro_concat(metamacro_foreach_cxt, metamacro_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)
#endif


#ifndef metamacro_foreach
/**
 * 与 #metamacro_foreach_cxt 相同，但不传入 CONTEXT，仅向 MACRO 传入索引与当前参数。
 */
#define metamacro_foreach(MACRO, SEP, ...) \
    metamacro_foreach_cxt(metamacro_foreach_iter, SEP, MACRO, __VA_ARGS__)
#endif

#ifndef metamacro_tail
/**
 * 返回除第一个以外的所有参数。至少需传入两个参数。
 */
#define metamacro_tail(...) \
    metamacro_tail_(__VA_ARGS__)
#endif

#ifndef keypath
/**
 * \@keypath 在编译期校验 key path。传入实际对象与 key path：
 *
 * @code
 NSString *UTF8StringPath = @keypath(str.lowercaseString.UTF8String);
 // => @"lowercaseString.UTF8String"
 NSString *versionPath = @keypath(NSObject, version);
 // => @"version"
 NSString *lowercaseStringPath = @keypath(NSString.new, lowercaseString);
 // => @"lowercaseString"
 * @endcode
 *
 * 宏返回去掉第一段的 \c NSString（如 @"lowercaseString.UTF8String", @"version"）。
 *
 * 除生成 key path 外，还可保证编译期合法（非法时产生语法错误），并支持重构：
 * 属性名修改后，\@keypath 的用法会一并更新。
 */
#define keypath(...) \
    metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(keypath1(__VA_ARGS__))(keypath2(__VA_ARGS__))

#define keypath1(PATH) \
    (((void)(NO && ((void)PATH, NO)), strchr(# PATH, '.') + 1))

#define keypath2(OBJ, PATH) \
    (((void)(NO && ((void)OBJ.PATH, NO)), # PATH))
#endif

#ifndef weakify
/**
 * 为传入的每个变量创建 \c __weak 影子变量，之后可用 #strongify 再次强引用。
 *
 * 常用于在 block 内弱引用变量，并在 block 实际执行时（若进入时仍存活）用 strongify 保证存活。
 *
 * 用法示例见 #strongify。
 */
#define weakify(...) \
    autoreleasepool {} \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wunused\"") \
    metamacro_foreach_cxt(rac_weakify_,, __weak, __VA_ARGS__) \
    _Pragma("clang diagnostic pop")
#endif

#ifndef strongify
/**
 * 对传入的变量做强引用，这些变量须事先通过 #weakify 传入。
 *
 * 生成的强引用会遮蔽原变量名，从而在当前作用域内可安全使用原名称，并显著降低循环引用风险。
 *
 * @code
    id foo = [[NSObject alloc] init];
    id bar = [[NSObject alloc] init];
    @weakify(foo, bar);
    // 该 block 不会持有 'foo' 或 'bar'
    BOOL (^matchesFooOrBar)(id) = ^ BOOL (id obj){
     // 进入 block 后 'foo'、'bar' 会保持存活直至 block 执行完毕
     @strongify(foo, bar);
     return [foo isEqual:obj] || [bar isEqual:obj];
     };
 * @endcode
 */
#define strongify(...) \
    try {} @finally {} \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    _Pragma("clang diagnostic ignored \"-Wunused\"") \
    metamacro_foreach(rac_strongify_,, __VA_ARGS__) \
    _Pragma("clang diagnostic pop")
#endif

#define FOREACH_ARGS(MACRO, ...)  \
    metamacro_if_eq(1,metamacro_argcount(__VA_ARGS__))                                                      \
    ()                                                                                                      \
    (metamacro_foreach(MACRO , , metamacro_tail(__VA_ARGS__)))                                              \


#define CREATE_ARGS_DELETE_PAREN(VALUE) ,VALUE

#define CREATE_ARGS(INDEX,VALUE) CREATE_ARGS_DELETE_PAREN VALUE

#define __CREATE_ARGS_DELETE_PAREN(...) \
    [type appendFormat:@"%s",@encode(metamacro_head(__VA_ARGS__))];

#define CRATE_TYPE_CODING_DEL_VAR(TYPE) TYPE ,

#define CRATE_TYPE_CODING(INDEX,VALUE) \
    __CREATE_ARGS_DELETE_PAREN(CRATE_TYPE_CODING_DEL_VAR VALUE)


#pragma mark - Clang

#define ArgumentToString(macro) #macro
#define ClangWarningConcat(warning_name) ArgumentToString(clang diagnostic ignored warning_name)

/// 参数可直接传入 clang 的 warning 名，warning 列表参考：https://clang.llvm.org/docs/DiagnosticsReference.html
#define BeginIgnoreClangWarning(warningName) _Pragma("clang diagnostic push") _Pragma(ClangWarningConcat(#warningName))
#define EndIgnoreClangWarning _Pragma("clang diagnostic pop")

#define BeginIgnorePerformSelectorLeaksWarning BeginIgnoreClangWarning(-Warc-performSelector-leaks)
#define EndIgnorePerformSelectorLeaksWarning EndIgnoreClangWarning


#define CGContextInspectContext(context, returnValue) if(![ZKHelper inspectContextIfInvalidated:context]){return returnValue;}

/**
 将 CFRange 转为 NSRange
 @param range CFRange
 @return NSRange
 */
static inline NSRange ZKNSRangeFromCFRange(CFRange range) {
    return NSMakeRange(range.location, range.length);
}

/**
 将 NSRange 转为 CFRange
 @param range NSRange
 @return CFRange
 */
static inline CFRange ZKCFRangeFromNSRange(NSRange range) {
    return CFRangeMake(range.location, range.length);
}

/**
 与 CFAutorelease() 等效，兼容 iOS6
 @param arg CF 对象
 @return 与传入值相同
 */
static inline CFTypeRef ZKCFAutorelease(CFTypeRef CF_RELEASES_ARGUMENT arg) {
    if (((long)CFAutorelease + 1) != 1) {
        return CFAutorelease(arg);
    } else {
        id __autoreleasing obj = CFBridgingRelease(arg);
        return (__bridge CFTypeRef)obj;
    }
}

/**
 测量代码耗时。
 @param block    待测代码
 @param complete 耗时回调（毫秒）
 
 用法：
 ZKBenchmark(^{
   // 待测代码
 }, ^(double ms) {
   NSLog("time cost: %.2f ms", ms);
 });
 */
static inline void ZKBenchmark(void (^block)(void), void (^complete)(double ms)) {
    // <QuartzCore/QuartzCore.h> version
    /*
     extern double CACurrentMediaTime (void);
     double begin, end, ms;
     begin = CACurrentMediaTime();
     block();
     end = CACurrentMediaTime();
     ms = (end - begin) * 1000.0;
     complete(ms);
     */
    
    // <sys/time.h> version
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}

static inline NSDate *_ZKCompileTime(const char *data, const char *time) {
    NSString *timeStr = [NSString stringWithFormat:@"%s %s",data,time];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd yyyy HH:mm:ss"];
    [formatter setLocale:locale];
    return [formatter dateFromString:timeStr];
}

/**
 获取编译时间戳。
 @return 表示编译日期与时间的新 NSDate 对象。
 */
#ifndef ZKCompileTime
// 使用宏避免在 pch 中引用时的编译警告
#define ZKCompileTime() _ZKCompileTime(__DATE__, __TIME__)
#endif

/**
 返回从当前时间起延迟指定秒数的 dispatch_time。
 */
static inline dispatch_time_t dispatch_time_delay(NSTimeInterval second) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/**
 返回从当前时间起延迟指定秒数的 dispatch_wall_time。
 */
static inline dispatch_time_t dispatch_walltime_delay(NSTimeInterval second) {
    return dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/**
 根据 NSDate 返回 dispatch_wall_time。
 */
static inline dispatch_time_t dispatch_walltime_date(NSDate *date) {
    NSTimeInterval interval;
    double second, subsecond;
    struct timespec time;
    dispatch_time_t milestone;
    
    interval = [date timeIntervalSince1970];
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&time, 0);
    return milestone;
}

/**
 是否在主队列/主线程。
 */
static inline bool dispatch_is_main_queue() {
    return pthread_main_np() != 0;
}

/**
 将 block 提交到主队列异步执行并立即返回。
 */
static inline void dispatch_async_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/**
 将 block 提交到主队列执行并等待其完成。
 */
static inline void dispatch_sync_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

/**
 初始化 pthread 互斥锁。
 */
static inline void pthread_mutex_init_recursive(pthread_mutex_t *mutex, bool recursive) {
#define ZKMUTEX_ASSERT_ON_ERROR(x_) do { \
__unused volatile int res = (x_); \
assert(res == 0); \
} while (0)
    assert(mutex != NULL);
    if (!recursive) {
        ZKMUTEX_ASSERT_ON_ERROR(pthread_mutex_init(mutex, NULL));
    } else {
        pthread_mutexattr_t attr;
        ZKMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_init (&attr));
        ZKMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE));
        ZKMUTEX_ASSERT_ON_ERROR(pthread_mutex_init (mutex, &attr));
        ZKMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_destroy (&attr));
    }
#undef ZKMUTEX_ASSERT_ON_ERROR
}


ZK_EXTERN_C_END

/*!
 *    @brief    系统隐藏方法, 返回字段为测试代码所耗费的时间  单位 纳秒
 *    @param    count 循环次数， block 中写入待测试的代码
 */
extern uint64_t dispatch_benchmark(size_t count, void(^block)(void));

/**
 用于判断一个给定的 type encoding（const char *）或者 Ivar 是哪种类型的系列函数。
 
 为了节省代码量，函数由宏展开生成，一个宏会展开为两个函数定义：
 
 1. isXxxTypeEncoding(const char *)，例如判断是否为 BOOL 类型的函数名为：isBOOLTypeEncoding()
 2. isXxxIvar(Ivar)，例如判断是否为 BOOL 的 Ivar 的函数名为：isBOOLIvar()
 
 @see https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
 */
#define _KAITypeEncodingDetectorGenerator(_TypeInFunctionName, _typeForEncode) \
    CG_INLINE BOOL is##_TypeInFunctionName##TypeEncoding(const char *typeEncoding) {\
        return strncmp(@encode(_typeForEncode), typeEncoding, strlen(@encode(_typeForEncode))) == 0;\
    }\
    CG_INLINE BOOL is##_TypeInFunctionName##Ivar(Ivar ivar) {\
        return is##_TypeInFunctionName##TypeEncoding(ivar_getTypeEncoding(ivar));\
    }

_KAITypeEncodingDetectorGenerator(Char, char)
_KAITypeEncodingDetectorGenerator(Int, int)
_KAITypeEncodingDetectorGenerator(Short, short)
_KAITypeEncodingDetectorGenerator(Long, long)
_KAITypeEncodingDetectorGenerator(LongLong, long long)
_KAITypeEncodingDetectorGenerator(NSInteger, NSInteger)
_KAITypeEncodingDetectorGenerator(UnsignedChar, unsigned char)
_KAITypeEncodingDetectorGenerator(UnsignedInt, unsigned int)
_KAITypeEncodingDetectorGenerator(UnsignedShort, unsigned short)
_KAITypeEncodingDetectorGenerator(UnsignedLong, unsigned long)
_KAITypeEncodingDetectorGenerator(UnsignedLongLong, unsigned long long)
_KAITypeEncodingDetectorGenerator(NSUInteger, NSUInteger)
_KAITypeEncodingDetectorGenerator(Float, float)
_KAITypeEncodingDetectorGenerator(Double, double)
_KAITypeEncodingDetectorGenerator(CGFloat, CGFloat)
_KAITypeEncodingDetectorGenerator(BOOL, BOOL)
_KAITypeEncodingDetectorGenerator(Void, void)
_KAITypeEncodingDetectorGenerator(Character, char *)
_KAITypeEncodingDetectorGenerator(Object, id)
_KAITypeEncodingDetectorGenerator(Class, Class)
_KAITypeEncodingDetectorGenerator(Selector, SEL)

#endif /* ZKCategoriesMacro_h */
