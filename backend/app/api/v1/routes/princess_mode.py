from fastapi import APIRouter

from app.schemas.princess_mode import PrincessModeRequest, PrincessModeResponse
from app.services.princess_mode import PrincessModeService

router = APIRouter(prefix="/princess-mode", tags=["princess mode"])
service = PrincessModeService()


@router.post("", response_model=PrincessModeResponse)
def generate_princess_outfit(payload: PrincessModeRequest) -> PrincessModeResponse:
    return service.generate(payload)
