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


def create_windows_spec():
    """Create Windows-specific spec file if it doesn't exist."""
    spec_content = '''# -*- mode: python ; coding: utf-8 -*-

import os
from pathlib import Path

# Get project root directory (current working directory when PyInstaller runs)
project_root = Path('.')

block_cipher = None

a = Analysis(
    ['main.py'],
    pathex=[str(project_root)],
    binaries=[],
    datas=[
        # Include QML files
        ('ui/*.qml', 'ui'),
        # Include data directory structure (but not actual data files - they'll be created at runtime)
        ('data', 'data'),
        # Include configuration files
        ('src/config', 'src/config'),
    ],
    hiddenimports=[
        # PySide6 core modules
        'PySide6.QtCore',
        'PySide6.QtGui', 
        'PySide6.QtQml',
        'PySide6.QtQuick',
        'PySide6.QtQuickControls2',
        # Windows-specific Qt platform plugins
        'PySide6.plugins.platforms.qwindows',
        'PySide6.plugins.platforms.qminimal',
        # Application modules
        'src.fathertime.config',
        'src.fathertime.config_manager',
        'src.fathertime.database',
        'src.fathertime.exceptions',
        'src.fathertime.logger',
        'src.fathertime.timer_manager',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        'tkinter',
        'matplotlib',
        'numpy',
        'pandas',
        'scipy',
        'PIL',
        'jupyter',
        'IPython',
        'test',
        'tests',
        # Exclude Linux-specific Qt plugins
        'PySide6.plugins.platforms.qxcb',
        'PySide6.plugins.platforms.qcocoa',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='FatherTime',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,  # Set to True for debugging
    disable_windowed_traceback=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,  # Add path to .ico file if you have one
    version=None,
)
'''
    
    with open("build-windows.spec", "w") as f:
        f.write(spec_content)
    print("✅ Created build-windows.spec")


def build_executable():
    """Build the executable using PyInstaller."""
    print("Building FatherTime executable...")
    
    # Ensure data directory exists (PyInstaller needs it to exist)
    Path("data").mkdir(exist_ok=True)
    
    # Choose the right spec file based on platform
    if sys.platform.startswith('win'):
        spec_file = "build-windows.spec"
        print("🪟 Using Windows-optimized build configuration")
        # Create Windows spec if it doesn't exist
        if not os.path.exists(spec_file):
            print(f"Creating missing {spec_file}...")
            create_windows_spec()
    else:
        spec_file = "build.spec"
        print("🐧 Using cross-platform build configuration")
    
    # Check if spec file exists
    if not os.path.exists(spec_file):
        print(f"❌ Spec file {spec_file} not found!")
        print("Available spec files:")
        for f in os.listdir("."):
            if f.endswith(".spec"):
                print(f"  - {f}")
        return False
    
    # Run PyInstaller with absolute path to spec file
    spec_path = os.path.abspath(spec_file)
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--clean",
        "--noconfirm", 
        spec_path
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