//
//  UIColor+ZKAdd.m
//  FBSnapshotTestCase
//
//  Created by zhangkai on 2017/9/25.
//

#import "UIColor+ZKAdd.h"

@implementation UIColor (ZKAdd)

+ (UIColor *)randomColor {
    NSInteger aRedValue = arc4random() % 255;
    NSInteger aGreenValue = arc4random() % 255;
    NSInteger aBlueValue = arc4random() % 255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue / 255.0f green:aGreenValue / 255.0f blue:aBlueValue / 255.0f alpha:1.0f];
    return randColor;
}

@end
