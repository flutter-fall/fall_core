@echo off
chcp 65001 >nul
REM Fall Core 多模块发布脚本 (Windows 版本)
REM 自动化发布 fall_core_base、fall_core_gen、fall_core_main 到 pub.dev

setlocal enabledelayedexpansion

echo.
echo ===========================================
echo    Fall Core 多模块发布脚本
echo ===========================================
echo.

REM 定义模块列表
set MODULES=fall_core_base fall_core_gen fall_core_main
set ROOT_DIR=%CD%

REM 检查当前是否在项目根目录
if not exist "fall_core_base" (
    echo [错误] 请在项目根目录执行此脚本
    echo.
    pause
    exit /b 1
)
if not exist "fall_core_gen" (
    echo [错误] 请在项目根目录执行此脚本
    echo.
    pause
    exit /b 1
)
if not exist "fall_core_main" (
    echo [错误] 请在项目根目录执行此脚本
    echo.
    pause
    exit /b 1
)

REM 检查是否有未提交的更改
for /f "delims=" %%i in ('git status --porcelain') do (
    echo [警告] 存在未提交的更改
    echo 请先提交所有更改后再发布
    git status --short
    pause
    exit /b 1
)

REM 显示即将发布的模块信息
echo [信息] 准备发布以下模块:
for %%m in (%MODULES%) do (
    cd "%ROOT_DIR%\%%m"
    for /f "tokens=2" %%v in ('findstr "^version:" pubspec.yaml') do (
        echo   📦 %%m v%%v
    )
    cd "%ROOT_DIR%"
)
echo.

REM 阶段1: 检查所有模块状态
echo [步骤 1/3] 检查所有模块状态
echo ==================================

for %%m in (%MODULES%) do (
    echo [检查] 模块: %%m
    cd "%ROOT_DIR%\%%m"
    
    REM 检查 pubspec.yaml 是否存在
    if not exist "pubspec.yaml" (
        echo [错误] %%m/pubspec.yaml 不存在
        cd "%ROOT_DIR%"
        pause
        exit /b 1
    )
    
    REM 获取版本号
    for /f "tokens=2" %%v in ('findstr "^version:" pubspec.yaml') do (
        echo   📦 版本: %%v
    )
    
    REM 检查依赖
    echo   🔍 检查依赖...
    call flutter pub get >nul 2>&1
    if errorlevel 1 (
        echo [错误] %%m 依赖获取失败
        cd "%ROOT_DIR%"
        pause
        exit /b 1
    )
    
    REM 运行分析
    echo   📋 代码分析...
    call flutter analyze --no-fatal-infos >nul 2>&1
    if errorlevel 1 (
        echo [错误] %%m 代码分析失败
        cd "%ROOT_DIR%"
        pause
        exit /b 1
    )
    
    REM 运行测试（如果存在）
    if exist "test" (
        echo   🧪 运行测试...
        call dart test >nul 2>&1
        if errorlevel 1 (
            echo [错误] %%m 测试失败
            cd "%ROOT_DIR%"
            pause
            exit /b 1
        )
    ) else (
        echo   ⚠️ %%m 未找到测试目录
    )
    
    REM 干运行发布检查
    echo   📦 发布检查...
    call dart pub publish --dry-run >nul 2>&1
    if errorlevel 1 (
        echo [错误] %%m 发布检查失败
        cd "%ROOT_DIR%"
        pause
        exit /b 1
    )
    
    echo [成功] %%m 检查通过
    cd "%ROOT_DIR%"
    echo.
)

echo [成功] 所有模块检查通过!
echo.

REM 阶段2: 确认发布
echo [步骤 2/3] 发布确认
echo ==================
echo ✅ 所有检查通过!
echo 📋 即将发布以下模块:
for %%m in (%MODULES%) do (
    cd "%ROOT_DIR%\%%m"
    for /f "tokens=2" %%v in ('findstr "^version:" pubspec.yaml') do (
        echo    📦 %%m v%%v
    )
    cd "%ROOT_DIR%"
)
echo.
set /p confirm="确认发布所有模块到 pub.dev? (y/N): "

if /i not "!confirm!"=="y" (
    echo.
    echo [已取消] 发布已取消
    echo.
    pause
    exit /b 1
)

REM 阶段3: 执行发布
echo.
echo [步骤 3/3] 执行发布
echo ==================

REM 按依赖顺序发布模块
set PUBLISH_ORDER=fall_core_base fall_core_gen fall_core_main

for %%m in (%PUBLISH_ORDER%) do (
    echo [发布] 模块: %%m
    cd "%ROOT_DIR%\%%m"
    
    REM 获取版本号
    for /f "tokens=2" %%v in ('findstr "^version:" pubspec.yaml') do (
        set MODULE_VERSION=%%v
    )
    
    echo   🚀 发布到 pub.dev...
    call dart pub publish --force
    if errorlevel 1 (
        echo [错误] %%m 发布失败
        cd "%ROOT_DIR%"
        pause
        exit /b 1
    )
    
    echo [成功] %%m v!MODULE_VERSION! 发布成功
    echo   📦 包地址: https://pub.dev/packages/%%m
    
    cd "%ROOT_DIR%"
    
    REM 等待 10 秒后发布下一个模块
    echo   ⏱️ 等待 10 秒后发布下一个模块...
    timeout /t 10 /nobreak >nul
    echo.
)

REM 创建 Git 标签
echo [步骤] 创建 Git 标签
for %%m in (%MODULES%) do (
    cd "%ROOT_DIR%\%%m"
    for /f "tokens=2" %%v in ('findstr "^version:" pubspec.yaml') do (
        set TAG=%%m-v%%v
        echo   🏷️ 创建标签: !TAG!
        git tag "!TAG!" 2>nul || (
            echo   ⚠️ 标签 !TAG! 已存在，跳过
        )
    )
    cd "%ROOT_DIR%"
)

echo   📤 推送标签到远程仓库...
git push origin --tags

echo [成功] Git 标签创建完成
echo.

REM 显示发布结果
echo ==========================================
echo          🎉 所有模块发布成功!
echo ==========================================
echo 📦 发布的模块:
for %%m in (%MODULES%) do (
    cd "%ROOT_DIR%\%%m"
    for /f "tokens=2" %%v in ('findstr "^version:" pubspec.yaml') do (
        echo    📦 %%m v%%v - https://pub.dev/packages/%%m
    )
    cd "%ROOT_DIR%"
)
echo.
echo [成功] 发布流程完成!
echo.
pause