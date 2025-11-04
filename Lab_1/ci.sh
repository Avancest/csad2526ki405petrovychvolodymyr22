#!/bin/bash

set -e  # Stop on first error

echo "=== Step 1: Create build directory ==="
mkdir -p build
cd build

echo "=== Step 2: Configure project with CMake ==="
cmake ..
if [ $? -ne 0 ]; then
    echo "[ERROR] CMake configuration failed!"
    exit 1
fi

echo "=== Step 3: Build project ==="
cmake --build .
if [ $? -ne 0 ]; then
    echo "[ERROR] Build failed!"
    exit 1
fi

echo "=== Step 4: Run tests ==="
ctest --output-on-failure
if [ $? -ne 0 ]; then
    echo "[ERROR] Tests failed!"
    exit 1
fi

echo "=== Step 5: Verify executable ==="
if [ -f "HelloWorld" ]; then
    echo "✅ Build successful! Found HelloWorld"
else
    echo "❌ HelloWorld executable not found!"
    exit 1
fi


echo "=== CI completed successfully! ==="
