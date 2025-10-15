import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'log_util.dart';

class AnnoUtil {
  static bool hasAnnotation(Element element, Type annotation) {
    return checker(annotation).hasAnnotationOfExact(element);
  }

  static DartObject? getAnnotation(Element element, Type annotation) {
    return checker(annotation).firstAnnotationOfExact(element);
  }

  static TypeChecker checker(Type type) {
    return TypeChecker.typeNamed(type);
  }

  /// 组合方法：从 Element 读取指定注解的字段值
  ///
  /// 结合 getAnnotation 和 readValue，一次性读取 Element 的某个 annotation 的某个 field 值
  /// [T] 值的类型
  /// [element] 要读取的元素（如 classElement）
  /// [annotation] 注解类型
  /// [fieldName] 字段名称
  /// [defaultValue] 默认值
  ///
  /// 示例：
  /// ```dart
  /// // 读取 @Service(name: "userService") 中的 name 字段
  /// final name = AnnoUtil.getAnnotationValue<String>(
  ///   classElement,
  ///   Service,
  ///   'name',
  ///   '',
  /// );
  /// ```
  static T getAnnotationValue<T>(
    Element element,
    Type annotation,
    String fieldName,
    T defaultValue,
  ) {
    try {
      // 1. 获取注解
      final dartObject = getAnnotation(element, annotation);
      if (dartObject == null) {
        LogUtil.d('元素 ${element.name} 没有找到注解 $annotation，返回默认值');
        return defaultValue;
      }

      // 2. 创建 ConstantReader
      final reader = ConstantReader(dartObject);

      // 3. 读取字段值
      return readValue<T>(reader, fieldName, defaultValue);
    } catch (e) {
      LogUtil.e('读取注解字段值失败: $annotation.$fieldName', error: e);
      return defaultValue;
    }
  }

  /// 组合方法：从 Element 读取指定注解的列表字段值
  ///
  /// 结合 getAnnotation 和 readList，一次性读取 Element 的某个 annotation 的某个 list field 值
  /// [T] 列表元素的类型
  /// [element] 要读取的元素（如 classElement）
  /// [annotation] 注解类型
  /// [fieldName] 字段名称
  /// [defaultValue] 默认值
  ///
  /// 示例：
  /// ```dart
  /// // 读取 @Aop(hooks: [LogHook, ValidationHook]) 中的 hooks 字段
  /// final hooks = AnnoUtil.getAnnotationList<Type>(
  ///   classElement,
  ///   Aop,
  ///   'hooks',
  ///   [],
  /// );
  /// ```
  static List<T> getAnnotationList<T>(
    Element element,
    Type annotation,
    String fieldName,
    List<T> defaultValue,
  ) {
    try {
      // 1. 获取注解
      final dartObject = getAnnotation(element, annotation);
      if (dartObject == null) {
        LogUtil.d('元素 ${element.name} 没有找到注解 $annotation，返回默认值');
        return defaultValue;
      }

      // 2. 创建 ConstantReader
      final reader = ConstantReader(dartObject);

      // 3. 读取列表字段值
      return readList<T>(reader, fieldName, defaultValue);
    } catch (e) {
      LogUtil.e('读取注解列表字段值失败: $annotation.$fieldName', error: e);
      return defaultValue;
    }
  }

  /// 组合方法：从 Element 读取指定注解的 Type 列表字段值
  ///
  /// 结合 getAnnotation 和 readListType，一次性读取 Element 的某个 annotation 的某个 Type list field 值
  /// [element] 要读取的元素（如 classElement）
  /// [annotation] 注解类型
  /// [fieldName] 字段名称
  /// [defaultValue] 默认值
  ///
  /// 示例：
  /// ```dart
  /// // 读取 @Aop(excludes: [String, int]) 中的 excludes 字段
  /// final excludes = AnnoUtil.getAnnotationListType(
  ///   classElement,
  ///   Aop,
  ///   'excludes',
  ///   [],
  /// );
  /// ```
  static List<TypeChecker> getAnnotationListType(
    Element element,
    Type annotation,
    String fieldName,
    List<Type> defaultValue,
  ) {
    try {
      // 1. 获取注解
      final dartObject = getAnnotation(element, annotation);
      if (dartObject == null) {
        LogUtil.d('元素 ${element.name} 没有找到注解 $annotation，返回默认值');
        return defaultValue.map((type) => TypeChecker.typeNamed(type)).toList();
      }

      // 2. 创建 ConstantReader
      final reader = ConstantReader(dartObject);

      // 3. 读取 Type 列表字段值
      return readListType(reader, fieldName, defaultValue);
    } catch (e) {
      LogUtil.e('读取注解 Type 列表字段值失败: $annotation.$fieldName', error: e);
      return defaultValue.map((type) => TypeChecker.typeNamed(type)).toList();
    }
  }

  /// 组合方法：从 Element 读取指定注解的单个 Type 字段值
  ///
  /// 结合 getAnnotation 和 readType，一次性读取 Element 的某个 annotation 的某个 Type field 值
  /// [element] 要读取的元素（如 classElement）
  /// [annotation] 注解类型
  /// [fieldName] 字段名称
  /// [defaultValue] 默认值
  ///
  /// 示例：
  /// ```dart
  /// // 读取 @Service(type: UserService) 中的 type 字段
  /// final type = AnnoUtil.getAnnotationType(
  ///   classElement,
  ///   Service,
  ///   'type',
  ///   null,
  /// );
  /// ```
  static TypeChecker? getAnnotationType(
    Element element,
    Type annotation,
    String fieldName,
    Type? defaultValue,
  ) {
    try {
      // 1. 获取注解
      final dartObject = getAnnotation(element, annotation);
      if (dartObject == null) {
        LogUtil.d('元素 ${element.name} 没有找到注解 $annotation，返回默认值');
        return defaultValue != null
            ? TypeChecker.typeNamed(defaultValue)
            : null;
      }

      // 2. 创建 ConstantReader
      final reader = ConstantReader(dartObject);

      // 3. 读取 Type 字段值
      return readType(reader, fieldName, defaultValue);
    } catch (e) {
      LogUtil.e('读取注解 Type 字段值失败: $annotation.$fieldName', error: e);
      return defaultValue != null ? TypeChecker.typeNamed(defaultValue) : null;
    }
  }

  /// 读取注解中的单个值参数（泛型版本）
  ///
  /// 支持读取不同类型的单个值：String、int、double、bool 等
  /// [T] 值的类型
  /// [annotation] 注解读取器
  /// [fieldName] 字段名称
  /// [defaultValue] 默认值
  static T readValue<T>(
    ConstantReader annotation,
    String fieldName,
    T defaultValue,
  ) {
    try {
      final reader = annotation.read(fieldName);

      if (reader.isNull) {
        return defaultValue;
      }

      T? value;

      if (T == String) {
        value = reader.stringValue as T?;
      } else if (T == int) {
        value = reader.intValue as T?;
      } else if (T == double) {
        value = reader.doubleValue as T?;
      } else if (T == bool) {
        value = reader.boolValue as T?;
      } else {
        // 对于其他类型，记录警告并返回默认值
        LogUtil.w('不支持的类型: $T，返回默认值');
        return defaultValue;
      }

      if (value != null) {
        // 对于字符串类型，如果为空字符串且默认值不为空，返回默认值
        if (T == String &&
            (value as String).isEmpty &&
            (defaultValue as String).isNotEmpty) {
          return defaultValue;
        }
        return value;
      }

      return defaultValue;
    } catch (e) {
      LogUtil.e('读取单个值参数失败: $fieldName', error: e);
      return defaultValue;
    }
  }

  /// 读取注解中的列表参数（泛型版本）
  ///
  /// 支持读取不同类型的列表：String、Type、int 等
  /// [T] 列表元素的类型
  /// [annotation] 注解读取器
  /// [fieldName] 字段名称
  /// [defaultValue] 默认值
  static List<T> readList<T>(
    ConstantReader annotation,
    String fieldName,
    List<T> defaultValue,
  ) {
    try {
      if (annotation.read(fieldName).isNull) {
        return defaultValue;
      }

      final listValue = annotation.read(fieldName).listValue;
      final result = <T>[];

      for (final item in listValue) {
        T? value;

        if (T == String) {
          value = item.toStringValue() as T?;
        } else if (T == Type) {
          value = item.toTypeValue() as T?;
        } else if (T == int) {
          value = item.toIntValue() as T?;
        } else if (T == double) {
          value = item.toDoubleValue() as T?;
        } else if (T == bool) {
          value = item.toBoolValue() as T?;
        } else {
          // 对于其他类型，尝试直接转换
          LogUtil.w('不支持的类型: $T，尝试直接转换');
          continue;
        }

        if (value != null) {
          // 对于字符串类型，过滤空字符串
          if (T == String && (value as String).isEmpty) {
            continue;
          }
          result.add(value);
        }
      }

      return result;
    } catch (e) {
      LogUtil.e('读取列表参数失败: $fieldName', error: e);
      return defaultValue;
    }
  }

  /// 读取注解中的 Type 列表参数（非泛型版本）
  ///
  /// 专门用于读取 Type 类型的列表，解决泛型 `T == Type` 判断失败的问题
  /// 当使用泛型 `readList<Type>` 时，由于泛型擦除，`T == Type` 会返回 false
  /// 此方法直接处理 DartType，返回 TypeChecker 列表以便在代码生成时使用
  ///
  /// [annotation] 注解读取器
  /// [fieldName] 字段名称
  /// [defaultValue] 默认值（运行时 Type 列表，用于创建默认的 TypeChecker）
  static List<TypeChecker> readListType(
    ConstantReader annotation,
    String fieldName,
    List<Type> defaultValue,
  ) {
    try {
      if (annotation.read(fieldName).isNull) {
        // 返回默认值对应的 TypeChecker 列表
        return defaultValue.map((type) => TypeChecker.typeNamed(type)).toList();
      }

      final listValue = annotation.read(fieldName).listValue;
      final result = <TypeChecker>[];

      for (final item in listValue) {
        final dartType = item.toTypeValue();
        if (dartType != null) {
          LogUtil.d('读取到类型: ${dartType.getDisplayString()}');

          // 从 DartType 创建 TypeChecker
          // 使用类型的完整名称（包含库信息）
          final element = dartType.element;
          if (element != null) {
            final libraryUrl = element.library?.identifier;
            final typeName = element.name;

            if (libraryUrl != null) {
              LogUtil.d('创建 TypeChecker: $typeName from $libraryUrl');
              final typeChecker = TypeChecker.fromUrl('$libraryUrl#$typeName');
              result.add(typeChecker);
            } else {
              LogUtil.w('无法获取类型的库信息: $dartType');
            }
          }
        }
      }

      return result.isNotEmpty
          ? result
          : defaultValue.map((type) => TypeChecker.typeNamed(type)).toList();
    } catch (e) {
      LogUtil.e('读取 Type 列表参数失败: $fieldName', error: e);
      // 返回默认值对应的 TypeChecker 列表
      return defaultValue.map((type) => TypeChecker.typeNamed(type)).toList();
    }
  }

  /// 读取注解中的单个 Type 参数（非泛型版本）
  ///
  /// 专门用于读取单个 Type 类型的值，解决泛型 `T == Type` 判断失败的问题
  /// 此方法直接处理 DartType，返回 TypeChecker 以便在代码生成时使用
  ///
  /// [annotation] 注解读取器
  /// [fieldName] 字段名称
  /// [defaultValue] 默认值（运行时 Type，用于创建默认的 TypeChecker）
  static TypeChecker? readType(
    ConstantReader annotation,
    String fieldName,
    Type? defaultValue,
  ) {
    try {
      final reader = annotation.read(fieldName);

      if (reader.isNull) {
        // 如果字段为 null，返回默认值对应的 TypeChecker
        return defaultValue != null
            ? TypeChecker.typeNamed(defaultValue)
            : null;
      }

      final dartType = reader.typeValue;
      LogUtil.d('读取到类型: ${dartType.getDisplayString()}');

      // 从 DartType 创建 TypeChecker
      // 使用类型的完整名称（包含库信息）
      final element = dartType.element;
      if (element == null) {
        LogUtil.w('无法获取类型元素: $dartType');
        return defaultValue != null
            ? TypeChecker.typeNamed(defaultValue)
            : null;
      }

      final libraryUrl = element.library?.identifier;
      final typeName = element.name;

      if (libraryUrl == null) {
        LogUtil.w('无法获取类型的库信息: $dartType');
        return defaultValue != null
            ? TypeChecker.typeNamed(defaultValue)
            : null;
      }

      LogUtil.d('创建 TypeChecker: $typeName from $libraryUrl');
      return TypeChecker.fromUrl('$libraryUrl#$typeName');
    } catch (e) {
      LogUtil.e('读取 Type 参数失败: $fieldName', error: e);
      // 返回默认值对应的 TypeChecker
      return defaultValue != null ? TypeChecker.typeNamed(defaultValue) : null;
    }
  }
}
