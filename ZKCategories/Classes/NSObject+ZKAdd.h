//
//  NSObject+ZKAdd.h
//  Pods
//
//  Created by Kaiser on 2017/1/11.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (ZKAdd)

// URL Parameter Strings
- (NSString *)URLParameterStringValue;

- (id)safePerform:(SEL)selector;
- (id)safePerform:(SEL)selector withObject:(id)object;

@end
