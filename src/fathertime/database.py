"""Database operations for Father Time application."""

import json
import os
from datetime import date, datetime, timedelta
from pathlib import Path
from typing import Any, Dict, List, Optional

from .config import (
    ARCHIVE_DIRECTORY,
    DEFAULT_DB_FILE,
    DEFAULT_SESSIONS_FILE,
)
from .exceptions import DatabaseError, ValidationError
from .logger import logger


class Database:
    """Handles all database operations for timers and sessions."""

    def __init__(self, db_file: str = DEFAULT_DB_FILE, data_dir: Optional[str] = None):
        """Initialize database with file paths.

        Args:
            db_file: Name of the database file
            data_dir: Directory to store data files (uses current dir if None)
        """
        self.data_dir = Path(data_dir) if data_dir else Path.cwd()
        self.db_file = self.data_dir / db_file
        self.sessions_file = self.data_dir / DEFAULT_SESSIONS_FILE
        self.daily_states_file = self.data_dir / "daily_timer_states.json"
        self.daily_timers_file = self.data_dir / "daily_timers.json"
        self.archive_dir = self.data_dir / ARCHIVE_DIRECTORY

        try:
            self.data = self._load_data()
            self.sessions = self._load_sessions()
            self.daily_states = self._load_daily_states()
            self.daily_timers = self._load_daily_timers()
            self._check_and_archive_old_data()
            logger.info(
                f"Database initialized with {len(self.data.get('timers', []))} timers"
            )
        except Exception as e:
            logger.error(f"Failed to initialize database: {e}")
            raise DatabaseError(f"Database initialization failed: {e}") from e

    def _load_data(self) -> Dict[str, Any]:
        """Load timer data from JSON file.

        Returns:
            Dictionary containing timers data

        Raises:
            DatabaseError: If file cannot be loaded
        """
        default_data = {"timers": [], "next_id": 1}

        if not self.db_file.exists():
            logger.info(
                f"Database file {self.db_file} does not exist, creating new one"
            )
            self._save_data_to_file(default_data, self.db_file)
            return default_data

        try:
            with open(self.db_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                self._validate_data_structure(data)
                return data
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON in database file: {e}")
            raise DatabaseError(f"Corrupt database file: {e}") from e
        except IOError as e:
            logger.error(f"Cannot read database file: {e}")
            raise DatabaseError(f"Cannot read database file: {e}") from e

    def _load_sessions(self) -> Dict[str, Any]:
        """Load session data from JSON file.

        Returns:
            Dictionary containing sessions data

        Raises:
            DatabaseError: If file cannot be loaded
        """
        default_sessions = {"sessions": []}

        if not self.sessions_file.exists():
            logger.info(
                f"Sessions file {self.sessions_file} does not exist, creating new one"
            )
            self._save_data_to_file(default_sessions, self.sessions_file)
            return default_sessions

        try:
            with open(self.sessions_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                self._validate_sessions_structure(data)
                return data
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON in sessions file: {e}")
            raise DatabaseError(f"Corrupt sessions file: {e}") from e
        except IOError as e:
            logger.error(f"Cannot read sessions file: {e}")
            raise DatabaseError(f"Cannot read sessions file: {e}") from e

    def _load_daily_states(self) -> Dict[str, Any]:
        """Load daily timer states from JSON file.

        Returns:
            Dictionary containing daily timer states data

        Raises:
            DatabaseError: If file cannot be loaded
        """
        default_states = {"daily_states": {}}

        if not self.daily_states_file.exists():
            logger.info(
                f"Daily states file {self.daily_states_file} does not exist, creating new one"
            )
            self._save_data_to_file(default_states, self.daily_states_file)
            return default_states

        try:
            with open(self.daily_states_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                self._validate_daily_states_structure(data)
                return data
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON in daily states file: {e}")
            raise DatabaseError(f"Corrupt daily states file: {e}") from e
        except IOError as e:
            logger.error(f"Cannot read daily states file: {e}")
            raise DatabaseError(f"Cannot read daily states file: {e}") from e

    def save_data(self) -> None:
        """Save timer data to JSON file.

        Raises:
            DatabaseError: If file cannot be saved
        """
        self._save_data_to_file(self.data, self.db_file)
        logger.debug(f"Saved timer data to {self.db_file}")

    def save_sessions(self) -> None:
        """Save session data to JSON file.

        Raises:
            DatabaseError: If file cannot be saved
        """
        self._save_data_to_file(self.sessions, self.sessions_file)
        logger.debug(f"Saved sessions data to {self.sessions_file}")

    def save_daily_states(self) -> None:
        """Save daily timer states to JSON file.

        Raises:
            DatabaseError: If file cannot be saved
        """
        self._save_data_to_file(self.daily_states, self.daily_states_file)
        logger.debug(f"Saved daily states data to {self.daily_states_file}")

    def _check_and_archive_old_data(self):
        """Archive data older than 2 weeks"""
        cutoff_date = date.today() - timedelta(days=14)
        cutoff_str = cutoff_date.isoformat()

        # Find sessions older than 2 weeks
        old_sessions = []
        recent_sessions = []

        for session in self.sessions.get("sessions", []):
            session_date = session.get("date", "")
            if session_date < cutoff_str:
                old_sessions.append(session)
            else:
                recent_sessions.append(session)

        # If we have old sessions, archive them
        if old_sessions:
            self._archive_sessions(old_sessions, cutoff_date)
            self.sessions["sessions"] = recent_sessions
            self.save_sessions()

    def _archive_sessions(self, sessions: List[Dict], cutoff_date: date):
        """Archive old sessions to dated folder"""
        if not os.path.exists(self.archive_dir):
            os.makedirs(self.archive_dir)

        # Create archive filename with date range
        oldest_date = min(session.get("date", "") for session in sessions)
        newest_date = max(session.get("date", "") for session in sessions)
        archive_file = (
            f"{self.archive_dir}/sessions_{oldest_date}_to_{newest_date}.json"
        )

        try:
            with open(archive_file, "w") as f:
                json.dump(
                    {
                        "archived_sessions": sessions,
                        "archived_on": date.today().isoformat(),
                    },
                    f,
                    indent=2,
                )
            logger.info(f"Archived {len(sessions)} sessions to {archive_file}")
        except IOError as e:
            logger.error(f"Error archiving sessions: {e}")
            raise DatabaseError(f"Cannot archive sessions: {e}") from e

    def _save_data_to_file(self, data: Dict[str, Any], file_path: Path) -> None:
        """Save data to JSON file with error handling.

        Args:
            data: Data to save
            file_path: Path to save file

        Raises:
            DatabaseError: If file cannot be saved
        """
        try:
            file_path.parent.mkdir(parents=True, exist_ok=True)
            with open(file_path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
        except IOError as e:
            logger.error(f"Cannot save to {file_path}: {e}")
            raise DatabaseError(f"Cannot save to {file_path}: {e}") from e

    def _validate_data_structure(self, data: Dict[str, Any]) -> None:
        """Validate timer data structure.

        Args:
            data: Data to validate

        Raises:
            ValidationError: If data structure is invalid
        """
        if not isinstance(data, dict):
            raise ValidationError("Data must be a dictionary")
        if "timers" not in data or not isinstance(data["timers"], list):
            raise ValidationError("Data must contain 'timers' list")
        if "next_id" not in data or not isinstance(data["next_id"], int):
            raise ValidationError("Data must contain 'next_id' integer")

    def _validate_sessions_structure(self, data: Dict[str, Any]) -> None:
        """Validate session data structure.

        Args:
            data: Data to validate

        Raises:
            ValidationError: If data structure is invalid
        """
        if not isinstance(data, dict):
            raise ValidationError("Sessions data must be a dictionary")
        if "sessions" not in data or not isinstance(data["sessions"], list):
            raise ValidationError("Sessions data must contain 'sessions' list")

    def _validate_daily_states_structure(self, data: Dict[str, Any]) -> None:
        """Validate daily states data structure.

        Args:
            data: Data to validate

        Raises:
            ValidationError: If data structure is invalid
        """
        if not isinstance(data, dict):
            raise ValidationError("Daily states data must be a dictionary")
        if "daily_states" not in data or not isinstance(data["daily_states"], dict):
            raise ValidationError("Daily states data must contain 'daily_states' dictionary")

    def _load_daily_timers(self) -> Dict[str, Any]:
        """Load daily timers from JSON file.

        Returns:
            Dictionary containing daily timers data

        Raises:
            DatabaseError: If file cannot be loaded
        """
        default_timers = {"daily_timers": {}}

        if not self.daily_timers_file.exists():
            logger.info(
                f"Daily timers file {self.daily_timers_file} does not exist, creating new one"
            )
            self._save_data_to_file(default_timers, self.daily_timers_file)
            return default_timers

        try:
            with open(self.daily_timers_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                self._validate_daily_timers_structure(data)
                return data
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON in daily timers file: {e}")
            raise DatabaseError(f"Corrupt daily timers file: {e}") from e
        except IOError as e:
            logger.error(f"Cannot read daily timers file: {e}")
            raise DatabaseError(f"Cannot read daily timers file: {e}") from e

    def _validate_daily_timers_structure(self, data: Dict[str, Any]) -> None:
        """Validate daily timers data structure.

        Args:
            data: Data to validate

        Raises:
            ValidationError: If data structure is invalid
        """
        if not isinstance(data, dict):
            raise ValidationError("Daily timers data must be a dictionary")
        if "daily_timers" not in data or not isinstance(data["daily_timers"], dict):
            raise ValidationError("Daily timers data must contain 'daily_timers' dictionary")

    def save_daily_timers(self) -> None:
        """Save daily timers to JSON file.

        Raises:
            DatabaseError: If file cannot be saved
        """
        self._save_data_to_file(self.daily_timers, self.daily_timers_file)
        logger.debug(f"Saved daily timers data to {self.daily_timers_file}")

    def get_all_timers(self) -> List[Dict]:
        return self.data.get("timers", [])

    def add_timer(self, name: str, timer_type: str = "stopwatch") -> int:
        """Add a new timer.

        Args:
            name: Timer name
            timer_type: Type of timer ('stopwatch' or 'countdown')

        Returns:
            ID of the created timer

        Raises:
            ValidationError: If input is invalid
            DatabaseError: If timer cannot be saved
        """
        # Validate inputs
        if not name or not name.strip():
            raise ValidationError("Timer name cannot be empty")
        if timer_type not in ("stopwatch", "countdown"):
            raise ValidationError("Timer type must be 'stopwatch' or 'countdown'")

        name = name.strip()

        # Check for duplicate names
        for timer in self.data["timers"]:
            if timer["name"] == name:
                raise ValidationError(f"Timer with name '{name}' already exists")
        timer_id = self.data["next_id"]
        timer = {
            "id": timer_id,
            "name": name,
            "type": timer_type,
            "elapsed_seconds": 0,
            "countdown_seconds": 0,
            "is_running": False,
            "created_at": datetime.now().isoformat(),
            "last_started": None,
        }
        self.data["timers"].append(timer)
        self.data["next_id"] += 1
        self.save_data()
        return timer_id

    def update_timer(self, timer_id: int, updates: Dict[str, Any]) -> bool:
        """Update timer data.

        Args:
            timer_id: ID of timer to update
            updates: Dictionary of fields to update

        Returns:
            True if timer was found and updated, False otherwise

        Raises:
            ValidationError: If update data is invalid
            DatabaseError: If timer cannot be saved
        """
        if not isinstance(timer_id, int) or timer_id <= 0:
            raise ValidationError("Timer ID must be a positive integer")
        if not isinstance(updates, dict) or not updates:
            raise ValidationError("Updates must be a non-empty dictionary")
        for timer in self.data["timers"]:
            if timer["id"] == timer_id:
                timer.update(updates)
                self.save_data()
                return True
        return False

    def delete_timer(self, timer_id: int) -> bool:
        original_length = len(self.data["timers"])
        self.data["timers"] = [t for t in self.data["timers"] if t["id"] != timer_id]
        if len(self.data["timers"]) < original_length:
            self.save_data()
            return True
        return False

    def get_timer(self, timer_id: int) -> Optional[Dict[str, Any]]:
        """Get timer by ID.

        Args:
            timer_id: ID of timer to retrieve

        Returns:
            Timer dictionary or None if not found

        Raises:
            ValidationError: If timer_id is invalid
        """
        if not isinstance(timer_id, int) or timer_id <= 0:
            raise ValidationError("Timer ID must be a positive integer")
        for timer in self.data["timers"]:
            if timer["id"] == timer_id:
                return timer
        return None

    def get_daily_timer_state(self, timer_id: int, date_str: str) -> Dict[str, Any]:
        """Get timer state for a specific date.
        
        Args:
            timer_id: ID of the timer
            date_str: Date string in YYYY-MM-DD format
            
        Returns:
            Dictionary with timer state for that date
        """
        if "daily_states" not in self.daily_states:
            self.daily_states["daily_states"] = {}
            
        if date_str not in self.daily_states["daily_states"]:
            self.daily_states["daily_states"][date_str] = {}
            
        if str(timer_id) not in self.daily_states["daily_states"][date_str]:
            # Create default state for this timer on this date
            # Now storing is_running and last_started per date for date-specific timer behavior
            self.daily_states["daily_states"][date_str][str(timer_id)] = {
                "elapsed_seconds": 0,
                "countdown_seconds": 0,
                "is_running": False,
                "last_started": None
            }
            self.save_daily_states()
            
        return self.daily_states["daily_states"][date_str][str(timer_id)]

    def update_daily_timer_state(self, timer_id: int, date_str: str, updates: Dict[str, Any]) -> None:
        """Update timer state for a specific date.
        
        Args:
            timer_id: ID of the timer
            date_str: Date string in YYYY-MM-DD format
            updates: Dictionary of fields to update
        """
        if "daily_states" not in self.daily_states:
            self.daily_states["daily_states"] = {}
            
        if date_str not in self.daily_states["daily_states"]:
            self.daily_states["daily_states"][date_str] = {}
            
        if str(timer_id) not in self.daily_states["daily_states"][date_str]:
            # Now storing is_running and last_started per date for date-specific timer behavior
            self.daily_states["daily_states"][date_str][str(timer_id)] = {
                "elapsed_seconds": 0,
                "countdown_seconds": 0,
                "is_running": False,
                "last_started": None
            }
            
        self.daily_states["daily_states"][date_str][str(timer_id)].update(updates)
        self.save_daily_states()

    def get_timers_for_date(self, date_str: str) -> List[Dict]:
        """Get all timers for a specific date with smart propagation logic.
        
        Args:
            date_str: Date string in YYYY-MM-DD format
            
        Returns:
            List of timer dictionaries for that date
        """
        if "daily_timers" not in self.daily_timers:
            self.daily_timers["daily_timers"] = {}
            
        # If date already has timers, return them
        if date_str in self.daily_timers["daily_timers"]:
            return self.daily_timers["daily_timers"][date_str]
            
        # Find the most recent date with timers that's <= current date
        recent_date = self._find_most_recent_timer_date(date_str)
        
        if recent_date:
            # Copy timers from most recent date
            base_timers = self.daily_timers["daily_timers"][recent_date].copy()
            # Create new timer set for this date
            self.daily_timers["daily_timers"][date_str] = base_timers
            self.save_daily_timers()
            return base_timers
        
        # No previous timers found, return empty list
        return []
        
    def _find_most_recent_timer_date(self, target_date: str) -> Optional[str]:
        """Find the most recent date with timers that's <= target_date."""
        available_dates = list(self.daily_timers["daily_timers"].keys())
        if not available_dates:
            return None
            
        # Filter dates <= target_date and sort descending
        valid_dates = [d for d in available_dates if d <= target_date]
        if not valid_dates:
            return None
            
        return max(valid_dates)
        
    def add_timer_to_date(self, date_str: str, name: str, timer_type: str = "stopwatch") -> int:
        """Add a timer to a specific date.
        
        Args:
            date_str: Date string in YYYY-MM-DD format
            name: Timer name
            timer_type: Type of timer
            
        Returns:
            Timer ID
        """
        # Create timer in global timers table (for sessions compatibility)
        timer_id = self.add_timer(name, timer_type)
        timer_data = self.get_timer(timer_id)
        
        # Add to date-specific timers
        if "daily_timers" not in self.daily_timers:
            self.daily_timers["daily_timers"] = {}
            
        if date_str not in self.daily_timers["daily_timers"]:
            self.daily_timers["daily_timers"][date_str] = []
            
        self.daily_timers["daily_timers"][date_str].append(timer_data)
        self.save_daily_timers()
        
        # Propagate to future dates that don't have this timer yet
        self._propagate_timer_forward(date_str, timer_data)
        
        return timer_id
        
    def _propagate_timer_forward(self, from_date: str, timer_data: Dict):
        """Propagate a timer to all future dates that need it."""
        from datetime import datetime, timedelta
        
        start_date = datetime.fromisoformat(from_date)
        
        # Find all existing dates after from_date
        existing_dates = [d for d in self.daily_timers["daily_timers"].keys() if d > from_date]
        
        for date_str in existing_dates:
            date_timers = self.daily_timers["daily_timers"][date_str]
            # Check if this timer name already exists
            if not any(t["name"] == timer_data["name"] for t in date_timers):
                date_timers.append(timer_data.copy())
                
        self.save_daily_timers()
        
    def remove_timer_from_date(self, date_str: str, timer_id: int):
        """Remove a timer from a specific date."""
        if (date_str in self.daily_timers.get("daily_timers", {}) and 
            self.daily_timers["daily_timers"][date_str]):
            
            self.daily_timers["daily_timers"][date_str] = [
                t for t in self.daily_timers["daily_timers"][date_str] 
                if t["id"] != timer_id
            ]
            self.save_daily_timers()

    def start_session(self, timer_id: int, project_name: str) -> int:
        """Start a new work session.

        Args:
            timer_id: ID of the timer
            project_name: Name of the project

        Returns:
            ID of the created session

        Raises:
            ValidationError: If inputs are invalid
            DatabaseError: If session cannot be saved
        """
        # Validate inputs
        if not isinstance(timer_id, int) or timer_id <= 0:
            raise ValidationError("Timer ID must be a positive integer")
        if not project_name or not project_name.strip():
            raise ValidationError("Project name cannot be empty")

        project_name = project_name.strip()
        
        # Generate unique session ID
        existing_ids = [s.get("id", 0) for s in self.sessions.get("sessions", [])]
        next_id = max(existing_ids) + 1 if existing_ids else 1
        
        session = {
            "id": next_id,
            "timer_id": timer_id,
            "project_name": project_name,
            "date": date.today().isoformat(),
            "start_time": datetime.now().isoformat(),
            "end_time": None,
            "duration_seconds": 0,
            "is_active": True,
        }

        if "sessions" not in self.sessions:
            self.sessions["sessions"] = []

        self.sessions["sessions"].append(session)
        self.save_sessions()
        return session["id"]

    def end_session(self, session_id: int) -> int:
        """End a work session and return duration.

        Args:
            session_id: ID of session to end

        Returns:
            Duration of session in seconds

        Raises:
            ValidationError: If session_id is invalid
            DatabaseError: If session cannot be saved
        """
        if not isinstance(session_id, int) or session_id <= 0:
            raise ValidationError("Session ID must be a positive integer")
        """End a work session and return duration in seconds"""
        for session in self.sessions.get("sessions", []):
            if session["id"] == session_id and session["is_active"]:
                session["end_time"] = datetime.now().isoformat()
                session["is_active"] = False

                # Calculate duration
                try:
                    start = datetime.fromisoformat(session["start_time"])
                    end = datetime.fromisoformat(session["end_time"])
                    duration = int((end - start).total_seconds())
                except ValueError as e:
                    logger.error(
                        f"Invalid datetime format in session {session_id}: {e}"
                    )
                    raise DatabaseError(f"Invalid session timestamps: {e}") from e
                session["duration_seconds"] = duration

                self.save_sessions()
                return duration
        return 0

    def get_daily_summary(self, target_date: str = None) -> Dict[str, int]:
        """Get project time summary for a specific date"""
        if target_date is None:
            target_date = date.today().isoformat()

        summary = {}
        for session in self.sessions.get("sessions", []):
            if session["date"] == target_date and not session["is_active"]:
                project = session["project_name"]
                duration = session["duration_seconds"]

                if project not in summary:
                    summary[project] = 0
                summary[project] += duration

        return summary

    def get_weekly_summary(self) -> Dict[str, Dict[str, int]]:
        """Get project time summary for the last 7 days"""
        weekly_data = {}

        for i in range(7):
            current_date = (date.today() - timedelta(days=i)).isoformat()
            daily_summary = self.get_daily_summary(current_date)
            if daily_summary:  # Only include days with work
                weekly_data[current_date] = daily_summary

        return weekly_data

    def reset_all_data(self):
        """Reset all data to initial state"""
        # Reset timers data
        self.data = {"timers": [], "next_id": 1}
        self.save_data()

        # Reset sessions data
        self.sessions = {"sessions": []}
        self.save_sessions()

        # Reset daily states data
        self.daily_states = {"daily_states": {}}
        self.save_daily_states()
        
        # Reset daily timers data
        self.daily_timers = {"daily_timers": {}}
        self.save_daily_timers()

        # Remove stats file if it exists
        stats_file = "stats.json"
        if os.path.exists(stats_file):
            os.remove(stats_file)
