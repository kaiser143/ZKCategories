//
//  NSArray+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (ZKAdd)

/**
 * @return NSArray with only the elements that pass the truth test
 */
- (NSArray *)filter:(BOOL(^)(id object))condition;

/**
 * @return NSArray with only the elements that pass the truth test
 */
- (NSArray *)ignore:(id)value;

/**
 * performs the operation to each element
 */
- (void)each:(void(^)(id object))operation;

/**
 * @return new NSArray from the result of the block performed to each element
 */
- (NSArray *)map:(id(^)(id obj, NSUInteger idx))block;

/**
 * @return new NSArray by flatting it and performing a map to each element
 */
- (NSArray *)flattenMap:(id(^)(id obj, NSUInteger idx))block;

/**
 * @return new NSArray by flatting it with the key and performing a map to each element
 */
- (NSArray *)flattenMap:(NSString *)key block:(id(^)(id obj, NSUInteger idx))block;


- (NSNumber *)sum;
- (NSNumber *)sum:(NSString *)keypath;
- (NSNumber *)avg;
- (NSNumber *)avg:(NSString *)keypath;
- (NSNumber *)max;
- (NSNumber *)max:(NSString *)keypath;
- (NSNumber *)min;
- (NSNumber *)min:(NSString *)keypath;
- (NSUInteger)countKeyPath:(NSString *)keypath;

- (id)objectPassingTest:(BOOL(^)(id))block;

/*!
 *  @brief  排序
 *  @param  ascending     是否升序
 *  @param  key 排序字段
 */
- (NSArray *)sortedArray:(BOOL)ascending
                   byKey:(NSString *)key, ... NS_REQUIRES_NIL_TERMINATION;

- (NSArray *)sortedArray:(NSDictionary *)sortedKeyValue;

#pragma mark - :. SafeAccess

- (id)objectAtIndex:(NSUInteger)index;

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

@end

NS_ASSUME_NONNULL_END

