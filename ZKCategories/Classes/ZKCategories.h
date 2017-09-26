//
//  ZKCategories.h
//  Pods
//
//  Created by Kaiser on 2016/12/14.
//
//

#import <UIKit/UIKit.h>

#if __has_include(<ZKCategories/ZKCategories.h>)
    #import <ZKCategories/NSObject+ZKAdd.h>
    #import <ZKCategories/NSDictionary+ZKAdd.h>
    #import <ZKCategories/NSDate+ZKAdd.h>
    #import <ZKCategories/NSNumber+ZKAdd.h>
    #import <ZKCategories/NSString+ZKAdd.h>
    #import <ZKCategories/NSURL+ZKAdd.h>
    #import <ZKCategories/NSRunLoop+ZKAdd.h>
    #import <ZKCategories/NSDecimalNumber+ZKAdd.h>
    #import <ZKCategories/UIBarButtonItem+ZKAdd.h>
    #import <ZKCategories/UIImagePickerController+ZKAdd.h>
    #import <ZKCategories/UINavigationController+ZKAdd.h>
    #import <ZKCategories/UIView+ZKAdd.h>
    #import <ZKCategories/UITableView+ZKAdd.h>
    #import <ZKCategories/UIWindow+ZKAdd.h>
    #import <ZKCategories/ZKCGUtilities.h>
//    #import <ZKCategories/UIColor+ZKAdd.h>
#else
    #import "NSObject+ZKAdd.h"
    #import "NSDictionary+ZKAdd.h"
    #import "NSDate+ZKAdd.h"
    #import "NSNumber+ZKAdd.h"
    #import "NSString+ZKAdd.h"
    #import "NSURL+ZKAdd.h"
    #import "NSRunLoop+ZKAdd.h"
    #import "NSDecimalNumber+ZKAdd.h"
    #import "UIBarButtonItem+ZKAdd.h"
    #import "UIImagePickerController+ZKAdd.h"
    #import "UINavigationController+ZKAdd.h"
    #import "UIView+ZKAdd.h"
    #import "UITableView+ZKAdd.h"
    #import "UIWindow+ZKAdd.h"
    #import "ZKCGUtilities.h"
    #import "UIColor+ZKAdd.h"
#endif
