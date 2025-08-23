import 'hook_context.dart';

/// 前置Hook接口，在目标方法执行前调用
/// 
/// 使用示例：
/// ```dart
/// class LoggingBeforeHook implements BeforeHook {
///   @override
///   String get name => 'logging';
///   
///   @override
///   void execute(HookContext context) {
///     print('Before method: ${context.methodName}');
///   }
/// }
/// ```
abstract class BeforeHook {
  /// Hook名称，用于识别和过滤
  String get name;
  
  /// 执行前置逻辑
  /// 
  /// [context] Hook执行上下文，包含方法调用信息
  void execute(HookContext context);
}