from app.schemas.style_score import (
    Improvement,
    ScoreBreakdown,
    StyleScoreRequest,
    StyleScoreResponse,
)


class StyleScoreEngine:
    WEIGHTS = {
        "body_fit": 25,
        "color_harmony": 15,
        "style_match": 15,
        "occasion_match": 15,
        "proportion_balance": 10,
        "item_compatibility": 10,
        "accessories": 5,
        "weather_match": 5,
    }

    IMPROVEMENT_MESSAGES = {
        "body_fit": "Выберите фасон, который лучше поддерживает пропорции вашей фигуры.",
        "color_harmony": "Замените один из основных цветов на оттенок из вашей персональной палитры.",
        "style_match": "Уберите элемент, который выбивается из выбранного направления.",
        "occasion_match": "Скорректируйте уровень формальности под выбранный повод.",
        "proportion_balance": "Добавьте акцент, который визуально уравновесит верх и низ.",
        "item_compatibility": "Замените наименее сочетающийся предмет комплекта.",
        "accessories": "Добавьте один лаконичный аксессуар или уберите лишний акцент.",
        "weather_match": "Адаптируйте слой или обувь к погоде.",
    }

    def calculate(self, data: StyleScoreRequest) -> StyleScoreResponse:
        raw = data.model_dump()
        active_keys = [key for key in self.WEIGHTS if raw.get(key) is not None]
        active_weight = sum(self.WEIGHTS[key] for key in active_keys)

        normalized_scores: dict[str, float] = {}
        total = 0.0

        for key, base_weight in self.WEIGHTS.items():
            value = raw.get(key)
            if value is None:
                normalized_scores[key] = 0.0
                continue
            adjusted_weight = base_weight * 100 / active_weight
            points = value * adjusted_weight
            normalized_scores[key] = round(points, 2)
            total += points

        rounded_total = max(0, min(100, round(total)))
        improvements = self._improvements(raw, active_weight)

        return StyleScoreResponse(
            total=rounded_total,
            label=self._label(rounded_total),
            breakdown=ScoreBreakdown(**normalized_scores),
            improvements=improvements,
        )

    def _improvements(self, values: dict[str, float | None], active_weight: int) -> list[Improvement]:
        candidates: list[Improvement] = []

        for key, value in values.items():
            if value is None or value >= 0.85:
                continue
            adjusted_weight = self.WEIGHTS[key] * 100 / active_weight
            potential_gain = round((1 - value) * adjusted_weight)
            candidates.append(
                Improvement(
                    key=key,
                    message=self.IMPROVEMENT_MESSAGES[key],
                    potential_gain=max(1, potential_gain),
                )
            )

        return sorted(candidates, key=lambda item: item.potential_gain, reverse=True)[:3]

    @staticmethod
    def _label(score: int) -> str:
        if score >= 90:
            return "Великолепный образ"
        if score >= 80:
            return "Очень удачный образ"
        if score >= 70:
            return "Хорошая основа"
        if score >= 60:
            return "Можно улучшить"
        return "Образ требует доработки"
