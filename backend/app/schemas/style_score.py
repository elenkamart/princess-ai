from pydantic import BaseModel, Field


class StyleScoreRequest(BaseModel):
    body_fit: float = Field(ge=0, le=1)
    color_harmony: float | None = Field(default=None, ge=0, le=1)
    style_match: float = Field(ge=0, le=1)
    occasion_match: float = Field(ge=0, le=1)
    proportion_balance: float = Field(ge=0, le=1)
    item_compatibility: float = Field(ge=0, le=1)
    accessories: float | None = Field(default=None, ge=0, le=1)
    weather_match: float | None = Field(default=None, ge=0, le=1)


class ScoreBreakdown(BaseModel):
    body_fit: float
    color_harmony: float
    style_match: float
    occasion_match: float
    proportion_balance: float
    item_compatibility: float
    accessories: float
    weather_match: float


class Improvement(BaseModel):
    key: str
    message: str
    potential_gain: int = Field(ge=0)


class StyleScoreResponse(BaseModel):
    total: int = Field(ge=0, le=100)
    label: str
    breakdown: ScoreBreakdown
    improvements: list[Improvement]
