"""
Application-wide constants.
"""

# ─── Supported Languages ───
SUPPORTED_LANGUAGES = ["en", "hi"]
DEFAULT_LANGUAGE = "hi"

# ─── Crop Types ───
CROP_TYPES = [
    "rice", "wheat", "maize", "cotton", "sugarcane", "soybean",
    "groundnut", "mustard", "potato", "tomato", "onion", "chilli",
    "turmeric", "ginger", "banana", "mango", "grape", "pomegranate",
    "apple", "tea", "coffee", "jute", "rubber",
]

CROP_TYPES_HI = {
    "rice": "चावल", "wheat": "गेहूं", "maize": "मक्का", "cotton": "कपास",
    "sugarcane": "गन्ना", "soybean": "सोयाबीन", "groundnut": "मूंगफली",
    "mustard": "सरसों", "potato": "आलू", "tomato": "टमाटर",
    "onion": "प्याज", "chilli": "मिर्च", "turmeric": "हल्दी",
    "ginger": "अदरक", "banana": "केला", "mango": "आम",
    "grape": "अंगूर", "pomegranate": "अनार", "apple": "सेब",
    "tea": "चाय", "coffee": "कॉफी", "jute": "जूट", "rubber": "रबर",
}

# ─── Disease Categories ───
DISEASE_SEVERITY = {
    "critical": {"min_confidence": 0.85, "color": "#FF0000"},
    "high": {"min_confidence": 0.70, "color": "#FF6600"},
    "medium": {"min_confidence": 0.50, "color": "#FFAA00"},
    "low": {"min_confidence": 0.30, "color": "#FFDD00"},
    "healthy": {"min_confidence": 0.0, "color": "#00CC00"},
}

# ─── Mesh Networking ───
MESH_PACKET_TYPES = ["diagnosis", "weather", "alert", "price", "sync", "ack"]
MESH_MAX_HOPS = 5
MESH_DEFAULT_TTL_HOURS = 24
MESH_MAX_PAYLOAD_BYTES = 4096

# ─── Insurance ───
INSURANCE_CLAIM_TYPES = ["crop_damage", "flood", "drought", "pest_attack", "hailstorm"]
INSURANCE_CLAIM_STATUSES = ["submitted", "under_review", "verified", "approved", "rejected", "settled"]

# ─── Soil Health ───
SOIL_TYPES = ["alluvial", "black", "red", "laterite", "desert", "mountain", "peaty"]
SOIL_HEALTH_PARAMS = ["ph", "nitrogen", "phosphorus", "potassium", "organic_carbon", "moisture"]

# ─── Fertilizer ───
FERTILIZER_TYPES = ["urea", "dap", "mop", "npk", "ssp", "zinc_sulphate", "borax"]

# ─── USSD ───
USSD_MAX_PAYLOAD = 140  # characters
USSD_ENCODING = "gsm7"

# ─── Sync ───
SYNC_BATCH_SIZE = 50
SYNC_CONFLICT_STRATEGY = "last_write_wins"
