"""
Fertilizer verification endpoints - Anti-counterfeit.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timezone
from app.db.session import get_db
from app.models.fertilizer import FertilizerRegistry
from app.schemas.schemas import FertilizerVerifyRequest, FertilizerVerifyResponse

router = APIRouter(prefix="/fertilizer", tags=["Fertilizer Verification"])


@router.post("/verify", response_model=FertilizerVerifyResponse)
async def verify_fertilizer(
    data: FertilizerVerifyRequest,
    db: AsyncSession = Depends(get_db),
):
    """Verify a fertilizer product's authenticity via QR, barcode, or seal."""
    if not data.qr_data and not data.barcode:
        raise HTTPException(status_code=400, detail="Provide either qr_data or barcode")

    # Search by QR hash first
    query = select(FertilizerRegistry)
    if data.qr_data:
        import hashlib
        qr_hash = hashlib.sha256(data.qr_data.encode()).hexdigest()
        query = query.where(FertilizerRegistry.qr_hash == qr_hash)
    elif data.barcode:
        query = query.where(FertilizerRegistry.barcode == data.barcode)

    result = await db.execute(query)
    product = result.scalar_one_or_none()

    if not product:
        return FertilizerVerifyResponse(
            is_authentic=False,
            confidence=0.0,
            message="❌ Product NOT found in registry. Likely COUNTERFEIT.",
        )

    # Check revocation
    if product.is_revoked:
        return FertilizerVerifyResponse(
            is_authentic=False,
            product_name=product.product_name,
            manufacturer=product.manufacturer,
            batch_number=product.batch_number,
            is_revoked=True,
            confidence=0.95,
            message=f"⚠️ Product REVOKED: {product.revoked_reason}",
        )

    # Check validity period
    valid_until = product.valid_until
    if valid_until and valid_until.tzinfo is None:
        valid_until = valid_until.replace(tzinfo=timezone.utc)
    now = datetime.now(timezone.utc)
    if valid_until and valid_until < now:
        return FertilizerVerifyResponse(
            is_authentic=False,
            product_name=product.product_name,
            manufacturer=product.manufacturer,
            batch_number=product.batch_number,
            valid_until=product.valid_until,
            confidence=0.7,
            message="⚠️ Product validity EXPIRED. May be repackaged counterfeit.",
        )

    # Update verification count
    product.verification_count = str(int(product.verification_count or "0") + 1)
    product.last_verified_at = now

    return FertilizerVerifyResponse(
        is_authentic=True,
        product_name=product.product_name,
        manufacturer=product.manufacturer,
        batch_number=product.batch_number,
        valid_until=product.valid_until,
        is_revoked=False,
        confidence=0.98,
        message="✅ Product is AUTHENTIC and within validity period.",
    )


@router.get("/registry")
async def get_registry_stats(db: AsyncSession = Depends(get_db)):
    """Get fertilizer registry statistics."""
    from sqlalchemy import func
    total = await db.execute(select(func.count(FertilizerRegistry.id)))
    revoked = await db.execute(
        select(func.count(FertilizerRegistry.id)).where(FertilizerRegistry.is_revoked == True)
    )
    return {
        "total_products": total.scalar() or 0,
        "revoked_products": revoked.scalar() or 0,
    }
