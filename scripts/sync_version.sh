#!/bin/bash

# Fall Core 版本同步脚本
# 统一更新所有模块的版本号

set -e

echo "🔄 Fall Core 版本同步脚本"
echo "=========================="

# 检查当前是否在项目根目录
if [ ! -d "fall_core_base" ] || [ ! -d "fall_core_gen" ] || [ ! -d "fall_core_main" ]; then
    echo "❌ 错误: 请在项目根目录执行此脚本"
    exit 1
fi

# 定义模块列表
MODULES=("fall_core_base" "fall_core_gen" "fall_core_main")
ROOT_DIR=$(pwd)

# 获取当前版本号
echo "📋 当前版本号:"
for module in "${MODULES[@]}"; do
    cd "$ROOT_DIR/$module"
    version=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    echo "  📦 $module: $version"
    cd "$ROOT_DIR"
done

echo
read -p "请输入新的版本号 (格式: x.y.z): " NEW_VERSION

# 验证版本号格式
if [[ ! $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ 错误: 版本号格式不正确，请使用 x.y.z 格式 (如: 1.0.0, 0.0.1)"
    echo "您输入的版本号: $NEW_VERSION"
    exit 1
fi

echo
echo "🔄 将所有模块版本号更新为: $NEW_VERSION"
echo "========================================"

# 更新所有模块的版本号
for module in "${MODULES[@]}"; do
    echo "📝 更新 $module..."
    cd "$ROOT_DIR/$module"
    
    # 备份原文件
    cp pubspec.yaml pubspec.yaml.bak
    
    # 更新版本号
    sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
    
    # 验证更新是否成功
    new_version=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    if [ "$new_version" = "$NEW_VERSION" ]; then
        echo "  ✅ $module 版本号已更新为 $NEW_VERSION"
        rm pubspec.yaml.bak
    else
        echo "  ❌ $module 版本号更新失败，恢复备份"
        mv pubspec.yaml.bak pubspec.yaml
        exit 1
    fi
    
    cd "$ROOT_DIR"
done

echo
echo "🎉 版本同步完成！"
echo "================="
echo "📦 所有模块版本号已更新为: $NEW_VERSION"
echo
echo "📝 下一步建议:"
echo "1. 检查并提交版本变更: git add . && git commit -m \"chore: bump version to $NEW_VERSION\""
echo "2. 更新各模块的 CHANGELOG.md"
echo "3. 运行发布脚本: ./scripts/publish.sh"