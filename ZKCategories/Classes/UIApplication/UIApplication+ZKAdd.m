//
//  UIApplication+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIApplication+ZKAdd.h"
#import "NSArray+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "ZKCategoriesMacro.h"
#import "UIDevice+ZKAdd.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <objc/runtime.h>

static NSUInteger __internalOperationCount = 0;

@implementation UIApplication (ZKAdd)

- (NSURL *)documentsURL {
    return [[[NSFileManager defaultManager]
        URLsForDirectory:NSDocumentDirectory
               inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)documentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSURL *)cachesURL {
    return [[[NSFileManager defaultManager]
        URLsForDirectory:NSCachesDirectory
               inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)cachesPath {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSURL *)libraryURL {
    return [[[NSFileManager defaultManager]
        URLsForDirectory:NSLibraryDirectory
               inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)libraryPath {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

- (BOOL)isPirated {
    if ([[UIDevice currentDevice] isSimulator]) return YES; // Simulator is not from appstore

    if (getgid() <= 10) return YES; // process ID shouldn't be root

    if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"]) {
        return YES;
    }

    if (![self _kai_fileExistInMainBundle:@"_CodeSignature"]) {
        return YES;
    }

    if (![self _kai_fileExistInMainBundle:@"SC_Info"]) {
        return YES;
    }

    //if someone really want to crack your app, this method is useless..
    //you may change this method's name, encrypt the code and do more check..
    return NO;
}

- (BOOL)_kai_fileExistInMainBundle:(NSString *)name {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path       = [NSString stringWithFormat:@"%@/%@", bundlePath, name];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (NSString *)appBundleName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSString *)appBundleID {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

- (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)appBuildVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (BOOL)isBeingDebugged {
    size_t size = sizeof(struct kinfo_proc);
    struct kinfo_proc info;
    int ret = 0, name[4];
    memset(&info, 0, sizeof(struct kinfo_proc));

    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();

    if (ret == (sysctl(name, 4, &info, &size, NULL, 0))) {
        return ret != 0;
    }
    return (info.kp_proc.p_flag & P_TRACED) ? YES : NO;
}

- (int64_t)memoryUsage {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kern          = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kern != KERN_SUCCESS) return -1;
    return info.resident_size;
}

- (float)cpuUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;

    task_info_count = TASK_INFO_MAX;
    kr              = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }

    thread_array_t thread_list;
    mach_msg_type_number_t thread_count;

    thread_info_data_t thinfo;
    mach_msg_type_number_t thread_info_count;

    thread_basic_info_t basic_info_th;

    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }

    long tot_sec  = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;

    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr                = thread_info(thread_list[j], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }

        basic_info_th = (thread_basic_info_t)thinfo;

        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec  = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu  = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
        }
    }

    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);

    return tot_cpu;
}

- (BOOL)isRunningTestFlightBeta {
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSString *receiptURLString = [receiptURL path];
    BOOL isRunningTestFlightBeta =  ([receiptURLString rangeOfString:@"sandboxReceipt"].location != NSNotFound);
    return isRunningTestFlightBeta;
}

- (void)pushActiveNetworkOperation {
    @synchronized(self) {
        __internalOperationCount++;

#if !TARGET_OS_TV
        dispatch_async(dispatch_get_main_queue(), ^{

            if (!self.isNetworkActivityIndicatorVisible && __internalOperationCount) {
                self.networkActivityIndicatorVisible = YES;
            }
        });
#endif
    }
}

- (void)popActiveNetworkOperation {
    @synchronized(self) {
        if (__internalOperationCount == 0) {
            // nothing to do
            return;
        }

        __internalOperationCount--;
#if !TARGET_OS_TV
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isNetworkActivityIndicatorVisible && !__internalOperationCount) {
                self.networkActivityIndicatorVisible = NO;
            }
        });
#endif
    }
}

+ (BOOL)isAppExtension {
    static BOOL isAppExtension = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls                                                                          = NSClassFromString(@"UIApplication");
        if (!cls || ![cls respondsToSelector:@selector(sharedApplication)]) isAppExtension = YES;
        if ([[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) isAppExtension       = YES;
    });
    return isAppExtension;
}

+ (UIApplication *)sharedExtensionApplication {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    return [self isAppExtension] ? nil : [UIApplication performSelector:@selector(sharedApplication)];
#pragma clang diagnostic pop
}

+ (CGSize)applicationSize {
    /// applicationFrame 在 iPad 下返回的 size 要比 window 实际的 size 小，这个差值体现在 origin 上，所以用 origin + size 修正得到正确的大小。
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
#pragma clang diagnostic pop
    
    CGSize applicationSize = CGSizeMake(applicationFrame.size.width + applicationFrame.origin.x, applicationFrame.size.height + applicationFrame.origin.y);
    if (CGSizeEqualToSize(applicationSize, CGSizeZero)) {
        // 实测 MacCatalystApp 通过 [UIScreen mainScreen].applicationFrame 拿不到大小，这里做一下保护
        UIWindow *window = UIApplication.sharedApplication.delegate.window;
        if (window) {
            applicationSize = window.bounds.size;
        } else {
            applicationSize = UIWindow.new.bounds.size;
        }
    }
    return applicationSize;
}

@end
