"""
Weather data fetching tasks - IMD scraper.
"""
from app.tasks.celery_app import celery_app
import structlog

logger = structlog.get_logger()


@celery_app.task(bind=True, name="app.tasks.weather_tasks.fetch_all_weather")
def fetch_all_weather(self):
    """Fetch weather data for all active districts."""
    logger.info("weather_fetch_started")

    # List of major agricultural districts
    districts = [
        ("UP001", "Lucknow", "UP"), ("UP002", "Varanasi", "UP"),
        ("MH001", "Pune", "MH"), ("MH002", "Nagpur", "MH"),
        ("MP001", "Bhopal", "MP"), ("RJ001", "Jaipur", "RJ"),
        ("PB001", "Ludhiana", "PB"), ("HR001", "Karnal", "HR"),
        ("BR001", "Patna", "BR"), ("WB001", "Kolkata", "WB"),
    ]

    results = []
    for code, name, state in districts:
        try:
            result = fetch_district_weather.delay(code, name, state)
            results.append({"district": code, "task_id": str(result.id)})
        except Exception as e:
            logger.error("weather_fetch_failed", district=code, error=str(e))

    logger.info("weather_fetch_dispatched", count=len(results))
    return {"dispatched": len(results)}


@celery_app.task(bind=True, name="app.tasks.weather_tasks.fetch_district_weather")
def fetch_district_weather(self, district_code: str, district_name: str, state_code: str):
    """Fetch weather for a single district from IMD API."""
    import random
    from datetime import datetime, timezone, timedelta

    logger.info("fetching_district_weather", district=district_code)

    # Generate realistic weather data (in production: call IMD API)
    weather_data = {
        "current": {
            "temp_c": round(random.uniform(25, 38), 1),
            "humidity_pct": random.randint(40, 90),
            "wind_speed_kmh": round(random.uniform(5, 25), 1),
            "wind_direction": random.choice(["N", "NE", "E", "SE", "S", "SW", "W", "NW"]),
            "condition": random.choice(["Sunny", "Partly Cloudy", "Cloudy", "Light Rain"]),
            "rainfall_mm": round(random.uniform(0, 20), 1),
        },
        "forecast_5day": [
            {
                "date": (datetime.now() + timedelta(days=i)).strftime("%Y-%m-%d"),
                "max_c": round(random.uniform(28, 38), 1),
                "min_c": round(random.uniform(20, 27), 1),
                "rain_mm": round(random.uniform(0, 30), 1),
                "condition": random.choice(["Sunny", "Partly Cloudy", "Light Rain", "Moderate Rain"]),
            }
            for i in range(1, 6)
        ],
        "advisory": "सिंचाई पर ध्यान दें। फसलों की निगरानी करें।",
    }

    # In production: store to DB
    logger.info("weather_fetched", district=district_code, temp=weather_data["current"]["temp_c"])
    return {"district": district_code, "data": weather_data}
