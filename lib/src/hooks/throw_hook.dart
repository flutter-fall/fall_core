import 'hook_context.dart';

/// 异常Hook接口，在目标方法抛出异常时调用
/// 
/// 使用示例：
/// ```dart
/// class ErrorHandlingThrowHook implements ThrowHook {
///   @override
///   String get name => 'error-handling';
///   
///   @override
///   void execute(HookContext context) {
///     print('Exception in method: ${context.methodName}, error: ${context.exception}');
///   }
/// }
/// ```
abstract class ThrowHook {
  /// Hook名称，用于识别和过滤
  String get name;
  
  /// 执行异常处理逻辑
  /// 
  /// [context] Hook执行上下文，包含方法调用信息和异常信息
  /// context.exception 包含抛出的异常
  void execute(HookContext context);
}