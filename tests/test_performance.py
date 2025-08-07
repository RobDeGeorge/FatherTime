"""Performance tests for Father Time application."""

import tempfile
import time
from pathlib import Path
import pytest

from src.fathertime.database import Database
from src.fathertime.timer_manager import TimerManager


class TestDatabasePerformance:
    """Test database performance optimizations."""

    def setup_method(self):
        """Set up test fixtures."""
        self.temp_dir = Path(tempfile.mkdtemp())
        self.db = Database(data_dir=str(self.temp_dir))

    def teardown_method(self):
        """Clean up test fixtures."""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_batch_saving_efficiency(self):
        """Test that batch saving reduces I/O operations."""
        # Disable batch timer for controlled testing
        if hasattr(self.db, '_batch_save_timer') and self.db._batch_save_timer:
            self.db._batch_save_timer.stop()
            
        # Create multiple timers and sessions
        timer_ids = []
        for i in range(10):
            timer_id = self.db.add_timer(f"Timer {i}", "stopwatch")
            timer_ids.append(timer_id)
            self.db.start_session(timer_id, f"Project {i}")
        
        # Test immediate saves (old behavior)
        start_time = time.time()
        for _ in range(5):
            self.db.save_data(immediate=True)
            self.db.save_sessions(immediate=True)
            self.db.save_daily_states(immediate=True)
        immediate_time = time.time() - start_time
        
        # Test batch saves (new behavior) 
        start_time = time.time()
        for _ in range(5):
            self.db._mark_for_save('data')
            self.db._mark_for_save('sessions')
            self.db._mark_for_save('daily_states')
        self.db._batch_save_all()
        batch_time = time.time() - start_time
        
        # Batch saving should be significantly faster
        assert batch_time < immediate_time / 2

    def test_large_dataset_performance(self):
        """Test performance with large datasets."""
        # Create a large number of timers and sessions
        start_time = time.time()
        
        timer_ids = []
        for i in range(100):
            timer_id = self.db.add_timer(f"Timer {i:03d}", "stopwatch")
            timer_ids.append(timer_id)
            
        creation_time = time.time() - start_time
        
        # Test session creation performance
        start_time = time.time()
        for timer_id in timer_ids:
            self.db.start_session(timer_id, f"Project {timer_id}")
            
        session_time = time.time() - start_time
        
        # Should complete in reasonable time
        assert creation_time < 2.0  # 100 timers in under 2 seconds
        assert session_time < 2.0   # 100 sessions in under 2 seconds

    def test_data_file_size_optimization(self):
        """Test that data files don't grow excessively."""
        # Create some data
        timer_id = self.db.add_timer("Size Test Timer", "stopwatch")
        
        # Create many sessions
        session_ids = []
        for i in range(50):
            session_id = self.db.start_session(timer_id, f"Project {i}")
            session_ids.append(session_id)
            
        # Force save to disk
        self.db.save_data(immediate=True)
        self.db.save_sessions(immediate=True)
        
        # Check file sizes are reasonable
        if self.db.db_file.exists():
            db_size = self.db.db_file.stat().st_size
            assert db_size < 100000  # Under 100KB for test data
            
        if self.db.sessions_file.exists():
            sessions_size = self.db.sessions_file.stat().st_size
            assert sessions_size < 500000  # Under 500KB for 50 sessions


class TestTimerManagerPerformance:
    """Test timer manager performance optimizations."""

    @pytest.fixture(autouse=True)
    def setup_qt_app(self):
        """Set up Qt application for testing."""
        from PySide6.QtWidgets import QApplication
        import sys
        
        # Create QApplication if it doesn't exist
        if not QApplication.instance():
            self.app = QApplication(sys.argv)
        else:
            self.app = QApplication.instance()
        
        yield
        
        # Clean up is handled by Qt

    def test_consolidated_timer_efficiency(self):
        """Test that consolidated timer system is more efficient."""
        timer_manager = TimerManager()
        
        # Add several timers
        timer_manager.addTimer("Test Timer 1", "stopwatch")
        timer_manager.addTimer("Test Timer 2", "stopwatch") 
        timer_manager.addTimer("Test Timer 3", "stopwatch")
        
        # The consolidated timer should only have one QTimer running
        assert hasattr(timer_manager, 'main_timer')
        assert timer_manager.main_timer.isActive()
        
        # Old separate timers should not exist
        assert not hasattr(timer_manager, 'update_timer')
        assert not hasattr(timer_manager, 'day_check_timer')
        assert not hasattr(timer_manager, 'breakdown_timer')

    def test_running_timer_set_optimization(self):
        """Test that only running timers are tracked for updates."""
        timer_manager = TimerManager()
        
        # Add timers but don't start them
        timer_manager.addTimer("Stopped Timer 1", "stopwatch")
        timer_manager.addTimer("Stopped Timer 2", "stopwatch")
        
        # Running timer set should be empty
        assert len(timer_manager._running_timer_ids) == 0
        
        # Start one timer
        if timer_manager._timers:
            timer_id = timer_manager._timers[0].id
            timer_manager.startTimer(timer_id)
            
            # Now running timer set should have one timer
            assert len(timer_manager._running_timer_ids) == 1
            assert timer_id in timer_manager._running_timer_ids

    def test_timer_update_performance(self):
        """Test that timer updates are performant."""
        timer_manager = TimerManager()
        
        # Add and start multiple timers
        timer_ids = []
        for i in range(5):
            timer_manager.addTimer(f"Perf Timer {i}", "stopwatch")
            if timer_manager._timers:
                timer_id = timer_manager._timers[-1].id
                timer_ids.append(timer_id)
                timer_manager.startTimer(timer_id)
        
        # Measure update performance
        start_time = time.time()
        
        # Simulate many timer updates
        for _ in range(100):
            timer_manager._consolidated_timer_update()
            
        update_time = time.time() - start_time
        
        # Should complete quickly
        assert update_time < 1.0  # 100 updates in under 1 second

    def test_memory_usage_stability(self):
        """Test that memory usage doesn't grow excessively."""
        import gc
        import sys
        
        timer_manager = TimerManager()
        
        # Get initial reference count
        initial_refs = len(gc.get_objects())
        
        # Create and destroy many timers
        for i in range(20):
            timer_manager.addTimer(f"Memory Test {i}", "stopwatch")
            
        # Force garbage collection
        gc.collect()
        
        # Check that we don't have excessive object growth
        final_refs = len(gc.get_objects())
        growth = final_refs - initial_refs
        
        # Some growth is expected, but not excessive
        assert growth < 1000  # Less than 1000 new objects for 20 timers


class TestRegularExpressionPerformance:
    """Test that regex patterns are optimized and safe."""

    def setup_method(self):
        """Set up test fixtures."""
        self.temp_dir = Path(tempfile.mkdtemp())
        self.db = Database(data_dir=str(self.temp_dir))

    def teardown_method(self):
        """Clean up test fixtures."""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_validation_regex_performance(self):
        """Test that validation regex patterns perform well."""
        # Test normal cases
        start_time = time.time()
        for i in range(1000):
            try:
                self.db._sanitize_timer_name(f"Normal Timer {i}")
            except:
                pass
        normal_time = time.time() - start_time
        
        # Should be very fast for normal input
        assert normal_time < 0.5  # 1000 validations in under 0.5 seconds
        
    def test_pathological_regex_input(self):
        """Test that regex patterns handle pathological input safely."""
        # Create input that could cause catastrophic backtracking
        pathological_inputs = [
            "a" * 1000,  # Very long input
            "(" * 100 + ")" * 100,  # Many parentheses
            "<" * 100 + "script" + ">" * 100,  # Potential XSS pattern
        ]
        
        for pathological_input in pathological_inputs:
            start_time = time.time()
            try:
                self.db._sanitize_timer_name(pathological_input)
            except:
                pass  # Expected to fail validation
            validation_time = time.time() - start_time
            
            # Should complete quickly even with pathological input
            assert validation_time < 0.1


class TestConcurrencyPerformance:
    """Test performance under concurrent operations."""

    def setup_method(self):
        """Set up test fixtures."""
        self.temp_dir = Path(tempfile.mkdtemp())
        self.db = Database(data_dir=str(self.temp_dir))

    def teardown_method(self):
        """Clean up test fixtures."""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_concurrent_timer_operations(self):
        """Test that concurrent timer operations don't cause performance issues."""
        import threading
        
        results = []
        
        def create_timers(thread_id):
            """Create timers in a separate thread."""
            thread_results = []
            try:
                for i in range(10):
                    start_time = time.time()
                    timer_id = self.db.add_timer(f"Thread {thread_id} Timer {i}", "stopwatch")
                    creation_time = time.time() - start_time
                    thread_results.append(creation_time)
                results.extend(thread_results)
            except Exception as e:
                results.append(f"Error: {e}")
        
        # Create multiple threads
        threads = []
        for i in range(3):
            thread = threading.Thread(target=create_timers, args=(i,))
            threads.append(thread)
        
        # Start all threads
        start_time = time.time()
        for thread in threads:
            thread.start()
            
        # Wait for completion
        for thread in threads:
            thread.join()
        total_time = time.time() - start_time
        
        # Should complete in reasonable time
        assert total_time < 5.0  # All operations in under 5 seconds
        
        # Check that individual operations were reasonably fast
        numeric_results = [r for r in results if isinstance(r, (int, float))]
        if numeric_results:
            avg_time = sum(numeric_results) / len(numeric_results)
            assert avg_time < 0.1  # Average under 0.1 seconds per operation