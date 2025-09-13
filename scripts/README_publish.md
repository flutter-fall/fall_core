# Fall Core 多模块发布工具 (Dart版本)

## 概述

`publish.dart` 是一个用于自动化发布 Fall Core 框架所有模块到 pub.dev 的 Dart 脚本，替代了原有的批处理脚本，提供更可靠、跨平台的发布管理功能。

## 功能特性

✅ **多模式发布**: 支持全量发布、基础模块发布、依赖模块发布  
✅ **依赖顺序管理**: 严格按照 base → gen → main 的依赖顺序发布  
✅ **全面检查**: 代码分析、测试运行、发布验证一站式检查  
✅ **Git集成**: 自动检查Git状态、创建版本标签  
✅ **安全发布**: 干运行检查、用户确认、失败回滚  
✅ **详细日志**: 每个步骤的详细状态反馈  
✅ **跨平台兼容**: Windows、macOS、Linux 均可使用  

## 使用方法

### 基本语法

```bash
dart scripts/publish.dart [参数]
```

### 参数说明

| 参数 | 功能 | 说明 |
|------|------|------|
| 无参数 | 发布所有模块 | 按依赖顺序发布 base → gen → main |
| `1` | 仅发布基础模块 | 只发布 fall_core_base |
| `2` | 发布依赖模块 | 发布 fall_core_gen 和 fall_core_main |
| `help` | 显示帮助 | 显示详细使用说明 |

### 使用示例

```bash
# 发布所有模块（推荐）
dart scripts/publish.dart

# 仅发布基础模块
dart scripts/publish.dart 1

# 发布代码生成器和运行时模块
dart scripts/publish.dart 2

# 显示帮助信息
dart scripts/publish.dart help
```

## 发布流程

### 第一阶段：模块检查

脚本会对每个模块执行以下检查：

1. **环境检查**
   - ✅ 验证项目根目录结构
   - ✅ 检查 Git 工作区状态
   - ✅ 确认所有更改已提交

2. **模块验证**
   - ✅ 检查 `pubspec.yaml` 文件存在性
   - ✅ 解析并显示模块版本号
   - ✅ 获取项目依赖 (`flutter pub get`)
   - ✅ 运行代码分析 (`flutter analyze`)
   - ✅ 执行单元测试 (`dart test`)
   - ✅ 发布预检查 (`dart pub publish --dry-run`)

### 第二阶段：发布确认

- 显示所有检查结果摘要
- 列出即将发布的模块和版本
- 等待用户确认发布操作

### 第三阶段：执行发布

1. **按序发布**: 严格按照依赖顺序发布模块
2. **间隔等待**: 模块间等待10秒避免服务器压力
3. **版本标签**: 自动创建 Git 标签并推送到远程
4. **结果汇总**: 显示发布结果和包链接

## 依赖关系管理

### 发布顺序

脚本严格遵循以下发布顺序以确保依赖关系正确：

```
fall_core_base (基础包)
    ↓
fall_core_gen (代码生成器) 依赖 fall_core_base
    ↓  
fall_core_main (运行时) 依赖 fall_core_base
```

### 模块间依赖

- `fall_core_gen` → `fall_core_base`
- `fall_core_main` → `fall_core_base`

**注意**: 必须先发布 `fall_core_base`，否则依赖模块发布会失败。

## 前置要求

### 环境要求

- **Dart SDK**: 2.12.0 或更高版本
- **Flutter SDK**: 3.0.0 或更高版本  
- **Git**: 用于版本控制和标签管理
- **网络**: 稳定的网络连接访问 pub.dev

### 权限要求

- **pub.dev 发布权限**: 需要对所有三个包有发布权限
- **Git 推送权限**: 需要向远程仓库推送标签的权限

### 准备工作

1. **版本同步**: 建议先运行版本同步脚本
   ```bash
   dart scripts/sync_version.dart
   ```

2. **代码提交**: 确保所有更改已提交到 Git
   ```bash
   git add .
   git commit -m "chore: prepare for release"
   ```

3. **Changelog 更新**: 更新各模块的 CHANGELOG.md 文件

## 错误处理

### 常见错误场景

#### Git 状态错误
```
❌ [警告] 存在未提交的更改
```
**解决方案**: 提交或暂存所有更改

#### 依赖获取失败
```
❌ [错误] module_name 依赖获取失败
```
**解决方案**: 检查网络连接，确认 pubspec.yaml 格式正确

#### 代码分析失败
```
❌ [错误] module_name 代码分析失败
```
**解决方案**: 修复代码分析警告和错误

#### 测试失败
```
❌ [错误] module_name 测试失败
```
**解决方案**: 修复失败的测试用例

#### 发布检查失败
```
❌ [错误] module_name 发布检查失败
```
**解决方案**: 检查包元数据，确保符合 pub.dev 要求

### 故障恢复

1. **回滚版本**: 如果发布过程中断，可能需要手动回滚已发布的版本
2. **清理标签**: 删除已创建但未完成发布的 Git 标签
3. **重新发布**: 修复问题后重新执行发布流程

## 示例输出

```
===========================================
   Fall Core 多模块发布脚本 (Dart版本)
===========================================

[信息] 模式: 发布所有模块

[信息] 准备发布以下模块:
  📦 fall_core_base v0.0.3
  📦 fall_core_gen v0.0.3
  📦 fall_core_main v0.0.3

[步骤 1/3] 检查所有模块状态
==================================

[检查] 模块: fall_core_base
  📦 版本: 0.0.3
  🔍 检查依赖...
  📋 代码分析...
  ⚠️ fall_core_base 未找到测试目录
  📦 发布检查...
✅ [成功] fall_core_base 检查通过

[检查] 模块: fall_core_gen
  📦 版本: 0.0.3
  🔍 检查依赖...
  📋 代码分析...
  🧪 运行测试...
  📦 发布检查...
✅ [成功] fall_core_gen 检查通过

[检查] 模块: fall_core_main
  📦 版本: 0.0.3
  🔍 检查依赖...
  📋 代码分析...
  ⚠️ fall_core_main 未找到测试目录
  📦 发布检查...
✅ [成功] fall_core_main 检查通过

✅ [成功] 所有模块检查通过!

[步骤 2/3] 发布确认
==================
✅ 所有检查通过!
📋 即将发布以下模块:
  📦 fall_core_base v0.0.3
  📦 fall_core_gen v0.0.3
  📦 fall_core_main v0.0.3

确认发布所有模块到 pub.dev? (y/N): y

[步骤 3/3] 执行发布
==================

[发布] 模块: fall_core_base
  🚀 发布到 pub.dev...
✅ [成功] fall_core_base v0.0.3 发布成功
  📦 包地址: https://pub.dev/packages/fall_core_base

  ⏱️ 等待 10 秒后发布下一个模块...

[发布] 模块: fall_core_gen
  🚀 发布到 pub.dev...
✅ [成功] fall_core_gen v0.0.3 发布成功
  📦 包地址: https://pub.dev/packages/fall_core_gen

  ⏱️ 等待 10 秒后发布下一个模块...

[发布] 模块: fall_core_main
  🚀 发布到 pub.dev...
✅ [成功] fall_core_main v0.0.3 发布成功
  📦 包地址: https://pub.dev/packages/fall_core_main

[步骤] 创建 Git 标签
  🏷️ 创建标签: fall_core_base-v0.0.3
  🏷️ 创建标签: fall_core_gen-v0.0.3
  🏷️ 创建标签: fall_core_main-v0.0.3
  📤 推送标签到远程仓库...
✅ [成功] Git 标签创建完成

==========================================
         🎉 所有模块发布成功!
==========================================
📦 发布的模块:
  📦 fall_core_base v0.0.3 - https://pub.dev/packages/fall_core_base
  📦 fall_core_gen v0.0.3 - https://pub.dev/packages/fall_core_gen
  📦 fall_core_main v0.0.3 - https://pub.dev/packages/fall_core_main

✅ [成功] 发布流程完成!
```

## 与批处理脚本的对比

| 特性 | Dart 脚本 | 批处理脚本 |
|------|-----------|------------|
| 跨平台支持 | ✅ | ❌ (仅Windows) |
| 错误处理 | ✅ 完善 | ⚠️ 基础 |
| 代码可读性 | ✅ 高 | ⚠️ 中等 |
| 维护性 | ✅ 高 | ⚠️ 有限 |
| 异步处理 | ✅ 原生支持 | ❌ |
| 参数验证 | ✅ 严格 | ⚠️ 基础 |
| 日志输出 | ✅ 结构化 | ⚠️ 简单 |

## 最佳实践

### 发布前检查清单

- [ ] 运行版本同步脚本确保版本一致
- [ ] 更新所有模块的 CHANGELOG.md
- [ ] 确保所有代码更改已提交
- [ ] 验证网络连接和 pub.dev 权限
- [ ] 在测试环境验证功能正常

### 发布流程建议

1. **本地验证**: 先执行干运行测试
2. **分阶段发布**: 可以先发布基础模块，验证后再发布依赖模块
3. **监控发布**: 发布后检查 pub.dev 页面确认成功
4. **通知团队**: 发布完成后通知相关团队成员

## 开发信息

- **文件位置**: `scripts/publish.dart`
- **替代文件**: `scripts/publish.bat`
- **依赖脚本**: `scripts/sync_version.dart`
- **维护者**: Fall Core 团队
- **创建时间**: 2025-09-13