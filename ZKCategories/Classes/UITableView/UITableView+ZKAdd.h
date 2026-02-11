//
//  UITableView+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// cell 在当前 section 里的位置，注意判断时要用 (var & xxx) == xxx 的方式
typedef NS_OPTIONS(NSInteger, KAITableViewCellPosition) {
    KAITableViewCellPositionNone            = 0, // 默认
    KAITableViewCellPositionFirstInSection  = 1 << 0,
    KAITableViewCellPositionMiddleInSection = 1 << 1,
    KAITableViewCellPositionLastInSection   = 1 << 2,
    KAITableViewCellPositionSingleInSection = KAITableViewCellPositionFirstInSection | KAITableViewCellPositionLastInSection,
};

@interface UITableView (ZKAdd)

/**
 * 表格右侧的索引视图。
 */
@property (nonatomic, readonly) UIView *indexView;

/**
 * 返回用于内嵌 table cell 的边距。
 *
 * Grouped 样式有边距，Plain 没有。在 cell 布局计算时可用于避免写死表格样式。
 */
@property (nonatomic, readonly) CGFloat tableCellMargin;

- (void)scrollToFirstRow:(BOOL)animated;

- (void)scrollToLastRow:(BOOL)animated;

- (void)touchRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

/**
 在 block 内批量执行插入、删除或选中行/section 的操作。

 @discussion 将一系列插入、删除、选中操作放在此 block 中，可使这些操作（以及
 cellForRowAtIndexPath:、indexPathsForVisibleRows 等）一起动画执行。

 @discussion 若不在 block 内进行插入/删除/选中，表格的行数等属性可能失效。不要在 block 内
 调用 reloadData；若在 block 内调用本方法，需自行处理动画。

 @param block 包含一系列表格更新调用的 block。
 */
- (void)updateWithBlock:(void (^)(UITableView *tableView))block;

/**
 滚动表格使指定行或 section 出现在屏幕上。

 @discussion 调用此方法不会触发 delegate 的 scrollViewDidScroll:，与其它代码触发的 UI 操作一致。

 @param row             所在 section 内的行索引。若目标 section 无行，可传 NSNotFound。
 @param section         section 索引。
 @param scrollPosition  滚动结束后行在表格中的相对位置（顶部、中间、底部）。
 @param animated        YES 为动画滚动，NO 为立即滚动。
 */
- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated NS_SWIFT_NAME(scroll(to:inSection:atPosition:animated:));

/**
 在指定位置插入一行，可选择是否动画。

 @param row        section 内的行索引。
 @param section    section 索引。
 @param animation  插入时的动画类型，或表示无动画的常量。
 */
- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 使用指定动画效果重载某行。

 @param row        section 内的行索引。
 @param section    section 索引。
 @param animation  重载动画类型（如淡出、从底部滑出等），会同时影响旧行滑出和新行滑入方向，
 例如 UITableViewRowAnimationRight 表示旧行向右滑出、新行从右侧滑入。
 */
- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 删除指定行，可选择是否动画。

 @param row        section 内的行索引。
 @param section    section 索引。
 @param animation  删除时的动画类型（如淡出、从底部滑出等）。
 */
- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 在 indexPath 指定位置插入一行，可选择是否动画。

 @param indexPath  用于标识表格中某行的 NSIndexPath。
 @param animation  插入时的动画类型，或表示无动画的常量。
 */
- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation NS_SWIFT_NAME(insertRow(at:animation:));

/**
 使用指定动画效果重载 indexPath 对应的行。

 @param indexPath  用于标识表格中某行的 NSIndexPath。
 @param animation  重载动画类型（如淡出、从底部滑出等），会同时影响旧行滑出和新行滑入方向。
 */
- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 删除 indexPath 对应的行，可选择是否动画。

 @param indexPath  用于标识表格中某行的 NSIndexPath。
 @param animation  删除时的动画类型（如淡出、从底部滑出等）。
 */
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 在指定位置插入一个 section，可选择是否动画。

 @param section   要插入的 section 索引；若该位置已有 section，会整体后移。
 @param animation 插入时的动画类型（如淡入、从左侧滑入等）。
 */
- (void)insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 删除指定 section，可选择是否动画。

 @param section   要删除的 section 索引；其后 section 会前移。
 @param animation 删除时的动画类型，或表示无动画的常量。
 */
- (void)deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 使用指定动画效果重载某个 section。

 @param section   要重载的 section 索引。
 @param animation 重载动画类型，会同时影响该 section 内旧行滑出和新行滑入方向。
 */
- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 取消 tableView 中所有行的选中状态。

 @param animated YES 为动画过渡，NO 为立即取消。
 */
- (void)clearSelectedRowsAnimated:(BOOL)animated;

/// 隐藏多余的线
- (void)extraCellLineHidden;

/**
 * 根据给定的indexPath，配合dataSource得到对应的cell在当前section中所处的位置
 * @param indexPath cell所在的indexPath
 * @return 给定indexPath对应的cell在当前section中所处的位置
 */
- (KAITableViewCellPosition)positionForRowAtIndexPath:(nullable NSIndexPath *)indexPath;

@end

/**
 系统在 iOS 13 新增了 UITableViewStyleInsetGrouped 类型用于展示往内缩进、cell 带圆角的列表，而这个 Category 让 iOS 12 及以下的系统也能支持这种样式，iOS 13 也可以通过这个 Category 修改左右的缩进值和 cell 的圆角。
 使用方式：
 对于 UITableView，通过 -[UITableView initWithStyle:UITableViewStyleInsetGrouped] 初始化 tableView。
 对于 UITableViewController，通过 -[UITableViewController initWithStyle:UITableViewStyleInsetGrouped] 初始化 tableViewController。
 可通过 @c kai_insetGroupedCornerRadius @c kai_insetGroupedHorizontalInset 统一修改圆角值和左右缩进，如果要为不同 indexPath 指定不同圆角值，可在 -[UITableViewDelegate tableView:willDisplayCell:forRowAtIndexPath:] 内修改 cell.layer.cornerRadius 的值。
 */
@interface UITableView (ZKAdd_InsetGrouped)

/// 当使用 UITableViewStyleInsetGrouped 时可通过这个属性修改 cell 的圆角值，默认值为 10，也即 iOS 13 系统默认表现。如果要为不同 indexPath 指定不同圆角值，可在 -[UITableViewDelegate tableView:willDisplayCell:forRowAtIndexPath:] 内修改 cell.layer.cornerRadius 的值。
@property (nonatomic, assign) IBInspectable CGFloat kai_insetGroupedCornerRadius UI_APPEARANCE_SELECTOR API_AVAILABLE(ios(13.0));

/// 当使用 UITableViewStyleInsetGrouped 时可通过这个属性修改列表的左右缩进值，默认值为 20，也即 iOS 13 系统默认表现。
@property (nonatomic, assign) IBInspectable CGFloat kai_insetGroupedHorizontalInset UI_APPEARANCE_SELECTOR API_AVAILABLE(ios(13.0));

@end

NS_ASSUME_NONNULL_END
