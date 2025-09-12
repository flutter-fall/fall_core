# Changelog

All notable changes to the fall_core_base package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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