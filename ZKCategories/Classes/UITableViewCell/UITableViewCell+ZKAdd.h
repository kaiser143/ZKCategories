//
//  UITableViewCell+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/19.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+ZKAdd.h"

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (ZKAdd)

/// cell 在当前 section 里的位置，在 willDisplayCell 时可以使用，cellForRow 里只能自己使用 -[UITableView positionForRowAtIndexPath:] 获取。
@property(nonatomic, assign, readonly) KAITableViewCellPosition cellPosition;

/// 获取当前 cell 所在的 tableView，iOS 13 下在 cellForRow(heightForRow 内不可以) 内 init 完 cell 就可以获取到值，而 iOS 12 及以下只能在 cell 即将显示时（也即 willDisplay 之前）才能获取到值
@property(nonatomic, weak, readonly, nullable) UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
