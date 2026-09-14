"""
API v1 router - Aggregates all endpoint routers.
"""
from fastapi import APIRouter
from app.api.v1.endpoints import auth, farmers, diagnoses, weather, mandi, mesh, insurance, fertilizer, kriging, dashboard, ai, telecom

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(farmers.router)
api_router.include_router(diagnoses.router)
api_router.include_router(weather.router)
api_router.include_router(mandi.router)
api_router.include_router(mesh.router)
api_router.include_router(insurance.router)
api_router.include_router(fertilizer.router)
api_router.include_router(kriging.router)
api_router.include_router(dashboard.router)
api_router.include_router(ai.router)
api_router.include_router(telecom.router)
