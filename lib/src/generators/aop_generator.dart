import 'dart:async';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../annotations/annotations.dart';

/// AOP代码生成器
///
/// 扫描所有@Aop标注的类，为每个类生成增强的子类
/// 生成的类名格式：_{原类名}，文件名格式：{原文件名}.aop.g.dart
class AopGenerator extends GeneratorForAnnotation<Aop> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // 只处理类
    if (element is! ClassElement2) {
      throw InvalidGenerationSourceError('@Aop注解只能用于类', element: element);
    }

    final className = element.name3 ?? 'UnknownClass';
    final enhancedClassName = '${className}Aop';

    // 获取注解参数
    final aopName = annotation.read('name').isNull
        ? null
        : annotation.read('name').stringValue;
    final allowedHooks = annotation.read('allowedHooks').isNull
        ? null
        : annotation
              .read('allowedHooks')
              .listValue
              .map((e) => e.toStringValue()!)
              .toList();

    // 生成增强类代码
    return _generateEnhancedClass(
      className,
      enhancedClassName,
      aopName,
      allowedHooks,
      element,
    );
  }

  /// 生成增强类代码
  String _generateEnhancedClass(
    String className,
    String enhancedClassName,
    String? aopName,
    List<String>? allowedHooks,
    ClassElement2 originalClass,
  ) {
    final buffer = StringBuffer();

    // 生成文件头部
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// AOP增强类，由Fall Core框架自动生成');
    buffer.writeln();
    buffer.writeln("import 'package:get/get.dart';");
    buffer.writeln("import 'package:fall_core/fall_core.dart';");

    // 导入原始类文件（使用相对路径）
    String fileName = _convertToSnakeCase(className);
    buffer.writeln("import '$fileName.dart';");
    buffer.writeln();

    // 生成增强类
    buffer.writeln('/// AOP增强类：$className');
    buffer.writeln('class $enhancedClassName extends $className {');

    // 生成构造函数
    _generateConstructors(buffer, originalClass, enhancedClassName);

    // 生成增强方法
    _generateMethods(buffer, originalClass, allowedHooks);

    buffer.writeln('}');

    return buffer.toString();
  }

  /// 生成构造函数
  void _generateConstructors(
    StringBuffer buffer,
    ClassElement2 originalClass,
    String enhancedClassName,
  ) {
    for (final constructor in originalClass.constructors2) {
      if (constructor.isPrivate) continue;

      final isDefault = constructor.isDefaultConstructor;
      final constructorName = isDefault ? '' : '.${constructor.name3}';
      final params = constructor.formalParameters
          .map(
            (p) => {
              'name': p.name3 ?? 'param',
              'type': p.type.getDisplayString(),
            },
          )
          .toList();

      // 生成构造函数
      buffer.writeln();
      buffer.write('  $enhancedClassName$constructorName(');

      for (int i = 0; i < params.length; i++) {
        final param = params[i];
        if (i > 0) buffer.write(', ');
        buffer.write('${param['type']} ${param['name']}');
      }

      buffer.write(') : super$constructorName(');

      for (int i = 0; i < params.length; i++) {
        final param = params[i];
        if (i > 0) buffer.write(', ');
        buffer.write(param['name']);
      }

      buffer.writeln(');');
    }
  }

  /// 生成增强方法
  void _generateMethods(
    StringBuffer buffer,
    ClassElement2 originalClass,
    List<String>? allowedHooks,
  ) {
    for (final method in originalClass.methods2) {
      // 跳过私有方法、静态方法、抽象方法
      if (method.isPrivate || method.isStatic || method.isAbstract) continue;

      // 检查是否有@NoAop注解
      if (_hasNoAopAnnotation(method)) continue;

      _generateMethod(buffer, method, allowedHooks);
    }
  }

  /// 检查方法是否有@NoAop注解
  bool _hasNoAopAnnotation(MethodElement2 method) {
    // 使用正确的analyzer API访问注解列表
    final annotations = method.metadata2.annotations;

    for (final annotation in annotations) {
      try {
        final element = annotation.element2;
        if (element?.enclosingElement2?.name3 == 'NoAop') {
          return true;
        }
      } catch (e) {
        // 忽略解析错误，继续检查下一个注解
      }
    }
    return false;
  }

  /// 生成单个方法
  void _generateMethod(
    StringBuffer buffer,
    MethodElement2 method,
    List<String>? allowedHooks,
  ) {
    final methodName = method.name3 ?? 'unknownMethod';
    final returnType = method.returnType.getDisplayString();
    final isVoid = returnType == 'void';

    final params = method.formalParameters
        .map(
          (p) => {
            'name': p.name3 ?? 'param',
            'type': p.type.getDisplayString(),
          },
        )
        .toList();

    buffer.writeln();
    buffer.writeln('  @override');
    buffer.write('  $returnType $methodName(');

    // 参数列表
    for (int i = 0; i < params.length; i++) {
      final param = params[i];
      if (i > 0) buffer.write(', ');
      buffer.write('${param['type']} ${param['name']}');
    }

    buffer.writeln(') {');

    // 方法体
    final paramNames = params.map((p) => p['name']!).join(', ');
    final paramTypesCode = params.isEmpty
        ? '<Type>[]'
        : '[${params.map((p) => '${p['name']}.runtimeType').join(', ')}]';

    final allowedHooksCode = allowedHooks != null
        ? '[${allowedHooks.map((h) => "'$h'").join(', ')}]'
        : 'null';

    buffer.writeln('    final aopService = Get.find<AopService>();');

    if (isVoid) {
      buffer.writeln('    aopService.executeAop(');
    } else {
      buffer.writeln('    return aopService.executeAop(');
    }

    buffer.writeln('      target: this,');
    buffer.writeln('      methodName: \'$methodName\',');
    buffer.writeln('      arguments: [$paramNames],');
    buffer.writeln('      argumentTypes: $paramTypesCode,');
    if (isVoid) {
      buffer.writeln('      returnType: dynamic,');
    } else {
      buffer.writeln('      returnType: $returnType,');
    }
    buffer.writeln('      allowedHooks: $allowedHooksCode,');
    buffer.writeln(
      '      originalMethod: () => super.$methodName($paramNames),',
    );

    if (isVoid) {
      buffer.writeln('    );');
    } else {
      buffer.writeln('    ) as $returnType;');
    }

    buffer.writeln('  }');
  }

  /// 将驼峰命名转换为下划线命名
  String _convertToSnakeCase(String camelCase) {
    return camelCase
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => '_${match.group(1)!.toLowerCase()}',
        )
        .substring(1); // 去掉开头的下划线
  }
}

/// 创建AOP生成器的Builder
Builder aopGenerator(BuilderOptions options) {
  return LibraryBuilder(AopGenerator(), generatedExtension: '.g.dart');
}
