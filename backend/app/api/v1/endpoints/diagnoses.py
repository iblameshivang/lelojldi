"""
Diagnosis endpoints - Crop disease detection results.
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import List, Optional
from uuid import UUID
from app.db.session import get_db
from app.api.deps import get_current_farmer
from app.models.farmer import Farmer
from app.models.diagnosis import CropDiagnosis
from app.models.disease_telemetry import DiseaseTelemetry
from app.schemas.schemas import DiagnosisSubmit, DiagnosisResponse

router = APIRouter(prefix="/diagnoses", tags=["Crop Diagnosis"])


@router.post("/", response_model=DiagnosisResponse, status_code=status.HTTP_201_CREATED)
async def submit_diagnosis(
    data: DiagnosisSubmit,
    farmer: Farmer = Depends(get_current_farmer),
    db: AsyncSession = Depends(get_db),
):
    """Submit a new crop diagnosis result from on-device CV model."""
    diagnosis = CropDiagnosis(
        farmer_id=farmer.id,
        plot_id=data.plot_id,
        image_hash=data.image_hash,
        disease_name=data.disease_name,
        disease_name_hi=data.disease_name_hi,
        confidence=data.confidence,
        severity=data.severity,
        crop_type=data.crop_type,
        treatment_recommendation=data.treatment_recommendation,
        treatment_recommendation_hi=data.treatment_recommendation_hi,
        gps_lat=data.gps_lat,
        gps_lon=data.gps_lon,
        district_code=data.district_code,
        device_signature=data.device_signature,
        model_version=data.model_version,
        sync_status="synced",
    )
    db.add(diagnosis)

    # Also add to disease telemetry for kriging
    if data.gps_lat and data.gps_lon and data.disease_name.lower() != "healthy":
        telemetry = DiseaseTelemetry(
            disease_name=data.disease_name,
            gps_lat=data.gps_lat,
            gps_lon=data.gps_lon,
            district_code=data.district_code,
            confidence=data.confidence,
            severity=data.severity,
            crop_type=data.crop_type,
            source_diagnosis_id=diagnosis.id,
        )
        db.add(telemetry)

    await db.flush()
    return DiagnosisResponse.model_validate(diagnosis)


@router.get("/", response_model=List[DiagnosisResponse])
async def get_diagnoses(
    farmer: Farmer = Depends(get_current_farmer),
    db: AsyncSession = Depends(get_db),
    limit: int = Query(default=50, le=200),
    offset: int = Query(default=0, ge=0),
    crop_type: Optional[str] = None,
):
    """Get farmer's diagnosis history."""
    query = select(CropDiagnosis).where(CropDiagnosis.farmer_id == farmer.id)
    if crop_type:
        query = query.where(CropDiagnosis.crop_type == crop_type)
    query = query.order_by(CropDiagnosis.diagnosed_at.desc()).limit(limit).offset(offset)

    result = await db.execute(query)
    return [DiagnosisResponse.model_validate(d) for d in result.scalars().all()]


@router.get("/stats")
async def get_diagnosis_stats(
    db: AsyncSession = Depends(get_db),
    district_code: Optional[str] = None,
):
    """Get aggregate diagnosis statistics for admin dashboard."""
    query = select(
        CropDiagnosis.disease_name,
        func.count(CropDiagnosis.id).label("count"),
        func.avg(CropDiagnosis.confidence).label("avg_confidence"),
    ).group_by(CropDiagnosis.disease_name)

    if district_code:
        query = query.where(CropDiagnosis.district_code == district_code)

    result = await db.execute(query)
    rows = result.all()

    return {
        "disease_stats": [
            {"disease_name": row[0], "count": row[1], "avg_confidence": round(float(row[2] or 0), 3)}
            for row in rows
        ]
    }
