import 'hook_context.dart';

/// 后置Hook接口，在目标方法执行后调用
/// 
/// 使用示例：
/// ```dart
/// class LoggingAfterHook implements AfterHook {
///   @override
///   String get name => 'logging';
///   
///   @override
///   void execute(HookContext context) {
///     print('After method: ${context.methodName}, result: ${context.result}');
///   }
/// }
/// ```
abstract class AfterHook {
  /// Hook名称，用于识别和过滤
  String get name;
  
  /// 执行后置逻辑
  /// 
  /// [context] Hook执行上下文，包含方法调用信息和执行结果
  /// context.result 包含方法的返回值
  void execute(HookContext context);
}