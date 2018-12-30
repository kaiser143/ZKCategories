//
//  ZKCategoriesMacro.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/26.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#ifndef ZKCategoriesMacro_h
#define ZKCategoriesMacro_h

/*!
 *    @brief    系统隐藏方法, 返回字段为测试代码所耗费的时间  单位 纳秒
 *    @param    count 循环次数， block 中写入待测试的代码
 */
extern uint64_t dispatch_benchmark(size_t count, void(^block)(void));


#endif /* ZKCategoriesMacro_h */
