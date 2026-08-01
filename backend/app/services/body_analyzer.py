from app.schemas.body_analysis import (
    BodyAnalysisRequest,
    BodyAnalysisResponse,
    BodyProportions,
    BodyType,
)


class BodyAnalyzer:
    """
    Deterministic MVP classifier.

    It uses relative differences, not fixed clothing sizes. Thresholds are
    intentionally conservative and should later be calibrated with stylist
    review and anonymized user feedback.
    """

    BALANCE_TOLERANCE = 0.05
    STRONG_DIFFERENCE = 0.10
    DEFINED_WAIST_RATIO = 0.78
    MODERATE_WAIST_RATIO = 0.84

    def analyze(self, data: BodyAnalysisRequest) -> BodyAnalysisResponse:
        bust = data.bust_cm
        waist = data.waist_cm
        hips = data.hips_cm
        shoulders = data.shoulders_cm

        upper_reference = max(bust, shoulders)
        lower_reference = hips
        frame_reference = max(upper_reference, lower_reference)
        upper_lower_delta = (upper_reference - lower_reference) / frame_reference
        waist_ratio = waist / ((bust + hips) / 2)

        body_type, confidence = self._classify(
            bust=bust,
            hips=hips,
            shoulders=shoulders,
            upper_lower_delta=upper_lower_delta,
            waist_ratio=waist_ratio,
        )

        proportions = BodyProportions(
            shoulders_vs_hips=self._relationship(shoulders, hips),
            waist_definition=self._waist_definition(waist_ratio),
            bust_vs_hips=self._relationship(bust, hips),
        )

        goals = {
            BodyType.HOURGLASS: ["preserve_balance", "emphasize_waist"],
            BodyType.PEAR: ["balance_upper_body", "emphasize_waist"],
            BodyType.APPLE: ["elongate_silhouette", "create_vertical_lines"],
            BodyType.RECTANGLE: ["create_waist_definition", "add_shape"],
            BodyType.INVERTED_TRIANGLE: ["balance_lower_body", "soften_shoulder_line"],
        }[body_type]

        explanations = {
            BodyType.HOURGLASS: "Верх и бёдра близки по пропорциям, а талия заметно выражена.",
            BodyType.PEAR: "Нижняя часть силуэта выражена сильнее верхней, талия заметна.",
            BodyType.APPLE: "Талия выражена мягче, а объём сосредоточен ближе к центру силуэта.",
            BodyType.RECTANGLE: "Плечи, грудь и бёдра близки по пропорциям, талия выражена умеренно.",
            BodyType.INVERTED_TRIANGLE: "Верхняя часть силуэта визуально шире линии бёдер.",
        }

        return BodyAnalysisResponse(
            body_type=body_type,
            confidence=round(confidence, 2),
            proportions=proportions,
            recommended_goals=goals,
            explanation=explanations[body_type],
        )

    def _classify(
        self,
        *,
        bust: float,
        hips: float,
        shoulders: float,
        upper_lower_delta: float,
        waist_ratio: float,
    ) -> tuple[BodyType, float]:
        upper = max(bust, shoulders)

        if upper_lower_delta >= self.STRONG_DIFFERENCE:
            confidence = min(0.98, 0.78 + upper_lower_delta)
            return BodyType.INVERTED_TRIANGLE, confidence

        if upper_lower_delta <= -self.STRONG_DIFFERENCE:
            confidence = min(0.98, 0.78 + abs(upper_lower_delta))
            return BodyType.PEAR, confidence

        if waist_ratio <= self.DEFINED_WAIST_RATIO:
            balance = 1 - abs(upper - hips) / max(upper, hips)
            return BodyType.HOURGLASS, min(0.97, 0.78 + balance * 0.18)

        if waist_ratio >= self.MODERATE_WAIST_RATIO:
            central_fullness = waist_ratio
            if central_fullness >= 0.90:
                return BodyType.APPLE, min(0.94, 0.72 + (central_fullness - 0.90))
            return BodyType.RECTANGLE, 0.82

        return BodyType.RECTANGLE, 0.74

    @staticmethod
    def _relationship(first: float, second: float) -> str:
        delta = (first - second) / max(first, second)
        if abs(delta) <= 0.05:
            return "balanced"
        return "wider" if delta > 0 else "narrower"

    def _waist_definition(self, ratio: float) -> str:
        if ratio <= self.DEFINED_WAIST_RATIO:
            return "defined"
        if ratio <= self.MODERATE_WAIST_RATIO:
            return "moderate"
        return "soft"
