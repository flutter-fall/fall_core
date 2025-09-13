#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Fall Core 版本同步脚本 (Dart 版本)
/// 统一更新所有模块的版本号和依赖关系
class VersionSyncTool {
  static const List<String> modules = [
    'fall_core_base',
    'fall_core_gen',
    'fall_core_main',
  ];

  static const Map<String, List<String>> dependencies = {
    'fall_core_gen': ['fall_core_base'],
    'fall_core_main': ['fall_core_base'],
  };

  late Directory rootDir;

  VersionSyncTool() {
    rootDir = Directory.current;
  }

  /// 检查是否在项目根目录
  bool _checkProjectRoot() {
    for (String module in modules) {
      if (!Directory('${rootDir.path}/$module').existsSync()) {
        print('❌ [错误] 请在项目根目录执行此脚本');
        print('   缺少模块目录: $module');
        return false;
      }
    }
    return true;
  }

  /// 读取pubspec.yaml文件内容
  String _readPubspecContent(String modulePath) {
    final pubspecFile = File('$modulePath/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml 文件不存在: $modulePath');
    }
    return pubspecFile.readAsStringSync();
  }

  /// 写入pubspec.yaml文件内容
  void _writePubspecContent(String modulePath, String content) {
    final pubspecFile = File('$modulePath/pubspec.yaml');
    pubspecFile.writeAsStringSync(content);
  }

  /// 从pubspec.yaml内容中提取版本号
  String? _extractVersion(String content) {
    final versionRegex = RegExp(r'^version:\s*(.+)$', multiLine: true);
    final match = versionRegex.firstMatch(content);
    return match?.group(1)?.trim();
  }

  /// 获取所有模块的当前版本
  Map<String, String> getCurrentVersions() {
    final versions = <String, String>{};

    for (String module in modules) {
      try {
        final content = _readPubspecContent('${rootDir.path}/$module');
        final version = _extractVersion(content);
        if (version != null) {
          versions[module] = version;
        } else {
          versions[module] = 'unknown';
        }
      } catch (e) {
        versions[module] = 'error: $e';
      }
    }

    return versions;
  }

  /// 验证版本号格式
  bool _isValidVersion(String version) {
    final versionRegex = RegExp(r'^\d+\.\d+\.\d+$');
    return versionRegex.hasMatch(version);
  }

  /// 更新单个模块的版本号
  bool _updateModuleVersion(String module, String newVersion) {
    try {
      final modulePath = '${rootDir.path}/$module';
      final content = _readPubspecContent(modulePath);

      // 备份原文件
      final backupFile = File('$modulePath/pubspec.yaml.bak');
      backupFile.writeAsStringSync(content);

      // 替换版本号
      final updatedContent = content.replaceFirst(
        RegExp(r'^version:\s*.*$', multiLine: true),
        'version: $newVersion',
      );

      _writePubspecContent(modulePath, updatedContent);

      // 验证更新是否成功
      final verifyContent = _readPubspecContent(modulePath);
      final actualVersion = _extractVersion(verifyContent);

      if (actualVersion == newVersion) {
        print('  ✅ $module: 成功更新到 $newVersion');
        return true;
      } else {
        print('  ❌ $module: 更新失败，版本仍为 $actualVersion');
        return false;
      }
    } catch (e) {
      print('  ❌ $module: 更新失败 - $e');
      return false;
    }
  }

  /// 更新模块间的依赖版本
  bool _updateDependencies(String newVersion) {
    bool allSuccess = true;

    print('\n📦 更新模块间依赖关系...');
    print('========================================');

    for (String module in modules) {
      final deps = dependencies[module];
      if (deps == null || deps.isEmpty) continue;

      try {
        final modulePath = '${rootDir.path}/$module';
        final content = _readPubspecContent(modulePath);
        String updatedContent = content;

        for (String dep in deps) {
          // 更新依赖版本，匹配格式: dep_name: ^x.x.x
          final depRegex = RegExp('($dep):\\s*\\^[0-9.]+', multiLine: true);

          if (depRegex.hasMatch(updatedContent)) {
            updatedContent = updatedContent.replaceAll(
              depRegex,
              '$dep: ^$newVersion',
            );
            print('  ✅ $module: 已更新 $dep 依赖至 ^$newVersion');
          }
        }

        _writePubspecContent(modulePath, updatedContent);
      } catch (e) {
        print('  ❌ $module: 依赖更新失败 - $e');
        allSuccess = false;
      }
    }

    return allSuccess;
  }

  /// 显示当前版本信息
  void showCurrentVersions() {
    print('\n📋 [信息] 当前版本号:');
    final versions = getCurrentVersions();

    for (String module in modules) {
      final version = versions[module] ?? 'unknown';
      print('  📦 $module: $version');
    }
  }

  /// 获取用户输入的新版本号
  String? _getUserInput() {
    print('\n请输入新的版本号 (格式: x.y.z): ');
    return stdin.readLineSync()?.trim();
  }

  /// 执行版本同步
  Future<void> syncVersions() async {
    print('=========================');
    print(' Fall Core 版本同步脚本');
    print('=========================\n');

    // 检查项目根目录
    if (!_checkProjectRoot()) {
      exit(1);
    }

    // 显示当前版本
    showCurrentVersions();

    // 获取新版本号
    final newVersion = _getUserInput();
    if (newVersion == null || newVersion.isEmpty) {
      print('❌ 版本号不能为空');
      exit(1);
    }

    // 验证版本号格式
    if (!_isValidVersion(newVersion)) {
      print('❌ 版本号格式不正确，请使用 x.y.z 格式 (如: 1.0.0, 0.0.3)');
      print('   您输入的版本号: $newVersion');
      exit(1);
    }

    print('\n📝 [信息] 将所有模块版本号更新为: $newVersion');
    print('========================================');

    // 更新所有模块版本
    bool allSuccess = true;
    final updateResults = <String, bool>{};

    for (String module in modules) {
      print('[更新] $module...');
      final success = _updateModuleVersion(module, newVersion);
      updateResults[module] = success;
      if (!success) allSuccess = false;
    }

    // 更新依赖关系
    final depSuccess = _updateDependencies(newVersion);
    if (!depSuccess) allSuccess = false;

    // 显示结果摘要
    print('\n==========================================');
    if (allSuccess) {
      print(' 🎉 版本同步完成！');
    } else {
      print(' ⚠️  版本同步部分完成（有错误）');
    }
    print('==========================================');

    print('📦 所有模块版本号已更新为: $newVersion');
    if (depSuccess) {
      print('🔗 模块间依赖关系已同步更新');
    }

    print('\n📝 下一步建议:');
    print(
      '1. 检查并提交版本变更: git add . && git commit -m "chore: bump version to $newVersion"',
    );
    print('2. 更新各模块的 CHANGELOG.md');
    print('3. 运行发布脚本: dart scripts/publish.dart 或 scripts/publish.bat');
    print('4. 验证模块依赖: flutter pub deps');

    print('\n📊 更新摘要:');
    for (String module in modules) {
      final success = updateResults[module] ?? false;
      if (success) {
        print('  ✅ $module: 成功更新至 $newVersion');
      } else {
        print('  ❌ $module: 更新失败');
      }
    }

    // 清理备份文件（可选）
    print('\n🧹 清理备份文件...');
    for (String module in modules) {
      final backupFile = File('${rootDir.path}/$module/pubspec.yaml.bak');
      if (backupFile.existsSync()) {
        backupFile.deleteSync();
        print('  🗑️ 已删除 $module/pubspec.yaml.bak');
      }
    }

    if (!allSuccess) {
      print('\n⚠️ 警告: 部分更新失败，请检查错误信息并手动修复');
      exit(1);
    }
  }
}

/// 主函数
void main() async {
  final tool = VersionSyncTool();
  try {
    await tool.syncVersions();
  } catch (e) {
    print('\n💥 执行过程中发生错误: $e');
    exit(1);
  }
}
