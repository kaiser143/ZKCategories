//
//  NSObject+ZKAdd.m
//  Pods
//
//  Created by Kaiser on 2017/1/11.
//
//

#import "NSObject+ZKAdd.h"
#import "NSDate+ZKAdd.h"

@implementation NSObject (ZKAdd)

#pragma mark URL Parameter Strings

- (NSString *)URLParameterStringValue {
    NSString *stringValue = nil;
    
    if ([self isKindOfClass: [NSString class]]) {
        stringValue = (NSString *)self;
    }
    else if ([self isKindOfClass: [NSNumber class]]) {
        stringValue = [(NSNumber *)self stringValue];
    }
    else if ([self isKindOfClass: [NSDate class]]) {
        stringValue = [(NSDate *)self HTTPTimeZoneHeaderString];
    }
    
    return stringValue;
}

#pragma mark - Safe Perform

- (id)safePerform:(SEL)selector {
    return [self safePerform:selector withObject:nil];
}

- (id)safePerform:(SEL)selector withObject:(id)object {
    NSParameterAssert(selector != NULL);
    NSParameterAssert([self respondsToSelector:selector]);
    
    if ([self respondsToSelector:selector]) {
        NSMethodSignature* methodSig = [self methodSignatureForSelector:selector];
        if(methodSig == nil) {
            return nil;
        }
        
        const char* retType = [methodSig methodReturnType];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if(strcmp(retType, @encode(void)) != 0) {
            return [self performSelector:selector withObject:object];
        } else {
            [self performSelector:selector withObject:object];
            return nil;
        }
#pragma clang diagnostic pop
    } else {
#ifndef NS_BLOCK_ASSERTIONS
        NSString *message =
        [NSString stringWithFormat:@"%@ does not recognize selector %@",
         self,
         NSStringFromSelector(selector)];
        NSAssert(false, message);
#endif
        return nil;
    }
}

@end
