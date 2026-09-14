"""
Custom exception classes for Krishi-Saarthi.
"""
from typing import Any, Optional


class KrishiSaarthiException(Exception):
    """Base exception for all Krishi-Saarthi errors."""

    def __init__(
        self,
        message: str = "An error occurred",
        status_code: int = 500,
        error_code: str = "INTERNAL_ERROR",
        detail: Optional[Any] = None,
    ):
        self.message = message
        self.status_code = status_code
        self.error_code = error_code
        self.detail = detail
        super().__init__(self.message)


class AuthenticationError(KrishiSaarthiException):
    def __init__(self, message: str = "Authentication failed", detail: Optional[Any] = None):
        super().__init__(message=message, status_code=401, error_code="AUTH_ERROR", detail=detail)


class AuthorizationError(KrishiSaarthiException):
    def __init__(self, message: str = "Not authorized", detail: Optional[Any] = None):
        super().__init__(message=message, status_code=403, error_code="FORBIDDEN", detail=detail)


class NotFoundError(KrishiSaarthiException):
    def __init__(self, resource: str = "Resource", detail: Optional[Any] = None):
        super().__init__(
            message=f"{resource} not found",
            status_code=404,
            error_code="NOT_FOUND",
            detail=detail,
        )


class ValidationError(KrishiSaarthiException):
    def __init__(self, message: str = "Validation failed", detail: Optional[Any] = None):
        super().__init__(message=message, status_code=422, error_code="VALIDATION_ERROR", detail=detail)


class ConflictError(KrishiSaarthiException):
    def __init__(self, message: str = "Resource conflict", detail: Optional[Any] = None):
        super().__init__(message=message, status_code=409, error_code="CONFLICT", detail=detail)


class DeviceSignatureError(KrishiSaarthiException):
    def __init__(self, message: str = "Invalid device signature", detail: Optional[Any] = None):
        super().__init__(message=message, status_code=401, error_code="SIGNATURE_INVALID", detail=detail)


class MeshPacketError(KrishiSaarthiException):
    def __init__(self, message: str = "Mesh packet error", detail: Optional[Any] = None):
        super().__init__(message=message, status_code=400, error_code="MESH_ERROR", detail=detail)


class SyncConflictError(KrishiSaarthiException):
    def __init__(self, message: str = "Sync conflict detected", detail: Optional[Any] = None):
        super().__init__(message=message, status_code=409, error_code="SYNC_CONFLICT", detail=detail)
