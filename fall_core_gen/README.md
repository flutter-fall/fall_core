# Fall Core Gen

Fall Core 框架的代码生成器模块，提供编译时代码生成功能。

[![Pub Version](https://img.shields.io/pub/v/fall_core_gen)](https://pub.dev/packages/fall_core_gen)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📦 模块介绍

`fall_core_gen` 是 Fall Core 框架的代码生成器模块，负责在编译时扫描代码并生成必要的服务注册和 AOP 代理代码。通过代码生成，框架实现了零运行时反射开销的依赖注入和 AOP 功能。

## ✨ 特性

- 🔍 **自动代码扫描**：扫描项目中的所有 Dart 文件
- 🏭 **服务代码生成**：自动生成服务注册和注入代码
- 🎭 **AOP代理生成**：为标记 `@Aop` 的类生成代理类
- ⚡ **零运行时开销**：所有依赖注入逻辑在编译时完成
- 🔧 **Analyzer 7.5.5 兼容**：支持最新的 Dart 分析器
- 📂 **Glob 模式支持**：灵活的文件匹配和过滤
- 🛠️ **Build Runner 集成**：完美集成 Dart 构建系统

## 🏭 核心生成器

### ServiceGenerator
服务注册代码生成器，负责：
- 扫描所有带 `@Service` 注解的类
- 生成 `auto_scan.g.dart` 文件
- 创建 `registerServices()` 方法
- 创建 `injectServices()` 方法

### AopGenerator  
AOP代理代码生成器，负责：
- 扫描所有带 `@Aop` 注解的类
- 为每个类生成对应的代理类
- 实现方法拦截和Hook调用
- 处理 `@NoAop` 排除逻辑

## 🚀 快速开始

### 1. 安装

在你的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  fall_core_base: ^0.0.1

dev_dependencies:
  fall_core_gen: ^0.0.1
  build_runner: ^2.7.0
```

### 2. 配置构建规则

在项目根目录创建 `build.yaml` 文件：

```yaml
targets:
  $default:
    builders:
      fall_core_gen:service_generator:
        enabled: true
        generate_for:
          - lib/**
        options:
          output_dir: lib/init/
      fall_core_gen:aop_generator:
        enabled: true
        generate_for:
          - lib/**
```

### 3. 定义服务

```dart
// lib/services/user_service.dart
import 'package:fall_core_base/fall_core_base.dart';

@Service()
class UserService {
  String getUserName() => 'John Doe';
}

@Service()
class OrderService {
  @Auto()
  late UserService userService;
  
  void processOrder() {
    final userName = userService.getUserName();
    print('Processing order for: $userName');
  }
}
```

### 4. 定义AOP服务

```dart
// lib/services/payment_service.dart
import 'package:fall_core_base/fall_core_base.dart';

@Service()
@Aop(allowedHooks: ['logging', 'timing'])
class PaymentService {
  Future<bool> processPayment(double amount) async {
    // 此方法会被AOP增强
    await Future.delayed(Duration(seconds: 1));
    return amount > 0;
  }
  
  @NoAop()
  String _generateTransactionId() {
    // 此方法不会被AOP增强
    return 'TXN_${DateTime.now().millisecondsSinceEpoch}';
  }
}
```

### 5. 运行代码生成

```bash
# 生成代码
flutter pub run build_runner build

# 监听模式（开发时推荐）
flutter pub run build_runner watch

# 清理并重新生成
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📁 生成的文件

### auto_scan.g.dart
生成的服务注册文件示例：

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:get/get.dart';
import 'package:fall_core_main/fall_core_main.dart';

import '../services/user_service.dart';
import '../services/order_service.dart';

class AutoScan {
  static void registerServices() {
    // 注册服务
    Get.lazyPut<UserService>(() => UserService());
    Get.lazyPut<OrderService>(() => OrderService());
  }
  
  static void injectServices() {
    // 注入依赖
    final orderService = Get.find<OrderService>();
    InjectUtil.inject<UserService>(null, (service) => orderService.userService = service);
  }
}
```

### AOP代理类
为带 `@Aop` 注解的类生成代理：

```dart
// payment_service.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:fall_core_main/fall_core_main.dart';
import 'payment_service.dart';

class PaymentServiceAop extends PaymentService {
  @override
  Future<bool> processPayment(double amount) {
    return AopService.instance.executeAop<Future<bool>>(
      target: this,
      methodName: 'processPayment',
      arguments: [amount],
      proceed: () => super.processPayment(amount),
      allowedHooks: ['logging', 'timing'],
    );
  }
  
  // _generateTransactionId 方法不会被代理（标记了@NoAop）
}
```

## ⚙️ 配置选项

### build.yaml 配置
```yaml
targets:
  $default:
    builders:
      fall_core_gen:service_generator:
        enabled: true
        generate_for:
          - lib/**
          - "!lib/generated/**"  # 排除生成的文件
        options:
          output_dir: lib/init/           # 输出目录
          file_name: auto_scan.g.dart     # 输出文件名
      fall_core_gen:aop_generator:
        enabled: true
        generate_for:
          - lib/**
        options:
          suffix: Aop                     # 代理类后缀
```

### @AutoScan 注解配置
```dart
@AutoScan(
  include: [
    'lib/services/**/*.dart',
    'lib/controllers/**/*.dart'
  ],
  exclude: [
    '**/*_test.dart',
    'lib/generated/**'
  ]
)
class AppConfig {}
```

## 🔧 高级功能

### 自定义生成器工具
```dart
import 'package:fall_core_gen/fall_core_gen.dart';

// 使用GenUtil工具类
class CustomGenerator {
  void generateCode() {
    final classInfo = GenUtil.extractClassInfo(element);
    final generatedCode = GenUtil.generateServiceCode(classInfo);
    // 自定义代码生成逻辑
  }
}
```

### 条件编译支持
```dart
@Service()
class DebugService {
  // 只在Debug模式下注册
}

@Service()
@pragma('fall_core:exclude_release')  // 自定义pragma
class DevOnlyService {
  // 只在开发环境下可用
}
```

## 🐛 故障排除

### 常见问题

1. **代码生成失败**
   ```bash
   # 清理构建缓存
   flutter clean
   flutter pub get
   flutter pub run build_runner clean
   flutter pub run build_runner build
   ```

2. **找不到生成的文件**
   - 检查 `build.yaml` 配置
   - 确认 `generate_for` 路径正确
   - 检查是否有语法错误

3. **依赖注入失败**
   - 确保调用了 `AutoScan.registerServices()`
   - 检查服务是否正确标记了 `@Service`
   - 验证导入路径是否正确

4. **AOP不生效**
   - 确保类标记了 `@Aop` 注解
   - 检查是否注册了代理类而不是原始类
   - 验证Hook是否正确注册

### 调试技巧

1. **查看生成的代码**：
   ```bash
   # 查看生成的文件
   cat lib/init/auto_scan.g.dart
   ```

2. **详细构建日志**：
   ```bash
   flutter pub run build_runner build --verbose
   ```

3. **单独测试生成器**：
   ```bash
   flutter pub run build_runner test
   ```

## 📊 性能优化

### 构建性能
- 使用 `flutter pub run build_runner watch` 进行增量构建
- 合理配置 `generate_for` 减少扫描范围
- 使用 `.gitignore` 排除不必要的文件

### 生成代码优化
- 生成器会自动优化代码结构
- 支持懒加载以减少启动时间
- 最小化生成代码的体积

## 🔗 相关模块

- **[fall_core_base](../fall_core_base/)** - 核心注解和工具模块
- **[fall_core_main](../fall_core_main/)** - 运行时核心模块

## 📄 许可证

本项目采用 [MIT 许可证](../LICENSE)。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**Fall Core Gen** - 强大的编译时代码生成器 🏭