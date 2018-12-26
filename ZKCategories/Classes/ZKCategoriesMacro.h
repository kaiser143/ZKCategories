//
//  ZKCategoriesMacro.h
//  Pods
//
//  Created by Kaiser on 2018/12/26.
//

#ifndef ZKCategoriesMacro_h
#define ZKCategoriesMacro_h

/*!
 *    @brief    系统隐藏方法
 *    @param    count 循环次数， block 中写入待测试的代码
 */
extern uint64_t dispatch_benchmark(size_t count, void(^block)(void));


#endif /* ZKCategoriesMacro_h */
