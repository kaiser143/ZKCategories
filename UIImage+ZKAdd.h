//
//  UIImage+ZKAdd.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2018/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ZKAdd)

/*!
 *    @brief    压缩图片质量达到指定大小
 *    @param    maxLength     压缩后图片大小小于这个值
 */
- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength;

/*!
 *    @brief    通过压缩图片尺寸来达到图片指定大小
 *    @param    maxLength     压缩后图片大小小于这个值
 */
- (NSData *)compressBySizeWithMaxLength:(NSUInteger)maxLength;

@end

NS_ASSUME_NONNULL_END
