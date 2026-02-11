//
//  NSArray+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ValueType> (ZKAdd)

/**
 * @return 仅包含通过条件测试的元素的 NSArray
 */
- (NSArray *)filter:(BOOL (^)(ValueType object))condition;

/**
 * @return 仅包含通过条件测试的元素的 NSArray
 */
- (NSArray *)ignore:(id)value;

/**
 * 对每个元素执行操作
 */
- (void)each:(void (^ _Nonnull)(ValueType object))operation;

/**
 * @return 对每个元素执行 block 后得到的新 NSArray
 */
- (NSArray *)map:(id (^ _Nonnull)(ValueType obj, NSUInteger idx))block;

/**
 * @return 先扁平化再对每个元素执行 map 得到的新 NSArray（把二维数组中的对象经过 block 转换为另一个对象）
 */
- (NSArray *)flattenMap:(id (^ _Nonnull)(ValueType obj, NSUInteger idx))block;

/**
 * @return 按 key 扁平化并对每个元素执行 map 得到的新 NSArray
 */
- (NSArray *)flattenMap:(NSString *_Nonnull)key block:(id (^ _Nonnull)(ValueType obj, NSUInteger idx))block;

// 参与运算的属性必须是NSNumber对象
- (NSNumber *)sum;
- (NSNumber *)sum:(NSString *)keypath;
- (NSNumber *)avg;
- (NSNumber *)avg:(NSString *)keypath;
- (NSNumber *)max;
- (NSNumber *)max:(NSString *)keypath;
- (NSNumber *)min;
- (NSNumber *)min:(NSString *)keypath;
- (NSUInteger)countKeyPath:(NSString *)keypath;
- (NSArray *)flatten:(NSString *)keypath;

- (ValueType)objectPassingTest:(BOOL (^ _Nonnull)(ValueType))block;

/*!
 *  @brief  排序
 *  @param  ascending     是否升序
 *  @param  key 排序字段
 */
- (NSArray *)sortedArray:(BOOL)ascending
                   byKey:(NSString *)key, ... NS_REQUIRES_NIL_TERMINATION;

- (NSArray *)sortedArray:(NSDictionary *)sortedKeyValue;

#pragma mark - :. SafeAccess

- (id)objectOrNilAtIndex:(NSUInteger)index;

- (NSString *)stringAtIndex:(NSUInteger)index;

- (NSNumber *)numberAtIndex:(NSUInteger)index;

- (NSDecimalNumber *)decimalNumberAtIndex:(NSUInteger)index;

- (NSArray *)arrayAtIndex:(NSUInteger)index;

- (NSDictionary *)dictionaryAtIndex:(NSUInteger)index;

- (NSInteger)integerAtIndex:(NSUInteger)index;

- (NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index;

- (BOOL)boolAtIndex:(NSUInteger)index;

- (int16_t)int16AtIndex:(NSUInteger)index;

- (int32_t)int32AtIndex:(NSUInteger)index;

- (int64_t)int64AtIndex:(NSUInteger)index;

- (char)charAtIndex:(NSUInteger)index;

- (short)shortAtIndex:(NSUInteger)index;

- (float)floatAtIndex:(NSUInteger)index;

- (double)doubleAtIndex:(NSUInteger)index;

- (NSDate *)dateAtIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat;
//CG
- (CGFloat)CGFloatAtIndex:(NSUInteger)index;

- (CGPoint)pointAtIndex:(NSUInteger)index;

- (CGSize)sizeAtIndex:(NSUInteger)index;

- (CGRect)rectAtIndex:(NSUInteger)index;


/*
 * 判断数组是否为空
 */
@property(nonatomic, readonly, getter=isEmpty) BOOL empty;

/*!
 *  @brief    交集,返回的数组是array中的对象
 */
- (NSArray<ValueType> *)intersectSet:(NSArray *)array;

/*!
 *  @brief    并集
 */
- (NSArray<ValueType> *)unionSet:(NSArray *)array;

/*!
 *  @brief    差集
 */
- (NSArray<ValueType> *)subtractingSet:(NSArray *)array;

@end

@interface NSMutableArray<ValueType> (SafeAccess)

/**
 移除数组中索引最小的对象。若数组为空则无效果。
 
 @discussion Apple 已实现此方法但未公开，此处重写以保证安全。
 */
- (void)removeFirstObject;

/**
 移除数组中索引最大的对象。若数组为空则无效果。
 
 @discussion Apple 文档称数组为空会抛出 NSRangeException，实际不会。此处重写以保证安全。
 */
- (void)removeLastObject;

/**
 移除并返回数组中索引最小的对象。若数组为空则返回 nil。
 
 @return 第一个对象，或 nil。
 */
- (nullable ValueType)popFirstObject;

/**
 移除并返回数组中索引最大的对象。若数组为空则返回 nil。
 
 @return 最后一个对象，或 nil。
 */
- (nullable ValueType)popLastObject;

/**
 在数组末尾插入给定对象。
 
 @param anObject 要插入到末尾的对象，不能为 nil，否则抛出 NSInvalidArgumentException。
 */
- (void)appendObject:(ValueType)anObject;

/**
 在数组开头插入给定对象。
 
 @param anObject 要插入到开头的对象，不能为 nil，否则抛出 NSInvalidArgumentException。
 */
- (void)prependObject:(ValueType)anObject;

/**
 将给定数组中的对象依次追加到接收数组末尾。
 
 @param objects 要追加的对象数组。若为 nil 或空则无效果。
 */
- (void)appendObjects:(NSArray<ValueType> *)objects;

/**
 将给定数组中的对象依次插入到接收数组开头。
 
 @param objects 要插入的对象数组。若为 nil 或空则无效果。
 */
- (void)prependObjects:(NSArray<ValueType> *)objects;

/**
 在指定索引处将给定数组中的对象插入到接收数组中。
 
 @param objects 要插入的对象数组。若为 nil 或空则无效果。
 
 @param index 插入位置索引，不能大于数组元素个数，否则抛出 NSRangeException。
 */
- (void)insertObjects:(NSArray<ValueType> *)objects atIndex:(NSUInteger)index;

/**
 反转数组中元素的顺序。例如：@[ @1, @2, @3 ] -> @[ @3, @2, @1 ]。
 */
- (void)reverse;

/**
 随机打乱数组中元素的顺序。
 */
- (void)shuffle;

- (void)addObj:(ValueType)i;
- (void)addString:(NSString *)i;
- (void)addBool:(BOOL)i;
- (void)addInt:(int)i;
- (void)addInteger:(NSInteger)i;
- (void)addUnsignedInteger:(NSUInteger)i;
- (void)addCGFloat:(CGFloat)f;
- (void)addChar:(char)c;
- (void)addFloat:(float)i;
- (void)addPoint:(CGPoint)o;
- (void)addSize:(CGSize)o;
- (void)addRect:(CGRect)o;
- (void)addRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END

