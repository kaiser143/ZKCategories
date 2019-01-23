//
//  UINavigationItem+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UINavigationItem+ZKAdd.h"
#import "NSObject+ZKAdd.h"

@implementation UINavigationItem (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(leftBarButtonItem) withMethod:@selector(kai_leftBarButtonItem)];
    [self swizzleMethod:@selector(setLeftBarButtonItem:animated:) withMethod:@selector(kai_setLeftBarButtonItem:animated:)];
    [self swizzleMethod:@selector(leftBarButtonItems) withMethod:@selector(kai_leftBarButtonItems)];
    [self swizzleMethod:@selector(setLeftBarButtonItem:animated:) withMethod:@selector(kai_setLeftBarButtonItem:animated:)];
    
    [self swizzleMethod:@selector(rightBarButtonItem) withMethod:@selector(kai_rightBarButtonItem)];
    [self swizzleMethod:@selector(setRightBarButtonItem:animated:) withMethod:@selector(kai_setRightBarButtonItem:animated:)];
    [self swizzleMethod:@selector(rightBarButtonItems) withMethod:@selector(kai_rightBarButtonItems)];
    [self swizzleMethod:@selector(setRightBarButtonItem:animated:) withMethod:@selector(kai_setRightBarButtonItem:animated:)];
}

+ (CGFloat)systemMargin {
    return 16; // iOS 7+
}

#pragma mark - Margin

- (CGFloat)leftMargin {
    NSNumber *value = [self associatedValueForKey:_cmd];
    return value ? value.floatValue : [self.class systemMargin];
}

- (void)setLeftMargin:(CGFloat)leftMargin {
    [self setAssociateValue:@(leftMargin) withKey:@selector(leftMargin)];
    self.leftBarButtonItems = self.leftBarButtonItems;
}

- (CGFloat)rightMargin {
    NSNumber *value = [self associatedValueForKey:_cmd];
    return value ? value.floatValue : [self.class systemMargin];
}

- (void)setRightMargin:(CGFloat)rightMargin {
    [self setAssociateValue:@(rightMargin) withKey:@selector(rightMargin)];
    self.rightBarButtonItems = self.rightBarButtonItems;
}

- (NSArray *)originalLeftBarButtonItems {
    return [self associatedValueForKey:_cmd];
}

- (void)setOriginalLeftBarButtonItems:(NSArray *)items {
    [self setAssociateValue:items withKey:@selector(originalLeftBarButtonItems)];
}

- (NSArray *)originalRightBarButtonItems {
    return [self associatedValueForKey:_cmd];
}

- (void)setOriginalRightBarButtonItems:(NSArray *)items {
    [self setAssociateValue:items withKey:@selector(originalRightBarButtonItems)];
}

- (UIBarButtonItem *)leftSpacerForItem:(UIBarButtonItem *)item {
    return [self spacerForItem:item withMargin:self.leftMargin];
}

- (UIBarButtonItem *)rightSpacerForItem:(UIBarButtonItem *)item {
    return [self spacerForItem:item withMargin:self.rightMargin];
}

- (UIBarButtonItem *)spacerForItem:(UIBarButtonItem *)item withMargin:(CGFloat)margin {
    UIBarButtonSystemItem type = UIBarButtonSystemItemFixedSpace;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:type target:self action:nil];
    spacer.width = margin - [self.class systemMargin];
    if (!item.customView) {
        spacer.width -= 2; // a margin of private class `UINavigationButton` is different from custom view
    }
    return spacer;
}

#pragma mark - Bar Button Item

- (UIBarButtonItem *)kai_leftBarButtonItem {
    return self.originalLeftBarButtonItems.firstObject;
}

- (void)kai_setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    if (!item) {
        [self setLeftBarButtonItems:nil animated:animated];
    } else {
        [self setLeftBarButtonItems:@[ item ] animated:animated];
    }
}

- (UIBarButtonItem *)kai_rightBarButtonItem {
    return self.originalRightBarButtonItems.firstObject;
}

- (void)kai_setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    if (!item) {
        [self setRightBarButtonItems:nil animated:animated];
    } else {
        [self setRightBarButtonItems:@[ item ] animated:animated];
    }
}

#pragma mark - Bar Button Items

- (NSArray *)kai_leftBarButtonItems {
    return self.originalLeftBarButtonItems;
}

- (void)kai_setLeftBarButtonItems:(NSArray *)items animated:(BOOL)animated {
    if (items.count) {
        self.originalLeftBarButtonItems = items;
        UIBarButtonItem *spacer = [self leftSpacerForItem:items.firstObject];
        NSArray *itemsWithMargin = [@[ spacer ] arrayByAddingObjectsFromArray:items];
        [self kai_setLeftBarButtonItems:itemsWithMargin animated:animated];
    } else {
        self.originalLeftBarButtonItems = nil;
        [self kai_setLeftBarButtonItem:nil animated:animated];
    }
}

- (NSArray *)kai_rightBarButtonItems {
    return self.originalRightBarButtonItems;
}

- (void)kai_setRightBarButtonItems:(NSArray *)items animated:(BOOL)animated {
    if (items.count) {
        self.originalRightBarButtonItems = items;
        UIBarButtonItem *spacer = [self rightSpacerForItem:items.firstObject];
        NSArray *itemsWithMargin = [@[ spacer ] arrayByAddingObjectsFromArray:items];
        [self kai_setRightBarButtonItems:itemsWithMargin animated:animated];
    } else {
        self.originalRightBarButtonItems = nil;
        [self kai_setRightBarButtonItem:nil animated:animated];
    }
}


@end
