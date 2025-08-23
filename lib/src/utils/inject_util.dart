import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'logger_factory.dart';

/// 依赖注入工具类
///
/// 提供统一的依赖注入方法，包含完整的错误处理和日志记录
class InjectUtil {
  // 框架级日志记录器
  static final Logger _logger = LoggerFactory.getFrameworkLogger();

  // 注入失败统计
  static final Map<String, int> _injectionFailures = <String, int>{};

  // 最大重试次数
  static const int _maxRetries = 2;

  /// 注入服务
  ///
  /// [serviceName] - 服务名称（可选，用于命名服务）
  /// [setter] - 设置字段值的回调函数
  static void inject<T>(
    String? serviceName,
    void Function(T service) setter, {
    int retryCount = 0,
  }) {
    final serviceKey = _buildServiceKey<T>(serviceName);

    try {
      // 根据是否有服务名称选择获取方式
      final T service = _getService<T>(serviceName);

      // 验证服务有效性
      if (!_validateService(service)) {
        throw Exception('获取的服务为空或无效');
      }

      // 执行注入
      setter(service);

      // 清理成功记录
      _injectionFailures.remove(serviceKey);
    } catch (e) {
      _handleInjectionError<T>(serviceName, serviceKey, e, setter, retryCount);
    }
  }

  /// 构建服务键
  static String _buildServiceKey<T>(String? serviceName) {
    return serviceName != null ? '${T.toString()}:$serviceName' : T.toString();
  }

  /// 获取服务
  static T _getService<T>(String? serviceName) {
    if (serviceName != null) {
      return Get.find<T>(tag: serviceName);
    } else {
      return Get.find<T>();
    }
  }

  /// 验证服务有效性
  static bool _validateService<T>(T service) {
    return service != null;
  }

  /// 处理注入错误
  static void _handleInjectionError<T>(
    String? serviceName,
    String serviceKey,
    dynamic exception,
    void Function(T service) setter,
    int retryCount,
  ) {
    // 更新失败统计
    _injectionFailures[serviceKey] = (_injectionFailures[serviceKey] ?? 0) + 1;

    // 分类处理错误
    final errorType = _classifyError(exception);

    // 是否允许重试
    if (retryCount < _maxRetries && _shouldRetry(errorType, exception)) {
      _logRetryAttempt<T>(serviceName, serviceKey, retryCount + 1, exception);

      // 延迟后重试
      Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)), () {
        inject<T>(serviceName, setter, retryCount: retryCount + 1);
      });
      return;
    }

    // 记录详细错误信息
    _logDetailedError<T>(
      serviceName,
      serviceKey,
      exception,
      errorType,
      retryCount,
    );
  }

  /// 分类错误类型
  static String _classifyError(dynamic exception) {
    final errorMessage = exception.toString().toLowerCase();

    if (errorMessage.contains('not found') ||
        errorMessage.contains('not registered')) {
      return '服务未注册';
    }

    if (errorMessage.contains('type') || errorMessage.contains('cast')) {
      return '类型不匹配';
    }

    if (errorMessage.contains('timeout')) {
      return '获取超时';
    }

    if (errorMessage.contains('tag')) {
      return '标签错误';
    }

    return '未知错误';
  }

  /// 判断是否应该重试
  static bool _shouldRetry(String errorType, dynamic exception) {
    // 仅在可能的临时性错误时重试
    return errorType == '获取超时' || errorType == '未知错误';
  }

  /// 记录重试尝试
  static void _logRetryAttempt<T>(
    String? serviceName,
    String serviceKey,
    int retryCount,
    dynamic exception,
  ) {
    _logger.w('注入服务重试 $retryCount/$_maxRetries: $serviceKey, 原因: $exception');
  }

  /// 记录详细错误信息
  static void _logDetailedError<T>(
    String? serviceName,
    String serviceKey,
    dynamic exception,
    String errorType,
    int retryCount,
  ) {
    try {
      _logger.e(
        '[依赖注入失败] $errorType',
        error: {
          'serviceType': T.toString(),
          'serviceName': serviceName,
          'serviceKey': serviceKey,
          'errorType': errorType,
          'exception': exception,
          'retryCount': retryCount,
          'failureCount': _injectionFailures[serviceKey] ?? 0,
          'suggestions': _generateSuggestions<T>(serviceName, errorType),
          'timestamp': DateTime.now().toIso8601String(),
        },
        stackTrace: StackTrace.current,
      );
    } catch (e) {
      _logger.w('依赖注入错误记录失败: $e');
      _logger.w('原始错误: $errorType - $serviceKey - $exception');
    }
  }

  /// 生成解决建议
  static List<String> _generateSuggestions<T>(
    String? serviceName,
    String errorType,
  ) {
    switch (errorType) {
      case '服务未注册':
        return [
          '请检查 ${T.toString()} 是否已经注册到GetX',
          serviceName != null
              ? '请确认服务名称 "$serviceName" 是否正确'
              : '请确认是否使用了正确的注册方式',
          '检查 AutoScan.registerServices() 是否已执行',
        ];
      case '类型不匹配':
        return ['请检查注册的服务类型与所需类型是否一致', '确认 ${T.toString()} 的类型定义正确'];
      case '标签错误':
        return [
          '请检查命名服务的tag是否正确',
          serviceName != null ? '确认服务注册时使用的tag与获取时一致' : '检查是否需要使用命名服务',
        ];
      default:
        return ['请检查控制台日志获取更多信息', '确认GetX框架已正确初始化'];
    }
  }

  /// 获取注入统计信息
  static Map<String, dynamic> getInjectionStats() {
    return {
      'totalFailures': _injectionFailures.length,
      'failures': Map.from(_injectionFailures),
    };
  }

  /// 重置统计信息
  static void resetStats() {
    _injectionFailures.clear();
  }
}
