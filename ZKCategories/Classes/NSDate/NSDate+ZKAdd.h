//
//  NSDate+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/1/11.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (ZKAdd)

// HTTP Dates
- (NSString *)HTTPTimeZoneHeaderString;
- (NSString *)HTTPTimeZoneHeaderStringForTimeZone:(nullable NSTimeZone *)inTimeZone;
- (NSString *)ISO8601String;
- (NSString *)ISO8601StringForLocalTimeZone;
- (NSString *)ISO8601StringForTimeZone:(nullable NSTimeZone *)inTimeZone;
- (NSString *)ISO8601StringForTimeZone:(nullable NSTimeZone *)inTimeZone usingFractionalSeconds:(BOOL)inUseFractionalSeconds;

#pragma mark - :. Component Properties
///=============================================================================
/// @name Component Properties
///=============================================================================

@property (nonatomic, readonly) NSInteger year;              ///< 年
@property (nonatomic, readonly) NSInteger month;             ///< 月 (1~12)
@property (nonatomic, readonly) NSInteger day;               ///< 日 (1~31)
@property (nonatomic, readonly) NSInteger hour;              ///< 时 (0~23)
@property (nonatomic, readonly) NSInteger minute;            ///< 分 (0~59)
@property (nonatomic, readonly) NSInteger second;            ///< 秒 (0~59)
@property (nonatomic, readonly) NSInteger nanosecond;        ///< 纳秒
@property (nonatomic, readonly) NSInteger weekday;           ///< 星期 (1~7，首日依用户设置)
@property (nonatomic, readonly) NSInteger weekdayOrdinal;    ///< WeekdayOrdinal 分量
@property (nonatomic, readonly) NSInteger weekOfMonth;       ///< 当月周序 (1~5)
@property (nonatomic, readonly) NSInteger weekOfYear;        ///< 当年周序 (1~53)
@property (nonatomic, readonly) NSInteger yearForWeekOfYear; ///< 周所在年
@property (nonatomic, readonly) NSInteger quarter;           ///< 季度
@property (nonatomic, readonly) BOOL isLeapMonth;            ///< 是否闰月
@property (nonatomic, readonly) BOOL isLeapYear;             ///< 是否闰年
@property (nonatomic, readonly) BOOL isToday;                ///< 是否今天（基于当前 locale）
@property (nonatomic, readonly) BOOL isYesterday;            ///< 是否昨天（基于当前 locale）

#pragma mark - :. Date modify
///=============================================================================
/// @name Date modify
///=============================================================================

/**
 返回在接收者日期上增加若干年后的日期。
 
 @param years  要增加的年数。
 @return 增加后的日期。
 */
- (nullable NSDate *)dateByAddingYears:(NSInteger)years;

/**
 返回在接收者日期上增加若干月后的日期。
 
 @param months 要增加的月数。
 @return 增加后的日期。
 */
- (nullable NSDate *)dateByAddingMonths:(NSInteger)months;

/**
 返回在接收者日期上增加若干周后的日期。
 
 @param weeks 要增加的周数。
 @return 增加后的日期。
 */
- (nullable NSDate *)dateByAddingWeeks:(NSInteger)weeks;

/**
 返回在接收者日期上增加若干天后的日期。
 
 @param days 要增加的天数。
 @return 增加后的日期。
 */
- (nullable NSDate *)dateByAddingDays:(NSInteger)days;

/**
 返回在接收者日期上增加若干小时后的日期。
 
 @param hours 要增加的小时数。
 @return 增加后的日期。
 */
- (nullable NSDate *)dateByAddingHours:(NSInteger)hours;

/**
 返回在接收者日期上增加若干分钟后的日期。
 
 @param minutes 要增加的分钟数。
 @return 增加后的日期。
 */
- (nullable NSDate *)dateByAddingMinutes:(NSInteger)minutes;

/**
 返回在接收者日期上增加若干秒后的日期。
 
 @param seconds 要增加的秒数。
 @return 增加后的日期。
 */
- (nullable NSDate *)dateByAddingSeconds:(NSInteger)seconds;

#pragma mark - :. Date Format
///=============================================================================
/// @name Date Format
///=============================================================================

/**
 按指定格式返回日期的格式化字符串。格式说明见 http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 
 @param format 日期格式，例如 @"yyyy-MM-dd HH:mm:ss"。
 @return 格式化后的日期字符串。
 */
- (nullable NSString *)stringWithFormat:(NSString *)format;

/**
 按指定格式、时区和 locale 返回日期的格式化字符串。
 
 @param format   日期格式，例如 @"yyyy-MM-dd HH:mm:ss"。
 @param timeZone 时区。
 @param locale   locale。
 @return 格式化后的日期字符串。
 */
- (nullable NSString *)stringWithFormat:(NSString *)format
                               timeZone:(nullable NSTimeZone *)timeZone
                                 locale:(nullable NSLocale *)locale;

/**
 返回 ISO8601 格式的日期字符串，例如 "2010-07-09T16:13:30+12:00"。
 
 @return ISO8601 格式的日期字符串。
 */
- (nullable NSString *)stringWithISOFormat;

/**
 按给定格式解析字符串得到日期。
 
 @param dateString 要解析的字符串。
 @param format    日期格式。
 @return 解析得到的日期，失败返回 nil。
 */
+ (nullable NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

/**
 按给定格式、时区和 locale 解析字符串得到日期。
 
 @param dateString 要解析的字符串。
 @param format     日期格式。
 @param timeZone   时区，可为 nil。
 @param locale     locale，可为 nil。
 @return 解析得到的日期，失败返回 nil。
 */
+ (nullable NSDate *)dateWithString:(NSString *)dateString
                             format:(NSString *)format
                           timeZone:(nullable NSTimeZone *)timeZone
                             locale:(nullable NSLocale *)locale;

/**
 按 ISO8601 格式解析字符串得到日期。
 
 @param dateString ISO8601 格式的日期字符串，例如 "2010-07-09T16:13:30+12:00"。
 @return 解析得到的日期，失败返回 nil。
 */
+ (nullable NSDate *)dateWithISOFormatString:(NSString *)dateString;

@end

NS_ASSUME_NONNULL_END
