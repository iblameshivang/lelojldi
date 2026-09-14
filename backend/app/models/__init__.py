"""
Models package - Import all models for Alembic auto-discovery.
"""
from app.models.farmer import Farmer, FarmPlot
from app.models.diagnosis import CropDiagnosis
from app.models.weather import WeatherCache
from app.models.mandi import MandiPrice
from app.models.mesh import MeshPacket
from app.models.insurance import InsuranceClaim
from app.models.fertilizer import FertilizerRegistry
from app.models.disease_telemetry import DiseaseTelemetry

__all__ = [
    "Farmer", "FarmPlot", "CropDiagnosis", "WeatherCache",
    "MandiPrice", "MeshPacket", "InsuranceClaim",
    "FertilizerRegistry", "DiseaseTelemetry",
]
