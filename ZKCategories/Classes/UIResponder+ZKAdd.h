//
//  UIResponder+ZKAdd.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2018/5/18.
//

#import <UIKit/UIKit.h>

@interface UIResponder (ZKAdd)

/**
 Returns the current first responder object.
 
 @return A UIResponder instance.
 */
+ (nullable instancetype)currentFirstResponder;

@end
