//
//  UILabel+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UILabel+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "NSNumber+ZKAdd.h"

const CGFloat KAILineHeightIdentity = -1000;

@interface NSParagraphStyle (ZKAdd) @end

@implementation NSParagraphStyle (ZKAdd)

+ (instancetype)kai_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment {
    Class className = ![self isMemberOfClass:NSMutableParagraphStyle.class] ? NSMutableParagraphStyle.class : self;// 保证如果有 NSMutableParagraphStyle 的子类来调用这个方法，也可以用子类的 Class 去初始化
    NSMutableParagraphStyle *paragraphStyle = [[className alloc] init];
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.alignment = textAlignment;
    return paragraphStyle;
}

@end


@implementation UILabel (ZKAdd)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(drawTextInRect:) withMethod:@selector(drawAutomaticWritingTextInRect:)];
        [self swizzleMethod:@selector(sizeThatFits:) withMethod:@selector(kai_sizeThatFits:)];
        [self swizzleMethod:@selector(textRectForBounds:limitedToNumberOfLines:) withMethod:@selector(kai_textRectForBounds:limitedToNumberOfLines:)];
        [self swizzleMethod:@selector(setText:) withMethod:@selector(kai_setText:)];
        [self swizzleMethod:@selector(setAttributedText:) withMethod:@selector(kai_setAttributedText:)];
        [self swizzleMethod:@selector(setLineBreakMode:) withMethod:@selector(kai_setLineBreakMode:)];
        [self swizzleMethod:@selector(setTextAlignment:) withMethod:@selector(kai_setTextAlignment:)];
    });
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [self setAssociateValue:[NSValue valueWithUIEdgeInsets:textContainerInset] withKey:@selector(textContainerInset)];
}

- (UIEdgeInsets)textContainerInset {
    NSValue *edgeInsetsValue = [self associatedValueForKey:_cmd];
    if (edgeInsetsValue) {
        return edgeInsetsValue.UIEdgeInsetsValue;
    }
    
    edgeInsetsValue = [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero];
    [self setTextContainerInset:edgeInsetsValue.UIEdgeInsetsValue];
    return edgeInsetsValue.UIEdgeInsetsValue;
}

- (void)drawAutomaticWritingTextInRect:(CGRect)rect {
    [self drawAutomaticWritingTextInRect:UIEdgeInsetsInsetRect(rect, self.textContainerInset)];
}

- (CGSize)kai_sizeThatFits:(CGSize)size {
    CGSize returnValue = [self kai_sizeThatFits:size];
    
    UIEdgeInsets insets = [self textContainerInset];
    returnValue.width += (insets.left + insets.right);
    returnValue.height += (insets.top + insets.bottom);
    return returnValue;
}

- (CGRect)kai_textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    UIEdgeInsets insets = self.textContainerInset;
    CGRect rect = [self kai_textRectForBounds:UIEdgeInsetsInsetRect(bounds, insets)
                       limitedToNumberOfLines:numberOfLines];
    
    rect.origin.x    -= insets.left;
    rect.origin.y    -= insets.top;
    rect.size.width  += (insets.left + insets.right);
    rect.size.height += (insets.top + insets.bottom);
    
    return rect;
}

- (void)kai_setText:(NSString *)text {
    if (!text) {
        [self kai_setText:text];
        return;
    }
    if (!self.kai_textAttributes.count && ![self _hasSetKaiLineHeight]) {
        [self kai_setText:text];
        return;
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:self.kai_textAttributes];
    [self kai_setAttributedText:[self attributedStringWithKernAndLineHeightAdjusted:attributedString]];
}

// 在 kai_textAttributes 样式基础上添加用户传入的 attributedString 中包含的新样式。换句话说，如果这个方法里有样式冲突，则以 attributedText 为准
- (void)kai_setAttributedText:(NSAttributedString *)text {
    if (!text || (!self.kai_textAttributes.count && ![self _hasSetKaiLineHeight])) {
        [self kai_setAttributedText:text];
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text.string attributes:self.kai_textAttributes];
    attributedString = [[self attributedStringWithKernAndLineHeightAdjusted:attributedString] mutableCopy];
    [text enumerateAttributesInRange:NSMakeRange(0, text.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        [attributedString addAttributes:attrs range:range];
    }];
    [self kai_setAttributedText:attributedString];
}

// 在现有样式基础上增加 kai_textAttributes 样式。换句话说，如果这个方法里有样式冲突，则以 kai_textAttributes 为准
- (void)setKai_textAttributes:(NSDictionary<NSAttributedStringKey, id> *)kai_textAttributes {
    NSDictionary *prevTextAttributes = self.kai_textAttributes;
    if ([prevTextAttributes isEqualToDictionary:kai_textAttributes]) {
        return;
    }
    
    [self setAssociateValue:kai_textAttributes withKey:@selector(kai_textAttributes)];
    
    if (!self.text.length) {
        return;
    }
    NSMutableAttributedString *string = [self.attributedText mutableCopy];
    NSRange fullRange = NSMakeRange(0, string.length);
    
    // 1）当前 attributedText 包含的样式可能来源于两方面：通过 kai_textAttributes 设置的、通过直接传入 attributedString 设置的，这里要过滤删除掉前者的样式效果，保留后者的样式效果
    if (prevTextAttributes) {
        // 找出现在 attributedText 中哪些 attrs 是通过上次的 kai_textAttributes 设置的
        NSMutableArray *willRemovedAttributes = [NSMutableArray array];
        [string enumerateAttributesInRange:NSMakeRange(0, string.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            // 如果存在 kern 属性，则只有 range 是第一个字至倒数第二个字，才有可能是通过 kai_textAttribtus 设置的
            if (NSEqualRanges(range, NSMakeRange(0, string.length - 1)) && [attrs[NSKernAttributeName] isEqualToNumber:prevTextAttributes[NSKernAttributeName]]) {
                [string removeAttribute:NSKernAttributeName range:NSMakeRange(0, string.length - 1)];
            }
            // 上面排除掉 kern 属性后，如果 range 不是整个字符串，那肯定不是通过 kai_textAttributes 设置的
            if (!NSEqualRanges(range, fullRange)) {
                return;
            }
            [attrs enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey _Nonnull attr, id  _Nonnull value, BOOL * _Nonnull stop) {
                if (prevTextAttributes[attr] == value) {
                    [willRemovedAttributes addObject:attr];
                }
            }];
        }];
        [willRemovedAttributes enumerateObjectsUsingBlock:^(id  _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop) {
            [string removeAttribute:attr range:fullRange];
        }];
    }
    
    // 2）添加新样式
    if (kai_textAttributes) {
        [string addAttributes:kai_textAttributes range:fullRange];
    }
    // 不能调用 setAttributedText: ，否则若遇到样式冲突，那个方法会让用户传进来的 NSAttributedString 样式覆盖 kai_textAttributes 的样式
    [self kai_setAttributedText:[self attributedStringWithKernAndLineHeightAdjusted:string]];
}

- (NSDictionary *)kai_textAttributes {
    return [self associatedValueForKey:_cmd];
}

// 去除最后一个字的 kern 效果，并且在有必要的情况下应用 kai_setLineHeight: 设置的行高
- (NSAttributedString *)attributedStringWithKernAndLineHeightAdjusted:(NSAttributedString *)string {
    if (!string.length) {
        return string;
    }
    NSMutableAttributedString *attributedString = nil;
    if ([string isKindOfClass:[NSMutableAttributedString class]]) {
        attributedString = (NSMutableAttributedString *)string;
    } else {
        attributedString = [string mutableCopy];
    }
    
    // 去除最后一个字的 kern 效果，使得文字整体在视觉上居中
    // 只有当 kai_textAttributes 中设置了 kern 时这里才应该做调整
    if (self.kai_textAttributes[NSKernAttributeName]) {
        [attributedString removeAttribute:NSKernAttributeName range:NSMakeRange(string.length - 1, 1)];
    }
    
    // 判断是否应该应用上通过 kai_setLineHeight: 设置的行高
    __block BOOL shouldAdjustLineHeight = [self _hasSetKaiLineHeight];
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(NSParagraphStyle *style, NSRange range, BOOL * _Nonnull stop) {
        // 如果用户已经通过传入 NSParagraphStyle 对文字整个 range 设置了行高，则这里不应该再次调整行高
        if (NSEqualRanges(range, NSMakeRange(0, attributedString.length))) {
            if (style && (style.maximumLineHeight || style.minimumLineHeight)) {
                shouldAdjustLineHeight = NO;
                *stop = YES;
            }
        }
    }];
    if (shouldAdjustLineHeight) {
        NSMutableParagraphStyle *paraStyle = [NSMutableParagraphStyle kai_paragraphStyleWithLineHeight:self.kai_lineHeight lineBreakMode:self.lineBreakMode textAlignment:self.textAlignment];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributedString.length)];
        
        // iOS 默认文字底对齐，改了行高要自己调整才能保证文字一直在 label 里垂直居中
        CGFloat baselineOffset = (self.kai_lineHeight - self.font.lineHeight) / 4;// 实际测量得知，baseline + 1，文字会往上移动 2pt，所以这里为了垂直居中，需要 / 4。
        [attributedString addAttribute:NSBaselineOffsetAttributeName value:@(baselineOffset) range:NSMakeRange(0, attributedString.length)];
    }
    
    return attributedString;
}

- (void)kai_setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    [self kai_setLineBreakMode:lineBreakMode];
    if (!self.kai_textAttributes) return;
    if (self.kai_textAttributes[NSParagraphStyleAttributeName]) {
        NSMutableParagraphStyle *p = ((NSParagraphStyle *)self.kai_textAttributes[NSParagraphStyleAttributeName]).mutableCopy;
        p.lineBreakMode = lineBreakMode;
        NSMutableDictionary<NSAttributedStringKey, id> *attrs = self.kai_textAttributes.mutableCopy;
        attrs[NSParagraphStyleAttributeName] = p.copy;
        self.kai_textAttributes = attrs.copy;
    }
}

- (void)kai_setTextAlignment:(NSTextAlignment)textAlignment {
    [self kai_setTextAlignment:textAlignment];
    if (!self.kai_textAttributes) return;
    if (self.kai_textAttributes[NSParagraphStyleAttributeName]) {
        NSMutableParagraphStyle *p = ((NSParagraphStyle *)self.kai_textAttributes[NSParagraphStyleAttributeName]).mutableCopy;
        p.alignment = textAlignment;
        NSMutableDictionary<NSAttributedStringKey, id> *attrs = self.kai_textAttributes.mutableCopy;
        attrs[NSParagraphStyleAttributeName] = p.copy;
        self.kai_textAttributes = attrs.copy;
    }
}

- (void)setKai_lineHeight:(CGFloat)lineHeight {
    if (lineHeight == KAILineHeightIdentity) {
        [self setAssociateValue:nil withKey:@selector(kai_lineHeight)];
    } else {
        [self setAssociateValue:@(lineHeight) withKey:@selector(kai_lineHeight)];
    }
    // 注意：对于 UILabel，只要你设置过 text，则 attributedText 就是有值的，因此这里无需区分 setText 还是 setAttributedText
    // 注意：这里需要刷新一下 kai_textAttributes 对 text 的样式，否则刚进行设置的 lineHeight 就会无法设置。
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.attributedText.string attributes:self.kai_textAttributes];
    attributedString = [[self attributedStringWithKernAndLineHeightAdjusted:attributedString] mutableCopy];
    [self setAttributedText:attributedString];
}

- (CGFloat)kai_lineHeight {
    if ([self _hasSetKaiLineHeight]) {
        return [[self associatedValueForKey:_cmd] CGFloatValue];
    } else if (self.attributedText.length) {
        __block NSMutableAttributedString *string = [self.attributedText mutableCopy];
        __block CGFloat result = 0;
        [string enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, string.length) options:0 usingBlock:^(NSParagraphStyle *style, NSRange range, BOOL * _Nonnull stop) {
            // 如果用户已经通过传入 NSParagraphStyle 对文字整个 range 设置了行高，则这里不应该再次调整行高
            if (NSEqualRanges(range, NSMakeRange(0, string.length))) {
                if (style && (style.maximumLineHeight || style.minimumLineHeight)) {
                    result = style.maximumLineHeight;
                    *stop = YES;
                }
            }
        }];
        
        return result == 0 ? self.font.lineHeight : result;
    } else if (self.text.length) {
        return self.font.lineHeight;
    } else if (self.kai_textAttributes) {
        // 当前 label 连文字都没有时，再尝试从 kai_textAttributes 里获取
        if ([self.kai_textAttributes.allKeys containsObject:NSParagraphStyleAttributeName]) {
            return ((NSParagraphStyle *)self.kai_textAttributes[NSParagraphStyleAttributeName]).minimumLineHeight;
        } else if ([self.kai_textAttributes.allKeys containsObject:NSFontAttributeName]) {
            return ((UIFont *)self.kai_textAttributes[NSFontAttributeName]).lineHeight;
        }
    }
    
    return 0;
}

- (BOOL)_hasSetKaiLineHeight {
    return !![self associatedValueForKey:@selector(kai_lineHeight)];
}

- (void)calculateHeightAfterSetAppearance {
    self.text = @"测";
    [self sizeToFit];
    self.text = nil;
}

@end
