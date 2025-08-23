import 'package:logger/logger.dart';
import '../annotations/annotations.dart';
import '../hooks/hooks.dart';
import '../utils/logger_factory.dart';

/// AOP服务，管理和执行Hook逻辑
///
/// 执行顺序：around -> before -> 目标方法 -> after -> throw(异常处理)
///
/// 使用示例：
/// ```dart
/// final aopService = Get.find<AopService>();
/// aopService.addBeforeHook(LoggingBeforeHook());
/// aopService.addAfterHook(LoggingAfterHook());
/// ```
@Service()
class AopService {
  // 框架级日志记录器
  static final Logger _logger = LoggerFactory.getFrameworkLogger();

  final List<BeforeHook> _beforeHooks = [];
  final List<AfterHook> _afterHooks = [];
  final List<ThrowHook> _throwHooks = [];
  final List<AroundHook> _aroundHooks = [];

  // Hook执行上下文缓存，用于去重和错误恢复
  final Map<String, Set<String>> _executedHooks = {};

  // 框架异常计数器
  int _frameworkExceptionCount = 0;

  // Hook执行统计
  final Map<String, int> _hookExecutionStats = {};

  /// 添加前置Hook
  void addBeforeHook(BeforeHook hook) {
    _beforeHooks.add(hook);
    _logger.d('添加BeforeHook: ${hook.name}');
  }

  /// 添加后置Hook
  void addAfterHook(AfterHook hook) {
    _afterHooks.add(hook);
    _logger.d('添加AfterHook: ${hook.name}');
  }

  /// 添加异常Hook
  void addThrowHook(ThrowHook hook) {
    _throwHooks.add(hook);
    _logger.d('添加ThrowHook: ${hook.name}');
  }

  /// 添加环绕Hook
  void addAroundHook(AroundHook hook) {
    _aroundHooks.add(hook);
    _logger.d('添加AroundHook: ${hook.name}');
  }

  /// 执行前置Hook
  void executeBefore(HookContext context) {
    final executionId = _getExecutionId(context);
    final executedHooks = _executedHooks[executionId] ??= <String>{};

    for (final hook in _beforeHooks) {
      if (context.isHookAllowed(hook.name)) {
        final hookKey = 'before_${hook.name}';

        // 检查是否已执行，防止重复
        if (executedHooks.contains(hookKey)) {
          continue;
        }

        try {
          hook.execute(context);
          executedHooks.add(hookKey);
          _updateHookStats('before_${hook.name}');
        } catch (e) {
          _handleHookException('BeforeHook', hook.name, context.methodName, e);
        }
      }
    }
  }

  /// 执行后置Hook
  void executeAfter(HookContext context) {
    final executionId = _getExecutionId(context);
    final executedHooks = _executedHooks[executionId] ??= <String>{};

    for (final hook in _afterHooks) {
      if (context.isHookAllowed(hook.name)) {
        final hookKey = 'after_${hook.name}';

        // 检查是否已执行，防止重复
        if (executedHooks.contains(hookKey)) {
          continue;
        }

        try {
          hook.execute(context);
          executedHooks.add(hookKey);
          _updateHookStats('after_${hook.name}');
        } catch (e) {
          _handleHookException('AfterHook', hook.name, context.methodName, e);
        }
      }
    }
  }

  /// 执行异常Hook
  void executeThrow(HookContext context) {
    final executionId = _getExecutionId(context);
    final executedHooks = _executedHooks[executionId] ??= <String>{};

    for (final hook in _throwHooks) {
      if (context.isHookAllowed(hook.name)) {
        final hookKey = 'throw_${hook.name}';

        // 检查是否已执行，防止重复
        if (executedHooks.contains(hookKey)) {
          continue;
        }

        try {
          hook.execute(context);
          executedHooks.add(hookKey);
          _updateHookStats('throw_${hook.name}');
        } catch (e) {
          // ThrowHook异常特殊处理，防止循环异常
          _handleHookException(
            'ThrowHook',
            hook.name,
            context.methodName,
            e,
            suppressLogging: true,
          );
        }
      }
    }
  }

  /// 执行环绕Hook
  ///
  /// [context] Hook上下文
  /// [proceed] 原始方法或下一个AroundHook的执行函数
  dynamic executeAround(HookContext context, Function proceed) {
    final executionId = _getExecutionId(context);
    final executedHooks = _executedHooks[executionId] ??= <String>{};

    // 获取所有允许的AroundHook，并过滤已执行的
    final allowedAroundHooks = _aroundHooks
        .where((hook) => context.isHookAllowed(hook.name))
        .where((hook) => !executedHooks.contains('around_${hook.name}'))
        .toList();

    if (allowedAroundHooks.isEmpty) {
      // 没有AroundHook，直接执行原方法
      return proceed();
    }

    // 构建AroundHook调用链
    Function currentProceed = proceed;
    for (int i = allowedAroundHooks.length - 1; i >= 0; i--) {
      final hook = allowedAroundHooks[i];
      final nextProceed = currentProceed;
      currentProceed = () {
        final hookKey = 'around_${hook.name}';

        // 防止重复执行
        if (executedHooks.contains(hookKey)) {
          return nextProceed();
        }

        try {
          final result = hook.execute(context, nextProceed);
          executedHooks.add(hookKey);
          _updateHookStats('around_${hook.name}');
          return result;
        } catch (e) {
          _handleHookException('AroundHook', hook.name, context.methodName, e);
          // Hook执行失败时记录错误但继续执行下一个
          return nextProceed();
        }
      };
    }

    return currentProceed();
  }

  /// 执行完整的AOP流程
  ///
  /// 执行顺序：around -> before -> 目标方法 -> after -> throw(异常处理)
  ///
  /// [target] 目标对象
  /// [methodName] 方法名
  /// [arguments] 方法参数
  /// [argumentTypes] 参数类型
  /// [returnType] 返回类型
  /// [allowedHooks] 允许的Hook名称列表
  /// [originalMethod] 原始方法执行函数
  dynamic executeAop({
    required Object target,
    required String methodName,
    required List<dynamic> arguments,
    required List<Type> argumentTypes,
    required Type returnType,
    List<String>? allowedHooks,
    required Function originalMethod,
  }) {
    final context = HookContext(
      target: target,
      methodName: methodName,
      arguments: arguments,
      argumentTypes: argumentTypes,
      returnType: returnType,
      allowedHooks: allowedHooks,
    );

    final executionId = _getExecutionId(context);
    final stopwatch = Stopwatch()..start();

    try {
      // 执行AroundHook和原方法
      final result = executeAround(context, () {
        // 执行BeforeHook
        executeBefore(context);

        // 执行原方法
        final methodResult = originalMethod();

        // 更新上下文结果
        context.result = methodResult;

        // 执行AfterHook
        executeAfter(context);

        return methodResult;
      });

      stopwatch.stop();
      return result;
    } catch (e) {
      stopwatch.stop();
      _frameworkExceptionCount++;

      try {
        // 更新上下文异常信息
        final exception = e is Exception ? e : Exception(e.toString());
        context.exception = exception;

        // 执行ThrowHook
        executeThrow(context);
      } catch (hookException) {
        // 防止ThrowHook异常影响原异常传播
        _handleFrameworkException(
          'ThrowHook执行异常',
          hookException,
          context.methodName,
        );
      }

      // 重新抛出异常
      rethrow;
    } finally {
      // 清理执行上下文缓存
      _cleanupExecutionContext(executionId);
    }
  }

  /// 获取所有BeforeHook的名称
  List<String> getBeforeHookNames() {
    return _beforeHooks.map((hook) => hook.name).toList();
  }

  /// 获取所有AfterHook的名称
  List<String> getAfterHookNames() {
    return _afterHooks.map((hook) => hook.name).toList();
  }

  /// 获取所有ThrowHook的名称
  List<String> getThrowHookNames() {
    return _throwHooks.map((hook) => hook.name).toList();
  }

  /// 获取所有AroundHook的名称
  List<String> getAroundHookNames() {
    return _aroundHooks.map((hook) => hook.name).toList();
  }

  /// 清除所有Hook（用于测试）
  void clearAllHooks() {
    _beforeHooks.clear();
    _afterHooks.clear();
    _throwHooks.clear();
    _aroundHooks.clear();
    _executedHooks.clear();
    _hookExecutionStats.clear();
    _frameworkExceptionCount = 0;
    _logger.i('清除所有Hook');
  }

  /// 生成执行上下文ID
  String _getExecutionId(HookContext context) {
    return '${context.target.runtimeType}_${context.methodName}_${DateTime.now().microsecondsSinceEpoch}';
  }

  /// 处理Hook执行异常
  void _handleHookException(
    String hookType,
    String hookName,
    String methodName,
    dynamic exception, {
    bool suppressLogging = false,
  }) {
    try {
      if (!suppressLogging) {
        _logger.e(
          'Hook执行异常',
          error: {
            'hookType': hookType,
            'hookName': hookName,
            'methodName': methodName,
            'exception': exception,
          },
          stackTrace: StackTrace.current,
        );
      }

      // 更新错误统计
      final errorKey = '${hookType.toLowerCase()}_${hookName}_error';
      _hookExecutionStats[errorKey] = (_hookExecutionStats[errorKey] ?? 0) + 1;
    } catch (loggingException) {
      // 日志记录失败时的备用处理
      _logger.w('AOP框架日志异常: $loggingException');
    }
  }

  /// 处理框架级异常
  void _handleFrameworkException(
    String operation,
    dynamic exception,
    String methodName,
  ) {
    try {
      _logger.e(
        'AOP框架异常',
        error: {
          'operation': operation,
          'exception': exception,
          'methodName': methodName,
          'frameworkExceptionCount': _frameworkExceptionCount + 1,
        },
        stackTrace: StackTrace.current,
      );
      _frameworkExceptionCount++;

      // 如果框架异常过多，记录警告
      if (_frameworkExceptionCount > 10) {
        _logger.w('AOP框架异常过多($_frameworkExceptionCount次)，建议检查Hook实现');
      }
    } catch (e) {
      // 最后的备用处理
      _logger.f('AOP框架关键异常: $e');
    }
  }

  /// 更新Hook执行统计
  void _updateHookStats(String hookKey) {
    _hookExecutionStats[hookKey] = (_hookExecutionStats[hookKey] ?? 0) + 1;
  }

  /// 清理执行上下文缓存
  void _cleanupExecutionContext(String executionId) {
    _executedHooks.remove(executionId);

    // 如果缓存过多，清理旧的上下文
    if (_executedHooks.length > 100) {
      final keysToRemove = _executedHooks.keys.take(50).toList();
      for (final key in keysToRemove) {
        _executedHooks.remove(key);
      }
    }
  }

  /// 获取Hook执行统计
  Map<String, int> getHookExecutionStats() {
    return Map.from(_hookExecutionStats);
  }

  /// 获取框架异常计数
  int getFrameworkExceptionCount() {
    return _frameworkExceptionCount;
  }

  /// 重置统计信息
  void resetStats() {
    _hookExecutionStats.clear();
    _frameworkExceptionCount = 0;
  }
}
