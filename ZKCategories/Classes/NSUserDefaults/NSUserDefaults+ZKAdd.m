//
//  NSUserDefaults+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "NSUserDefaults+ZKAdd.h"

static NSNumber *ZKNSNumberFromID(id value) {
    static NSCharacterSet *dot;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
    });
    if (!value) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSString *lower = ((NSString *)value).lowercaseString;
        if ([lower isEqualToString:@"true"] || [lower isEqualToString:@"yes"]) return @(YES);
        if ([lower isEqualToString:@"false"] || [lower isEqualToString:@"no"]) return @(NO);
        if ([lower isEqualToString:@"nil"] || [lower isEqualToString:@"null"]) return nil;
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            return @(((NSString *)value).doubleValue);
        } else {
            return @(((NSString *)value).longLongValue);
        }
    }
    return nil;
}

@implementation NSUserDefaults (ZKAdd)

- (void)setValue:(id)value forKey:(NSString *)key iCloudSync:(BOOL)sync {
    if (sync)
        [[NSUbiquitousKeyValueStore defaultStore] setValue:value forKey:key];

    [self setValue:value forKey:key];
}

- (id)valueForKey:(NSString *)key iCloudSync:(BOOL)sync {
    if (sync) {
        //Get value from iCloud
        id value = [[NSUbiquitousKeyValueStore defaultStore] valueForKey:key];

        //Store locally and synchronize
        [self setValue:value forKey:key];
        [self synchronize];

        return value;
    }

    return [self valueForKey:key];
}

- (void)removeValueForKey:(NSString *)key iCloudSync:(BOOL)sync {
    [self removeObjectForKey:key iCloudSync:sync];
}

- (void)setObject:(id)value forKey:(NSString *)defaultName iCloudSync:(BOOL)sync {
    if (sync)
        [[NSUbiquitousKeyValueStore defaultStore] setObject:value forKey:defaultName];

    [self setObject:value forKey:defaultName];
}

- (id)objectForKey:(NSString *)key iCloudSync:(BOOL)sync {
    if (sync) {
        //Get value from iCloud
        id value = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:key];

        //Store to NSUserDefault and synchronize
        [self setObject:value forKey:key];
        [self synchronize];

        return value;
    }

    return [self objectForKey:key];
}

- (void)removeObjectForKey:(NSString *)key iCloudSync:(BOOL)sync {
    if (sync)
        [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:key];

    //Remove from NSUserDefault
    return [self removeObjectForKey:key];
}

- (BOOL)synchronizeAlsoiCloudSync:(BOOL)sync {
    BOOL res = true;

    if (sync)
        res &= [self synchronize];

    res &= [[NSUbiquitousKeyValueStore defaultStore] synchronize];

    return res;
}

#pragma mark -
#pragma mark :. DefaultValueAccess

#define RETURN_UD_VALUE(_type_)                                              \
    if (!key) return defaultValue;                                           \
    id value = [self objectForKey:key];                                      \
    if (!value) return defaultValue;                                         \
    if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value)._type_; \
    if ([value isKindOfClass:[NSString class]]) return ZKNSNumberFromID(value)._type_; \
    return defaultValue;

- (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    RETURN_UD_VALUE(boolValue);
}

- (char)charValueForKey:(NSString *)key defaultValue:(char)defaultValue {
    RETURN_UD_VALUE(charValue);
}

- (unsigned char)unsignedCharValueForKey:(NSString *)key defaultValue:(unsigned char)defaultValue {
    RETURN_UD_VALUE(unsignedCharValue);
}

- (short)shortValueForKey:(NSString *)key defaultValue:(short)defaultValue {
    RETURN_UD_VALUE(shortValue);
}

- (unsigned short)unsignedShortValueForKey:(NSString *)key defaultValue:(unsigned short)defaultValue {
    RETURN_UD_VALUE(unsignedShortValue);
}

- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue {
    RETURN_UD_VALUE(intValue);
}

- (unsigned int)unsignedIntValueForKey:(NSString *)key defaultValue:(unsigned int)defaultValue {
    RETURN_UD_VALUE(unsignedIntValue);
}

- (long)longValueForKey:(NSString *)key defaultValue:(long)defaultValue {
    RETURN_UD_VALUE(longValue);
}

- (unsigned long)unsignedLongValueForKey:(NSString *)key defaultValue:(unsigned long)defaultValue {
    RETURN_UD_VALUE(unsignedLongValue);
}

- (long long)longLongValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
    RETURN_UD_VALUE(longLongValue);
}

- (unsigned long long)unsignedLongLongValueForKey:(NSString *)key defaultValue:(unsigned long long)defaultValue {
    RETURN_UD_VALUE(unsignedLongLongValue);
}

- (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue {
    RETURN_UD_VALUE(floatValue);
}

- (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue {
    RETURN_UD_VALUE(doubleValue);
}

- (NSInteger)integerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue {
    RETURN_UD_VALUE(integerValue);
}

- (NSUInteger)unsignedIntegerValueForKey:(NSString *)key defaultValue:(NSUInteger)defaultValue {
    RETURN_UD_VALUE(unsignedIntegerValue);
}

- (NSNumber *)numberValueForKey:(NSString *)key defaultValue:(NSNumber *)defaultValue {
    if (!key) return defaultValue;
    id value = [self objectForKey:key];
    if (!value) return defaultValue;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) return ZKNSNumberFromID(value);
    return defaultValue;
}

- (NSString *)stringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    if (!key) return defaultValue;
    id value = [self objectForKey:key];
    if (!value) return defaultValue;
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value).description;
    return defaultValue;
}

#pragma mark -
#pragma mark :. SafeAccess

+ (NSString *)stringForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:defaultName];
}

+ (NSArray *)arrayForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:defaultName];
}

+ (NSDictionary *)dictionaryForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:defaultName];
}

+ (NSData *)dataForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] dataForKey:defaultName];
}

+ (NSArray *)stringArrayForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] stringArrayForKey:defaultName];
}

+ (NSInteger)integerForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] integerForKey:defaultName];
}

+ (float)floatForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] floatForKey:defaultName];
}

+ (double)doubleForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:defaultName];
}

+ (BOOL)boolForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:defaultName];
}

+ (NSURL *)URLForKey:(NSString *)defaultName {
    return [[NSUserDefaults standardUserDefaults] URLForKey:defaultName];
}

#pragma mark--- WRITE FOR STANDARD

+ (void)setObject:(id)value forKey:(NSString *)defaultName {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark--- READ ARCHIVE FOR STANDARD

+ (id)arcObjectForKey:(NSString *)defaultName {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:defaultName]];
}

#pragma mark--- WRITE ARCHIVE FOR STANDARD

+ (void)setArcObject:(id)value forKey:(NSString *)defaultName {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
