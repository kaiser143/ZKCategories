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
