//
//  NSString+ZKAdd.m
//  kuaisong
//
//  Created by Kaiser on 2016/11/21.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "NSString+ZKAdd.h"
#import "NSNumber+ZKAdd.h"
#import "NSDictionary+ZKAdd.h"
#import <MobileCoreServices/MobileCoreServices.h>

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

- (BOOL)contains:(NSString *)substring {
    NSRange range = [self rangeOfString:substring];
    return range.location != NSNotFound;
}

- (BOOL)startWith:(NSString *)substring {
    NSRange range = [self rangeOfString:substring];
    return range.location == 0;
}

- (BOOL)endWith:(NSString *)substring {
    NSRange range = [self rangeOfString:substring];
    return range.location == self.length - substring.length;
}

- (NSUInteger)indexOf:(NSString *)substring {
    NSRange range = [self rangeOfString:substring options:NSCaseInsensitiveSearch];
    return range.location == NSNotFound ? -1 : range.location;
}

- (NSArray *)split:(NSString *)token {
    return [self split:token limit:0];
}

- (NSArray*)split: (NSString*)token limit:(NSUInteger)maxResults {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity: 8];
    NSString* buffer = self;
    while ([buffer contains:token]) {
        if (maxResults > 0 && [result count] == maxResults - 1) {
            break;
        }
        NSUInteger matchIndex = [buffer indexOf:token];
        NSString* nextPart = [buffer substringFromIndex:0 toIndex:matchIndex];
        buffer = [buffer substringFromIndex:matchIndex + [token length]];
        [result addObject:nextPart];
    }
    if ([buffer length] > 0) {
        [result addObject:buffer];
    }
    
    return result;
}

- (NSString*)substringFromIndex:(NSUInteger)from toIndex:(NSUInteger)to {
    NSRange range;
    range.location = from;
    range.length = to - from;
    return [self substringWithRange:range];
}

+ (NSString *)stringByFormattingBytes:(long long)bytes {
    NSArray *units = @[@"%1.0f Bytes", @"%1.1f KB", @"%1.1f MB", @"%1.1f GB", @"%1.1f TB"];
    
    long long value = bytes * 10;
    for (NSUInteger i=0; i<[units count]; i++) {
        if (i > 0) {
            value = value/1024;
        }
        if (value < 10000) {
            return [NSString stringWithFormat:units[i], value/10.0];
        }
    }
    
    return [NSString stringWithFormat:units[[units count]-1], value/10.0];
}

@end

@implementation NSString (ZKUTI)

+ (NSString *)MIMETypeForFileExtension:(NSString *)extension {
    CFStringRef typeForExt = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)extension , NULL);
    NSString *result = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(typeForExt, kUTTagClassMIMEType);
    CFRelease(typeForExt);
    if (!result)
    {
        return @"application/octet-stream";
    }
    
    return result;
}

+ (NSString *)fileTypeDescriptionForFileExtension:(NSString *)extension {
    CFStringRef typeForExt = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)extension , NULL);
    NSString *result = (__bridge_transfer NSString *)UTTypeCopyDescription(typeForExt);
    CFRelease(typeForExt);
    return result;
}

+ (NSString *)universalTypeIdentifierForFileExtension:(NSString *)extension {
    return (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)extension , NULL);
}

+ (NSString *)fileExtensionForUniversalTypeIdentifier:(NSString *)UTI {
    return (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)(UTI), kUTTagClassFilenameExtension);
}

- (BOOL)conformsToUniversalTypeIdentifier:(NSString *)conformingUTI {
    return UTTypeConformsTo((__bridge CFStringRef)(self), (__bridge CFStringRef)conformingUTI);
}

- (BOOL)isMovieFileName {
    NSString *extension = [self pathExtension];
    
    // without extension we cannot know
    if (![extension length])
    {
        return NO;
    }
    
    NSString *uti = [NSString universalTypeIdentifierForFileExtension:extension];
    
    return [uti conformsToUniversalTypeIdentifier:@"public.movie"];
}

- (BOOL)isAudioFileName {
    NSString *extension = [self pathExtension];
    
    // without extension we cannot know
    if (![extension length])
    {
        return NO;
    }
    
    NSString *uti = [NSString universalTypeIdentifierForFileExtension:extension];
    
    return [uti conformsToUniversalTypeIdentifier:@"public.audio"];
}

- (BOOL)isImageFileName {
    NSString *extension = [self pathExtension];
    
    // without extension we cannot know
    if (![extension length])
    {
        return NO;
    }
    
    NSString *uti = [NSString universalTypeIdentifierForFileExtension:extension];
    
    return [uti conformsToUniversalTypeIdentifier:@"public.image"];
}

- (BOOL)isHTMLFileName {
    NSString *extension = [self pathExtension];
    
    // without extension we cannot know
    if (![extension length])
    {
        return NO;
    }
    
    NSString *uti = [NSString universalTypeIdentifierForFileExtension:extension];
    
    return [uti conformsToUniversalTypeIdentifier:@"public.html"];
}

@end

