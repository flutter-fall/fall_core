/// Fall Core 框架注解定义
/// 
/// 提供了AOP和依赖注入相关的注解：
/// - [@Aop] 标记需要AOP增强的类
/// - [@Service] 标记需要自动注册的服务类
/// - [@Auto] 标记需要自动注入的属性
/// - [@NoAop] 标记不需要AOP增强的方法
library annotations;

export 'aop.dart';
export 'service.dart';
export 'auto.dart';
export 'no_aop.dart';