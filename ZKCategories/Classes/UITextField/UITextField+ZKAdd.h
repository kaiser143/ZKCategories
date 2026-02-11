//
//  UITextField+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 为 `UITextField` 提供扩展。
 */
@interface UITextField (ZKAdd)

@property (nonatomic, copy) BOOL (^shouldBegindEditingBlock)(UITextField *textField);
@property (nonatomic, copy) BOOL (^shouldEndEditingBlock)(UITextField *textField);
@property (nonatomic, copy) void (^didBeginEditingBlock)(UITextField *textField);
@property (nonatomic, copy) void (^didEndEditingBlock)(UITextField *textField);
@property (nonatomic, copy) BOOL (^shouldChangeCharactersInRangeBlock)(UITextField *textField, NSRange range, NSString *replacementString);
@property (nonatomic, copy) BOOL (^shouldReturnBlock)(UITextField *textField);
@property (nonatomic, copy) BOOL (^shouldClearBlock)(UITextField *textField);

- (void)setShouldBegindEditingBlock:(BOOL (^)(UITextField *textField))shouldBegindEditingBlock;
- (void)setShouldEndEditingBlock:(BOOL (^)(UITextField *textField))shouldEndEditingBlock;
- (void)setDidBeginEditingBlock:(void (^)(UITextField *textField))didBeginEditingBlock;
- (void)setDidEndEditingBlock:(void (^)(UITextField *textField))didEndEditingBlock;
- (void)setShouldChangeCharactersInRangeBlock:(BOOL (^)(UITextField *textField, NSRange range, NSString *string))shouldChangeCharactersInRangeBlock;
- (void)setShouldClearBlock:(BOOL (^)(UITextField *textField))shouldClearBlock;
- (void)setShouldReturnBlock:(BOOL (^)(UITextField *textField))shouldReturnBlock;

/**
 *  @brief  当前选中的字符串范围
 */
- (NSRange)selectedRange;

/**
 选中全部文字。
 */
- (void)selectAllText;

/**
 选中指定范围的文字。
 
 @param range 要选中的文字在文档中的范围。
 */
- (void)setSelectedRange:(NSRange)range;

/**
 * 将 UITextRange 转为 NSRange，例如 [self convertNSRangeFromUITextRange:self.markedTextRange]
 */
- (NSRange)convertNSRangeFromUITextRange:(UITextRange *)textRange;

/**
 * 将 NSRange 转为 UITextRange
 *  @return range 无效时返回 nil。
 */
- (nullable UITextRange *)convertUITextRangeFromNSRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
