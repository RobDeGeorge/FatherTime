"""Configuration constants and settings for Father Time application."""

import os
import sys
from typing import Dict

# Application constants
APP_NAME = "Father Time"
DEFAULT_WINDOW_WIDTH = 800
DEFAULT_WINDOW_HEIGHT = 600

# File paths (relative to project root)
DEFAULT_DB_FILE = "data/timers.json"
DEFAULT_SESSIONS_FILE = "data/sessions.json"
DEFAULT_STATS_FILE = "data/stats.json"
DEFAULT_CONFIG_FILE = "src/config/config.json"
ARCHIVE_DIRECTORY = "data/archive"

# Timer update intervals (milliseconds)
TIMER_UPDATE_INTERVAL = 1000  # 1 second
DAY_CHECK_INTERVAL = 60000  # 1 minute
BREAKDOWN_UPDATE_INTERVAL = 5000  # 5 seconds
BATCH_SAVE_INTERVAL = 10000  # 10 seconds

# Archive settings
ARCHIVE_DAYS_THRESHOLD = 14  # Archive data older than 2 weeks

# Qt environment settings - platform specific
def get_qt_environment() -> Dict[str, str]:
    """Get Qt environment settings based on the current platform."""
    if sys.platform.startswith('win'):
        # Windows settings
        return {
            "QT_QPA_PLATFORM": "windows",
            "QT_QUICK_BACKEND": "software",
            "QSG_RHI_BACKEND": "software",
        }
    elif sys.platform.startswith('darwin'):
        # macOS settings
        return {
            "QT_QPA_PLATFORM": "cocoa",
            "QT_QUICK_BACKEND": "software", 
            "QSG_RHI_BACKEND": "software",
        }
    else:
        # Linux/Unix settings
        return {
            "QT_QPA_PLATFORM": "xcb",
            "QT_QUICK_BACKEND": "software",
            "QSG_RHI_BACKEND": "software",
        }

# Default Qt environment for backwards compatibility
QT_ENVIRONMENT: Dict[str, str] = get_qt_environment()

# Default color scheme
DEFAULT_COLORS: Dict[str, str] = {
    "primary": "#2c3e50",
    "secondary": "#34495e",
    "accent": "#3498db",
    "success": "#27ae60",
    "danger": "#e74c3c",
    "warning": "#f39c12",
    "background": "#ecf0f1",
    "text": "#2c3e50",
    "cardBackground": "#ffffff",
    "cardBorder": "#e0e0e0",
}


def get_data_dir() -> str:
    """Get the application data directory."""
    return os.path.expanduser("~/.fathertime")


def ensure_data_dir() -> str:
    """Ensure the data directory exists and return its path."""
    data_dir = get_data_dir()
    os.makedirs(data_dir, exist_ok=True)
    return data_dir
