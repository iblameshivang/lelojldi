"""
Database session and dependency injection.
"""
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base import AsyncSessionLocal, engine


async def get_db() -> AsyncSession:
    """FastAPI dependency that provides an async database session."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
