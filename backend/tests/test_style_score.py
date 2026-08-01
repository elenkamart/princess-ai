from app.schemas.style_score import StyleScoreRequest
from app.services.style_score import StyleScoreEngine

engine = StyleScoreEngine()


def test_perfect_score() -> None:
    result = engine.calculate(
        StyleScoreRequest(
            body_fit=1,
            color_harmony=1,
            style_match=1,
            occasion_match=1,
            proportion_balance=1,
            item_compatibility=1,
            accessories=1,
            weather_match=1,
        )
    )
    assert result.total == 100
    assert result.improvements == []


def test_missing_optional_fields_are_reweighted() -> None:
    result = engine.calculate(
        StyleScoreRequest(
            body_fit=1,
            color_harmony=None,
            style_match=1,
            occasion_match=1,
            proportion_balance=1,
            item_compatibility=1,
            accessories=None,
            weather_match=None,
        )
    )
    assert result.total == 100


def test_returns_top_three_improvements() -> None:
    result = engine.calculate(
        StyleScoreRequest(
            body_fit=0.4,
            color_harmony=0.4,
            style_match=0.4,
            occasion_match=0.4,
            proportion_balance=0.4,
            item_compatibility=0.4,
            accessories=0.4,
            weather_match=0.4,
        )
    )
    assert len(result.improvements) == 3
