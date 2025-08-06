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

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

Run the application:
```bash
python run.py
```

### Controls

- **+ Stopwatch**: Create a new stopwatch timer
- **+ Countdown**: Create a new countdown timer with custom time
- **Start/Stop**: Start or stop any timer
- **Reset**: Reset timer to zero
- **Time Adjustment**: Use -1m, -1s, +1s, +1m buttons to adjust time manually
- **Delete Timer**: Remove a timer completely

### Data Storage

Timer data is automatically saved to `timers.json` in the application directory.

## Project Structure

```
_FatherTime/
├── main.py              # Application entry point
├── run.py               # Convenience runner script
├── timer_manager.py     # Timer logic and Qt integration
├── database.py          # JSON database handler
├── requirements.txt     # Python dependencies
├── ui/
│   ├── main.qml        # Main application UI
│   └── TimerCard.qml   # Individual timer component
└── timers.json         # Data storage (created automatically)
```# FatherTime
