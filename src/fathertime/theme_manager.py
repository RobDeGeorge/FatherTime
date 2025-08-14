"""Theme management for Father Time application."""

from PySide6.QtCore import QObject, Signal, Slot, Property
from .logger import logger
import json
import os


class ThemeManager(QObject):
    """Manages application themes with cycling functionality"""
    
    themeChanged = Signal()
    
    def __init__(self, config_manager):
        super().__init__()
        self.config_manager = config_manager
        self._current_theme = "default"
        
    def get_builtin_themes(self):
        """Get predefined themes optimized for Father Time"""
        return {
            "default": {
                "name": "Default",
                "primary": "#2c3e50",
                "secondary": "#34495e", 
                "accent": "#3498db",
                "success": "#27ae60",
                "danger": "#e74c3c",
                "warning": "#f39c12",
                "background": "#ecf0f1",
                "text": "#2c3e50",
                "cardBackground": "#ffffff",
                "cardBorder": "#e0e0e0"
            },
            "dracula": {
                "name": "Dracula",
                "primary": "#bd93f9",
                "secondary": "#6272a4",
                "accent": "#8be9fd",
                "success": "#50fa7b",
                "danger": "#ff5555",
                "warning": "#f1fa8c",
                "background": "#282a36",
                "text": "#f8f8f2",
                "cardBackground": "#44475a",
                "cardBorder": "#6272a4"
            },
            "nightOwl": {
                "name": "Night Owl",
                "primary": "#c792ea",
                "secondary": "#7fdbca",
                "accent": "#82aaff",
                "success": "#addb67",
                "danger": "#ef5350",
                "warning": "#ffcb6b",
                "background": "#011627",
                "text": "#d6deeb",
                "cardBackground": "#1d3b53",
                "cardBorder": "#5f7a95"
            },
            "githubDark": {
                "name": "GitHub Dark",
                "primary": "#58a6ff",
                "secondary": "#7d8590",
                "accent": "#79c0ff",
                "success": "#56d364",
                "danger": "#f85149",
                "warning": "#d29922",
                "background": "#0d1117",
                "text": "#f0f6fc",
                "cardBackground": "#21262d",
                "cardBorder": "#30363d"
            },
            "catppuccin": {
                "name": "Catppuccin",
                "primary": "#cba6f7",
                "secondary": "#f9e2af",
                "accent": "#89b4fa",
                "success": "#a6e3a1",
                "danger": "#f38ba8",
                "warning": "#fab387",
                "background": "#1e1e2e",
                "text": "#cdd6f4",
                "cardBackground": "#313244",
                "cardBorder": "#45475a"
            },
            "tokyoNight": {
                "name": "Tokyo Night",
                "primary": "#7aa2f7",
                "secondary": "#9ece6a",
                "accent": "#bb9af7",
                "success": "#9ece6a",
                "danger": "#f7768e",
                "warning": "#e0af68",
                "background": "#1a1b26",
                "text": "#c0caf5",
                "cardBackground": "#24283b",
                "cardBorder": "#414868"
            },
            "gruvboxDark": {
                "name": "Gruvbox Dark",
                "primary": "#83a598",
                "secondary": "#fe8019",
                "accent": "#8ec07c",
                "success": "#b8bb26",
                "danger": "#fb4934",
                "warning": "#fabd2f",
                "background": "#282828",
                "text": "#ebdbb2",
                "cardBackground": "#3c3836",
                "cardBorder": "#665c54"
            },
            "nordDark": {
                "name": "Nord Dark",
                "primary": "#88c0d0",
                "secondary": "#d08770",
                "accent": "#81a1c1",
                "success": "#a3be8c",
                "danger": "#bf616a",
                "warning": "#ebcb8b",
                "background": "#2e3440",
                "text": "#eceff4",
                "cardBackground": "#3b4252",
                "cardBorder": "#4c566a"
            },
            "oneDark": {
                "name": "One Dark",
                "primary": "#61afef",
                "secondary": "#e06c75",
                "accent": "#56b6c2",
                "success": "#98c379",
                "danger": "#e06c75",
                "warning": "#e5c07b",
                "background": "#1e2127",
                "text": "#abb2bf",
                "cardBackground": "#2c323c",
                "cardBorder": "#3e4451"
            },
            "solarizedLight": {
                "name": "Solarized Light",
                "primary": "#268bd2",
                "secondary": "#93a1a1",
                "accent": "#2aa198",
                "success": "#859900",
                "danger": "#dc322f",
                "warning": "#b58900",
                "background": "#fdf6e3",
                "text": "#586e75",
                "cardBackground": "#eee8d5",
                "cardBorder": "#93a1a1"
            },
            "solarizedDark": {
                "name": "Solarized Dark",
                "primary": "#268bd2",
                "secondary": "#586e75",
                "accent": "#2aa198",
                "success": "#859900",
                "danger": "#dc322f",
                "warning": "#b58900",
                "background": "#002b36",
                "text": "#839496",
                "cardBackground": "#073642",
                "cardBorder": "#586e75"
            },
            "materialLight": {
                "name": "Material Light",
                "primary": "#1976d2",
                "secondary": "#424242",
                "accent": "#03dac6",
                "success": "#4caf50",
                "danger": "#f44336",
                "warning": "#ff9800",
                "background": "#fafafa",
                "text": "#212121",
                "cardBackground": "#ffffff",
                "cardBorder": "#e0e0e0"
            },
            "highContrast": {
                "name": "High Contrast",
                "primary": "#000000",
                "secondary": "#333333",
                "accent": "#0066cc",
                "success": "#006600",
                "danger": "#cc0000",
                "warning": "#ff6600",
                "background": "#ffffff",
                "text": "#000000",
                "cardBackground": "#f5f5f5",
                "cardBorder": "#000000"
            },
            "cyberpunk": {
                "name": "Cyberpunk",
                "primary": "#ff0080",
                "secondary": "#00ffff",
                "accent": "#ffff00",
                "success": "#00ff00",
                "danger": "#ff0040",
                "warning": "#ff8000",
                "background": "#0d0221",
                "text": "#e0e0ff",
                "cardBackground": "#1a0b3d",
                "cardBorder": "#ff0080"
            },
            "forest": {
                "name": "Forest",
                "primary": "#2d5016",
                "secondary": "#4a7c59",
                "accent": "#7ec699",
                "success": "#90d4a0",
                "danger": "#d97a7a",
                "warning": "#d4b85a",
                "background": "#1a2319",
                "text": "#e8f2e8",
                "cardBackground": "#2d3b2c",
                "cardBorder": "#4a7c59"
            },
            "ocean": {
                "name": "Ocean",
                "primary": "#0077be",
                "secondary": "#4a90a4",
                "accent": "#87ceeb",
                "success": "#20b2aa",
                "danger": "#dc143c",
                "warning": "#ffa500",
                "background": "#001f3f",
                "text": "#e6f3ff",
                "cardBackground": "#003366",
                "cardBorder": "#0077be"
            },
            "sunset": {
                "name": "Sunset",
                "primary": "#ff6b35",
                "secondary": "#f7931e",
                "accent": "#ffb347",
                "success": "#32cd32",
                "danger": "#ff4500",
                "warning": "#ffd700",
                "background": "#2c1810",
                "text": "#fff8dc",
                "cardBackground": "#4a2c17",
                "cardBorder": "#ff6b35"
            }
        }
    
    @Slot(result=list)
    def getAvailableThemes(self):
        """Get list of available theme keys"""
        themes = self.get_builtin_themes()
        return list(themes.keys())
    
    @Slot(result='QVariant')
    def getAllThemes(self):
        """Get all themes with their data"""
        return self.get_builtin_themes()
    
    @Slot(str, result='QVariant')
    def getTheme(self, theme_key):
        """Get a specific theme by key"""
        themes = self.get_builtin_themes()
        return themes.get(theme_key, themes["default"])
    
    @Slot(result=str)
    def getCurrentTheme(self):
        """Get current theme key"""
        return self._current_theme
    
    @Slot(str)
    def setTheme(self, theme_key):
        """Set current theme"""
        themes = self.get_builtin_themes()
        logger.info(f"setTheme called with: {theme_key}")
        
        if theme_key in themes:
            if self._current_theme != theme_key:
                logger.info(f"Changing theme from {self._current_theme} to {theme_key}")
                self._current_theme = theme_key
                
                # Update config manager with new colors
                theme_colors = themes[theme_key]
                
                for color_key, color_value in theme_colors.items():
                    if color_key != "name":  # Skip the name field
                        self.config_manager.set_value(f"colors.{color_key}", color_value)
                
                # Save current theme to config
                self.config_manager.set_value("currentTheme", theme_key)
                
                self.themeChanged.emit()
                logger.info(f"Theme successfully changed to: {theme_colors['name']}")
            else:
                logger.info(f"Theme {theme_key} is already current")
        else:
            logger.error(f"Theme '{theme_key}' not found! Available: {list(themes.keys())}")
    
    @Slot()
    def cycleTheme(self):
        """Cycle to the next theme"""
        available_themes = self.getAvailableThemes()
        try:
            current_index = available_themes.index(self._current_theme)
            next_index = (current_index + 1) % len(available_themes)
            next_theme = available_themes[next_index]
            self.setTheme(next_theme)
        except ValueError:
            # Current theme not found, default to first theme
            if available_themes:
                self.setTheme(available_themes[0])
    
    @Slot()
    def cycleThemeBackward(self):
        """Cycle to the previous theme"""
        available_themes = self.getAvailableThemes()
        try:
            current_index = available_themes.index(self._current_theme)
            prev_index = (current_index - 1) % len(available_themes)
            prev_theme = available_themes[prev_index]
            self.setTheme(prev_theme)
        except ValueError:
            # Current theme not found, default to last theme
            if available_themes:
                self.setTheme(available_themes[-1])
    
    def initialize_theme(self):
        """Initialize theme from config on startup"""
        saved_theme = self.config_manager.get_value("currentTheme", "default")
        available_themes = self.getAvailableThemes()
        
        # Ensure saved theme exists, fallback to default if not
        if saved_theme not in available_themes:
            saved_theme = "default"
        
        self._current_theme = saved_theme
        
        # Apply theme colors to config manager
        theme_colors = self.getTheme(saved_theme)
        for color_key, color_value in theme_colors.items():
            if color_key != "name":
                self.config_manager.set_value(f"colors.{color_key}", color_value)
        
        logger.info(f"Initialized with theme: {theme_colors['name']}")