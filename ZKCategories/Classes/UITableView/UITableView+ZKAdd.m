//
//  UITableView+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "NSNumber+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "NSString+ZKAdd.h"
#import "UITableView+ZKAdd.h"
#import "UITableViewCell+ZKAdd.h"
#import "UIView+ZKAdd.h"
#import "ZKCGUtilities.h"

@implementation UITableView (ZKAdd)

- (UIView *)indexView {
    Class indexViewClass = NSClassFromString(@"UITableViewIndex");
    return [self descendantOrSelfWithClass:indexViewClass];
}

- (CGFloat)tableCellMargin {
    if (self.style == UITableViewStyleGrouped) {
        return 10;

    } else {
        return 0;
    }
}

- (void)scrollToFirstRow:(BOOL)animated {
    if ([self numberOfSections] > 0 && [self numberOfRowsInSection:0] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self scrollToRowAtIndexPath:indexPath
                    atScrollPosition:UITableViewScrollPositionTop
                            animated:NO];
    }
}

- (void)scrollToLastRow:(BOOL)animated {
    if ([self numberOfSections] > 0) {
        NSInteger section  = [self numberOfSections] - 1;
        NSInteger rowCount = [self numberOfRowsInSection:section];
        if (rowCount > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowCount - 1 inSection:section];
            [self scrollToRowAtIndexPath:indexPath
                        atScrollPosition:UITableViewScrollPositionBottom
                                animated:NO];
        }
    }
}

- (void)touchRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (![self cellForRowAtIndexPath:indexPath]) {
        [self reloadData];
    }

    if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        [self.delegate tableView:self willSelectRowAtIndexPath:indexPath];
    }

    [self selectRowAtIndexPath:indexPath
                      animated:animated
                scrollPosition:UITableViewScrollPositionTop];

    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:self didSelectRowAtIndexPath:indexPath];
    }
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    // Because we set delaysContentTouches = NO, we return YES for UIButtons
    // so that scrolling works correctly when the scroll gesture
    // starts in the UIButtons.

    if ([view isKindOfClass:[UIControl class]]) {
        return YES;
    }

    return [super touchesShouldCancelInContentView:view];
}

- (void)updateWithBlock:(void (^)(UITableView *tableView))block {
    [self beginUpdates];
    block(self);
    [self endUpdates];
}

- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *toInsert = [NSIndexPath indexPathForRow:row inSection:section];
    [self insertRowAtIndexPath:toInsert withRowAnimation:animation];
}

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *toReload = [NSIndexPath indexPathForRow:row inSection:section];
    [self reloadRowAtIndexPath:toReload withRowAnimation:animation];
}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *toDelete = [NSIndexPath indexPathForRow:row inSection:section];
    [self deleteRowAtIndexPath:toDelete withRowAnimation:animation];
}

- (void)insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section];
    [self insertSections:sections withRowAnimation:animation];
}

- (void)deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section];
    [self deleteSections:sections withRowAnimation:animation];
}

- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self reloadSections:indexSet withRowAnimation:animation];
}

- (void)clearSelectedRowsAnimated:(BOOL)animated {
    NSArray *indexs = [self indexPathsForSelectedRows];
    [indexs enumerateObjectsUsingBlock:^(NSIndexPath *path, NSUInteger idx, BOOL *stop) {
        [self deselectRowAtIndexPath:path animated:animated];
    }];
}

- (void)extraCellLineHidden {
    UIView *v         = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:v];
}

- (KAITableViewCellPosition)positionForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfRowsInSection = [self.dataSource tableView:self numberOfRowsInSection:indexPath.section];
    if (numberOfRowsInSection == 1) {
        return KAITableViewCellPositionSingleInSection;
    }
    if (indexPath.row == 0) {
        return KAITableViewCellPositionFirstInSection;
    }
    if (indexPath.row == numberOfRowsInSection - 1) {
        return KAITableViewCellPositionLastInSection;
    }
    return KAITableViewCellPositionMiddleInSection;
}

@end

@interface UITableViewCell (ZKAdd_Private)

@property (nonatomic, assign, readwrite) KAITableViewCellPosition cellPosition;
@end

@implementation UITableView (ZKAdd_InsetGrouped)

// 统一的圆角设置方法，确保在 iOS 26 兼容模式下也能生效
// 参考 TOInsetGroupedTableView 的实现方式
+ (void)kai_applyCornerRadiusToCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView {
    [self kai_applyCornerRadiusToCell:cell forTableView:tableView forceLayout:YES];
}

+ (void)kai_applyCornerRadiusToCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView forceLayout:(BOOL)forceLayout {
    if (@available(iOS 13.0, *)) {
        if (tableView.style != UITableViewStyleInsetGrouped) {
            return;
        }
    } else {
        return;
    }

    // 关键：在应用圆角前强制 layout，确保 cell 已经完成布局（参考 TOInsetGroupedTableView 的实现）
    // 这对于 iOS 26 兼容模式尤其重要
    // 但如果在 layoutSubviews 中调用，则不需要再次 layout
    if (forceLayout) {
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
    }

    KAITableViewCellPosition position = cell.cellPosition;
    CGFloat cornerRadius              = tableView.kai_insetGroupedCornerRadius;

    // 如果 position 还是 MiddleInSection（可能是未正确设置），尝试通过检查 separator 位置来判断（参考 TOInsetGroupedTableView 的方式）
    // 注意：这里只有当 position 是 MiddleInSection 时才判断，因为其他位置已经明确
    if (position == KAITableViewCellPositionMiddleInSection) {
        BOOL topRounded         = NO;
        BOOL bottomRounded      = NO;
        CGFloat separatorHeight = 1.0f;

        // 检查 separator 位置来判断 cell 位置
        for (UIView *subview in cell.subviews) {
            CGRect frame = subview.frame;
            if (frame.size.height > separatorHeight) continue;
            if (frame.origin.x > FLT_EPSILON) continue; // 这是有偏移的 separator，跳过

            if (frame.origin.y < FLT_EPSILON) {
                topRounded = YES;
            } else {
                bottomRounded = YES;
            }
        }

        // 如果检测到 separator，说明这不是真正的中间位置，需要重新判断
        if (topRounded || bottomRounded) {
            if (topRounded && bottomRounded) {
                position = KAITableViewCellPositionSingleInSection;
            } else if (topRounded) {
                position = KAITableViewCellPositionFirstInSection;
            } else if (bottomRounded) {
                position = KAITableViewCellPositionLastInSection;
            }
            cell.cellPosition = position;
        }
    }

    // 中间位置的 cell 不需要圆角
    if (position == KAITableViewCellPositionMiddleInSection) {
        cornerRadius = 0;
    }

    // 设置 cell 的 masksToBounds
    cell.layer.masksToBounds = YES;

    if (cornerRadius > 0) {
        // 确定哪些角需要圆角
        UIRectCorner corners = 0;

        if (position == KAITableViewCellPositionSingleInSection) {
            // 唯一的 cell：设置所有圆角
            corners = UIRectCornerAllCorners;
        } else if (position == KAITableViewCellPositionFirstInSection) {
            // 第一个 cell：只设置上圆角
            corners = UIRectCornerTopLeft | UIRectCornerTopRight;
        } else if (position == KAITableViewCellPositionLastInSection) {
            // 最后一个 cell：只设置下圆角
            corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
        }

        // iOS 26 及以上：使用 CAShapeLayer mask 实现圆角（兼容模式下更可靠，不会被系统覆盖）
        // iOS 26 以下：使用 cornerRadius + maskedCorners 方式
        if (@available(iOS 26.0, *)) {
            // 使用 CAShapeLayer mask 实现圆角（参考 TOInsetGroupedTableView 的实现）
            CGRect bounds           = cell.bounds;
            UIBezierPath *maskPath  = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                           byRoundingCorners:corners
                                                                 cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame         = bounds;
            maskLayer.path          = maskPath.CGPath;
            cell.layer.mask         = maskLayer;
        } else {
            // iOS 26 以下：使用原有的实现方式
            cell.layer.cornerRadius = cornerRadius;
            if (@available(iOS 11.0, *)) {
                CACornerMask maskedCorners = 0;
                if (position == KAITableViewCellPositionSingleInSection) {
                    maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
                } else if (position == KAITableViewCellPositionFirstInSection) {
                    maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                } else if (position == KAITableViewCellPositionLastInSection) {
                    maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
                }
                cell.layer.maskedCorners = maskedCorners;
            }
            // 移除可能存在的 mask（如果之前是 iOS 26+ 创建的）
            cell.layer.mask = nil;
        }
    } else {
        // 没有圆角时，清除所有圆角设置
        cell.layer.mask         = nil;
        cell.layer.cornerRadius = 0;
        if (@available(iOS 11.0, *)) {
            cell.layer.maskedCorners = 0;
        }
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // -[UITableViewDelegate tableView:willDisplayCell:forRowAtIndexPath:] 比这个还晚，所以不用担心触发 delegate
        OverrideImplementation([UITableView class], NSSelectorFromString(@"_configureCellForDisplay:forIndexPath:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject, UITableViewCell *cell, NSIndexPath *indexPath) {
                // call super
                void (*originSelectorIMP)(id, SEL, UITableViewCell *, NSIndexPath *);
                originSelectorIMP = (void (*)(id, SEL, UITableViewCell *, NSIndexPath *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, cell, indexPath);

                // UITableViewCell 内会根据 cellPosition 调整 separator 的布局，所以先在这里赋值以供那边使用
                KAITableViewCellPosition position = [selfObject positionForRowAtIndexPath:indexPath];
                cell.cellPosition                 = position;

                // 应用圆角设置：先立即应用一次，然后延迟再次应用确保在系统设置之后（iOS 26 兼容模式）
                if (@available(iOS 13.0, *)) {
                    if (selfObject.style == UITableViewStyleInsetGrouped) {
                        [UITableView kai_applyCornerRadiusToCell:cell forTableView:selfObject];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (selfObject.style == UITableViewStyleInsetGrouped) {
                                [UITableView kai_applyCornerRadiusToCell:cell forTableView:selfObject];
                            }
                        });
                    }
                }
            };
        });

        // -[UITableViewCell _setContentClipCorners:updateCorners:]，用来控制系统 InsetGrouped 的圆角（很多情况都会触发系统更新圆角，例如设置 cell.backgroundColor、...，对于 iOS 12 及以下的系统，则靠 -[UITableView _configureCellForDisplay:forIndexPath:] 来处理
        // - (void) _setContentClipCorners:(unsigned long)arg1 updateCorners:(BOOL)arg2; (0x10db0a5b7)
        // 这个方法使用 CACornerMask，只在 iOS 11.0+ 可用
        if (@available(iOS 11.0, *)) {
            OverrideImplementation([UITableViewCell class], NSSelectorFromString([NSString stringByConcat:@"_setContentClipCorners", @":", @"updateCorners", @":", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UITableViewCell *selfObject, CACornerMask firstArgv, BOOL secondArgv) {
                    // call super
                    void (*originSelectorIMP)(id, SEL, CACornerMask, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, CACornerMask, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);

                    UITableView *tableView = selfObject.tableView;
                    if (@available(iOS 13.0, *)) {
                        if (tableView && tableView.style == UITableViewStyleInsetGrouped) {
                            [UITableView kai_applyCornerRadiusToCell:selfObject forTableView:tableView];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (tableView && tableView.style == UITableViewStyleInsetGrouped) {
                                    [UITableView kai_applyCornerRadiusToCell:selfObject forTableView:tableView];
                                }
                            });
                        }
                    }
                };
            });
        }

        // Hook UITableViewCell 的 layoutSubviews 作为后备方案，确保在 iOS 26 兼容模式下圆角也能生效
        // 在布局完成后再次应用圆角，确保不会被系统覆盖
        ExtendImplementationOfVoidMethodWithoutArguments([UITableViewCell class], @selector(layoutSubviews), ^(UITableViewCell *selfObject) {
            UITableView *tableView = selfObject.tableView;
            if (@available(iOS 13.0, *)) {
                if (tableView && tableView.style == UITableViewStyleInsetGrouped) {
                    // 确保 cellPosition 已设置
                    if (selfObject.cellPosition == KAITableViewCellPositionMiddleInSection) {
                        NSIndexPath *indexPath = [tableView indexPathForCell:selfObject];
                        if (indexPath) {
                            selfObject.cellPosition = [tableView positionForRowAtIndexPath:indexPath];
                        }
                    }
                    // 应用圆角设置（在 layoutSubviews 中不需要再次 layout，但会重新创建 mask 以匹配新的 bounds）
                    [UITableView kai_applyCornerRadiusToCell:selfObject forTableView:tableView forceLayout:NO];
                }
            }
        });

        // -[UITableView layoutMargins]，用来控制系统 InsetGrouped 的左右间距
        OverrideImplementation([UITableView class], @selector(layoutMargins), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIEdgeInsets(UITableView *selfObject) {
                // call super
                UIEdgeInsets (*originSelectorIMP)(id, SEL);
                originSelectorIMP   = (UIEdgeInsets(*)(id, SEL))originalIMPProvider();
                UIEdgeInsets result = originSelectorIMP(selfObject, originCMD);

                if (@available(iOS 13.0, *)) {
                    if (selfObject.style == UITableViewStyleInsetGrouped) {
                        result.left  = selfObject.safeAreaInsets.left + selfObject.kai_insetGroupedHorizontalInset;
                        result.right = selfObject.safeAreaInsets.right + selfObject.kai_insetGroupedHorizontalInset;
                    }
                }

                return result;
            };
        });
    });
}

- (void)setKai_insetGroupedCornerRadius:(CGFloat)kai_insetGroupedCornerRadius {
    [self setAssociateValue:@(kai_insetGroupedCornerRadius) withKey:@selector(kai_insetGroupedCornerRadius)];
    if (@available(iOS 13.0, *)) {
        if (self.style == UITableViewStyleInsetGrouped) {
            // 立即对所有可见的 cell 应用圆角
            for (NSIndexPath *indexPath in self.indexPathsForVisibleRows) {
                UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
                if (cell) {
                    if (cell.cellPosition == KAITableViewCellPositionMiddleInSection) {
                        cell.cellPosition = [self positionForRowAtIndexPath:indexPath];
                    }
                    [UITableView kai_applyCornerRadiusToCell:cell forTableView:self];
                }
            }
            // 延迟再次应用，确保在系统设置之后（iOS 26 兼容模式）
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSIndexPath *indexPath in self.indexPathsForVisibleRows) {
                    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
                    if (cell) {
                        if (cell.cellPosition == KAITableViewCellPositionMiddleInSection) {
                            cell.cellPosition = [self positionForRowAtIndexPath:indexPath];
                        }
                        [UITableView kai_applyCornerRadiusToCell:cell forTableView:self];
                    }
                }
            });
        }
    }
}

- (CGFloat)kai_insetGroupedCornerRadius {
    NSNumber *value = [self associatedValueForKey:_cmd];
    if (!value) {
        // 从来没设置过（包括业务主动设置或者通过 UIAppearance 方式设置），则用 iOS 13 系统默认值
        // 不在 UITableView init 时设置是因为那样会使 UIAppearance 失效
        return 10;
    }
    return [value CGFloatValue];
}

- (void)setKai_insetGroupedHorizontalInset:(CGFloat)kai_insetGroupedHorizontalInset {
    [self setAssociateValue:@(kai_insetGroupedHorizontalInset) withKey:@selector(kai_insetGroupedHorizontalInset)];
    if (@available(iOS 13.0, *)) {
        if (self.style == UITableViewStyleInsetGrouped && self.indexPathsForVisibleRows.count) {
            [self reloadData];
        }
    }
}

- (CGFloat)kai_insetGroupedHorizontalInset {
    NSNumber *associatedValue = [self associatedValueForKey:_cmd];
    if (!associatedValue) {
        // 从来没设置过（包括业务主动设置或者通过 UIAppearance 方式设置），则用 iOS 13 系统默认值
        // 不在 UITableView init 时设置是因为那样会使 UIAppearance 失效
        return 20;
    }
    return associatedValue.CGFloatValue;
}

@end
