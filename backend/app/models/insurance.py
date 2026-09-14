"""
Insurance claim model - Tamper-proof evidence for crop insurance.
"""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Float, Text, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.base import Base


class InsuranceClaim(Base):
    __tablename__ = "insurance_claims"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    farmer_id = Column(UUID(as_uuid=True), ForeignKey("farmers.id", ondelete="CASCADE"), nullable=False, index=True)
    policy_number = Column(String(50), nullable=True, index=True)
    claim_type = Column(String(30), nullable=False)  # crop_damage, flood, drought, pest_attack, hailstorm

    # Evidence
    evidence_video_hash = Column(String(64), nullable=False)
    evidence_video_url = Column(Text, nullable=True)
    evidence_photos = Column(JSON, nullable=True)  # Array of photo URLs
    metadata_signature = Column(Text, nullable=False)
    device_metadata = Column(JSON, nullable=True)  # GPS, gyro, timestamp, device info

    # Blockchain anchor
    blockchain_tx_id = Column(String(128), nullable=True)
    blockchain_network = Column(String(50), nullable=True)  # polygon, ethereum

    # Claim status
    claim_status = Column(String(20), default="submitted", nullable=False, index=True)
    reviewer_notes = Column(Text, nullable=True)
    submitted_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    reviewed_at = Column(DateTime(timezone=True), nullable=True)
    settled_at = Column(DateTime(timezone=True), nullable=True)
    settlement_amount = Column(Float, nullable=True)

    # Location
    gps_lat = Column(Float, nullable=True)
    gps_lon = Column(Float, nullable=True)
    district_code = Column(String(10), nullable=True, index=True)

    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    farmer = relationship("Farmer", back_populates="insurance_claims")
