//
//  UITextField+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//
#import "UITextField+ZKAdd.h"
#import "ZKCategoriesMacro.h"
#import "NSObject+ZKAdd.h"
#import <objc/runtime.h>

static void *const UITextFieldDelegateKey = &UITextFieldDelegateKey;
static void *const UITextFieldShouldBeginEditingKey = &UITextFieldShouldBeginEditingKey;
static void *const UITextFieldShouldEndEditingKey = &UITextFieldShouldEndEditingKey;
static void *const UITextFieldDidBeginEditingKey = &UITextFieldDidBeginEditingKey;
static void *const UITextFieldDidEndEditingKey = &UITextFieldDidEndEditingKey;
static void *const UITextFieldShouldChangeCharactersInRangeKey = &UITextFieldShouldChangeCharactersInRangeKey;
static void *const UITextFieldShouldClearKey = &UITextFieldShouldClearKey;
static void *const UITextFieldShouldReturnKey = &UITextFieldShouldReturnKey;

ZKSYNTH_DUMMY_CLASS(UITextField_ZKAdd)

@implementation UITextField (ZKAdd)

- (NSRange)selectedRange {
    UITextPosition *beginning = self.beginningOfDocument;
    
    UITextRange *selectedRange = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void)selectAllText {
    UITextRange *range = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}

- (void)setSelectedRange:(NSRange)range {
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}

#pragma mark UITextField Delegate methods

+ (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.shouldBegindEditingBlock) {
        return textField.shouldBegindEditingBlock(textField);
    }
    
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [delegate textFieldShouldBeginEditing:textField];
    }
    // return default value just in case
    return YES;
}

+ (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.shouldEndEditingBlock) {
        return textField.shouldEndEditingBlock(textField);
    }
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [delegate textFieldShouldEndEditing:textField];
    }
    // return default value just in case
    return YES;
}

+ (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.didBeginEditingBlock) {
        textField.didBeginEditingBlock(textField);
    }
    
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [delegate textFieldDidBeginEditing:textField];
    }
}

+ (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.didEndEditingBlock) {
        textField.didEndEditingBlock(textField);
    }
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [delegate textFieldDidBeginEditing:textField];
    }
}

+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.shouldChangeCharactersInRangeBlock) {
        return textField.shouldChangeCharactersInRangeBlock(textField, range, string);
    }
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

+ (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField.shouldClearBlock) {
        return textField.shouldClearBlock(textField);
    }
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [delegate textFieldShouldClear:textField];
    }
    return YES;
}

+ (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.shouldReturnBlock) {
        return textField.shouldReturnBlock(textField);
    }
    id delegate = [self associatedValueForKey:UITextFieldDelegateKey];
    if ([delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [delegate textFieldShouldReturn:textField];
    }
    return YES;
}

#pragma mark Block setting/getting methods

- (BOOL(^)(UITextField *))shouldBegindEditingBlock {
    return [self associatedValueForKey:UITextFieldShouldBeginEditingKey];
}

- (void)setShouldBegindEditingBlock:(BOOL (^)(UITextField *))shouldBegindEditingBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldShouldBeginEditingKey, shouldBegindEditingBlock, OBJC_ASSOCIATION_COPY);
}

- (BOOL(^)(UITextField *))shouldEndEditingBlock {
    return [self associatedValueForKey:UITextFieldShouldEndEditingKey];
}

- (void)setShouldEndEditingBlock:(BOOL (^)(UITextField *))shouldEndEditingBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldShouldEndEditingKey, shouldEndEditingBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UITextField *))didBeginEditingBlock {
    return [self associatedValueForKey:UITextFieldDidBeginEditingKey];
}

- (void)setDidBeginEditingBlock:(void (^)(UITextField *))didBeginEditingBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldDidBeginEditingKey, didBeginEditingBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UITextField *))didEndEditingBlock {
    return [self associatedValueForKey:UITextFieldDidEndEditingKey];
}

- (void)setDidEndEditingBlock:(void (^)(UITextField *))didEndEditingBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldDidEndEditingKey, didEndEditingBlock, OBJC_ASSOCIATION_COPY);
}

- (BOOL(^)(UITextField *, NSRange, NSString *))shouldChangeCharactersInRangeBlock {
    return [self associatedValueForKey:UITextFieldShouldChangeCharactersInRangeKey];
}

- (void)setShouldChangeCharactersInRangeBlock:(BOOL(^)(UITextField *, NSRange, NSString *))shouldChangeCharactersInRangeBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldShouldChangeCharactersInRangeKey, shouldChangeCharactersInRangeBlock, OBJC_ASSOCIATION_COPY);
}

- (BOOL(^)(UITextField *))shouldReturnBlock {
    return objc_getAssociatedObject(self, UITextFieldShouldReturnKey);
}

- (void)setShouldReturnBlock:(BOOL (^)(UITextField *))shouldReturnBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldShouldReturnKey, shouldReturnBlock, OBJC_ASSOCIATION_COPY);
}

- (BOOL(^)(UITextField *))shouldClearBlock {
    return [self associatedValueForKey:UITextFieldShouldClearKey];
}

- (void)setShouldClearBlock:(BOOL(^)(UITextField *textField))shouldClearBlock {
    [self setDelegateIfNoDelegateSet];
    objc_setAssociatedObject(self, UITextFieldShouldClearKey, shouldClearBlock, OBJC_ASSOCIATION_COPY);
}

#pragma mark control method
/*
 Setting itself as delegate if no other delegate has been set. This ensures the UITextField will use blocks if no delegate is set.
 */
- (void)setDelegateIfNoDelegateSet {
    if (self.delegate != (id<UITextFieldDelegate>)[self class]) {
        [self setAssociateWeakValue:self.delegate withKey:UITextFieldDelegateKey];
        self.delegate = (id<UITextFieldDelegate>)[self class];
    }
}

@end
