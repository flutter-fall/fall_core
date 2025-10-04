# Changelog

All notable changes to the fall_core_gen package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.4] - 2025-10-04

### 🚀 Major Refactoring
- **代码生成器重构**: `ServiceGenerator` → `ServiceAutoScan`
  - 更明确的类名，更好地反映其自动扫描功能
  - 更新所有相关导出和构建器配置
  - 保持API兼容性，仅修改内部实现

### 🔧 Enhanced Features
- **GenUtil 工具增强**: 新增 `asset` URI 方案支持
  - 支持 `asset:` 协议的相对路径计算
  - 优化跨包导入路径处理逻辑
  - 增强多级目录的路径解析能力
  - 为复杂项目结构提供更稳定的路径生成

### 🏗️ Architecture Improvements
- **模块化设计优化**: 完善代码组织结构
- **命名规范**: 提升代码可读性和维护性
- **模块边界明确化**: 更清晰的功能分离和责任划分

### 🧩 Testing Enhancements
- **单元测试增强**: 新增 `asset` URI 处理的测试用例
  - 覆盖相同包内的路径计算场景
  - 覆盖不同包间的 URI 处理场景
  - 覆盖嵌套目录的复杂路径场景
- **Mock 对象完善**: 修复 `MockElement` 的 `metadata` 属性缺失问题

### 🔄 Breaking Changes
⚠️ **内部重构**: 如果你的代码直接引用了 `ServiceGenerator`，需要更新为 `ServiceAutoScan`

### 📦 Dependencies Update
- **依赖版本同步**: 升级至 fall_core_base ^0.0.4
- **构建工具链保持**: 所有构建相关依赖版本稳定

### 📝 Migration Guide
1. **对于一般用户**: 无需任何修改，直接升级即可
2. **对于高级用户**: 如果直接使用了 `ServiceGenerator`，请更新为 `ServiceAutoScan`
3. **清理重建**: `flutter packages pub run build_runner clean && flutter packages pub run build_runner build`

### ✨ Highlights
- 🎨 **更清晰的代码结构**: 类名和模块划分更加直观
- 🚀 **更强大的路径处理**: 支持更多类型的 URI 方案
- 🛡️ **更完善的测试**: 更全面的单元测试覆盖

### Notes
- 本版本主要面向代码质量和可维护性提升
- 所有核心功能保持稳定，无功能性变更
- 建议与 fall_core_base 0.0.4+ 和 fall_core_main 0.0.4+ 配合使用

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