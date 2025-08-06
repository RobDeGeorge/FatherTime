@echo off
REM Build script for Windows

echo 🔨 Building FatherTime for Windows...

REM Check if virtual environment exists
if not exist "venv" (
    echo ❌ Virtual environment not found!
    echo Please run: python -m venv venv
    echo Then: venv\Scripts\activate
    echo Then: pip install -r requirements.txt
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install/update PyInstaller
echo Installing PyInstaller...
pip install pyinstaller>=5.0.0

REM Try the main build script first
echo.
echo 🔧 Trying main build script...
python build.py

REM If that fails, try the simple build
if %ERRORLEVEL% neq 0 (
    echo.
    echo ⚠️ Main build failed, trying simple build method...
    python build-simple.py
)

REM Check if executable was created
if exist "dist\FatherTime.exe" (
    echo.
    echo ✅ SUCCESS! Executable created: dist\FatherTime.exe
    echo 📁 File size:
    dir dist\FatherTime.exe | findstr FatherTime.exe
) else (
    echo.
    echo ❌ Build failed! No executable found in dist/
)

echo.
echo Build process completed!
echo Check the dist/ directory for your executable.
echo.

pause