"""
Crop Diagnosis model - Disease detection results.
"""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Float, Text, ForeignKey, Enum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.base import Base
import enum


class SyncStatus(str, enum.Enum):
    PENDING = "pending"
    SYNCED = "synced"
    CONFLICT = "conflict"
    FAILED = "failed"


class CropDiagnosis(Base):
    __tablename__ = "crop_diagnoses"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    farmer_id = Column(UUID(as_uuid=True), ForeignKey("farmers.id", ondelete="CASCADE"), nullable=False, index=True)
    plot_id = Column(UUID(as_uuid=True), ForeignKey("farm_plots.id", ondelete="SET NULL"), nullable=True, index=True)
    image_hash = Column(String(64), nullable=False)
    image_url = Column(Text, nullable=True)

    # Diagnosis results
    disease_name = Column(String(255), nullable=False)
    disease_name_hi = Column(String(255), nullable=True)
    confidence = Column(Float, nullable=False)
    severity = Column(String(20), nullable=True)  # critical, high, medium, low, healthy
    crop_type = Column(String(100), nullable=True)

    # Treatment
    treatment_recommendation = Column(Text, nullable=True)
    treatment_recommendation_hi = Column(Text, nullable=True)

    # Location
    gps_lat = Column(Float, nullable=True)
    gps_lon = Column(Float, nullable=True)
    district_code = Column(String(10), nullable=True, index=True)

    # Device verification
    device_signature = Column(Text, nullable=True)
    model_version = Column(String(50), nullable=True)

    # Sync
    sync_status = Column(String(20), default=SyncStatus.PENDING, nullable=False, index=True)
    synced_at = Column(DateTime(timezone=True), nullable=True)

    # Timestamps
    diagnosed_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    # Relationships
    farmer = relationship("Farmer", back_populates="diagnoses")
