"""
Mesh networking packet model - P2P store-and-forward.
"""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Integer, LargeBinary, Text
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base


class MeshPacket(Base):
    __tablename__ = "mesh_packets"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    origin_device_id = Column(String(128), nullable=False, index=True)
    destination_device_id = Column(String(128), nullable=True)  # None = broadcast
    packet_type = Column(String(20), nullable=False, index=True)  # diagnosis, weather, alert, price, sync
    payload_encrypted = Column(LargeBinary, nullable=False)
    payload_hash = Column(String(64), nullable=False, unique=True, index=True)  # Dedup key
    signature = Column(Text, nullable=False)
    nonce = Column(LargeBinary, nullable=True)  # AES-GCM nonce
    priority = Column(Integer, default=5, nullable=False)  # 1=highest, 10=lowest
    ttl_hours = Column(Integer, default=24, nullable=False)
    hop_count = Column(Integer, default=0, nullable=False)
    max_hops = Column(Integer, default=5, nullable=False)
    status = Column(String(20), default="pending", nullable=False, index=True)  # pending, delivered, expired, failed
    received_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    expires_at = Column(DateTime(timezone=True), nullable=False)
    delivered_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
