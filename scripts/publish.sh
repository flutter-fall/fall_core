#!/bin/bash

# Fall Core 多模块发布脚本
# 自动化发布 fall_core_base、fall_core_gen、fall_core_main 到 pub.dev

set -e  # 遇到错误时停止执行

echo "🚀 Fall Core 多模块发布脚本"
echo "================================"
echo

# 定义模块列表
MODULES=("fall_core_base" "fall_core_gen" "fall_core_main")
ROOT_DIR=$(pwd)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 工具函数
print_step() {
    echo -e "${BLUE}[步骤]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 检查当前是否在项目根目录
if [ ! -d "fall_core_base" ] || [ ! -d "fall_core_gen" ] || [ ! -d "fall_core_main" ]; then
    print_error "请在项目根目录执行此脚本"
    exit 1
fi

# 检查是否有未提交的更改
if [ -n "$(git status --porcelain)" ]; then
    print_warning "存在未提交的更改"
    echo "请先提交所有更改后再发布"
    git status --short
    exit 1
fi

# 函数：检查模块状态
check_module() {
    local module=$1
    print_step "检查模块: $module"
    
    cd "$ROOT_DIR/$module"
    
    # 检查 pubspec.yaml 是否存在
    if [ ! -f "pubspec.yaml" ]; then
        print_error "$module/pubspec.yaml 不存在"
        return 1
    fi
    
    # 获取版本号
    local version=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    echo "  📦 版本: $version"
    
    # 检查依赖
    echo "  🔍 检查依赖..."
    flutter pub get > /dev/null 2>&1
    
    # 运行分析
    echo "  📋 代码分析..."
    flutter analyze --no-fatal-infos > /dev/null 2>&1 || {
        print_error "$module 代码分析失败"
        return 1
    }
    
    # 运行测试（如果存在）
    if [ -d "test" ]; then
        echo "  🧪 运行测试..."
        dart test > /dev/null 2>&1 || {
            print_error "$module 测试失败"
            return 1
        }
    else
        print_warning "$module 未找到测试目录"
    fi
    
    # 干运行发布检查
    echo "  📦 发布检查..."
    dart pub publish --dry-run > /dev/null 2>&1 || {
        print_error "$module 发布检查失败"
        return 1
    }
    
    print_success "$module 检查通过"
    cd "$ROOT_DIR"
}

# 函数：发布模块
publish_module() {
    local module=$1
    print_step "发布模块: $module"
    
    cd "$ROOT_DIR/$module"
    
    # 获取版本号
    local version=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    
    echo "  🚀 发布到 pub.dev..."
    dart pub publish --force || {
        print_error "$module 发布失败"
        return 1
    }
    
    print_success "$module v$version 发布成功"
    echo "  📦 包地址: https://pub.dev/packages/$module"
    
    cd "$ROOT_DIR"
}

# 函数：创建 Git 标签
create_git_tags() {
    print_step "创建 Git 标签"
    
    for module in "${MODULES[@]}"; do
        cd "$ROOT_DIR/$module"
        local version=$(grep '^version:' pubspec.yaml | sed 's/version: //')
        local tag="$module-v$version"
        
        echo "  🏷️  创建标签: $tag"
        git tag "$tag" 2>/dev/null || {
            print_warning "标签 $tag 已存在，跳过"
        }
        
        cd "$ROOT_DIR"
    done
    
    echo "  📤 推送标签到远程仓库..."
    git push origin --tags
    
    print_success "Git 标签创建完成"
}

echo "📋 准备发布以下模块:"
for module in "${MODULES[@]}"; do
    cd "$ROOT_DIR/$module"
    version=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    echo "  📦 $module v$version"
    cd "$ROOT_DIR"
done
echo

# 第一阶段：检查所有模块
print_step "阶段 1/3: 检查所有模块状态"
echo "=================================="

for module in "${MODULES[@]}"; do
    check_module "$module" || exit 1
done

print_success "所有模块检查通过!"
echo

# 第二阶段：确认发布
print_step "阶段 2/3: 发布确认"
echo "=================="
echo "✅ 所有检查通过!"
echo "📋 即将发布以下模块:"
for module in "${MODULES[@]}"; do
    cd "$ROOT_DIR/$module"
    version=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    echo "   📦 $module v$version"
    cd "$ROOT_DIR"
done
echo
read -p "确认发布所有模块到 pub.dev? (y/N): " -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "发布已取消"
    exit 1
fi

# 第三阶段：执行发布
print_step "阶段 3/3: 执行发布"
echo "=================="

# 按依赖顺序发布模块
PUBLISH_ORDER=("fall_core_base" "fall_core_gen" "fall_core_main")

for module in "${PUBLISH_ORDER[@]}"; do
    publish_module "$module" || exit 1
    echo "  ⏱️  等待 10 秒后发布下一个模块..."
    sleep 10
done

# 创建 Git 标签
create_git_tags

echo
print_success "🎉 所有模块发布成功!"
echo "================================"
echo "📦 发布的模块:"
for module in "${MODULES[@]}"; do
    cd "$ROOT_DIR/$module"
    version=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    echo "   📦 $module v$version - https://pub.dev/packages/$module"
    cd "$ROOT_DIR"
done
echo
print_success "发布流程完成!"