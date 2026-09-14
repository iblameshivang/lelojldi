"""
Farmer model - Core user entity for the platform.
"""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Text, Boolean, ForeignKey, Float
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.base import Base


class Farmer(Base):
    __tablename__ = "farmers"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    aadhaar_hash = Column(String(64), unique=True, nullable=False, index=True)
    phone_hash = Column(String(64), unique=True, nullable=False, index=True)
    device_id = Column(String(128), nullable=True, index=True)
    public_key = Column(Text, nullable=True)
    preferred_language = Column(String(5), default="hi", nullable=False)
    full_name = Column(String(255), nullable=True)
    district_code = Column(String(10), nullable=True, index=True)
    state_code = Column(String(5), nullable=True, index=True)
    is_active = Column(Boolean, default=True, nullable=False)
    last_sync_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    farm_plots = relationship("FarmPlot", back_populates="farmer", cascade="all, delete-orphan")
    diagnoses = relationship("CropDiagnosis", back_populates="farmer", cascade="all, delete-orphan")
    insurance_claims = relationship("InsuranceClaim", back_populates="farmer", cascade="all, delete-orphan")


class FarmPlot(Base):
    __tablename__ = "farm_plots"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    farmer_id = Column(UUID(as_uuid=True), ForeignKey("farmers.id", ondelete="CASCADE"), nullable=False, index=True)
    plot_name = Column(String(255), nullable=False)
    boundary_geojson = Column(Text, nullable=True)
    area_sqm = Column(Float, nullable=True)
    soil_type = Column(String(50), nullable=True)
    current_crop = Column(String(100), nullable=True)
    sowing_date = Column(DateTime(timezone=True), nullable=True)
    gps_lat = Column(Float, nullable=True)
    gps_lon = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    farmer = relationship("Farmer", back_populates="farm_plots")
