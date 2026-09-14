"""
Fertilizer registry model - Anti-counterfeit verification.
"""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Boolean, Text
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base


class FertilizerRegistry(Base):
    __tablename__ = "fertilizer_registry"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    product_name = Column(String(255), nullable=False, index=True)
    manufacturer = Column(String(255), nullable=False, index=True)
    batch_number = Column(String(100), nullable=False, index=True)
    qr_hash = Column(String(64), nullable=False, unique=True, index=True)
    seal_pattern_hash = Column(String(64), nullable=True)
    barcode = Column(String(50), nullable=True)
    product_type = Column(String(50), nullable=True)  # urea, dap, npk, etc.
    weight_kg = Column(String(20), nullable=True)
    mrp = Column(String(20), nullable=True)
    valid_from = Column(DateTime(timezone=True), nullable=False)
    valid_until = Column(DateTime(timezone=True), nullable=False)
    is_revoked = Column(Boolean, default=False, nullable=False, index=True)
    revoked_reason = Column(Text, nullable=True)
    registry_signature = Column(Text, nullable=False)  # ECDSA signature of registry entry
    verification_count = Column(String(20), default="0")  # How many times scanned
    last_verified_at = Column(DateTime(timezone=True), nullable=True)
    last_verified_location = Column(String(255), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))
