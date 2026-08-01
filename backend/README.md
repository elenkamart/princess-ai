# Princess AI — MVP Backend

Первый рабочий инкремент проекта Princess AI:

- FastAPI API;
- Body Type Analyzer;
- Style Score Engine;
- Princess Mode demo endpoint;
- PostgreSQL schema;
- seed data;
- automated tests;
- Docker support.

## Быстрый запуск

### Локально

```bash
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Откройте:

- API: http://127.0.0.1:8000
- Swagger: http://127.0.0.1:8000/docs
- Health check: http://127.0.0.1:8000/health

### Docker

```bash
docker compose up --build
```

## Тесты

```bash
pytest
```

## Основные endpoints

### Анализ типа фигуры

`POST /api/v1/body-analysis`

```json
{
  "bust_cm": 92,
  "waist_cm": 70,
  "hips_cm": 101,
  "shoulders_cm": 88
}
```

### Style Score

`POST /api/v1/style-score`

```json
{
  "body_fit": 0.9,
  "color_harmony": 0.8,
  "style_match": 0.95,
  "occasion_match": 0.9,
  "proportion_balance": 0.85,
  "item_compatibility": 0.9,
  "accessories": 0.7,
  "weather_match": 1.0
}
```

### Princess Mode

`POST /api/v1/princess-mode`

```json
{
  "body_type": "pear",
  "occasion": "date",
  "preferred_style": "romantic",
  "budget_eur": 200
}
```

## Архитектурный принцип

Экспертные правила принимают решение.  
AI-слой в будущем формулирует объяснения, но не подменяет расчёты.
