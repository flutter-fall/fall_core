/// AOP注解，用于标记需要AOP增强的类
/// 
/// 使用示例：
/// ```dart
/// @Aop()
/// class UserService {
///   void login() {
///     // 业务逻辑
///   }
/// }
/// ```
class Aop {
  /// AOP名称，可选参数
  final String? name;
  
  /// 允许执行的Hook名称列表，为空表示允许所有Hook
  final List<String>? allowedHooks;
  
  const Aop({
    this.name,
    this.allowedHooks,
  });
}