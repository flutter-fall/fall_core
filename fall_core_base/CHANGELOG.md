# Changelog

All notable changes to the fall_core_base package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.6] - 2025-10-05

### 🔄 Version Sync
- **版本同步升级**: 与框架其他模块保持版本一致性
- **构建优化**: 配合 fall_core_gen PartBuilder 重构，确保更好的兼容性

### ✨ Highlights
- 🔧 **无破坏性变更**: 所有现有 API 和功能保持不变
- 📦 **完全兼容**: 与 fall_core_gen 0.0.6+ 和 fall_core_main 模块协同升级
- 🚀 **构建稳定性**: 受益于代码生成器架构优化

## [0.0.5] - 2025-10-04

### 🔄 Version Sync
- **版本同步升级**: 与框架其他模块保持版本一致性
- **构建优化**: 适配 fall_core_gen 构建路径修复，提升整体框架稳定性

### ✨ Highlights
- 🔧 **无破坏性变更**: 所有现有 API 和功能保持不变
- 📦 **完全兼容**: 与 fall_core_gen 0.0.5+ 和 fall_core_main 模块协同升级

## [0.0.4] - 2025-10-04

### Enhanced
- 🔧 **@AutoScan 注解增强**: 新增 `annotations` 参数，支持指定要扫描的注解类型
  - 默认扫描 `['Service']` 注解
  - 支持自定义扫描目标注解，提升代码生成器的灵活性
  - 与现有 `include`/`exclude` 参数协同工作，实现精准控制

### Improved
- 📊 **注解系统优化**: 完善自动扫描配置的可配置性
- 🏗️ **架构改进**: 为代码生成器提供更精确的注解过滤机制

### Compatibility
- ✅ 完全向后兼容，现有代码无需修改
- ✅ 新增参数为可选参数，不影响现有使用方式
- ✅ 与 fall_core_gen 和 fall_core_main 模块协同升级

### Notes
- 本版本主要面向代码生成器功能增强
- 建议配合 fall_core_gen 0.0.4+ 使用以获得最佳体验
- 核心注解功能保持稳定，无破坏性变更

## [0.0.3] - 2025-09-13

### Version Sync
- 🔄 **版本同步升级**: 与其他模块保持版本一致性

## [0.0.2] - 2025-09-13

### Changed
- 修改main的导出类，本包同步升级版本


## [0.0.1] - 2025-09-12

### Added
- 初始版本发布
- 核心注解系统：
  - `@Service` - 标记可注入服务的注解
  - `@Auto` - 自动依赖注入注解
  - `@Aop` - AOP切面注解
  - `@NoAop` - 排除AOP的注解
  - `@AutoScan` - 自动扫描配置注解
- 基础工具类：
  - `LoggerFactory` - 日志工厂类
  - 核心工具函数

### Architecture
- 实现零外部依赖设计（除Flutter SDK外）
- 作为框架的核心基础模块，提供注解和基础工具
- 支持其他模块的构建和运行时依赖

### Dependencies
- `flutter`: Flutter SDK 支持
- `meta`: 元数据注解支持

### Notes
- 此模块专注于提供核心注解和基础工具
- 遵循轻量化设计原则，保持最小依赖
- 为代码生成器和运行时模块提供基础支持