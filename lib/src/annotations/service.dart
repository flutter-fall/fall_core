/// Service注解，用于标记需要自动注册到GetX的服务类
/// 
/// 使用示例：
/// ```dart
/// @Service()
/// class UserService {
///   void login() {
///     // 业务逻辑
///   }
/// }
/// ```
class Service {
  /// 服务名称，可选参数
  final String? name;
  
  /// 是否为单例，默认为true
  final bool singleton;
  
  /// 是否懒加载，默认为true
  final bool lazy;
  
  const Service({
    this.name,
    this.singleton = true,
    this.lazy = true,
  });
}