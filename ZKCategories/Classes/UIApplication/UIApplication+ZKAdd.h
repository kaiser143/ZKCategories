//
//  UIApplication+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 为 `UIApplication` 提供扩展。
 */
@interface UIApplication (ZKAdd)

/// 应用沙盒中的 "Documents" 目录。
@property (nonatomic, readonly) NSURL *documentsURL;
@property (nonatomic, readonly) NSString *documentsPath;

/// 应用沙盒中的 "Caches" 目录。
@property (nonatomic, readonly) NSURL *cachesURL;
@property (nonatomic, readonly) NSString *cachesPath;

/// 应用沙盒中的 "Library" 目录。
@property (nonatomic, readonly) NSURL *libraryURL;
@property (nonatomic, readonly) NSString *libraryPath;

/// 应用 Bundle 名称（在 SpringBoard 中显示）。
@property (nullable, nonatomic, readonly) NSString *appBundleName;

/// 应用 Bundle ID，如 "com.kaiser.MyApp"
@property (nullable, nonatomic, readonly) NSString *appBundleID;

/// 应用版本号，如 "1.2.0"
@property (nullable, nonatomic, readonly) NSString *appVersion;

/// 应用 Build 号，如 "123"
@property (nullable, nonatomic, readonly) NSString *appBuildVersion;

/// 是否为盗版（非 App Store 安装）。
@property (nonatomic, readonly) BOOL isPirated;

/// 是否正在被调试（已连接调试器）。
@property (nonatomic, readonly) BOOL isBeingDebugged;

/// 当前线程实际占用内存（字节），错误时返回 -1。
@property (nonatomic, readonly) int64_t memoryUsage;

/// 当前线程 CPU 使用率，1.0 表示 100%，错误时返回 -1。
@property (nonatomic, readonly) float cpuUsage;

@property (nonatomic, assign, readonly, getter=isRunningTestFlightBeta) BOOL runningTestFlightBeta;

/**
 在 iPad 分屏模式下可获得实际运行区域的窗口大小，如需适配 iPad 分屏，建议用这个方法来代替 [UIScreen mainScreen].bounds.size
 @return 应用运行的窗口大小
 */
@property(class, nonatomic, readonly) CGSize applicationSize;

/**
 将“进行中的网络操作”计数加一（用于延迟休眠）。
 */
- (void)pushActiveNetworkOperation;

/**
 将“进行中的网络操作”计数减一。
 */
- (void)popActiveNetworkOperation;


/// 在 App Extension 中返回 YES。
+ (BOOL)isAppExtension;

/// 与 sharedApplication 相同，但在 App Extension 中返回 nil。
+ (nullable UIApplication *)sharedExtensionApplication;

@end

NS_ASSUME_NONNULL_END
