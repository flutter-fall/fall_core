#!/bin/bash

# Fall Core 发布脚本
# 自动化发布到 pub.dev 的流程

set -e  # 遇到错误时停止执行

echo "🚀 Fall Core 发布脚本"
echo "===================="

# 检查当前是否在项目根目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 错误: 请在项目根目录执行此脚本"
    exit 1
fi

# 检查是否有未提交的更改
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  警告: 存在未提交的更改"
    echo "请先提交所有更改后再发布"
    git status --short
    exit 1
fi

# 获取当前版本
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
echo "📦 当前版本: $CURRENT_VERSION"

# 清理项目
echo "🧹 清理项目..."
flutter clean
flutter pub get

# 运行测试
echo "🧪 运行测试..."
if [ -d "test" ]; then
    flutter test
else
    echo "⚠️  未找到测试目录，跳过测试"
fi

# 运行代码分析
echo "🔍 运行代码分析..."
flutter analyze

# 检查发布准备情况
echo "📋 检查发布准备情况..."
dart pub publish --dry-run

# 确认发布
echo ""
echo "✅ 所有检查通过!"
echo "📋 发布信息:"
echo "   - 版本: $CURRENT_VERSION"
echo "   - 包名: fall_core"
echo ""
read -p "确认发布到 pub.dev? (y/N): " -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 发布到 pub.dev..."
    dart pub publish
    
    # 创建 Git 标签
    echo "🏷️  创建 Git 标签..."
    git tag "v$CURRENT_VERSION"
    git push origin "v$CURRENT_VERSION"
    
    echo ""
    echo "🎉 发布成功!"
    echo "📦 包地址: https://pub.dev/packages/fall_core"
    echo "🏷️  Git 标签: v$CURRENT_VERSION"
else
    echo "❌ 发布已取消"
    exit 1
fi