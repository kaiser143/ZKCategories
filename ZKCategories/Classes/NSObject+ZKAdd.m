//
//  NSObject+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/1/11.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import "NSObject+ZKAdd.h"
#import "NSDate+ZKAdd.h"
#import <objc/runtime.h>

static inline dispatch_time_t dTimeDelay(NSTimeInterval time) {
    int64_t delta = (int64_t)(NSEC_PER_SEC * time);
    return dispatch_time(DISPATCH_TIME_NOW, delta);
}

@interface ZKObjectBlockExecutor : NSObject

@property (nonatomic, copy) void(^deallocBlock)(void);

@end

@implementation ZKObjectBlockExecutor

+ (id)blockExecutorWithDeallocBlock:(void(^)(void))block {
    ZKObjectBlockExecutor *executor = [[ZKObjectBlockExecutor alloc] init];
    executor.deallocBlock = block; // copy
    return executor;
}

- (void)dealloc {
    if (_deallocBlock) {
        _deallocBlock();
        _deallocBlock = nil;
    }
}

@end

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

+ (ZKNSObjectDelayBlock)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL) = ^(BOOL cancel) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled)block();
    };
    
    wrappingBlock = [wrappingBlock copy];
    
    dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO); });
    
    return wrappingBlock;
}

+ (void)cancelBlock:(ZKNSObjectDelayBlock)block {
    if (!block) return;
    void (^aWrappingBlock)(BOOL) = (void(^)(BOOL))block;
    aWrappingBlock(YES);
}

+ (void)cancelPreviousPerformBlock:(ZKNSObjectDelayBlock)aWrappingBlockHandle {
    [self cancelBlock:aWrappingBlockHandle];
}

@end


@implementation NSObject (ZKRuntime)

static char DTRuntimeDeallocBlocks;

- (void)addDeallocBlock:(void(^)(void))block {
    // don't accept NULL block
    NSParameterAssert(block);

    NSMutableArray *deallocBlocks = objc_getAssociatedObject(self, &DTRuntimeDeallocBlocks);
    
    // add array of dealloc blocks if not existing yet
    if (!deallocBlocks)
    {
        deallocBlocks = [[NSMutableArray alloc] init];
        
        objc_setAssociatedObject(self, &DTRuntimeDeallocBlocks, deallocBlocks, OBJC_ASSOCIATION_RETAIN);
    }
    
    ZKObjectBlockExecutor *executor = [ZKObjectBlockExecutor blockExecutorWithDeallocBlock:block];
    
    [deallocBlocks addObject:executor];
}

+ (BOOL)addInstanceMethodWithSelectorName:(NSString *)selectorName block:(void(^)(id))block {
    // don't accept nil name
    NSParameterAssert(selectorName);
    
    // don't accept NULL block
    NSParameterAssert(block);
    
    // See http://stackoverflow.com/questions/6357663/casting-a-block-to-a-void-for-dynamic-class-method-resolution
    
#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_7
    void *impBlockForIMP = (void *)objc_unretainedPointer(block);
#else
    id impBlockForIMP = (__bridge id)(__bridge void *)(block);
#endif
    
    IMP myIMP = imp_implementationWithBlock(impBlockForIMP);
    
    SEL selector = NSSelectorFromString(selectorName);
    return class_addMethod(self, selector, myIMP, "v@:");
}

#pragma mark - Method Swizzling

+ (void)swizzleMethod:(SEL)selector withMethod:(SEL)otherSelector {
    // my own class is being targetted
    Class myClass = [self class];
    
    // get the methods from the selectors
    Method originalMethod = class_getInstanceMethod(myClass, selector);
    Method otherMethod = class_getInstanceMethod(myClass, otherSelector);
    
    if (class_addMethod(myClass, selector, method_getImplementation(otherMethod), method_getTypeEncoding(otherMethod))) {
        class_replaceMethod(myClass, otherSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, otherMethod);
    }
}

+ (void)swizzleClassMethod:(SEL)selector withMethod:(SEL)otherSelector {
    // my own class is being targetted
    Class myClass = [self class];
    
    // get the methods from the selectors
    Method originalMethod = class_getClassMethod(myClass, selector);
    Method otherMethod = class_getClassMethod(myClass, otherSelector);
    
    //    if (class_addMethod(c, selector, method_getImplementation(otherMethod), method_getTypeEncoding(otherMethod)))
    //    {
    //        class_replaceMethod(c, otherSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    //    }
    //    else
    //    {
    method_exchangeImplementations(originalMethod, otherMethod);
    //    }
}

- (void)setAssociateValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setAssociateWeakValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (void)removeAssociatedValues {
    objc_removeAssociatedObjects(self);
}

- (id)associatedValueForKey:(void *)key {
    return objc_getAssociatedObject(self, key);
}

+ (NSString *)className {
    return NSStringFromClass(self);
}

- (NSString *)className {
    return [NSString stringWithUTF8String:class_getName([self class])];
}

- (id)deepCopy {
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return obj;
}

- (id)deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver {
    id obj = nil;
    @try {
        obj = [unarchiver unarchiveObjectWithData:[archiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return obj;
}

@end

