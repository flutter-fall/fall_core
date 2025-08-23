import 'package:logger/logger.dart';
import 'hook_context.dart';
import 'before_hook.dart';
import 'after_hook.dart';
import 'throw_hook.dart';
import 'around_hook.dart';
import '../utils/logger_factory.dart';

/// 标准的日志记录BeforeHook
///
/// 在方法执行前记录方法调用信息，包括：
/// - 类名和方法名
/// - 调用参数（敏感参数会被遮蔽）
/// - 调用时间
class LogBeforeHook implements BeforeHook {
  static final Logger _logger = LoggerFactory.getBusinessLogger();

  @override
  String get name => 'logging';

  @override
  void execute(HookContext context) {
    try {
      // 参数验证
      if (context.target == null) {
        print('LogBeforeHook: target is null');
        return;
      }

      if (context.methodName.isEmpty) {
        print('LogBeforeHook: methodName is empty');
        return;
      }

      final className = context.target.runtimeType.toString();
      final methodName = context.methodName;

      // 处理参数，对可能的敏感信息进行遮蔽
      final safeArgs = _maskSensitiveArgs(methodName, context.arguments ?? []);

      _logger.i(
        '[$className.$methodName] 方法调用开始',
        error: {
          'className': className,
          'methodName': methodName,
          'arguments': safeArgs,
          'argumentTypes': (context.argumentTypes ?? [])
              .map((t) => t.toString())
              .toList(),
          'returnType': context.returnType?.toString() ?? 'unknown',
          'allowedHooks': context.allowedHooks ?? [],
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // 防止LogHook异常影响主流程
      print('LogBeforeHook执行异常: $e');
    }
  }

  /// 遮蔽敏感参数
  List<dynamic> _maskSensitiveArgs(String methodName, List<dynamic> args) {
    try {
      if (args.isEmpty) return [];

      // 对常见的敏感方法参数进行遮蔽
      if (methodName.toLowerCase().contains('login') ||
          methodName.toLowerCase().contains('password') ||
          methodName.toLowerCase().contains('auth')) {
        return args.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          // 通常第二个参数是密码
          if (index == 1 && value is String) {
            return '****';
          }
          return value;
        }).toList();
      }
      return args;
    } catch (e) {
      // 参数处理异常时返回安全默认值
      return ['<参数处理异常>'];
    }
  }
}

/// 标准的性能计时AroundHook
///
/// 在方法执行前后记录执行时间，包括：
/// - 方法执行开始时间
/// - 方法执行结束时间
/// - 准确的执行耗时统计
/// - 执行成功/失败状态
class TimingAroundHook implements AroundHook {
  static final Logger _logger = LoggerFactory.getBusinessLogger();

  @override
  String get name => 'timing';

  @override
  dynamic execute(HookContext context, Function proceed) {
    Stopwatch? stopwatch;

    try {
      // 参数验证
      if (context.target == null || context.methodName.isEmpty) {
        return proceed();
      }

      final className = context.target.runtimeType.toString();
      final methodName = context.methodName;
      stopwatch = Stopwatch()..start();

      try {
        final result = proceed();
        stopwatch.stop();

        // 记录成功执行的时间
        _logger.i(
          '[$className.$methodName] 执行完成',
          error: {
            'className': className,
            'methodName': methodName,
            'duration': '${stopwatch.elapsedMilliseconds}ms',
            'success': true,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        return result;
      } catch (e) {
        stopwatch?.stop();

        // 记录执行失败的时间
        _logger.e(
          '[$className.$methodName] 执行失败',
          error: {
            'exception': e,
            'className': className,
            'methodName': methodName,
            'duration': '${stopwatch?.elapsedMilliseconds ?? 0}ms',
            'success': false,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        rethrow;
      }
    } catch (e) {
      // TimingHook本身异常时的处理
      stopwatch?.stop();
      print('TimingAroundHook执行异常: $e');
      // 异常时仍然执行原方法
      return proceed();
    }
  }
}

/// 标准的日志记录AfterHook
///
/// 在方法执行后记录方法完成信息，包括：
/// - 方法执行结果
/// - 返回值类型
/// - 执行完成时间
class LogAfterHook implements AfterHook {
  static final Logger _logger = LoggerFactory.getBusinessLogger();

  @override
  String get name => 'logging';

  @override
  void execute(HookContext context) {
    try {
      // 参数验证
      if (context.target == null || context.methodName.isEmpty) {
        print('LogAfterHook: invalid context');
        return;
      }

      final className = context.target.runtimeType.toString();
      final methodName = context.methodName;

      // 处理返回值，避免记录过大的对象
      final safeResult = _formatResult(context.result);

      // 特殊处理异步结果
      final resultInfo = _analyzeResult(context.result);

      _logger.i(
        '[$className.$methodName] 方法执行完成',
        error: {
          'className': className,
          'methodName': methodName,
          'result': safeResult,
          'resultType': resultInfo['type'],
          'isAsync': resultInfo['isAsync'],
          'returnType': context.returnType?.toString() ?? 'unknown',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // 防止LogHook异常影响主流程
      print('LogAfterHook执行异常: $e');
    }
  }

  /// 格式化返回值，避免记录过大的对象
  dynamic _formatResult(dynamic result) {
    try {
      if (result == null) return null;

      // 基本类型直接返回
      if (result is String || result is num || result is bool) {
        return result;
      }

      // Future类型特殊处理
      if (result is Future) {
        return '<Future<${result.runtimeType.toString().replaceAll('Future<', '').replaceAll('>', '')}> - 异步结果>';
      }

      // Map类型，限制大小
      if (result is Map) {
        if (result.length <= 10) {
          return result;
        } else {
          return '${result.runtimeType}(size: ${result.length})';
        }
      }

      // List类型，限制大小
      if (result is List) {
        if (result.length <= 10) {
          return result;
        } else {
          return '${result.runtimeType}(length: ${result.length})';
        }
      }

      // 其他复杂对象，只记录类型
      return result.runtimeType.toString();
    } catch (e) {
      return '<结果格式化异常: $e>';
    }
  }

  /// 分析返回结果类型和特性
  Map<String, dynamic> _analyzeResult(dynamic result) {
    try {
      return {
        'type': result?.runtimeType.toString() ?? 'null',
        'isAsync': result is Future,
        'isCollection': result is Iterable || result is Map,
        'size': _getResultSize(result),
      };
    } catch (e) {
      return {
        'type': 'unknown',
        'isAsync': false,
        'isCollection': false,
        'size': 0,
      };
    }
  }

  /// 获取结果大小
  int _getResultSize(dynamic result) {
    try {
      if (result is Map) return result.length;
      if (result is Iterable) return result.length;
      if (result is String) return result.length;
      return 0;
    } catch (e) {
      return 0;
    }
  }
}

/// 标准的日志记录ThrowHook
///
/// 在方法执行异常时记录异常信息，包括：
/// - 异常类型和消息
/// - 异常堆栈信息
/// - 方法调用上下文
class LogThrowHook implements ThrowHook {
  static final Logger _logger = LoggerFactory.getBusinessLogger();

  @override
  String get name => 'logging';

  @override
  void execute(HookContext context) {
    try {
      // 参数验证
      if (context.target == null || context.methodName.isEmpty) {
        print('LogThrowHook: invalid context');
        return;
      }

      final className = context.target.runtimeType.toString();
      final methodName = context.methodName;
      final exception = context.exception;

      // 记录异常信息
      _logger.e(
        '[$className.$methodName] 方法执行异常',
        error: {
          'exception': exception,
          'className': className,
          'methodName': methodName,
          'exceptionType': exception?.runtimeType.toString() ?? 'unknown',
          'exceptionMessage': _getSafeExceptionMessage(exception),
          'arguments': _maskSensitiveArgs(methodName, context.arguments ?? []),
          'argumentTypes': (context.argumentTypes ?? [])
              .map((t) => t.toString())
              .toList(),
          'returnType': context.returnType?.toString() ?? 'unknown',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // 防止ThrowHook异常导致循环异常
      print('LogThrowHook执行异常(已防止循环): $e');
    }
  }

  /// 安全获取异常消息
  String _getSafeExceptionMessage(dynamic exception) {
    try {
      return exception?.toString() ?? 'null exception';
    } catch (e) {
      return '<异常消息获取失败>';
    }
  }

  /// 遮蔽敏感参数（与BeforeHook保持一致）
  List<dynamic> _maskSensitiveArgs(String methodName, List<dynamic> args) {
    try {
      if (args.isEmpty) return [];

      if (methodName.toLowerCase().contains('login') ||
          methodName.toLowerCase().contains('password') ||
          methodName.toLowerCase().contains('auth')) {
        return args.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          if (index == 1 && value is String) {
            return '****';
          }
          return value;
        }).toList();
      }
      return args;
    } catch (e) {
      return ['<参数处理异常>'];
    }
  }
}
