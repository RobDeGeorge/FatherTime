.PHONY: help install install-dev test lint format type-check clean run

# Default target
help:
	@echo "Available targets:"
	@echo "  install      - Install production dependencies"
	@echo "  install-dev  - Install development dependencies"
	@echo "  test         - Run tests"
	@echo "  lint         - Run linting (flake8)"
	@echo "  format       - Format code (black, isort)"
	@echo "  type-check   - Run type checking (mypy)"
	@echo "  clean        - Clean build artifacts"
	@echo "  run          - Run the application"
	@echo "  qa           - Run all quality checks (lint, type-check, test)"

# Install production dependencies
install:
	pip install -r requirements.txt

# Install development dependencies
install-dev:
	pip install -r requirements.txt

# Run tests
test:
	python -m pytest tests/ -v

# Run linting
lint:
	python -m flake8 .

# Format code
format:
	python -m black .
	python -m isort .

# Type checking
type-check:
	python -m mypy .

# Clean build artifacts
clean:
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	rm -rf build/ dist/ .pytest_cache/ .mypy_cache/

# Run the application
run:
	./run

# Run all quality assurance checks
qa: lint type-check test
	@echo "All quality checks passed!"

# Development workflow
dev-setup: install-dev
	@echo "Development environment set up!"
	@echo "Run 'make qa' to check code quality"
	@echo "Run 'make run' to start the application"