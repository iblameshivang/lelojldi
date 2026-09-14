"""
Kriging computation tasks - Batch disease risk surface generation.
"""
from app.tasks.celery_app import celery_app
import structlog

logger = structlog.get_logger()


@celery_app.task(bind=True, name="app.tasks.kriging_tasks.compute_risk_surfaces")
def compute_risk_surfaces(self):
    """Compute kriging risk surfaces for all active diseases."""
    logger.info("kriging_computation_started")

    diseases = ["leaf_blight", "rust", "powdery_mildew", "bacterial_wilt", "mosaic_virus"]
    results = []

    for disease in diseases:
        try:
            result = compute_disease_surface.delay(disease)
            results.append({"disease": disease, "task_id": str(result.id)})
        except Exception as e:
            logger.error("kriging_failed", disease=disease, error=str(e))

    logger.info("kriging_dispatched", count=len(results))
    return {"dispatched": len(results)}


@celery_app.task(bind=True, name="app.tasks.kriging_tasks.compute_disease_surface")
def compute_disease_surface(self, disease_name: str):
    """Compute kriging surface for a single disease using IDW interpolation."""
    import math
    import random
    from datetime import datetime, timezone

    logger.info("computing_surface", disease=disease_name)

    # In production: fetch real data from disease_telemetry table
    # For now: generate representative data points
    data_points = [
        (random.uniform(20, 30), random.uniform(75, 85), random.uniform(0.3, 0.95))
        for _ in range(random.randint(10, 50))
    ]

    # Grid parameters
    lat_min, lat_max = 20.0, 30.0
    lon_min, lon_max = 75.0, 85.0
    grid_size = 20

    lat_step = (lat_max - lat_min) / grid_size
    lon_step = (lon_max - lon_min) / grid_size

    risk_grid = []
    for i in range(grid_size):
        for j in range(grid_size):
            lat = lat_min + i * lat_step
            lon = lon_min + j * lon_step

            # IDW interpolation
            weights_sum = 0
            value_sum = 0
            for plat, plon, pval in data_points:
                dist = math.sqrt((lat - plat) ** 2 + (lon - plon) ** 2)
                if dist < 0.001:
                    risk = pval
                    break
                w = 1 / (dist ** 2)
                weights_sum += w
                value_sum += w * pval
            else:
                risk = value_sum / weights_sum if weights_sum > 0 else 0

            if risk > 0.05:
                risk_grid.append({
                    "lat": round(lat, 4),
                    "lon": round(lon, 4),
                    "risk": round(risk, 4),
                })

    result = {
        "disease": disease_name,
        "grid_points": len(risk_grid),
        "data_points_used": len(data_points),
        "computed_at": datetime.now(timezone.utc).isoformat(),
    }

    logger.info("surface_computed", disease=disease_name, points=len(risk_grid))
    return result
