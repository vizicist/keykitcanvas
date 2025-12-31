@echo off
REM Complete build script for KeyKit WebAssembly
REM This builds everything: manifests, keylib files, WASM, and distribution zip

echo ==========================================
echo KeyKit WebAssembly Complete Build
echo ==========================================

cd /d "%~dp0"

REM Create the distribution (which runs all build steps internally)
python create_dist.py keykitcanvas.zip

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo BUILD FAILED!
    exit /b 1
)

echo.
echo ==========================================
echo Build completed successfully!
echo ==========================================
echo.
echo Output: dist\keykitcanvas.zip
