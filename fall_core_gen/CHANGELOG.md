# Changelog

All notable changes to the fall_core_gen package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.3] - 2025-09-13

### Updated
- **🚀 构建依赖升级**: 升级核心代码生成依赖包以提升性能和稳定性
  - `source_gen`: 升级至 ^4.0.1 - 支持最新代码生成特性
  - `analyzer`: 升级至 ^8.1.1 - 增强静态分析能力
  - `build`: 升级至 ^4.0.0 - 优化构建性能
  - `build_config`: 升级至 ^1.2.0 - 改进配置管理

### Enhanced
- **⚡ 代码生成性能**: 受益于依赖升级，代码生成速度和准确性显著提升
- **🔍 类型检查增强**: 更严格的类型安全检查和更好的错误提示
- **📊 构建优化**: 减少构建时间，提升开发体验

### Testing
- **🧪 测试框架升级**: 
  - `test`: 升级至 ^1.26.3 - 支持最新测试特性
  - `build_test`: 升级至 ^3.3.2 - 改进构建测试能力
  - `mockito`: 升级至 ^5.5.1 - 增强模拟测试功能

### Breaking Changes
- ⚠️ **依赖要求**: 需要更新开发环境以支持新的依赖版本
- 🔄 **重新构建**: 升级后需要清理并重新运行代码生成

### Migration Guide
- 清理旧的生成文件: `flutter packages pub run build_runner clean`
- 获取新依赖: `flutter pub get`
- 重新生成代码: `flutter packages pub run build_runner build`

### Compatibility
- ✅ 与 fall_core_base ^0.0.4 完全兼容
- ✅ 支持 Dart 3.8.1+ 和 Flutter 3.0+
- ✅ 向后兼容所有现有注解和生成逻辑

### Notes
- 本版本着重提升开发工具链的现代化程度
- 建议与 fall_core_main 0.0.4+ 配合使用以获得最佳体验
- 所有核心功能保持稳定，无破坏性变更

## [0.0.2] - 2025-09-13

### Changed
- 修改main的导出类，本包同步升级版本

## [0.0.1] - 2025-09-12

### Added
- 初始版本发布
- 核心代码生成器：
  - `ServiceGenerator` - 服务注册代码生成器
  - `AopGenerator` - AOP代理类生成器
- 代码生成工具：
  - `GenUtil` - 代码生成通用工具类
  - 构建器配置 (`builders.dart`)
- 构建配置：
  - `build.yaml` - 构建规则配置
  - 支持 `build_runner` 集成

### Features
- **编译时代码生成**：在编译时自动扫描并生成服务注册代码
- **AOP代理生成**：为标记 `@Aop` 的类生成代理类
- **Analyzer 7.5.5 兼容**：更新至最新 analyzer API
- **自动扫描机制**：支持 glob 模式的文件扫描
- **零运行时开销**：所有依赖注入代码在编译时生成

### Dependencies
- `fall_core_base`: 核心注解和工具依赖
- `build`: 构建系统支持
- `source_gen`: 源码生成框架
- `code_builder`: 代码构建工具
- `analyzer`: 静态分析支持
- `glob`: 文件模式匹配
- `path`: 路径处理工具
- `logger`: 日志支持

### Architecture
- 作为代码生成专用模块，分离构建时逻辑
- 与核心注解模块解耦，支持独立发布
- 提供完整的构建工具链支持

### Notes
- 此模块专注于编译时代码生成
- 需要配合 `build_runner` 使用
- 为项目提供零运行时反射的依赖注入实现