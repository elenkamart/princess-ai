from fastapi import APIRouter

from app.api.v1.routes import body_analysis, princess_mode, style_score

api_router = APIRouter()
api_router.include_router(body_analysis.router)
api_router.include_router(style_score.router)
api_router.include_router(princess_mode.router)
