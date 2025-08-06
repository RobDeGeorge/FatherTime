#!/usr/bin/env python3
"""Build script for creating FatherTime executable."""

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
    
    # Clean .pyc files
    for root, dirs, files in os.walk("."):
        for file in files:
            if file.endswith(".pyc"):
                os.remove(os.path.join(root, file))


def build_executable():
    """Build the executable using PyInstaller."""
    print("Building FatherTime executable...")
    
    # Ensure data directory exists (PyInstaller needs it to exist)
    Path("data").mkdir(exist_ok=True)
    
    # Run PyInstaller
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--clean",
        "--noconfirm", 
        "build.spec"
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✅ Build successful!")
        print("📁 Executable created in dist/")
        if os.path.exists("dist/FatherTime.exe"):
            print("🎉 Windows executable: dist/FatherTime.exe")
        elif os.path.exists("dist/FatherTime"):
            print("🎉 Executable: dist/FatherTime")
    else:
        print("❌ Build failed!")
        print("STDOUT:", result.stdout)
        print("STDERR:", result.stderr)
        return False
    
    return True


def main():
    """Main build process."""
    print("🔨 Starting FatherTime build process...")
    
    # Check if PyInstaller is available
    try:
        import PyInstaller
        print(f"✅ PyInstaller {PyInstaller.__version__} found")
    except ImportError:
        print("❌ PyInstaller not found. Installing...")
        subprocess.run([sys.executable, "-m", "pip", "install", "pyinstaller>=5.0.0"])
    
    # Clean previous builds
    clean_build_dirs()
    
    # Build executable
    if build_executable():
        print("\n🎊 Build completed successfully!")
        print("📦 You can find your executable in the dist/ directory")
    else:
        print("\n💥 Build failed!")
        sys.exit(1)


if __name__ == "__main__":
    main()