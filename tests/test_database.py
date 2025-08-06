"""Tests for database module."""

import tempfile
from pathlib import Path

import pytest

from database import Database
from exceptions import DatabaseError, ValidationError


class TestDatabase:
    """Test cases for Database class."""

    def setup_method(self):
        """Set up test fixtures."""
        self.temp_dir = Path(tempfile.mkdtemp())
        self.db = Database(data_dir=str(self.temp_dir))

    def teardown_method(self):
        """Clean up test fixtures."""
        import shutil

        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_initialization(self):
        """Test database initialization."""
        assert self.db.data_dir == self.temp_dir
        assert "timers" in self.db.data
        assert "next_id" in self.db.data
        assert isinstance(self.db.data["timers"], list)
        assert isinstance(self.db.data["next_id"], int)

    def test_add_timer_valid(self):
        """Test adding a valid timer."""
        timer_id = self.db.add_timer("Test Timer", "stopwatch")
        assert isinstance(timer_id, int)
        assert timer_id > 0

        timer = self.db.get_timer(timer_id)
        assert timer is not None
        assert timer["name"] == "Test Timer"
        assert timer["type"] == "stopwatch"

    def test_add_timer_invalid_name(self):
        """Test adding timer with invalid name."""
        with pytest.raises(ValidationError):
            self.db.add_timer("", "stopwatch")

        with pytest.raises(ValidationError):
            self.db.add_timer("   ", "stopwatch")

    def test_add_timer_invalid_type(self):
        """Test adding timer with invalid type."""
        with pytest.raises(ValidationError):
            self.db.add_timer("Test", "invalid_type")

    def test_add_timer_duplicate_name(self):
        """Test adding timer with duplicate name."""
        self.db.add_timer("Test Timer", "stopwatch")
        with pytest.raises(ValidationError):
            self.db.add_timer("Test Timer", "countdown")

    def test_get_timer_invalid_id(self):
        """Test getting timer with invalid ID."""
        with pytest.raises(ValidationError):
            self.db.get_timer(0)

        with pytest.raises(ValidationError):
            self.db.get_timer(-1)

        with pytest.raises(ValidationError):
            self.db.get_timer("invalid")

    def test_update_timer(self):
        """Test updating timer."""
        timer_id = self.db.add_timer("Test Timer", "stopwatch")

        success = self.db.update_timer(timer_id, {"elapsed_seconds": 100})
        assert success is True

        timer = self.db.get_timer(timer_id)
        assert timer["elapsed_seconds"] == 100

    def test_start_session_valid(self):
        """Test starting a valid session."""
        timer_id = self.db.add_timer("Work Timer", "stopwatch")
        session_id = self.db.start_session(timer_id, "Project A")

        assert isinstance(session_id, int)
        assert session_id > 0

    def test_start_session_invalid_inputs(self):
        """Test starting session with invalid inputs."""
        with pytest.raises(ValidationError):
            self.db.start_session(0, "Project")

        with pytest.raises(ValidationError):
            self.db.start_session(1, "")

        with pytest.raises(ValidationError):
            self.db.start_session(1, "   ")

    def test_data_persistence(self):
        """Test that data persists across database instances."""
        # Add data to first instance
        timer_id = self.db.add_timer("Persistent Timer", "stopwatch")

        # Create new database instance with same directory
        db2 = Database(data_dir=str(self.temp_dir))

        # Verify data persisted
        timer = db2.get_timer(timer_id)
        assert timer is not None
        assert timer["name"] == "Persistent Timer"


class TestDatabaseErrorHandling:
    """Test database error handling."""

    def test_corrupt_json_file(self):
        """Test handling of corrupt JSON file."""
        temp_dir = Path(tempfile.mkdtemp())
        db_file = temp_dir / "timers.json"

        # Write invalid JSON
        db_file.write_text("invalid json content")

        with pytest.raises(DatabaseError):
            Database(data_dir=str(temp_dir))

        # Cleanup
        import shutil

        shutil.rmtree(temp_dir, ignore_errors=True)

    def test_permission_error(self):
        """Test handling of permission errors."""
        # This test would need special setup to create permission errors
        # Skipping for now as it's platform-specific
        pass
