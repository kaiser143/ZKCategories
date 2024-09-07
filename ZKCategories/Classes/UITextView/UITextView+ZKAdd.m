//
//  UITextView+ZKAdd.m
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/1/14.
//

#import "UITextView+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "ZKCGUtilities.h"
#import "UIScrollView+ZKAdd.h"

static void *minFontSizeKey = &minFontSizeKey;
static void *maxFontSizeKey = &maxFontSizeKey;
static void *zoomEnabledKey = &zoomEnabledKey;

@implementation UITextView (ZKAdd)

- (NSRange)selectedRange {
    UITextPosition *beginning = self.beginningOfDocument;

    UITextRange *selectedRange     = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd   = selectedRange.end;

    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length   = [self offsetFromPosition:selectionStart toPosition:selectionEnd];

    return NSMakeRange(location, length);
}

- (void)selectAllText {
    UITextRange *range = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}

- (void)setSelectedRange:(NSRange)range {
    UITextPosition *beginning     = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition   = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange   = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}

- (NSInteger)getInputLengthWithText:(NSString *)text {
    NSInteger textLength = 0;
    //获取高亮部分
    UITextRange *selectedRange = [self markedTextRange];
    if (selectedRange) {
        NSString *newText = [self textInRange:selectedRange];
        textLength        = (newText.length + 1) / 2 + [self offsetFromPosition:self.beginningOfDocument toPosition:selectedRange.start] + text.length;
    } else {
        textLength = self.text.length + text.length;
    }
    return textLength;
}

- (void)setMaxFontSize:(CGFloat)maxFontSize {
    [self setAssociateValue:@(maxFontSize) withKey:maxFontSizeKey];
}

- (CGFloat)maxFontSize {
    return [[self associatedValueForKey:maxFontSizeKey] floatValue];
}

- (void)setMinFontSize:(CGFloat)maxFontSize {
    [self setAssociateValue:@(maxFontSize) withKey:minFontSizeKey];
}

- (CGFloat)minFontSize {
    return [[self associatedValueForKey:minFontSizeKey] floatValue];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
    if (!self.isZoomEnabled) return;

    CGFloat pointSize = (gestureRecognizer.velocity > 0.0f ? 1.0f : -1.0f) + self.font.pointSize;

    pointSize = MAX(MIN(pointSize, self.maxFontSize), self.minFontSize);

    self.font = [UIFont fontWithName:self.font.fontName size:pointSize];
}

- (void)setZoomEnabled:(BOOL)zoomEnabled {
    [self setAssociateValue:@(zoomEnabled) withKey:zoomEnabledKey];

    if (zoomEnabled) {
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers) // initialized already
            if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) return;

        self.minFontSize                          = self.minFontSize ?: 8.0f;
        self.maxFontSize                          = self.maxFontSize ?: 42.0f;
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(pinchGesture:)];
        [self addGestureRecognizer:pinchRecognizer];
#if !__has_feature(objc_arc)
        [pinchRecognizer release];
#endif
    }
}

- (BOOL)isZoomEnabled {
    return [[self associatedValueForKey:zoomEnabledKey] boolValue];
}

- (NSRange)convertNSRangeFromUITextRange:(UITextRange *)textRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:textRange.start];
    NSInteger length = [self offsetFromPosition:textRange.start toPosition:textRange.end];
    return NSMakeRange(location, length);
}

- (UITextRange *)convertUITextRangeFromNSRange:(NSRange)range {
    if (range.location == NSNotFound || NSMaxRange(range) > self.text.length) {
        return nil;
    }
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    return [self textRangeFromPosition:startPosition toPosition:endPosition];
}

- (void)scrollRangeToVisible:(NSRange)range {
    if (CGRectIsEmpty(self.bounds)) return;
    
    UITextRange *textRange = [self convertUITextRangeFromNSRange:range];
    if (!textRange) return;
    
    NSArray<UITextSelectionRect *> *selectionRects = [self selectionRectsForRange:textRange];
    CGRect rect = CGRectZero;
    for (UITextSelectionRect *selectionRect in selectionRects) {
        if (!CGRectIsEmpty(selectionRect.rect)) {
            if (CGRectIsEmpty(rect)) {
                rect = selectionRect.rect;
            } else {
                rect = CGRectUnion(rect, selectionRect.rect);
            }
        }
    }
    if (!CGRectIsEmpty(rect)) {
        rect = [self convertRect:rect fromView:self.textInputView];
        [self _scrollRectToVisible:rect animated:YES];
    }
}

- (void)scrollCaretVisibleAnimated:(BOOL)animated {
    if (CGRectIsEmpty(self.bounds)) return;
    
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
    [self _scrollRectToVisible:caretRect animated:animated];
}

- (void)_scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    // scrollEnabled 为 NO 时可能产生不合法的 rect 值 https://github.com/Tencent/QMUI_iOS/issues/205
    if (!CGRectIsValidated(rect)) {
        return;
    }
    
    CGFloat contentOffsetY = self.contentOffset.y;
    
    BOOL canScroll = self.canScroll;
    if (canScroll) {
        if (CGRectGetMinY(rect) < contentOffsetY + self.textContainerInset.top) {
            // 光标在可视区域上方，往下滚动
            contentOffsetY = CGRectGetMinY(rect) - self.textContainerInset.top - self.adjustedContentInset.top;
        } else if (CGRectGetMaxY(rect) > contentOffsetY + CGRectGetHeight(self.bounds) - self.textContainerInset.bottom - self.adjustedContentInset.bottom) {
            // 光标在可视区域下方，往上滚动
            contentOffsetY = CGRectGetMaxY(rect) - CGRectGetHeight(self.bounds) + self.textContainerInset.bottom + self.adjustedContentInset.bottom;
        } else {
            // 光标在可视区域，不用滚动
        }
        CGFloat contentOffsetWhenScrollToTop = -self.adjustedContentInset.top;
        CGFloat contentOffsetWhenScrollToBottom = self.contentSize.height + self.adjustedContentInset.bottom - CGRectGetHeight(self.bounds);
        contentOffsetY = MAX(MIN(contentOffsetY, contentOffsetWhenScrollToBottom), contentOffsetWhenScrollToTop);
    } else {
        contentOffsetY = -self.adjustedContentInset.top;
    }
    [self setContentOffset:CGPointMake(self.contentOffset.x, contentOffsetY) animated:animated];
}

@end
