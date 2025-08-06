import json
import os
from datetime import date, datetime, timedelta
from typing import Dict

from PySide6.QtCore import (
    Property,
    QObject,
    QTimer,
    Signal,
    Slot,
)

from .database import Database


class TimerItem(QObject):
    idChanged = Signal()
    nameChanged = Signal()
    typeChanged = Signal()
    elapsedSecondsChanged = Signal()
    countdownSecondsChanged = Signal()
    isRunningChanged = Signal()
    displayTimeChanged = Signal()

    def __init__(self, timer_data: Dict = None):
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
        self._is_running = timer_data.get("is_running", False) if timer_data else False
        self._last_started = timer_data.get("last_started") if timer_data else None

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

    @Property(bool, notify=isRunningChanged)
    def isRunning(self):
        return self._is_running

    @isRunning.setter
    def isRunning(self, value):
        if self._is_running != value:
            self._is_running = value
            self.isRunningChanged.emit()

    @Property(str, notify=displayTimeChanged)
    def displayTime(self):
        if self._type == "countdown":
            seconds = max(0, self._countdown_seconds)
        else:
            seconds = self._elapsed_seconds

        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        secs = seconds % 60
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"


class TimerManager(QObject):
    timersChanged = Signal()
    statsChanged = Signal()
    timesheetChanged = Signal()
    dailyBreakdownChanged = Signal()

    def __init__(self):
        super().__init__()
        self.db = Database()
        self._timers = []
        self.stats_file = "stats.json"
        self._active_sessions = {}  # timer_id -> session_id mapping
        self._current_date = date.today()
        self._daily_breakdown = []

        # Timer for updating running timers every second
        self.update_timer = QTimer()
        self.update_timer.timeout.connect(self._update_running_timers)
        self.update_timer.start(1000)

        # Timer to check for day rollover every minute
        self.day_check_timer = QTimer()
        self.day_check_timer.timeout.connect(self._check_day_rollover)
        self.day_check_timer.start(60000)  # Check every minute

        # Timer to update daily breakdown every 5 seconds for live updates
        self.breakdown_timer = QTimer()
        self.breakdown_timer.timeout.connect(self._update_daily_breakdown)
        self.breakdown_timer.start(5000)  # Update every 5 seconds

        self._load_timers()

        # Emit initial signal to populate daily breakdown
        self._update_breakdown_data()
        self.timesheetChanged.emit()


    def _load_timers(self):
        self._timers.clear()
        current_date = self._get_current_date_string()
        
        # Get date-specific timers (with smart propagation)
        timer_data = self.db.get_timers_for_date(current_date)
        
        for data in timer_data:
            # Get the daily state for this timer on the current date (includes running state)
            daily_state = self.db.get_daily_timer_state(data["id"], current_date)
            
            # Merge timer definition with daily state
            merged_data = data.copy()
            merged_data.update(daily_state)
            
            timer_item = TimerItem(merged_data)
            self._timers.append(timer_item)
        self.timersChanged.emit()
        
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
        hours = total_seconds / 3600
        return f"{hours:.1f}h"

    @Property(str, notify=statsChanged)
    def yesterdayHours(self):
        from datetime import timedelta
        yesterday = str(date.today() - timedelta(days=1))
        daily_summary = self.db.get_daily_summary(yesterday)
        total_seconds = sum(daily_summary.values()) if daily_summary else 0
        hours = total_seconds / 3600
        return f"{hours:.1f}h"

    @Property(str, notify=statsChanged)
    def thisWeekHours(self):
        weekly_data = self.db.get_weekly_summary()
        total_seconds = 0
        for day_data in weekly_data.values():
            total_seconds += sum(day_data.values())
        hours = total_seconds / 3600
        return f"{hours:.1f}h"

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
        total_hours = 0

        for project, seconds in daily_summary.items():
            hours = seconds / 3600
            total_hours += hours
            lines.append(f"  • {project}: {hours:.1f}h")

        lines.append(f"Total: {total_hours:.1f}h")
        return "\n".join(lines)

    @Slot(result=str)
    def getWeeklyTimesheet(self):
        """Get formatted weekly timesheet for copy-paste"""
        weekly_data = self.db.get_weekly_summary()
        if not weekly_data:
            return "No work sessions this week"

        lines = ["WEEKLY TIMESHEET", "=" * 40]
        weekly_total = 0

        # Sort dates in reverse order (most recent first)
        for date_str in sorted(weekly_data.keys(), reverse=True):
            projects = weekly_data[date_str]
            date_obj = datetime.fromisoformat(date_str).date()
            day_name = date_obj.strftime("%A")

            lines.append(f"\n{day_name}, {date_obj.strftime('%B %d, %Y')}:")
            daily_total = 0

            for project, seconds in projects.items():
                hours = seconds / 3600
                daily_total += hours
                lines.append(f"  • {project}: {hours:.1f}h")

            lines.append(f"  Daily Total: {daily_total:.1f}h")
            weekly_total += daily_total

        lines.append(f"\nWEEKLY TOTAL: {weekly_total:.1f}h")
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
                                "hours": f"{hours:.1f}h",
                                "rawHours": hours,
                            }
                        )
                else:
                    # Show "No work today" for empty days
                    projects.append(
                        {"name": "No work sessions", "hours": "0.0h", "rawHours": 0}
                    )

                breakdown_data.append(
                    {
                        "date": current_date,
                        "dayName": day_name,
                        "formattedDate": formatted_date,
                        "projects": projects,
                        "totalHours": f"{total_hours:.1f}h",
                        "rawTotalHours": total_hours,
                        "isToday": i == 0,
                    }
                )

        return breakdown_data

    @Slot(str, str)
    def addTimer(self, name: str, timer_type: str = "stopwatch"):
        current_date = self._get_current_date_string()
        timer_id = self.db.add_timer_to_date(current_date, name, timer_type)
        # Reload timers to reflect the new timer and any propagation
        self._load_timers()

    @Slot(int)
    def startTimer(self, timer_id: int):
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

    @Slot(int)
    def stopTimer(self, timer_id: int):
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

    @Slot(int)
    def resetTimer(self, timer_id: int):
        timer_item = self._get_timer_by_id(timer_id)
        if timer_item:
            timer_item.isRunning = False
            current_date = self._get_current_date_string()
            
            if timer_item.type == "countdown":
                timer_item.countdownSeconds = 0
            else:
                timer_item.elapsedSeconds = 0

            # Update daily state for running status and time values
            self.db.update_daily_timer_state(timer_id, current_date, {
                "is_running": False,
                "elapsed_seconds": timer_item.elapsedSeconds,
                "countdown_seconds": timer_item.countdownSeconds,
            })

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
            current_date = self._get_current_date_string()
            
            # Update daily state instead of global timer state
            self.db.update_daily_timer_state(timer_id, current_date, {
                "countdown_seconds": seconds
            })

    @Slot(int)
    def deleteTimer(self, timer_id: int):
        current_date = self._get_current_date_string()
        # Remove from current date's timer set (doesn't affect other dates)
        self.db.remove_timer_from_date(current_date, timer_id)
        # Reload timers to reflect the change
        self._load_timers()

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

    def _get_timer_by_id(self, timer_id: int):
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

    def _update_daily_breakdown(self):
        """Update daily breakdown if there are active timers"""
        if self._active_sessions:  # Only update if there are running timers
            self._update_breakdown_data()
            self.timesheetChanged.emit()

    def _check_day_rollover(self):
        """Check if we've rolled over to a new day and refresh timesheet if so"""
        current_date = date.today()
        if current_date != self._current_date:
            self._current_date = current_date
            self._update_breakdown_data()
            self.timesheetChanged.emit()  # Refresh the daily breakdown view
