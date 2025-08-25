# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-25

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