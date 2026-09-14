"""
Pydantic schemas for API request/response validation.
"""
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, List
from datetime import datetime, date
from uuid import UUID


# ─── Common ───
class ResponseBase(BaseModel):
    success: bool = True
    message: str = "OK"


class PaginatedResponse(ResponseBase):
    total: int = 0
    page: int = 1
    page_size: int = 20


# ─── Farmer Schemas ───
class FarmerRegister(BaseModel):
    aadhaar_number: str = Field(..., min_length=12, max_length=12)
    phone_number: str = Field(..., min_length=10, max_length=13)
    full_name: Optional[str] = None
    preferred_language: str = Field(default="hi", pattern="^(en|hi)$")
    device_id: Optional[str] = None
    district_code: Optional[str] = None
    state_code: Optional[str] = None


class FarmerLogin(BaseModel):
    phone_number: str = Field(..., min_length=10, max_length=13)
    device_id: str


class FarmerResponse(BaseModel):
    id: UUID
    preferred_language: str
    full_name: Optional[str] = None
    district_code: Optional[str] = None
    state_code: Optional[str] = None
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    farmer: FarmerResponse


# ─── Farm Plot Schemas ───
class FarmPlotCreate(BaseModel):
    plot_name: str
    boundary_geojson: Optional[str] = None
    area_sqm: Optional[float] = None
    soil_type: Optional[str] = None
    current_crop: Optional[str] = None
    sowing_date: Optional[datetime] = None
    gps_lat: Optional[float] = None
    gps_lon: Optional[float] = None


class FarmPlotResponse(BaseModel):
    id: UUID
    farmer_id: UUID
    plot_name: str
    area_sqm: Optional[float] = None
    soil_type: Optional[str] = None
    current_crop: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


# ─── Diagnosis Schemas ───
class DiagnosisSubmit(BaseModel):
    model_config = ConfigDict(protected_namespaces=())
    image_hash: str
    disease_name: str
    disease_name_hi: Optional[str] = None
    confidence: float = Field(..., ge=0.0, le=1.0)
    severity: Optional[str] = None
    crop_type: Optional[str] = None
    treatment_recommendation: Optional[str] = None
    treatment_recommendation_hi: Optional[str] = None
    gps_lat: Optional[float] = None
    gps_lon: Optional[float] = None
    district_code: Optional[str] = None
    device_signature: Optional[str] = None
    model_version: Optional[str] = None
    plot_id: Optional[UUID] = None


class DiagnosisResponse(BaseModel):
    id: UUID
    farmer_id: UUID
    disease_name: str
    disease_name_hi: Optional[str] = None
    confidence: float
    severity: Optional[str] = None
    crop_type: Optional[str] = None
    treatment_recommendation: Optional[str] = None
    treatment_recommendation_hi: Optional[str] = None
    gps_lat: Optional[float] = None
    gps_lon: Optional[float] = None
    sync_status: str
    diagnosed_at: datetime

    class Config:
        from_attributes = True


# ─── Weather Schemas ───
class WeatherQuery(BaseModel):
    district_code: str
    state_code: Optional[str] = None


class WeatherResponse(BaseModel):
    district_code: str
    district_name: Optional[str] = None
    forecast_data: dict
    compressed_payload: Optional[str] = None
    source: str
    fetched_at: datetime
    expires_at: datetime
    hours_left_in_cache: Optional[float] = None

    class Config:
        from_attributes = True


# ─── Mandi Price Schemas ───
class MandiPriceQuery(BaseModel):
    district_code: Optional[str] = None
    state_code: Optional[str] = None
    crop_name: Optional[str] = None
    date_from: Optional[date] = None
    date_to: Optional[date] = None


class MandiPriceResponse(BaseModel):
    id: UUID
    market_name: str
    crop_name: str
    crop_name_hi: Optional[str] = None
    price_per_quintal: float
    min_price: Optional[float] = None
    max_price: Optional[float] = None
    price_trend: Optional[str] = None
    price_change_pct: Optional[float] = None
    price_date: date
    source: str

    class Config:
        from_attributes = True


# ─── Mesh Packet Schemas ───
class MeshPacketSubmit(BaseModel):
    origin_device_id: str
    destination_device_id: Optional[str] = None
    packet_type: str
    payload_encrypted: str  # Base64 encoded
    payload_hash: str
    signature: str
    nonce: Optional[str] = None  # Base64 encoded
    priority: int = Field(default=5, ge=1, le=10)
    ttl_hours: int = Field(default=24, ge=1, le=168)
    hop_count: int = Field(default=0, ge=0)
    max_hops: int = Field(default=5, ge=1, le=10)


class MeshPacketResponse(BaseModel):
    id: UUID
    origin_device_id: str
    packet_type: str
    payload_hash: str
    status: str
    hop_count: int
    received_at: datetime
    expires_at: datetime

    class Config:
        from_attributes = True


# ─── Insurance Schemas ───
class InsuranceClaimSubmit(BaseModel):
    policy_number: Optional[str] = None
    claim_type: str
    evidence_video_hash: str
    evidence_video_url: Optional[str] = None
    metadata_signature: str
    device_metadata: Optional[dict] = None
    gps_lat: Optional[float] = None
    gps_lon: Optional[float] = None
    district_code: Optional[str] = None


class InsuranceClaimResponse(BaseModel):
    id: UUID
    farmer_id: UUID
    claim_type: str
    claim_status: str
    evidence_video_hash: str
    blockchain_tx_id: Optional[str] = None
    submitted_at: datetime
    settlement_amount: Optional[float] = None

    class Config:
        from_attributes = True


# ─── Fertilizer Schemas ───
class FertilizerVerifyRequest(BaseModel):
    qr_data: Optional[str] = None
    barcode: Optional[str] = None
    seal_image_hash: Optional[str] = None


class FertilizerVerifyResponse(BaseModel):
    is_authentic: bool
    product_name: Optional[str] = None
    manufacturer: Optional[str] = None
    batch_number: Optional[str] = None
    valid_until: Optional[datetime] = None
    is_revoked: bool = False
    confidence: float = 0.0
    message: str = ""


# ─── Kriging Schemas ───
class KrigingQuery(BaseModel):
    disease_name: Optional[str] = None
    state_code: Optional[str] = None
    district_code: Optional[str] = None
    prediction_hours: int = Field(default=72, ge=1, le=168)


class KrigingResponse(BaseModel):
    disease_name: str
    risk_surface: dict  # GeoJSON with risk values
    prediction_hours: int
    generated_at: datetime
    data_points_used: int


# ─── Dashboard Schemas ───
class DashboardStats(BaseModel):
    total_farmers: int = 0
    total_diagnoses: int = 0
    active_diseases: int = 0
    total_insurance_claims: int = 0
    mesh_packets_today: int = 0
    counterfeit_alerts: int = 0
    districts_covered: int = 0


# ─── Sync Schemas ───
class SyncRequest(BaseModel):
    device_id: str
    last_sync_at: Optional[datetime] = None
    merkle_root: Optional[str] = None
    data_types: List[str] = Field(default=["diagnoses", "weather", "prices"])


class SyncResponse(BaseModel):
    new_records: dict
    updated_records: dict
    merkle_root: str
    server_time: datetime
