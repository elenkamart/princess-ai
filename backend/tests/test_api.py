from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_body_analysis_endpoint() -> None:
    response = client.post(
        "/api/v1/body-analysis",
        json={
            "bust_cm": 90,
            "waist_cm": 69,
            "hips_cm": 104,
            "shoulders_cm": 88,
        },
    )
    assert response.status_code == 200
    assert response.json()["body_type"] == "pear"


def test_style_score_endpoint() -> None:
    response = client.post(
        "/api/v1/style-score",
        json={
            "body_fit": 0.9,
            "color_harmony": 0.8,
            "style_match": 0.95,
            "occasion_match": 0.9,
            "proportion_balance": 0.85,
            "item_compatibility": 0.9,
            "accessories": 0.7,
            "weather_match": 1.0,
        },
    )
    assert response.status_code == 200
    assert 0 <= response.json()["total"] <= 100


def test_princess_mode_endpoint() -> None:
    response = client.post(
        "/api/v1/princess-mode",
        json={
            "body_type": "pear",
            "occasion": "date",
            "preferred_style": "romantic",
            "budget_eur": 200,
        },
    )
    assert response.status_code == 200
    body = response.json()
    assert body["score"] >= 90
    assert len(body["items"]) >= 6
