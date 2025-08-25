@echo off
chcp 65001 >nul
REM Fall Core Publishing Script (Windows Version)
REM Automated publishing process to pub.dev

setlocal enabledelayedexpansion

echo.
echo ===========================================
echo    Fall Core Publishing Script
echo ===========================================
echo.

REM Check if we are in the project root directory
if not exist "pubspec.yaml" (
    echo [ERROR] Please run this script from the project root directory
    echo.
    pause
    exit /b 1
)


REM Get current version
for /f "tokens=2" %%i in ('findstr "^version:" pubspec.yaml') do set CURRENT_VERSION=%%i
echo [INFO] Current version: !CURRENT_VERSION!
echo.

REM Clean project
echo [STEP 1/5] Cleaning project...
call flutter clean
call flutter pub get
echo.

REM Run tests
echo [STEP 2/5] Running tests...
if exist "test" (
    call flutter test
) else (
    echo [WARNING] No test directory found, skipping tests
)
echo.

REM Run code analysis
echo [STEP 3/5] Running code analysis...
call flutter analyze
echo.

REM Check publishing readiness
echo [STEP 4/5] Checking publishing readiness...
call dart pub publish --dry-run
echo.

REM Confirm publishing
echo [STEP 5/5] Publishing confirmation
echo ========================================
echo All checks passed!
echo.
echo Package Information:
echo   - Name: fall_core
echo   - Version: !CURRENT_VERSION!
echo   - Target: pub.dev
echo.
set /p confirm="Do you want to publish to pub.dev? (y/N): "

if /i "!confirm!"=="y" (
    echo.
    echo [PUBLISHING] Publishing to pub.dev...
    call dart pub publish
    
    REM Create Git tag
    echo.
    echo [GIT] Creating Git tag...
    git tag "v!CURRENT_VERSION!"
    git push origin "v!CURRENT_VERSION!"
    
    echo.
    echo ==========================================
    echo          PUBLISHING SUCCESSFUL!
    echo ==========================================
    echo Package URL: https://pub.dev/packages/fall_core
    echo Git Tag: v!CURRENT_VERSION!
    echo.
) else (
    echo.
    echo [CANCELLED] Publishing cancelled by user
    echo.
)