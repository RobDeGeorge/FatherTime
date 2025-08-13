#!/usr/bin/env python3
"""Main entry point for Father Time application."""

import os
import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

from src.fathertime.config import APP_NAME, QT_ENVIRONMENT
from src.fathertime.config_manager import ConfigManager
from src.fathertime.exceptions import FatherTimeError
from src.fathertime.logger import logger
from src.fathertime.timer_manager import TimerManager
from src.fathertime.theme_manager import ThemeManager


def setup_qt_environment() -> None:
    """Configure Qt environment variables."""
    for key, value in QT_ENVIRONMENT.items():
        os.environ[key] = value
        logger.debug(f"Set {key}={value}")


def create_application() -> QGuiApplication:
    """Create and configure Qt application."""
    app = QGuiApplication(sys.argv)
    QQuickStyle.setStyle("Basic")
    app.setApplicationName(APP_NAME)
    return app


def load_qml(engine: QQmlApplicationEngine) -> bool:
    """Load QML file and return success status."""
    qml_file = Path(__file__).parent / "ui" / "main.qml"
    if not qml_file.exists():
        logger.error(f"QML file not found: {qml_file}")
        return False

    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        logger.error("Failed to load QML file - no root objects created")
        return False

    logger.info("QML loaded successfully")
    return True


def main() -> int:
    """Main application entry point."""
    try:
        logger.info(f"Starting {APP_NAME}")

        # Setup Qt environment
        setup_qt_environment()

        # Create Qt application
        app = create_application()

        # Create QML engine and managers
        engine = QQmlApplicationEngine()

        try:
            timer_manager = TimerManager()
            config_manager = ConfigManager()
            theme_manager = ThemeManager(config_manager)
            theme_manager.initialize_theme()
        except FatherTimeError as e:
            logger.error(f"Failed to initialize managers: {e}")
            return 1

        # Set context properties
        engine.rootContext().setContextProperty("timerManager", timer_manager)
        engine.rootContext().setContextProperty("configManager", config_manager)
        engine.rootContext().setContextProperty("themeManager", theme_manager)

        # Load QML
        if not load_qml(engine):
            return 1

        logger.info("Application initialized successfully")
        return app.exec()

    except Exception as e:
        logger.error(f"Unexpected error in main: {e}", exc_info=True)
        return 1


if __name__ == "__main__":
    try:
        exit_code = main()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        logger.info("Application interrupted by user")
        sys.exit(0)
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)
