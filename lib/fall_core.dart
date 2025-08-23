/// Fall Core - Flutter AOP and Dependency Injection Framework
///
/// Fall Core 是一个 Flutter 框架，提供了完整的 AOP（面向切面编程）和依赖注入解决方案，
/// 灵感来自于 Spring 框架，基于 GetX 进行了进一步封装。
///
/// ## 主要功能
///
/// ### 注解系统
/// - [@Aop] 标记需要AOP增强的类
/// - [@Service] 标记需要自动注册的服务类
/// - [@Auto] 标记需要自动注入的属性
/// - [@NoAop] 标记不需要AOP增强的方法
///
/// ### Hook系统
/// - [BeforeHook] 前置Hook接口
/// - [AfterHook] 后置Hook接口
/// - [ThrowHook] 异常Hook接口
/// - [AroundHook] 环绕Hook接口
///
/// ### 核心服务
/// - [AopService] AOP服务
///
/// ## 使用示例
///
/// ```dart
/// // 1. 定义带AOP的服务类
/// @Aop(allowedHooks: ['logging', 'timing'])
/// @Service()
/// class UserService {
///   static final Logger _logger = LoggerFactory.getBusinessLogger();
///
///   Future<bool> login(String username, String password) async {
///     // 业务逻辑，会自动被AOP增强
///     return username == 'admin' && password == 'password';
///   }
///
///   @NoAop()
///   String _internalMethod() {
///     // 不会被AOP增强的方法
///     return 'internal';
///   }
/// }
///
/// // 2. 注册服务和Hook
/// void main() {
///   // 手动注册（未来会由代码生成器自动完成）
///   Get.lazyPut<AopService>(() => AopService());
///   Get.lazyPut<UserService>(() => UserService());
///
///   // 注册Hook
///   final aopService = Get.find<AopService>();
///   aopService.addBeforeHook(LogBeforeHook());
///   aopService.addAroundHook(TimingAroundHook());
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## AOP执行顺序
/// around -> before -> 目标方法 -> after -> throw(异常处理)
///
/// ## 技术特性
/// - ✅ 完整的注解系统
/// - ✅ 四种Hook类型支持
/// - ✅ Hook名称过滤
/// - ✅ 异常处理和日志记录
/// - ✅ 懒加载依赖注入
/// - ✅ 完整的示例代码
/// - ⚠️ 代码生成器（需要修复analyzer API问题）
///
library fall_core;

// 核心注解
export 'src/annotations/annotations.dart';

// Hook接口
export 'src/hooks/hooks.dart';

// 核心服务
export 'src/services/services.dart';

// 工具类
export 'src/utils/utils.dart';

// 代码生成器（暂时有问题）
// export 'src/generators/generators.dart';
