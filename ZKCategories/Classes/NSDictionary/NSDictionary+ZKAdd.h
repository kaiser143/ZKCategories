//
//  NSDictionary+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/1/11.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<__covariant KeyType, __covariant ValueType> (ZKAdd)

#pragma mark :. URL Parameter Strings

- (NSString *)URLEncodedStringValue;

/// 将给定字典的键值合并到接收者。若同一 key 在两边都存在，以 dictionary 中的值为准。
/// 返回新字典，包含接收者与 dictionary 的合并结果。
- (NSDictionary<KeyType, ValueType> *)dictionaryByAddingEntriesFromDictionary:(NSDictionary<KeyType, ValueType> *)dictionary;

/// 从接收者中移除指定 keys 对应的条目，返回新字典。
- (NSDictionary<KeyType, ValueType> *)dictionaryByRemovingValuesForKeys:(NSArray<KeyType> *)keys;

/**
 返回字典所有 key 排序后的新数组。key 应为 NSString，按升序排列。
 
 @return 排序后的 key 数组，字典为空时返回空数组。
 */
- (NSArray<KeyType> *)allKeysSorted;

/**
 按 key 排序后返回字典所有 value 的新数组。顺序由 key 决定，key 应为 NSString，按升序。
 
 @return 按 key 排序的 value 数组，字典为空时返回空数组。
 */
- (NSArray<ValueType> *)allValuesSortedByKeys;

/**
 返回仅包含指定 keys 对应条目的新字典。keys 为空或 nil 时返回空字典。
 
 @param keys 键数组。
 @return 这些 key 对应的条目字典。
 */
- (NSDictionary<KeyType, ValueType> *)entriesForKeys:(NSArray<KeyType> *)keys;

/**
 将字典转为 JSON 字符串。失败返回 nil。
 */
- (nullable NSString *)jsonStringEncoded;

/**
 将字典转为格式化后的 JSON 字符串。失败返回 nil。
 */
- (nullable NSString *)jsonPrettyStringEncoded;

/**
 尝试解析 XML 并包装为字典。适合从小段 XML 中取值。
 
 示例 XML: "<config><a href="test.com">link</a></config>"
 示例返回: @{@"_name":@"config", @"a":{@"_text":@"link",@"href":@"test.com"}}
 
 @param xmlDataOrString NSData 或 NSString 形式的 XML。
 @return 新字典，解析失败返回 nil。
 */
+ (nullable NSDictionary<KeyType, ValueType> *)dictionaryWithXML:(id)xmlDataOrString;

#pragma mark - :. SafeAccess

/**
 返回字典是否包含指定 key 对应的对象。
 
 @param key 键。
 */
- (BOOL)hasKey:(KeyType)key;

/**
 返回指定 key 对应的 NSString。若不是 NSString 且无法转换则返回 nil。
 
 @param key 键。
 @returns 对应的字符串。
 */
- (NSString *)stringForKey:(KeyType)key;

/**
 返回指定 key 对应的 NSNumber。若该 key 对应字符串，则用 en_US_POSIX 数字格式解析，格式不符返回 nil。
 
 @param key 键。
 @returns 对应的数字。
 */
- (NSNumber *)numberForKey:(KeyType)key;

/**
 返回指定 key 对应的 NSNumber。若该 key 对应字符串，用 numberFormatter 解析。
 
 @param key 键。
 @param numberFormatter 当 key 对应字符串时用于解析的格式器。
 @returns 对应的数字。
 */
- (NSNumber *)numberForKey:(KeyType)key usingFormatter:(NSNumberFormatter *)numberFormatter;

/**
 返回指定 key 对应的 NSArray。若不是 NSArray 则返回 nil。
 
 @param key 键。
 @returns 对应的数组。
 */
- (NSArray<ValueType> *)arrayForKey:(KeyType)key;

/**
 返回指定 key 对应的 NSDictionary。若不是 NSDictionary 则返回 nil。
 
 @param key 键。
 @returns 对应的字典。
 */
- (NSDictionary<KeyType, ValueType> *)dictionaryForKey:(KeyType)key;

/**
 按 keyPath 取嵌套对象（如 relationship.property 形式，例如 “department.name” 或 “department.manager.lastName”）。
 @param keyPath 键路径。
 @returns keyPath 对应的值，无效时返回 nil。
 */
- (ValueType)objectForKeyPath:(NSString *)keyPath;

/**
 按 keyPath 取嵌套对象并转为 NSString。无效或无法转为字符串时返回 nil。
 
 @param keyPath 键路径，参见 objectForKeyPath:。
 @returns 对应的字符串。
 */
- (NSString *)stringForKeyPath:(NSString *)keyPath;

/**
 按 keyPath 取嵌套对象并转为 NSNumber。keyPath 对应字符串时用 en_US_POSIX 解析，格式不符返回 nil。
 
 @param keyPath 键路径，参见 objectForKeyPath:。
 @returns 对应的数字。
 */
- (NSNumber *)numberForKeyPath:(NSString *)keyPath;

/**
 按 keyPath 取嵌套对象并转为 NSNumber。keyPath 对应字符串时用 numberFormatter 解析。
 
 @param keyPath 键路径。
 @param numberFormatter 当 keyPath 对应字符串时用于解析的格式器。
 @returns 对应的数字。
 */
- (NSNumber *)numberForKeyPath:(NSString *)keyPath usingFormatter:(NSNumberFormatter *)numberFormatter;

/**
 按 keyPath 取嵌套对象并转为 NSArray。无效或非 NSArray 时返回 nil。
 
 @param keyPath 键路径，参见 objectForKeyPath:。
 @returns 对应的数组。
 */
- (NSArray *)arrayForKeyPath:(NSString *)keyPath;

/**
 按 keyPath 取嵌套对象并转为 NSDictionary。无效或非 NSDictionary 时返回 nil。
 
 @param keyPath 键路径，参见 objectForKeyPath:。
 @returns 对应的字典。
 */
- (NSDictionary<KeyType, ValueType> *)dictionaryForKeyPath:(NSString *)keyPath;

- (BOOL)boolValueForKey:(NSString *)key default:(BOOL)def;

- (char)charValueForKey:(NSString *)key default:(char)def;
- (unsigned char)unsignedCharValueForKey:(NSString *)key default:(unsigned char)def;

- (short)shortValueForKey:(NSString *)key default:(short)def;
- (unsigned short)unsignedShortValueForKey:(NSString *)key default:(unsigned short)def;

- (int)intValueForKey:(NSString *)key default:(int)def;
- (unsigned int)unsignedIntValueForKey:(NSString *)key default:(unsigned int)def;

- (long)longValueForKey:(NSString *)key default:(long)def;
- (unsigned long)unsignedLongValueForKey:(NSString *)key default:(unsigned long)def;

- (long long)longLongValueForKey:(NSString *)key default:(long long)def;
- (unsigned long long)unsignedLongLongValueForKey:(NSString *)key default:(unsigned long long)def;

- (float)floatValueForKey:(NSString *)key default:(float)def;
- (double)doubleValueForKey:(NSString *)key default:(double)def;

- (NSInteger)integerValueForKey:(NSString *)key default:(NSInteger)def;
- (NSUInteger)unsignedIntegerValueForKey:(NSString *)key default:(NSUInteger)def;

- (nullable NSNumber *)numberValueForKey:(NSString *)key default:(nullable NSNumber *)def;
- (nullable NSString *)stringValueForKey:(NSString *)key default:(nullable NSString *)def;

#pragma mark - :. XML

/*!
 *  @brief    将NSDictionary转成XML 字符串
 */
- (NSString *)XMLString;

/*
 * 判断字典是否为空
 */
@property(nonatomic, readonly, getter=isEmpty) BOOL empty;

@end

@interface NSMutableDictionary<KeyType, ValueType> (ZKAdd)

/**
 移除并返回指定 key 对应的值。
 
 @param aKey 键。
 @return 该 key 对应的值，不存在则返回 nil。
 */
- (nullable ValueType)popObjectForKey:(KeyType)aKey;

/**
 返回由指定 keys 对应条目组成的新字典，并从接收者中移除这些条目。keys 为空或 nil 时返回空字典。
 
 @param keys 键数组。
 @return 这些 key 对应的条目字典。
 */
- (NSDictionary<KeyType, ValueType> *)popEntriesForKeys:(NSArray<KeyType> *)keys;

@end

NS_ASSUME_NONNULL_END
