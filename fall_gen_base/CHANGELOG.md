# Changelog

All notable changes to the fall_gen_base package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.9] - 2025-10-08

### Changed
- 🔧 **版本更新**: 统一更新到 0.0.9 版本

### ✨ Highlights
- 🔧 **无破坏性变更**: 所有现有 API 和功能保持不变
- 📦 **完全兼容**: 与框架其他模块协同升级
- 🎆 **模块成熟**: 作为成熟的基础模块，为其他生成器提供稳定支持

## [0.0.8] - 2025-10-07

### 🚀 Initial Release
- **全新模块**: Fall Gen Base - 代码生成器基础模块首次发布
- **公共逻辑抽取**: 从 fall_core_gen 模块抽取公共代码生成逻辑

### 🏗️ Core Features
- **BaseAutoScan**: 基础自动扫描生成器抽象类
- **GenUtil**: 代码生成通用工具类
  - 支持相对路径计算和URI方案处理
  - 提供跨包导入路径处理逻辑
  - 增强多级目录的路径解析能力

### 📦 Architecture Benefits
- **模块化设计**: 为代码生成器提供统一的基础设施
- **代码复用**: 避免重复实现，提升维护效率
- **扩展性**: 为future代码生成功能提供扩展基础

### 🔧 Technical Features
- **零外部依赖**: 除Flutter SDK外保持轻量化设计
- **类型安全**: 完整的静态类型检查支持
- **测试覆盖**: 提供完善的单元测试套件

### ✨ Highlights
- 🎯 **专业化**: 专注于代码生成器公共逻辑
- 🚀 **高性能**: 优化的路径处理和URI解析
- 🔧 **工具导向**: 为其他生成器模块提供基础工具

### 📝 Dependencies
- `source_gen`: ^4.0.1 - 源码生成框架
- `code_builder`: ^4.10.1 - 代码构建工具
- `analyzer`: ^8.1.1 - 静态分析支持
- `build`: ^4.0.0 - 构建系统支持
- `glob`: ^2.1.0 - 文件模式匹配
- `path`: ^1.9.1 - 路径处理工具
- `logger`: ^2.6.1 - 日志支持

### 🎯 Use Cases
- 作为 fall_core_gen 的基础依赖
- 为其他代码生成器项目提供通用工具
- 支持复杂项目结构的代码生成需求

### Notes
- 这是一个全新的模块，从 fall_core_gen 中重构而来
- 专注于提供代码生成器的公共基础设施
- 建议与 fall_core_base 0.0.8+ 和其他 Fall Core 模块配合使用