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
    KAITableViewCellPositionNone               = 0, // 默认
    KAITableViewCellPositionFirstInSection     = 1 << 0,
    KAITableViewCellPositionMiddleInSection    = 1 << 1,
    KAITableViewCellPositionLastInSection      = 1 << 2,
    KAITableViewCellPositionSingleInSection    = KAITableViewCellPositionFirstInSection | KAITableViewCellPositionLastInSection,
};

@interface UITableView (ZKAdd)

/**
 * The view that contains the "index" along the right side of the table.
 */
@property (nonatomic, readonly) UIView *indexView;

/**
 * Returns the margin used to inset table cells.
 *
 * Grouped tables have a margin but plain tables don't.  This is useful in table cell
 * layout calculations where you don't want to hard-code the table style.
 */
@property (nonatomic, readonly) CGFloat tableCellMargin;

- (void)scrollToFirstRow:(BOOL)animated;

- (void)scrollToLastRow:(BOOL)animated;

- (void)touchRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

/**
 Perform a series of method calls that insert, delete, or select rows and
 sections of the receiver.
 
 @discussion Perform a series of method calls that insert, delete, or select
 rows and sections of the table. Call this method if you want
 subsequent insertions, deletion, and selection operations (for
 example, cellForRowAtIndexPath: and indexPathsForVisibleRows)
 to be animated simultaneously.
 
 @discussion If you do not make the insertion, deletion, and selection calls
 inside this block, table attributes such as row count might become
 invalid. You should not call reloadData within the block; if you
 call this method within the group, you will need to perform any
 animations yourself.
 
 @param block  A block combine a series of method calls.
 */
- (void)updateWithBlock:(void (^)(UITableView *tableView))block;

/**
 Scrolls the receiver until a row or section location on the screen.
 
 @discussion            Invoking this method does not cause the delegate to
 receive a scrollViewDidScroll: message, as is normal for
 programmatically-invoked user interface operations.
 
 @param row             Row index in section. NSNotFound is a valid value for
 scrolling to a section with zero rows.
 
 @param section         Section index in table.
 
 @param scrollPosition  A constant that identifies a relative position in the
 receiving table view (top, middle, bottom) for row when
 scrolling concludes.
 
 @param animated        YES if you want to animate the change in position,
 NO if it should be immediate.
 */
- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated NS_SWIFT_NAME(scroll(to:inSection:atPosition:animated:));

/**
 Inserts a row in the receiver with an option to animate the insertion.
 
 @param row        Row index in section.
 
 @param section    Section index in table.
 
 @param animation  A constant that either specifies the kind of animation to
 perform when inserting the cell or requests no animation.
 */
- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Reloads the specified row using a certain animation effect.
 
 @param row        Row index in section.
 
 @param section    Section index in table.
 
 @param animation  A constant that indicates how the reloading is to be animated,
 for example, fade out or slide out from the bottom. The animation
 constant affects the direction in which both the old and the
 new rows slide. For example, if the animation constant is
 UITableViewRowAnimationRight, the old rows slide out to the
 right and the new cells slide in from the right.
 */
- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Deletes the row with an option to animate the deletion.
 
 @param row        Row index in section.
 
 @param section    Section index in table.
 
 @param animation  A constant that indicates how the deletion is to be animated,
 for example, fade out or slide out from the bottom.
 */
- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Inserts the row in the receiver at the locations identified by the indexPath,
 with an option to animate the insertion.
 
 @param indexPath  An NSIndexPath object representing a row index and section
 index that together identify a row in the table view.
 
 @param animation  A constant that either specifies the kind of animation to
 perform when inserting the cell or requests no animation.
 */
- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation NS_SWIFT_NAME(insertRow(at:animation:));

/**
 Reloads the specified row using a certain animation effect.
 
 @param indexPath  An NSIndexPath object representing a row index and section
 index that together identify a row in the table view.
 
 @param animation A constant that indicates how the reloading is to be animated,
 for example, fade out or slide out from the bottom. The animation
 constant affects the direction in which both the old and the
 new rows slide. For example, if the animation constant is
 UITableViewRowAnimationRight, the old rows slide out to the
 right and the new cells slide in from the right.
 */
- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Deletes the row specified by an array of index paths,
 with an option to animate the deletion.
 
 @param indexPath  An NSIndexPath object representing a row index and section
 index that together identify a row in the table view.
 
 @param animation  A constant that indicates how the deletion is to be animated,
 for example, fade out or slide out from the bottom.
 */
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Inserts a section in the receiver, with an option to animate the insertion.
 
 @param section    An index specifies the section to insert in the receiving
 table view. If a section already exists at the specified
 index location, it is moved down one index location.
 
 @param animation  A constant that indicates how the insertion is to be animated,
 for example, fade in or slide in from the left.
 */
- (void)insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Deletes a section in the receiver, with an option to animate the deletion.
 
 @param section    An index that specifies the sections to delete from the
 receiving table view. If a section exists after the specified
 index location, it is moved up one index location.
 
 @param animation  A constant that either specifies the kind of animation to
 perform when deleting the section or requests no animation.
 */
- (void)deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Reloads the specified section using a given animation effect.
 
 @param section    An index identifying the section to reload.
 
 @param animation  A constant that indicates how the reloading is to be animated,
 for example, fade out or slide out from the bottom. The
 animation constant affects the direction in which both the
 old and the new section rows slide. For example, if the
 animation constant is UITableViewRowAnimationRight, the old
 rows slide out to the right and the new cells slide in from the right.
 */
- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 Unselect all rows in tableView.
 
 @param animated YES to animate the transition, NO to make the transition immediate.
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
@property(nonatomic, assign) CGFloat kai_insetGroupedCornerRadius UI_APPEARANCE_SELECTOR;

/// 当使用 UITableViewStyleInsetGrouped 时可通过这个属性修改列表的左右缩进值，默认值为 20，也即 iOS 13 系统默认表现。
@property(nonatomic, assign) CGFloat kai_insetGroupedHorizontalInset UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
