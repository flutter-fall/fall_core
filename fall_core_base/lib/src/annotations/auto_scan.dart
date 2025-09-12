/// AutoScan注解，用于配置代码生成器的扫描范围
///
/// 这个注解仅用于配置，实际的扫描功能由fall_gen项目实现
///
/// 使用示例：
/// ```dart
/// @AutoScan(
///   include: ['lib/services/**', 'lib/controllers/**/*.dart'],
///   exclude: ['lib/generated/**', '**/*.g.dart', '**/*.freezed.dart'],
/// )
/// library my_app;
/// ```
class AutoScan {
  /// 需要包含的文件或目录模式列表
  /// 支持glob模式匹配，如：
  /// - 'lib/services/**' : 扫描services目录下的所有文件
  /// - 'lib/**/*.dart' : 扫描lib目录下的所有.dart文件
  /// - 'lib/controllers' : 扫描controllers目录
  final List<String> include;

  /// 需要排除的文件或目录模式列表
  /// 支持glob模式匹配，如：
  /// - '**/*.g.dart' : 排除所有生成的.g.dart文件
  /// - 'lib/generated/**' : 排除generated目录下的所有文件
  /// - '**/test/**' : 排除所有test目录
  final List<String> exclude;

  const AutoScan({
    this.include = const ['lib/**/*.dart'],
    this.exclude = const ['**/*.g.dart', '**/*.freezed.dart'],
  });
}
