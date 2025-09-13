# Changelog

All notable changes to the fall_core_main package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.3] - 2025-09-13

### Version Sync
- 🔄 **版本同步升级**: 与框架其他模块保持版本一致性
- 📦 **无运行时变更**: 本版本仅进行版本号同步，AOP和DI功能保持稳定
- 🔗 **模块协调**: 确保与 fall_core_base 和 fall_core_gen 的最佳兼容性


## [0.0.2] - 2025-09-13

### Changed
- 修改main的导出类

## [0.0.1] - 2025-09-12

### Added
- 初始版本发布
- AOP运行时系统：
  - `AopService` - AOP执行引擎
  - Hook接口体系：
    - `BeforeHook` - 方法执行前切面
    - `AfterHook` - 方法执行后切面
    - `AroundHook` - 环绕切面
    - `ThrowHook` - 异常处理切面
  - `HookContext` - Hook执行上下文
  - `LogHooks` - 内置日志切面
- 依赖注入工具：
  - `InjectUtil` - 依赖注入工具类
- 服务管理：
  - 服务注册和查找机制
  - 与GetX容器深度集成

### Features
- **运行时AOP支持**：提供完整的面向切面编程运行时
- **Hook过滤机制**：支持基于白名单的Hook过滤
- **上下文传递**：完整的方法调用上下文支持
- **异常处理**：专用的异常切面处理机制
- **日志集成**：内置日志切面支持
- **GetX集成**：深度集成GetX依赖注入容器

### Dependencies
- `fall_core_base`: 核心注解和工具依赖
- `get`: GetX状态管理和依赖注入
- `logger`: 日志支持

### Architecture
- 作为框架的运行时核心，提供AOP和DI的执行环境
- 与代码生成器协作，执行生成的代理代码
- 提供完整的企业级DI和AOP功能

### Runtime Integration
- **服务生命周期管理**：支持单例和懒加载模式
- **属性注入**：自动注入标记 `@Auto` 的属性
- **方法拦截**：通过生成的代理类实现方法拦截
- **Hook链执行**：按配置顺序执行Hook链

### Notes
- 此模块提供框架的运行时功能
- 需要配合代码生成器使用以获得完整功能
- 为业务代码提供企业级的DI和AOP支持