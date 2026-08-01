from fastapi import APIRouter

from app.schemas.body_analysis import BodyAnalysisRequest, BodyAnalysisResponse
from app.services.body_analyzer import BodyAnalyzer

router = APIRouter(prefix="/body-analysis", tags=["body analysis"])
analyzer = BodyAnalyzer()


@router.post("", response_model=BodyAnalysisResponse)
def analyze_body(payload: BodyAnalysisRequest) -> BodyAnalysisResponse:
    return analyzer.analyze(payload)
