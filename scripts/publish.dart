#!/usr/bin/env dart

import 'dart:io';
import 'dart:async';

/// Fall Core 多模块发布脚本 (Dart 版本)
/// 自动化发布 fall_core_base、fall_core_gen、fall_core_main 到 pub.dev
///
/// 使用方法:
///   dart scripts/publish.dart      - 发布所有模块
///   dart scripts/publish.dart 1    - 仅发布 fall_core_base
///   dart scripts/publish.dart 2    - 发布 fall_core_gen 和 fall_core_main
///   dart scripts/publish.dart help - 显示帮助信息
class PublishTool {
  static const List<String> allModules = [
    'fall_core_base',
    'fall_gen_base',
    'fall_core_gen',
    'fall_core_main',
  ];

  /// 按依赖顺序定义发布顺序：必须先发布 fall_core_base，然后 fall_gen_base
  static const List<String> publishOrder = [
    'fall_core_base',
    'fall_gen_base',
    'fall_core_gen',
    'fall_core_main',
  ];

  late Directory rootDir;
  late List<String> modulesToPublish;
  late List<String> publishSequence;

  PublishTool() {
    rootDir = Directory.current;
  }

  /// 显示帮助信息
  void showHelp() {
    print('''
===========================================
   Fall Core 多模块发布脚本 (Dart版本)
===========================================

使用说明:
  dart scripts/publish.dart      - 发布所有模块
  dart scripts/publish.dart 1    - 仅发布 fall_core_base
  dart scripts/publish.dart 2    - 发布 fall_core_base 和 fall_gen_base
  dart scripts/publish.dart 3    - 发布 fall_core_gen 和 fall_core_main
  dart scripts/publish.dart help - 显示此帮助信息

注意事项:
  • 发布前请确保所有更改已提交到 Git
  • 模块将按依赖顺序自动发布：base → gen_base → gen → main
  • 需要有 pub.dev 发布权限
  • 建议在发布前运行版本同步脚本
''');
  }

  /// 解析命令行参数
  void parseArguments(List<String> args) {
    if (args.isEmpty) {
      // 发布所有模块
      modulesToPublish = List.from(allModules);
      publishSequence = List.from(publishOrder);
      print('[信息] 模式: 发布所有模块');
    } else if (args[0] == 'help' || args[0] == '-h' || args[0] == '--help') {
      showHelp();
      exit(0);
    } else if (args[0] == '1') {
      // 仅发布 fall_core_base
      modulesToPublish = ['fall_core_base'];
      publishSequence = ['fall_core_base'];
      print('[信息] 模式: 仅发布 fall_core_base');
    } else if (args[0] == '2') {
      // 发布 fall_core_base 和 fall_gen_base
      modulesToPublish = ['fall_gen_base'];
      publishSequence = ['fall_gen_base'];
      print('[信息] 模式: 发布 fall_gen_base');
    } else if (args[0] == '3') {
      // 发布 fall_core_gen 和 fall_core_main
      modulesToPublish = ['fall_core_main'];
      publishSequence = ['fall_core_main'];
      print('[信息] 模式: 发布 fall_core_main');
    } else if (args[0] == '4') {
      // 发布 fall_core_gen 和 fall_core_main
      modulesToPublish = ['fall_core_gen'];
      publishSequence = ['fall_core_gen'];
      print('[信息] 模式: 发布 fall_core_gen');
    } else {
      print('❌ 无效参数: ${args[0]}');
      print('使用 "dart scripts/publish.dart help" 查看帮助信息');
      exit(1);
    }
    print('');
  }

  /// 检查项目根目录
  bool _checkProjectRoot() {
    for (String module in modulesToPublish) {
      if (!Directory('${rootDir.path}/$module').existsSync()) {
        print('❌ [错误] 请在项目根目录执行此脚本，缺少目录: $module');
        return false;
      }
    }
    return true;
  }

  /// 执行命令并返回结果
  Future<ProcessResult> _runCommand(
    String command,
    List<String> args, {
    String? workingDirectory,
    bool silent = false,
  }) async {
    if (!silent) {
      print('   💻 执行: $command ${args.join(' ')}');
    }

    try {
      // 在Windows下使用shell执行，让系统自动找到正确的可执行文件
      return await Process.run(
        command,
        args,
        workingDirectory: workingDirectory ?? rootDir.path,
        runInShell: true, // 使用shell执行，确保能找到PATH中的命令
      );
    } catch (e) {
      if (!silent) {
        print('   ❌ 命令执行失败: $e');
      }
      // 返回一个失败的 ProcessResult
      return ProcessResult(0, 1, '', 'Command execution failed: $e');
    }
  }

  /// 检查Git状态
  Future<bool> _checkGitStatus() async {
    print('[检查] Git状态...');

    final result = await _runCommand('git', [
      'status',
      '--porcelain',
    ], silent: true);

    if (result.exitCode != 0) {
      print('❌ [错误] 无法检查 Git 状态');
      return false;
    }

    if (result.stdout.toString().trim().isNotEmpty) {
      print('❌ [警告] 存在未提交的更改');
      print('请先提交所有更改后再发布');

      // 显示未提交的文件
      final statusResult = await _runCommand('git', ['status', '--short']);
      print(statusResult.stdout);
      return false;
    }

    print('✅ Git状态检查通过');
    return true;
  }

  /// 读取模块版本
  String? _getModuleVersion(String modulePath) {
    final pubspecFile = File('$modulePath/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      return null;
    }

    final content = pubspecFile.readAsStringSync();
    final versionRegex = RegExp(r'^version:\s*(.+)$', multiLine: true);
    final match = versionRegex.firstMatch(content);
    return match?.group(1)?.trim();
  }

  /// 显示即将发布的模块信息
  void _showModulesInfo() {
    print('[信息] 准备发布以下模块:');
    for (String module in modulesToPublish) {
      final version = _getModuleVersion('${rootDir.path}/$module');
      print('  📦 $module v${version ?? 'unknown'}');
    }
    print('');
  }

  /// 检查单个模块
  Future<bool> _checkModule(String module) async {
    final modulePath = '${rootDir.path}/$module';
    print('[检查] 模块: $module');

    // 检查 pubspec.yaml
    if (!File('$modulePath/pubspec.yaml').existsSync()) {
      print('❌ [错误] $module/pubspec.yaml 不存在');
      return false;
    }

    // 获取版本号
    final version = _getModuleVersion(modulePath);
    if (version != null) {
      print('  📦 版本: $version');
    }

    // 检查依赖
    print('  🔍 检查依赖...');
    var result = await _runCommand(
      'flutter',
      ['pub', 'get'],
      workingDirectory: modulePath,
      silent: true,
    );
    if (result.exitCode != 0) {
      print('❌ [错误] $module 依赖获取失败');
      print(result.stderr);
      return false;
    }

    // 代码分析
    print('  📋 代码分析...');
    result = await _runCommand(
      'flutter',
      ['analyze', '--no-fatal-infos'],
      workingDirectory: modulePath,
      silent: true,
    );
    if (result.exitCode != 0) {
      print('❌ [错误] $module 代码分析失败');
      print(result.stdout);
      return false;
    }

    // 运行测试（如果存在）
    final testDir = Directory('$modulePath/test');
    if (testDir.existsSync()) {
      print('  🧪 运行测试...');
      result = await _runCommand(
        'dart',
        ['test'],
        workingDirectory: modulePath,
        silent: true,
      );
      if (result.exitCode != 0) {
        print('❌ [错误] $module 测试失败');
        print(result.stdout);
        return false;
      }
    } else {
      print('  ⚠️ $module 未找到测试目录');
    }

    // 干运行发布检查
    print('  📦 发布检查...');
    result = await _runCommand(
      'dart',
      ['pub', 'publish', '--dry-run'],
      workingDirectory: modulePath,
      silent: true,
    );
    if (result.exitCode != 0) {
      print('❌ [错误] $module 发布检查失败');
      print(result.stderr);
      return false;
    }

    print('✅ [成功] $module 检查通过');
    print('');
    return true;
  }

  /// 发布单个模块
  Future<bool> _publishModule(String module) async {
    final modulePath = '${rootDir.path}/$module';
    print('[发布] 模块: $module');

    final version = _getModuleVersion(modulePath);
    if (version == null) {
      print('❌ [错误] 无法获取 $module 的版本号');
      return false;
    }

    print('  🚀 发布到 pub.dev...');
    final result = await _runCommand('dart', [
      'pub',
      'publish',
      '--force',
    ], workingDirectory: modulePath);

    if (result.exitCode != 0) {
      print('❌ [错误] $module 发布失败');
      print(result.stderr);
      return false;
    }

    print('✅ [成功] $module v$version 发布成功');
    print('  📦 包地址: https://pub.dev/packages/$module');
    print('');

    return true;
  }

  /// 创建Git标签
  Future<void> _createGitTags() async {
    print('[步骤] 创建 Git 标签');

    for (String module in modulesToPublish) {
      final version = _getModuleVersion('${rootDir.path}/$module');
      if (version != null) {
        final tag = '$module-v$version';
        print('  🏷️ 创建标签: $tag');

        final result = await _runCommand('git', ['tag', tag], silent: true);
        if (result.exitCode != 0) {
          print('  ⚠️ 标签 $tag 已存在，跳过');
        }
      }
    }

    print('  📤 推送标签到远程仓库...');
    await _runCommand('git', ['push', 'origin', '--tags']);
    print('✅ [成功] Git 标签创建完成');
    print('');
  }

  /// 获取用户确认
  Future<bool> _getUserConfirmation() async {
    print('[步骤 2/3] 发布确认');
    print('==================');
    print('✅ 所有检查通过!');
    print('📋 即将发布以下模块:');

    for (String module in modulesToPublish) {
      final version = _getModuleVersion('${rootDir.path}/$module');
      print('  📦 $module v${version ?? 'unknown'}');
    }
    print('');

    stdout.write('确认发布所有模块到 pub.dev? (y/N): ');
    final input = stdin.readLineSync()?.trim().toLowerCase();

    return input == 'y' || input == 'yes';
  }

  /// 显示发布结果摘要
  void _showPublishSummary() {
    print('==========================================');
    print('         🎉 所有模块发布成功!');
    print('==========================================');
    print('📦 发布的模块:');

    for (String module in modulesToPublish) {
      final version = _getModuleVersion('${rootDir.path}/$module');
      print(
        '  📦 $module v${version ?? 'unknown'} - https://pub.dev/packages/$module',
      );
    }
    print('');
    print('✅ [成功] 发布流程完成!');
    print('');
  }

  /// 等待指定秒数
  Future<void> _waitSeconds(int seconds) async {
    print('  ⏱️ 等待 $seconds 秒后发布下一个模块...');
    await Future.delayed(Duration(seconds: seconds));
  }

  /// 执行发布流程
  Future<void> publish(List<String> args) async {
    print('===========================================');
    print('   Fall Core 多模块发布脚本 (Dart版本)');
    print('===========================================');
    print('');

    // 解析参数
    parseArguments(args);

    // 检查项目根目录
    if (!_checkProjectRoot()) {
      exit(1);
    }

    // 检查Git状态
    if (!await _checkGitStatus()) {
      exit(1);
    }

    // 显示模块信息
    _showModulesInfo();

    // 阶段1: 检查所有模块状态
    print('[步骤 1/3] 检查所有模块状态');
    print('==================================');
    print('');

    for (String module in modulesToPublish) {
      if (!await _checkModule(module)) {
        exit(1);
      }
    }

    print('✅ [成功] 所有模块检查通过!');
    print('');

    // 阶段2: 确认发布
    if (!await _getUserConfirmation()) {
      print('');
      print('❌ [已取消] 发布已取消');
      print('');
      exit(1);
    }

    // 阶段3: 执行发布
    print('');
    print('[步骤 3/3] 执行发布');
    print('==================');
    print('');

    // 按依赖顺序发布模块
    for (int i = 0; i < publishSequence.length; i++) {
      final module = publishSequence[i];

      // 只发布用户指定的模块
      if (!modulesToPublish.contains(module)) {
        continue;
      }

      if (!await _publishModule(module)) {
        exit(1);
      }

      // 如果不是最后一个模块，等待10秒
      if (i < publishSequence.length - 1 && i < modulesToPublish.length - 1) {
        await _waitSeconds(10);
      }
    }

    // 创建Git标签
    await _createGitTags();

    // 显示发布结果
    _showPublishSummary();
  }
}

/// 主函数
void main(List<String> args) async {
  final tool = PublishTool();

  try {
    await tool.publish(args);
  } catch (e, stackTrace) {
    print('\n💥 执行过程中发生错误: $e');
    if (args.contains('--debug')) {
      print('Stack trace: $stackTrace');
    }
    exit(1);
  }
}
