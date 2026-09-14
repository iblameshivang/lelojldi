"""
USSD Encoder/Decoder - 140-character payload for 2G SMS fallback.
Implements Huffman-like compression for weather and price data.
"""
from typing import Dict, List, Optional
import json


# Character frequency table for agricultural data (custom Huffman-like)
FIELD_CODES = {
    "temperature": "T",
    "humidity": "H",
    "rainfall": "R",
    "wind_speed": "W",
    "wind_direction": "D",
    "condition": "C",
    "crop_name": "N",
    "price": "P",
    "trend": "X",
    "district": "Z",
    "date": "A",
    "forecast": "F",
}

TREND_CODES = {"up": "↑", "down": "↓", "stable": "→"}

CONDITION_CODES = {
    "sunny": "☀", "clear": "☀", "cloudy": "☁", "partly cloudy": "⛅",
    "rain": "🌧", "light rain": "🌦", "moderate rain": "🌧",
    "heavy rain": "⛈", "thunderstorm": "⚡", "fog": "🌫",
}

USSD_MAX_CHARS = 140


def encode_weather_ussd(weather_data: dict, district_code: str) -> str:
    """Compress weather forecast into 140-char USSD payload."""
    current = weather_data.get("current", {})
    forecast = weather_data.get("forecast_5day", [])

    # Format: WX|DIST|TEMP°C|HUM%|RAIN mm|WIND|3d:T1/T2/T3
    parts = [
        f"WX|{district_code}",
        f"{current.get('temp_c', '?')}°C",
        f"{current.get('humidity_pct', '?')}%",
        f"{current.get('rainfall_mm', 0)}mm",
        f"{current.get('wind_direction', '?')}{current.get('wind_speed_kmh', '?')}",
    ]

    # Add 3-day forecast temperatures
    if forecast:
        temps = "/".join([str(f.get("max_c", "?")) for f in forecast[:3]])
        parts.append(f"3d:{temps}°C")

    # Add advisory (truncated)
    advisory = weather_data.get("advisory", "")
    if advisory:
        remaining = USSD_MAX_CHARS - len("|".join(parts)) - 2
        if remaining > 10:
            parts.append(advisory[:remaining])

    payload = "|".join(parts)
    return payload[:USSD_MAX_CHARS]


def encode_mandi_ussd(prices: list, district_code: str) -> str:
    """Compress mandi prices into 140-char USSD payload."""
    # Format: MN|DIST|CROP:PRICE↑|CROP:PRICE↓|...
    parts = [f"MN|{district_code}"]

    for price in prices[:6]:  # Max 6 crops to fit
        crop = price.get("crop_name", "?")[:4]  # Truncate crop name
        amount = int(price.get("price_per_quintal", 0))
        trend = TREND_CODES.get(price.get("price_trend", "stable"), "→")
        parts.append(f"{crop}:{amount}{trend}")

    payload = "|".join(parts)
    return payload[:USSD_MAX_CHARS]


def decode_ussd_payload(payload: str) -> dict:
    """Decode a USSD-compressed payload."""
    parts = payload.split("|")
    if not parts:
        return {"error": "Empty payload"}

    msg_type = parts[0]

    if msg_type == "WX":
        return _decode_weather(parts)
    elif msg_type == "MN":
        return _decode_mandi(parts)
    else:
        return {"type": "unknown", "raw": payload}


def _decode_weather(parts: list) -> dict:
    """Decode weather USSD payload."""
    result = {"type": "weather"}
    if len(parts) > 1:
        result["district"] = parts[1]
    if len(parts) > 2:
        result["temperature"] = parts[2]
    if len(parts) > 3:
        result["humidity"] = parts[3]
    if len(parts) > 4:
        result["rainfall"] = parts[4]
    if len(parts) > 5:
        result["wind"] = parts[5]
    if len(parts) > 6:
        result["forecast_3day"] = parts[6]
    return result


def _decode_mandi(parts: list) -> dict:
    """Decode mandi USSD payload."""
    result = {"type": "mandi"}
    if len(parts) > 1:
        result["district"] = parts[1]
    prices = []
    for part in parts[2:]:
        if ":" in part:
            crop, price_trend = part.split(":", 1)
            prices.append({"crop": crop, "price_trend": price_trend})
    result["prices"] = prices
    return result
