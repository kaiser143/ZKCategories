//
//  ZKCGUtilities.m
//  shandiansong
//
//  Created by Kaiser on 2016/10/25.
//  Copyright © 2016年 zhiqiyun. All rights reserved.
//

#import "ZKCGUtilities.h"

CGSize ZKScreenSize() {
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [UIScreen mainScreen].bounds.size;
        if (size.height < size.width) {
            CGFloat tmp = size.height;
            size.height = size.width;
            size.width = tmp;
        }
    });
    return size;
}

CGFloat ZKScreenScale() {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
}
