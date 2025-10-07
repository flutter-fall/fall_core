import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:logger/logger.dart';
import 'package:source_gen/source_gen.dart';
import 'package:path/path.dart' as p;
import 'package:fall_core_base/fall_core_base.dart';

/// 依赖注入工具类
///
/// 提供统一的依赖注入方法，包含完整的错误处理和日志记录
class GenUtil {
  // 框架级日志记录器
  static final Logger _logger = LoggerFactory.getFrameworkLogger();
  static bool hasAnnotation(Element element, Type annotation) {
    return checker(annotation).hasAnnotationOfExact(element);
  }

  static DartObject? getAnnotation(Element element, Type annotation) {
    return checker(annotation).firstAnnotationOfExact(element);
  }

  static TypeChecker checker(Type type) {
    return TypeChecker.typeNamed(type);
  }

  /// 计算相对导入路径
  ///
  /// [importUri] 需要导入的文件的URI
  /// [outputUri] 输出文件的URI
  /// 返回相对导入路径
  static String getImportPath(Uri importUri, Uri outputUri) {
    _logger.i('计算导入路径: $importUri -> $outputUri');
    try {
      // 如果是package URI，检查是否为相同package
      if (importUri.scheme == 'package' && outputUri.scheme == 'package') {
        // 提取package名称
        final importPackage = importUri.pathSegments.isNotEmpty
            ? importUri.pathSegments.first
            : '';
        final outputPackage = outputUri.pathSegments.isNotEmpty
            ? outputUri.pathSegments.first
            : '';

        // 如果是相同package，计算相对路径
        if (importPackage == outputPackage && importPackage.isNotEmpty) {
          // 构建相对路径，去掉package名称部分
          final importPath = importUri.pathSegments.skip(1).join('/');
          final outputPath = outputUri.pathSegments.skip(1).join('/');
          final outputDir = p.dirname(outputPath);

          String relativePath = p.relative(importPath, from: outputDir);

          // 确保使用正斜杠作为路径分隔符（Dart导入路径要求）
          relativePath = relativePath.replaceAll(p.separator, '/');

          // 如果相对路径不以'./'开头，添加'./'
          if (!relativePath.startsWith('./') &&
              !relativePath.startsWith('../')) {
            relativePath = './$relativePath';
          }

          return relativePath;
        }
      }

      // 如果是asset URI，检查是否为相同package
      if (importUri.scheme == 'asset' && outputUri.scheme == 'asset') {
        // 提取package名称
        final importPackage = importUri.pathSegments.isNotEmpty
            ? importUri.pathSegments.first
            : '';
        final outputPackage = outputUri.pathSegments.isNotEmpty
            ? outputUri.pathSegments.first
            : '';

        // 如果是相同package，计算相对路径
        if (importPackage == outputPackage && importPackage.isNotEmpty) {
          // 构建相对路径，去掉package名称部分
          final importPath = importUri.pathSegments.skip(1).join('/');
          final outputPath = outputUri.pathSegments.skip(1).join('/');
          final outputDir = p.dirname(outputPath);

          String relativePath = p.relative(importPath, from: outputDir);

          // 确保使用正斜杠作为路径分隔符（Dart导入路径要求）
          relativePath = relativePath.replaceAll(p.separator, '/');

          // 如果相对路径不以'./'开头，添加'./'
          if (!relativePath.startsWith('./') &&
              !relativePath.startsWith('../')) {
            relativePath = './$relativePath';
          }

          return relativePath;
        }
      }

      // 如果是不同package的package URI或asset URI，直接返回
      if (importUri.scheme == 'package' || importUri.scheme == 'asset') {
        return importUri.toString();
      }

      // 计算相对路径
      if (importUri.scheme == 'file' && outputUri.scheme == 'file') {
        String importPath = importUri.toFilePath();
        String outputPath = outputUri.toFilePath();
        String outputDir = p.dirname(outputPath);

        String relativePath = p.relative(importPath, from: outputDir);

        // 确保使用正斜杠作为路径分隔符（Dart导入路径要求）
        relativePath = relativePath.replaceAll(p.separator, '/');

        // 如果相对路径不以'./'开头，添加'./'
        if (!relativePath.startsWith('./') && !relativePath.startsWith('../')) {
          relativePath = './$relativePath';
        }

        return relativePath;
      }

      // 其他情况直接返回原始URI字符串
      return importUri.toString();
    } catch (e) {
      _logger.e('计算导入路径失败', error: e);
      // 如果计算失败，返回原始URI字符串
      return importUri.toString();
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
          _logger.w('不支持的类型: $T，尝试直接转换');
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
      _logger.e('读取列表参数失败: $fieldName', error: e);
      return defaultValue;
    }
  }
}
