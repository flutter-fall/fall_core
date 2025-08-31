# Fall Core

[![Pub Version](https://img.shields.io/pub/v/fall_core)](https://pub.dev/packages/fall_core)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dart](https://img.shields.io/badge/Dart-3.8.1+-blue.svg)](https://dart.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-compatible-blue.svg)](https://flutter.dev/)

**Fall Core** is a Flutter AOP (Aspect-Oriented Programming) and Dependency Injection framework inspired by Java Spring Framework, designed to provide enterprise-level architectural support and development experience for Flutter applications.

## 🌟 Vision

Fall Core aims to become the "Spring Framework" of the Flutter ecosystem, bringing mature enterprise-level architectural patterns and best practices to mobile application development.

[中文文档 | Chinese Documentation](#中文文档)

## ✨ 核心特性

### 🎯 依赖注入 (Dependency Injection)
- **服务注解**: 通过 `@Service` 注解标记服务类
- **自动注入**: 通过 `@Auto` 注解实现属性注入
- **命名注入**: 支持通过名称区分同类型的多个服务实例
- **生命周期管理**: 支持单例和原型模式
- **懒加载**: 按需创建服务实例，优化应用启动性能

### 🔄 面向切面编程 (AOP)
- **Before Hook**: 方法执行前的拦截处理
- **After Hook**: 方法执行后的拦截处理
- **Around Hook**: 环绕通知，完全控制方法执行
- **Throw Hook**: 异常处理和统一错误管理
- **Hook 过滤**: 支持按名称过滤特定的 Hook

### 📝 企业级架构
- **注解驱动**: 类似 Spring 的注解系统
- **异常处理**: 完整的异常拦截和处理机制
- **日志系统**: 内置的日志系统和 Hook 集成
- **性能优化**: 基于 GetX 的高性能依赖注入

## 🚀 快速开始

### Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  fall_core: ^0.0.4
  get: ^4.7.2
```

Then run:

```bash
flutter pub get
```

### 基本使用

#### 1. 定义服务

```dart
import 'package:fall_core/fall_core.dart';

// 基础服务定义
@Service()
class UserService {
  Future<User> getUserById(String id) async {
    // 业务逻辑
  }
}

// 带 AOP 的服务
@Service()
@Aop(allowedHooks: ['logging', 'timing'])
class OrderService {
  Future<Order> createOrder(Order order) async {
    // 业务逻辑
  }

  @NoAop() // 跳过 AOP 处理
  String _generateOrderId() {
    return 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// 命名服务
@Service(name: 'primaryCache')
class CacheService {
  void set(String key, dynamic value) { /* ... */ }
  dynamic get(String key) { /* ... */ }
}
```

#### 2. 依赖注入

```dart
@Service()
class OrderController {
  @Auto() // 自动注入
  late UserService userService;
  
  @Auto(name: 'primaryCache') // 命名注入
  late CacheService cacheService;
  
  Future<void> processOrder(String userId, Order order) async {
    final user = await userService.getUserById(userId);
    cacheService.set('last_order_${userId}', order);
    // 处理订单逻辑
  }
}
```

#### 3. AOP Hook 定义

```dart
// 日志记录 Hook
class LoggingHook implements BeforeHook, AfterHook {
  @override
  String get name => 'logging';
  
  @override
  void onBefore(HookContext context) {
    print('开始执行: ${context.methodName}');
  }
  
  @override
  void onAfter(HookContext context, dynamic result) {
    print('执行完成: ${context.methodName} -> $result');
  }
}

// 性能监控 Hook
class TimingHook implements AroundHook {
  @override
  String get name => 'timing';
  
  @override
  dynamic execute(HookContext context, Function() proceed) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = proceed();
      return result;
    } finally {
      stopwatch.stop();
      print('${context.methodName} 执行耗时: ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}
```

#### 4. 应用初始化

```dart
void main() {
  // 手动注册服务到GetX
  Get.lazyPut<AopService>(() => AopService());

  // 注册 AOP Hooks
  final aopService = Get.find<AopService>();
  aopService.addBeforeHook(LoggingHook());
  aopService.addAroundHook(TimingHook());

  //结合fall_gen自动生成Aop代码
  //结合fall_gen自动生成auto_scan代码，详见fall_gen说明
  
  runApp(MyApp());
}
```



## 📚 核心概念

### 注解系统

| 注解 | 用途 | 示例 |
|------|------|------|
| `@Service()` | 标记服务类 | `@Service(name: 'userService', lazy: false)` |
| `@Aop()` | 启用 AOP 增强 | `@Aop(allowedHooks: ['logging'])` |
| `@Auto()` | 自动依赖注入 | `@Auto(name: 'primaryCache')` |
| `@NoAop()` | 跳过 AOP 处理 | `@NoAop(reason: '性能敏感方法')` |

### Hook 类型

- **BeforeHook**: 在目标方法执行前调用
- **AfterHook**: 在目标方法执行后调用
- **AroundHook**: 完全包围目标方法的执行
- **ThrowHook**: 在方法抛出异常时调用

### 执行顺序

```
AroundHook.before → BeforeHook → 目标方法 → AfterHook → AroundHook.after
                                    ↓ (异常)
                                ThrowHook
```

## 🏗️ 架构对比

| 特性 | Spring (Java) | Fall Core (Flutter) |
|------|---------------|----------------------|
| 依赖注入 | @Autowired, @Component | @Auto, @Service |
| AOP | @Aspect, @Around | @Aop, AroundHook |
| 配置 | application.yml | pubspec.yaml |
| 容器 | ApplicationContext | GetX |

## 📖 示例项目

查看 [example](./example) 目录获取完整的示例项目，包含：

- 完整的服务定义和注入示例
- AOP Hook 的使用演示
- 错误处理和参数验证
- 性能监控和日志记录
- 完整的 Flutter 应用示例

## 🔧 配置

### 自定义配置

```dart
// 自定义服务配置
@Service(
  name: 'customService',
  lazy: false,        // 立即初始化
  singleton: true,    // 单例模式
)
class CustomService { }

// 自定义 AOP 配置
@Aop(
  allowedHooks: ['logging', 'security', 'timing'],
  name: 'secureService'
)
class SecureService { }
```

## 🤝 贡献指南

我们欢迎社区贡献！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与项目开发。

### 开发环境设置

```bash
# 克隆项目
git clone https://github.com/flutter-fall/fall_core.git
cd fall-core

# 安装依赖
flutter pub get

# 运行示例
cd example
flutter pub get
flutter run
```

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE)。

## 🔗 相关链接

- [API 文档](https://pub.dev/documentation/fall_core)
- [示例项目](./example)
- [更新日志](CHANGELOG.md)
- [问题反馈](https://github.com/flutter-fall/fall_core/issues)

## 🙏 致谢

特别感谢以下项目的启发：

- [Spring Framework](https://spring.io/) - Java 企业级应用框架
- [GetX](https://github.com/jonataslaw/getx) - Flutter 状态管理和依赖注入
- [Injectable](https://github.com/Milad-Akarie/injectable) - Dart 依赖注入代码生成

---

**Fall Core** - 让 Flutter 开发更简单、更优雅、更企业级 🚀