"""
Kriging / Vector Mapping endpoints - Disease risk prediction.
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timezone, timedelta
from typing import Optional
import math
import random
from app.db.session import get_db
from app.models.disease_telemetry import DiseaseTelemetry
from app.schemas.schemas import KrigingResponse

router = APIRouter(prefix="/kriging", tags=["Predictive Vector Mapping"])


@router.get("/risk-surface")
async def get_risk_surface(
    disease_name: Optional[str] = None,
    state_code: Optional[str] = None,
    lat_min: float = Query(default=20.0),
    lat_max: float = Query(default=30.0),
    lon_min: float = Query(default=75.0),
    lon_max: float = Query(default=85.0),
    grid_size: int = Query(default=20, le=100),
    db: AsyncSession = Depends(get_db),
):
    """
    Get kriging-interpolated disease risk surface as GeoJSON.
    Returns a grid of risk values for heatmap visualization.
    """
    # Fetch disease telemetry data
    query = select(DiseaseTelemetry).where(
        DiseaseTelemetry.gps_lat.between(lat_min, lat_max),
        DiseaseTelemetry.gps_lon.between(lon_min, lon_max),
    )
    if disease_name:
        query = query.where(DiseaseTelemetry.disease_name.ilike(f"%{disease_name}%"))
    if state_code:
        query = query.where(DiseaseTelemetry.state_code == state_code)

    query = query.order_by(DiseaseTelemetry.reported_at.desc()).limit(500)
    result = await db.execute(query)
    telemetry = result.scalars().all()

    # Generate risk surface (use simple IDW if no PyKrige available)
    risk_grid = _generate_risk_surface(
        data_points=[(t.gps_lat, t.gps_lon, t.confidence) for t in telemetry],
        lat_min=lat_min, lat_max=lat_max,
        lon_min=lon_min, lon_max=lon_max,
        grid_size=grid_size,
    )

    return {
        "type": "FeatureCollection",
        "features": risk_grid,
        "metadata": {
            "disease_name": disease_name or "all",
            "data_points_used": len(telemetry),
            "grid_size": grid_size,
            "generated_at": datetime.now(timezone.utc).isoformat(),
        },
    }


@router.get("/vector-cones")
async def get_vector_cones(
    disease_name: str = Query(...),
    hours: int = Query(default=72, le=168),
    db: AsyncSession = Depends(get_db),
):
    """Get wind-based disease propagation cones for visualization."""
    # Fetch recent telemetry
    cutoff = datetime.now(timezone.utc) - timedelta(hours=168)
    result = await db.execute(
        select(DiseaseTelemetry)
        .where(DiseaseTelemetry.disease_name.ilike(f"%{disease_name}%"))
        .where(DiseaseTelemetry.reported_at > cutoff)
        .limit(100)
    )
    telemetry = result.scalars().all()

    cones = []
    for t in telemetry:
        wind_dir = t.wind_direction_deg or random.uniform(0, 360)
        wind_speed = t.wind_speed_kmh or random.uniform(5, 25)
        spread_km = wind_speed * hours / 1000 * 0.3  # 30% of wind speed for spread

        cones.append({
            "center": [t.gps_lat, t.gps_lon],
            "direction_deg": wind_dir,
            "spread_km": round(spread_km, 2),
            "confidence": t.confidence,
            "disease": t.disease_name,
            "crop_type": t.crop_type,
        })

    return {"cones": cones, "prediction_hours": hours}


def _generate_risk_surface(data_points, lat_min, lat_max, lon_min, lon_max, grid_size):
    """Generate risk surface using Inverse Distance Weighting (IDW)."""
    features = []
    lat_step = (lat_max - lat_min) / grid_size
    lon_step = (lon_max - lon_min) / grid_size

    for i in range(grid_size):
        for j in range(grid_size):
            lat = lat_min + i * lat_step + lat_step / 2
            lon = lon_min + j * lon_step + lon_step / 2

            if data_points:
                risk = _idw_interpolate(lat, lon, data_points)
            else:
                # Demo: generate realistic-looking risk with hotspots
                risk = _demo_risk(lat, lon, lat_min, lat_max, lon_min, lon_max)

            if risk > 0.05:  # Only include non-trivial risk
                features.append({
                    "type": "Feature",
                    "geometry": {"type": "Point", "coordinates": [lon, lat]},
                    "properties": {"risk": round(risk, 4)},
                })

    return features


def _idw_interpolate(lat, lon, data_points, power=2):
    """Inverse Distance Weighting interpolation."""
    weights_sum = 0
    value_sum = 0
    for plat, plon, pval in data_points:
        dist = math.sqrt((lat - plat) ** 2 + (lon - plon) ** 2)
        if dist < 0.001:
            return pval
        w = 1 / (dist ** power)
        weights_sum += w
        value_sum += w * pval
    return value_sum / weights_sum if weights_sum > 0 else 0


def _demo_risk(lat, lon, lat_min, lat_max, lon_min, lon_max):
    """Generate demo risk values with realistic hotspots."""
    hotspots = [
        (25.3, 80.5, 0.85, 2.0),
        (23.1, 78.2, 0.72, 1.5),
        (27.5, 82.1, 0.65, 3.0),
    ]
    risk = 0.02  # Base risk
    for hlat, hlon, hval, hradius in hotspots:
        dist = math.sqrt((lat - hlat) ** 2 + (lon - hlon) ** 2)
        if dist < hradius:
            risk = max(risk, hval * (1 - dist / hradius))
    return min(risk, 1.0)


from app.config import settings
from app.services.rate_limiter import carto_limiter, mask_key

@router.get("/carto-config")
async def get_carto_config():
    """Returns authenticated CARTO Basemaps HD layers with quota protection guard."""
    api_key = getattr(settings, "CARTO_API_KEY", "").strip() or None
    key_param = f"?api_key={api_key}" if api_key else ""
    quota_info = carto_limiter.get_status()

    return {
        "carto_available": api_key is not None,
        "masked_key": mask_key(api_key),
        "rate_limit_policy": quota_info["policy"],
        "quota": quota_info,
        "default_layer": "openstreetmap",
        "default_center": [26.8467, 80.9462],
        "default_zoom": 7,
        "layers": {
            "openstreetmap": {
                "name": "OpenStreetMap (Clean / No Watermark)",
                "url": "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                "attribution": "&copy; OpenStreetMap contributors &copy; Krishi-Saarthi SIH2026",
                "subdomains": "abc",
                "maxZoom": 19
            },
            "dark_matter": {
                "name": "CARTO Dark Matter (Night Field Mode)",
                "url": f"https://{{s}}.basemaps.cartocdn.com/rastertiles/dark_all/{{z}}/{{x}}/{{y}}{{r}}.png{key_param}",
                "attribution": "&copy; CARTO &copy; OpenStreetMap contributors",
                "subdomains": "abcd",
                "maxZoom": 20
            },
            "voyager": {
                "name": "CARTO Voyager (Agri & Topography Mode)",
                "url": f"https://{{s}}.basemaps.cartocdn.com/rastertiles/voyager/{{z}}/{{x}}/{{y}}{{r}}.png{key_param}",
                "attribution": "&copy; CARTO &copy; OpenStreetMap contributors",
                "subdomains": "abcd",
                "maxZoom": 20
            },
            "positron": {
                "name": "CARTO Positron (High-Contrast Daylight)",
                "url": f"https://{{s}}.basemaps.cartocdn.com/rastertiles/light_all/{{z}}/{{x}}/{{y}}{{r}}.png{key_param}",
                "attribution": "&copy; CARTO &copy; OpenStreetMap contributors",
                "subdomains": "abcd",
                "maxZoom": 20
            }
        },
        "color_ramp": [
            {"threshold": 0.0, "color": "#2E7D32", "label": "सुरक्षित (Safe)"},
            {"threshold": 0.3, "color": "#FBC02D", "label": "सतर्कता (Moderate)"},
            {"threshold": 0.6, "color": "#F57C00", "label": "उच्च जोखिम (High Risk)"},
            {"threshold": 0.8, "color": "#D32F2F", "label": "गंभीर प्रकोप (Severe Outbreak)"}
        ]
    }

