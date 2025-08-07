"""Security and validation tests for Father Time application."""

import tempfile
from pathlib import Path
import pytest

from src.fathertime.config_manager import ConfigManager
from src.fathertime.database import Database
from src.fathertime.exceptions import ConfigError, ValidationError, DatabaseError


class TestConfigManagerSecurity:
    """Test security features in ConfigManager."""

    def setup_method(self):
        """Set up test fixtures."""
        self.temp_dir = Path(tempfile.mkdtemp())

    def teardown_method(self):
        """Clean up test fixtures."""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_path_traversal_prevention(self):
        """Test that path traversal attempts are blocked."""
        # Test various path traversal patterns
        malicious_paths = [
            "../etc/passwd",
            "../../root/.ssh/id_rsa", 
            "/etc/shadow",
            "~/.ssh/config",
            "$HOME/.bashrc",
            "..\\..\\windows\\system32",
        ]
        
        for malicious_path in malicious_paths:
            with pytest.raises(ConfigError, match="dangerous components|restricted system directory"):
                ConfigManager(data_dir=malicious_path)

    def test_config_filename_validation(self):
        """Test that dangerous config filenames are rejected."""
        dangerous_filenames = [
            "../malicious.json",  # Path traversal
            "/etc/passwd",        # Absolute path
            "config|rm -rf /",    # Command injection
            "config;cat /etc/passwd",  # Command chaining
            "config&whoami",      # Command background
            "config$(rm -rf)",    # Command substitution
        ]
        
        for dangerous_name in dangerous_filenames:
            with pytest.raises(ConfigError, match="contains invalid characters|cannot be an absolute path"):
                ConfigManager(config_file=dangerous_name, data_dir=str(self.temp_dir))
                
    def test_valid_config_paths_allowed(self):
        """Test that valid relative config paths are accepted."""
        valid_paths = [
            "config.json",
            "src/config.json", 
            "data/app/config.json",
        ]
        
        for valid_path in valid_paths:
            try:
                config_manager = ConfigManager(config_file=valid_path, data_dir=str(self.temp_dir))
                # Should not raise exception
            except ConfigError as e:
                if "invalid characters" in str(e):
                    pytest.fail(f"Valid path {valid_path} was incorrectly rejected: {e}")

    def test_file_permissions_set_correctly(self):
        """Test that config files are created with secure permissions."""
        config_manager = ConfigManager(data_dir=str(self.temp_dir))
        config_manager.update_color("primary", "#ff0000")
        
        # Check file permissions (owner read/write only = 0o600)
        config_file = config_manager.config_file
        assert config_file.exists()
        assert oct(config_file.stat().st_mode)[-3:] == '600'

    def test_long_path_rejection(self):
        """Test that extremely long paths are rejected."""
        long_path = "a" * 300  # 300 characters
        with pytest.raises(ConfigError, match="path too long"):
            ConfigManager(data_dir=long_path)


class TestDatabaseSecurity:
    """Test security features in Database."""

    def setup_method(self):
        """Set up test fixtures."""
        self.temp_dir = Path(tempfile.mkdtemp())
        self.db = Database(data_dir=str(self.temp_dir))

    def teardown_method(self):
        """Clean up test fixtures."""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_timer_name_sanitization(self):
        """Test that timer names are properly sanitized."""
        # Test script injection attempts
        malicious_names = [
            "<script>alert('xss')</script>",
            "javascript:alert('xss')",
            "<iframe src='evil.com'></iframe>",
            "onclick='malicious()'",
            "<object data='evil.swf'></object>",
        ]
        
        for malicious_name in malicious_names:
            with pytest.raises(ValidationError, match="potentially dangerous content"):
                self.db.add_timer(malicious_name, "stopwatch")

    def test_timer_name_character_validation(self):
        """Test that only safe characters are allowed in timer names."""
        invalid_names = [
            "timer<script>",
            "timer\\x00null",
            "timer\n\r\t",
            "timer|pipe", 
            "timer;semicolon",
            "timer&ampersand",
        ]
        
        for invalid_name in invalid_names:
            with pytest.raises(ValidationError, match="invalid characters|dangerous content"):
                self.db.add_timer(invalid_name, "stopwatch")

    def test_timer_name_length_limits(self):
        """Test that timer names have reasonable length limits."""
        # Test empty names
        with pytest.raises(ValidationError, match="empty"):
            self.db.add_timer("", "stopwatch")
            
        with pytest.raises(ValidationError, match="empty"):
            self.db.add_timer("   ", "stopwatch")

        # Test extremely long names
        long_name = "a" * 101  # 101 characters
        with pytest.raises(ValidationError, match="too long"):
            self.db.add_timer(long_name, "stopwatch")

    def test_project_name_sanitization(self):
        """Test that project names are properly sanitized."""
        # First create a timer
        timer_id = self.db.add_timer("Test Timer", "stopwatch")
        
        # Test malicious project names
        malicious_projects = [
            "<script>alert('project')</script>",
            "javascript:void(0)",
            "<iframe src='malicious.com'></iframe>",
        ]
        
        for malicious_project in malicious_projects:
            with pytest.raises(ValidationError, match="potentially dangerous content"):
                self.db.start_session(timer_id, malicious_project)

    def test_data_file_permissions(self):
        """Test that data files are created with secure permissions."""
        # Create some data
        timer_id = self.db.add_timer("Test Timer", "stopwatch")
        self.db.start_session(timer_id, "Test Project")
        
        # Force immediate save to create files
        self.db.save_data(immediate=True)
        self.db.save_sessions(immediate=True)
        self.db.save_daily_states(immediate=True)
        
        # Check permissions on all data files
        data_files = [
            self.db.db_file,
            self.db.sessions_file,
            self.db.daily_states_file,
        ]
        
        for data_file in data_files:
            if data_file.exists():
                # Check file permissions (owner read/write only = 0o600)
                assert oct(data_file.stat().st_mode)[-3:] == '600'

    def test_timer_id_validation(self):
        """Test that timer IDs are properly validated."""
        invalid_ids = [
            0,        # Zero
            -1,       # Negative
            "abc",    # String
            None,     # None
            3.14,     # Float
        ]
        
        for invalid_id in invalid_ids:
            with pytest.raises(ValidationError, match="positive integer"):
                self.db.start_session(invalid_id, "Test Project")

    def test_batch_saving_security(self):
        """Test that batch saving doesn't compromise security."""
        # Create data that will be batch saved
        timer_id = self.db.add_timer("Batch Test", "stopwatch")
        session_id = self.db.start_session(timer_id, "Batch Project")
        
        # Trigger batch save
        self.db._batch_save_all()
        
        # Verify files still have secure permissions
        if self.db.db_file.exists():
            assert oct(self.db.db_file.stat().st_mode)[-3:] == '600'
        if self.db.sessions_file.exists():
            assert oct(self.db.sessions_file.stat().st_mode)[-3:] == '600'


class TestInputValidation:
    """Test comprehensive input validation across modules."""

    def setup_method(self):
        """Set up test fixtures."""
        self.temp_dir = Path(tempfile.mkdtemp())
        self.db = Database(data_dir=str(self.temp_dir))

    def teardown_method(self):
        """Clean up test fixtures."""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_type_validation(self):
        """Test that proper types are enforced."""
        # Test non-string timer names
        with pytest.raises(ValidationError, match="non-empty string"):
            self.db.add_timer(123, "stopwatch")
            
        with pytest.raises(ValidationError, match="non-empty string"):
            self.db.add_timer(None, "stopwatch")
            
        with pytest.raises(ValidationError, match="non-empty string"):
            self.db.add_timer([], "stopwatch")

    def test_whitespace_handling(self):
        """Test proper whitespace normalization."""
        # Test that multiple spaces are normalized
        timer_id = self.db.add_timer("Test    Timer    Name", "stopwatch")
        timer = self.db.get_timer(timer_id)
        assert timer["name"] == "Test Timer Name"  # Multiple spaces reduced to one

    def test_unicode_handling(self):
        """Test that Unicode characters are handled safely."""
        # Test valid Unicode
        timer_id = self.db.add_timer("测试计时器", "stopwatch")  # Chinese characters
        timer = self.db.get_timer(timer_id)
        assert timer["name"] == "测试计时器"
        
        # Test Unicode with emojis (should be rejected)
        with pytest.raises(ValidationError, match="invalid characters"):
            self.db.add_timer("Timer 🚀 Rocket", "stopwatch")


class TestPerformanceSecurity:
    """Test that security measures don't create performance vulnerabilities."""

    def setup_method(self):
        """Set up test fixtures."""
        self.temp_dir = Path(tempfile.mkdtemp())
        self.db = Database(data_dir=str(self.temp_dir))

    def teardown_method(self):
        """Clean up test fixtures."""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_validation_performance(self):
        """Test that validation doesn't create DoS opportunities."""
        import time
        
        # Test that validation time is reasonable even for edge cases
        start_time = time.time()
        
        # Try to create many timers with various names
        for i in range(50):
            try:
                self.db.add_timer(f"Timer {i:03d}", "stopwatch")
            except ValidationError:
                pass  # Expected for some test cases
                
        end_time = time.time()
        
        # Should complete in under 1 second
        assert (end_time - start_time) < 1.0

    def test_regex_safety(self):
        """Test that regex patterns don't create ReDoS vulnerabilities."""
        import time
        
        # Test potentially problematic input that could cause catastrophic backtracking
        problematic_input = "a" * 1000 + "!"
        
        start_time = time.time()
        try:
            self.db.add_timer(problematic_input, "stopwatch")
        except ValidationError:
            pass  # Expected
        end_time = time.time()
        
        # Should complete quickly (under 0.1 seconds)
        assert (end_time - start_time) < 0.1