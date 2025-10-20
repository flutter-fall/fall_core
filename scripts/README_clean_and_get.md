# Flutter Clean and Pub Get 脚本使用说明

本目录包含用于清理和更新所有 Fall Core 模块依赖的脚本。

## 脚本文件

- `clean_and_get.bat` - Windows 批处理脚本
- `clean_and_get.sh` - Mac/Linux Shell 脚本

## 功能说明

这些脚本会自动为以下模块执行 `flutter clean` 和 `flutter pub get`:

1. fall_core_base
2. fall_core_gen
3. fall_core_main
4. fall_gen_base

## 使用方法

### Windows

在项目根目录下运行:

```cmd
.\scripts\clean_and_get.bat
```

或者直接双击 `scripts\clean_and_get.bat` 文件。

### Mac/Linux

在项目根目录下运行:

```bash
# 首次使用需要添加执行权限
chmod +x ./scripts/clean_and_get.sh

# 执行脚本
./scripts/clean_and_get.sh
```

## 脚本特性

- ✅ 按顺序处理每个模块
- ✅ 显示详细的执行进度
- ✅ 错误检测和提示
- ✅ 如果某个模块失败，脚本会立即终止
- ✅ 成功完成后显示确认消息

## 注意事项

1. 确保已安装 Flutter SDK 并配置好环境变量
2. 在执行脚本前，请确保当前工作目录为项目根目录
3. 脚本会清除所有模块的 build 缓存和依赖，然后重新获取依赖
4. 如果某个模块执行失败，脚本会停止并返回错误码

## 常见问题

**Q: 脚本运行失败怎么办？**

A: 检查以下几点：
- Flutter 是否正确安装并在 PATH 中
- 是否在项目根目录执行脚本
- 网络连接是否正常（pub get 需要网络）
- 检查各模块的 pubspec.yaml 文件是否正确

**Q: Mac/Linux 提示权限不足？**

A: 使用 `chmod +x ./scripts/clean_and_get.sh` 添加执行权限

**Q: 可以只清理某个模块吗？**

A: 可以手动编辑脚本，修改 `MODULES` 变量，只保留需要处理的模块名称。
