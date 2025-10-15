import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:fall_core_base/fall_core_base.dart';
import 'package:fall_gen_base/fall_gen_base.dart';

/// 服务扫描代码生成器
///
/// 基于@AutoScan注解的include、exclude、annotations配置，扫描所有@Service标注的类，
/// 生成自动注册和依赖注入逻辑作为被标注类的part文件
class ServiceAutoScan extends BaseAutoScan<ServiceInfo> {
  ServiceAutoScan({super.debug});
  @override
  List<ServiceInfo> process(
    ClassElement element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    return [ServiceInfo.fromElement(element, annotation, buildStep)];
  }

  @override
  Object genClassExtend(String className, List<Method> methods) {
    return Class(
      (b) => b
        ..name = '${className}Impl'
        ..extend = refer(className)
        ..methods.addAll(methods),
    );
  }

  @override
  List<String> getAdditionalImports(ServiceInfo service, String relativePath) {
    final additionalImports = <String>[];
    if (service.hasAop) {
      final aopFilePath = relativePath.replaceAll('.dart', '.g.dart');
      additionalImports.add(aopFilePath);
    }
    return additionalImports;
  }

  @override
  String genInjectBody(List<ServiceInfo> services) {
    final statements = <String>[];

    for (final service in services) {
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

    return statements.join('\n');
  }

  @override
  String genRegisterBody(List<ServiceInfo> services) {
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

    return statements.join('\n');
  }
}

/// 服务信息
class ServiceInfo implements ServiceInfoBase {
  @override
  final String className;
  @override
  final Uri inputUri;
  @override
  final String? serviceName;
  final bool lazy;
  final bool singleton;
  final bool hasAop;
  @override
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
    BuildStep buildStep,
  ) {
    // 读取@Service注解参数
    final serviceName = annotation.read('name').isNull
        ? null
        : annotation.read('name').stringValue;
    final lazy = annotation.read('lazy').boolValue;
    final singleton = annotation.read('singleton').boolValue;

    // 检查是否有@Aop注解
    final hasAop = AnnoUtil.hasAnnotation(element, Aop);

    // 收集@Auto标注的字段
    final injectableFields = InjectableField.collectInjectableFields(element);

    return ServiceInfo(
      className: element.name ?? 'UnknownClass',
      inputUri: element.library.uri,
      serviceName: serviceName,
      lazy: lazy,
      singleton: singleton,
      hasAop: hasAop,
      injectableFields: injectableFields,
    );
  }
}
