import 'package:logger/logger.dart';

/// Logger工厂类，提供统一的Logger实例配置
///
/// 为框架层和业务层提供不同的Logger配置策略：
/// - 框架层：精简配置，专注于错误和调试信息
/// - 业务层：详细配置，支持完整的业务日志记录
class LoggerFactory {
  // 私有构造函数，防止实例化
  LoggerFactory._();

  /// 获取框架级Logger实例
  ///
  /// 适用于框架内部使用（如AopService、InjectUtil等）
  /// 配置特点：
  /// - 精简的调用栈信息
  /// - 专注于错误追踪
  /// - 不显示表情符号，保持专业性
  static Logger getFrameworkLogger() {
    return Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 3,
        lineLength: 80,
        colors: true,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  /// 获取业务级Logger实例
  ///
  /// 适用于业务代码使用（如LogService）
  /// 配置特点：
  /// - 详细的调用栈信息
  /// - 支持表情符号，提升可读性
  /// - 更长的日志行，适合复杂业务信息
  static Logger getBusinessLogger() {
    return Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  /// 获取自定义配置的Logger实例
  ///
  /// 提供完全自定义的Logger配置能力
  /// [methodCount] - 正常情况下显示的调用栈层数
  /// [errorMethodCount] - 错误情况下显示的调用栈层数
  /// [lineLength] - 单行日志的最大长度
  /// [colors] - 是否启用颜色
  /// [printEmojis] - 是否显示表情符号
  static Logger getCustomLogger({
    int methodCount = 1,
    int errorMethodCount = 3,
    int lineLength = 80,
    bool colors = true,
    bool printEmojis = false,
  }) {
    return Logger(
      printer: PrettyPrinter(
        methodCount: methodCount,
        errorMethodCount: errorMethodCount,
        lineLength: lineLength,
        colors: colors,
        printEmojis: printEmojis,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  /// 获取静默Logger实例（用于测试环境）
  ///
  /// 提供无输出的Logger，适用于单元测试或需要静默运行的场景
  static Logger getSilentLogger() {
    return Logger(
      printer: SimplePrinter(),
      output: null, // 不输出任何内容
    );
  }
}
