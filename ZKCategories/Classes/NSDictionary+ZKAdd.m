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

@end
