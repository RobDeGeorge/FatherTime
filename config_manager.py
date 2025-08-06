"""Configuration management for Father Time application."""

import json
from pathlib import Path
from typing import Any, Dict, Optional

from PySide6.QtCore import Property, QObject, Signal

from config import DEFAULT_COLORS, DEFAULT_CONFIG_FILE
from exceptions import ConfigError
from logger import logger


class ConfigManager(QObject):
    """Manages application configuration including color themes."""

    colorsChanged = Signal()

    def __init__(
        self, config_file: Optional[str] = None, data_dir: Optional[str] = None
    ):
        """Initialize configuration manager.

        Args:
            config_file: Name of config file (uses default if None)
            data_dir: Directory for config file (uses current dir if None)
        """
        super().__init__()
        self.data_dir = Path(data_dir) if data_dir else Path.cwd()
        self.config_file = self.data_dir / (config_file or DEFAULT_CONFIG_FILE)

        try:
            self._colors = self._load_colors()
            logger.info(f"Config loaded from {self.config_file}")
        except Exception as e:
            logger.error(f"Failed to load config: {e}")
            self._colors = DEFAULT_COLORS.copy()
            logger.info("Using default colors")

    def _load_colors(self) -> Dict[str, str]:
        """Load color configuration from file.

        Returns:
            Dictionary of color values

        Raises:
            ConfigError: If config cannot be loaded or is invalid
        """
        if not self.config_file.exists():
            logger.info(
                f"Config file {self.config_file} does not exist, creating default"
            )
            self._save_config({"colors": DEFAULT_COLORS})
            return DEFAULT_COLORS.copy()

        try:
            with open(self.config_file, "r", encoding="utf-8") as f:
                config = json.load(f)

            if not isinstance(config, dict):
                raise ConfigError("Config file must contain a JSON object")

            colors = config.get("colors", {})
            if not isinstance(colors, dict):
                logger.warning("Invalid colors section in config, using defaults")
                return DEFAULT_COLORS.copy()

            # Merge with defaults to ensure all required colors exist
            result_colors = DEFAULT_COLORS.copy()
            result_colors.update(colors)

            # Validate color values
            self._validate_colors(result_colors)

            return result_colors

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
            self._colors = self._load_colors()
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

        # Save to file
        config = {"colors": self._colors}
        self._save_config(config)

        # Emit change signal
        self.colorsChanged.emit()
        logger.info(f"Color {key} updated to {value}")
