#!/usr/bin/env python3
"""Simple build script for Windows without spec file."""

import os
import shutil
import subprocess
import sys
from pathlib import Path


def clean_build_dirs():
    """Clean previous build artifacts."""
    dirs_to_clean = ["build", "dist", "__pycache__"]
    for dir_name in dirs_to_clean:
        if os.path.exists(dir_name):
            print(f"Cleaning {dir_name}/")
            shutil.rmtree(dir_name)


def build_simple():
    """Build executable using direct PyInstaller command."""
    print("Building FatherTime executable (simple method)...")
    
    # Ensure data directory exists
    Path("data").mkdir(exist_ok=True)
    
    # Basic PyInstaller command
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--onefile",
        "--windowed",
        "--name=FatherTime",
        "--add-data=ui;ui",
        "--add-data=data;data", 
        "--add-data=src/config;src/config",
        "--hidden-import=PySide6.QtCore",
        "--hidden-import=PySide6.QtGui",
        "--hidden-import=PySide6.QtQml",
        "--hidden-import=PySide6.QtQuick",
        "--hidden-import=PySide6.QtQuickControls2",
        "--hidden-import=src.fathertime.config",
        "--hidden-import=src.fathertime.config_manager", 
        "--hidden-import=src.fathertime.database",
        "--hidden-import=src.fathertime.exceptions",
        "--hidden-import=src.fathertime.logger",
        "--hidden-import=src.fathertime.timer_manager",
        "--clean",
        "--noconfirm",
        "main.py"
    ]
    
    print("Running PyInstaller...")
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✅ Build successful!")
        print("📁 Executable created in dist/")
        if os.path.exists("dist/FatherTime.exe"):
            print("🎉 Windows executable: dist/FatherTime.exe")
        elif os.path.exists("dist/FatherTime"):
            print("🎉 Executable: dist/FatherTime")
        return True
    else:
        print("❌ Build failed!")
        print("STDOUT:", result.stdout)
        print("STDERR:", result.stderr)
        return False


def main():
    """Main build process."""
    print("🔨 Starting simple FatherTime build...")
    
    # Check PyInstaller
    try:
        import PyInstaller
        print(f"✅ PyInstaller {PyInstaller.__version__} found")
    except ImportError:
        print("❌ Installing PyInstaller...")
        subprocess.run([sys.executable, "-m", "pip", "install", "pyinstaller>=5.0.0"])
    
    clean_build_dirs()
    
    if build_simple():
        print("\n🎊 Build completed successfully!")
    else:
        print("\n💥 Build failed!")
        sys.exit(1)


if __name__ == "__main__":
    main()