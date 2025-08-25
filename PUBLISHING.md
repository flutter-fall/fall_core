# Fall Core 发布前检查清单

在发布新版本到 pub.dev 之前，请确保完成以下所有检查项：

## 📋 代码质量检查

- [ ] **代码分析通过**: `flutter analyze` 无错误和警告
- [ ] **测试通过**: 所有单元测试和集成测试通过
- [ ] **代码格式化**: 使用 `dart format .` 格式化所有代码
- [ ] **依赖检查**: 确保所有依赖版本是最新稳定版本

## 📚 文档检查

- [ ] **README.md 更新**: 确保 README 包含最新功能和使用方法
- [ ] **CHANGELOG.md 更新**: 记录新版本的所有变更
- [ ] **API 文档**: 确保所有公共 API 都有完整的 dartdoc 注释
- [ ] **示例代码**: example/ 目录下的示例代码可以正常运行

## 🔧 版本管理

- [ ] **版本号更新**: 在 pubspec.yaml 中更新版本号
- [ ] **版本号遵循语义化**: 遵循 [语义化版本控制](https://semver.org/lang/zh-CN/)
  - 主版本号 (X.y.z): 不兼容的 API 修改
  - 次版本号 (x.Y.z): 向下兼容的功能性新增
  - 修订号 (x.y.Z): 向下兼容的问题修正
- [ ] **Git 标签**: 为新版本创建对应的 Git 标签

## 🎯 发布信息

- [ ] **描述完整**: pubspec.yaml 中的 description 准确描述包功能
- [ ] **主页链接**: homepage 和 repository 链接正确
- [ ] **话题标签**: topics 包含相关关键词
- [ ] **许可证**: LICENSE 文件存在且适当

## 🧪 功能测试

- [ ] **核心功能**: 所有核心功能正常工作
- [ ] **依赖注入**: @Service 和 @Auto 注解正常工作
- [ ] **AOP 功能**: Hook 系统正常工作
- [ ] **代码生成**: build_runner 生成的代码正确
- [ ] **示例应用**: example 应用可以正常构建和运行

## 📦 发布准备

- [ ] **干运行测试**: `dart pub publish --dry-run` 通过
- [ ] **发布权限**: 确保有 pub.dev 发布权限
- [ ] **网络连接**: 确保网络连接稳定

## 🚀 发布后验证

- [ ] **包页面检查**: 在 pub.dev 上检查包页面显示正确
- [ ] **文档渲染**: 确保文档在 pub.dev 上正确渲染
- [ ] **下载测试**: 在新项目中测试包的安装和使用

## 📝 发布命令

### 方式一：使用发布脚本
```bash
# Linux/macOS
chmod +x scripts/publish.sh
./scripts/publish.sh

# Windows
scripts\publish.bat
```

### 方式二：手动发布
```bash
# 1. 清理和检查
flutter clean
flutter pub get
flutter analyze
flutter test

# 2. 干运行
dart pub publish --dry-run

# 3. 正式发布
dart pub publish

# 4. 创建标签
git tag v1.0.0
git push origin v1.0.0
```

## 🔄 发布后流程

1. **更新文档网站** (如果有)
2. **发布公告**: 在相关社区发布新版本公告
3. **更新示例项目**: 确保示例项目使用最新版本
4. **监控反馈**: 关注 GitHub Issues 和 pub.dev 评分

---

**注意**: 发布到 pub.dev 是不可撤销的操作，请确保在发布前完成所有检查项。