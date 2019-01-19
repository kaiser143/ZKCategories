//
//  UIButton+ZKAdd.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/1/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (ZKAdd)

/**
 *  @brief  设置按钮额外热区
 */
@property(nonatomic, assign) UIEdgeInsets touchAreaInsets;

@end

NS_ASSUME_NONNULL_END
