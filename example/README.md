# Fall Core Example

🚀 **Fall Core 框架完整功能演示项目**

这是一个全面展示 Fall Core 框架功能的示例应用程序。Fall Core 是 Flutter 生态中的 "Spring Framework"，提供企业级的 AOP 和依赖注入解决方案。

## 🎯 演示功能

### 📦 依赖注入 (Dependency Injection)
- ✅ **自动服务发现**: 通过 `@Service` 注解自动注册
- ✅ **命名服务注入**: 支持通过名称区分同类型的多个实例
- ✅ **生命周期管理**: 支持单例模式和懒加载
- ✅ **类型安全注入**: 编译时类型检查，避免运行时错误

### 🔄 面向切面编程 (AOP)
- ✅ **Before Hook**: 方法执行前的拦截处理
- ✅ **After Hook**: 方法执行后的拦截处理
- ✅ **Throw Hook**: 统一异常处理和错误管理
- ✅ **Hook 过滤**: 按名称过滤特定的 Hook

### 🤖 自动代码生成
- ✅ **服务自动扫描**: 扫描 `@Service` 并生成注册代码
- ✅ **AOP 代理生成**: 为 `@Aop` 类生成增强代理类
- ✅ **依赖注入模板**: 自动生成依赖注入样板代码

## 📁 项目结构

```
example/
├── lib/
│   ├── services/                    # 业务服务层
│   │   ├── user_service.dart         # 用户服务 (@Aop + @Service)
│   │   ├── user_service.g.dart       # 自动生成的 AOP 代理类
│   │   ├── product_service.dart      # 商品服务 (@Service)
│   │   └── test_service.dart         # 测试服务 (命名注入)
│   ├── hooks/
│   │   └── example_hooks.dart        # AOP Hook 示例
│   ├── init/
│   │   └── auto_scan.g.dart          # 自动生成的服务注册
│   ├── main.dart                    # 应用入口 (使用 AutoScan)
│   └── examples.dart                # 导出文件
├── pubspec.yaml                     # 项目依赖配置
├── build.yaml                       # 代码生成配置
├── analysis_options.yaml            # 代码分析规则
├── .gitignore                       # Git 忽略文件
├── Makefile                         # 开发命令快捷方式
└── README.md                        # 项目说明文档
```

## 🚀 快速开始

### 1. 安装依赖

```bash
cd example
flutter pub get
```

### 2. 代码生成

```bash
# 运行代码生成器
cd example ; dart run build_runner build --delete-conflicting-outputs

# 监视模式 (开发时推荐)
cd example ; dart run build_runner watch --delete-conflicting-outputs
```

### 3. 运行示例

```bash
# Windows 桌面应用
flutter run -d windows

# 其他平台
flutter run
```

### 4. 使用 Makefile 快捷命令

```bash
# 获取依赖
make get

# 代码生成
make build

# 监视模式
make watch

# 运行应用
make run

# 全面检查
make check
```

## 使用示例

### 定义服务

```dart
@Service()
class UserService {
  @AOP()
  Future<bool> login(String username, String password) async {
    // 业务逻辑
  }
  
  @AOP()
  String getUserInfo(String userId) {
    // 业务逻辑
  }
}
```

### 使用依赖注入

```dart
class MyController {
  // 自动注入
  final UserService userService = Get.find<UserService>();
  
  void someMethod() {
    userService.login('admin', 'password');
  }
}
```

### 定义AOP钩子

```dart
class LogBeforeHook extends BeforeHook {
  @override
  void onBefore(HookContext context) {
    print('方法 ${context.methodName} 开始执行');
  }
}
```

## 测试功能

应用包含以下测试按钮：

1. **测试用户服务** - 演示用户登录、获取信息等功能
2. **测试商品服务** - 演示商品查询、库存检查等功能  
3. **测试错误处理** - 演示异常拦截和处理
4. **测试参数验证** - 演示方法参数验证
5. **测试命名注入** - 演示通过名称进行依赖注入

## 🤖 代码生成文件

运行 `dart run build_runner build` 后会生成以下文件：

### AOP 代理类
- `lib/services/user_service.g.dart` - UserService 的 AOP 增强代理类
  - 包含 `UserServiceAop` 类
  - 自动拦截所有公共方法
  - 支持 Hook 过滤 (`logging`, `timing`)

### 服务自动注册
- `lib/init/auto_scan.g.dart` - 服务自动注册文件
  - `AutoScan.registerServices()` - 注册所有 @Service 服务
  - `AutoScan.injectServices()` - 执行依赖注入
  - 支持命名服务和懒加载

### 生成的服务
| 服务类 | 注册方式 | 特性 |
|---------|----------|------|
| UserService | 懒加载 | AOP 增强 (UserServiceAop) |
| ProductService | 立即注册 | 无 AOP |
| TestService | 立即注册 | 命名: "testService" |
| NamedService | 懒加载 | 命名: "namedService" |

## 技术栈

- **Flutter** 3.8.1+
- **GetX** 4.7.2+ (状态管理和依赖注入基础)
- **Fall Core** (AOP框架)
- **Build Runner** 2.7.0+ (代码生成)

## 更多信息

- [Fall Core 框架文档](../README.md)
- [Flutter 官方文档](https://flutter.dev/docs)
- [GetX 文档](https://github.com/jonataslaw/getx)