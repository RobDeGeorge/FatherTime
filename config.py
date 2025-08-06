"""Configuration constants and settings for Father Time application."""

import os
from typing import Dict

# Application constants
APP_NAME = "Father Time"
DEFAULT_WINDOW_WIDTH = 800
DEFAULT_WINDOW_HEIGHT = 600

# File paths
DEFAULT_DB_FILE = "timers.json"
DEFAULT_SESSIONS_FILE = "sessions.json"
DEFAULT_STATS_FILE = "stats.json"
DEFAULT_CONFIG_FILE = "config.json"
ARCHIVE_DIRECTORY = "archive"

# Timer update intervals (milliseconds)
TIMER_UPDATE_INTERVAL = 1000  # 1 second
DAY_CHECK_INTERVAL = 60000  # 1 minute
BREAKDOWN_UPDATE_INTERVAL = 5000  # 5 seconds
BATCH_SAVE_INTERVAL = 10000  # 10 seconds

# Archive settings
ARCHIVE_DAYS_THRESHOLD = 14  # Archive data older than 2 weeks

# Qt environment settings
QT_ENVIRONMENT: Dict[str, str] = {
    "QT_QPA_PLATFORM": "xcb",
    "QT_QUICK_BACKEND": "software",
    "QSG_RHI_BACKEND": "software",
}

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
