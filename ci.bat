@echo off
echo === Step 1: Create build directory ===
if not exist build mkdir build
cd build

echo === Step 2: Configure project with CMake ===
cmake ..
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Step 3: Build project ===
cmake --build .
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Step 4: Run tests ===
ctest --output-on-failure
if %errorlevel% neq 0 exit /b %errorlevel%

echo === Step 5: Verify executable ===
if exist HelloWorld.exe (
    echo ✅ Build successful! Found HelloWorld.exe
) else (
    echo ❌ HelloWorld.exe not found!
    exit /b 1
)

echo === CI completed successfully! ===
exit /b 0
