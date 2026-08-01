from pydantic import BaseModel, Field

from app.schemas.body_analysis import BodyType


class PrincessModeRequest(BaseModel):
    body_type: BodyType
    occasion: str = Field(min_length=2, max_length=50)
    preferred_style: str = Field(min_length=2, max_length=50)
    budget_eur: float | None = Field(default=None, ge=0, le=100000)


class OutfitItem(BaseModel):
    role: str
    name: str
    reason: str


class PrincessModeResponse(BaseModel):
    title: str
    score: int
    items: list[OutfitItem]
    explanation: list[str]
    beauty_suggestions: dict[str, str]
