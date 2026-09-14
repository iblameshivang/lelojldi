"""
Krishi-Saarthi AI & LLM Endpoints
Provides chat, multimodal leaf diagnosis, API key management, and agricultural knowledge.
"""
from fastapi import APIRouter, HTTPException, Header
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from app.services.ai_service import AIService, AGRICULTURAL_KNOWLEDGE_BASE, SCHEMES_KNOWLEDGE

router = APIRouter(prefix="/ai", tags=["AI & LLM Agronomist"])


class ChatRequest(BaseModel):
    message: str = Field(..., description="Farmer query or agronomic question")
    language: str = Field("hi", description="Language code ('hi', 'en', 'mr', 'pa')")
    history: Optional[List[Dict[str, str]]] = Field(None, description="Prior conversation history")
    api_key: Optional[str] = Field(None, description="Optional Google Gemini API Key override")


class DiagnoseRequest(BaseModel):
    image_base64: str = Field(..., description="Base64 encoded leaf photograph")
    crop_hint: Optional[str] = Field(None, description="Crop name (wheat, rice, cotton, etc.)")
    language: str = Field("hi", description="Language for diagnosis report")
    api_key: Optional[str] = Field(None, description="Optional Google Gemini API Key override")


class ConfigureKeyRequest(BaseModel):
    api_key: str = Field(..., description="Google Gemini API key")


@router.post("/chat")
async def chat_agronomist(req: ChatRequest, x_api_key: Optional[str] = Header(None)):
    """Conversational agronomist: answers farming questions via Gemini LLM or ICAR RAG knowledge."""
    effective_key = req.api_key or x_api_key
    res = await AIService.chat_with_agronomist(
        message=req.message,
        language=req.language,
        history=req.history,
        override_key=effective_key
    )
    return res


@router.post("/diagnose")
async def diagnose_leaf(req: DiagnoseRequest, x_api_key: Optional[str] = Header(None)):
    """Multimodal vision diagnosis: inspects leaf image for pathogens, cures, and spot spray dosages."""
    effective_key = req.api_key or x_api_key
    res = await AIService.diagnose_leaf_image(
        image_base64=req.image_base64,
        crop_hint=req.crop_hint,
        language=req.language,
        override_key=effective_key
    )
    return res


from app.services.rate_limiter import gemini_limiter, mask_key

@router.get("/key-status")
async def get_key_status(x_api_key: Optional[str] = Header(None)):
    """Check if Gemini API Key is configured and ready."""
    key = AIService.get_api_key(x_api_key)
    if key and len(key) > 8:
        masked = mask_key(key)
        limiter_info = gemini_limiter.get_status()
        return {
            "configured": True,
            "masked_key": masked,
            "active_model": "gemini-2.5-flash",
            "capabilities": ["multimodal_vision", "voice_copilot", "icar_rag", "realtime_treatment"],
            "status": "ready",
            "quota": limiter_info
        }
    return {
        "configured": False,
        "masked_key": None,
        "active_model": "icar-offline-edge",
        "capabilities": ["icar_offline_rag", "quantized_cv", "rule_based_dosage"],
        "status": "offline_fallback_active"
    }


@router.post("/configure-key")
async def configure_api_key(req: ConfigureKeyRequest):
    """Runtime configuration of Gemini API Key for demo and local deployments."""
    cleaned = req.api_key.strip()
    if len(cleaned) < 10:
        raise HTTPException(status_code=400, detail="Invalid API Key format")
    AIService.set_runtime_api_key(cleaned)
    return {
        "success": True,
        "message": "Google Gemini API Key configured successfully",
        "masked_key": mask_key(cleaned)
    }


@router.get("/knowledge")
async def get_agricultural_knowledge():
    """Retrieve full ICAR package of practices and government schemes reference data."""
    return {
        "crops": AGRICULTURAL_KNOWLEDGE_BASE,
        "schemes": SCHEMES_KNOWLEDGE,
        "source": "ICAR-CIBRC Agronomic Standards 2026"
    }


@router.get("/quota-status")
async def get_quota_status():
    """Returns Gemini API sliding window quota (15 requests/hour free-tier protection)."""
    return gemini_limiter.get_status()

