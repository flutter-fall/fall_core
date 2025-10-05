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

  static const Map<String, String> pathDependencies = {
    'fall_core_gen': '../fall_core_base',
    'fall_core_main': '../fall_core_base',
  };

  late Directory rootDir;
  final bool devMode;

  VersionSyncTool({this.devMode = false}) {
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

      // 逐行处理，只更新版本号行
      final lines = content.split('\n');
      final updatedLines = <String>[];

      for (String line in lines) {
        if (line.startsWith('version:')) {
          updatedLines.add('version: $newVersion');
        } else {
          updatedLines.add(line);
        }
      }

      final updatedContent = updatedLines.join('\n');
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

    if (devMode) {
      print('\n📦 切换到开发模式（使用本地路径依赖）...');
    } else {
      print('\n📦 更新模块间依赖关系...');
    }
    print('========================================');

    for (String module in modules) {
      final deps = dependencies[module];
      if (deps == null || deps.isEmpty) continue;

      try {
        final modulePath = '${rootDir.path}/$module';
        final content = _readPubspecContent(modulePath);

        final lines = content.split('\n');
        final updatedLines = <String>[];

        String? currentSection; // 'dependencies' 或 'dev_dependencies'
        bool skipNextLine = false; // 用于跳过路径依赖的第二行

        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          final trimmedLine = line.trim();

          // 检测当前所在的配置段
          if (trimmedLine.startsWith('dependencies:')) {
            currentSection = 'dependencies';
            updatedLines.add(line);
            continue;
          } else if (trimmedLine.startsWith('dev_dependencies:')) {
            currentSection = 'dev_dependencies';
            updatedLines.add(line);
            continue;
          }

          // 如果需要跳过当前行（路径依赖的第二行）
          if (skipNextLine) {
            skipNextLine = false;
            continue;
          }

          // 在 dependencies 或 dev_dependencies 段内处理
          if (currentSection != null) {
            bool isTargetDep = false;
            String? targetDepName;

            // 检查是否是目标依赖
            for (String dep in deps) {
              if (trimmedLine.startsWith('$dep:') ||
                  trimmedLine.startsWith('# $dep:')) {
                isTargetDep = true;
                targetDepName = dep;
                break;
              }
            }

            if (isTargetDep && targetDepName != null) {
              // 删除原有的依赖行
              // 检查下一行是否是路径依赖的第二行
              if (i + 1 < lines.length) {
                final nextLine = lines[i + 1].trim();
                if (nextLine.startsWith('path:') ||
                    nextLine.startsWith('# path:')) {
                  skipNextLine = true;
                }
              }

              // 添加新的依赖配置
              final pathDep = pathDependencies[module];
              if (devMode && pathDep != null) {
                // 开发模式：添加路径依赖
                updatedLines.add('  $targetDepName:');
                updatedLines.add('    path: $pathDep');
                print('  ✅ $module: 已设置 $targetDepName 为路径依赖模式 ($pathDep)');
              } else {
                // 生产模式：添加版本依赖
                updatedLines.add('  $targetDepName: ^$newVersion');
                print('  ✅ $module: 已设置 $targetDepName 为版本依赖模式 (^$newVersion)');
              }
            } else {
              // 保留其他行
              updatedLines.add(line);
            }
          } else {
            // 不在目标配置段内，保留原行
            updatedLines.add(line);
          }
        }

        final updatedContent = updatedLines.join('\n');
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
    if (devMode) {
      print(' Fall Core 开发模式切换脚本');
    } else {
      print(' Fall Core 版本同步脚本');
    }
    print('=========================\n');

    // 检查项目根目录
    if (!_checkProjectRoot()) {
      exit(1);
    }

    // 显示当前版本
    showCurrentVersions();

    String? newVersion;

    if (devMode) {
      // 开发模式不需要版本号，使用当前版本
      final versions = getCurrentVersions();
      newVersion = versions['fall_core_base'] ?? '0.0.6';
      print('\n📝 [信息] 开发模式: 使用本地路径依赖，保持当前版本: $newVersion');
    } else {
      // 获取新版本号
      newVersion = _getUserInput();
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
    }

    if (devMode) {
      print('\n📝 [信息] 切换到开发模式（使用本地路径依赖）');
    } else {
      print('\n📝 [信息] 将所有模块版本号更新为: $newVersion');
    }
    print('========================================');

    // 更新所有模块版本
    bool allSuccess = true;
    final updateResults = <String, bool>{};

    if (!devMode) {
      // 只有非开发模式才更新版本号
      for (String module in modules) {
        print('[更新] $module...');
        final success = _updateModuleVersion(module, newVersion!);
        updateResults[module] = success;
        if (!success) allSuccess = false;
      }
    } else {
      // 开发模式不更新版本号
      for (String module in modules) {
        updateResults[module] = true;
      }
    }

    // 更新依赖关系
    final depSuccess = _updateDependencies(newVersion!);
    if (!depSuccess) allSuccess = false;

    // 显示结果摘要
    print('\n==========================================');
    if (allSuccess) {
      if (devMode) {
        print(' 🎉 开发模式切换完成！');
      } else {
        print(' 🎉 版本同步完成！');
      }
    } else {
      if (devMode) {
        print(' ⚠️  开发模式切换部分完成（有错误）');
      } else {
        print(' ⚠️  版本同步部分完成（有错误）');
      }
    }
    print('==========================================');

    if (devMode) {
      print('📦 已切换到开发模式（使用本地路径依赖）');
      print('🔗 模块间依赖关系已切换为本地路径');
    } else {
      print('📦 所有模块版本号已更新为: $newVersion');
      if (depSuccess) {
        print('🔗 模块间依赖关系已同步更新');
      }
    }

    print('\n📝 下一步建议:');
    if (devMode) {
      print(
        '1. 检查并提交依赖变更: git add . && git commit -m "chore: switch to dev mode (local path dependencies)"',
      );
      print('2. 开始本地开发: flutter pub get');
      print('3. 切换回生产模式: dart scripts/sync_version.dart');
    } else {
      print(
        '1. 检查并提交版本变更: git add . && git commit -m "chore: bump version to $newVersion"',
      );
      print('2. 更新各模块的 CHANGELOG.md');
      print('3. 运行发布脚本: dart scripts/publish.dart 或 scripts/publish.bat');
      print('4. 验证模块依赖: flutter pub deps');
    }

    print('\n📈 更新摘要:');
    for (String module in modules) {
      final success = updateResults[module] ?? false;
      if (success) {
        if (devMode) {
          print('  ✅ $module: 已切换到开发模式');
        } else {
          print('  ✅ $module: 成功更新至 $newVersion');
        }
      } else {
        if (devMode) {
          print('  ❌ $module: 切换失败');
        } else {
          print('  ❌ $module: 更新失败');
        }
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
void main(List<String> args) async {
  // 检查是否传入 dev 参数
  final bool devMode = args.contains('dev');

  if (devMode) {
    print('📝 [参数] 检测到 dev 参数，将切换到开发模式');
  }

  final tool = VersionSyncTool(devMode: devMode);
  try {
    await tool.syncVersions();
  } catch (e) {
    print('\n💥 执行过程中发生错误: $e');
    exit(1);
  }
}
