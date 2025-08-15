#!/usr/bin/env python3
"""
Simple Popup Menu Demo Runner
A working demo that avoids complex QML issues
"""

import sys
import os
from pathlib import Path

# Set Qt platform and rendering options to avoid issues
os.environ['QT_QPA_PLATFORM'] = 'xcb'
os.environ['QT_QUICK_BACKEND'] = 'software'
os.environ['QT_OPENGL'] = 'software'

# Add project root to path
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

def main():
    """Run the simple popup menu demo"""
    
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Simple Popup Menu Demo")
    
    engine = QQmlApplicationEngine()
    
    # Get the directory where this script is located
    current_dir = Path(__file__).parent
    demo_file = current_dir / "SimpleDemo.qml"
    
    if not demo_file.exists():
        print(f"Error: Demo file not found at {demo_file}")
        return 1
    
    # Load the QML file
    engine.load(QUrl.fromLocalFile(str(demo_file)))
    
    if not engine.rootObjects():
        print("Error: Failed to load QML file")
        return 1
    
    print("Simple Popup Menu Demo is running!")
    print("- Click the menu buttons to test functionality")
    print("- Try resizing the window to see responsive behavior")
    print("- Use Escape or click outside to close menus")
    print("- Press Ctrl+C to quit")
    
    return app.exec()

if __name__ == "__main__":
    sys.exit(main())