/// Hook执行上下文，包含方法调用的所有信息
class HookContext {
  /// 目标对象实例
  final Object target;

  /// 方法名称
  final String methodName;

  /// 方法参数列表
  final List<dynamic> arguments;

  /// 方法参数类型列表
  final List<Type> argumentTypes;

  /// 方法返回类型
  final Type returnType;

  /// 允许执行的Hook名称列表，为空表示允许所有Hook
  final List<String>? allowedHooks;

  /// 方法执行结果（在after和around hook中可用）
  dynamic result;

  /// 方法执行异常（在throw hook中可用）
  Exception? exception;

  /// 额外的上下文数据，可用于Hook之间传递数据
  final Map<String, dynamic> data = {};

  HookContext({
    required this.target,
    required this.methodName,
    required this.arguments,
    required this.argumentTypes,
    required this.returnType,
    this.allowedHooks,
    this.result,
    this.exception,
  });

  /// 检查是否允许执行指定名称的Hook
  bool isHookAllowed(String hookName) {
    if (allowedHooks == null || allowedHooks!.isEmpty) {
      return true; // 没有限制，允许所有Hook
    }
    return allowedHooks!.contains(hookName);
  }

  /// 复制上下文，用于传递给不同的Hook
  HookContext copyWith({dynamic result, Exception? exception}) {
    return HookContext(
      target: target,
      methodName: methodName,
      arguments: arguments,
      argumentTypes: argumentTypes,
      returnType: returnType,
      allowedHooks: allowedHooks,
      result: result ?? this.result,
      exception: exception ?? this.exception,
    )..data.addAll(data);
  }

  @override
  String toString() {
    return 'HookContext('
        'target: $target, '
        'methodName: $methodName, '
        'arguments: $arguments, '
        'returnType: $returnType, '
        'allowedHooks: $allowedHooks'
        ')';
  }
}
