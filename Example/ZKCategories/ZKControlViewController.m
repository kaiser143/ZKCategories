//
//  ZKControlViewController.m
//  ZKCategories_Example
//
//  Created by Kaiser on 2026/8/18.
//  Copyright © 2026 Kaiser. All rights reserved.
//

#import "ZKControlViewController.h"
#import <ZKCategories/ZKCategories.h>

@interface ZKHighlightDemoButton : UIButton

@property (nonatomic, strong) UIColor *normalBackgroundColor;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;

@end

@implementation ZKHighlightDemoButton

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    UIColor *color = highlighted ? self.highlightedBackgroundColor : self.normalBackgroundColor;
    if (color) {
        self.backgroundColor = color;
    }
}

@end

@interface ZKControlViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) ZKHighlightDemoButton *systemButton;
@property (nonatomic, strong) ZKHighlightDemoButton *optimizedButton;
@property (nonatomic, strong) UILabel *compareTipsLabel;
@property (nonatomic, strong) UILabel *repeatTitleLabel;
@property (nonatomic, strong) UIButton *repeatButton;
@property (nonatomic, strong) UILabel *repeatTipsLabel;
@property (nonatomic, assign) NSInteger tapCount;

@end

@implementation ZKControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"UIControl 高亮";
    self.view.backgroundColor = UIColor.whiteColor;
    self.tapCount = 0;

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.systemButton];
    [self.scrollView addSubview:self.optimizedButton];
    [self.scrollView addSubview:self.compareTipsLabel];
    [self.scrollView addSubview:self.repeatTitleLabel];
    [self.scrollView addSubview:self.repeatButton];
    [self.scrollView addSubview:self.repeatTipsLabel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    UIEdgeInsets safeArea = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeArea = self.view.safeAreaInsets;
    }

    self.scrollView.frame = self.view.bounds;

    CGFloat padding = 16.f;
    CGFloat contentWidth = CGRectGetWidth(self.view.bounds) - padding * 2;
    CGFloat buttonWidth = 120.f;
    CGFloat buttonHeight = 48.f;
    CGFloat top = safeArea.top + 24.f;
    CGFloat gap = (contentWidth - buttonWidth * 2) / 3.f;

    self.systemButton.frame = CGRectMake(padding + gap, top, buttonWidth, buttonHeight);
    self.optimizedButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - padding - gap - buttonWidth,
                                            top,
                                            buttonWidth,
                                            buttonHeight);

    CGSize tipsSize = [self.compareTipsLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    self.compareTipsLabel.frame = CGRectMake(padding, CGRectGetMaxY(self.systemButton.frame) + 16.f, contentWidth, tipsSize.height);

    self.repeatTitleLabel.frame = CGRectMake(padding, CGRectGetMaxY(self.compareTipsLabel.frame) + 32.f, contentWidth, 22.f);
    self.repeatButton.frame = CGRectMake(padding, CGRectGetMaxY(self.repeatTitleLabel.frame) + 12.f, contentWidth, buttonHeight);

    CGSize repeatTipsSize = [self.repeatTipsLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    self.repeatTipsLabel.frame = CGRectMake(padding, CGRectGetMaxY(self.repeatButton.frame) + 16.f, contentWidth, repeatTipsSize.height);

    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds),
                                             MAX(CGRectGetMaxY(self.repeatTipsLabel.frame) + 48.f + safeArea.bottom,
                                                 CGRectGetHeight(self.view.bounds) + 120.f));
}

#pragma mark - Actions

- (void)handleRepeatTap:(UIButton *)sender {
    self.tapCount += 1;
    [sender setTitle:[NSString stringWithFormat:@"已触发 %ld 次", (long)self.tapCount] forState:UIControlStateNormal];
}

#pragma mark - Factory

- (ZKHighlightDemoButton *)makeDemoButtonWithTitle:(NSString *)title {
    ZKHighlightDemoButton *button = [ZKHighlightDemoButton buttonWithType:UIButtonTypeCustom];
    button.normalBackgroundColor = [UIColor colorWithHexString:@"#3478F6"];
    button.highlightedBackgroundColor = [UIColor colorWithHexString:@"#1C4FD8"];
    button.backgroundColor = button.normalBackgroundColor;
    button.layer.cornerRadius = 8.f;
    button.clipsToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    return button;
}

- (UILabel *)makeTipsLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.textColor = [UIColor colorWithHexString:@"#5C6670"];
    label.font = [UIFont systemFontOfSize:13.f];
    label.text = text;
    return label;
}

#pragma mark - Getters

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.backgroundColor = UIColor.whiteColor;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

- (ZKHighlightDemoButton *)systemButton {
    if (!_systemButton) {
        _systemButton = [self makeDemoButtonWithTitle:@"系统默认"];
    }
    return _systemButton;
}

- (ZKHighlightDemoButton *)optimizedButton {
    if (!_optimizedButton) {
        _optimizedButton = [self makeDemoButtonWithTitle:@"已开启优化"];
        _optimizedButton.automaticallyAdjustTouchHighlightedInScrollView = YES;
    }
    return _optimizedButton;
}

- (UILabel *)compareTipsLabel {
    if (!_compareTipsLabel) {
        _compareTipsLabel = [self makeTipsLabelWithText:
                             @"对比说明（请在上方按钮上操作）：\n"
                             @"1. 快速点击左侧「系统默认」：受 UIScrollView 约 300ms 延迟影响，通常看不到高亮。\n"
                             @"2. 快速点击右侧「已开启优化」：抬起时会短暂高亮，点击反馈更明显。\n"
                             @"3. 在右侧按钮上按下后立刻拖动滚动：未满 300ms 不会因按下而高亮，也不影响滚动。\n"
                             @"4. 按住右侧按钮超过 300ms 且不移动：才会进入按住高亮。"];
    }
    return _compareTipsLabel;
}

- (UILabel *)repeatTitleLabel {
    if (!_repeatTitleLabel) {
        _repeatTitleLabel = [[UILabel alloc] init];
        _repeatTitleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
        _repeatTitleLabel.textColor = [UIColor colorWithHexString:@"#1C1C1E"];
        _repeatTitleLabel.text = @"防重复点击";
    }
    return _repeatTitleLabel;
}

- (UIButton *)repeatButton {
    if (!_repeatButton) {
        _repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _repeatButton.backgroundColor = [UIColor colorWithHexString:@"#F2F4F7"];
        _repeatButton.layer.cornerRadius = 8.f;
        _repeatButton.clipsToBounds = YES;
        _repeatButton.titleLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
        [_repeatButton setTitle:@"已触发 0 次" forState:UIControlStateNormal];
        [_repeatButton setTitleColor:[UIColor colorWithHexString:@"#1C1C1E"] forState:UIControlStateNormal];
        _repeatButton.preventsRepeatedTouchUpInsideEvent = YES;
        [_repeatButton addTarget:self action:@selector(handleRepeatTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _repeatButton;
}

- (UILabel *)repeatTipsLabel {
    if (!_repeatTipsLabel) {
        _repeatTipsLabel = [self makeTipsLabelWithText:
                            @"下方按钮开启了 preventsRepeatedTouchUpInsideEvent。连续快速点击时只有第一次会触发 UIControlEventTouchUpInside，停顿后再点才会重新计数。\n"
                            @"注意：不能与 automaticallyAdjustTouchHighlightedInScrollView 同时开启。"];
    }
    return _repeatTipsLabel;
}

@end
