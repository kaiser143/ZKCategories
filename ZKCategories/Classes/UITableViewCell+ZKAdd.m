//
//  UITableViewCell+ZKAdd.m
//  Pods
//
//  Created by Kaiser on 2016/12/19.
//
//

#import "UITableViewCell+ZKAdd.h"
#import "UIView+ZKAdd.h"
#import "NSObject+ZKAdd.h"

@interface UITableViewCell ()

@end

@implementation UITableViewCell (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(initWithStyle:reuseIdentifier:) withMethod:@selector(zk_initWithStyle:reuseIdentifier:)];
}

- (instancetype)zk_initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    id object = [self zk_initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (object) {
        UIScrollView *scrollView = (UIScrollView *)[object descendantOrSelfWithClass:[UIScrollView class]];
        if (scrollView) {
            scrollView.delaysContentTouches = NO;
        }
        
        [(UIView *)object setClipsToBounds:YES];
    }
    
    return object;
}

- (UITableView *)tableView {
    return (UITableView *)[self ancestorOrSelfWithClass:[UITableView class]];
}

- (NSIndexPath *)indexPath {
    return [[self tableView] indexPathForCell:self];
}

@end
