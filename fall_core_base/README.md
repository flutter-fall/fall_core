# Fall Core Base

Fall Core 框架的核心注解和基础工具模块。

[![Pub Version](https://img.shields.io/pub/v/fall_core_base)](https://pub.dev/packages/fall_core_base)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📦 模块介绍

`fall_core_base` 是 Fall Core 框架的基础模块，提供了核心注解系统和基础工具类。作为框架的最底层模块，它保持零外部依赖（除Flutter SDK外），确保轻量级和高兼容性。

## ✨ 特性

- 🏷️ **核心注解系统**：提供所有框架必需的注解
- 🛠️ **基础工具类**：日志工厂和通用工具函数
- 📦 **零外部依赖**：除Flutter SDK外无任何外部依赖
- ⚡ **轻量级设计**：最小化包体积和运行时开销
- 🔧 **元数据支持**：完整的编译时元数据注解支持

## 🏷️ 核心注解

### @Service
标记一个类为可注入的服务：

```dart
import 'package:fall_core_base/fall_core_base.dart';

// 基础服务
@Service()
class UserService {
  String getUserName() => 'John Doe';
}

// 命名服务
@Service(name: 'primaryCache')
class CacheService {
  void cache(String key, dynamic value) { /* ... */ }
}

// 懒加载服务
@Service(lazy: true)
class ExpensiveService {
  ExpensiveService() {
    // 只有在首次使用时才会创建
  }
}

// 非单例服务
@Service(singleton: false)
class PrototypeService {
  // 每次注入都会创建新实例
}
```

### @Auto
标记字段进行自动依赖注入：

```dart
@Service()
class OrderService {
  @Auto()
  late UserService userService;
  
  @Auto(name: 'primaryCache')
  late CacheService cacheService;
  
  void processOrder() {
    final user = userService.getUserName();
    cacheService.cache('lastUser', user);
  }
}
```

### @Aop
启用面向切面编程增强：

```dart
@Service()
@Aop(allowedHooks: ['logging', 'timing'])
class PaymentService {
  Future<bool> processPayment(double amount) async {
    // 此方法会被AOP增强
    return true;
  }
  
  @NoAop()
  String _generateTransactionId() {
    // 此方法不会被AOP增强
    return 'TXN_${DateTime.now().millisecondsSinceEpoch}';
  }
}
```

### @NoAop
排除特定方法的AOP处理：

```dart
@Service()
@Aop()
class DataService {
  Future<List<String>> fetchData() async {
    // 会被AOP增强
    return [];
  }
  
  @NoAop(reason: '性能敏感方法')
  bool _isValidData(String data) {
    // 不会被AOP增强
    return data.isNotEmpty;
  }
}
```

### @AutoScan
配置自动扫描范围：

```dart
@AutoScan(
  include: ['lib/services/**/*.dart', 'lib/controllers/**/*.dart'],
  exclude: ['**/*_test.dart', 'lib/generated/**']
)
class AppConfig {}
```

## 🛠️ 基础工具

### LoggerFactory
日志工厂类，提供统一的日志创建接口：

```dart
import 'package:fall_core_base/fall_core_base.dart';

class MyService {
  final logger = LoggerFactory.getLogger('MyService');
  
  void doSomething() {
    logger.info('开始执行业务逻辑');
    try {
      // 业务逻辑
      logger.debug('业务逻辑执行成功');
    } catch (e) {
      logger.error('业务逻辑执行失败', e);
    }
  }
}
```

## 📋 注解参数详解

### Service 注解参数
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `name` | `String?` | `null` | 服务名称，用于命名注入 |
| `lazy` | `bool` | `true` | 是否懒加载，true为按需创建 |
| `singleton` | `bool` | `true` | 是否单例，false每次创建新实例 |

### Auto 注解参数
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `name` | `String?` | `null` | 指定注入的服务名称 |

### Aop 注解参数
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `name` | `String?` | `null` | AOP实例名称 |
| `allowedHooks` | `List<String>?` | `null` | 允许的Hook白名单 |

### NoAop 注解参数
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `reason` | `String?` | `null` | 排除AOP的原因说明 |

### AutoScan 注解参数
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `include` | `List<String>` | `['lib/**/*.dart']` | 包含的文件模式 |
| `exclude` | `List<String>` | `[]` | 排除的文件模式 |

## 🏗️ 架构设计

### 零依赖原则
`fall_core_base` 严格遵循零外部依赖原则：
- 仅依赖 Flutter SDK 和 meta 包
- 不引入任何第三方库
- 确保最大兼容性和最小包体积

### 模块职责
- **注解定义**：提供框架所需的所有注解
- **基础工具**：提供日志、工具函数等基础设施
- **类型定义**：定义框架核心的数据结构和接口

## 📦 安装

在你的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  fall_core_base: ^0.0.1
```

然后运行：

```bash
flutter pub get
```

## 🔗 相关模块

- **[fall_core_gen](../fall_core_gen/)** - 代码生成器模块
- **[fall_core_main](../fall_core_main/)** - 运行时核心模块

## 📄 许可证

本项目采用 [MIT 许可证](../LICENSE)。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**Fall Core Base** - 轻量级的注解和工具基础 🏷️