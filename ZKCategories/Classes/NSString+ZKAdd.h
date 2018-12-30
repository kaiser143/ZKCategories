//
//  NSString+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/11/21.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ZKAdd)

- (BOOL)isValidURL;

/**
 * Parses a URL query string into a dictionary where the values are arrays.
 */
- (nullable NSDictionary *)dictionaryWithURLEncodedString;

/**
 * Parses a URL, adds query parameters to its query, and re-encodes it as a new URL.
 */
- (nonnull NSString *)stringByAddingQueryDictionary:(nullable NSDictionary *)query;

/**
 * Compares two strings expressing software versions.
 *
 * The comparison is (except for the development version provisions noted below) lexicographic
 * string comparison. So as long as the strings being compared use consistent version formats,
 * a variety of schemes are supported. For example "3.02" < "3.03" and "3.0.2" < "3.0.3". If you
 * mix such schemes, like trying to compare "3.02" and "3.0.3", the result may not be what you
 * expect.
 *
 * Development versions are also supported by adding an "a" character and more version info after
 * it. For example "3.0a1" or "3.01a4". The way these are handled is as follows: if the parts
 * before the "a" are different, the parts after the "a" are ignored. If the parts before the "a"
 * are identical, the result of the comparison is the result of NUMERICALLY comparing the parts
 * after the "a". If the part after the "a" is empty, it is treated as if it were "0". If one
 * string has an "a" and the other does not (e.g. "3.0" and "3.0a1") the one without the "a"
 * is newer.
 *
 * Examples (?? means undefined):
 *   "3.0" = "3.0"
 *   "3.0a2" = "3.0a2"
 *   "3.0" > "2.5"
 *   "3.1" > "3.0"
 *   "3.0a1" < "3.0"
 *   "3.0a1" < "3.0a4"
 *   "3.0a2" < "3.0a19"  <-- numeric, not lexicographic
 *   "3.0a" < "3.0a1"
 *   "3.02" < "3.03"
 *   "3.0.2" < "3.0.3"
 *   "3.00" ?? "3.0"
 *   "3.02" ?? "3.0.3"
 *   "3.02" ?? "3.0.2"
 */
- (NSComparisonResult)versionStringCompare:(nonnull NSString *)other;

#pragma mark URL

- (NSString *)stringByEscapingQueryParameters;
- (NSString *)stringByReplacingPercentEscapes;

- (nullable NSURL *)URL;
- (nullable NSURL *)URLRelativeToURL:(nullable NSURL *)baseURL;

#pragma mark - Java API

- (BOOL)contains:(nonnull NSString *)substring;
- (BOOL)startWith:(nonnull NSString *)substring;
- (BOOL)endWith:(nonnull NSString *)substring;
- (NSUInteger)indexOf:(nonnull NSString *)substring;
- (NSArray *)split:(nonnull NSString *)token;

/*!
 *    @brief    %1.0f Bytes", @"%1.1f KB", @"%1.1f MB", @"%1.1f GB", @"%1.1f TB
 */
+ (NSString *)stringByFormattingBytes:(long long)bytes;


@end


@interface NSString (ZKUTI)

/**-------------------------------------------------------------------------------------
 @name Working with UTIs
 ---------------------------------------------------------------------------------------
 */

/**
 Method to get the recommended MIME-Type for the given file extension. If no MIME-Type can be determined then 'application/octet-stream' is returned.
 @param extension the file extension
 @return the recommended MIME-Type for the given path extension.
 */
+ (NSString *)MIMETypeForFileExtension:(NSString *)extension;


/**
 Method to get the official description for a given file extension.
 @param extension the file extension
 @return the description
 */
+ (NSString *)fileTypeDescriptionForFileExtension:(NSString *)extension;


/**
 Method to get the preferred UTI for a given file extension.
 @param extension the file extension
 @return the UTI
 */
+ (NSString *)universalTypeIdentifierForFileExtension:(NSString *)extension;

/**
 Get the prefered file extension for a given UTI.
 @param UTI he UTI
 @returns The File Extension
 */
+ (NSString *)fileExtensionForUniversalTypeIdentifier:(NSString *)UTI;

/**
 Tests if the receiver conforms to a given UTI.
 @param conformingUTI the UTI that is tested against
 @return `YES` if the receiver conforms
 */
- (BOOL)conformsToUniversalTypeIdentifier:(NSString *)conformingUTI;

/**
 @returns `YES` if the receiver is a movie file name
 */
- (BOOL)isMovieFileName;

/**
 @Returns `YES` if the receiver is an audio file name
 */
- (BOOL)isAudioFileName;

/**
 @Returns `YES` if the receiver is an image file name
 */
- (BOOL)isImageFileName;

/**
 @Returns `YES` if the receiver is an HTML file name
 */
- (BOOL)isHTMLFileName;

@end

NS_ASSUME_NONNULL_END
