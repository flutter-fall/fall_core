import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:glob/glob.dart';
import 'package:fall_core_base/fall_core_base.dart';
import '../utils/gen_util.dart';
import '../utils/log_util.dart';
import '../utils/anno_util.dart';

/// 自动扫描代码生成器的抽象基类
///
/// 基于@AutoScan注解的include、exclude、annotations配置，
/// 扫描符合条件的类并生成相应的代码
abstract class BaseAutoScan<T extends ServiceInfoBase>
    extends GeneratorForAnnotation<AutoScan> {
  final bool debug;
  BaseAutoScan({this.debug = false});

  /// 步骤1：读取@AutoScan注解参数
  ///
  /// 1.1：include：包含的文件模式，默认为lib/**/*.dart
  /// 1.2：exclude：排除的文件模式，默认为**/*.g.dart
  /// 1.3：annotations：需要扫描的注解类型，默认为Service

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    LogUtil.debug = debug;
    // 只处理类
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('@AutoScan注解只能用于类', element: element);
    }
    // 步骤1：读取@AutoScan注解参数
    final includePatterns = AnnoUtil.readList(annotation, 'include', [
      'lib/**/*.dart',
    ]);
    final excludePatterns = AnnoUtil.readList(annotation, 'exclude', [
      '**/*.g.dart',
      '**/*.freezed.dart',
    ]);
    final annotations = AnnoUtil.readListType(annotation, 'annotations', [
      Service,
    ]);
    // 步骤2：根据配置扫描符合条件的文件
    final services = await scanAndProcess(
      buildStep,
      includePatterns,
      excludePatterns,
      annotations,
    );

    if (services.isEmpty) {
      return '// No services found to generate';
    }

    // 步骤3：生成class文件
    return genClassFile(services, element, annotation, buildStep);
  }

  /// 步骤2：根据annotations扫描符合条件的文件并处理
  Future<List<T>> scanAndProcess(
    BuildStep buildStep,
    List<String> includePatterns,
    List<String> excludePatterns,
    List<TypeChecker> typeCheckers,
  ) async {
    final services = <T>[];
    final currentPackage = buildStep.inputId.package;

    // 打印 TypeChecker 信息
    for (final checker in typeCheckers) {
      LogUtil.d('TypeChecker: $checker');
    }
    // 为每个include模式创建Glob并扫描
    for (final includePattern in includePatterns) {
      final glob = Glob(includePattern);

      await for (final input in buildStep.findAssets(glob)) {
        // 只处理当前项目的文件
        if (input.package != currentPackage) continue;

        // 检查是否被exclude模式排除
        if (isExcluded(input.path, excludePatterns)) continue;

        try {
          final lib = await buildStep.resolver.libraryFor(input);
          final libraryReader = LibraryReader(lib);
          // 对每个TypeChecker进行检查
          for (final typeChecker in typeCheckers) {
            for (final clazz in libraryReader.classes) {
              if (typeChecker.hasAnnotationOf(clazz)) {
                LogUtil.d(
                  '${clazz.displayName} has annotation:${typeChecker.toString()}',
                );
                services.addAll(
                  process(
                    clazz,
                    ConstantReader(typeChecker.firstAnnotationOfExact(clazz)),
                    buildStep,
                  ),
                );
              }
            }
          }
        } catch (e) {
          // 忽略解析错误，继续处理其他文件
        }
      }
    }

    return services;
  }

  /// 检查文件路径是否被exclude模式排除
  bool isExcluded(String filePath, List<String> excludePatterns) {
    for (final excludePattern in excludePatterns) {
      final glob = Glob(excludePattern);
      if (glob.matches(filePath)) {
        return true;
      }
    }
    return false;
  }

  /// 步骤3：生成Class文件
  String genClassFile(
    List<T> services,
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final className = element.name ?? 'UnknownClass';

    // 生成导入
    final imports = genImport(services, buildStep);

    // 生成方法列表
    final methods = <Method>[];
    methods.add(genRegister(services));

    // 只有存在可注入字段时才生成inject方法
    if (services.any((s) => s.injectableFields.isNotEmpty)) {
      methods.add(genInject(services));
    }

    // 生成Class或Extension
    final classOrExtension = genClassExtend(className, methods);

    // 生成Library
    final library = Library(
      (b) => b
        ..directives.addAll(imports)
        ..body.add(classOrExtension as Spec),
    );

    final emitter = DartEmitter();
    return library.accept(emitter).toString();
  }

  /// 4个子方法：生成导入语句
  List<Directive> genImport(List<T> services, BuildStep buildStep) {
    final sourceUri = buildStep.inputId.uri;
    final imports = <Directive>[];

    // 基础导入
    imports.addAll([
      Directive.import('package:get/get.dart'),
      // Directive.import('package:fall_core_base/fall_core_base.dart'),
      Directive.import('package:fall_core_main/fall_core_main.dart'),
      Directive.import(
        GenUtil.getImportPath(
          buildStep.inputId.uri,
          buildStep.inputId.changeExtension(".g.dart").uri,
        ),
      ),
    ]);

    // 收集服务文件导入
    final importPaths = <String>{};
    for (final service in services) {
      LogUtil.d('Processing service: ${service.inputUri}');

      final relativePath = GenUtil.getImportPath(service.inputUri, sourceUri);
      importPaths.add(relativePath);

      // 子类可以覆盖此方法添加特定导入
      importPaths.addAll(getAdditionalImports(service, relativePath));
    }

    for (final importPath in importPaths) {
      imports.add(Directive.import(importPath));
    }

    return imports;
  }

  /// 统一的注册方法
  Method genRegister(List<T> services) {
    return Method(
      (b) => b
        ..static = false
        ..annotations.add(CodeExpression(Code('override\n')))
        ..returns = refer('void')
        ..name = 'register'
        ..docs.add('/// 注册所有服务到GetX')
        ..body = Code(genRegisterBody(services)),
    );
  }

  /// 统一的注入方法
  Method genInject(List<T> services) {
    final servicesWithInjection = services
        .where((s) => s.injectableFields.isNotEmpty)
        .toList();

    return Method(
      (b) => b
        ..static = false
        ..annotations.add(CodeExpression(Code('override\n')))
        ..returns = refer('void')
        ..name = 'inject'
        ..docs.add('/// 为所有服务注入依赖')
        ..body = Code(genInjectBody(servicesWithInjection)),
    );
  }

  // 抽象方法，需要子类实现

  /// 处理单个ClassElement，返回对应的服务信息对象列表
  List<T> process(
    ClassElement element,
    ConstantReader annotation,
    BuildStep buildStep,
  );

  /// 生成注册方法的方法体
  String genRegisterBody(List<T> services);

  /// 生成注入方法的方法体
  String genInjectBody(List<T> services);

  /// 生成Class或Extension对象
  Object genClassExtend(String className, List<Method> methods);

  /// 获取特定服务的额外导入路径
  List<String> getAdditionalImports(T service, String relativePath) => [];
}

/// 服务信息基类接口
abstract class ServiceInfoBase {
  String get className;
  Uri get inputUri;
  String? get serviceName;
  List<InjectableField> get injectableFields;
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

  /// 收集标注@Auto的字段
  static List<InjectableField> collectInjectableFields(ClassElement element) {
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
