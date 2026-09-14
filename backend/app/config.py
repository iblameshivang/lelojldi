"""
Krishi-Saarthi Backend Configuration
Pydantic Settings for all environment variables
"""
from pydantic_settings import BaseSettings
from functools import lru_cache
from typing import Optional


class Settings(BaseSettings):
    # ─── Application ───
    APP_NAME: str = "Krishi-Saarthi API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True

    # ─── Database ───
    DATABASE_URL: str = "postgresql+asyncpg://krishi_admin:krishi_secure_2026@localhost:5432/krishi_saarthi_master"
    DATABASE_URL_SYNC: str = "postgresql+psycopg2://krishi_admin:krishi_secure_2026@localhost:5432/krishi_saarthi_master"

    # ─── Redis ───
    REDIS_URL: str = "redis://localhost:6379/0"

    # ─── Security ───
    SECRET_KEY: str = "krishi-saarthi-super-secret-jwt-key-change-in-production-2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080  # 7 days

    # ─── External APIs ───
    IMD_API_KEY: str = ""
    IMD_API_URL: str = "https://api.imd.gov.in/v1"
    AGMARKNET_API_KEY: str = ""
    AGMARKNET_API_URL: str = "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
    OGD_API_KEY: str = ""

    # ─── AI & Basemaps (Protected Free-Tier Quota Guards) ───
    GEMINI_API_KEY: str = ""
    GEMINI_RATE_LIMIT_PER_HOUR: int = 15
    CARTO_API_KEY: str = ""
    CARTO_RATE_LIMIT_PER_HOUR: int = 15

    # ─── USSD ───
    USSD_SHORT_CODE: str = "*123#"
    USSD_GATEWAY_URL: str = ""

    # ─── MinIO (S3-compatible) ───
    MINIO_ENDPOINT: str = "localhost:9000"
    MINIO_ACCESS_KEY: str = "krishiminio"
    MINIO_SECRET_KEY: str = "minio_secure_2026"
    MINIO_BUCKET: str = "krishi-saarthi"
    MINIO_USE_SSL: bool = False

    # ─── Kriging ───
    KRIGING_GRID_SIZE: int = 100
    KRIGING_PREDICTION_HOURS: int = 72

    # ─── Celery ───
    CELERY_BROKER_URL: str = "redis://localhost:6379/1"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/2"

    # ─── CORS ───
    CORS_ORIGINS: list[str] = ["*"]

    class Config:
        # Check both local and parent directory for .env files
        env_file = (".env", "backend/.env", "../.env")
        env_file_encoding = "utf-8"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    cfg = Settings()
    # Security check: alert if insecure placeholder key is used in production
    if not cfg.DEBUG and ("change-in-production" in cfg.SECRET_KEY or "super-secret" in cfg.SECRET_KEY):
        import logging
        logging.getLogger("security").critical(
            "CRITICAL SECURITY RISK: Insecure default SECRET_KEY detected in production mode! "
            "Please set a cryptographically secure SECRET_KEY in your environment."
        )
    return cfg


settings = get_settings()
