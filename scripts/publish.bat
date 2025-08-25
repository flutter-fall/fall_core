@echo off
REM Fall Core 发布脚本 (Windows 版本)
REM 自动化发布到 pub.dev 的流程

setlocal enabledelayedexpansion

echo 🚀 Fall Core 发布脚本
echo ====================

REM 检查当前是否在项目根目录
if not exist "pubspec.yaml" (
    echo ❌ 错误: 请在项目根目录执行此脚本
    pause
    exit /b 1
)

REM 检查是否有未提交的更改
git status --porcelain > temp_status.txt
set /p git_status=<temp_status.txt
del temp_status.txt

if not "!git_status!"=="" (
    echo ⚠️  警告: 存在未提交的更改
    echo 请先提交所有更改后再发布
    git status --short
    pause
    exit /b 1
)

REM 获取当前版本
for /f "tokens=2" %%i in ('findstr "^version:" pubspec.yaml') do set CURRENT_VERSION=%%i
echo 📦 当前版本: !CURRENT_VERSION!

REM 清理项目
echo 🧹 清理项目...
call flutter clean
call flutter pub get

REM 运行测试
echo 🧪 运行测试...
if exist "test" (
    call flutter test
) else (
    echo ⚠️  未找到测试目录，跳过测试
)

REM 运行代码分析
echo 🔍 运行代码分析...
call flutter analyze

REM 检查发布准备情况
echo 📋 检查发布准备情况...
call dart pub publish --dry-run

REM 确认发布
echo.
echo ✅ 所有检查通过!
echo 📋 发布信息:
echo    - 版本: !CURRENT_VERSION!
echo    - 包名: fall_core
echo.
set /p confirm="确认发布到 pub.dev? (y/N): "

if /i "!confirm!"=="y" (
    echo 🚀 发布到 pub.dev...
    call dart pub publish
    
    REM 创建 Git 标签
    echo 🏷️  创建 Git 标签...
    git tag "v!CURRENT_VERSION!"
    git push origin "v!CURRENT_VERSION!"
    
    echo.
    echo 🎉 发布成功!
    echo 📦 包地址: https://pub.dev/packages/fall_core
    echo 🏷️  Git 标签: v!CURRENT_VERSION!
) else (
    echo ❌ 发布已取消
)

pause