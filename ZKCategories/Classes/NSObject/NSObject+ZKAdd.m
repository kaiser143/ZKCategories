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
#import "NSString+ZKAdd.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ZKCategoriesMacro.h"

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
    return [self safePerform:selector withArguments:&object, nil];
}

- (id)safePerform:(SEL)selector withObjects:(nonnull NSArray *)objects {
    NSParameterAssert(selector != NULL);
    NSParameterAssert([self respondsToSelector:selector]);
    
    if (![self respondsToSelector:selector]) {
#ifndef NS_BLOCK_ASSERTIONS
        NSString *message = [NSString stringWithFormat:@"%@ does not recognize selector %@", self, NSStringFromSelector(selector)];
        NSAssert(false, message);
#endif
        return nil;
    }
    
    NSMethodSignature *methodSig = [self methodSignatureForSelector:selector];
    if (methodSig == nil) return nil;
    
    // 方法调用者 方法名 方法参数 方法返回值
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    invocation.target = self;
    invocation.selector = selector;
    
    for (int i = 0; i< objects.count; i++) {
        id objct = objects[i];
        if ([objct isKindOfClass:[NSNull class]]) continue;
        [invocation setArgument:&objct atIndex:i+2];
    }
    //调用方法
    [invocation invoke];
    
    const char *typeEncoding = method_getTypeEncoding(class_getInstanceMethod(object_getClass(self), selector));
    if (isObjectTypeEncoding(typeEncoding)) {
        __unsafe_unretained id returnValue;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    return nil;
}

- (nullable id)safePerform:(SEL)selector withArguments:(nullable void *)firstArgument, ... {
    NSParameterAssert(selector != NULL);
    NSParameterAssert([self respondsToSelector:selector]);
    
    if (![self respondsToSelector:selector]) {
#ifndef NS_BLOCK_ASSERTIONS
        NSString *message = [NSString stringWithFormat:@"%@ does not recognize selector %@", self, NSStringFromSelector(selector)];
        NSAssert(false, message);
#endif
        return nil;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    if (firstArgument) {
        va_list valist;
        va_start(valist, firstArgument);
        [invocation setArgument:firstArgument atIndex:2];// 0->self, 1->_cmd
        
        void *currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(valist, void *))) {
            [invocation setArgument:currentArgument atIndex:index];
            index++;
        }
        va_end(valist);
    }
    
    [invocation invoke];
    
    const char *typeEncoding = method_getTypeEncoding(class_getInstanceMethod(object_getClass(self), selector));
    if (isObjectTypeEncoding(typeEncoding)) {
        __unsafe_unretained id returnValue;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    return nil;
}

- (void)safePerform:(SEL)selector withPrimitiveReturnValue:(nullable void *)returnValue arguments:(nullable void *)firstArgument, ... {
    NSParameterAssert(selector != NULL);
    NSParameterAssert([self respondsToSelector:selector]);
    
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    if (firstArgument) {
        va_list valist;
        va_start(valist, firstArgument);
        [invocation setArgument:firstArgument atIndex:2];// 0->self, 1->_cmd
        
        void *currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(valist, void *))) {
            [invocation setArgument:currentArgument atIndex:index];
            index++;
        }
        va_end(valist);
    }
    
    [invocation invoke];
    
    if (returnValue) {
        [invocation getReturnValue:returnValue];
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

- (BOOL)kai_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass {
    return [NSObject kai_hasOverrideMethod:selector forClass:self.class ofSuperclass:superclass];
}

+ (BOOL)kai_hasOverrideMethod:(SEL)selector forClass:(Class)aClass ofSuperclass:(Class)superclass {
    if (![aClass isSubclassOfClass:superclass]) {
        return NO;
    }
    
    if (![superclass instancesRespondToSelector:selector]) {
        return NO;
    }
    
    Method superclassMethod = class_getInstanceMethod(superclass, selector);
    Method instanceMethod = class_getInstanceMethod(aClass, selector);
    if (!instanceMethod || instanceMethod == superclassMethod) {
        return NO;
    }
    return YES;
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
        ZKLog(@"%@", exception);
    }
    return obj;
}

- (id)deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver {
    id obj = nil;
    @try {
        obj = [unarchiver unarchiveObjectWithData:[archiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        ZKLog(@"%@", exception);
    }
    return obj;
}

- (void)kai_enumrateIvarsIncludingInherited:(BOOL)includingInherited usingBlock:(void (^)(Ivar ivar, NSString *ivarDescription))block {
    NSMutableArray<NSString *> *ivarDescriptions = [NSMutableArray new];
    BeginIgnorePerformSelectorLeaksWarning
    NSString *ivarList = [self performSelector:NSSelectorFromString(@"_ivarDescription")];
    EndIgnorePerformSelectorLeaksWarning
    NSError *error;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"in %@:(.*?)((?=in \\w+:)|$)", NSStringFromClass(self.class)] options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    if (!error) {
        NSArray<NSTextCheckingResult *> *result = [reg matchesInString:ivarList options:NSMatchingReportCompletion range:NSMakeRange(0, ivarList.length)];
        [result enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *ivars = [ivarList substringWithRange:[obj rangeAtIndex:1]];
            [ivars enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
                if (![line hasPrefix:@"\t\t"]) {// 有些 struct 类型的变量，会把 struct 的成员也缩进打出来，所以用这种方式过滤掉
                    line = line.stringByTrim;
                    if (line.length > 2) {// 过滤掉空行或者 struct 结尾的"}"
                        NSRange range = [line rangeOfString:@":"];
                        if (range.location != NSNotFound)// 有些"unknow type"的变量不会显示指针地址（例如 UIView->_viewFlags）
                            line = [line substringToIndex:range.location];// 去掉指针地址
                        NSUInteger typeStart = [line rangeOfString:@" ("].location;
                        line = [NSString stringWithFormat:@"%@ %@", [line substringWithRange:NSMakeRange(typeStart + 2, line.length - 1 - (typeStart + 2))], [line substringToIndex:typeStart]];// 交换变量类型和变量名的位置，变量类型在前，变量名在后，空格隔开
                        [ivarDescriptions addObject:line];
                    }
                }
            }];
        }];
    }
    
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(self.class, &outCount);
    for (unsigned int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithFormat:@"%s", ivar_getName(ivar)];
        for (NSString *desc in ivarDescriptions) {
            if ([desc hasSuffix:ivarName]) {
                block(ivar, desc);
                break;
            }
        }
    }
    free(ivars);
    
    if (includingInherited) {
        Class superclass = self.superclass;
        if (superclass) {
            [NSObject kai_enumrateIvarsOfClass:superclass includingInherited:includingInherited usingBlock:block];
        }
    }
}

+ (void)kai_enumrateIvarsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Ivar, NSString *))block {
    if (!block) return;
    NSObject *obj = nil;
    if ([aClass isSubclassOfClass:[UICollectionView class]]) {
        obj = [[aClass alloc] initWithFrame:CGRectZero collectionViewLayout:UICollectionViewFlowLayout.new];
    } else if ([aClass isSubclassOfClass:[UIApplication class]]) {
        obj = UIApplication.sharedApplication;
    } else {
        obj = [aClass new];
    }
    [obj kai_enumrateIvarsIncludingInherited:includingInherited usingBlock:block];
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

@implementation NSObject (ZKKVOBlock)

+ (void)load {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#ifdef KVOSAFE
    [self swizzleMethod:@selector(addObserver:forKeyPath:options:context:) withMethod:@selector(_kai_addObserver:forKeyPath:options:context:)];
    [self swizzleMethod:@selector(removeObserver:forKeyPath:) withMethod:@selector(_kai_removeObserver:forKeyPath:)];
#endif
#pragma clang diagnostic pop
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

@end


@interface _KAIKVOProxy : NSObject

@property (nonatomic, weak) NSObject *observed;

/**
 {keypath : [ob1,ob2](NSHashTable)}
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSHashTable<NSObject *> *> *KVOInfoMap;

@end

@implementation _KAIKVOProxy

- (instancetype)initWithObserverd:(NSObject *)observed {
    self = [super init];
    if (self == nil) return nil;
    
    _observed = observed;
    
    return self;
}

- (void)dealloc {
    @autoreleasepool {
        NSDictionary<NSString *, NSHashTable<NSObject *> *> *KVOInfos = self.KVOInfoMap.copy;
        for (NSString *keyPath in KVOInfos) {
            [self.observed removeObserver:self forKeyPath:keyPath];
        }
    }
}

#pragma mark - :. getters and setters

- (NSMutableDictionary<NSString *,NSHashTable<NSObject *> *> *)KVOInfoMap {
    if (!_KVOInfoMap) {
        _KVOInfoMap = @{}.mutableCopy;
    }
    return _KVOInfoMap;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSHashTable<NSObject *> *os = self.KVOInfoMap[keyPath];
    for (NSObject *observer in os) {
        if ([observer respondsToSelector:_cmd]) [observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

@interface NSObject (ZKKVOSafe)

@property (nonatomic, strong) _KAIKVOProxy *KVOProxy;

@end

@implementation NSObject (ZKKVOSafe)

- (void)_kai_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if ([self filterKVOObj:observer]) {
        [self _kai_addObserver:observer forKeyPath:keyPath options:options context:context];
        return;
    }

    if (!self.KVOProxy) {
        @autoreleasepool {
            self.KVOProxy = [[_KAIKVOProxy alloc] initWithObserverd:self];
        }
    }

    NSHashTable<NSObject *> *os = self.KVOProxy.KVOInfoMap[keyPath];
    if (os.count == 0) {
        os = [[NSHashTable alloc] initWithOptions:(NSPointerFunctionsWeakMemory) capacity:0];
        [os addObject:observer];

        [self _kai_addObserver:self.KVOProxy forKeyPath:keyPath options:options context:context];
        self.KVOProxy.KVOInfoMap[keyPath] = os;
        return;
    }

    if ([os containsObject:observer]) {
        //        NSString *reason = [NSString stringWithFormat:@"target is %@ method is %@, reason : KVO add Observer to many timers.",
        //                            [self class], XXSEL2Str(@selector(addObserver:forKeyPath:options:context:))];
    } else {
        [os addObject:observer];
    }
}

- (void)_kai_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    if ([self filterKVOObj:observer]) {
        [self _kai_removeObserver:observer forKeyPath:keyPath];
        return;
    }
    
    NSHashTable<NSObject *> *os = self.KVOProxy.KVOInfoMap[keyPath];
    if (os.count == 0) {
        //        NSString *reason = [NSString stringWithFormat:@"target is %@ method is %@, reason : KVO remove Observer to many times.",
        //                            [self class], XXSEL2Str(@selector(removeObserver:forKeyPath:))];
        return;
    }
    
    [os removeObject:observer];
    
    if (os.count == 0) {
        [self _kai_removeObserver:self.KVOProxy forKeyPath:keyPath];
        [self.KVOProxy.KVOInfoMap removeObjectForKey:keyPath];
    }
    
//    [self _kai_removeObserver:observer forKeyPath:keyPath];
}

- (BOOL)filterKVOObj:(id)obj {
    if (!obj) return NO;

    //Ignore ReactiveCocoa
    if (object_getClass(obj) == objc_getClass("RACKVOProxy")) {
        return YES;
    }

    //Ignore AMAP
    NSString *className = NSStringFromClass(object_getClass(obj));
    if ([className hasPrefix:@"AMap"]) {
        return YES;
    }

    return NO;
}

#pragma mark - :. getters and setters

- (void)setKVOProxy:(_KAIKVOProxy *)KVOProxy {
    [self setAssociateValue:KVOProxy withKey:@selector(KVOProxy)];
}

- (_KAIKVOProxy *)KVOProxy {
    return [self associatedValueForKey:_cmd];
}

@end
