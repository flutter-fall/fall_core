# Changelog

All notable changes to the fall_core_main package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.4] - 2025-10-04

### 🔄 Version Sync
- **版本同步升级**: 与框架其他模块保持版本一致性
- **依赖更新**: 升级至 fall_core_base ^0.0.4

### 🔗 Enhanced Integration
- **模块协同**: 与新的 fall_core_gen 代码生成器架构完美兼容
  - 支持新的 `ServiceAutoScan` 生成器
  - 保持与增强的 `@AutoScan` 注解的协同工作
  - 支持更精确的注解过滤机制

### 🛡️ Stability Improvements
- **运行时稳定性**: 所有 AOP 和 DI 功能保持稳定运行
- **向后兼容**: 现有业务代码无需任何修改
- **性能保持**: Hook 执行效率和内存占用保持优化状态

### 🏗️ Architecture Alignment
- **模块边界**: 与新的代码生成器架构对齐，保持清晰的模块边界
- **服务生命周期**: 支持更精确的服务管理和自动扫描
- **Hook 系统**: 与更新的注解系统协同，提供更精准的 AOP 控制

### 📊 Quality Assurance
- **无功能变更**: 本版本不包含任何新功能或破坏性变更
- **稳定性保证**: 所有现有 API 和行为保持不变
- **性能优化**: 受益于依赖模块的优化，整体性能得到提升

### 🛠️ Technical Details
- **依赖版本**: 无三方依赖版本变更，仅升级 fall_core_base
- **编译兼容**: 与新的代码生成器输出完全兼容
- **运行时检查**: 所有运行时检查和验证机制保持不变

### 🎆 Benefits
- 🔄 **版本一致性**: 与整个 Fall Core 框架保持同步
- 🔗 **更好的集成**: 与增强的代码生成器更好协同
- 🛡️ **稳定可靠**: 零破坏性变更，平滑升级

### 📝 Usage Notes
- ✅ **平滑升级**: 直接升级包版本即可，无需代码修改
- ✅ **最佳实践**: 建议与 fall_core_base 0.0.4+ 和 fall_core_gen 0.0.4+ 一同使用
- ✅ **性能优化**: 全框架升级后可获得更好的整体性能

### Notes
- 本版本为纯版本同步升级，不包含任何功能变更
- 所有运行时组件保持稳定，与新的框架架构完美对齐
- 为 Fall Core 框架的后续版本升级奠定均衡的技术基础

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