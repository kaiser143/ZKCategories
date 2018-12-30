//
//  NSDate+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/1/11.
//  Copyright © 2017年 Kaiser. All rights reserved.
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
