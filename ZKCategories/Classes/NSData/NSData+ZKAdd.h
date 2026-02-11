//
//  NSData+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (ZKAdd)

#pragma mark - :. Hash
///=============================================================================
/// @name Hash
///=============================================================================

/**
 返回 md2 哈希的小写 NSString。
 */
- (NSString *)md2String;

/**
 返回 md2 哈希的 NSData。
 */
- (NSData *)md2Data;

/**
 返回 md4 哈希的小写 NSString。
 */
- (NSString *)md4String;

/**
 返回 md4 哈希的 NSData。
 */
- (NSData *)md4Data;

/**
 返回 md5 哈希的小写 NSString。
 */
- (NSString *)md5String;

/**
 返回 md5 哈希的 NSData。
 */
- (NSData *)md5Data;

/**
 返回 sha1 哈希的小写 NSString。
 */
- (NSString *)sha1String;

/**
 返回 sha1 哈希的 NSData。
 */
- (NSData *)sha1Data;

/**
 返回 sha224 哈希的小写 NSString。
 */
- (NSString *)sha224String;

/**
 返回 sha224 哈希的 NSData。
 */
- (NSData *)sha224Data;

/**
 返回 sha256 哈希的小写 NSString。
 */
- (NSString *)sha256String;

/**
 返回 sha256 哈希的 NSData。
 */
- (NSData *)sha256Data;

/**
 返回 sha384 哈希的小写 NSString。
 */
- (NSString *)sha384String;

/**
 返回 sha384 哈希的 NSData。
 */
- (NSData *)sha384Data;

/**
 返回 sha512 哈希的小写 NSString。
 */
- (NSString *)sha512String;

/**
 返回 sha512 哈希的 NSData。
 */
- (NSData *)sha512Data;

/**
 使用 key 做 hmac-md5，返回小写 NSString。
 @param key hmac 密钥。
 */
- (NSString *)hmacMD5StringWithKey:(NSString *)key;

/**
 使用 key 做 hmac-md5，返回 NSData。
 @param key hmac 密钥。
 */
- (NSData *)hmacMD5DataWithKey:(NSData *)key;

/**
 使用 key 做 hmac-sha1，返回小写 NSString。
 @param key hmac 密钥。
 */
- (NSString *)hmacSHA1StringWithKey:(NSString *)key;

/**
 使用 key 做 hmac-sha1，返回 NSData。
 @param key hmac 密钥。
 */
- (NSData *)hmacSHA1DataWithKey:(NSData *)key;

/**
 使用 key 做 hmac-sha224，返回小写 NSString。
 @param key hmac 密钥。
 */
- (NSString *)hmacSHA224StringWithKey:(NSString *)key;

/**
 使用 key 做 hmac-sha224，返回 NSData。
 @param key hmac 密钥。
 */
- (NSData *)hmacSHA224DataWithKey:(NSData *)key;

/**
 使用 key 做 hmac-sha256，返回小写 NSString。
 @param key hmac 密钥。
 */
- (NSString *)hmacSHA256StringWithKey:(NSString *)key;

/**
 使用 key 做 hmac-sha256，返回 NSData。
 @param key hmac 密钥。
 */
- (NSData *)hmacSHA256DataWithKey:(NSData *)key;

/**
 使用 key 做 hmac-sha384，返回小写 NSString。
 @param key hmac 密钥。
 */
- (NSString *)hmacSHA384StringWithKey:(NSString *)key;

/**
 使用 key 做 hmac-sha384，返回 NSData。
 @param key hmac 密钥。
 */
- (NSData *)hmacSHA384DataWithKey:(NSData *)key;

/**
 使用 key 做 hmac-sha512，返回小写 NSString。
 @param key hmac 密钥。
 */
- (NSString *)hmacSHA512StringWithKey:(NSString *)key;

/**
 使用 key 做 hmac-sha512，返回 NSData。
 @param key hmac 密钥。
 */
- (NSData *)hmacSHA512DataWithKey:(NSData *)key;

/**
 返回 crc32 哈希的小写 NSString。
 */
- (NSString *)crc32String;

/**
 返回 crc32 哈希值。
 */
- (uint32_t)crc32;

#pragma mark - :. Encrypt and Decrypt
///=============================================================================
/// @name Encrypt and Decrypt
///=============================================================================

/**
 使用 AES 加密，返回加密后的 NSData。
 
 @param key 密钥长度 16、24 或 32 字节（128、192 或 256 位）。
 @param iv  初始向量长度 16 字节（128 位），不使用可传 nil。
 @return 加密后的 NSData，失败返回 nil。
 */
- (nullable NSData *)aes256EncryptWithKey:(NSData *)key iv:(nullable NSData *)iv;

/**
 使用 AES 解密，返回解密后的 NSData。
 
 @param key 密钥长度 16、24 或 32 字节（128、192 或 256 位）。
 @param iv  初始向量长度 16 字节（128 位），未使用可传 nil。
 @return 解密后的 NSData，失败返回 nil。
 */
- (nullable NSData *)aes256DecryptWithkey:(NSData *)key iv:(nullable NSData *)iv;

#pragma mark - :. Encode and decode
///=============================================================================
/// @name Encode and decode
///=============================================================================

/**
 按 UTF-8 解码返回字符串。
 */
- (nullable NSString *)utf8String;

/**
 返回大写的十六进制 NSString。
 */
- (nullable NSString *)hexString;

/**
 从十六进制字符串生成 NSData（大小写不敏感）。
 
 @param hexString 十六进制字符串。
 @return 新 NSData，失败返回 nil。
 */
+ (nullable NSData *)dataWithHexString:(NSString *)hexString;

/**
 返回 base64 编码后的 NSString。
 */
- (nullable NSString *)base64EncodedString;

/**
 从 base64 编码字符串解析出 NSData。
 
 @warning iOS7 已提供系统实现。
 
 @param base64EncodedString 已编码的字符串。
 */
+ (nullable NSData *)dataWithBase64EncodedString:(NSString *)base64EncodedString;

/**
 将 self 按 JSON 解析为 NSDictionary 或 NSArray，失败返回 nil。
 */
- (nullable id)jsonValueDecoded;

#pragma mark - :. Inflate and deflate
///=============================================================================
/// @name Inflate and deflate
///=============================================================================

/**
 对 gzip 压缩数据解压。
 @return 解压后的数据。
 */
- (nullable NSData *)gzipInflate;

/**
 使用默认压缩级别将数据压缩为 gzip 格式。
 @return 压缩后的数据。
 */
- (nullable NSData *)gzipDeflate;

/**
 对 zlib 压缩数据解压。
 @return 解压后的数据。
 */
- (nullable NSData *)zlibInflate;

/**
 使用默认压缩级别将数据压缩为 zlib 格式。
 @return 压缩后的数据。
 */
- (nullable NSData *)zlibDeflate;

#pragma mark - :. Others
///=============================================================================
/// @name Others
///=============================================================================

/**
 从 main bundle 中按文件名读取并创建 NSData（类似 [UIImage imageNamed:]）。
 
 @param name 文件名（位于 main bundle）。
 @return 从文件读取得到的新 NSData。
 */
+ (nullable NSData *)dataNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
