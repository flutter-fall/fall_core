import 'hook_context.dart';

/// 环绕Hook接口，可以完全控制目标方法的执行
/// 
/// 使用示例：
/// ```dart
/// class TimingAroundHook implements AroundHook {
///   @override
///   String get name => 'timing';
///   
///   @override
///   dynamic execute(HookContext context, Function proceed) {
///     final stopwatch = Stopwatch()..start();
///     try {
///       final result = proceed();
///       stopwatch.stop();
///       print('Method ${context.methodName} took ${stopwatch.elapsedMilliseconds}ms');
///       return result;
///     } catch (e) {
///       stopwatch.stop();
///       print('Method ${context.methodName} failed after ${stopwatch.elapsedMilliseconds}ms');
///       rethrow;
///     }
///   }
/// }
/// ```
abstract class AroundHook {
  /// Hook名称，用于识别和过滤
  String get name;
  
  /// 执行环绕逻辑
  /// 
  /// [context] Hook执行上下文，包含方法调用信息
  /// [proceed] 继续执行的函数，调用它将执行原方法或下一个AroundHook
  /// 
  /// 返回值：方法的执行结果，可以是原方法的返回值或修改后的值
  dynamic execute(HookContext context, Function proceed);
}