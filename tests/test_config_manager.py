"""Tests for config_manager module."""

import json
import tempfile
from pathlib import Path

import pytest

from config import DEFAULT_COLORS
from config_manager import ConfigManager
from exceptions import ConfigError


class TestConfigManager:
    """Test cases for ConfigManager class."""

    def setup_method(self):
        """Set up test fixtures."""
        self.temp_dir = Path(tempfile.mkdtemp())

    def teardown_method(self):
        """Clean up test fixtures."""
        import shutil

        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_initialization_no_config_file(self):
        """Test initialization when no config file exists."""
        config_manager = ConfigManager(data_dir=str(self.temp_dir))

        # Should create default config
        assert (self.temp_dir / "config.json").exists()

        # Should have all default colors
        for key, expected_value in DEFAULT_COLORS.items():
            actual_value = getattr(config_manager, key)
            assert actual_value == expected_value

    def test_initialization_with_existing_config(self):
        """Test initialization with existing config file."""
        config_file = self.temp_dir / "config.json"
        test_colors = DEFAULT_COLORS.copy()
        test_colors["primary"] = "#ff0000"

        config_file.write_text(json.dumps({"colors": test_colors}, indent=2))

        config_manager = ConfigManager(data_dir=str(self.temp_dir))
        assert config_manager.primary == "#ff0000"

    def test_color_validation(self):
        """Test color value validation."""
        config_manager = ConfigManager(data_dir=str(self.temp_dir))

        # Valid color should work
        config_manager.update_color("primary", "#ff0000")
        assert config_manager.primary == "#ff0000"

        # Invalid colors should raise errors
        with pytest.raises(ConfigError):
            config_manager.update_color("primary", "invalid")

        with pytest.raises(ConfigError):
            config_manager.update_color("primary", "#xyz")

        with pytest.raises(ConfigError):
            config_manager.update_color("primary", "#ff00")  # Too short

    def test_unknown_color_key(self):
        """Test updating unknown color key."""
        config_manager = ConfigManager(data_dir=str(self.temp_dir))

        with pytest.raises(ConfigError):
            config_manager.update_color("unknown_key", "#ff0000")

    def test_config_persistence(self):
        """Test that config changes persist."""
        config_manager = ConfigManager(data_dir=str(self.temp_dir))
        config_manager.update_color("accent", "#00ff00")

        # Create new instance - should load saved config
        config_manager2 = ConfigManager(data_dir=str(self.temp_dir))
        assert config_manager2.accent == "#00ff00"

    def test_corrupt_config_file(self):
        """Test handling of corrupt config file."""
        config_file = self.temp_dir / "config.json"
        config_file.write_text("invalid json")

        # Should fall back to defaults
        config_manager = ConfigManager(data_dir=str(self.temp_dir))
        assert config_manager.primary == DEFAULT_COLORS["primary"]

    def test_invalid_config_structure(self):
        """Test handling of invalid config structure."""
        config_file = self.temp_dir / "config.json"

        # Non-dict colors section
        config_file.write_text('{"colors": "invalid"}')
        config_manager = ConfigManager(data_dir=str(self.temp_dir))
        assert config_manager.primary == DEFAULT_COLORS["primary"]

        # Missing colors section
        config_file.write_text('{"other": "data"}')
        config_manager2 = ConfigManager(data_dir=str(self.temp_dir))
        assert config_manager2.primary == DEFAULT_COLORS["primary"]


# Note: Testing Qt Properties and Signals would require a Qt application instance
# These tests focus on the core functionality without Qt dependencies
