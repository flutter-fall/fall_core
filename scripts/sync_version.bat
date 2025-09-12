@echo off
chcp 65001 >nul
REM Fall Core 版本同步脚本 (Windows 版本)
REM 统一更新所有模块的版本号

setlocal enabledelayedexpansion

echo.
echo =========================
echo  Fall Core 版本同步脚本
echo =========================
echo.

REM 检查当前是否在项目根目录
if not exist "fall_core_base" (
    echo [错误] 请在项目根目录执行此脚本
    pause
    exit /b 1
)
if not exist "fall_core_gen" (
    echo [错误] 请在项目根目录执行此脚本
    pause
    exit /b 1
)
if not exist "fall_core_main" (
    echo [错误] 请在项目根目录执行此脚本
    pause
    exit /b 1
)

@echo off
REM 定义模块列表
set MODULES=fall_core_base fall_core_gen fall_core_main
set ROOT_DIR=%CD%

REM 获取当前版本号
echo [信息] 当前版本号:
for %%m in (%MODULES%) do (
    cd "%ROOT_DIR%\%%m"
    for /f "tokens=2" %%v in ('findstr "^version:" pubspec.yaml') do (
        echo   📦 %%m: %%v
    )
    cd "%ROOT_DIR%"
)

echo.
set /p NEW_VERSION="请输入新的版本号 (格式: x.y.z): "

REM 简单的版本号格式验证
powershell -Command "if ('%NEW_VERSION%' -match '^\d+\.\d+\.\d+$') { exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo 版本号格式不正确，请使用 x.y.z 格式 (如: 1.0.0, 0.0.1)
    echo 您输入的版本号: %NEW_VERSION%
    pause
    exit /b 1
)

echo.
echo [信息] 将所有模块版本号更新为: %NEW_VERSION%
echo ========================================

REM 更新所有模块的版本号
for %%m in (%MODULES%) do (
    echo [更新] %%m...
    cd "%ROOT_DIR%\%%m"
    
    REM 备份原文件
    copy pubspec.yaml pubspec.yaml.bak >nul
    
    REM 更新版本号
    powershell -Command "(Get-Content pubspec.yaml) -replace '^version: .*', 'version: %NEW_VERSION%' | Set-Content pubspec.yaml"
    
    REM 验证更新是否成功
    for /f "tokens=2" %%v in ('findstr "^version:" pubspec.yaml') do (
        if "%%v"=="%NEW_VERSION%" (
            echo   ✅ 成功更新到 %%v
        ) else (
            echo   ❌ 更新失败，版本仍为 %%v
        )
    )
    cd "%ROOT_DIR%"
)

echo.
echo ==================
echo  🎉 版本同步完成！
echo ==================
echo 📦 所有模块版本号已更新为: %NEW_VERSION%
echo.
echo 📝 下一步建议:
echo 1. 检查并提交版本变更: git add . ^&^& git commit -m "chore: bump version to %NEW_VERSION%"
echo 2. 更新各模块的 CHANGELOG.md
echo 3. 运行发布脚本: scripts\publish.bat
echo.
pause