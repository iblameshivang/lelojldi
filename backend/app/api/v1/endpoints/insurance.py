"""
Insurance endpoints - Claim submission and status.
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Optional
from uuid import UUID
from app.db.session import get_db
from app.api.deps import get_current_farmer
from app.models.farmer import Farmer
from app.models.insurance import InsuranceClaim
from app.schemas.schemas import InsuranceClaimSubmit, InsuranceClaimResponse

router = APIRouter(prefix="/insurance", tags=["Insurance"])


@router.post("/claims", response_model=InsuranceClaimResponse, status_code=status.HTTP_201_CREATED)
async def submit_insurance_claim(
    data: InsuranceClaimSubmit,
    farmer: Farmer = Depends(get_current_farmer),
    db: AsyncSession = Depends(get_db),
):
    """Submit an insurance claim with tamper-proof video evidence."""
    claim = InsuranceClaim(
        farmer_id=farmer.id,
        policy_number=data.policy_number,
        claim_type=data.claim_type,
        evidence_video_hash=data.evidence_video_hash,
        evidence_video_url=data.evidence_video_url,
        metadata_signature=data.metadata_signature,
        device_metadata=data.device_metadata,
        gps_lat=data.gps_lat,
        gps_lon=data.gps_lon,
        district_code=data.district_code,
        claim_status="submitted",
    )
    db.add(claim)
    await db.flush()

    # Simulate blockchain anchor
    import hashlib
    claim.blockchain_tx_id = f"0x{hashlib.sha256(str(claim.id).encode()).hexdigest()[:40]}"
    claim.blockchain_network = "polygon"

    return InsuranceClaimResponse.model_validate(claim)


@router.get("/claims", response_model=List[InsuranceClaimResponse])
async def get_insurance_claims(
    farmer: Farmer = Depends(get_current_farmer),
    db: AsyncSession = Depends(get_db),
    claim_status: Optional[str] = None,
):
    """Get farmer's insurance claims."""
    query = select(InsuranceClaim).where(InsuranceClaim.farmer_id == farmer.id)
    if claim_status:
        query = query.where(InsuranceClaim.claim_status == claim_status)
    query = query.order_by(InsuranceClaim.submitted_at.desc())

    result = await db.execute(query)
    return [InsuranceClaimResponse.model_validate(c) for c in result.scalars().all()]


@router.get("/claims/{claim_id}", response_model=InsuranceClaimResponse)
async def get_claim_detail(
    claim_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """Get insurance claim detail (for admin review)."""
    result = await db.execute(select(InsuranceClaim).where(InsuranceClaim.id == claim_id))
    claim = result.scalar_one_or_none()
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")
    return InsuranceClaimResponse.model_validate(claim)


@router.patch("/claims/{claim_id}/status")
async def update_claim_status(
    claim_id: UUID,
    new_status: str = Query(...),
    reviewer_notes: Optional[str] = None,
    settlement_amount: Optional[float] = None,
    db: AsyncSession = Depends(get_db),
):
    """Update claim status (admin action)."""
    result = await db.execute(select(InsuranceClaim).where(InsuranceClaim.id == claim_id))
    claim = result.scalar_one_or_none()
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")

    valid_statuses = ["submitted", "under_review", "verified", "approved", "rejected", "settled"]
    if new_status not in valid_statuses:
        raise HTTPException(status_code=400, detail=f"Invalid status. Must be one of {valid_statuses}")

    claim.claim_status = new_status
    if reviewer_notes:
        claim.reviewer_notes = reviewer_notes
    if settlement_amount:
        claim.settlement_amount = settlement_amount
    if new_status == "settled":
        from datetime import datetime, timezone
        claim.settled_at = datetime.now(timezone.utc)

    await db.flush()
    return {"message": "Claim status updated", "claim_id": str(claim_id), "status": new_status}
