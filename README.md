# Father Time

A clean, modern time tracker application built with PySide6 and QML. Track your project time with multiple labeled timers, countdown timers, and manual time adjustments.

## Features

- **Multiple Timers**: Create multiple labeled stopwatch timers
- **Countdown Timers**: Set countdown timers with hours, minutes, and seconds
- **Time Adjustment**: Add or subtract time manually in case you miss tracking
- **Clean UI**: Modern, minimal interface with clear visual feedback
- **JSON Database**: Simple JSON file storage for persistence
- **Manual Control**: Mostly manual operation as requested

## Requirements

- Python 3.7+
- PySide6

## Installation and Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/RobDeGeorge/FatherTime.git
   cd FatherTime
   ```

2. **Create and activate virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   make install
   # or manually: pip install -r requirements.txt
   ```

## Usage

### Running the Application

**Option 1 - Using Makefile (recommended):**
```bash
make run
```

**Option 2 - Using run script:**
```bash
./run
```

**Option 3 - Direct execution:**
```bash
python main.py
```

## Building Executable

To create a standalone .exe (Windows) or executable (Linux/Mac):

### Quick Build
```bash
make build
```

### Manual Build Process
```bash
# Activate virtual environment
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install build dependencies
pip install pyinstaller>=5.0.0

# Build executable
python build.py
```

### Build Options

**Standard Build (no console):**
```bash
make build
```

**Debug Build (with console for troubleshooting):**
```bash
make build-dev
```

**Custom Build:**
```bash
# Edit build.spec file for advanced options
pyinstaller --clean --noconfirm build.spec
```

### Build Output

The executable will be created in the `dist/` directory:
- **Windows**: `dist/FatherTime.exe`
- **Linux/Mac**: `dist/FatherTime`

The executable includes all dependencies and can be distributed without requiring Python installation.

### Controls

- **+ Stopwatch**: Create a new stopwatch timer
- **+ Countdown**: Create a new countdown timer with custom time
- **Start/Stop**: Start or stop any timer
- **Reset**: Reset timer to zero
- **Time Adjustment**: Use -1m, -1s, +1s, +1m buttons to adjust time manually
- **Delete Timer**: Remove a timer completely

### Data Storage

Timer data is automatically saved to JSON files in the `data/` directory:
- `data/timers.json` - Main timer data
- `data/sessions.json` - Session history
- `data/daily_timers.json` - Daily timer data
- `data/daily_timer_states.json` - Daily timer states

## Development

### Available Make Commands

```bash
make help          # Show all available commands
make install       # Install production dependencies
make test          # Run tests
make lint          # Run linting (flake8)
make format        # Format code (black, isort)
make type-check    # Run type checking (mypy)
make qa            # Run all quality checks
make clean         # Clean build artifacts
make run           # Run the application
make build         # Build executable
make build-dev     # Build executable with debug console
```

### Project Structure

```
FatherTime/
├── main.py                    # Application entry point
├── run                        # Executable script to run the app
├── Makefile                   # Build and development commands
├── README.md                  # This file
├── requirements.txt           # Python dependencies
├── .gitignore                 # Git ignore patterns
├── src/                       # Source code
│   ├── fathertime/           # Main application package
│   │   ├── __init__.py
│   │   ├── config.py         # Configuration constants
│   │   ├── config_manager.py # Configuration management
│   │   ├── database.py       # JSON database operations
│   │   ├── exceptions.py     # Custom exception classes
│   │   ├── logger.py         # Logging setup
│   │   └── timer_manager.py  # Timer logic and Qt integration
│   └── config/               # Configuration files
│       ├── config.json
│       ├── pyproject.toml
│       └── setup.cfg
├── data/                      # Data files (auto-created)
│   ├── timers.json
│   ├── sessions.json
│   ├── daily_timers.json
│   └── daily_timer_states.json
├── ui/                        # QML user interface files
│   ├── main.qml              # Main application UI
│   └── TimerCard.qml         # Individual timer component
├── tests/                     # Test files
│   ├── __init__.py
│   ├── test_config_manager.py
│   └── test_database.py
├── docs/                      # Documentation
│   └── CLEANUP_REPORT.md
└── venv/                      # Virtual environment (excluded from git)
```

## Architecture

The application follows a clean layered architecture:

- **Foundation Layer**: `exceptions.py`, `logger.py`, `config.py`
- **Data Layer**: `database.py`, `config_manager.py`
- **Business Logic**: `timer_manager.py`
- **Presentation**: `main.py`, QML files in `ui/`

All dependencies flow in one direction with no circular imports, making the codebase maintainable and testable.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run quality checks: `make qa`
5. Submit a pull request

## License

[Add your license information here]