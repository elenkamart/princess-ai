from enum import StrEnum

from pydantic import BaseModel, Field, model_validator


class BodyType(StrEnum):
    HOURGLASS = "hourglass"
    PEAR = "pear"
    APPLE = "apple"
    RECTANGLE = "rectangle"
    INVERTED_TRIANGLE = "inverted_triangle"


class BodyAnalysisRequest(BaseModel):
    bust_cm: float = Field(gt=40, lt=220)
    waist_cm: float = Field(gt=35, lt=220)
    hips_cm: float = Field(gt=40, lt=240)
    shoulders_cm: float = Field(gt=30, lt=180)

    @model_validator(mode="after")
    def validate_measurements(self) -> "BodyAnalysisRequest":
        values = [self.bust_cm, self.waist_cm, self.hips_cm, self.shoulders_cm]
        if max(values) / min(values) > 3:
            raise ValueError("Measurements appear inconsistent.")
        return self


class BodyProportions(BaseModel):
    shoulders_vs_hips: str
    waist_definition: str
    bust_vs_hips: str


class BodyAnalysisResponse(BaseModel):
    body_type: BodyType
    confidence: float = Field(ge=0, le=1)
    proportions: BodyProportions
    recommended_goals: list[str]
    explanation: str
