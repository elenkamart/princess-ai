from fastapi import APIRouter

from app.schemas.style_score import StyleScoreRequest, StyleScoreResponse
from app.services.style_score import StyleScoreEngine

router = APIRouter(prefix="/style-score", tags=["style score"])
engine = StyleScoreEngine()


@router.post("", response_model=StyleScoreResponse)
def calculate_style_score(payload: StyleScoreRequest) -> StyleScoreResponse:
    return engine.calculate(payload)
