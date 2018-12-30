//
//  NSDate+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/1/11.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import "NSDate+ZKAdd.h"

@implementation NSDate (ZKAdd)

+ (NSDateFormatter *)ISO8601DateFormatterConfiguredForTimeZone:(NSTimeZone *)inTimeZone supportingFractionalSeconds:(BOOL)inSupportFractionalSeconds {
    NSTimeZone *timeZone = inTimeZone;
    if (!timeZone) {
        timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    }
    
    // Y-MM-dd'T'HH':'MM':'ss'.'SSS'Z
    // Y-MM-dd'T'HH':'MM':'ss'.'SSS'Z'Z
    NSMutableString *formatString = [[NSMutableString alloc] initWithString:@"Y-MM-dd'T'HH':'mm':'ss"];
    if (inSupportFractionalSeconds) {
        [formatString appendString:@"'.'SSS"];
    }
    
    [formatString appendString:@"'Z'"];
    
    if (inTimeZone && ![timeZone isEqualToTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]]) {
        [formatString appendString:@"Z"];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatString];
    [formatter setTimeZone:timeZone];
    
    return formatter;
}

- (NSString *)HTTPTimeZoneHeaderString {
    return [self HTTPTimeZoneHeaderStringForTimeZone:nil];
}

- (NSString *)HTTPTimeZoneHeaderStringForTimeZone:(NSTimeZone *)inTimeZone {
    NSTimeZone *timeZone = inTimeZone ? inTimeZone : [NSTimeZone localTimeZone];
    NSString *dateString = [self ISO8601StringForTimeZone:timeZone];
    NSString *timeZoneHeader = [NSString stringWithFormat:@"%@;;%@", dateString, [timeZone name]];
    return timeZoneHeader;
}

- (NSString *)ISO8601StringForLocalTimeZone {
    return [self ISO8601StringForTimeZone:[NSTimeZone localTimeZone]];
}

- (NSString *)ISO8601String {
    return [self ISO8601StringForTimeZone:nil];
}

- (NSString *)ISO8601StringForTimeZone:(NSTimeZone *)inTimeZone {
    return [self ISO8601StringForTimeZone:inTimeZone usingFractionalSeconds:NO];
}

- (NSString *)ISO8601StringForTimeZone:(NSTimeZone *)inTimeZone usingFractionalSeconds:(BOOL)inUseFractionalSeconds {
    return [[NSDate ISO8601DateFormatterConfiguredForTimeZone:inTimeZone supportingFractionalSeconds:inUseFractionalSeconds] stringFromDate:self];
    
    /*
     struct tm *timeinfo;
     char buffer[80];
     
     time_t rawtime = [self timeIntervalSince1970] - [timeZone secondsFromGMT];
     timeinfo = localtime(&rawtime);
     
     NSString *formatString = nil;
     if (inTimeZone) {
     
     }
     
     strftime(buffer, 80, "%Y-%m-%dT%H:%M:%S%z", timeinfo);
     
     returnString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
     */
}

@end
