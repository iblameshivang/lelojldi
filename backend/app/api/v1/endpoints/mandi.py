"""
Mandi (Market) price endpoints.
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import List, Optional
from datetime import date, timedelta
from app.db.session import get_db
from app.models.mandi import MandiPrice
from app.schemas.schemas import MandiPriceResponse

router = APIRouter(prefix="/mandi", tags=["Mandi Prices"])


@router.get("/prices", response_model=List[MandiPriceResponse])
async def get_mandi_prices(
    db: AsyncSession = Depends(get_db),
    district_code: Optional[str] = None,
    state_code: Optional[str] = None,
    crop_name: Optional[str] = None,
    limit: int = Query(default=50, le=200),
):
    """Get latest mandi prices with optional filters."""
    query = select(MandiPrice)
    if district_code:
        query = query.where(MandiPrice.district_code == district_code)
    if state_code:
        query = query.where(MandiPrice.state_code == state_code)
    if crop_name:
        query = query.where(MandiPrice.crop_name.ilike(f"%{crop_name}%"))

    query = query.order_by(MandiPrice.price_date.desc()).limit(limit)
    result = await db.execute(query)
    prices = result.scalars().all()

    return [MandiPriceResponse.model_validate(p) for p in prices]


@router.get("/trends")
async def get_price_trends(
    crop_name: str = Query(...),
    district_code: Optional[str] = None,
    days: int = Query(default=30, le=90),
    db: AsyncSession = Depends(get_db),
):
    """Get price trend for a crop over N days."""
    cutoff = date.today() - timedelta(days=days)
    query = (
        select(MandiPrice.price_date, func.avg(MandiPrice.price_per_quintal).label("avg_price"))
        .where(MandiPrice.crop_name.ilike(f"%{crop_name}%"))
        .where(MandiPrice.price_date >= cutoff)
    )
    if district_code:
        query = query.where(MandiPrice.district_code == district_code)

    query = query.group_by(MandiPrice.price_date).order_by(MandiPrice.price_date)
    result = await db.execute(query)

    return {
        "crop_name": crop_name,
        "trend": [
            {"date": str(row[0]), "avg_price": round(float(row[1]), 2)}
            for row in result.all()
        ],
    }

