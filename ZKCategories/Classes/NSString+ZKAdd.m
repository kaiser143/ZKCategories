//
//  NSString+ZKAdd.m
//  kuaisong
//
//  Created by Kaiser on 2016/11/21.
//  Copyright © 2016年 zhiqiyun. All rights reserved.
//

#import "NSString+ZKAdd.h"
#import "NSNumber+ZKAdd.h"
#import "NSDictionary+ZKAdd.h"

#define URL_MATCHING_PATTERN @"(?i)\\b((?:https?://|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))"

@implementation NSString (ZKAdd)

- (BOOL)isValidURL {
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", URL_MATCHING_PATTERN];
    BOOL returnBool = [regex evaluateWithObject:self];
    return returnBool;
}

- (nullable NSDictionary *)dictionaryWithURLEncodedString {
    NSMutableDictionary *mutableResponseDictionary = [[NSMutableDictionary alloc] init];
    // split string by &s
    NSArray *encodedParameters = [self componentsSeparatedByString:@"&"];
    for (NSString *parameter in encodedParameters) {
        NSArray *keyValuePair = [parameter componentsSeparatedByString:@"="];
        if (keyValuePair.count == 2) {
            NSString *key = [[keyValuePair objectAtIndex:0] stringByReplacingPercentEscapes];
            NSString *value = [[keyValuePair objectAtIndex:1] stringByReplacingPercentEscapes];
            [mutableResponseDictionary setObject:value forKey:key];
        }
    }
    return mutableResponseDictionary;
}

- (NSString *)stringByAddingQueryDictionary:(NSDictionary*)query {
    if (0 == query.count) return self;

    NSString *stringValue = [query URLEncodedStringValue];
    if ([self rangeOfString:@"?"].location == NSNotFound) {
        return [self stringByAppendingFormat:@"?%@", stringValue];
        
    } else {
        return [self stringByAppendingFormat:@"&%@", stringValue];
    }
}

- (NSComparisonResult)versionStringCompare:(NSString *)other {
    NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
    NSArray *twoComponents = [other componentsSeparatedByString:@"a"];
    
    // The parts before the "a"
    NSString *oneMain = [oneComponents objectAtIndex:0];
    NSString *twoMain = [twoComponents objectAtIndex:0];
    
    // If main parts are different, return that result, regardless of alpha part
    NSComparisonResult mainDiff;
    if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
        return mainDiff;
    }
    
    // At this point the main parts are the same; just deal with alpha stuff
    // If one has an alpha part and the other doesn't, the one without is newer
    if ([oneComponents count] < [twoComponents count]) {
        return NSOrderedDescending;
        
    } else if ([oneComponents count] > [twoComponents count]) {
        return NSOrderedAscending;
        
    } else if ([oneComponents count] == 1) {
        // Neither has an alpha part, and we know the main parts are the same
        return NSOrderedSame;
    }
    
    // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
    // numerically. If it's not a valid number (including empty string) it's treated as zero.
    NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
    NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
    return [oneAlpha compare:twoAlpha];
}

#pragma mark URL Escaping

- (NSString *)stringByEscapingQueryParameters {
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]%"), kCFStringEncodingUTF8));
}

- (NSString *)stringByReplacingPercentEscapes {
    return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)self, CFSTR("")));
}

- (nullable NSURL *)URL {
    return [NSURL URLWithString:self];
}

- (nullable NSURL *)URLRelativeToURL:(nullable NSURL *)baseURL {
    return [NSURL URLWithString:self relativeToURL:baseURL];
}

@end
