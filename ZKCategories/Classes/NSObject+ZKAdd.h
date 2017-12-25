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


@interface NSObject (ZKRuntime)

/**-------------------------------------------------------------------------------------
 @name Blocks
 ---------------------------------------------------------------------------------------
 */

/**
 Adds a block to be executed as soon as the receiver's memory is deallocated
 @param block The block to execute when the receiver is being deallocated
 */
- (void)addDeallocBlock:(void(^)(void))block;

/**
 Adds a new instance method to a class. All instances of this class will have this method.
 
 The block captures `self` in the calling context. To allow access to the instance from within the block it is passed as parameter to the block.
 @param selectorName The name of the method.
 @param block The block to execute for the instance method, a pointer to the instance is passed as the only parameter.
 @returns `YES` if the operation was successful
 */
+ (BOOL)addInstanceMethodWithSelectorName:(NSString *)selectorName block:(void(^)(id))block;

/**-------------------------------------------------------------------------------------
 @name Method Swizzling
 ---------------------------------------------------------------------------------------
 */

/**
 Exchanges two method implementations. After the call methods to the first selector will now go to the second one and vice versa.
 @param selector The first method
 @param otherSelector The second method
 */
+ (void)swizzleMethod:(SEL)selector withMethod:(SEL)otherSelector;


/**
 Exchanges two class method implementations. After the call methods to the first selector will now go to the second one and vice versa.
 @param selector The first method
 @param otherSelector The second method
 */
+ (void)swizzleClassMethod:(SEL)selector withMethod:(SEL)otherSelector;

@end
