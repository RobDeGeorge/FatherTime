@echo off
REM Build script for Windows

echo 🔨 Building FatherTime for Windows...

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Try the main build script first
echo Trying main build script...
python build.py

REM If that fails, try the simple build
if %ERRORLEVEL% neq 0 (
    echo Main build failed, trying simple build...
    python build-simple.py
)

echo.
echo Build process completed!
echo Check the dist/ directory for your executable.

pause