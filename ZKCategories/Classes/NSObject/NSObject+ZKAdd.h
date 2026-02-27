//
//  NSObject+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/1/11.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZKNSObjectDelayBlock)(BOOL cancel);

@interface NSObject (ZKAdd)

// URL 参数字符串
- (NSString *)URLParameterStringValue NS_SWIFT_NAME(URLParameterStringValue());

/// 返回值为对象或者 void
- (nullable id)safePerform:(SEL)selector;
- (nullable id)safePerform:(SEL)selector withObject:(nullable id)object;
- (nullable id)safePerform:(SEL)selector withObjects:(nonnull NSArray *)objects;

/**
 调用一个带参数的 selector，参数类型支持对象和非对象，也没有数量限制。返回值为对象或者 void。
 
 @code
 id target = xxx;
 SEL action = xxx;
 UIControlEvents events = xxx;
 [control safePerform:@selector(addTarget:action:forControlEvents:) withArguments:&target, &action, &events, nil];
 @endcode
 */
- (nullable id)safePerform:(SEL)selector withArguments:(nullable void *)firstArgument, ...;

/**
 调用一个返回值类型为非对象且带参数的 selector，参数类型支持对象和非对象，也没有数量限制。
 
 @param selector 要判断的方法
 @param returnValue selector 的返回值的指针地址
 
 @code
 CGPoint point = xxx;
 UIEvent *event = xxx;
 BOOL isInside;
 [view safePerform:@selector(pointInside:withEvent:) withPrimitiveReturnValue:&isInside arguments:&point, &event, nil];
 @endcode
 */
- (void)safePerform:(SEL)selector withPrimitiveReturnValue:(nullable void *)returnValue arguments:(nullable void *)firstArgument, ...;


+ (ZKNSObjectDelayBlock)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

+ (void)cancelBlock:(ZKNSObjectDelayBlock)block;
+ (void)cancelPreviousPerformBlock:(ZKNSObjectDelayBlock)aWrappingBlockHandle __attribute__((deprecated));

/**
 判断当前类是否有重写某个父类的指定方法
 
 @param selector 要判断的方法
 @param superclass 要比较的父类，必须是当前类的某个 superclass
 @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
 */
- (BOOL)kai_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass;

/**
 判断指定的类是否有重写某个父类的指定方法
 
 @param selector 要判断的方法
 @param superclass 要比较的父类，必须是当前类的某个 superclass
 @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
 */
+ (BOOL)kai_hasOverrideMethod:(SEL)selector forClass:(Class)aClass ofSuperclass:(Class)superclass;

/// catgory runtime实现get set方法增加一个字符串属性
@property (nonatomic, strong) NSString *stringProperty;

/// catgory runtime实现get set方法增加一个NSInteger属性
@property (nonatomic, assign) NSInteger integerProperty;

/// catgory runtime实现get set方法增加一个id属性
@property (nonatomic, strong) id extra;

@end

@interface NSObject (ZKRuntime)

/**-------------------------------------------------------------------------------------
 @name Block
 ---------------------------------------------------------------------------------------
 */

/**
 在接收者内存被释放时执行传入的 block。
 @param block 在接收者被释放时执行的 block。
 */
- (void)addDeallocBlock:(void (^)(void))block;

/**
 为类添加新的实例方法，该类的所有实例都会拥有此方法。
 
 block 会捕获调用时的 `self`。为在 block 内访问实例，会将实例指针作为 block 的唯一参数传入。
 @param selectorName 方法名。
 @param block 实例方法对应的 block，其唯一参数为指向实例的指针。
 @return 操作成功返回 `YES`。
 */
+ (BOOL)addInstanceMethodWithSelectorName:(NSString *)selectorName block:(void (^)(id))block;

/**-------------------------------------------------------------------------------------
 @name 方法交换 (Method Swizzling)
 ---------------------------------------------------------------------------------------
 */

/**
 交换两个方法的实现。调用后，对第一个 selector 的调用会走第二个实现，反之亦然。
 @param selector 第一个方法。
 @param otherSelector 第二个方法。
 */
+ (void)swizzleMethod:(SEL)selector withMethod:(SEL)otherSelector;

/**
 交换两个类方法的实现。调用后，对第一个 selector 的调用会走第二个实现，反之亦然。
 @param selector 第一个方法。
 @param otherSelector 第二个方法。
 */
+ (void)swizzleClassMethod:(SEL)selector withMethod:(SEL)otherSelector;

#pragma mark - :. Associate value

///=============================================================================
/// @name 关联对象 (Associate value)
///=============================================================================

/**
 将对象以强引用方式关联到 `self`（相当于 strong, nonatomic 属性）。
 
 @param value 要关联的对象。
 @param key   用于从 `self` 取值的指针。
 */
- (void)setAssociateValue:(nullable id)value withKey:(void *)key;

/**
 将对象以弱引用方式关联到 `self`（相当于 weak, nonatomic 属性）。
 
 @param value 要关联的对象。
 @param key   用于从 `self` 取值的指针。
 */
- (void)setAssociateWeakValue:(nullable id)value withKey:(void *)key;

/**
 将对象以拷贝方式关联到 `self`（相当于 copy, nonatomic 属性）。
 
 @param value 要关联的对象。
 @param key   用于从 `self` 取值的指针。
 */
- (void)setAssociateCopyValue:(nullable id)value withKey:(void *)key;

/**
 从 `self` 获取关联对象。
 
 @param key 用于从 `self` 取值的指针。
 */
- (nullable id)associatedValueForKey:(void *)key;

/**
 移除所有关联对象。
 */
- (void)removeAssociatedValues;

#pragma mark - :. Others
///=============================================================================
/// @name 其他
///=============================================================================

/**
 以 NSString 返回类名。
 */
+ (NSString *)className;

/**
 以 NSString 返回类名。
 
 @discussion Apple 在 NSObject(NSLayoutConstraintCallsThis) 中实现了此方法，但未公开。
 */
- (NSString *)className;

/// 实例属性字典
- (NSDictionary *)propertyDictionary;

//属性名称列表
- (NSArray *)propertyKeys;
+ (NSArray *)propertyKeys;

//属性详细信息列表
- (NSArray *)propertiesInfo;
+ (NSArray *)propertiesInfo;

//格式化后的属性列表
+ (NSArray *)propertiesWithCodeFormat;

//方法列表
- (NSArray *)methodList;
+ (NSArray *)methodList;

- (NSArray *)methodListInfo;

/**
 使用 `NSKeyedArchiver` 与 `NSKeyedUnarchiver` 返回实例的深拷贝。
 若发生错误则返回 nil。
 */
- (nullable id)deepCopy;

/**
 使用指定的 archiver 与 unarchiver 返回实例的深拷贝。
 若发生错误则返回 nil。
 
 @param archiver   NSKeyedArchiver 或其子类。
 @param unarchiver NSKeyedUnarchiver 或其子类。
 */
- (nullable id)deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver;

/**
 使用 block 遍历指定 class 的所有成员变量（也即 _xxx 那种），不包含 property 对应的 _property 成员变量
 
 @param aClass 指定的 class
 @param includingInherited 是否要包含由继承链带过来的 ivars
 @param block  用于遍历的 block
 */
+ (void)kai_enumrateIvarsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Ivar ivar, NSString *ivarDescription))block;

@end

@interface NSObject (ZKKVOBlock)

/**
 为接收者注册一个 block，用于接收指定 key-path 的 KVO 通知。
 
 @discussion block 及其捕获的对象会被持有。请调用
 `removeObserverBlocksForKeyPath:` 或 `removeObserverBlocks` 以释放。
 
 @param keyPath 相对于接收者、要观察属性的 key path，不能为 nil。
 
 @param block   用于接收 KVO 通知的 block。
 */
- (void)addObserverBlockForKeyPath:(NSString *)keyPath
                             block:(void (^)(id _Nonnull obj, id _Nonnull oldVal, id _Nonnull newVal))block;

/**
 停止所有通过 `addObserverBlockForKeyPath:block:` 注册的 block 接收指定 key-path 的
 变更通知，并释放这些 block。
 
 @param keyPath 相对于接收者的 key-path，即已注册接收 KVO 变更通知的 key-path。
 */
- (void)removeObserverBlocksForKeyPath:(NSString *)keyPath;

/**
 停止所有通过 `addObserverBlockForKeyPath:block:` 注册的 block 接收变更通知，并释放这些 block。
 */
- (void)removeObserverBlocks;

@end

NS_ASSUME_NONNULL_END

