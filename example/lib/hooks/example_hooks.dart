import 'package:fall_core/fall_core.dart';
import 'package:logger/logger.dart';

/// 缓存AroundHook示例
class CacheAroundHook implements AroundHook {
  static final Logger _logger = LoggerFactory.getBusinessLogger();

  @override
  String get name => 'cache';

  static final Map<String, dynamic> _cache = {};

  @override
  dynamic execute(HookContext context, Function proceed) {
    // 生成缓存key
    final cacheKey =
        '${context.target.runtimeType}.${context.methodName}(${context.arguments.join(',')})';

    // 检查缓存
    if (_cache.containsKey(cacheKey)) {
      _logger.d('缓存命中', error: {'cacheKey': cacheKey});
      return _cache[cacheKey];
    }

    // 执行原方法并缓存结果
    final result = proceed();
    _cache[cacheKey] = result;

    _logger.d('结果已缓存', error: {'cacheKey': cacheKey});

    return result;
  }
}

/// 参数验证BeforeHook示例
class ValidationBeforeHook implements BeforeHook {
  static final Logger _logger = LoggerFactory.getBusinessLogger();

  @override
  String get name => 'validation';

  @override
  void execute(HookContext context) {
    // 简单的参数验证示例
    if (context.methodName == 'login') {
      final username = context.arguments.isNotEmpty
          ? context.arguments[0]
          : null;
      final password = context.arguments.length > 1
          ? context.arguments[1]
          : null;

      if (username == null || username.toString().isEmpty) {
        throw ArgumentError('用户名不能为空');
      }

      if (password == null || password.toString().isEmpty) {
        throw ArgumentError('密码不能为空');
      }

      _logger.d('参数验证通过', error: {'method': context.methodName});
    }
  }
}
