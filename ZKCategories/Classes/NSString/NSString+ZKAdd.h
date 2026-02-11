//
//  NSString+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/11/21.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZKCategoriesMacro.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ZKAdd)

- (BOOL)isValidURL;

/**
 * 将 URL 查询字符串解析为字典，值为数组。
 */
- (nullable NSDictionary *)dictionaryWithURLEncodedString;

/**
 * 解析 URL，向其查询部分添加参数，并重新编码为新 URL 字符串。
 */
- (nonnull NSString *)stringByAddingQueryDictionary:(nullable NSDictionary *)query;

/**
 * 比较两个表示软件版本的字符串。
 *
 * 除下述开发版规则外，按字典序比较。只要格式一致即可支持多种写法，如 "3.02" < "3.03"、
 * "3.0.2" < "3.0.3"。若混用格式（如 "3.02" 与 "3.0.3"），结果可能不符合预期。
 *
 * 支持在版本号后加 "a" 表示开发版，如 "3.0a1"、"3.01a4"。规则："a" 前不同则忽略 "a" 后部分；
 * "a" 前相同则按 "a" 后部分的数值比较；"a" 后为空视为 "0"；无 "a" 的比有 "a" 的更新（如 "3.0" > "3.0a1"）。
 *
 * 示例（?? 表示未定义）：
 *   "3.0" = "3.0"
 *   "3.0a2" = "3.0a2"
 *   "3.0" > "2.5"
 *   "3.1" > "3.0"
 *   "3.0a1" < "3.0"
 *   "3.0a1" < "3.0a4"
 *   "3.0a2" < "3.0a19"  <-- 按数值非字典序
 *   "3.0a" < "3.0a1"
 *   "3.02" < "3.03"
 *   "3.0.2" < "3.0.3"
 *   "3.00" ?? "3.0"
 *   "3.02" ?? "3.0.3"
 *   "3.02" ?? "3.0.2"
 */
- (NSComparisonResult)versionStringCompare:(NSString *)other ZK_API_DEPRECATED(ZKVersion);

#pragma mark - :. URL

- (NSString *)stringByURLEncoding NS_SWIFT_NAME(URLEncoding());
- (NSString *)stringByEscapingQueryParameters NS_SWIFT_NAME(escapingQueryParameters());
- (NSString *)stringByReplacingPercentEscapes NS_SWIFT_NAME(replacingPercentEscapes());

- (nullable NSURL *)URL;
- (nullable NSURL *)URLRelativeToURL:(nullable NSURL *)baseURL;

#pragma mark - :. Java API

- (BOOL)contains:(NSString *)substring NS_SWIFT_UNAVAILABLE("");
- (BOOL)startWith:(NSString *)substring;
- (BOOL)endWith:(NSString *)substring;
- (NSUInteger)indexOf:(NSString *)substring;
- (NSArray *)split:(NSString *)token;

/*!
 *    @brief    %1.0f Bytes", @"%1.1f KB", @"%1.1f MB", @"%1.1f GB", @"%1.1f TB
 */
+ (NSString *)stringByFormattingBytes:(long long)bytes NS_SWIFT_NAME(formatting(bytes:));

/*!
 *  @brief    字符串字节长度
 */
- (NSInteger)byteLength;

/**
 *  按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
 */
- (NSUInteger)lengthWhenCountingNonASCIICharacterAsTwo;

#pragma mark - :. Hash
///=============================================================================
/// @name Hash
///=============================================================================

/**
 返回 md2 哈希的小写 NSString。
 */
- (nullable NSString *)md2String;

/**
 返回 md4 哈希的小写 NSString。
 */
- (nullable NSString *)md4String;

/**
 返回 md5 哈希的小写 NSString。
 */
- (nullable NSString *)md5String;

/**
 返回 sha1 哈希的小写 NSString。
 */
- (nullable NSString *)sha1String;

/**
 返回 sha224 哈希的小写 NSString。
 */
- (nullable NSString *)sha224String;

/**
 返回 sha256 哈希的小写 NSString。
 */
- (nullable NSString *)sha256String;

/**
 返回 sha384 哈希的小写 NSString。
 */
- (nullable NSString *)sha384String;

/**
 返回 sha512 哈希的小写 NSString。
 */
- (nullable NSString *)sha512String;

/**
 使用 key 对内容做 hmac-md5，返回小写 NSString。
 @param key hmac 密钥。
 */
- (nullable NSString *)hmacMD5StringWithKey:(NSString *)key;

/**
 使用 key 对内容做 hmac-sha1，返回小写 NSString。
 @param key hmac 密钥。
 */
- (nullable NSString *)hmacSHA1StringWithKey:(NSString *)key;

/**
 使用 key 对内容做 hmac-sha224，返回小写 NSString。
 @param key hmac 密钥。
 */
- (nullable NSString *)hmacSHA224StringWithKey:(NSString *)key;

/**
 使用 key 对内容做 hmac-sha256，返回小写 NSString。
 @param key hmac 密钥。
 */
- (nullable NSString *)hmacSHA256StringWithKey:(NSString *)key;

/**
 使用 key 对内容做 hmac-sha384，返回小写 NSString。
 @param key hmac 密钥。
 */
- (nullable NSString *)hmacSHA384StringWithKey:(NSString *)key;

/**
 使用 key 对内容做 hmac-sha512，返回小写 NSString。
 @param key hmac 密钥。
 */
- (nullable NSString *)hmacSHA512StringWithKey:(NSString *)key;

/**
 返回 crc32 哈希的小写 NSString。
 */
- (nullable NSString *)crc32String;

#pragma mark - :. Encode and decode
///=============================================================================
/// @name Encode and decode
///=============================================================================

/**
 返回当前字符串的 base64 编码 NSString。
 */
- (nullable NSString *)base64EncodedString;

/**
 从 base64 编码字符串解析出 NSString。
 @param base64EncodedString 已编码的字符串。
 */
+ (nullable NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString;

/**
 按 UTF-8 进行 URL 编码。
 @return 编码后的字符串。
 */
- (NSString *)stringByURLEncode NS_SWIFT_NAME(URLEncode());

/**
 按 UTF-8 进行 URL 解码。
 @return 解码后的字符串。
 */
- (NSString *)stringByURLDecode NS_SWIFT_NAME(URLDecode());

/**
 将常见 HTML 字符转义为实体。例如 "a < b" -> "a&lt;b"。
 */
- (NSString *)stringByEscapingHTML NS_SWIFT_NAME(escapingHTML());

#pragma mark - :. Drawing
///=============================================================================
/// @name Drawing
///=============================================================================

/**
 在给定约束下绘制时字符串的尺寸。
 
 @param font          用于计算的字体。
 @param size          字符串允许的最大尺寸，用于计算换行与折行。
 @param lineBreakMode 换行方式，参见 NSLineBreakMode。
 @return              绘制后边界框的宽高，可能向上取整。
 */
- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

/**
 使用指定字体单行绘制时的字符串宽度。
 
 @param font  用于计算宽度的字体。
 @return      绘制后边界框的宽度，可能向上取整。
 */
- (CGFloat)widthForFont:(UIFont *)font;

/**
 在给定宽度约束下绘制时字符串的高度。
 
 @param font  用于计算的字体。
 @param width 字符串允许的最大宽度，用于计算换行与折行。
 @return      绘制后边界框的高度，可能向上取整。
 */
- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width;

#pragma mark - :. Regular Expression
///=============================================================================
/// @name Regular Expression
///=============================================================================

/**
 是否能匹配该正则表达式。
 
 @param regex   正则表达式。
 @param options 匹配选项。
 @return 能匹配返回 YES，否则 NO。
 */
- (BOOL)matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options;

/**
 匹配正则并在每个匹配上执行 block。
 
 @param regex   正则表达式。
 @param options 匹配选项。
 @param block   对每个匹配调用的 block。参数：match 匹配子串，matchRange 匹配范围，
 stop 可设为 YES 以停止后续枚举（仅应在 block 内设为 YES）。
 */
- (void)enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block;

/**
 将匹配正则的部分替换为模板字符串，返回新字符串。
 
 @param regex       正则表达式。
 @param options     匹配选项。
 @param replacement 替换模板。
 @return 替换后的新字符串。
 */
- (NSString *)stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                          withString:(NSString *)replacement;

#pragma mark - :. NSNumber Compatible
///=============================================================================
/// @name 与 NSNumber 兼容
///=============================================================================

// 可将 NSString 当作 NSNumber 使用（通过下列属性取值）。
@property (readonly) char charValue;
@property (readonly) unsigned char unsignedCharValue;
@property (readonly) short shortValue;
@property (readonly) unsigned short unsignedShortValue;
@property (readonly) unsigned int unsignedIntValue;
@property (readonly) long longValue;
@property (readonly) unsigned long unsignedLongValue;
@property (readonly) unsigned long long unsignedLongLongValue;
@property (readonly) NSUInteger unsignedIntegerValue;

#pragma mark - :. Utilities
///=============================================================================
/// @name Utilities
///=============================================================================

/**
 返回新的 UUID 字符串，例如 "D1178E50-2A4D-4F1F-9BD3-F6AAB00E06B1"。
 */
+ (NSString *)UUIDString;

/**
 根据给定的 UTF-32 字符生成字符串。
 
 @param char32 一个 UTF-32 字符。
 @return 新字符串，字符无效时返回 nil。
 */
+ (NSString *)stringWithUTF32Char:(UTF32Char)char32;

/**
 根据给定的 UTF-32 字符数组生成字符串。
 
 @param char32  UTF-32 字符数组。
 @param length  数组中的字符个数。
 @return 新字符串，出错时返回 nil。
 */
+ (NSString *)stringWithUTF32Chars:(const UTF32Char *)char32 length:(NSUInteger)length;

/**
 枚举字符串指定范围内的 Unicode 字符（UTF-32）。
 
 @param range 要枚举的范围。
 @param block 每个字符调用的 block。参数：char32 为 Unicode 字符；range 为在接收者中的范围
 （length 为 1 表示 BMP 字符，为 2 表示非 BMP 平面字符，由代理对表示）；stop 设为 YES 可停止枚举。
 */
- (void)enumerateUTF32CharInRange:(NSRange)range usingBlock:(void (^)(UTF32Char char32, NSRange range, BOOL *stop))block;

/**
 去除首尾空白（空格与换行）。
 @return 去除后的字符串。
 */
- (NSString *)stringByTrim NS_SWIFT_NAME(trim());

/**
 在文件名（不含扩展名）后添加 scale 修饰，如 @"name" -> @"name@2x"。
 
 @param scale 资源 scale。
 @return 添加 scale 后的字符串；若末尾不是文件名则返回原字符串。
 */
- (NSString *)stringByAppendingNameScale:(CGFloat)scale;

/**
 在文件路径（含扩展名）中添加 scale 修饰，如 @"name.png" -> @"name@2x.png"。
 
 @param scale 资源 scale。
 @return 添加 scale 后的字符串；若末尾不是文件名则返回原字符串。
 */
- (NSString *)stringByAppendingPathScale:(CGFloat)scale;

/**
 返回路径中的 scale。如 "icon.png" -> 1，"icon@2x.png" -> 2，"icon@2.5x.png" -> 2.5 等。
 */
- (CGFloat)pathScale;

/**
 nil、@""、@"  "、@"\n" 返回 NO；否则返回 YES。
 */
- (BOOL)isNotBlank;

/**
 若接收者包含目标字符串则返回 YES。
 @param string 要检测的字符串。
 
 @discussion Apple 在 iOS8 中已提供此方法。
 */
- (BOOL)containsString:(NSString *)string;

/**
 若接收者包含目标字符集中任意字符则返回 YES。
 @param set 要检测的字符集。
 */
- (BOOL)containsCharacterSet:(NSCharacterSet *)set;

/**
 尝试将字符串解析为 NSNumber。
 @return 解析成功返回 NSNumber，失败返回 nil。
 */
- (NSNumber *)numberValue;

/**
 按 UTF-8 编码返回 NSData。
 */
- (NSData *)dataValue;

/**
 返回 NSMakeRange(0, self.length)。
 */
- (NSRange)rangeOfAll;

/**
 将接收者按 JSON 解析为 NSDictionary 或 NSArray，解析失败返回 nil。
 
 例如 @"{\"name\":\"a\",\"count\":2}" => @{@"name":@"a", @"count":@2}
 */
- (id)jsonValueDecoded;

/**
 从主 bundle 中按文件名读取内容并创建字符串（类似 [UIImage imageNamed:]）。
 
 @param name 文件名（位于 main bundle）。
 @return 按 UTF-8 读取得到的新字符串。
 */
+ (NSString *)stringNamed:(NSString *)name;

/** 在路径末尾追加或递增括号中的序号。
 若已有数字后缀则递增，否则追加 (1)。
 @return 递增后的路径。
 */
- (NSString *_Nonnull)pathByIncrementingSequenceNumber;

/** 移除路径末尾括号中的序号。
 若有数字后缀则移除，否则返回接收者本身。
 @return 修改后的路径。
 */
- (NSString *_Nonnull)pathByDeletingSequenceNumber;

- (NSMutableAttributedString *)mutableAttributedString;
- (NSMutableAttributedString *)mutableAttributedStringWithAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs;

/**
 *  将字符串里指定 range 的子字符串裁剪出来，会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
 *
 *  例如对于字符串“😊😞”，它的长度为4，在 lessValue 模式下，裁剪 (0, 1) 得到的是空字符串，裁剪 (0, 2) 得到的是“😊”。
 *  在非 lessValue 模式下，裁剪 (0, 1) 或 (0, 2)，得到的都是“😊”。
 *
 *  @param range 要裁剪的文字位置
 *  @param lessValue 裁剪时若遇到“character sequences”，是向下取整还是向上取整（系统的 rangeOfComposedCharacterSequencesForRange: 会尽量把给定 range 里包含的所有 character sequences 都包含在内，也即 lessValue = NO）。
 *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
 *  @return 裁剪完的字符
 */
- (nullable instancetype)substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;

/**
 *  相当于 `substringAvoidBreakingUpCharacterSequencesWithRange:lessValue:YES` countingNonASCIICharacterAsTwo:NO
 *  @see substringAvoidBreakingUpCharacterSequencesWithRange:lessValue:countingNonASCIICharacterAsTwo:
 */
- (nullable instancetype)substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range;

/// 把当前文本的第一个字符改为大写，其他的字符保持不变，例如 backgroundView.kai_capitalizedString -> BackgroundView（系统的 capitalizedString 会变成 Backgroundview）
@property(nullable, readonly, copy) NSString *kai_capitalizedString;

@end

@interface NSString (ZKUTI)

/**-------------------------------------------------------------------------------------
 @name 与 UTI 相关
 ---------------------------------------------------------------------------------------
 */

/**
 根据文件扩展名返回推荐的 MIME 类型。无法确定时返回 'application/octet-stream'。
 @param extension 文件扩展名。
 @return 该扩展名推荐的 MIME 类型。
 */
+ (NSString *)MIMETypeForFileExtension:(NSString *)extension;

/**
 根据文件扩展名返回官方描述。
 @param extension 文件扩展名。
 @return 描述字符串。
 */
+ (NSString *)fileTypeDescriptionForFileExtension:(NSString *)extension;

/**
 根据文件扩展名返回首选 UTI。
 @param extension 文件扩展名。
 @return UTI 字符串。
 */
+ (NSString *)universalTypeIdentifierForFileExtension:(NSString *)extension;

/**
 根据 UTI 返回首选文件扩展名。
 @param UTI UTI 字符串。
 @returns 文件扩展名。
 */
+ (NSString *)fileExtensionForUniversalTypeIdentifier:(NSString *)UTI;

/**
 判断接收者是否符合给定的 UTI。
 @param conformingUTI 要对比的 UTI。
 @return 符合返回 `YES`。
 */
- (BOOL)conformsToUniversalTypeIdentifier:(NSString *)conformingUTI;

/**
 接收者是否为电影文件名时返回 `YES`。
 */
- (BOOL)isMovieFileName;

/**
 接收者是否为音频文件名时返回 `YES`。
 */
- (BOOL)isAudioFileName;

/**
 接收者是否为图片文件名时返回 `YES`。
 */
- (BOOL)isImageFileName;

/**
 接收者是否为 HTML 文件名时返回 `YES`。
 */
- (BOOL)isHTMLFileName;


/// 把参数列表拼接成一个字符串并返回，相当于用另一种语法来代替 [NSString stringWithFormat:]
+ (NSString *)stringByConcat:(id)firstArgv, ...;

@end

NS_ASSUME_NONNULL_END
