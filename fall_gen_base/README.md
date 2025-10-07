# Fall Gen Base

Fall Core 框架的代码生成基础模块，提供可扩展的代码生成工具和通用生成器。

[![Pub Version](https://img.shields.io/pub/v/fall_gen_base)](https://pub.dev/packages/fall_gen_base)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📦 模块介绍

`fall_gen_base` 是 Fall Core 框架的代码生成基础模块，为其他代码生成器提供了通用的基础设施和工具类。它抽象了代码扫描、文件处理、代码生成等常用功能，使开发者可以更容易地创建自定义的代码生成器。

## ✨ 特性

- 🏗️ **抽象基础生成器**：提供可扩展的 `BaseAutoScan` 抽象类
- 🔍 **文件扫描引擎**：支持 Glob 模式的文件包含/排除机制
- 🛠️ **代码生成工具**：提供丰富的代码生成工具函数
- 📂 **路径计算工具**：智能的导入路径计算和转换
- 🎯 **注解处理**：统一的注解读取和处理工具
- ⚡ **高性能扫描**：优化的文件扫描和处理机制
- 🔧 **Source Gen 集成**：完美集成 Dart source_gen 框架

## 🏗️ 核心组件

### BaseAutoScan<T>
抽象的自动扫描代码生成器基类：

```dart
abstract class BaseAutoScan<T extends ServiceInfoBase> 
    extends GeneratorForAnnotation<AutoScan> {
  
  // 处理单个ClassElement，返回对应的服务信息对象列表
  List<T> process(ClassElement element, ConstantReader annotation, BuildStep buildStep);
  
  // 生成注册方法的方法体
  String genRegisterBody(List<T> services);
  
  // 生成注入方法的方法体  
  String genInjectBody(List<T> services);
  
  // 生成Class或Extension对象
  Object genClassExtend(String className, List<Method> methods);
}
```

### GenUtil
代码生成工具类，提供常用的工具函数：

```dart
class GenUtil {
  // 计算相对导入路径
  static String getImportPath(Uri importUri, Uri outputUri);
  
  // 读取注解中的列表参数（泛型版本）
  static List<T> readList<T>(ConstantReader annotation, String fieldName, List<T> defaultValue);
  
  // 检查元素是否有指定注解
  static bool hasAnnotation(Element element, Type annotation);
  
  // 获取元素的注解对象
  static DartObject? getAnnotation(Element element, Type annotation);
  
  // 创建类型检查器
  static TypeChecker checker(Type type);
}
```

### ServiceInfoBase
服务信息基类接口，定义了服务信息对象的基本结构：

```dart
abstract class ServiceInfoBase {
  String get className;        // 类名
  Uri get inputUri;           // 源文件URI
  String? get serviceName;    // 服务名称（可选）
  List<InjectableField> get injectableFields; // 可注入字段列表
}
```

### InjectableField
可注入字段信息类：

```dart
class InjectableField {
  final String fieldName;     // 字段名
  final String fieldType;     // 字段类型
  final bool lazy;            // 是否懒加载
  final String? serviceName;  // 服务名称（可选）
  
  // 收集标注@Auto的字段
  static List<InjectableField> collectInjectableFields(ClassElement element);
}
```

## 🚀 快速开始

### 1. 安装

在你的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  fall_core_base: ^0.0.8

dev_dependencies:
  fall_gen_base: ^0.0.8
  build_runner: ^2.7.0
```

### 2. 创建自定义生成器

```dart
// my_generator.dart
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:fall_gen_base/fall_gen_base.dart';

// 定义自定义服务信息类
class MyServiceInfo extends ServiceInfoBase {
  @override
  final String className;
  @override
  final Uri inputUri;
  @override
  final String? serviceName;
  @override
  final List<InjectableField> injectableFields;
  
  MyServiceInfo({
    required this.className,
    required this.inputUri,
    this.serviceName,
    required this.injectableFields,
  });
}

// 实现自定义生成器
class MyGenerator extends BaseAutoScan<MyServiceInfo> {
  MyGenerator({bool debug = false}) : super(debug: debug);
  
  @override
  List<MyServiceInfo> process(
    ClassElement element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // 处理单个类元素，提取服务信息
    return [
      MyServiceInfo(
        className: element.name ?? 'Unknown',
        inputUri: buildStep.inputId.uri,
        serviceName: annotation.read('name').isNull 
            ? null 
            : annotation.read('name').stringValue,
        injectableFields: InjectableField.collectInjectableFields(element),
      )
    ];
  }
  
  @override
  String genRegisterBody(List<MyServiceInfo> services) {
    // 生成服务注册代码
    final buffer = StringBuffer();
    for (final service in services) {
      buffer.writeln('Get.lazyPut<${service.className}>(() => ${service.className}());');
    }
    return buffer.toString();
  }
  
  @override
  String genInjectBody(List<MyServiceInfo> services) {
    // 生成依赖注入代码
    final buffer = StringBuffer();
    for (final service in services) {
      for (final field in service.injectableFields) {
        buffer.writeln(
          'InjectUtil.inject<${field.fieldType}>(${field.serviceName != null ? "'${field.serviceName}'" : 'null'}, '
          '(instance) => Get.find<${service.className}>().${field.fieldName} = instance);'
        );
      }
    }
    return buffer.toString();
  }
  
  @override
  Object genClassExtend(String className, List<Method> methods) {
    // 生成扩展类
    return Extension(
      (b) => b
        ..name = '${className}Extension'
        ..on = refer(className)
        ..methods.addAll(methods),
    );
  }
}
```

### 3. 配置构建器

```dart
// build.dart
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'my_generator.dart';

Builder myGeneratorBuilder(BuilderOptions options) {
  return SharedPartBuilder([MyGenerator(debug: true)], 'my_generator');
}
```

### 4. 配置 build.yaml

```yaml
targets:
  $default:
    builders:
      my_package:my_generator:
        enabled: true
        generate_for:
          - lib/**
        options:
          debug: true
```

## 🔧 高级功能

### 文件扫描配置

```dart
@AutoScan(
  include: [
    'lib/services/**/*.dart',
    'lib/repositories/**/*.dart'
  ],
  exclude: [
    '**/*_test.dart',
    '**/*.g.dart',
    '**/*.freezed.dart'
  ],
  annotations: [Service, Component]  // 指定要扫描的注解类型
)
class MyConfig {}
```

### 路径计算示例

```dart
// 计算相对导入路径
final importUri = Uri.parse('package:my_app/services/user_service.dart');
final outputUri = Uri.parse('package:my_app/init/auto_scan.g.dart');
final relativePath = GenUtil.getImportPath(importUri, outputUri);
// 结果: '../services/user_service.dart'
```

### 注解参数读取

```dart
// 读取不同类型的列表参数
final stringList = GenUtil.readList<String>(annotation, 'include', ['lib/**/*.dart']);
final typeList = GenUtil.readList<Type>(annotation, 'annotations', [Service]);
final intList = GenUtil.readList<int>(annotation, 'priorities', [1, 2, 3]);
```

### 自定义字段收集

```dart
// 扩展 InjectableField 收集其他注解
class CustomField extends InjectableField {
  final bool required;
  
  CustomField({
    required String fieldName,
    required String fieldType,
    required bool lazy,
    String? serviceName,
    required this.required,
  }) : super(
    fieldName: fieldName,
    fieldType: fieldType,
    lazy: lazy,
    serviceName: serviceName,
  );
  
  static List<CustomField> collectCustomFields(ClassElement element) {
    // 自定义字段收集逻辑
    return [];
  }
}
```

## 🛠️ 工具函数详解

### GenUtil.getImportPath()
智能路径计算函数，支持：
- Package URI 和 Asset URI 之间的转换
- 相同 package 内的相对路径计算
- 跨 package 的绝对路径处理
- 自动处理路径分隔符标准化

### GenUtil.readList<T>()
泛型列表读取函数，支持：
- `String` 列表
- `Type` 列表  
- `int`、`double`、`bool` 基础类型列表
- 自动过滤空值和无效值

### InjectableField.collectInjectableFields()
字段收集函数，功能包括：
- 自动识别 `@Auto` 注解
- 提取字段类型信息
- 解析懒加载和命名参数
- 错误处理和异常忽略

## 📊 性能优化

### 扫描优化
- 使用 Glob 模式进行高效文件匹配
- 支持排除模式减少不必要的文件处理
- 并行处理多个文件以提升性能

### 内存优化
- 延迟加载和处理文件内容
- 及时释放不需要的对象引用
- 优化字符串操作减少内存分配

### 构建优化
- 支持增量构建，只处理变更的文件
- 智能缓存机制避免重复计算
- 最小化生成代码的体积

## 🐛 故障排除

### 常见问题

1. **扫描不到文件**
   ```yaml
   # 检查 include 模式是否正确
   include:
     - 'lib/**/*.dart'  # 正确
     - 'lib/*/*.dart'   # 只扫描一层目录
   ```

2. **路径计算错误**
   ```dart
   // 确保 URI 格式正确
   final uri1 = Uri.parse('package:my_app/file.dart');  // 正确
   final uri2 = Uri.parse('my_app/file.dart');          // 错误
   ```

3. **注解读取失败**
   ```dart
   // 使用 try-catch 包装注解读取
   try {
     final value = annotation.read('fieldName').stringValue;
   } catch (e) {
     // 使用默认值
   }
   ```

### 调试技巧

1. **启用调试模式**：
   ```dart
   MyGenerator(debug: true)  // 输出详细日志
   ```

2. **查看扫描结果**：
   ```dart
   // 在 process 方法中添加日志
   if (debug) {
     print('Found service: ${element.name}');
   }
   ```

## 🔗 相关模块

- **[fall_core_base](../fall_core_base/)** - 核心注解和工具模块
- **[fall_core_gen](../fall_core_gen/)** - 具体的代码生成器实现
- **[fall_core_main](../fall_core_main/)** - 运行时核心模块

## 📄 许可证

本项目采用 [MIT 许可证](../LICENSE)。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**Fall Gen Base** - 可扩展的代码生成基础设施 🏗️