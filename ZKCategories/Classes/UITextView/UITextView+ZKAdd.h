//
//  UITextView+ZKAdd.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/1/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (ZKAdd)

@property (nonatomic) CGFloat maxFontSize, minFontSize;

@property (nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;

/**
 *  @brief  当前选中的字符串范围
 *
 *  @return NSRange
 */
- (NSRange)selectedRange;

/**
 *  @brief  选中所有文字
 */
- (void)selectAllText;

/**
 *  @brief  选中指定范围的文字
 *
 *  @param range NSRange范围
 */
- (void)setSelectedRange:(NSRange)range;

// 用于计算textview输入情况下的字符数，解决实现限制字符数时，计算不准的问题
- (NSInteger)getInputLengthWithText:(NSString *)text;

/**
 *  convert UITextRange to NSRange, for example, [self convertNSRangeFromUITextRange:self.markedTextRange]
 */
- (NSRange)convertNSRangeFromUITextRange:(UITextRange *)textRange;

/**
 *  convert NSRange to UITextRange
 *  @return return nil if range is invalidate.
 */
- (nullable UITextRange *)convertUITextRangeFromNSRange:(NSRange)range;

/**
 [UITextView scrollRangeToVisible:] 并不会考虑 textContainerInset.bottom，所以使用这个方法来代替

 @param range 要滚动到的文字区域，如果 range 非法则什么都不做
 */
- (void)scrollRangeToVisible:(NSRange)range;

/**
 * 将光标滚到可视区域
 */
- (void)scrollCaretVisibleAnimated:(BOOL)animated;

/*
 * @code
 - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSInteger textLength = [textView getInputLengthWithText:text];
    if (textLength > 20) {
        //超过20个字可以删除
        if ([text isEqualToString:@""]) {
            return YES;
        }
        return NO;
    }
    return YES;
 }

 - (void)textViewDidChange:(UITextView *)textView {
    if ([textView getInputLengthWithText:nil] > 20) {
        textView.text = [textView.text substringToIndex:20];
    }
 }
 * @endcode
 */

@end

NS_ASSUME_NONNULL_END
