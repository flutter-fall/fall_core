# Changelog

All notable changes to the fall_core_gen package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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