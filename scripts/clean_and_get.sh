#!/bin/bash

echo "========================================"
echo "Flutter Clean and Pub Get for All Modules"
echo "========================================"
echo ""

MODULES=("fall_core_base" "fall_gen_base" "fall_core_main" "fall_core_gen")

for module in "${MODULES[@]}"; do
    echo ""
    echo "========================================"
    echo "Processing module: $module"
    echo "========================================"
    
    if [ -d "$module" ]; then
        cd "$module" || exit 1
        
        echo "[$module] Running flutter clean..."
        if ! flutter clean; then
            echo "[$module] ERROR: flutter clean failed!"
            cd ..
            exit 1
        fi
        
        echo "[$module] Running flutter pub get..."
        if ! flutter pub get; then
            echo "[$module] ERROR: flutter pub get failed!"
            cd ..
            exit 1
        fi
        
        echo "[$module] Completed successfully!"
        cd ..
    else
        echo "[$module] WARNING: Module directory not found!"
    fi
done

echo ""
echo "========================================"
echo "All modules processed successfully!"
echo "========================================"

exit 0
