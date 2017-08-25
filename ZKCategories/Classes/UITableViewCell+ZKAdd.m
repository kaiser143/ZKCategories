//
//  UITableViewCell+ZKAdd.m
//  Pods
//
//  Created by Kaiser on 2016/12/19.
//
//

#import "UITableViewCell+ZKAdd.h"
#import "UIView+ZKAdd.h"
#import <objc/runtime.h>

@interface UITableViewCell ()

@end

@implementation UITableViewCell (ZKAdd)

+ (void)load {
    Method originalMethod = class_getInstanceMethod(self, @selector(initWithStyle:reuseIdentifier:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(zk_initWithStyle:reuseIdentifier:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
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
