/// Auto注解，用于标记需要自动注入的属性
/// 
/// 使用示例：
/// ```dart
/// class UserController {
///   @Auto()
///   late UserService userService;
///   
///   @Auto(lazy: false)
///   late LogService logService;
/// }
/// ```
class Auto {
  /// 注入的服务名称，可选参数
  final String? name;
  
  /// 是否懒加载，默认为true
  final bool lazy;
  
  const Auto({
    this.name,
    this.lazy = true,
  });
}