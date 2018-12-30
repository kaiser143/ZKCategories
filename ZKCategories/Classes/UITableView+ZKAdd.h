//
//  UITableView+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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

- (void)scrollToTop:(BOOL)animated;

- (void)scrollToBottom:(BOOL)animated;

- (void)scrollToFirstRow:(BOOL)animated;

- (void)scrollToLastRow:(BOOL)animated;

- (void)touchRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
