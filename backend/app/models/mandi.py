"""
Mandi (Market) prices model - Agricultural commodity prices.
"""
import uuid
from datetime import datetime, date, timezone
from sqlalchemy import Column, String, DateTime, Float, Date, Text
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base


class MandiPrice(Base):
    __tablename__ = "mandi_prices"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    market_code = Column(String(20), nullable=False, index=True)
    market_name = Column(String(255), nullable=False)
    district_code = Column(String(10), nullable=False, index=True)
    state_code = Column(String(5), nullable=False, index=True)
    crop_name = Column(String(100), nullable=False, index=True)
    crop_name_hi = Column(String(100), nullable=True)
    variety = Column(String(100), nullable=True)
    min_price = Column(Float, nullable=True)
    max_price = Column(Float, nullable=True)
    modal_price = Column(Float, nullable=True)
    price_per_quintal = Column(Float, nullable=False)
    price_trend = Column(String(10), nullable=True)  # up, down, stable
    price_change_pct = Column(Float, nullable=True)
    price_date = Column(Date, nullable=False, index=True)
    source = Column(String(50), default="agmarknet", nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
