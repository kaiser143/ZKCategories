//
//  NSObject+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/1/11.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import "NSObject+ZKAdd.h"
#import "NSDate+ZKAdd.h"
#import "NSArray+ZKAdd.h"
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

- (void)setStringProperty:(NSString *)stringProperty {
    [self setAssociateValue:stringProperty withKey:@selector(stringProperty)];
}

- (NSString *)stringProperty {
    return [self associatedValueForKey:_cmd];
}

- (void)setIntegerProperty:(NSInteger)integerProperty {
    [self setAssociateValue:@(integerProperty) withKey:@selector(integerProperty)];
}

- (NSInteger)integerProperty {
    return [[self associatedValueForKey:_cmd] integerValue];
}

- (void)setExtra:(id)extra {
    [self setAssociateValue:extra withKey:@selector(extra)];
}

- (id)extra {
    return [self associatedValueForKey:_cmd];
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

- (void)setAssociateCopyValue:(id)value withKey:(void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
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


@interface _ZKNSObjetKVOBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(__weak id obj, id oldVal, id newVal);

- (id)initWithBlock:(void (^)(__weak id obj, id oldVal, id newVal))block;

@end

@implementation _ZKNSObjetKVOBlockTarget

- (id)initWithBlock:(void (^)(__weak id obj, id oldVal, id newVal))block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!self.block) return;
    
    BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    if (isPrior) return;
    
    NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (changeKind != NSKeyValueChangeSetting) return;
    
    id oldVal = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldVal == [NSNull null]) oldVal = nil;
    
    id newVal = [change objectForKey:NSKeyValueChangeNewKey];
    if (newVal == [NSNull null]) newVal = nil;
    
    self.block(object, oldVal, newVal);
}

@end


@interface _ZKKVOInfo : NSObject

@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, weak) NSObject *observer;

- (instancetype)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

@implementation _ZKKVOInfo

- (instancetype)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    self = [super init];
    if (self == nil) return nil;
    
    self.observer = observer;
    self.keyPath = keyPath;
    
    return self;
}

@end


@implementation NSObject (ZKAddForKVO)

+ (void)load {
    [self swizzleMethod:@selector(addObserver:forKeyPath:options:context:) withMethod:@selector(_kai_addObserver:forKeyPath:options:context:)];
    [self swizzleMethod:@selector(removeObserver:forKeyPath:context:) withMethod:@selector(_kai_removeObserver:forKeyPath:context:)];
}

- (void)addObserverBlockForKeyPath:(NSString *)keyPath block:(void (^)(__weak id obj, id oldVal, id newVal))block {
    if (!keyPath || !block) return;
    _ZKNSObjetKVOBlockTarget *target = [[_ZKNSObjetKVOBlockTarget alloc] initWithBlock:block];
    NSMutableDictionary *dic = [self _kai_allNSObjectObserverBlocks];
    NSMutableArray *arr = dic[keyPath];
    if (!arr) {
        arr = [NSMutableArray new];
        dic[keyPath] = arr;
    }
    [arr addObject:target];
    [self addObserver:target forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

- (void)removeObserverBlocksForKeyPath:(NSString *)keyPath {
    if (!keyPath) return;
    NSMutableDictionary *dic = [self _kai_allNSObjectObserverBlocks];
    NSMutableArray *arr = dic[keyPath];
    [arr enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeObserver:obj forKeyPath:keyPath];
    }];
    
    [dic removeObjectForKey:keyPath];
}

- (void)removeObserverBlocks {
    NSMutableDictionary *dic = [self _kai_allNSObjectObserverBlocks];
    [dic enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSArray *arr, BOOL *stop) {
        [arr enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            [self removeObserver:obj forKeyPath:key];
        }];
    }];
    
    [dic removeAllObjects];
}

- (NSMutableDictionary *)_kai_allNSObjectObserverBlocks {
    NSMutableDictionary *targets = [self associatedValueForKey:_cmd];
    if (!targets) {
        targets = [NSMutableDictionary new];
        [self setAssociateValue:targets withKey:_cmd];
    }
    return targets;
}

/// 解决重复removeObserver 引起的闪退
- (NSMutableDictionary<NSString *, NSMutableArray *> *)_kai_allObserverInfos {
    NSMutableDictionary *infos = [self associatedValueForKey:_cmd];
    if (!infos) {
        infos = [NSMutableDictionary new];
        [self setAssociateValue:infos withKey:_cmd];
    }
    return infos;
}

- (void)_kai_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if (!observer || !keyPath) return;
    
    _ZKKVOInfo *info = [[_ZKKVOInfo alloc] initWithObserver:observer forKeyPath:keyPath];
    NSMutableDictionary *dic = [self _kai_allObserverInfos];
    NSMutableArray *arr = dic[keyPath];
    if (!arr) {
        arr = [NSMutableArray new];
        dic[keyPath] = arr;
    }
    [arr addObject:info];
    [self _kai_addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)_kai_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    if (![self _kai_observerKeyPath:keyPath observer:observer]) return;
    
    [self _kai_removeObserver:observer forKeyPath:keyPath context:context];
    
    NSMutableDictionary *dic = [self _kai_allObserverInfos];
    NSMutableArray *array = dic[keyPath];
    _ZKKVOInfo *info = [array objectPassingTest:^BOOL(_ZKKVOInfo *obj) {
        return ([observer isEqual:obj.observer] && [keyPath isEqualToString:obj.keyPath]);
    }];
    if (info) [array removeObject:info];
}

- (BOOL)_kai_observerKeyPath:(NSString *)keyPath observer:(id)observer {
    NSMutableDictionary *dic = [self _kai_allObserverInfos];
    NSArray *array = dic[keyPath];
    _ZKKVOInfo *info = [array objectPassingTest:^BOOL(_ZKKVOInfo *obj) {
        return ([observer isEqual:obj.observer] && [keyPath isEqualToString:obj.keyPath]);
    }];
    return info ? YES : NO;
}

// AVPlayerLayer 类在调用 observationInfo 会引起闪退“*** -[AVPlayerLayer release]: message sent to deallocated instance 0x600002da1f20”
//- (BOOL)_kai_observerKeyPath:(NSString *)key observer:(id)observer {
//    id info = self.observationInfo;
//    NSArray *array = [info valueForKey:@"_observances"];
//    for (id objc in array) {
//        id Properties = [objc valueForKeyPath:@"_property"];
//        id newObserver = [objc valueForKeyPath:@"_observer"];
//
//        NSString *keyPath = [Properties valueForKeyPath:@"_keyPath"];
//        if ([key isEqualToString:keyPath] && [newObserver isEqual:observer]) {
//            return YES;
//        }
//    }
//    return NO;
//}

@end
