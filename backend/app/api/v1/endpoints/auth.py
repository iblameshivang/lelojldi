"""
Auth endpoints - Registration and login.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.models.farmer import Farmer
from app.schemas.schemas import FarmerRegister, FarmerLogin, TokenResponse, FarmerResponse
from app.core.security import (
    create_access_token, hash_aadhaar, hash_phone,
    get_password_hash, verify_password,
)

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register_farmer(data: FarmerRegister, db: AsyncSession = Depends(get_db)):
    """Register a new farmer with Aadhaar and phone number."""
    aadhaar_h = hash_aadhaar(data.aadhaar_number)
    phone_h = hash_phone(data.phone_number)

    # Check if already registered
    existing = await db.execute(
        select(Farmer).where(
            (Farmer.aadhaar_hash == aadhaar_h) | (Farmer.phone_hash == phone_h)
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Farmer already registered with this Aadhaar or phone number",
        )

    farmer = Farmer(
        aadhaar_hash=aadhaar_h,
        phone_hash=phone_h,
        device_id=data.device_id,
        full_name=data.full_name,
        preferred_language=data.preferred_language,
        district_code=data.district_code,
        state_code=data.state_code,
    )
    db.add(farmer)
    await db.flush()

    token = create_access_token(data={"sub": str(farmer.id)})
    return TokenResponse(
        access_token=token,
        farmer=FarmerResponse.model_validate(farmer),
    )


@router.post("/login", response_model=TokenResponse)
async def login_farmer(data: FarmerLogin, db: AsyncSession = Depends(get_db)):
    """Login with phone number and device ID."""
    phone_h = hash_phone(data.phone_number)
    result = await db.execute(select(Farmer).where(Farmer.phone_hash == phone_h))
    farmer = result.scalar_one_or_none()

    if not farmer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Farmer not found")
    if not farmer.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account deactivated")

    # Update device ID
    farmer.device_id = data.device_id
    await db.flush()

    token = create_access_token(data={"sub": str(farmer.id)})
    return TokenResponse(
        access_token=token,
        farmer=FarmerResponse.model_validate(farmer),
    )
