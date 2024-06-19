//
//  UITableView+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UITableView+ZKAdd.h"
#import "UIView+ZKAdd.h"
#import "ZKCGUtilities.h"
#import "UITableViewCell+ZKAdd.h"
#import "NSString+ZKAdd.h"
#import "NSNumber+ZKAdd.h"
#import "NSObject+ZKAdd.h"

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

@property(nonatomic, assign, readwrite) KAITableViewCellPosition cellPosition;
@end

@implementation UITableView (ZKAdd_InsetGrouped)

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
                
                // UITableViewCell(QMUI) 内会根据 cellPosition 调整 separator 的布局，所以先在这里赋值以供那边使用
                KAITableViewCellPosition position = [selfObject positionForRowAtIndexPath:indexPath];
                cell.cellPosition = position;
                
                if (selfObject.style == UITableViewStyleInsetGrouped) {
                    CGFloat cornerRadius = selfObject.kai_insetGroupedCornerRadius;
                    if (position == KAITableViewCellPositionMiddleInSection || position == KAITableViewCellPositionNone) {
                        cornerRadius = 0;
                    }
                    cell.layer.cornerRadius = cornerRadius;
                }
            };
        });
        
        // -[UITableViewCell _setContentClipCorners:updateCorners:]，用来控制系统 InsetGrouped 的圆角（很多情况都会触发系统更新圆角，例如设置 cell.backgroundColor、...，对于 iOS 12 及以下的系统，则靠 -[UITableView _configureCellForDisplay:forIndexPath:] 来处理
        // - (void) _setContentClipCorners:(unsigned long)arg1 updateCorners:(BOOL)arg2; (0x10db0a5b7)
        OverrideImplementation([UITableViewCell class], NSSelectorFromString([NSString stringByConcat:@"_setContentClipCorners", @":", @"updateCorners", @":", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableViewCell *selfObject, CACornerMask firstArgv, BOOL secondArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, CACornerMask, BOOL);
                originSelectorIMP = (void (*)(id, SEL, CACornerMask, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                
                UITableView *tableView = selfObject.tableView;
                if (tableView && tableView.style == UITableViewStyleInsetGrouped) {
                    CGFloat cornerRadius = tableView.kai_insetGroupedCornerRadius;
                    if (selfObject.cellPosition == KAITableViewCellPositionMiddleInSection || selfObject.cellPosition == KAITableViewCellPositionNone) {
                        cornerRadius = 0;
                    }
                    selfObject.layer.cornerRadius = cornerRadius;
                }
            };
        });
        
        
        // -[UITableView layoutMargins]，用来控制系统 InsetGrouped 的左右间距
        OverrideImplementation([UITableView class], @selector(layoutMargins), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIEdgeInsets(UITableView *selfObject) {
                // call super
                UIEdgeInsets (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (UIEdgeInsets (*)(id, SEL))originalIMPProvider();
                UIEdgeInsets result = originSelectorIMP(selfObject, originCMD);
                
                if (selfObject.style == UITableViewStyleInsetGrouped) {
                    result.left = selfObject.safeAreaInsets.left + selfObject.kai_insetGroupedHorizontalInset;
                    result.right = selfObject.safeAreaInsets.right + selfObject.kai_insetGroupedHorizontalInset;
                }
                
                return result;
            };
        });
    });
}

- (void)setKai_insetGroupedCornerRadius:(CGFloat)kai_insetGroupedCornerRadius {
    [self setAssociateValue:@(kai_insetGroupedCornerRadius) withKey:@selector(kai_insetGroupedCornerRadius)];
    if (self.style == UITableViewStyleGrouped && self.indexPathsForVisibleRows.count) {
        [self reloadData];
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
    if (self.style == UITableViewStyleInsetGrouped && self.indexPathsForVisibleRows.count) {
        [self reloadData];
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
