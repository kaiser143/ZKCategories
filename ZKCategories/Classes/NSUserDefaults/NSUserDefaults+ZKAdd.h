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

+ (id)arcObjectForKey:(NSString *)defaultName;

#pragma mark - :. WRITE ARCHIVE FOR STANDARD

+ (void)setArcObject:(id)value forKey:(NSString *)defaultName;

@end

NS_ASSUME_NONNULL_END
