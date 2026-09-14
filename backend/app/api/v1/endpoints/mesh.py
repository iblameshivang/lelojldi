"""
Mesh networking endpoints - P2P packet ingestion.
"""
import base64
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timezone, timedelta
from typing import List, Optional
from app.db.session import get_db
from app.models.mesh import MeshPacket
from app.schemas.schemas import MeshPacketSubmit, MeshPacketResponse

router = APIRouter(prefix="/mesh", tags=["Mesh Networking"])


@router.post("/packets", response_model=MeshPacketResponse, status_code=status.HTTP_201_CREATED)
async def ingest_mesh_packet(
    data: MeshPacketSubmit,
    db: AsyncSession = Depends(get_db),
):
    """Ingest a mesh packet from a device that has connectivity."""
    # Dedup check
    existing = await db.execute(
        select(MeshPacket).where(MeshPacket.payload_hash == data.payload_hash)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Packet already ingested (duplicate hash)",
        )

    expires_at = datetime.now(timezone.utc) + timedelta(hours=data.ttl_hours)
    packet = MeshPacket(
        origin_device_id=data.origin_device_id,
        destination_device_id=data.destination_device_id,
        packet_type=data.packet_type,
        payload_encrypted=base64.b64decode(data.payload_encrypted),
        payload_hash=data.payload_hash,
        signature=data.signature,
        nonce=base64.b64decode(data.nonce) if data.nonce else None,
        priority=data.priority,
        ttl_hours=data.ttl_hours,
        hop_count=data.hop_count,
        max_hops=data.max_hops,
        status="delivered",
        expires_at=expires_at,
        delivered_at=datetime.now(timezone.utc),
    )
    db.add(packet)
    await db.flush()
    return MeshPacketResponse.model_validate(packet)


@router.get("/packets", response_model=List[MeshPacketResponse])
async def get_pending_packets(
    device_id: str = Query(...),
    db: AsyncSession = Depends(get_db),
    limit: int = Query(default=50, le=200),
):
    """Get pending packets for a device (download when connectivity available)."""
    result = await db.execute(
        select(MeshPacket)
        .where(
            (MeshPacket.destination_device_id == device_id)
            | (MeshPacket.destination_device_id.is_(None))  # Broadcast
        )
        .where(MeshPacket.status == "pending")
        .where(MeshPacket.expires_at > datetime.now(timezone.utc))
        .order_by(MeshPacket.priority.asc(), MeshPacket.received_at.asc())
        .limit(limit)
    )
    return [MeshPacketResponse.model_validate(p) for p in result.scalars().all()]


@router.get("/stats")
async def get_mesh_stats(db: AsyncSession = Depends(get_db)):
    """Get mesh network statistics for admin dashboard."""
    from sqlalchemy import func

    total = await db.execute(select(func.count(MeshPacket.id)))
    pending = await db.execute(
        select(func.count(MeshPacket.id)).where(MeshPacket.status == "pending")
    )
    delivered = await db.execute(
        select(func.count(MeshPacket.id)).where(MeshPacket.status == "delivered")
    )

    return {
        "total_packets": total.scalar() or 0,
        "pending": pending.scalar() or 0,
        "delivered": delivered.scalar() or 0,
    }
