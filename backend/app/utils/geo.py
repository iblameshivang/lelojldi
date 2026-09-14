"""
Geo utilities - Distance calculations, bounding boxes, district mapping.
"""
import math
from typing import Tuple, List, Optional


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate great-circle distance between two GPS points in km."""
    R = 6371  # Earth's radius in km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c


def bounding_box(lat: float, lon: float, radius_km: float) -> dict:
    """Get bounding box around a point for spatial queries."""
    lat_delta = radius_km / 111.0  # ~111km per degree lat
    lon_delta = radius_km / (111.0 * math.cos(math.radians(lat)))

    return {
        "lat_min": lat - lat_delta,
        "lat_max": lat + lat_delta,
        "lon_min": lon - lon_delta,
        "lon_max": lon + lon_delta,
    }


def points_within_radius(
    center_lat: float,
    center_lon: float,
    radius_km: float,
    points: List[Tuple[float, float]],
) -> List[Tuple[float, float]]:
    """Filter points within a radius of a center point."""
    return [
        (lat, lon) for lat, lon in points
        if haversine_distance(center_lat, center_lon, lat, lon) <= radius_km
    ]


def convex_hull_area(points: List[Tuple[float, float]]) -> float:
    """Approximate area of convex hull in square meters from GPS points."""
    if len(points) < 3:
        return 0.0

    # Simple shoelace formula for polygon area (approximate for small regions)
    n = len(points)
    area = 0.0
    for i in range(n):
        j = (i + 1) % n
        # Convert to approximate meters
        lat_m = points[i][0] * 111320
        lon_m = points[i][1] * 111320 * math.cos(math.radians(points[i][0]))
        lat_m_next = points[j][0] * 111320
        lon_m_next = points[j][1] * 111320 * math.cos(math.radians(points[j][0]))

        area += lat_m * lon_m_next
        area -= lat_m_next * lon_m

    return abs(area) / 2.0


# India state codes to names mapping
INDIA_STATES = {
    "AN": "Andaman and Nicobar", "AP": "Andhra Pradesh", "AR": "Arunachal Pradesh",
    "AS": "Assam", "BR": "Bihar", "CG": "Chhattisgarh", "CH": "Chandigarh",
    "DD": "Daman and Diu", "DL": "Delhi", "GA": "Goa", "GJ": "Gujarat",
    "HP": "Himachal Pradesh", "HR": "Haryana", "JH": "Jharkhand", "JK": "Jammu and Kashmir",
    "KA": "Karnataka", "KL": "Kerala", "LA": "Ladakh", "MH": "Maharashtra",
    "ML": "Meghalaya", "MN": "Manipur", "MP": "Madhya Pradesh", "MZ": "Mizoram",
    "NL": "Nagaland", "OD": "Odisha", "PB": "Punjab", "PY": "Puducherry",
    "RJ": "Rajasthan", "SK": "Sikkim", "TN": "Tamil Nadu", "TS": "Telangana",
    "TR": "Tripura", "UK": "Uttarakhand", "UP": "Uttar Pradesh", "WB": "West Bengal",
}
