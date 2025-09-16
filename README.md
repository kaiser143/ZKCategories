<h1 align="center">
ZKCategories
</h1>
<p align="center">
<img src="https://img.shields.io/cocoapods/v/ZKCategories.svg?style=flat" />
<img src="https://img.shields.io/badge/supporting-objectiveC-yellow.svg" />
<img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" />
<img src="https://img.shields.io/badge/platform- iOS -lightgrey.svg" />
<img src="https://img.shields.io/badge/support-iOS 7+ -blue.svg?style=flat" />
</p>

<p align="center"><b>一个功能丰富的iOS分类库，为Foundation和UIKit提供便捷的扩展方法</b></p>



## 📖 项目介绍

ZKCategories 是一个专为iOS开发设计的Objective-C分类库，提供了大量实用的扩展方法，让iOS开发更加高效便捷。该库涵盖了Foundation框架和UIKit框架的常用类，为日常开发中频繁使用的功能提供了简洁易用的API。

### ✨ 主要特性

- 🛡️ **安全可靠** - 所有方法都经过充分测试，确保稳定性
- 🚀 **性能优化** - 高效实现，不影响应用性能
- 📱 **全面覆盖** - 涵盖Foundation和UIKit的主要类
- 🔧 **易于使用** - 简洁的API设计，开箱即用
- 🛠️ **KVO安全** - 提供KVO防闪退功能
- 📦 **模块化** - 支持按需引入，减少包体积

## 🏗️ 功能模块

### Foundation 框架扩展
- **NSString** - 字符串处理、URL编码、版本比较等
- **NSArray** - 数组操作、安全访问等
- **NSDictionary** - 字典操作、JSON处理等
- **NSDate** - 日期格式化、计算等
- **NSNumber** - 数值转换、计算等
- **NSData** - 数据转换、加密等
- **NSURL** - URL处理、参数解析等
- **NSObject** - 安全方法调用、KVO等
- **NSTimer** - 定时器管理
- **NSUserDefaults** - 偏好设置管理
- **NSNotificationCenter** - 通知管理

### UIKit 框架扩展
- **UIView** - 视图操作、截图、阴影等
- **UIViewController** - 控制器管理、生命周期等
- **UIButton** - 按钮样式、状态管理
- **UILabel** - 标签样式、文本处理
- **UITextField** - 输入框管理、验证
- **UITextView** - 文本视图处理
- **UIImage** - 图片处理、滤镜等
- **UIImageView** - 图片视图管理
- **UITableView** - 表格视图操作
- **UIScrollView** - 滚动视图管理
- **UINavigationController** - 导航管理
- **UIColor** - 颜色处理、主题支持
- **UIScreen** - 屏幕信息获取
- **UIDevice** - 设备信息获取
- **UIApplication** - 应用状态管理

## 📦 安装

### 系统要求
- iOS 9.0+
- Xcode 8.0+
- Objective-C 2.0+

### CocoaPods 安装

在 `Podfile` 中添加：

```ruby
# 基础版本
pod 'ZKCategories'

# 包含KVO防闪退功能
pod 'ZKCategories', :subspecs => ['ZKKVOSAFE']

# 指定版本
pod 'ZKCategories', '~> 0.4.14'

# 从Git仓库安装
pod 'ZKCategories', :git => 'https://github.com/kaiser143/ZKCategories.git', :tag => '0.4.14'
```

然后运行：
```bash
pod install
```

### 手动安装

1. 下载项目源码
2. 将 `ZKCategories/Classes` 文件夹添加到你的项目中
3. 在需要使用的文件中导入：
```objc
#import "ZKCategories.h"
```

## 🚀 快速开始

### 基础使用

```objc
#import "ZKCategories.h"

// 字符串处理
NSString *url = @"https://example.com?param=value";
BOOL isValid = [url isValidURL];
NSDictionary *params = [url dictionaryWithURLEncodedString];

// 视图操作
UIImage *snapshot = [self.view snapshotImage];
[self.view setLayerShadow:[UIColor blackColor] offset:CGSizeMake(0, 2) radius:4];

// 安全方法调用
id result = [target safePerform:@selector(someMethod:) withObject:parameter];

// 日期处理
NSDate *now = [NSDate date];
NSString *formatted = [now stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
```

### KVO 防闪退

```objc
// 在 Podfile 中使用 ZKKVOSAFE 子模块
pod 'ZKCategories', :subspecs => ['ZKKVOSAFE']

// 自动防止KVO相关的崩溃
// 无需额外代码，库会自动处理
```

## 📚 使用示例

### 字符串处理
```objc
// URL验证
NSString *url = @"https://www.apple.com";
if ([url isValidURL]) {
    NSLog(@"有效的URL");
}

// 版本比较
NSString *version1 = @"1.2.3";
NSString *version2 = @"1.2.4";
NSComparisonResult result = [version1 compareVersion:version2];
// result == NSOrderedAscending
```

### 视图操作
```objc
// 查找子视图
UIButton *button = (UIButton *)[self.view descendantOrSelfWithClass:[UIButton class]];

// 截图
UIImage *snapshot = [self.view snapshotImage];

// 设置阴影
[self.view setLayerShadow:[UIColor blackColor] 
                   offset:CGSizeMake(0, 2) 
                   radius:4];
```

### 数组安全操作
```objc
NSArray *array = @[@"a", @"b", @"c"];

// 安全访问
id object = [array safeObjectAtIndex:5]; // 返回nil而不是崩溃

// 数组转换
NSMutableArray *mutableArray = [array mutableArray];
```

## 🔧 配置选项

### KVO 安全模式
如果你需要KVO防闪退功能，请在Podfile中指定：

```ruby
pod 'ZKCategories', :subspecs => ['ZKKVOSAFE']
```

这将启用KVO相关的安全检查，防止常见的KVO崩溃问题。

## 📄 API 文档

详细的API文档请参考各个分类的头文件，每个方法都有详细的注释说明。

主要分类文件：
- `NSString+ZKAdd.h` - 字符串扩展
- `UIView+ZKAdd.h` - 视图扩展
- `NSObject+ZKAdd.h` - 对象扩展
- `NSArray+ZKAdd.h` - 数组扩展
- `NSDictionary+ZKAdd.h` - 字典扩展

## 📝 更新日志

### v0.4.14
- 更新依赖版本
- 修复已知问题
- 优化性能

### v0.3.x
- 添加KVO防闪退功能
- 新增多个实用分类
- 完善文档

## 👨‍💻 作者

**Kaiser**
- Email: deyang143@126.com
- GitHub: [@kaiser143](https://github.com/kaiser143)

## 📄 许可证

ZKCategories 基于 MIT 许可证开源。详情请查看 [LICENSE](LICENSE) 文件。

## ⭐ 支持

如果这个项目对你有帮助，请给它一个⭐️！

---

<div align="center">
Made with ❤️ by Kaiser
</div>
