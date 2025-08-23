/// NoAop注解，用于标记不需要AOP增强的方法
/// 
/// 使用示例：
/// ```dart
/// @Aop()
/// class UserService {
///   void login() {
///     // 这个方法会被AOP增强
///   }
///   
///   @NoAop()
///   void internalMethod() {
///     // 这个方法不会被AOP增强
///   }
/// }
/// ```
class NoAop {
  /// 可选的说明文字
  final String? reason;
  
  const NoAop({this.reason});
}