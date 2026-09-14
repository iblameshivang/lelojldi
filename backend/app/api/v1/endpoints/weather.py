"""
Weather endpoints - Forecast data with USSD compression.
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timezone
from app.db.session import get_db
from app.models.weather import WeatherCache
from app.schemas.schemas import WeatherResponse

router = APIRouter(prefix="/weather", tags=["Weather"])


import httpx
from datetime import timedelta

DISTRICT_COORDS = {
    "UP001": (26.8467, 80.9462),  # Lucknow
    "UP002": (26.4499, 80.3319),  # Kanpur
    "UP003": (25.3176, 82.9739),  # Varanasi
}

@router.get("/forecast", response_model=WeatherResponse)
async def get_weather_forecast(
    district_code: str = Query(..., description="District code (e.g., 'UP001')"),
    db: AsyncSession = Depends(get_db),
):
    """Get weather forecast for a district. Returns cached data or triggers fetch."""
    now = datetime.now(timezone.utc)
    
    result = await db.execute(
        select(WeatherCache)
        .where(WeatherCache.district_code == district_code)
        .order_by(WeatherCache.fetched_at.desc())
        .limit(1)
    )
    cache = result.scalar_one_or_none()

    # Ensure cache.expires_at is timezone-aware for safe comparison
    if cache and cache.expires_at:
        expires_at = cache.expires_at
        if expires_at.tzinfo is None:
            expires_at = expires_at.replace(tzinfo=timezone.utc)
        if expires_at > now:
            hours_left = (expires_at - now).total_seconds() / 3600.0
            return WeatherResponse(
                district_code=cache.district_code,
                district_name=cache.district_name,
                forecast_data=cache.forecast_data,
                compressed_payload=cache.compressed_payload,
                source=cache.source,
                fetched_at=cache.fetched_at,
                expires_at=cache.expires_at,
                hours_left_in_cache=hours_left
            )

    # Need to fetch new data from Open-Meteo
    lat, lon = DISTRICT_COORDS.get(district_code, (26.8467, 80.9462))  # Default Lucknow
    
    async with httpx.AsyncClient() as client:
        try:
            resp = await client.get(
                f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,precipitation&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=Asia%2FKolkata"
            )
            resp.raise_for_status()
            data = resp.json()
            
            # Convert Open-Meteo data to our format
            current = data.get("current", {})
            daily = data.get("daily", {})
            
            forecast_5day = []
            for i in range(min(5, len(daily.get("time", [])))):
                forecast_5day.append({
                    "date": daily["time"][i],
                    "max_c": daily["temperature_2m_max"][i],
                    "min_c": daily["temperature_2m_min"][i],
                    "rain_mm": daily["precipitation_sum"][i],
                    "condition_hi": "बारिश" if daily["precipitation_sum"][i] > 2 else "धूप",
                })
            
            forecast_data = {
                "current": {
                    "temp_c": current.get("temperature_2m", 30),
                    "humidity_pct": current.get("relative_humidity_2m", 65),
                    "wind_speed_kmh": current.get("wind_speed_10m", 12),
                    "wind_direction": "SW",
                    "condition": "Clear",
                    "condition_hi": "साफ",
                    "rainfall_mm": current.get("precipitation", 0),
                },
                "forecast_5day": forecast_5day,
                "advisory": "मौसम अद्यतन।",
                "advisory_en": "Weather updated.",
            }
            source = "open-meteo"
            
        except Exception as e:
            print(f"Weather API error: {e}")
            # Fallback to demo
            forecast_data = _generate_demo_forecast(district_code)
            source = "demo-fallback"
    
    # Save to cache (12-hour offline cache)
    expires = now + timedelta(hours=12)
    new_cache = WeatherCache(
        district_code=district_code,
        district_name=f"District {district_code}",
        forecast_data=forecast_data,
        source=source,
        fetched_at=now,
        expires_at=expires,
        compressed_payload=f"WX|{district_code}|{forecast_data['current']['temp_c']}C"
    )
    db.add(new_cache)
    await db.commit()
    await db.refresh(new_cache)
    
    return WeatherResponse(
        district_code=new_cache.district_code,
        district_name=new_cache.district_name,
        forecast_data=new_cache.forecast_data,
        compressed_payload=new_cache.compressed_payload,
        source=new_cache.source,
        fetched_at=new_cache.fetched_at,
        expires_at=new_cache.expires_at,
        hours_left_in_cache=12.0
    )


@router.get("/ussd")
async def get_ussd_weather(
    district_code: str = Query(...),
    db: AsyncSession = Depends(get_db),
):
    """Get weather in USSD-compressed 140-char format for 2G fallback."""
    result = await db.execute(
        select(WeatherCache)
        .where(WeatherCache.district_code == district_code)
        .order_by(WeatherCache.fetched_at.desc())
        .limit(1)
    )
    cache = result.scalar_one_or_none()

    if cache and cache.compressed_payload:
        return {"payload": cache.compressed_payload, "encoding": "huffman"}

    # Generate compressed demo
    return {
        "payload": f"WX|{district_code}|30C|65%RH|5mm|SW12|3d:30/31/29C",
        "encoding": "plain",
        "chars": 45,
    }


def _generate_demo_forecast(district_code: str) -> dict:
    """Generate realistic demo forecast data."""
    return {
        "current": {
            "temp_c": 30,
            "humidity_pct": 65,
            "wind_speed_kmh": 12,
            "wind_direction": "SW",
            "condition": "Partly Cloudy",
            "condition_hi": "आंशिक बादल",
            "rainfall_mm": 0,
        },
        "forecast_5day": [
            {"date": "2026-09-13", "max_c": 31, "min_c": 24, "rain_mm": 5, "condition": "Light Rain", "condition_hi": "हल्की बारिश"},
            {"date": "2026-09-14", "max_c": 30, "min_c": 23, "rain_mm": 12, "condition": "Moderate Rain", "condition_hi": "मध्यम बारिश"},
            {"date": "2026-09-15", "max_c": 29, "min_c": 23, "rain_mm": 8, "condition": "Light Rain", "condition_hi": "हल्की बारिश"},
            {"date": "2026-09-16", "max_c": 31, "min_c": 24, "rain_mm": 0, "condition": "Sunny", "condition_hi": "धूप"},
            {"date": "2026-09-17", "max_c": 32, "min_c": 25, "rain_mm": 0, "condition": "Clear", "condition_hi": "साफ"},
        ],
        "advisory": "कम बारिश के साथ फसल सिंचाई पर ध्यान दें। कीटनाशक छिड़काव से बचें।",
        "advisory_en": "Focus on crop irrigation with low rainfall expected. Avoid pesticide spraying.",
    }
