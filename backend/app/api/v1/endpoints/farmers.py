"""
Farmer management endpoints.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from app.db.session import get_db
from app.api.deps import get_current_farmer
from app.models.farmer import Farmer, FarmPlot
from app.schemas.schemas import FarmerResponse, FarmPlotCreate, FarmPlotResponse

router = APIRouter(prefix="/farmers", tags=["Farmers"])


@router.get("/me", response_model=FarmerResponse)
async def get_current_farmer_profile(
    farmer: Farmer = Depends(get_current_farmer),
):
    """Get current farmer's profile."""
    return FarmerResponse.model_validate(farmer)


@router.patch("/me")
async def update_farmer_profile(
    preferred_language: str = None,
    full_name: str = None,
    district_code: str = None,
    state_code: str = None,
    farmer: Farmer = Depends(get_current_farmer),
    db: AsyncSession = Depends(get_db),
):
    """Update farmer profile."""
    if preferred_language:
        farmer.preferred_language = preferred_language
    if full_name:
        farmer.full_name = full_name
    if district_code:
        farmer.district_code = district_code
    if state_code:
        farmer.state_code = state_code
    await db.flush()
    return FarmerResponse.model_validate(farmer)


@router.post("/plots", response_model=FarmPlotResponse, status_code=201)
async def add_farm_plot(
    data: FarmPlotCreate,
    farmer: Farmer = Depends(get_current_farmer),
    db: AsyncSession = Depends(get_db),
):
    """Add a new farm plot."""
    plot = FarmPlot(
        farmer_id=farmer.id,
        plot_name=data.plot_name,
        boundary_geojson=data.boundary_geojson,
        area_sqm=data.area_sqm,
        soil_type=data.soil_type,
        current_crop=data.current_crop,
        sowing_date=data.sowing_date,
        gps_lat=data.gps_lat,
        gps_lon=data.gps_lon,
    )
    db.add(plot)
    await db.flush()
    return FarmPlotResponse.model_validate(plot)


@router.get("/plots", response_model=List[FarmPlotResponse])
async def get_farm_plots(
    farmer: Farmer = Depends(get_current_farmer),
    db: AsyncSession = Depends(get_db),
):
    """Get all farm plots for current farmer."""
    result = await db.execute(
        select(FarmPlot).where(FarmPlot.farmer_id == farmer.id)
    )
    return [FarmPlotResponse.model_validate(p) for p in result.scalars().all()]
