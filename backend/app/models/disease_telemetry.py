"""
Disease telemetry model - Spatial disease data for Kriging/vector mapping.
"""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Float, Boolean
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base


class DiseaseTelemetry(Base):
    __tablename__ = "disease_telemetry"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    disease_name = Column(String(255), nullable=False, index=True)
    gps_lat = Column(Float, nullable=False)
    gps_lon = Column(Float, nullable=False)
    district_code = Column(String(10), nullable=True, index=True)
    state_code = Column(String(5), nullable=True, index=True)
    confidence = Column(Float, nullable=False)
    severity = Column(String(20), nullable=True)
    crop_type = Column(String(100), nullable=True, index=True)
    source_diagnosis_id = Column(UUID(as_uuid=True), nullable=True, index=True)
    wind_speed_kmh = Column(Float, nullable=True)
    wind_direction_deg = Column(Float, nullable=True)
    temperature_c = Column(Float, nullable=True)
    humidity_pct = Column(Float, nullable=True)
    reported_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False, index=True)
    processed_for_kriging = Column(Boolean, default=False, nullable=False, index=True)
    kriging_batch_id = Column(String(64), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
