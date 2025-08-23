/// Fall Core 框架Hook接口定义
/// 
/// 提供了AOP相关的Hook接口：
/// - [HookContext] Hook执行上下文
/// - [BeforeHook] 前置Hook接口
/// - [AfterHook] 后置Hook接口
/// - [ThrowHook] 异常Hook接口
/// - [AroundHook] 环绕Hook接口
/// - 标准LogHooks实现
library hooks;

export 'hook_context.dart';
export 'before_hook.dart';
export 'after_hook.dart';
export 'throw_hook.dart';
export 'around_hook.dart';
export 'log_hooks.dart';