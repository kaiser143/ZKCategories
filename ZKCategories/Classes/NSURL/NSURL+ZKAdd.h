//
//  NSURL+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (ZKAdd)

/** 返回在 App Store 中打开该应用页面的 URL。
 
 URL 构造参见 [QA1629](https://developer.apple.com/library/ios/#qa/qa2008/qa1629.html)。实测即使不带 itms: 或 itms-apps: scheme 也可直接打开 App Store。此类 URL 也可用于在非 iOS 设备上跳转应用链接。
 
 @param identifier 在 iTunes Connect 中添加应用时分配的应用标识。
 @return 直达 App Store 应用页的 URL
 */
+ (NSURL *)appStoreURLforApplicationIdentifier:(NSString *)identifier;


/** 返回在 App Store 中打开该应用评价页的 URL。
 
 评价页为 appStoreURLforApplicationIdentifier: 返回的应用落地页的子页面。
 
 @param identifier 在 iTunes Connect 中添加应用时分配的应用标识。
 @return 直达 App Store 应用评价页的 URL
 */
+ (NSURL *)appStoreReviewURLForApplicationIdentifier:(NSString *)identifier;

- (NSDictionary *)queryParameters;
- (NSURL *)URLByAppendingString:(NSString *)string;
- (NSURL *)URLByAppendingQueryParameters:(NSDictionary *)parameters;

@end


@interface NSURL (ZKComparing)

/**
 将接收者与另一 URL 比较。
 @param URL 另一 URL
 @return 若接收者与传入 URL 等价则返回 `YES`
 */
- (BOOL)isEqualToURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
