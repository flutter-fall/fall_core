import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fall_gen_base/fall_gen_base.dart';

/// 类加载工具类
/// 提供通用的类加载和子类判断功能
class ClassUtil {
  /// 加载文件中对应的子类，返回类集合
  ///
  /// [buildStep] 构建步骤
  /// [filePath] 要加载的文件路径
  /// [parentClassName] 父类名称
  static Future<Set<ClassElement>> loadSubclasses(
    BuildStep buildStep,
    String filePath,
    String? parentClassName,
  ) async {
    LogUtil.d(
      'ClassUtil.loadSubclasses: 开始加载 $parentClassName 的子类 from $filePath',
    );

    try {
      // 构建目标文件的AssetId
      final targetAssetId = AssetId(buildStep.inputId.package, filePath);
      // 检查文件是否存在
      if (!await buildStep.canRead(targetAssetId)) {
        LogUtil.d('⚠️ ClassUtil.loadSubclasses: 文件不存在: $filePath，返回空集合');
        return <ClassElement>{};
      }

      LogUtil.d('ClassUtil.loadSubclasses: 开始读取文件$targetAssetId内容...');

      return parseClasses(targetAssetId, buildStep, parentClassName);
    } catch (e) {
      LogUtil.d('⚠️ ClassUtil.loadSubclasses: 加载过程中发生错误: $e');
      return <ClassElement>{};
    }
  }

  static Future<Set<ClassElement>> parseClasses(
    AssetId targetAssetId,
    BuildStep buildStep,
    String? parentClassName,
  ) async {
    // 获取解析器和库
    final resolver = buildStep.resolver;
    final library = await resolver.libraryFor(targetAssetId);

    // 从解析结果中查找目标类名
    final subclasses = <ClassElement>{};
    LogUtil.d('ClassUtil.loadSubclasses: 开始遍历AST查找 $parentClassName 的子类...');

    for (final clazz in library.classes) {
      if (isSubclassOf(clazz, parentClassName)) {
        subclasses.add(clazz);
        LogUtil.d(
          '🔥 ClassUtil.loadSubclasses: 从源码中找到 $parentClassName 子类: ${clazz.name}',
        );
      }
    }

    LogUtil.d(
      '✅ ClassUtil.loadSubclasses: 加载完成，找到${subclasses.length}个 $parentClassName 子类',
    );
    return subclasses;
  }

  /// 检查ClassElement是否为指定类的子类
  ///
  /// [element] 要检查的类元素
  /// [parentClassName] 父类名称
  /// [checkAllSupertypes] 是否检查所有父类和接口，默认为true
  static bool isSubclassOf(
    ClassElement element,
    String? parentClassName, {
    bool checkAllSupertypes = true,
  }) {
    if (parentClassName == null) {
      return true;
    }
    // 检查直接父类
    final supertype = element.supertype;
    if (supertype != null) {
      final supertypeName = supertype.element.name;
      if (supertypeName == parentClassName) {
        return true;
      }
    }

    // 如果需要，检查所有父类和接口
    if (checkAllSupertypes) {
      final allSupertypes = element.allSupertypes;
      for (final type in allSupertypes) {
        if (type.element.name == parentClassName) {
          return true;
        }
      }
    }

    return false;
  }
}
