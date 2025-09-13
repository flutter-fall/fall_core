import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import '../utils/gen_util.dart';
import 'package:source_gen/source_gen.dart' hide LibraryBuilder;
import 'package:fall_core_base/fall_core_base.dart';

/// AOP代码生成器
///
/// 扫描所有@Aop标注的类，为每个类生成增强的子类
/// 生成的类名格式：{原类名}Aop，文件名格式：{原文件名}.aop.g.dart
class AopGenerator extends GeneratorForAnnotation<Aop> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // 只处理类
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('@Aop注解只能用于类', element: element);
    }

    final className = element.name ?? 'UnknownClass';
    final enhancedClassName = '${className}Aop';

    final allowedHooks = annotation.read('allowedHooks').isNull
        ? null
        : annotation
              .read('allowedHooks')
              .listValue
              .map((e) => e.toStringValue()!)
              .toList();

    // 生成库
    final library = Library(
      (b) => b
        ..directives.addAll([
          Directive.import('package:get/get.dart'),
          Directive.import('package:fall_core/fall_core.dart'),
          Directive.import(
            GenUtil.getImportPath(
              buildStep.inputId.uri,
              buildStep.inputId.changeExtension(".g.dart").uri,
            ),
          ),
        ])
        ..body.add(_generateClass(element, enhancedClassName, allowedHooks)),
    );

    final emitter = DartEmitter();
    final source = library.accept(emitter).toString();
    return source;
  }

  /// 生成增强类
  Class _generateClass(
    ClassElement originalClass,
    String enhancedClassName,
    List<String>? allowedHooks,
  ) {
    final className = originalClass.name ?? 'UnknownClass';

    return Class(
      (b) => b
        ..name = enhancedClassName
        ..extend = refer(className)
        ..constructors.addAll(_generateConstructors(originalClass))
        ..methods.addAll(_generateMethods(originalClass, allowedHooks)),
    );
  }

  /// 生成构造函数列表
  List<Constructor> _generateConstructors(ClassElement originalClass) {
    final constructors = <Constructor>[];

    for (final constructor in originalClass.constructors) {
      if (constructor.isPrivate) continue;

      final isDefault = constructor.isDefaultConstructor;
      final constructorName = constructor.name;

      // 构建参数列表
      final parameters = constructor.formalParameters.map((p) {
        final paramName = p.name ?? 'param';
        final paramType = p.type.getDisplayString();

        return Parameter(
          (b) => b
            ..name = paramName
            ..type = refer(paramType),
        );
      }).toList();

      // 构建super调用的参数
      final superArgs = constructor.formalParameters.map((p) {
        return refer(p.name ?? 'param');
      }).toList();

      // 创建Constructor对象
      final constructorBuilder = Constructor((b) {
        // 设置构造函数名称（如果不是默认构造函数）
        if (!isDefault && constructorName != null) {
          b.name = constructorName;
        }

        // 添加参数
        b.requiredParameters.addAll(parameters);

        // 添加super调用的初始化器
        if (isDefault) {
          b.initializers.add(refer('super').call(superArgs).code);
        } else {
          b.initializers.add(
            refer('super').property(constructorName ?? '').call(superArgs).code,
          );
        }
      });

      constructors.add(constructorBuilder);
    }

    return constructors;
  }

  /// 生成增强方法
  List<Method> _generateMethods(
    ClassElement originalClass,
    List<String>? allowedHooks,
  ) {
    final methods = <Method>[];

    for (final method in originalClass.methods) {
      // 跳过私有方法、静态方法、抽象方法
      if (method.isPrivate || method.isStatic || method.isAbstract) continue;

      // 检查是否有@NoAop注解
      if (GenUtil.hasAnnotation(method, NoAop)) continue;

      methods.add(_generateMethod(method, allowedHooks));
    }

    return methods;
  }

  /// 生成单个方法
  Method _generateMethod(MethodElement method, List<String>? allowedHooks) {
    final methodName = method.name ?? 'unknownMethod';
    final returnType = method.returnType.getDisplayString();
    final isVoid = returnType == 'void';

    // 构建参数列表
    final parameters = method.formalParameters.map((p) {
      final paramName = p.name ?? 'param';
      final paramType = p.type.getDisplayString();

      return Parameter(
        (b) => b
          ..name = paramName
          ..type = refer(paramType),
      );
    }).toList();

    // 构建参数名称字符串，用于方法调用
    final paramNamesStr = method.formalParameters
        .map((p) => p.name ?? 'param')
        .join(', ');

    // 构建参数类型数组字符串
    final paramTypesStr = method.formalParameters.isEmpty
        ? '<Type>[]'
        : '[${method.formalParameters.map((p) => '${p.name ?? 'param'}.runtimeType').join(', ')}]';

    // 构建允许的Hook列表字符串
    final allowedHooksStr = allowedHooks != null
        ? '[${allowedHooks.map((h) => "'$h'").join(', ')}]'
        : 'null';

    // 生成方法体代码
    final methodBodyCode = isVoid
        ? '''
final aopService = Get.find<AopService>();
aopService.executeAop(
  target: this,
  methodName: '$methodName',
  arguments: [$paramNamesStr],
  argumentTypes: $paramTypesStr,
  returnType: dynamic,
  allowedHooks: $allowedHooksStr,
  originalMethod: () => super.$methodName($paramNamesStr),
);'''
        : '''
final aopService = Get.find<AopService>();
return aopService.executeAop(
  target: this,
  methodName: '$methodName',
  arguments: [$paramNamesStr],
  argumentTypes: $paramTypesStr,
  returnType: $returnType,
  allowedHooks: $allowedHooksStr,
  originalMethod: () => super.$methodName($paramNamesStr),
) as $returnType;''';

    // 构建方法体
    final methodBody = Code(methodBodyCode);

    return Method(
      (b) => b
        ..annotations.add(refer('override'))
        ..name = methodName
        ..returns = refer(returnType)
        ..requiredParameters.addAll(parameters)
        ..body = methodBody,
    );
  }
}
