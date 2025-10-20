@echo off
echo ========================================
echo Flutter Clean and Pub Get for All Modules
echo ========================================
echo.

set MODULES=fall_core_base fall_gen_base  fall_core_main fall_core_gen

for %%m in (%MODULES%) do (
    echo.
    echo ========================================
    echo Processing module: %%m
    echo ========================================
    
    if exist %%m (
        cd %%m
        
        echo [%%m] Running flutter clean...
        call flutter clean
        if errorlevel 1 (
            echo [%%m] ERROR: flutter clean failed!
            cd ..
            goto :error
        )
        
        echo [%%m] Running flutter pub get...
        call flutter pub get
        if errorlevel 1 (
            echo [%%m] ERROR: flutter pub get failed!
            cd ..
            goto :error
        )
        
        echo [%%m] Completed successfully!
        cd ..
    ) else (
        echo [%%m] WARNING: Module directory not found!
    )
)

echo.
echo ========================================
echo All modules processed successfully!
echo ========================================
goto :end

:error
echo.
echo ========================================
echo Script terminated due to error!
echo ========================================
exit /b 1

:end
exit /b 0
