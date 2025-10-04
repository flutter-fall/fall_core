import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:glob/glob.dart';
import 'package:fall_core_base/fall_core_base.dart';
import '../utils/gen_util.dart';

/// 服务扫描代码生成器
///
/// 基于@AutoScan注解的include和exclude配置，扫描所有@Service标注的类，
/// 生成自动注册和依赖注入逻辑作为被标注类的part文件
class ServiceAutoScan extends GeneratorForAnnotation<AutoScan> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    // 只处理类
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('@AutoScan注解只能用于类', element: element);
    }

    final className = element.name ?? 'UnknownClass';

    // 读取@AutoScan注解参数
    final includePatterns = _readStringList(annotation, 'include', [
      'lib/**/*.dart',
    ]);
    final excludePatterns = _readStringList(annotation, 'exclude', [
      '**/*.g.dart',
      '**/*.freezed.dart',
    ]);

    // 收集所有@Service标注的类
    final services = <ServiceInfo>[];
    await _scanServices(buildStep, services, includePatterns, excludePatterns);

    if (services.isEmpty) {
      return '// No services found to generate';
    }

    // 生成part文件内容
    return _generatePartFile(services, className, buildStep.inputId.uri);
  }

  /// 读取注解中的字符串列表参数
  List<String> _readStringList(
    ConstantReader annotation,
    String fieldName,
    List<String> defaultValue,
  ) {
    try {
      if (annotation.read(fieldName).isNull) {
        return defaultValue;
      }
      return annotation
          .read(fieldName)
          .listValue
          .map((e) => e.toStringValue() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      return defaultValue;
    }
  }

  /// 基于include和exclude模式扫描服务
  Future<void> _scanServices(
    BuildStep buildStep,
    List<ServiceInfo> services,
    List<String> includePatterns,
    List<String> excludePatterns,
  ) async {
    final currentPackage = buildStep.inputId.package;

    // 为每个include模式创建Glob并扫描
    for (final includePattern in includePatterns) {
      final glob = Glob(includePattern);

      await for (final input in buildStep.findAssets(glob)) {
        // 只处理当前项目的文件
        if (input.package != currentPackage) continue;

        // 检查是否被exclude模式排除
        if (_isExcluded(input.path, excludePatterns)) continue;

        try {
          final lib = await buildStep.resolver.libraryFor(input);
          final libraryReader = LibraryReader(lib);

          // 查找@Service注解的类
          for (final annotatedElement in libraryReader.annotatedWith(
            TypeChecker.typeNamed(Service),
          )) {
            final element = annotatedElement.element;
            if (element is ClassElement) {
              services.add(
                ServiceInfo.fromElement(
                  element,
                  annotatedElement.annotation,
                  input.uri,
                ),
              );
            }
          }
        } catch (e) {
          // 忽略解析错误，继续处理其他文件
        }
      }
    }
  }

  /// 检查文件路径是否被exclude模式排除
  bool _isExcluded(String filePath, List<String> excludePatterns) {
    for (final excludePattern in excludePatterns) {
      final glob = Glob(excludePattern);
      if (glob.matches(filePath)) {
        return true;
      }
    }
    return false;
  }

  /// 生成part文件内容
  String _generatePartFile(
    List<ServiceInfo> services,
    String className,
    Uri sourceUri,
  ) {
    // 收集导入
    final imports = <Directive>[];

    // 基础导入
    imports.addAll([
      Directive.import('package:get/get.dart'),
      Directive.import('package:fall_common/fall_common.dart'),
    ]);

    // 收集服务文件导入
    final importPaths = <String>{};
    for (final service in services) {
      final relativePath = GenUtil.getImportPath(service.inputUri, sourceUri);
      importPaths.add(relativePath);

      if (service.hasAop) {
        final aopFilePath = relativePath.replaceAll('.dart', '.g.dart');
        importPaths.add(aopFilePath);
      }
    }

    for (final importPath in importPaths) {
      imports.add(Directive.import(importPath));
    }

    // 生成扩展类，包含注册和注入方法
    final extensionClass = Extension(
      (b) => b
        ..name = '${className}Generated'
        ..on = refer(className)
        ..methods.addAll([
          _genRegisterMethod(services),
          if (services.any((s) => s.injectableFields.isNotEmpty))
            _genInjectMethod(services),
        ]),
    );

    // 生成part文件
    final library = Library(
      (b) => b
        ..comments.addAll([
          '// GENERATED CODE - DO NOT MODIFY BY HAND',
          '// part of \'${sourceUri.pathSegments.last}\'',
          '// 服务自动扫描和注册，由Fall Gen框架自动生成',
        ])
        ..directives.addAll(imports)
        ..body.add(extensionClass),
    );

    final emitter = DartEmitter();
    final source = library.accept(emitter).toString();
    return source;
  }
}

/// 生成依赖注入方法
Method _genInjectMethod(List<ServiceInfo> services) {
  final servicesWithInjection = services
      .where((s) => s.injectableFields.isNotEmpty)
      .toList();

  final statements = <String>[];

  for (final service in servicesWithInjection) {
    statements.add('// 为${service.className}注入依赖');

    // 根据服务是否有名称来决定获取方式
    if (service.serviceName != null) {
      statements.add(
        'final ${service.className.toLowerCase()}Instance = Get.find<${service.className}>(tag: "${service.serviceName}");',
      );
    } else {
      statements.add(
        'final ${service.className.toLowerCase()}Instance = Get.find<${service.className}>();',
      );
    }

    for (final field in service.injectableFields) {
      final fieldServiceName = field.serviceName;
      statements.add('// ${field.lazy ? '懒加载' : '立即'}注入${field.fieldName}');

      // 使用 InjectUtil 工具类进行注入
      final injectCode =
          '''
InjectUtil.inject<${field.fieldType}>(
  ${fieldServiceName != null ? '"$fieldServiceName"' : 'null'},
  (service) => ${service.className.toLowerCase()}Instance.${field.fieldName} = service,
);''';
      statements.add(injectCode);
    }
    statements.add(''); // 添加空行
  }

  final methodBodyCode = statements.join('\n');

  return Method(
    (b) => b
      ..static = true
      ..returns = refer('void')
      ..name = 'injectServices'
      ..docs.add('/// 为所有服务注入依赖')
      ..body = Code(methodBodyCode),
  );
}

/// 生成服务注册方法
Method _genRegisterMethod(List<ServiceInfo> services) {
  // 生成方法体代码
  final statements = <String>[];

  for (final service in services) {
    final className = service.hasAop
        ? '${service.className}Aop'
        : service.className;
    final serviceName = service.serviceName;

    statements.add('// 注册${service.serviceName ?? service.className}');

    if (service.lazy) {
      if (serviceName != null) {
        statements.add(
          'Get.lazyPut<${service.className}>(() => $className(), tag: "$serviceName");',
        );
      } else {
        statements.add(
          'Get.lazyPut<${service.className}>(() => $className());',
        );
      }
    } else {
      if (serviceName != null) {
        statements.add(
          'Get.put<${service.className}>($className(), tag: "$serviceName");',
        );
      } else {
        statements.add('Get.put<${service.className}>($className());');
      }
    }
  }

  final methodBodyCode = statements.join('\n');

  return Method(
    (b) => b
      ..static = true
      ..returns = refer('void')
      ..name = 'registerServices'
      ..docs.add('/// 注册所有标注@Service的类到GetX')
      ..body = Code(methodBodyCode),
  );
}

/// 服务信息
class ServiceInfo {
  final String className;
  final Uri inputUri;
  final String? serviceName;
  final bool lazy;
  final bool singleton;
  final bool hasAop;
  final List<InjectableField> injectableFields;

  ServiceInfo({
    required this.className,
    required this.inputUri,
    this.serviceName,
    required this.lazy,
    required this.singleton,
    required this.hasAop,
    required this.injectableFields,
  });

  factory ServiceInfo.fromElement(
    ClassElement element,
    ConstantReader annotation,
    Uri inputUri,
  ) {
    // 读取@Service注解参数
    final serviceName = annotation.read('name').isNull
        ? null
        : annotation.read('name').stringValue;
    final lazy = annotation.read('lazy').boolValue;
    final singleton = annotation.read('singleton').boolValue;

    // 检查是否有@Aop注解
    final hasAop = GenUtil.hasAnnotation(element, Aop);

    // 收集@Auto标注的字段
    final injectableFields = _collectInjectableFields(element);

    return ServiceInfo(
      className: element.name ?? 'UnknownClass',
      inputUri: inputUri,
      serviceName: serviceName,
      lazy: lazy,
      singleton: singleton,
      hasAop: hasAop,
      injectableFields: injectableFields,
    );
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
                fieldType: field.type.getDisplayString(),
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
