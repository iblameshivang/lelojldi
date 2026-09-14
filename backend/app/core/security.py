"""
Security utilities: JWT tokens, password hashing, device signatures.
"""
from datetime import datetime, timedelta, timezone
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.config import settings

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain password against its hash."""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Hash a password using bcrypt."""
    return pwd_context.hash(password)


def create_access_token(
    data: dict,
    expires_delta: Optional[timedelta] = None,
) -> str:
    """Create a JWT access token."""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode.update({"exp": expire, "iat": datetime.now(timezone.utc)})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_access_token(token: str) -> Optional[dict]:
    """Decode and verify a JWT access token."""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None


def hash_aadhaar(aadhaar_number: str) -> str:
    """One-way hash of Aadhaar number for privacy-preserving storage."""
    import hashlib
    salted = f"krishi_saarthi_aadhaar_{aadhaar_number}_salt_2026"
    return hashlib.sha256(salted.encode()).hexdigest()


def hash_phone(phone_number: str) -> str:
    """One-way hash of phone number for privacy-preserving storage."""
    import hashlib
    salted = f"krishi_saarthi_phone_{phone_number}_salt_2026"
    return hashlib.sha256(salted.encode()).hexdigest()
