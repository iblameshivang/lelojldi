"""
SQLAlchemy async engine and base model.
"""
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import DeclarativeBase, sessionmaker
from app.config import settings

from pathlib import Path

# Normalize SQLite database path to ensure seamless resolution from root or backend directories
db_url = settings.DATABASE_URL
if "sqlite" in db_url and ":///" in db_url:
    backend_dir = Path(__file__).resolve().parent.parent.parent
    db_file = db_url.split(":///")[-1]
    if not db_file.startswith("/"):
        clean_name = Path(db_file.lstrip("./")).name
        abs_path = backend_dir / clean_name
        driver = db_url.split(":///")[0]
        db_url = f"{driver}:///{abs_path}"

engine_kwargs = {"echo": settings.DEBUG}
if "sqlite" in db_url:
    engine_kwargs["connect_args"] = {"check_same_thread": False}
else:
    engine_kwargs.update({
        "pool_size": 20,
        "max_overflow": 10,
        "pool_pre_ping": True,
    })

engine = create_async_engine(
    db_url,
    **engine_kwargs
)

AsyncSessionLocal = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


class Base(DeclarativeBase):
    """Base class for all SQLAlchemy models."""
    pass
