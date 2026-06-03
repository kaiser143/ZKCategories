//
//  NSUserDefaults+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (ZKAdd)

- (void)setValue:(id)value forKey:(NSString *)key iCloudSync:(BOOL)sync;
- (void)setObject:(id)value forKey:(NSString *)key iCloudSync:(BOOL)sync;

- (id)valueForKey:(NSString *)key iCloudSync:(BOOL)sync;
- (id)objectForKey:(NSString *)key iCloudSync:(BOOL)sync;

- (BOOL)synchronizeAlsoiCloudSync:(BOOL)sync;

#pragma mark-
#pragma mark :. DefaultValueAccess

/**
 读取指定 key 对应的值并转为目标类型。
 
 @param key          存储时使用的 key。
 @param defaultValue key 不存在、值为 nil 或无法转换时返回的默认值。
 @return 转换后的值，失败时返回 defaultValue。
 @note 支持 NSNumber 直接转换；NSString 会尝试解析为数值或布尔值（如 "true"、"yes"）。
 */
- (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue NS_SWIFT_NAME(bool(forKey:defaultValue:));

- (char)charValueForKey:(NSString *)key defaultValue:(char)defaultValue NS_SWIFT_NAME(char(forKey:defaultValue:));
- (unsigned char)unsignedCharValueForKey:(NSString *)key defaultValue:(unsigned char)defaultValue NS_SWIFT_NAME(unsignedChar(forKey:defaultValue:));

- (short)shortValueForKey:(NSString *)key defaultValue:(short)defaultValue NS_SWIFT_NAME(short(forKey:defaultValue:));
- (unsigned short)unsignedShortValueForKey:(NSString *)key defaultValue:(unsigned short)defaultValue NS_SWIFT_NAME(unsignedShort(forKey:defaultValue:));

- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue NS_SWIFT_NAME(int(forKey:defaultValue:));
- (unsigned int)unsignedIntValueForKey:(NSString *)key defaultValue:(unsigned int)defaultValue NS_SWIFT_NAME(unsignedInt(forKey:defaultValue:));

- (long)longValueForKey:(NSString *)key defaultValue:(long)defaultValue NS_SWIFT_NAME(long(forKey:defaultValue:));
- (unsigned long)unsignedLongValueForKey:(NSString *)key defaultValue:(unsigned long)defaultValue NS_SWIFT_NAME(unsignedLong(forKey:defaultValue:));

- (long long)longLongValueForKey:(NSString *)key defaultValue:(long long)defaultValue NS_SWIFT_NAME(longLong(forKey:defaultValue:));
- (unsigned long long)unsignedLongLongValueForKey:(NSString *)key defaultValue:(unsigned long long)defaultValue NS_SWIFT_NAME(unsignedLongLong(forKey:defaultValue:));

- (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue NS_SWIFT_NAME(float(forKey:defaultValue:));
- (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue NS_SWIFT_NAME(double(forKey:defaultValue:));

- (NSInteger)integerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue NS_SWIFT_NAME(integer(forKey:defaultValue:));
- (NSUInteger)unsignedIntegerValueForKey:(NSString *)key defaultValue:(NSUInteger)defaultValue NS_SWIFT_NAME(unsignedInteger(forKey:defaultValue:));

- (nullable NSNumber *)numberValueForKey:(NSString *)key defaultValue:(nullable NSNumber *)defaultValue NS_SWIFT_NAME(number(forKey:defaultValue:));
- (nullable NSString *)stringValueForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue NS_SWIFT_NAME(string(forKey:defaultValue:));

#pragma mark-
#pragma mark :. SafeAccess

+ (NSString *)stringForKey:(NSString *)defaultName NS_SWIFT_UNAVAILABLE("");

+ (NSArray *)arrayForKey:(NSString *)defaultName NS_SWIFT_UNAVAILABLE("");

+ (NSDictionary *)dictionaryForKey:(NSString *)defaultName NS_SWIFT_UNAVAILABLE("");

+ (NSData *)dataForKey:(NSString *)defaultName NS_SWIFT_UNAVAILABLE("");

+ (NSArray *)stringArrayForKey:(NSString *)defaultName NS_SWIFT_UNAVAILABLE("");

+ (NSInteger)integerForKey:(NSString *)defaultName NS_SWIFT_UNAVAILABLE("");

+ (float)floatForKey:(NSString *)defaultName NS_SWIFT_UNAVAILABLE("");

+ (double)doubleForKey:(NSString *)defaultName NS_SWIFT_UNAVAILABLE("");

+ (BOOL)boolForKey:(NSString *)defaultName NS_SWIFT_UNAVAILABLE("");

+ (NSURL *)URLForKey:(NSString *)defaultName NS_SWIFT_UNAVAILABLE("");

#pragma mark - :. WRITE FOR STANDARD

+ (void)setObject:(id)value forKey:(NSString *)defaultName;

#pragma mark - :. READ ARCHIVE FOR STANDARD

/**
 *  @brief  从 [NSUserDefaults standardUserDefaults] 读取并解档对象。
 *  @param defaultName 存储时使用的 key。
 *  @return 解档后的对象，未存储或解档失败时返回 nil。
 *  @note 对象须支持 NSCoding（实现 encodeWithCoder: 与 initWithCoder:）。
 *
 *  @code
 *  // 读取
 *  MyModel *model = [NSUserDefaults arcObjectForKey:@"my_model"];
 *  @endcode
 */
+ (id)arcObjectForKey:(NSString *)defaultName;

#pragma mark - :. WRITE ARCHIVE FOR STANDARD

/**
 *  @brief  将对象归档后写入 [NSUserDefaults standardUserDefaults] 并 synchronize。
 *  @param value       要存储的对象，须支持 NSCoding；传 nil 会写入空数据。
 *  @param defaultName 存储使用的 key。
 *  @note 对象须支持 NSCoding（实现 encodeWithCoder: 与 initWithCoder:）。
 *
 *  @code
 *  // 存储
 *  MyModel *model = [[MyModel alloc] init];
 *  [NSUserDefaults setArcObject:model forKey:@"my_model"];
 *  @endcode
 */
+ (void)setArcObject:(id)value forKey:(NSString *)defaultName;

@end

NS_ASSUME_NONNULL_END
