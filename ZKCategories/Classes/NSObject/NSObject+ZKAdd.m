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
#import <objc/message.h>

static inline dispatch_time_t dTimeDelay(NSTimeInterval time) {
    int64_t delta = (int64_t)(NSEC_PER_SEC * time);
    return dispatch_time(DISPATCH_TIME_NOW, delta);
}

@interface _KAIBlockExecutor : NSObject

@property (nonatomic, copy) void (^deallocBlock)(void);

@end

@implementation _KAIBlockExecutor

+ (id)blockExecutorWithDeallocBlock:(void (^)(void))block {
    _KAIBlockExecutor *executor = [[_KAIBlockExecutor alloc] init];
    executor.deallocBlock       = block; // copy
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

    if ([self isKindOfClass:[NSString class]]) {
        stringValue = (NSString *)self;
    } else if ([self isKindOfClass:[NSNumber class]]) {
        stringValue = [(NSNumber *)self stringValue];
    } else if ([self isKindOfClass:[NSDate class]]) {
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
        NSMethodSignature *methodSig = [self methodSignatureForSelector:selector];
        if (methodSig == nil) {
            return nil;
        }

        const char *retType = [methodSig methodReturnType];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (strcmp(retType, @encode(void)) != 0) {
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
        if (!cancelled) block();
    };

    wrappingBlock = [wrappingBlock copy];

    dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{ wrappingBlock(NO); });

    return wrappingBlock;
}

+ (void)cancelBlock:(ZKNSObjectDelayBlock)block {
    if (!block) return;
    void (^aWrappingBlock)(BOOL) = (void (^)(BOOL))block;
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

- (void)addDeallocBlock:(void (^)(void))block {
    // don't accept NULL block
    NSParameterAssert(block);

    NSMutableArray *deallocBlocks = objc_getAssociatedObject(self, &DTRuntimeDeallocBlocks);

    // add array of dealloc blocks if not existing yet
    if (!deallocBlocks) {
        deallocBlocks = [[NSMutableArray alloc] init];

        objc_setAssociatedObject(self, &DTRuntimeDeallocBlocks, deallocBlocks, OBJC_ASSOCIATION_RETAIN);
    }

    _KAIBlockExecutor *executor = [_KAIBlockExecutor blockExecutorWithDeallocBlock:block];

    [deallocBlocks addObject:executor];
}

+ (BOOL)addInstanceMethodWithSelectorName:(NSString *)selectorName block:(void (^)(id))block {
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
    Method otherMethod    = class_getInstanceMethod(myClass, otherSelector);

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
    Method otherMethod    = class_getClassMethod(myClass, otherSelector);

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

- (NSDictionary *)propertyDictionary {
    //创建可变字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t prop = props[i];
        NSString *propName   = [[NSString alloc] initWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
        id propValue         = [self valueForKey:propName];
        [dict setObject:propValue ?: [NSNull null] forKey:propName];
    }
    free(props);
    return dict;
}

- (NSArray *)propertyKeys {
    return [[self class] propertyKeys];
}

+ (NSArray *)propertyKeys {
    unsigned int propertyCount    = 0;
    objc_property_t *properties   = class_copyPropertyList(self, &propertyCount);
    NSMutableArray *propertyNames = [NSMutableArray array];
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char *name         = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    return propertyNames;
}

- (NSArray *)propertiesInfo {
    return [[self class] propertiesInfo];
}

/**
 *  @brief 属性列表与属性的各种信息
 */
+ (NSArray *)propertiesInfo {
    NSMutableArray *propertieArray = [NSMutableArray array];

    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);

    for (int i = 0; i < propertyCount; i++) {
        [propertieArray addObject:({

                            NSDictionary *dictionary = [self dictionaryWithProperty:properties[i]];

                            dictionary;
                        })];
    }

    free(properties);

    return propertieArray;
}

+ (NSArray *)propertiesWithCodeFormat {
    NSMutableArray *array = [NSMutableArray array];

    NSArray *properties = [[self class] propertiesInfo];

    for (NSDictionary *item in properties) {
        NSMutableString *format = ({

            NSMutableString *formatString = [NSMutableString stringWithFormat:@"@property "];
            //attribute
            NSArray *attribute = [item objectForKey:@"attribute"];
            attribute          = [attribute sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2 options:NSNumericSearch];
            }];
            if (attribute && attribute.count > 0) {
                NSString *attributeStr = [NSString stringWithFormat:@"(%@)", [attribute componentsJoinedByString:@", "]];

                [formatString appendString:attributeStr];
            }

            //type
            NSString *type = [item objectForKey:@"type"];
            if (type) {
                [formatString appendString:@" "];
                [formatString appendString:type];
            }

            //name
            NSString *name = [item objectForKey:@"name"];
            if (name) {
                [formatString appendString:@" "];
                [formatString appendString:name];
                [formatString appendString:@";"];
            }

            formatString;
        });

        [array addObject:format];
    }

    return array;
}

- (NSArray *)methodList {
    u_int count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method *methods            = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        SEL name          = method_getName(methods[i]);
        NSString *strName = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        [methodList addObject:strName];
    }
    free(methods);
    return methodList;
}

- (NSArray *)methodListInfo {
    u_int count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method *methods            = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];

        Method method = methods[i];
        //        IMP imp = method_getImplementation(method);
        SEL name = method_getName(method);
        // 返回方法的参数的个数
        int argumentsCount = method_getNumberOfArguments(method);
        //获取描述方法参数和返回值类型的字符串
        const char *encoding = method_getTypeEncoding(method);
        //取方法的返回值类型的字符串
        const char *returnType = method_copyReturnType(method);

        NSMutableArray *arguments = [NSMutableArray array];
        for (int index = 0; index < argumentsCount; index++) {
            // 获取方法的指定位置参数的类型字符串
            char *arg = method_copyArgumentType(method, index);
            //            NSString *argString = [NSString stringWithCString:arg encoding:NSUTF8StringEncoding];
            [arguments addObject:[[self class] decodeType:arg]];
        }

        NSString *returnTypeString = [[self class] decodeType:returnType];
        NSString *encodeString     = [[self class] decodeType:encoding];
        NSString *nameString       = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];

        [info setObject:arguments forKey:@"arguments"];
        [info setObject:[NSString stringWithFormat:@"%d", argumentsCount] forKey:@"argumentsCount"];
        [info setObject:returnTypeString forKey:@"returnType"];
        [info setObject:encodeString forKey:@"encode"];
        [info setObject:nameString forKey:@"name"];
        //        [info setObject:imp_f forKey:@"imp"];
        [methodList addObject:info];
    }
    free(methods);
    return methodList;
}

+ (NSArray *)methodList {
    u_int count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method *methods            = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        SEL name          = method_getName(methods[i]);
        NSString *strName = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        [methodList addObject:strName];
    }
    free(methods);

    return methodList;
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

+ (NSDictionary *)dictionaryWithProperty:(objc_property_t)property {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    //name
    NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
    [result setObject:propertyName forKey:@"name"];

    //attribute

    NSMutableDictionary *attributeDictionary = ({

        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

        unsigned int attributeCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attributeCount);

        for (int i = 0; i < attributeCount; i++) {
            NSString *name  = [NSString stringWithCString:attrs[i].name encoding:NSUTF8StringEncoding];
            NSString *value = [NSString stringWithCString:attrs[i].value encoding:NSUTF8StringEncoding];
            [dictionary setObject:value forKey:name];
        }

        free(attrs);

        dictionary;
    });

    NSMutableArray *attributeArray = [NSMutableArray array];

    /***
     R           | The property is read-only (readonly).
     C           | The property is a copy of the value last assigned (copy).
     &           | The property is a reference to the value last assigned (retain).
     N           | The property is non-atomic (nonatomic).
     G<name>     | The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
     S<name>     | The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,).
     D           | The property is dynamic (@dynamic).
     W           | The property is a weak reference (__weak).
     P           | The property is eligible for garbage collection.
     t<encoding> | Specifies the type using old-style encoding.
     */

    //R
    if ([attributeDictionary objectForKey:@"R"])
        [attributeArray addObject:@"readonly"];

    //C
    if ([attributeDictionary objectForKey:@"C"])
        [attributeArray addObject:@"copy"];

    //&
    if ([attributeDictionary objectForKey:@"&"])
        [attributeArray addObject:@"strong"];

    //N
    if ([attributeDictionary objectForKey:@"N"])
        [attributeArray addObject:@"nonatomic"];
    else
        [attributeArray addObject:@"atomic"];

    //G<name>
    if ([attributeDictionary objectForKey:@"G"])
        [attributeArray addObject:[NSString stringWithFormat:@"getter=%@", [attributeDictionary objectForKey:@"G"]]];

    //S<name>
    if ([attributeDictionary objectForKey:@"S"])
        [attributeArray addObject:[NSString stringWithFormat:@"setter=%@", [attributeDictionary objectForKey:@"G"]]];

    //D
    if ([attributeDictionary objectForKey:@"D"])
        [result setObject:[NSNumber numberWithBool:YES] forKey:@"isDynamic"];
    else
        [result setObject:[NSNumber numberWithBool:NO] forKey:@"isDynamic"];

    //W
    if ([attributeDictionary objectForKey:@"W"])
        [attributeArray addObject:@"weak"];

    //P
    if ([attributeDictionary objectForKey:@"P"])
        //TODO:P | The property is eligible for garbage collection.

        //T
        if ([attributeDictionary objectForKey:@"T"]) {
            /*
             c               A char
             i               An int
             s               A short
             l               A long l is treated as a 32-bit quantity on 64-bit programs.
             q               A long long
             C               An unsigned char
             I               An unsigned int
             S               An unsigned short
             L               An unsigned long
             Q               An unsigned long long
             f               A float
             d               A double
             B               A C++ bool or a C99 _Bool
             v               A void
             *               A character string (char *)
             @               An object (whether statically typed or typed id)
             #               A class object (Class)
             :               A method selector (SEL)
             [array type]    An array
             {name=type...}  A structure
             (name=type...)  A union
             bnum            A bit field of num bits
             ^type           A pointer to type
             ?               An unknown type (among other things, this code is used for function pointers)
             
             */

            NSDictionary *typeDic = @{ @"c": @"char",
                                       @"i": @"int",
                                       @"s": @"short",
                                       @"l": @"long",
                                       @"q": @"long long",
                                       @"C": @"unsigned char",
                                       @"I": @"unsigned int",
                                       @"S": @"unsigned short",
                                       @"L": @"unsigned long",
                                       @"Q": @"unsigned long long",
                                       @"f": @"float",
                                       @"d": @"double",
                                       @"B": @"BOOL",
                                       @"v": @"void",
                                       @"*": @"char *",
                                       @"@": @"id",
                                       @"#": @"Class",
                                       @":": @"SEL",
            };
            //TODO:An array
            NSString *key = [attributeDictionary objectForKey:@"T"];

            id type_str = [typeDic objectForKey:key];

            if (type_str == nil) {
                if ([[key substringToIndex:1] isEqualToString:@"@"] && [key rangeOfString:@"?"].location == NSNotFound) {
                    type_str = [[key substringWithRange:NSMakeRange(2, key.length - 3)] stringByAppendingString:@"*"];
                } else if ([[key substringToIndex:1] isEqualToString:@"^"]) {
                    id str = [typeDic objectForKey:[key substringFromIndex:1]];

                    if (str) {
                        type_str = [NSString stringWithFormat:@"%@ *", str];
                    }
                } else {
                    type_str = @"unknow";
                }
            }

            [result setObject:type_str forKey:@"type"];
        }

    [result setObject:attributeArray forKey:@"attribute"];

    return result;
}

+ (NSString *)decodeType:(const char *)cString {
    if (!strcmp(cString, @encode(char)))
        return @"char";
    if (!strcmp(cString, @encode(int)))
        return @"int";
    if (!strcmp(cString, @encode(short)))
        return @"short";
    if (!strcmp(cString, @encode(long)))
        return @"long";
    if (!strcmp(cString, @encode(long long)))
        return @"long long";
    if (!strcmp(cString, @encode(unsigned char)))
        return @"unsigned char";
    if (!strcmp(cString, @encode(unsigned int)))
        return @"unsigned int";
    if (!strcmp(cString, @encode(unsigned short)))
        return @"unsigned short";
    if (!strcmp(cString, @encode(unsigned long)))
        return @"unsigned long";
    if (!strcmp(cString, @encode(unsigned long long)))
        return @"unsigned long long";
    if (!strcmp(cString, @encode(float)))
        return @"float";
    if (!strcmp(cString, @encode(double)))
        return @"double";
    if (!strcmp(cString, @encode(bool)))
        return @"bool";
    if (!strcmp(cString, @encode(_Bool)))
        return @"_Bool";
    if (!strcmp(cString, @encode(void)))
        return @"void";
    if (!strcmp(cString, @encode(char *)))
        return @"char *";
    if (!strcmp(cString, @encode(id)))
        return @"id";
    if (!strcmp(cString, @encode(Class)))
        return @"class";
    if (!strcmp(cString, @encode(SEL)))
        return @"SEL";
    if (!strcmp(cString, @encode(BOOL)))
        return @"BOOL";

    //@TODO: do handle bitmasks
    NSString *result = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];

    if ([[result substringToIndex:1] isEqualToString:@"@"] && [result rangeOfString:@"?"].location == NSNotFound) {
        result = [[result substringWithRange:NSMakeRange(2, result.length - 3)] stringByAppendingString:@"*"];
    } else {
        if ([[result substringToIndex:1] isEqualToString:@"^"]) {
            result = [NSString stringWithFormat:@"%@ *",
                                                [NSString decodeType:[[result substringFromIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]]];
        }
    }
    return result;
}

@end

@interface _KAIKVOBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(__weak id obj, id oldVal, id newVal);

- (id)initWithBlock:(void (^)(__weak id obj, id oldVal, id newVal))block;

@end

@implementation _KAIKVOBlockTarget

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

    id oldVal                           = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldVal == [NSNull null]) oldVal = nil;

    id newVal                           = [change objectForKey:NSKeyValueChangeNewKey];
    if (newVal == [NSNull null]) newVal = nil;

    self.block(object, oldVal, newVal);
}

@end

@interface _KAIKVOInfo : NSObject

@property (nonatomic, weak) NSObject *target;
@property (nonatomic, copy) NSString *targetAddress;
@property (nonatomic, copy) NSString *targetClassName;

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *observerAddress;
@property (nonatomic, copy) NSString *observerClassName;

@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, assign) void *context;

@end

@implementation _KAIKVOInfo @end


@interface _KAIRecursiveLock : NSRecursiveLock @end
@implementation _KAIRecursiveLock @end


@interface NSObject ()

@property (nonatomic, strong) _KAIKVOInfo *kai_willRemoveObserverInfo;
//dealloc时标记有多少没移除，然后手动替他移除，比如有7个 我都替他移除掉，数量还是7，然后用户手动移除时，数量会减少，然后计算最终剩多少就是用户没有移除的，提示用户有没移除的KVO  默认为YES dealloc时改为NO
@property (nonatomic,assign) BOOL kai_notNeedRemoveKeypathFromCrashArray;
@property (nonatomic,strong) _KAIRecursiveLock *kai_lock;
@end

@implementation NSObject (ZKKVOSafe)

static NSMutableSet *KVOSafeSwizzledClasses() {
    static dispatch_once_t onceToken;
    static NSMutableSet *swizzledClasses = nil;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [[NSMutableSet alloc] init];
    });
    return swizzledClasses;
}

static NSMutableDictionary *KVOSafeDeallocCrashes() {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *KVOSafeDeallocCrashes = nil;
    dispatch_once(&onceToken, ^{
        KVOSafeDeallocCrashes = [[NSMutableDictionary alloc] init];
    });
    return KVOSafeDeallocCrashes;
}

NSString * KAIFormatterStringFromObject(id object) {
    return   [NSString stringWithFormat:@"%p-%@",object,NSStringFromClass([object class])];
}

+ (void)load {
    // 功能不稳定，会出现一些闪退 “[xxx release]: message sent to deallocated instance”
    [self swizzleMethod:@selector(addObserver:forKeyPath:options:context:) withMethod:@selector(kai_addObserver:forKeyPath:options:context:)];
    [self swizzleMethod:@selector(observeValueForKeyPath:ofObject:change:context:) withMethod:@selector(kai_observeValueForKeyPath:ofObject:change:context:)];
    [self swizzleMethod:@selector(removeObserver:forKeyPath:) withMethod:@selector(kai_removeObserver:forKeyPath:)];
    [self swizzleMethod:@selector(removeObserver:forKeyPath:context:) withMethod:@selector(kai_removeObserver:forKeyPath:context:)];
}

- (void)addObserverBlockForKeyPath:(NSString *)keyPath block:(void (^)(__weak id obj, id oldVal, id newVal))block {
    if (!keyPath || !block) return;
    _KAIKVOBlockTarget *target = [[_KAIKVOBlockTarget alloc] initWithBlock:block];
    NSMutableDictionary *dic   = [self _kai_allNSObjectObserverBlocks];
    NSMutableArray *arr        = dic[keyPath];
    if (!arr) {
        arr          = [NSMutableArray new];
        dic[keyPath] = arr;
    }
    [arr addObject:target];
    [self addObserver:target forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

- (void)removeObserverBlocksForKeyPath:(NSString *)keyPath {
    if (!keyPath) return;
    NSMutableDictionary *dic = [self _kai_allNSObjectObserverBlocks];
    NSMutableArray *arr      = dic[keyPath];
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeObserver:obj forKeyPath:keyPath];
    }];

    [dic removeObjectForKey:keyPath];
}

- (void)removeObserverBlocks {
    NSMutableDictionary *dic = [self _kai_allNSObjectObserverBlocks];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *arr, BOOL *stop) {
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self removeObserver:obj forKeyPath:key];
        }];
    }];

    [dic removeAllObjects];
}

- (NSMutableDictionary<NSString *, NSMutableArray *> *)_kai_allNSObjectObserverBlocks {
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

-(void)kai_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    @try{
        [self kai_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }@catch (NSException *exception){
        
    }@finally{
        
    }
}

- (void)kai_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if(!observer||!keyPath||([keyPath isKindOfClass:[NSString class]]&&keyPath.length<=0)){
        return ;
    }
    observer.kai_notNeedRemoveKeypathFromCrashArray=YES;
    _KAIRecursiveLock *lock;
    @synchronized(self){
        lock = self.kai_lock;
        if (lock == nil) {
            lock = [[_KAIRecursiveLock alloc] init];
            lock.name = [NSString stringWithFormat:@"%@", [self class]];
            self.kai_lock=lock;
        }
    }
    [lock lock];
    
    _KAIKVOInfo *info=[self kai_canAddOrRemoveObserverWithKeypathWithObserver:observer keyPath:keyPath context:context haveContext:YES isAdd:YES];
    
    if(info != nil){
        //如果添加过了直接return
        [lock unlock];
        return;
    }
    @try {
        NSString *targetAddress=[NSString stringWithFormat:@"%p",self];
        NSString *observerAddress=[NSString stringWithFormat:@"%p",observer];
        _KAIKVOInfo *info=[_KAIKVOInfo new];
        info.target=self;
        info.observer=observer;
        info.keyPath=keyPath;
        info.context=context;
        info.targetAddress=targetAddress;
        info.observerAddress=observerAddress;
        info.targetClassName=NSStringFromClass([self class]);
        info.observerClassName=NSStringFromClass([observer class]);
        @synchronized(self.kai_downObservedKeyPathArray){
            [self.kai_downObservedKeyPathArray addObject:info];
        }
        @synchronized(observer.kai_upObservedArray){
            [observer.kai_upObservedArray addObject:info];
        }
        [self kai_addObserver:observer forKeyPath:keyPath options:options context:context];
        
        //交换dealloc方法
        [observer kai_KVOChangeDidDeallocSignal];
        [self kai_KVOChangeDidDeallocSignal];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [lock unlock];
    }
}

//以下两个方法的区别
//带context参数的方法，苹果是倒序遍历数组，然后判断keypath和context是否都相等，如果都相等则移除，如果没有都相等的则崩溃，如果context参数=NULL，也是相同逻辑，判断keypath是否相等，context是否等于NULL，有则移除，没有相等的则崩溃
//不带context，苹果也是倒序遍历数组，然后判断keypath是否相等(不管context是啥)，如果相等则移除，如果没有相等的则崩溃
//移除时不但要把 有哪些对象监听了自己字典移除，还要把observer的监听了哪些人字典移除
- (void)kai_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    [self kai_allRemoveObserver:observer forKeyPath:keyPath context:nil isContext:NO];
}

- (void)kai_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    [self kai_allRemoveObserver:observer forKeyPath:keyPath context:context isContext:YES];
}

- (void)kai_allRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context isContext:(BOOL)isContext{
    if(!observer||!keyPath||([keyPath isKindOfClass:[NSString class]]&&keyPath.length<=0)){
        return ;
    }
    _KAIRecursiveLock *lock;
    @synchronized(self){
        lock =self.kai_lock;
        if (lock==nil) {
            lock=observer.kai_lock;
            if (lock==nil) {
                lock=[[_KAIRecursiveLock alloc]init];
                lock.name=[NSString stringWithFormat:@"%@",[observer class]];
                observer.kai_lock=lock;
            }
        }
    }
    
    [lock lock];
    _KAIKVOInfo *info=[self kai_canAddOrRemoveObserverWithKeypathWithObserver:observer keyPath:keyPath context:context haveContext:isContext isAdd:NO];
    if (info==nil) {
        // 重复删除观察者或不含有 或者keypath=nil  observer=nil
        NSString *text=@"";
        if (observer.kai_notNeedRemoveKeypathFromCrashArray) {
        }else{
            //observer走完了dealloc，然后去移除，事实上我已经替他移除完了
            text=@"主动";
        }
        [lock unlock];
        return;
    }
    
    @try {
        if (isContext) {
            NSString *targetAddress=[NSString stringWithFormat:@"%p",self];
            NSString *observerAddress=[NSString stringWithFormat:@"%p",observer];
            //此处是因为remove  keypath context调用的还是remove keypath方法
            _KAIKVOInfo *info=[_KAIKVOInfo new];
            info.keyPath=keyPath;
            info.context=context;
            info.targetAddress=targetAddress;
            info.observerAddress=observerAddress;
            self.kai_willRemoveObserverInfo = info;
            [self kai_removeObserver:observer forKeyPath:keyPath context:context];
        } else {
            //kai_removeObserver:observer forKeyPath:keyPath context:
            //newContext是上面方法的参数值，因为上面方法底层调用的方法是不带context参数的remove方法
            void *newContext = NULL;
            if (self.kai_willRemoveObserverInfo) {
                newContext = self.kai_willRemoveObserverInfo.context;
            }
            [self kai_removeObserver:observer forKeyPath:keyPath];
        }
    }
    @catch (NSException *exception) {

    }
    @finally {
        if (isContext) {
            self.kai_willRemoveObserverInfo = nil;
        }
        [self kai_removeSuccessObserver:observer info:info];
        [lock unlock];
    }
}

- (void)kai_removeSuccessObserver:(NSObject *)observer info:(_KAIKVOInfo *)info {
    //    NSString *key =[NSString stringWithFormat:@"%p",self];
    //哪些对象监听了自己
    NSMutableArray *downArray = self.kai_downObservedKeyPathArray;

    //observer监听了哪些对象
    NSMutableArray *upArray = observer.kai_upObservedArray;

    if (info) {
        @synchronized(downArray) {
            if ([downArray containsObject:info]) {
                [downArray removeObject:info];
            }
        }
        @synchronized(upArray) {
            if ([upArray containsObject:info]) {
                [upArray removeObject:info];
            }
        }
    }
}

//为什么判断能否移除 而不是直接remove try catch 捕获异常，因为有的类remove keypath两次，try直接就崩溃了
- (_KAIKVOInfo *)kai_canAddOrRemoveObserverWithKeypathWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath context:(void *)context haveContext:(BOOL)haveContext isAdd:(BOOL)isAdd {
    if (observer.kai_notNeedRemoveKeypathFromCrashArray == NO) {
        NSString *observerKey    = KAIFormatterStringFromObject(observer);
        NSMutableDictionary *dic = KVOSafeDeallocCrashes()[observerKey];
        NSMutableArray *array    = dic[@"keyPaths"];
        __block NSMutableDictionary *willRemoveDic;
        if (array.count > 0) {
            [[array copy] enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL *_Nonnull stop) {
                if ([obj[@"targetName"] isEqualToString:NSStringFromClass([self class])] && [obj[@"targetAddress"] isEqualToString:[NSString stringWithFormat:@"%p", self]] && [keyPath isEqualToString:obj[@"keyPath"]]) {
                    willRemoveDic = obj;
                    *stop         = YES;
                }
            }];
            if (willRemoveDic) {
                [array removeObject:willRemoveDic];
                if (array.count <= 0) {
                    @synchronized(KVOSafeDeallocCrashes()) {
                        [KVOSafeDeallocCrashes() removeObjectForKey:observerKey];
                    }
                }
            }
        }
    }

    if (haveContext == NO && self.kai_willRemoveObserverInfo) {
        context = self.kai_willRemoveObserverInfo.context;
    }
    if (self.kai_willRemoveObserverInfo) {
        haveContext = YES;
    }

    //哪些对象监听了自己
    NSMutableArray *downArray = self.kai_downObservedKeyPathArray;

    //返回已重复的KVO，或者将要移除的KVO
    __block _KAIKVOInfo *info;

    //处理添加的逻辑
    if (isAdd) {
        //判断是否完全相等
        [downArray enumerateObjectsUsingBlock:^(_KAIKVOInfo *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.observerAddress isEqualToString:[NSString stringWithFormat:@"%p",observer]]&&[obj.keyPath isEqualToString:keyPath]) {
                if(obj.context==context){
                    info=obj;
                    *stop=YES;
                }
            }
        }];
        if (info) {
            return info;
        }
        return nil;
    }
    
    
    //处理移除的逻辑
    [downArray enumerateObjectsWithOptions:(NSEnumerationReverse) usingBlock:^(_KAIKVOInfo *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.observerAddress isEqualToString:[NSString stringWithFormat:@"%p",observer]]&&[obj.keyPath isEqualToString:keyPath]) {
            if(haveContext){
                if(obj.context==context){
                    info=obj;
                    *stop=YES;
                }
            }else{
                info=obj;
                *stop=YES;
            }
        }
    }];
    if (info) {
        return info;
    }
    return nil;
}

/* 防止此种崩溃所以新创建个NSArray 和 NSMutableDictionary遍历
 Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <__NSArrayM: 0x61800024f7b0> was mutated while being enumerated.'
 
 Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <__NSDictionaryM: 0x170640de0> was mutated while being enumerated.'
 */
-(void)kai_KVODealloc {
    if (self.kai_upObservedArray.count>0) {
        @synchronized(KVOSafeDeallocCrashes()){
            NSString *currentKey = KAIFormatterStringFromObject(self);
            NSMutableDictionary *crashDic=[NSMutableDictionary dictionary];
            NSMutableArray *array=[NSMutableArray array];
            crashDic[@"keyPaths"]=array;
            crashDic[@"className"]=NSStringFromClass([self class]);
            KVOSafeDeallocCrashes()[currentKey]=crashDic;
            for (_KAIKVOInfo *info in self.kai_upObservedArray) {
                NSMutableDictionary *newDic=[NSMutableDictionary dictionary];
                newDic[@"targetName"]=info.targetClassName;
                newDic[@"targetAddress"]=info.targetAddress;
                newDic[@"keyPath"]=info.keyPath;
                newDic[@"context"]=[NSString stringWithFormat:@"%p",info.context];
                [array addObject:newDic];
            }
        }
    }

    //A->B A先销毁 B的kai_upObservedArray 里的info.target=nil,然后在B dealloc里在remove会导致移除不了，然后系统会报销毁时还持有某keypath的crash
    //A->B B先销毁 此时A remove 但事实上的A的kai_downObservedArray里info.observer=nil  所以B remove里会判断observer是否有值，如果没值则不remove导致没有remove

    //监听了哪些人 让那些人移除自己
    NSMutableArray *newUpArray = [[[self.kai_upObservedArray reverseObjectEnumerator] allObjects] mutableCopy];

    for (_KAIKVOInfo *upInfo in newUpArray) {
        id target = upInfo.target;
        if (target) {
            [target kai_allRemoveObserver:self forKeyPath:upInfo.keyPath context:upInfo.context isContext:upInfo.context != NULL];
        } else if ([upInfo.targetAddress isEqualToString:[NSString stringWithFormat:@"%p", self]]) {
            [self kai_allRemoveObserver:self forKeyPath:upInfo.keyPath context:upInfo.context isContext:upInfo.context != NULL];
        }
    }

    //谁监听了自己 移除他们 这块必须处理  不然 A->B   A先销毁了 在B里面调用A remove就无效了，因为A=nil
    NSMutableArray *downNewArray=[[[self.kai_downObservedKeyPathArray reverseObjectEnumerator]allObjects] mutableCopy];
    for (_KAIKVOInfo *downInfo in downNewArray) {
        [self kai_allRemoveObserver:downInfo.observer forKeyPath:downInfo.keyPath context:downInfo.context isContext:downInfo.context!=NULL];
    }
    self.kai_notNeedRemoveKeypathFromCrashArray=NO;
}

+ (void)kai_dealloc_crash:(NSString*)classAddress {
    //比如A先释放了然后走到此处，然后地址又被B重新使用了，A又释放了走了kai_KVODealloc方法，KVOSafeDeallocCrashes以地址为key的值又被重新赋值，导致误报(A还监听着B监听的内容)，赋值KVOSafeDeallocCrashes以地址为kay的字典的时候，导致字典被释放其他地方又使用，导致野指针
    @synchronized(KVOSafeDeallocCrashes()){
        NSString *currentKey=[NSString stringWithFormat:@"%@-%@",classAddress,NSStringFromClass(self)];
//        NSDictionary *crashDic = KVOSafeDeallocCrashes()[currentKey];
//        NSArray *array = [crashDic[@"keyPaths"] copy];
//        for (NSMutableDictionary *dic in array) {
//            NSString *reason = [NSString stringWithFormat:@"%@:(%@） dealloc时仍然监听着 %@:%@ 的 keyPath of %@ context:%@",crashDic[@"className"],classAddress,dic[@"targetName"],dic[@"targetAddress"],dic[@"keyPath"],dic[@"context"]];
//            NSException *exception = [NSException exceptionWithName:@"KVO crash" reason:reason userInfo:nil];
//        }
        [KVOSafeDeallocCrashes() removeObjectForKey:currentKey];
    }
}

//最后替换的dealloc 会最先调用倒序
- (void)kai_KVOChangeDidDeallocSignal {
    //此处交换dealloc方法是借鉴RAC源码
    Class classToSwizzle=[self class];
    @synchronized (KVOSafeSwizzledClasses()) {
        NSString *className = NSStringFromClass(classToSwizzle);
        if ([KVOSafeSwizzledClasses() containsObject:className]) return;
        
        SEL deallocSelector = sel_registerName("dealloc");
        
        __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
        
        id newDealloc = ^(__unsafe_unretained id self) {
            [self kai_KVODealloc];
            NSString *classAddress=[NSString stringWithFormat:@"%p",self];
            if (originalDealloc == NULL) {
                struct objc_super superInfo = {
                    .receiver = self,
                    .super_class = class_getSuperclass(classToSwizzle)
                };
                void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
                msgSend(&superInfo, deallocSelector);
            } else {
                originalDealloc(self, deallocSelector);
            }
            [NSClassFromString(className) kai_dealloc_crash:classAddress];
        };
        
        IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
        
        if (!class_addMethod(classToSwizzle, deallocSelector, newDeallocIMP, "v@:")) {
            // The class already contains a method implementation.
            Method deallocMethod = class_getInstanceMethod(classToSwizzle, deallocSelector);
            
            // We need to store original implementation before setting new implementation
            // in case method is called at the time of setting.
            originalDealloc = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
            
            // We need to store original implementation again, in case it just changed.
            originalDealloc = (__typeof__(originalDealloc))method_setImplementation(deallocMethod, newDeallocIMP);
        }
        
        [KVOSafeSwizzledClasses() addObject:className];
    }
}

- (NSMutableArray *)kai_downObservedKeyPathArray{
    NSMutableArray *array = [self associatedValueForKey:_cmd];
    if (!array) {
        array = [NSMutableArray new];
        [self setAssociateValue:array withKey:_cmd];
    }
    return array;
}

- (void)setkai_downObservedKeyPathArray:(NSMutableArray *)kai_downObservedKeyPathArray{
    [self setAssociateValue:kai_downObservedKeyPathArray withKey:@selector(kai_downObservedKeyPathArray)];
}

- (NSMutableArray *)kai_upObservedArray{
    @synchronized(self){
        NSMutableArray *array = [self associatedValueForKey:_cmd];
        if (!array) {
            array = [NSMutableArray array];
            [self setkai_upObservedArray:array];
        }
        return array;
    }
}

- (void)setkai_upObservedArray:(NSMutableArray *)kai_upObservedArray {
    [self setAssociateValue:kai_upObservedArray withKey:@selector(kai_upObservedArray)];
}

- (void)setkai_willRemoveObserverInfo:(_KAIKVOInfo *)kai_willRemoveObserverInfo{
    [self setAssociateValue:kai_willRemoveObserverInfo withKey:@selector(kai_willRemoveObserverInfo)];
}

- (_KAIKVOInfo *)kai_willRemoveObserverInfo{
    return [self associatedValueForKey:_cmd];
}

- (void)setkai_notNeedRemoveKeypathFromCrashArray:(BOOL)kai_notNeedRemoveKeypathFromCrashArray {
    [self setAssociateValue:@(kai_notNeedRemoveKeypathFromCrashArray) withKey:@selector(kai_notNeedRemoveKeypathFromCrashArray)];
}

- (BOOL)kai_notNeedRemoveKeypathFromCrashArray{
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setkai_lock:(_KAIRecursiveLock *)kai_lock{
    [self setAssociateValue:kai_lock withKey:@selector(kai_lock)];
}

- (_KAIRecursiveLock *)kai_lock {
    _KAIRecursiveLock *lock = [self associatedValueForKey:_cmd];
    return lock;
}

@end
