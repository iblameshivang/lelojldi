"""
Dashboard endpoints - Admin aggregate statistics.
"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import datetime, timezone, timedelta
from app.db.session import get_db
from app.models.farmer import Farmer
from app.models.diagnosis import CropDiagnosis
from app.models.insurance import InsuranceClaim
from app.models.mesh import MeshPacket
from app.models.fertilizer import FertilizerRegistry
from app.models.disease_telemetry import DiseaseTelemetry
from app.schemas.schemas import DashboardStats

router = APIRouter(prefix="/dashboard", tags=["Admin Dashboard"])


@router.get("/stats", response_model=DashboardStats)
async def get_dashboard_stats(db: AsyncSession = Depends(get_db)):
    """Get aggregate statistics for admin dashboard."""
    total_farmers = await db.execute(select(func.count(Farmer.id)))
    total_diagnoses = await db.execute(select(func.count(CropDiagnosis.id)))
    active_diseases = await db.execute(
        select(func.count(func.distinct(CropDiagnosis.disease_name)))
    )
    total_claims = await db.execute(select(func.count(InsuranceClaim.id)))

    today = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0)
    mesh_today = await db.execute(
        select(func.count(MeshPacket.id)).where(MeshPacket.received_at >= today)
    )
    districts = await db.execute(
        select(func.count(func.distinct(Farmer.district_code)))
    )

    return DashboardStats(
        total_farmers=total_farmers.scalar() or 0,
        total_diagnoses=total_diagnoses.scalar() or 0,
        active_diseases=active_diseases.scalar() or 0,
        total_insurance_claims=total_claims.scalar() or 0,
        mesh_packets_today=mesh_today.scalar() or 0,
        districts_covered=districts.scalar() or 0,
    )


@router.get("/recent-diagnoses")
async def get_recent_diagnoses(
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
):
    """Get recent diagnoses for admin feed."""
    result = await db.execute(
        select(CropDiagnosis)
        .order_by(CropDiagnosis.diagnosed_at.desc())
        .limit(limit)
    )
    diagnoses = result.scalars().all()
    return [
        {
            "id": str(d.id),
            "disease_name": d.disease_name,
            "disease_name_hi": d.disease_name_hi,
            "confidence": d.confidence,
            "severity": d.severity,
            "crop_type": d.crop_type,
            "district_code": d.district_code,
            "gps_lat": d.gps_lat,
            "gps_lon": d.gps_lon,
            "diagnosed_at": d.diagnosed_at.isoformat() if d.diagnosed_at else None,
        }
        for d in diagnoses
    ]


@router.get("/disease-heatmap")
async def get_disease_heatmap(db: AsyncSession = Depends(get_db)):
    """Get disease distribution as heatmap data."""
    result = await db.execute(
        select(
            DiseaseTelemetry.gps_lat,
            DiseaseTelemetry.gps_lon,
            DiseaseTelemetry.confidence,
            DiseaseTelemetry.disease_name,
        )
        .order_by(DiseaseTelemetry.reported_at.desc())
        .limit(1000)
    )
    points = result.all()
    return {
        "heatmap_data": [
            {"lat": p[0], "lon": p[1], "intensity": p[2], "disease": p[3]}
            for p in points
        ]
    }
