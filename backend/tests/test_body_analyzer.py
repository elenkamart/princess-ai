from app.schemas.body_analysis import BodyAnalysisRequest, BodyType
from app.services.body_analyzer import BodyAnalyzer

analyzer = BodyAnalyzer()


def test_detects_pear() -> None:
    result = analyzer.analyze(
        BodyAnalysisRequest(
            bust_cm=90,
            waist_cm=69,
            hips_cm=104,
            shoulders_cm=88,
        )
    )
    assert result.body_type == BodyType.PEAR


def test_detects_hourglass() -> None:
    result = analyzer.analyze(
        BodyAnalysisRequest(
            bust_cm=96,
            waist_cm=70,
            hips_cm=98,
            shoulders_cm=96,
        )
    )
    assert result.body_type == BodyType.HOURGLASS


def test_detects_inverted_triangle() -> None:
    result = analyzer.analyze(
        BodyAnalysisRequest(
            bust_cm=103,
            waist_cm=82,
            hips_cm=89,
            shoulders_cm=106,
        )
    )
    assert result.body_type == BodyType.INVERTED_TRIANGLE
