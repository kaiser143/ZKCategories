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

@end

NS_ASSUME_NONNULL_END

