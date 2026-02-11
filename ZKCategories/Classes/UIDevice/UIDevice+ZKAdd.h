//
//  UIDevice+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 为 `UIDevice` 提供扩展。
 */
@interface UIDevice (ZKAdd)

#pragma mark - Device Information
///=============================================================================
/// @name 设备信息
///=============================================================================

/// 系统版本号（如 8.1）
+ (double)systemVersion;

// 刘海屏
@property (nonatomic, readonly) BOOL iPhoneX;

/// 是否为 iPad / iPad mini。
@property (nonatomic, readonly) BOOL isPad;

/// 是否为模拟器。
@property (nonatomic, readonly) BOOL isSimulator;

/// 是否越狱。
@property (nonatomic, readonly) BOOL isJailbroken;

/// 是否支持拨打电话。
@property (nonatomic, readonly) BOOL canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");

/// 设备机型标识，如 "iPhone6,1" "iPad4,6"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString *machineModel;

/// 设备机型名称，如 "iPhone 5s" "iPad mini 2"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString *machineModelName;

/// 系统启动时间。
@property (nonatomic, readonly) NSDate *systemUptime;

#pragma mark - Network Information
///=============================================================================
/// @name 网络信息
///=============================================================================

/// 本机 WIFI IP（可能为 nil），如 @"192.168.1.111"
@property (nullable, nonatomic, readonly) NSString *ipAddressWIFI;

/// 本机蜂窝网 IP（可能为 nil），如 @"10.2.2.222"
@property (nullable, nonatomic, readonly) NSString *ipAddressCell;

/**
 网络流量类型：
 WWAN：无线广域网（如 3G/4G）。
 WIFI：Wi-Fi。
 AWDL：Apple 无线直连（点对点，如 AirDrop、AirPlay、GameKit）。
 */
typedef NS_OPTIONS(NSUInteger, ZKNetworkTrafficType) {
    ZKNetworkTrafficTypeWWANSent     = 1 << 0,
    ZKNetworkTrafficTypeWWANReceived = 1 << 1,
    ZKNetworkTrafficTypeWIFISent     = 1 << 2,
    ZKNetworkTrafficTypeWIFIReceived = 1 << 3,
    ZKNetworkTrafficTypeAWDLSent     = 1 << 4,
    ZKNetworkTrafficTypeAWDLReceived = 1 << 5,

    ZKNetworkTrafficTypeWWAN = ZKNetworkTrafficTypeWWANSent | ZKNetworkTrafficTypeWWANReceived,
    ZKNetworkTrafficTypeWIFI = ZKNetworkTrafficTypeWIFISent | ZKNetworkTrafficTypeWIFIReceived,
    ZKNetworkTrafficTypeAWDL = ZKNetworkTrafficTypeAWDLSent | ZKNetworkTrafficTypeAWDLReceived,

    ZKNetworkTrafficTypeALL = ZKNetworkTrafficTypeWWAN |
                              ZKNetworkTrafficTypeWIFI |
                              ZKNetworkTrafficTypeAWDL,
};

/**
 获取设备网络流量字节数。

 @discussion 为自设备上次启动以来的累计计数。可用于计算网速（两次调用间隔的字节差/时间差）。
 @param types 流量类型掩码。
 @return 字节计数。
 */
- (uint64_t)getNetworkTrafficBytes:(ZKNetworkTrafficType)types;

#pragma mark - Disk Space
///=============================================================================
/// @name 磁盘空间
///=============================================================================

/// 磁盘总空间（字节），错误时返回 -1。
@property (nonatomic, readonly) int64_t diskSpace;

/// 磁盘可用空间（字节），错误时返回 -1。
@property (nonatomic, readonly) int64_t diskSpaceFree;

/// 磁盘已用空间（字节），错误时返回 -1。
@property (nonatomic, readonly) int64_t diskSpaceUsed;

#pragma mark - Memory Information
///=============================================================================
/// @name 内存信息
///=============================================================================

/// 物理内存总量（字节），错误时返回 -1。
@property (nonatomic, readonly) int64_t memoryTotal;

/// 已用内存（active + inactive + wired）（字节），错误时返回 -1。
@property (nonatomic, readonly) int64_t memoryUsed;

/// 空闲内存（字节），错误时返回 -1。
@property (nonatomic, readonly) int64_t memoryFree;

/// Active 内存（字节），错误时返回 -1。
@property (nonatomic, readonly) int64_t memoryActive;

/// Inactive 内存（字节），错误时返回 -1。
@property (nonatomic, readonly) int64_t memoryInactive;

/// Wired 内存（字节），错误时返回 -1。
@property (nonatomic, readonly) int64_t memoryWired;

/// Purgable 内存（字节），错误时返回 -1。
@property (nonatomic, readonly) int64_t memoryPurgable;

#pragma mark - CPU Information
///=============================================================================
/// @name CPU 信息
///=============================================================================

/// 可用 CPU 核心数。
@property (nonatomic, readonly) NSUInteger cpuCount;

/// 当前 CPU 使用率，1.0 表示 100%，错误时返回 -1。
@property (nonatomic, readonly) float cpuUsage;

/// 各核心 CPU 使用率（NSNumber 数组），1.0 表示 100%，错误时返回 nil。
@property (nullable, nonatomic, readonly) NSArray<NSNumber *> *cpuUsagePerProcessor;

@end

NS_ASSUME_NONNULL_END

#ifndef kSystemVersion
#define kSystemVersion [UIDevice systemVersion]
#endif

#ifndef kiOS6Later
#define kiOS6Later (kSystemVersion >= 6)
#endif

#ifndef kiOS7Later
#define kiOS7Later (kSystemVersion >= 7)
#endif

#ifndef kiOS8Later
#define kiOS8Later (kSystemVersion >= 8)
#endif

#ifndef kiOS9Later
#define kiOS9Later (kSystemVersion >= 9)
#endif
