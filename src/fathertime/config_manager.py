"""Configuration management for Father Time application."""

import json
import os
from pathlib import Path
from typing import Any, Dict, Optional

from PySide6.QtCore import Property, QObject, Signal, Slot

from .config import DEFAULT_COLORS, DEFAULT_CONFIG_FILE
from .exceptions import ConfigError
from .logger import logger


class ConfigManager(QObject):
    """Manages application configuration including color themes."""

    colorsChanged = Signal()
    timeRoundingChanged = Signal()
    calendarViewChanged = Signal()
    windowSizeChanged = Signal()

    def __init__(
        self, config_file: Optional[str] = None, data_dir: Optional[str] = None
    ):
        """Initialize configuration manager.

        Args:
            config_file: Name of config file (uses default if None)
            data_dir: Directory for config file (uses current dir if None)
            
        Raises:
            ConfigError: If paths contain invalid or dangerous components
        """
        super().__init__()
        self.data_dir = self._validate_and_resolve_path(data_dir)
        self.config_file = self._validate_config_file_path(
            config_file or DEFAULT_CONFIG_FILE
        )

        try:
            self._config_data = self._load_config()
            self._colors = self._config_data.get("colors", DEFAULT_COLORS.copy())
            self._calendar_view = self._config_data.get("calendar_view", "month")
            self._window_width = self._config_data.get("window_width", 1200)
            self._window_height = self._config_data.get("window_height", 700)
            logger.info(f"Config loaded from {self.config_file}")
        except Exception as e:
            logger.error(f"Failed to load config: {e}")
            self._config_data = {
                "colors": DEFAULT_COLORS.copy(), 
                "calendar_view": "month",
                "window_width": 1200,
                "window_height": 700
            }
            self._colors = DEFAULT_COLORS.copy()
            self._calendar_view = "month"
            self._window_width = 1200
            self._window_height = 700
            logger.info("Using default colors, calendar view, and window size")

    def _validate_and_resolve_path(self, data_dir: Optional[str]) -> Path:
        """Validate and resolve data directory path securely.
        
        Args:
            data_dir: User-provided directory path
            
        Returns:
            Validated and resolved Path object
            
        Raises:
            ConfigError: If path is invalid or contains dangerous components
        """
        if data_dir is None:
            return Path.cwd()
            
        # Convert to Path and resolve to handle relative paths
        try:
            path = Path(data_dir).resolve()
        except (OSError, ValueError) as e:
            raise ConfigError(f"Invalid directory path '{data_dir}': {e}") from e
            
        # Security checks
        path_str = str(path)
        
        # Check for path traversal attempts
        dangerous_components = ['..', '~', '$']
        if any(component in data_dir for component in dangerous_components):
            raise ConfigError(
                f"Directory path '{data_dir}' contains dangerous components"
            )
            
        # Ensure path is not pointing to sensitive system directories
        sensitive_paths = ['/etc', '/root', '/var/log', '/usr', '/bin', '/sbin']
        if any(path_str.startswith(sensitive) for sensitive in sensitive_paths):
            raise ConfigError(
                f"Directory path '{data_dir}' points to restricted system directory"
            )
            
        # Ensure path length is reasonable
        if len(path_str) > 255:
            raise ConfigError(f"Directory path too long: {len(path_str)} characters")
            
        return path
        
    def _validate_config_file_path(self, config_file: str) -> Path:
        """Validate config file name securely.
        
        Args:
            config_file: Config file name or relative path
            
        Returns:
            Validated config file Path object
            
        Raises:
            ConfigError: If filename is invalid or dangerous
        """
        if not config_file:
            raise ConfigError("Config file name cannot be empty")
            
        # Security checks for filename - allow forward slashes for relative paths but block dangerous patterns
        dangerous_patterns = ['..', '~', '$', '|', ';', '&', '\\']
        if any(pattern in config_file for pattern in dangerous_patterns):
            raise ConfigError(
                f"Config file name '{config_file}' contains invalid characters"
            )
            
        # Block absolute paths (starting with /)
        if config_file.startswith('/'):
            raise ConfigError(
                f"Config file name '{config_file}' cannot be an absolute path"
            )
            
        # Check file extension
        allowed_extensions = ['.json', '.conf', '.cfg']
        if not any(config_file.endswith(ext) for ext in allowed_extensions):
            config_file += '.json'  # Default to JSON if no extension
            
        # Ensure filename length is reasonable
        if len(config_file) > 100:
            raise ConfigError(f"Config file name too long: {len(config_file)} characters")
            
        return self.data_dir / config_file

    def _load_config(self) -> Dict[str, Any]:
        """Load full configuration from file.

        Returns:
            Dictionary of config values

        Raises:
            ConfigError: If config cannot be loaded or is invalid
        """
        default_config = {"colors": DEFAULT_COLORS}
        
        if not self.config_file.exists():
            logger.info(
                f"Config file {self.config_file} does not exist, creating default"
            )
            self._save_config(default_config)
            return default_config

        try:
            with open(self.config_file, "r", encoding="utf-8") as f:
                config = json.load(f)

            if not isinstance(config, dict):
                raise ConfigError("Config file must contain a JSON object")

            colors = config.get("colors", {})
            if not isinstance(colors, dict):
                logger.warning("Invalid colors section in config, using defaults")
                colors = DEFAULT_COLORS.copy()
            else:
                # Merge with defaults to ensure all required colors exist
                merged_colors = DEFAULT_COLORS.copy()
                merged_colors.update(colors)
                colors = merged_colors

            # Validate color values
            self._validate_colors(colors)
            config["colors"] = colors

            return config

        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON in config file: {e}")
            raise ConfigError(f"Invalid JSON in config file: {e}") from e
        except IOError as e:
            logger.error(f"Cannot read config file: {e}")
            raise ConfigError(f"Cannot read config file: {e}") from e

    def _save_config(self, config: Dict[str, Any]) -> None:
        """Save configuration to file.

        Args:
            config: Configuration dictionary to save

        Raises:
            ConfigError: If config cannot be saved
        """
        try:
            self.config_file.parent.mkdir(parents=True, exist_ok=True)
            with open(self.config_file, "w", encoding="utf-8") as f:
                json.dump(config, f, indent=2, ensure_ascii=False)
            
            # Set secure file permissions (owner read/write only)
            self.config_file.chmod(0o600)
            logger.debug(f"Config saved to {self.config_file}")
        except IOError as e:
            logger.error(f"Error saving config: {e}")
            raise ConfigError(f"Cannot save config: {e}") from e

    def _validate_colors(self, colors: Dict[str, str]) -> None:
        """Validate color values are valid hex colors.

        Args:
            colors: Dictionary of color values to validate

        Raises:
            ConfigError: If any color value is invalid
        """
        for key, value in colors.items():
            if not isinstance(value, str):
                raise ConfigError(f"Color {key} must be a string, got {type(value)}")
            if not value.startswith("#") or len(value) != 7:
                raise ConfigError(
                    f"Color {key} must be a valid hex color "
                    f"(e.g., #ff0000), got {value}"
                )
            try:
                int(value[1:], 16)
            except ValueError:
                raise ConfigError(
                    f"Color {key} contains invalid hex characters: {value}"
                )

    @Property(str, notify=colorsChanged)
    def primary(self) -> str:
        """Get primary color."""
        return self._colors.get("primary", DEFAULT_COLORS["primary"])

    @Property(str, notify=colorsChanged)
    def secondary(self) -> str:
        """Get secondary color."""
        return self._colors.get("secondary", DEFAULT_COLORS["secondary"])

    @Property(str, notify=colorsChanged)
    def accent(self) -> str:
        """Get accent color."""
        return self._colors.get("accent", DEFAULT_COLORS["accent"])

    @Property(str, notify=colorsChanged)
    def success(self) -> str:
        """Get success color."""
        return self._colors.get("success", DEFAULT_COLORS["success"])

    @Property(str, notify=colorsChanged)
    def danger(self) -> str:
        """Get danger color."""
        return self._colors.get("danger", DEFAULT_COLORS["danger"])

    @Property(str, notify=colorsChanged)
    def warning(self) -> str:
        """Get warning color."""
        return self._colors.get("warning", DEFAULT_COLORS["warning"])

    @Property(str, notify=colorsChanged)
    def background(self) -> str:
        """Get background color."""
        return self._colors.get("background", DEFAULT_COLORS["background"])

    @Property(str, notify=colorsChanged)
    def text(self) -> str:
        """Get text color."""
        return self._colors.get("text", DEFAULT_COLORS["text"])

    @Property(str, notify=colorsChanged)
    def cardBackground(self) -> str:
        """Get card background color."""
        return self._colors.get("cardBackground", DEFAULT_COLORS["cardBackground"])

    @Property(str, notify=colorsChanged)
    def cardBorder(self) -> str:
        """Get card border color."""
        return self._colors.get("cardBorder", DEFAULT_COLORS["cardBorder"])

    def reload_colors(self) -> None:
        """Reload colors from config file and emit change signal."""
        try:
            self._config_data = self._load_config()
            self._colors = self._config_data.get("colors", DEFAULT_COLORS.copy())
            self.colorsChanged.emit()
            logger.info("Colors reloaded successfully")
        except ConfigError as e:
            logger.error(f"Failed to reload colors: {e}")
            # Keep existing colors on failure

    def update_color(self, key: str, value: str) -> None:
        """Update a single color value and save to file.

        Args:
            key: Color key to update
            value: New color value (hex format)

        Raises:
            ConfigError: If color key or value is invalid
        """
        if key not in DEFAULT_COLORS:
            raise ConfigError(f"Unknown color key: {key}")

        # Validate single color
        temp_colors = {key: value}
        self._validate_colors(temp_colors)

        # Update colors
        self._colors[key] = value
        self._config_data["colors"] = self._colors

        # Save to file
        self._save_config(self._config_data)

        # Emit change signal
        self.colorsChanged.emit()
        logger.info(f"Color {key} updated to {value}")

    def get_value(self, key: str, default: Any = None) -> Any:
        """Get a configuration value.

        Args:
            key: Configuration key (can use dot notation like "colors.primary")
            default: Default value if key not found

        Returns:
            Configuration value or default
        """
        keys = key.split(".")
        value = self._config_data
        
        try:
            for k in keys:
                value = value[k]
            return value
        except (KeyError, TypeError):
            return default

    def set_value(self, key: str, value: Any) -> None:
        """Set a configuration value.

        Args:
            key: Configuration key (can use dot notation like "colors.primary")
            value: Value to set
        """
        keys = key.split(".")
        config = self._config_data
        
        # Navigate to parent of the key to set
        for k in keys[:-1]:
            if k not in config:
                config[k] = {}
            config = config[k]
        
        # Set the value
        config[keys[-1]] = value
        
        # If we're updating colors, also update the local colors dict
        if keys[0] == "colors" and len(keys) == 2:
            self._colors[keys[1]] = value
        
        # Save to file
        self._save_config(self._config_data)
        
        # Emit change signal if colors were updated
        if keys[0] == "colors":
            self.colorsChanged.emit()

    @Property(bool, notify=timeRoundingChanged)
    def timeRoundingEnabled(self) -> bool:
        """Get whether time rounding is enabled."""
        return self.get_value("timeRounding.enabled", True)
    
    @Property(int, notify=timeRoundingChanged)
    def timeRoundingMinutes(self) -> int:
        """Get time rounding interval in minutes (15=quarter hours, 30=half hours, 60=full hours)."""
        return self.get_value("timeRounding.roundingMinutes", 15)
    
    @Slot(bool)
    def setTimeRoundingEnabled(self, enabled: bool) -> None:
        """Set whether time rounding is enabled."""
        logger.info(f"Setting time rounding enabled: {enabled}")
        self.set_value("timeRounding.enabled", enabled)
        self.timeRoundingChanged.emit()
    
    @Slot(int)
    def setTimeRoundingMinutes(self, minutes: int) -> None:
        """Set time rounding interval in minutes."""
        logger.info(f"Setting time rounding minutes: {minutes}")
        if minutes not in [15, 30, 60]:
            raise ConfigError(f"Invalid rounding minutes: {minutes}. Must be 15, 30, or 60")
        self.set_value("timeRounding.roundingMinutes", minutes)
        self.timeRoundingChanged.emit()

    @Property(str, notify=calendarViewChanged)
    def calendarView(self) -> str:
        """Get current calendar view mode (month or week)."""
        return self._calendar_view
    
    @Slot(str)
    def setCalendarView(self, view: str) -> None:
        """Set calendar view mode."""
        if view not in ["month", "week"]:
            raise ConfigError(f"Invalid calendar view: {view}. Must be 'month' or 'week'")
        
        logger.info(f"Setting calendar view: {view}")
        self._calendar_view = view
        self._config_data["calendar_view"] = view
        self._save_config(self._config_data)
        self.calendarViewChanged.emit()
    
    @Slot()
    def toggleCalendarView(self) -> None:
        """Toggle between month and week calendar view."""
        new_view = "week" if self._calendar_view == "month" else "month"
        self.setCalendarView(new_view)
        logger.info(f"Toggled calendar view to: {new_view}")

    @Property(int, notify=windowSizeChanged)
    def windowWidth(self) -> int:
        """Get default window width."""
        return self._window_width
    
    @Property(int, notify=windowSizeChanged)
    def windowHeight(self) -> int:
        """Get default window height."""
        return self._window_height
    
    @Slot(int)
    def setWindowWidth(self, width: int) -> None:
        """Set default window width."""
        if width < 800 or width > 3840:
            raise ConfigError(f"Invalid window width: {width}. Must be between 800 and 3840")
        
        logger.info(f"Setting window width: {width}")
        self._window_width = width
        self._config_data["window_width"] = width
        self._save_config(self._config_data)
        self.windowSizeChanged.emit()
    
    @Slot(int)
    def setWindowHeight(self, height: int) -> None:
        """Set default window height."""
        if height < 600 or height > 2160:
            raise ConfigError(f"Invalid window height: {height}. Must be between 600 and 2160")
        
        logger.info(f"Setting window height: {height}")
        self._window_height = height
        self._config_data["window_height"] = height
        self._save_config(self._config_data)
        self.windowSizeChanged.emit()
