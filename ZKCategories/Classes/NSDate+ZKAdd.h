//
//  NSDate+ZKAdd.h
//  Pods
//
//  Created by Kaiser on 2017/1/11.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (ZKAdd)

// HTTP Dates
- (NSString *)HTTPTimeZoneHeaderString;
- (NSString *)HTTPTimeZoneHeaderStringForTimeZone:(NSTimeZone *)inTimeZone;
- (NSString *)ISO8601String;
- (NSString *)ISO8601StringForLocalTimeZone;
- (NSString *)ISO8601StringForTimeZone:(NSTimeZone *)inTimeZone;
- (NSString *)ISO8601StringForTimeZone:(NSTimeZone *)inTimeZone usingFractionalSeconds:(BOOL)inUseFractionalSeconds;

@end
