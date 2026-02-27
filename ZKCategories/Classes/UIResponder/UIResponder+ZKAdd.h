//
//  UIResponder+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/5/18.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/*!
 *  @brief  通过 eventStrategy 字典 + NSInvocation 将事件名映射到对应方法，在 responderDidReceiveEvent:userInfo: 中统一派发。
 *
 *  e.g.
 @interface ZKViewController : UIViewController
 @property (nonatomic, strong) NSDictionary<NSString *, NSInvocation *> *eventStrategy;
 @end

 @implementation ZKViewController

 - (BOOL)responderDidReceiveEvent:(nonnull NSString *)eventName userInfo:(nullable id)userInfo {
     NSInvocation *invocation = self.eventStrategy[eventName];
     [invocation setArgument:&userInfo atIndex:2];
     [invocation invokeWithTarget:self];
     return NO;
 }

 - (NSInvocation *)createInvocationWithSelector:(SEL)selector {
     NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
     NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
     [invocation setSelector:selector];
     return invocation;
 }

 - (NSDictionary<NSString *, NSInvocation *> *)eventStrategy {
     if (_eventStrategy == nil) {
         _eventStrategy = @{
             kBLGoodsDetailTicketEvent:        [self createInvocationWithSelector:@selector(ticketEvent:)],
             kBLGoodsDetailPromotionEvent:     [self createInvocationWithSelector:@selector(promotionEvent:)],
             kBLGoodsDetailScoreEvent:         [self createInvocationWithSelector:@selector(scoreEvent:)],
             kBLGoodsDetailTargetAddressEvent: [self createInvocationWithSelector:@selector(targetAddressEvent:)],
             kBLGoodsDetailServiceEvent:       [self createInvocationWithSelector:@selector(serviceEvent:)],
             kBLGoodsDetailSKUSelectionEvent:  [self createInvocationWithSelector:@selector(skuSelectionEvent:)],
         };
     }
     return _eventStrategy;
 }

 @end
 */

@interface UIResponder (ZKAdd)

/**
 返回当前第一响应者。
 
 @return UIResponder 实例。
 */
+ (nullable instancetype)currentFirstResponder;

/*!
 *  @brief    发送事件
 *  @param    eventName    事件名
 */
- (void)sendEventWithName:(nonnull NSString *)eventName userInfo:(nullable id)userInfo;


/*!
 *  @brief    在需要响应的位置重写该方法
 *  @param    eventName    事件名
 *  @return    是否继续往next responder派发事件
 */
- (BOOL)responderDidReceiveEvent:(nonnull NSString *)eventName userInfo:(nullable id)userInfo;

/*!
 *  @brief  响应者链
 *  @return  响应者链
 */
- (nullable NSString *)responderChainDescription;

@end
