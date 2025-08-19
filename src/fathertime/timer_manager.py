"""Timer management for Father Time application.

This module handles all timer operations including starting, stopping, and tracking
timer states across different dates. It integrates with the Qt/QML UI system and
provides optimized performance for handling multiple concurrent timers.
"""

import json
import os
from datetime import date, datetime, timedelta
from typing import Dict, Optional, List, Set

from PySide6.QtCore import (
    Property,
    QObject,
    QTimer,
    Signal,
    Slot,
)

from .database import Database
from .logger import logger


class TimerItem(QObject):
    idChanged = Signal()
    nameChanged = Signal()
    typeChanged = Signal()
    elapsedSecondsChanged = Signal()
    countdownSecondsChanged = Signal()
    initialCountdownSecondsChanged = Signal()
    isRunningChanged = Signal()
    isFavoriteChanged = Signal()
    displayTimeChanged = Signal()

    def __init__(self, timer_data: Dict = None, config_manager=None):
        super().__init__()
        self._id = timer_data.get("id", 0) if timer_data else 0
        self._name = timer_data.get("name", "") if timer_data else ""
        self._type = timer_data.get("type", "stopwatch") if timer_data else "stopwatch"
        self._elapsed_seconds = (
            timer_data.get("elapsed_seconds", 0) if timer_data else 0
        )
        self._countdown_seconds = (
            timer_data.get("countdown_seconds", 0) if timer_data else 0
        )
        self._initial_countdown_seconds = (
            timer_data.get("initial_countdown_seconds", 0) if timer_data else 0
        )
        self._is_running = timer_data.get("is_running", False) if timer_data else False
        self._is_favorite = timer_data.get("is_favorite", False) if timer_data else False
        self._last_started = timer_data.get("last_started") if timer_data else None
        self._config_manager = config_manager

    @Property(int, notify=idChanged)
    def id(self):
        return self._id

    @Property(str, notify=nameChanged)
    def name(self):
        return self._name

    @name.setter
    def name(self, value):
        if self._name != value:
            self._name = value
            self.nameChanged.emit()

    @Property(str, notify=typeChanged)
    def type(self):
        return self._type

    @type.setter
    def type(self, value):
        if self._type != value:
            self._type = value
            self.typeChanged.emit()

    @Property(int, notify=elapsedSecondsChanged)
    def elapsedSeconds(self):
        return self._elapsed_seconds

    @elapsedSeconds.setter
    def elapsedSeconds(self, value):
        if self._elapsed_seconds != value:
            self._elapsed_seconds = value
            self.elapsedSecondsChanged.emit()
            self.displayTimeChanged.emit()

    @Property(int, notify=countdownSecondsChanged)
    def countdownSeconds(self):
        return self._countdown_seconds

    @countdownSeconds.setter
    def countdownSeconds(self, value):
        if self._countdown_seconds != value:
            self._countdown_seconds = value
            self.countdownSecondsChanged.emit()
            self.displayTimeChanged.emit()

    @Property(int, notify=initialCountdownSecondsChanged)
    def initialCountdownSeconds(self):
        return self._initial_countdown_seconds

    @initialCountdownSeconds.setter
    def initialCountdownSeconds(self, value):
        if self._initial_countdown_seconds != value:
            self._initial_countdown_seconds = value
            self.initialCountdownSecondsChanged.emit()

    @Property(bool, notify=isRunningChanged)
    def isRunning(self):
        return self._is_running

    @isRunning.setter
    def isRunning(self, value):
        if self._is_running != value:
            self._is_running = value
            self.isRunningChanged.emit()
            self.displayTimeChanged.emit()  # Format changes based on running state

    @Property(bool, notify=isFavoriteChanged)
    def isFavorite(self):
        return self._is_favorite

    @isFavorite.setter
    def isFavorite(self, value):
        if self._is_favorite != value:
            self._is_favorite = value
            self.isFavoriteChanged.emit()

    @Property(str, notify=displayTimeChanged)
    def displayTime(self):
        if self._type == "countdown":
            seconds = max(0, self._countdown_seconds)
        else:
            seconds = self._elapsed_seconds

        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        secs = seconds % 60
        
        # For stopped timers, show timesheet-friendly format (decimal hours)
        # For running timers, show standard HH:MM:SS format
        if not self._is_running and self._type != "countdown":
            # Convert to decimal hours for timesheet entry
            decimal_hours = seconds / 3600.0
            
            # Apply time rounding if enabled and config manager is available
            if self._config_manager:
                if self._config_manager.timeRoundingEnabled:
                    rounding_minutes = self._config_manager.timeRoundingMinutes
                    original_hours = decimal_hours
                    # Round to the nearest specified interval
                    if rounding_minutes == 15:  # Quarter hours: 0.25 intervals
                        decimal_hours = round(decimal_hours * 4) / 4
                    elif rounding_minutes == 30:  # Half hours: 0.5 intervals
                        decimal_hours = round(decimal_hours * 2) / 2
                    elif rounding_minutes == 60:  # Full hours: 1.0 intervals
                        decimal_hours = round(decimal_hours)
                    
                    # Debug logging
                    from .logger import logger
                    logger.debug(f"Rounding: {original_hours:.4f}h → {decimal_hours:.4f}h (interval: {rounding_minutes}min)")
                else:
                    from .logger import logger
                    logger.debug(f"Rounding disabled: {decimal_hours:.4f}h")
            
            if decimal_hours == 0:
                return "0.00h"
            elif decimal_hours < 0.01:  # Less than 0.01 hours (36 seconds)
                return f"{decimal_hours:.3f}h"
            else:
                return f"{decimal_hours:.2f}h"
        else:
            # Standard format for running timers and countdown timers
            return f"{hours:02d}:{minutes:02d}:{secs:02d}"


class TimerManager(QObject):
    timersChanged = Signal()
    statsChanged = Signal()
    timesheetChanged = Signal()
    dailyBreakdownChanged = Signal()

    def __init__(self, config_manager=None) -> None:
        super().__init__()
        self.db = Database()
        self._timers = []
        self.stats_file = "stats.json"
        self._active_sessions = {}  # timer_id -> session_id mapping
        self._current_date = date.today()
        self._daily_breakdown = []
        self._config_manager = config_manager

        # Consolidated timer system - single timer with state-based logic
        self.main_timer = QTimer()
        self.main_timer.timeout.connect(self._consolidated_timer_update)
        self.main_timer.start(1000)  # 1 second interval
        
        # Timer state tracking for efficient updates
        self._timer_update_counter = 0
        self._last_day_check = 0  # Track when we last checked for day rollover
        self._last_breakdown_update = 0  # Track when we last updated breakdown
        
        # Performance: track only running timers to avoid unnecessary work
        self._running_timer_ids = set()  # Set of timer IDs that are currently running

        self._load_timers()

        # Emit initial signal to populate daily breakdown
        self._update_breakdown_data()
        self.timesheetChanged.emit()
        
        # Connect to config changes to update timer displays
        if self._config_manager:
            self._config_manager.timeRoundingChanged.connect(self._on_time_rounding_changed)

    def _format_time_literal(self, total_seconds: int) -> str:
        """Format time without approximations showing exact hours, minutes, seconds."""
        if total_seconds == 0:
            return "0s"
            
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        seconds = total_seconds % 60
        
        parts = []
        if hours > 0:
            parts.append(f"{hours}h")
        if minutes > 0:
            parts.append(f"{minutes}m")
        if seconds > 0:
            parts.append(f"{seconds}s")
            
        return " ".join(parts)

    def _on_time_rounding_changed(self):
        """Handle time rounding configuration changes by updating all timer displays."""
        # Force update all timer displays by emitting displayTimeChanged signal
        for timer in self._timers:
            timer.displayTimeChanged.emit()

    def _load_timers(self):
        self._timers.clear()
        self._running_timer_ids.clear()  # Reset running timer set
        current_date = self._get_current_date_string()
        
        # Get date-specific timers (with smart propagation)
        timer_data = self.db.get_timers_for_date(current_date)
        
        # Get the display order for this date
        display_order = self.db.get_timer_order(current_date)
        
        # Create timer items
        timer_items = {}
        for data in timer_data:
            # Get the daily state for this timer on the current date (includes running state)
            daily_state = self.db.get_daily_timer_state(data["id"], current_date)
            
            # Merge timer definition with daily state
            merged_data = data.copy()
            merged_data.update(daily_state)
            
            timer_item = TimerItem(merged_data, self._config_manager)
            timer_items[data["id"]] = timer_item
            
            # Add to running timer set if timer is currently running
            if merged_data.get("is_running", False):
                self._running_timer_ids.add(data["id"])
        
        # Respect the saved display order exactly as manually arranged
        if display_order:
            # Add timers in the exact order they were saved
            for timer_id in display_order:
                if timer_id in timer_items:
                    timer_item = timer_items[timer_id]
                    self._timers.append(timer_item)
                    del timer_items[timer_id]
        
        # Add any remaining timers that weren't in the display order
        # Add new timers at the end, sorted by creation order
        remaining_timers = list(timer_items.values())
        if remaining_timers:
            # Sort by timer ID (creation order)
            remaining_timers.sort(key=lambda t: t.id)
            # Append all remaining timers at the end
            self._timers.extend(remaining_timers)
        
        # Update the display order to match the current layout (no auto-correction)
        self._update_display_order_for_current_layout()
                
        self.timersChanged.emit()
    
    def _update_display_order_for_current_layout(self):
        """Update the display order to match the current timer layout."""
        current_date = self._get_current_date_string()
        
        # Create the order based on current timer layout
        current_order = [timer.id for timer in self._timers]
        
        # Only update if the order has actually changed
        existing_order = self.db.get_timer_order(current_date)
        if current_order != existing_order:
            self.db.update_timer_order(current_date, current_order)
        
    def _get_current_date_string(self):
        """Get current date as string, but use selectedDateForTimers from UI if available"""
        # This will be overridden by the UI when date changes
        return self._current_date_str if hasattr(self, '_current_date_str') else date.today().isoformat()
        
    @Slot(str)
    def set_current_date(self, date_string):
        """Set the current date for timer states"""
        if hasattr(self, '_current_date_str') and self._current_date_str == date_string:
            return
            
        self._current_date_str = date_string
        self._load_timers()  # Reload timers with new date's states

    @Property(list, notify=timersChanged)
    def timers(self):
        return self._timers
        
    @Slot(str, result="QVariant")
    def getTimersForDate(self, dateString):
        """Get timers that were active on a specific date"""
        # For now, return all timers since we don't track per-date timer creation
        # In future, this could filter by creation date or activity on that date
        return self._timers

    @Property(str, notify=statsChanged)
    def todayHours(self):
        today = str(date.today())
        daily_summary = self.db.get_daily_summary(today)
        total_seconds = sum(daily_summary.values()) if daily_summary else 0
        return self._format_time_literal(total_seconds)

    @Property(str, notify=statsChanged)
    def yesterdayHours(self):
        from datetime import timedelta
        yesterday = str(date.today() - timedelta(days=1))
        daily_summary = self.db.get_daily_summary(yesterday)
        total_seconds = sum(daily_summary.values()) if daily_summary else 0
        return self._format_time_literal(total_seconds)

    @Property(str, notify=statsChanged)
    def thisWeekHours(self):
        weekly_data = self.db.get_weekly_summary()
        total_seconds = 0
        for day_data in weekly_data.values():
            total_seconds += sum(day_data.values())
        return self._format_time_literal(total_seconds)

    @Property("QVariant", notify=dailyBreakdownChanged)
    def dailyBreakdown(self):
        return self._daily_breakdown

    @Property(str, notify=timesheetChanged)
    def todayTimesheet(self):
        """Get today's project breakdown as formatted string"""
        daily_summary = self.db.get_daily_summary()
        if not daily_summary:
            return "No work sessions today"

        lines = [f"Today ({date.today().strftime('%Y-%m-%d')}):"]
        total_seconds = 0

        for project, seconds in daily_summary.items():
            total_seconds += seconds
            lines.append(f"  • {project}: {self._format_time_literal(seconds)}")

        lines.append(f"Total: {self._format_time_literal(total_seconds)}")
        return "\n".join(lines)

    @Slot(result=str)
    def getWeeklyTimesheet(self):
        """Get formatted weekly timesheet for copy-paste"""
        weekly_data = self.db.get_weekly_summary()
        if not weekly_data:
            return "No work sessions this week"

        lines = ["WEEKLY TIMESHEET", "=" * 40]
        weekly_total_seconds = 0

        # Sort dates in reverse order (most recent first)
        for date_str in sorted(weekly_data.keys(), reverse=True):
            projects = weekly_data[date_str]
            date_obj = datetime.fromisoformat(date_str).date()
            day_name = date_obj.strftime("%A")

            lines.append(f"\n{day_name}, {date_obj.strftime('%B %d, %Y')}:")
            daily_total_seconds = 0

            for project, seconds in projects.items():
                daily_total_seconds += seconds
                lines.append(f"  • {project}: {self._format_time_literal(seconds)}")

            lines.append(f"  Daily Total: {self._format_time_literal(daily_total_seconds)}")
            weekly_total_seconds += daily_total_seconds

        lines.append(f"\nWEEKLY TOTAL: {self._format_time_literal(weekly_total_seconds)}")
        lines.append("=" * 40)

        return "\n".join(lines)

    def _update_breakdown_data(self):
        """Update the internal daily breakdown data"""
        self._daily_breakdown = self._calculate_daily_breakdown()
        self.dailyBreakdownChanged.emit()

    @Slot(result="QVariant")
    def getDailyBreakdown(self):
        """Get daily project breakdowns (for backwards compatibility)."""
        return self.dailyBreakdown

    def _calculate_daily_breakdown(self):
        """Get the last 14 days of daily project breakdowns"""
        breakdown_data = []

        for i in range(14):
            current_date = (date.today() - timedelta(days=i)).isoformat()
            daily_summary = self.db.get_daily_summary(current_date)

            # Also include today's active sessions
            if i == 0:  # Today
                # Add time from any currently running sessions
                for timer_id, session_id in self._active_sessions.items():
                    timer_item = self._get_timer_by_id(timer_id)
                    if timer_item and timer_item.type == "stopwatch":
                        # Add the current elapsed time to today's summary
                        if timer_item.name not in daily_summary:
                            daily_summary[timer_item.name] = 0
                        daily_summary[timer_item.name] += timer_item.elapsedSeconds

            # Always show today, even if empty
            if daily_summary or i == 0:
                date_obj = datetime.fromisoformat(current_date).date()
                day_name = date_obj.strftime("%A")
                formatted_date = date_obj.strftime("%B %d, %Y")

                total_seconds = sum(daily_summary.values()) if daily_summary else 0
                total_hours = total_seconds / 3600

                projects = []
                if daily_summary:
                    for project, seconds in daily_summary.items():
                        hours = seconds / 3600
                        projects.append(
                            {
                                "name": project,
                                "hours": self._format_time_literal(seconds),
                                "rawHours": hours,
                            }
                        )
                else:
                    # Show "No work today" for empty days
                    projects.append(
                        {"name": "No work sessions", "hours": "0s", "rawHours": 0}
                    )

                breakdown_data.append(
                    {
                        "date": current_date,
                        "dayName": day_name,
                        "formattedDate": formatted_date,
                        "projects": projects,
                        "totalHours": self._format_time_literal(total_seconds),
                        "rawTotalHours": total_hours,
                        "isToday": i == 0,
                    }
                )

        return breakdown_data

    @Slot(str, str, result=int)
    def addTimer(self, name: str, timer_type: str = "stopwatch"):
        """Add a new timer with validation.
        
        Args:
            name: Name of the timer
            timer_type: Type of timer ('stopwatch' or 'countdown')
        """
        # Validate inputs
        if not isinstance(name, str):
            logger.error("Timer name must be a string")
            return -1
            
        if not isinstance(timer_type, str):
            logger.error("Timer type must be a string")
            return -1
            
        if timer_type not in ("stopwatch", "countdown"):
            logger.error(f"Invalid timer type: {timer_type}")
            return -1
        
        try:
            current_date = self._get_current_date_string()
            timer_id = self.db.add_timer_to_date(current_date, name, timer_type)
            # Reload timers to reflect the new timer
            self._load_timers()
            return timer_id
        except Exception as e:
            logger.error(f"Failed to add timer: {e}")
            return -1
    

    @Slot(int)
    def startTimer(self, timer_id: int):
        """Start a timer with the given ID.
        
        Args:
            timer_id: ID of the timer to start
        """
        # Validate timer ID
        if not isinstance(timer_id, int) or timer_id <= 0:
            logger.error(f"Invalid timer ID: {timer_id}")
            return
            
        timer_item = self._get_timer_by_id(timer_id)
        if timer_item and not timer_item.isRunning:
            timer_item.isRunning = True
            now = datetime.now().isoformat()
            current_date = self._get_current_date_string()

            # Start a new session for stopwatch timers only
            if timer_item.type == "stopwatch":
                session_id = self.db.start_session(timer_id, timer_item.name)
                self._active_sessions[timer_id] = session_id

            # Update daily timer state for running status (date-specific)
            self.db.update_daily_timer_state(timer_id, current_date, {
                "is_running": True, 
                "last_started": now
            })
            
            # Add to running timer set for optimized updates
            self._running_timer_ids.add(timer_id)

    @Slot(int)
    def stopTimer(self, timer_id: int):
        """Stop a timer with the given ID.
        
        Args:
            timer_id: ID of the timer to stop
        """
        # Validate timer ID
        if not isinstance(timer_id, int) or timer_id <= 0:
            logger.error(f"Invalid timer ID: {timer_id}")
            return
            
        timer_item = self._get_timer_by_id(timer_id)
        if timer_item and timer_item.isRunning:
            timer_item.isRunning = False
            current_date = self._get_current_date_string()

            # End the session for stopwatch timers
            if timer_item.type == "stopwatch" and timer_id in self._active_sessions:
                session_id = self._active_sessions[timer_id]
                self.db.end_session(session_id)
                del self._active_sessions[timer_id]
                self._update_breakdown_data()
                self.timesheetChanged.emit()

            # Update daily state for running status and time values
            self.db.update_daily_timer_state(timer_id, current_date, {
                "is_running": False,
                "elapsed_seconds": timer_item.elapsedSeconds,
                "countdown_seconds": timer_item.countdownSeconds,
            })
            
            # Remove from running timer set
            self._running_timer_ids.discard(timer_id)

    @Slot(int)
    def resetTimer(self, timer_id: int):
        timer_item = self._get_timer_by_id(timer_id)
        if timer_item:
            timer_item.isRunning = False
            current_date = self._get_current_date_string()
            
            if timer_item.type == "countdown":
                # Reset countdown to its original/initial time instead of 0
                timer_item.countdownSeconds = timer_item.initialCountdownSeconds
            else:
                timer_item.elapsedSeconds = 0

            # Update daily state for running status and time values
            self.db.update_daily_timer_state(timer_id, current_date, {
                "is_running": False,
                "elapsed_seconds": timer_item.elapsedSeconds,
                "countdown_seconds": timer_item.countdownSeconds,
            })
            
            # Remove from running timer set since timer is reset
            self._running_timer_ids.discard(timer_id)

    @Slot(int, int)
    def adjustTime(self, timer_id: int, seconds: int):
        timer_item = self._get_timer_by_id(timer_id)
        if timer_item:
            current_date = self._get_current_date_string()
            
            if timer_item.type == "countdown":
                timer_item.countdownSeconds = max(
                    0, timer_item.countdownSeconds + seconds
                )
            else:
                timer_item.elapsedSeconds = max(0, timer_item.elapsedSeconds + seconds)

            # Update daily state instead of global timer state
            self.db.update_daily_timer_state(timer_id, current_date, {
                "elapsed_seconds": timer_item.elapsedSeconds,
                "countdown_seconds": timer_item.countdownSeconds,
            })

    @Slot(int, int)
    def setCountdownTime(self, timer_id: int, seconds: int):
        timer_item = self._get_timer_by_id(timer_id)
        if timer_item and timer_item.type == "countdown":
            timer_item.countdownSeconds = seconds
            timer_item.initialCountdownSeconds = seconds  # Store the initial time
            current_date = self._get_current_date_string()
            
            # Update daily state instead of global timer state
            self.db.update_daily_timer_state(timer_id, current_date, {
                "countdown_seconds": seconds,
                "initial_countdown_seconds": seconds
            })

    @Slot(int)
    def toggleTimerFavorite(self, timer_id: int):
        """Toggle the favorite status of a timer.
        
        Args:
            timer_id: ID of the timer to toggle
        """
        # Validate timer ID
        if not isinstance(timer_id, int) or timer_id <= 0:
            logger.error(f"Invalid timer ID: {timer_id}")
            return
            
        current_date = self._get_current_date_string()
        
        try:
            # Get current status before toggling
            timer_item = self._get_timer_by_id(timer_id)
            was_favorite = timer_item.isFavorite if timer_item else False
            
            # Toggle in database
            new_status = self.db.toggle_timer_favorite(current_date, timer_id)
            
            # Update the local timer object
            if timer_item:
                timer_item.isFavorite = new_status
            
            # Just reload timers to update the UI (no auto-reordering)
            self._load_timers()
                
        except Exception as e:
            logger.error(f"Failed to toggle timer favorite: {e}")
    

    @Slot(int, str)
    def renameTimer(self, timer_id: int, new_name: str):
        """Rename a timer with the given ID.
        
        Args:
            timer_id: ID of the timer to rename
            new_name: New name for the timer
        """
        # Validate inputs
        if not isinstance(timer_id, int) or timer_id <= 0:
            logger.error(f"Invalid timer ID: {timer_id}")
            return
            
        if not isinstance(new_name, str) or not new_name.strip():
            logger.error("New timer name must be a non-empty string")
            return
            
        timer_item = self._get_timer_by_id(timer_id)
        
        if timer_item:
            # Update the timer name in the database
            current_date = self._get_current_date_string()
            try:
                self.db.rename_timer_on_date(current_date, timer_id, new_name.strip())
                # Reload timers to reflect the change
                self._load_timers()
                logger.info(f"Timer '{timer_item.name}' renamed to '{new_name.strip()}'")
            except Exception as e:
                logger.error(f"Failed to rename timer: {e}")
        else:
            logger.error(f"Timer with ID {timer_id} not found in current timers list")

    @Slot(int)
    def deleteTimer(self, timer_id: int):
        current_date = self._get_current_date_string()
        # Remove from current date's timer set (doesn't affect other dates)
        self.db.remove_timer_from_date(current_date, timer_id)
        # Reload timers to reflect the change
        self._load_timers()

    @Slot(int, int)
    def reorderTimer(self, fromIndex: int, toIndex: int):
        """Reorder a timer from one position to another.
        
        Args:
            fromIndex: Current index of the timer
            toIndex: Target index for the timer
        """
        if (fromIndex < 0 or fromIndex >= len(self._timers) or 
            toIndex < 0 or toIndex >= len(self._timers) or 
            fromIndex == toIndex):
            return
            
        # Move the timer in the local list
        timer = self._timers.pop(fromIndex)
        self._timers.insert(toIndex, timer)
        
        # Update the display order in the database
        current_date = self._get_current_date_string()
        timer_ids = [t.id for t in self._timers]
        self.db.update_timer_order(current_date, timer_ids)
        
        # Emit signal to update the UI
        self.timersChanged.emit()

    @Slot()
    def resetAllData(self):
        """Reset all timer data, sessions, and stats"""
        # Stop all running timers first
        for timer in self._timers:
            if timer.isRunning:
                self.stopTimer(timer.id)

        # Clear all data
        self.db.reset_all_data()
        self._active_sessions = {}

        # Reload timers (will be empty)
        self._load_timers()

        # Update all displays
        self._update_breakdown_data()
        self.timesheetChanged.emit()
        self.statsChanged.emit()

    def _get_timer_by_id(self, timer_id: int) -> Optional['TimerItem']:
        for timer in self._timers:
            if timer.id == timer_id:
                return timer
        return None

    def _update_running_timers(self):
        # Update all running timers across all dates, not just the currently viewed date
        all_dates_with_states = self.db.daily_states.get("daily_states", {})
        
        for date_str, date_states in all_dates_with_states.items():
            for timer_id_str, timer_state in date_states.items():
                if timer_state.get("is_running", False):
                    timer_id = int(timer_id_str)
                    
                    # Get the timer definition
                    timer_def = self.db.get_timer(timer_id)
                    if not timer_def:
                        continue
                        
                    if timer_def["type"] == "countdown":
                        if timer_state.get("countdown_seconds", 0) > 0:
                            new_countdown = timer_state["countdown_seconds"] - 1
                            self.db.update_daily_timer_state(timer_id, date_str, {
                                "countdown_seconds": new_countdown
                            })
                        else:
                            # Timer finished
                            self.db.update_daily_timer_state(timer_id, date_str, {
                                "is_running": False,
                                "countdown_seconds": 0
                            })
                    else:  # stopwatch
                        new_elapsed = timer_state.get("elapsed_seconds", 0) + 1
                        self.db.update_daily_timer_state(timer_id, date_str, {
                            "elapsed_seconds": new_elapsed
                        })
                        
        # Update the UI for the currently viewed date
        current_date = self._get_current_date_string()
        current_changed = False
        for timer in self._timers:
            if timer.isRunning:
                # Get the latest state for this timer on current date
                updated_state = self.db.get_daily_timer_state(timer.id, current_date)
                if timer.type == "countdown":
                    if timer.countdownSeconds != updated_state.get("countdown_seconds", 0):
                        timer.countdownSeconds = updated_state["countdown_seconds"]
                        current_changed = True
                    if not updated_state.get("is_running", False):
                        timer.isRunning = False
                        current_changed = True
                else:
                    if timer.elapsedSeconds != updated_state.get("elapsed_seconds", 0):
                        timer.elapsedSeconds = updated_state["elapsed_seconds"]
                        current_changed = True
        
        # Emit signal if any timers changed
        if current_changed:
            self.timersChanged.emit()

    def _update_daily_breakdown(self):
        """Update daily breakdown if there are active timers"""
        if self._active_sessions:  # Only update if there are running timers
            self._update_breakdown_data()
            self.timesheetChanged.emit()

    def _consolidated_timer_update(self):
        """Consolidated timer update method that efficiently handles all timing tasks.
        
        This replaces the previous three separate timers with a single efficient system.
        Updates are performed based on counters to maintain the same effective intervals:
        - Running timers: Every 1 second (always)
        - Day rollover check: Every 60 seconds 
        - Breakdown update: Every 5 seconds (when there are active sessions)
        """
        self._timer_update_counter += 1
        
        # Always update running timers (every 1 second)
        if self._running_timer_ids:  # Only if there are running timers
            self._update_running_timers()
        
        # Check day rollover every 60 seconds (60 * 1 second intervals)
        if self._timer_update_counter % 60 == 0:
            self._check_day_rollover()
            self._last_day_check = self._timer_update_counter
            
        # Update breakdown every 5 seconds (5 * 1 second intervals) when active
        if self._timer_update_counter % 5 == 0 and self._active_sessions:
            self._update_daily_breakdown()
            self._last_breakdown_update = self._timer_update_counter
            
        # Reset counter every 300 seconds (5 minutes) to prevent overflow
        if self._timer_update_counter >= 300:
            self._timer_update_counter = 0

    # REMOVED: _update_running_timers_optimized() method was causing timer conflicts
    # Using the simpler _update_running_timers() method instead

    def _check_day_rollover(self):
        """Check if we've rolled over to a new day and refresh timesheet if so"""
        current_date = date.today()
        if current_date != self._current_date:
            self._current_date = current_date
            self._update_breakdown_data()
            self.timesheetChanged.emit()  # Refresh the daily breakdown view
