# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2025-08-31

### Changed
- **架构重构**: 将代码生成器功能分离到独立的 `fall_gen` 项目
- **核心简化**: 保留仅最基本的 AOP 和依赖注入功能
- **项目结构**: 示例项目将单独创建，不再包含在此包中

### Removed
- **代码生成器**: 移除 `build_runner` 相关的代码生成功能
- **AutoScan 工具**: 移除自动扫描和注册功能
- **依赖清理**: 移除 `analyzer`、`dart_style` 等代码生成相关依赖

### Fixed
- **文档更新**: 更新 README 和相关文档，移除代码生成器相关内容
- **示例代码**: 更新示例代码，使用手动注册方式
- **错误提示**: 更新依赖注入失败提示，移除 AutoScan 引用

### Technical Details
- **轻量化**: 核心包更加轻量，仅包含必要的运行时功能
- **可维护性**: 通过分离代码生成器，提高项目的可维护性
- **灵活性**: 用户可以选择仅使用核心功能或结合 `fall_gen` 使用完整功能

### Migration Guide
如果您从 0.0.1 升级到 0.0.2：

1. **移除 build_runner 依赖**：从 `pubspec.yaml` 中移除 `build_runner`
2. **手动注册服务**：替换 `AutoScan.registerServices()` 为手动注册
3. **使用 fall_gen**：如需代码生成功能，请添加 `fall_gen` 作为 `dev_dependencies`

## [0.0.1] - 2025-08-25

### Added
- Initial release of Fall Core framework
- **Dependency Injection System**
  - `@Service` annotation for service registration
  - `@Auto` annotation for automatic dependency injection
  - Support for named services with `name` parameter
  - Lazy loading and singleton lifecycle management
  - Integration with GetX for dependency lookup
- **Aspect-Oriented Programming (AOP)**
  - `@Aop` annotation for method interception
  - `@NoAop` annotation to exclude methods from AOP
  - Hook system with BeforeHook, AfterHook, AroundHook, and ThrowHook
  - Automatic proxy class generation for AOP functionality
- **Code Generation**
  - Compile-time code generation using `build_runner`
  - `service_generator` for automatic service registration
  - `aop_generator` for AOP proxy class generation
  - Type-safe code generation avoiding runtime reflection
- **Core Components**
  - `AutoScan` utility for automatic service registration and injection
  - `AopService` for managing hooks and AOP functionality
  - `InjectUtil` for dependency injection utilities
  - `LoggerFactory` for business and system logging
- **Annotations System**
  - Complete annotation system for DI and AOP
  - Support for custom configuration parameters
  - Build-time validation and error reporting
- **Example Application**
  - Comprehensive example demonstrating all features
  - Sample services with AOP integration
  - Test cases for various scenarios

### Features
- **Enterprise-Grade Architecture**: Inspired by Spring Framework
- **Compile-Time Safety**: No runtime reflection, all code generated at build time
- **Performance Optimized**: Minimal runtime overhead with compile-time optimization
- **Developer Friendly**: Annotation-driven development with clear APIs
- **Modular Design**: Clean separation of concerns with AOP support
- **Comprehensive Logging**: Built-in logging system with hook integration

### Technical Details
- Minimum Dart SDK: 3.8.1
- Flutter support with GetX integration
- Build runner integration for code generation
- Compatible with modern Flutter development practices

### Documentation
- Complete API documentation
- Quick start guide
- Advanced usage examples
- Best practices and guidelines

## [Unreleased]

### Planned Features
- Performance monitoring hooks
- Enhanced error handling and validation
- Additional lifecycle management options
- Plugin system for custom generators
- Integration with other state management solutions

---

**Note**: This is the first stable release of Fall Core. We follow semantic versioning, so any breaking changes will be clearly documented and versioned appropriately.