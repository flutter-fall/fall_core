import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:glob/glob.dart';

/// 服务扫描代码生成器
///
/// 扫描所有@Service标注的类，生成自动注册和依赖注入逻辑到auto_scan.g.dart
class ServiceGenerator extends Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['init/auto_scan.g.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // 收集所有@Service标注的类
    final services = <ServiceInfo>[];

    // 扫描整个项目，查找@Service注解
    await for (final input in buildStep.findAssets(Glob('lib/**/*.dart'))) {
      if (input.path.endsWith('.g.dart')) continue; // 跳过生成的文件

      try {
        final libraryElement = await buildStep.resolver.libraryFor(input);
        final libraryReader = LibraryReader(libraryElement);

        // 查找@Service注解的类
        for (final annotatedElement in libraryReader.annotatedWith(
          TypeChecker.fromUrl(
            'package:fall_core/src/annotations/service.dart#Service',
          ),
        )) {
          final element = annotatedElement.element;
          if (element is ClassElement) {
            // annotatedElement.annotation已经是ConstantReader类型
            services.add(
              ServiceInfo.fromElement(
                element,
                annotatedElement.annotation,
                input.path,
              ),
            );
          }
        }
      } catch (e) {
        // 忽略解析错误，继续处理其他文件
      }
    }

    if (services.isEmpty) return;

    final outputId = AssetId(
      buildStep.inputId.package,
      'lib/init/auto_scan.g.dart',
    );
    await buildStep.writeAsString(outputId, _generateAutoScanFile(services));
  }

  /// 生成auto_scan.g.dart文件内容
  String _generateAutoScanFile(List<ServiceInfo> services) {
    final buffer = StringBuffer();

    // 文件头部
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// 服务自动扫描和注册，由Fall Core框架自动生成');
    buffer.writeln();
    buffer.writeln("import 'package:get/get.dart';");
    buffer.writeln("import 'package:fall_core/fall_core.dart';");
    // 收集导入
    final imports = <String>{};
    for (final service in services) {
      imports.add("import '${service.importPath}';");
      if (service.hasAop) {
        final aopFilePath = service.importPath.replaceAll('.dart', '.g.dart');
        imports.add("import '$aopFilePath';");
      }
    }

    for (final import in imports) {
      buffer.writeln(import);
    }

    buffer.writeln();
    buffer.writeln('/// 自动扫描和注册服务');
    buffer.writeln('class AutoScan {');

    // 生成服务注册方法
    buffer.writeln('  /// 注册所有标注@Service的类到GetX');
    buffer.writeln('  static void registerServices() {');

    for (final service in services) {
      final className = service.hasAop
          ? '${service.className}Aop'
          : service.className;
      final serviceName = service.serviceName;

      buffer.writeln('    // 注册${service.serviceName ?? service.className}');
      if (service.lazy) {
        if (serviceName != null) {
          buffer.writeln(
            '    Get.lazyPut<${service.className}>(() => $className(), tag: "$serviceName");',
          );
        } else {
          buffer.writeln(
            '    Get.lazyPut<${service.className}>(() => $className());',
          );
        }
      } else {
        if (serviceName != null) {
          buffer.writeln(
            '    Get.put<${service.className}>($className(), tag: "$serviceName");',
          );
        } else {
          buffer.writeln('    Get.put<${service.className}>($className());');
        }
      }
    }

    buffer.writeln('  }');

    // 生成统一的依赖注入方法
    final servicesWithInjection = services
        .where((s) => s.injectableFields.isNotEmpty)
        .toList();
    if (servicesWithInjection.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('  /// 为所有服务注入依赖');
      buffer.writeln('  static void injectServices() {');

      for (final service in servicesWithInjection) {
        buffer.writeln('    // 为${service.className}注入依赖');

        // 根据服务是否有名称来决定获取方式
        if (service.serviceName != null) {
          buffer.writeln(
            '    final ${service.className.toLowerCase()}Instance = Get.find<${service.className}>(tag: "${service.serviceName}");',
          );
        } else {
          buffer.writeln(
            '    final ${service.className.toLowerCase()}Instance = Get.find<${service.className}>();',
          );
        }

        for (final field in service.injectableFields) {
          final fieldServiceName = field.serviceName;
          buffer.writeln(
            '    // ${field.lazy ? '懒加载' : '立即'}注入${field.fieldName}',
          );

          // 使用 InjectUtil 工具类进行注入
          buffer.writeln('    InjectUtil.inject<${field.fieldType}>(');
          if (fieldServiceName != null) {
            buffer.writeln('      "$fieldServiceName",');
          } else {
            buffer.writeln('      null,');
          }
          buffer.writeln(
            '      (service) => ${service.className.toLowerCase()}Instance.${field.fieldName} = service,',
          );
          buffer.writeln('    );');
        }
        buffer.writeln();
      }

      buffer.writeln('  }');
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}

/// 服务信息
class ServiceInfo {
  final String className;
  final String importPath;
  final String? serviceName;
  final bool lazy;
  final bool singleton;
  final bool hasAop;
  final List<InjectableField> injectableFields;

  ServiceInfo({
    required this.className,
    required this.importPath,
    this.serviceName,
    required this.lazy,
    required this.singleton,
    required this.hasAop,
    required this.injectableFields,
  });

  factory ServiceInfo.fromElement(
    ClassElement element,
    ConstantReader annotation,
    String filePath,
  ) {
    // 读取@Service注解参数
    final serviceName = annotation.read('name').isNull
        ? null
        : annotation.read('name').stringValue;
    final lazy = annotation.read('lazy').boolValue;
    final singleton = annotation.read('singleton').boolValue;

    // 检查是否有@Aop注解
    final hasAop = _hasAopAnnotation(element);

    // 收集@Auto标注的字段
    final injectableFields = _collectInjectableFields(element);

    // 生成相对导入路径（从 lib/init/ 的角度）
    String importPath = filePath.replaceFirst('lib/', '../');
    if (filePath.startsWith('lib/examples/')) {
      importPath = filePath.replaceFirst('lib/', '../');
    } else if (filePath.startsWith('lib/services/')) {
      importPath = filePath.replaceFirst('lib/', '../');
    } else {
      importPath = filePath.replaceFirst('lib/', '../');
    }

    return ServiceInfo(
      className: element.name ?? 'UnknownClass',
      importPath: importPath,
      serviceName: serviceName,
      lazy: lazy,
      singleton: singleton,
      hasAop: hasAop,
      injectableFields: injectableFields,
    );
  }

  /// 检查类是否有@Aop注解
  static bool _hasAopAnnotation(ClassElement element) {
    final annotations = element.metadata.annotations;

    for (final annotation in annotations) {
      try {
        final annotationElement = annotation.element;
        if (annotationElement?.enclosingElement?.name == 'Aop') {
          return true;
        }
      } catch (e) {
        // 忽略解析错误
      }
    }
    return false;
  }

  /// 收集标注@Auto的字段
  static List<InjectableField> _collectInjectableFields(ClassElement element) {
    final fields = <InjectableField>[];

    for (final field in element.fields) {
      final annotations = field.metadata.annotations;

      for (final annotation in annotations) {
        try {
          final annotationElement = annotation.element;
          if (annotationElement?.enclosingElement?.name == 'Auto') {
            final annotationReader = ConstantReader(
              annotation.computeConstantValue(),
            );
            final lazy = annotationReader.read('lazy').boolValue;
            final serviceName = annotationReader.read('name').isNull
                ? null
                : annotationReader.read('name').stringValue;

            fields.add(
              InjectableField(
                fieldName: field.name ?? 'unknownField',
                fieldType: field.type.getDisplayString(withNullability: false),
                lazy: lazy,
                serviceName: serviceName,
              ),
            );
            break;
          }
        } catch (e) {
          // 忽略解析错误
        }
      }
    }

    return fields;
  }
}

/// 可注入字段信息
class InjectableField {
  final String fieldName;
  final String fieldType;
  final bool lazy;
  final String? serviceName;

  InjectableField({
    required this.fieldName,
    required this.fieldType,
    required this.lazy,
    this.serviceName,
  });
}

/// 创建服务生成器的Builder
Builder serviceGenerator(BuilderOptions options) {
  return ServiceGenerator();
}
