//
//  UIVisualEffectView+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2025/2/26.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIVisualEffectView (ZKAdd)

/**
 系统的 UIVisualEffectView 会为不同的 effect 生成不同的 subview 并为其设置对应的 backgroundColor、alpha，这些 subview 的样式我们是修改不了的，如果有设计需求希望在磨砂上方盖一层前景色来调整磨砂效果，总是会受自带的 subview 的影响(例如无法有特别明显的磨砂效果，因为自带的 subview alpha 可能很高，透不过去），因此增加这个属性，当设置一个非 nil 的颜色后，会强制把系统自带的 subview 隐藏掉，只显示你自己的 foregroundColor，从而实现精准的调整。
 
 以 UINavigationBar 为例，当我们通过 UINavigationBar.barTintColor 或者 UINavigationBarAppearance.backgroundEffect/backgroundColor 实现磨砂效果时，我们设置上去的 barTintColor 最终会被系统进行一些运算后产生另一个色值，最终显示出来的色值和我们设置的 barTintColor 是相似但不相等的，如果希望有精准的色值调整，就可以自己获取 UINavigationBar 内部的 UIVisualEffectView，再修改它的 kai_foregroundColor。
 
 @note 注意这个颜色需要是半透明的，才能透出背后的磨砂，如果设置不透明的色值，就失去了磨砂效果了。
 @note 注意如果开启了系统的“降低透明度”辅助功能开关，此时 kai_foregroundColor 的效果会变得比较怪异，因此默认会监听 UIAccessibilityIsReduceTransparencyEnabled 的变化，当开启时会强制把 kai_foregroundColor 改为不透明的，从而屏蔽磨砂的效果。
 */
@property(nonatomic, strong, nullable) UIColor *kai_foregroundColor;

@end

NS_ASSUME_NONNULL_END
