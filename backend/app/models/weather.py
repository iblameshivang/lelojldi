"""
Weather cache model - Cached weather forecasts by district.
"""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Text, JSON
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base


class WeatherCache(Base):
    __tablename__ = "weather_cache"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    district_code = Column(String(10), nullable=False, index=True)
    state_code = Column(String(5), nullable=True, index=True)
    district_name = Column(String(255), nullable=True)
    forecast_data = Column(JSON, nullable=False)  # Full forecast JSON
    compressed_payload = Column(Text, nullable=True)  # USSD-compressed version
    source = Column(String(50), default="imd", nullable=False)
    fetched_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
