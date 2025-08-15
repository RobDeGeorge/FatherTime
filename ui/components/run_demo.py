#!/usr/bin/env python3
"""
Popup Menu Demo Runner
Run this script to test the ResponsivePopupMenu component
"""

import sys
import os
from pathlib import Path

# Set Qt platform to xcb to avoid Wayland issues
os.environ['QT_QPA_PLATFORM'] = 'xcb'

# Add project root to path so we can import modules
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

def main():
    """Run the popup menu demo"""
    
    # Create application
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Popup Menu Demo")
    
    # Create QML engine
    engine = QQmlApplicationEngine()
    
    # Get the directory where this script is located
    current_dir = Path(__file__).parent
    
    # Load the demo QML file
    demo_file = current_dir / "PopupMenuDemo.qml"
    
    if not demo_file.exists():
        print(f"Error: Demo file not found at {demo_file}")
        return 1
    
    # Load the QML file
    engine.load(QUrl.fromLocalFile(str(demo_file)))
    
    # Check if loading was successful
    if not engine.rootObjects():
        print("Error: Failed to load QML file")
        return 1
    
    print("Popup Menu Demo is running!")
    print("- Try different window sizes using the buttons")
    print("- Test keyboard navigation (↑/↓, Enter, Escape)")
    print("- Click outside menus to close them")
    print("- Press Ctrl+C to quit")
    
    # Run the application
    return app.exec()

if __name__ == "__main__":
    sys.exit(main())