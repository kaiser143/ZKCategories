//
//  NSDictionary+ZKAdd.m
//  Pods
//
//  Created by Kaiser on 2017/1/11.
//
//

#import "NSDictionary+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "NSString+ZKAdd.h"

@interface NSDictionary (ZKAdd_Private)

- (NSString *)stringWithObject:(id)obj;
- (NSNumber *)numberWithObject:(id)obj usingFormatter:(NSNumberFormatter *)numberFormatter;
- (NSArray *)arrayWithObject:(id)obj;
- (NSDictionary *)dictionaryWithObject:(id)obj;
+ (NSNumberFormatter *)posixNumberFormatter;

@end

@implementation NSDictionary (ZKAdd)

#pragma mark URL Parameter Strings

- (NSString *)URLEncodedStringValue {
    if (self.count < 1) {
        return @"";
    }
    
    NSEnumerator *keyEnum = [self keyEnumerator];
    NSString *currentKey;
    
    BOOL appendAmpersand = NO;
    
    NSMutableString *parameterString = [[NSMutableString alloc] init];
    
    while ((currentKey = (NSString *)[keyEnum nextObject]) != nil) {
        id currentValue = [self objectForKey:currentKey];
        NSString *stringValue = [currentValue URLParameterStringValue];
        
        if (stringValue != nil) {
            if (appendAmpersand) {
                [parameterString appendString: @"&"];
            }
            
            NSString *escapedStringValue = [stringValue stringByEscapingQueryParameters];
            [parameterString appendFormat: @"%@=%@", currentKey, escapedStringValue];
        }
        
        appendAmpersand = YES;
    }
    
    return parameterString;
}

- (NSDictionary *)dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *result = [self mutableCopy];
    [result addEntriesFromDictionary:dictionary];
    return result;
}

- (NSDictionary *)dictionaryByRemovingValuesForKeys:(NSArray *)keys {
    NSMutableDictionary *result = [self mutableCopy];
    [result removeObjectsForKeys:keys];
    return result;
}

- (NSString *)stringForKey:(id)key {
    id obj = [self safeObjectForKey:key];
    return [self stringWithObject:obj];
}

- (NSNumber *)numberForKey:(id)key {
    id obj = [self safeObjectForKey:key];
    return [self numberWithObject:obj usingFormatter:[[self class] posixNumberFormatter]];
}

- (NSNumber *)numberForKey:(id)key usingFormatter:(NSNumberFormatter *)numberFormatter {
    id obj = [self safeObjectForKey:key];
    return [self numberWithObject:obj usingFormatter:numberFormatter];
}

- (NSArray *)arrayForKey:(id)key {
    id obj = [self safeObjectForKey:key];
    return [self arrayWithObject:obj];
}

- (NSDictionary *)dictionaryForKey:(id)key {
    id obj = [self safeObjectForKey:key];
    return [self dictionaryWithObject:obj];
}

- (id)safeObjectForKey:(id)key {
    NSAssert(key != nil, @"nil key");
    return [self objectForKey:key];
}

- (id)objectForKeyPath:(NSString *)keyPath {
    id object = self;
    NSArray *keyPaths = [keyPath componentsSeparatedByString:@"."];
    for (NSString *currentKeyPath in keyPaths) {
        if (![object isKindOfClass:[NSDictionary class]])
            object = nil;
        
        object = [object objectForKey:currentKeyPath];
        
        if (object == nil)
            break;
    }
    return object;
}

- (NSString *)stringForKeyPath:(id)keyPath {
    id obj = [self objectForKeyPath:keyPath];
    return [self stringWithObject:obj];
    
}

- (NSNumber *)numberForKeyPath:(id)keyPath {
    id obj = [self objectForKeyPath:keyPath];
    return [self numberWithObject:obj usingFormatter:[[self class] posixNumberFormatter]];
}

- (NSNumber *)numberForKeyPath:(id)keyPath usingFormatter:(NSNumberFormatter *)numberFormatter{
    id obj = [self objectForKeyPath:keyPath];
    return [self numberWithObject:obj usingFormatter:numberFormatter];
}

- (NSArray *)arrayForKeyPath:(id)keyPath {
    id obj = [self objectForKeyPath:keyPath];
    return [self arrayWithObject:obj];
}

- (NSDictionary *)dictionaryForKeyPath:(id)keyPath {
    id obj = [self objectForKeyPath:keyPath];
    return [self dictionaryWithObject:obj];
}

@end

@implementation NSDictionary (ZKAdd_Private)

+ (NSNumberFormatter *)posixNumberFormatter {
    static dispatch_once_t onceToken;
    static NSNumberFormatter *posixFormatter;
    dispatch_once(&onceToken, ^{
        posixFormatter = [[NSNumberFormatter alloc] init];
        [posixFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return posixFormatter;
}

- (NSString *)stringWithObject:(id)obj {
    NSString *string = obj;
    
    if (![string isKindOfClass:[NSString class]] && [string respondsToSelector:@selector(stringValue)])
        string = [string performSelector:@selector(stringValue)];
    
    if (![string isKindOfClass:[NSString class]])
        string = nil;
    
    return string;
}

- (NSNumber *)numberWithObject:(id)obj usingFormatter:(NSNumberFormatter *)numberFormatter{
    
    if ([obj isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)obj;
    }
    
    if ([obj isKindOfClass:[NSString class]]) {
        NSNumber *number = [numberFormatter numberFromString:(NSString *)obj];
        return number;
    }
    
    return nil;
}

- (NSArray *)arrayWithObject:(id)obj {
    NSArray *array = obj;
    
    if (![array isKindOfClass:[NSArray class]]) {
        array = nil;
    }
    
    return array;
}

- (NSDictionary *)dictionaryWithObject:(id)obj {
    NSDictionary *dictionary = obj;
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        dictionary = nil;
    }
    
    return dictionary;
}

@end
