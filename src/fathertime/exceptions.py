"""Custom exceptions for Father Time application."""


class FatherTimeError(Exception):
    """Base exception class for Father Time application."""

    pass


class DatabaseError(FatherTimeError):
    """Raised when database operations fail."""

    pass


class TimerError(FatherTimeError):
    """Raised when timer operations fail."""

    pass


class ConfigError(FatherTimeError):
    """Raised when configuration operations fail."""

    pass


class ValidationError(FatherTimeError):
    """Raised when input validation fails."""

    pass
