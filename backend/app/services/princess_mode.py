from app.schemas.body_analysis import BodyType
from app.schemas.princess_mode import (
    OutfitItem,
    PrincessModeRequest,
    PrincessModeResponse,
)


class PrincessModeService:
    """
    Curated MVP generator. Later this will query clothing inventory and score
    many combinations through the rule engine.
    """

    BODY_BLUEPRINTS = {
        BodyType.PEAR: {
            "top": ("Топ с выразительной линией плеч", "Балансирует верх и линию бёдер."),
            "main": ("Юбка А-силуэта миди", "Подчёркивает талию и мягко формирует силуэт."),
            "outerwear": ("Укороченный жакет", "Сохраняет акцент на талии."),
        },
        BodyType.HOURGLASS: {
            "top": ("Блуза с V-вырезом", "Поддерживает естественный баланс пропорций."),
            "main": ("Платье с акцентом на талии", "Повторяет линии фигуры без перегрузки."),
            "outerwear": ("Приталенный жакет", "Сохраняет выраженную линию талии."),
        },
        BodyType.APPLE: {
            "top": ("Топ с вертикальной линией выреза", "Визуально вытягивает силуэт."),
            "main": ("Прямые брюки со средней посадкой", "Создают чистую вертикальную линию."),
            "outerwear": ("Однобортный удлинённый жакет", "Формирует спокойную вертикаль."),
        },
        BodyType.RECTANGLE: {
            "top": ("Блуза с мягким объёмом", "Добавляет форму верхней части силуэта."),
            "main": ("Юбка с поясом и мягкими складками", "Создаёт более выраженную талию."),
            "outerwear": ("Жакет с конструктивной талией", "Добавляет архитектуру силуэту."),
        },
        BodyType.INVERTED_TRIANGLE: {
            "top": ("Лаконичный топ без объёма в плечах", "Смягчает верхнюю линию."),
            "main": ("Широкие брюки палаццо", "Добавляют баланс нижней части силуэта."),
            "outerwear": ("Жакет без подплечников", "Не усиливает ширину плеч."),
        },
    }

    def generate(self, data: PrincessModeRequest) -> PrincessModeResponse:
        blueprint = self.BODY_BLUEPRINTS[data.body_type]
        items = [
            OutfitItem(role=role, name=name, reason=reason)
            for role, (name, reason) in blueprint.items()
        ]
        items.extend(
            [
                OutfitItem(
                    role="shoes",
                    name="Лаконичные туфли или лоферы",
                    reason="Завершают образ и сохраняют выбранный уровень элегантности.",
                ),
                OutfitItem(
                    role="bag",
                    name="Структурированная сумка среднего размера",
                    reason="Добавляет собранность без визуальной перегрузки.",
                ),
                OutfitItem(
                    role="accessory",
                    name="Один выразительный аксессуар",
                    reason="Создаёт фокус и не конкурирует с силуэтом.",
                ),
            ]
        )

        title = f"{data.preferred_style.title()} образ: {data.occasion}"
        budget_note = (
            f"Комплект следует собрать в бюджете до €{data.budget_eur:.0f}."
            if data.budget_eur is not None
            else "При подборе можно использовать вещи из гардероба в первую очередь."
        )

        return PrincessModeResponse(
            title=title,
            score=91,
            items=items,
            explanation=[
                "Силуэт построен с учётом выбранного типа фигуры.",
                f"Уровень формальности адаптирован под повод: {data.occasion}.",
                f"Визуальное направление соответствует стилю: {data.preferred_style}.",
                budget_note,
            ],
            beauty_suggestions={
                "makeup": "Свежий тон, мягкий акцент на глазах или губах.",
                "hair": "Аккуратная укладка, поддерживающая характер образа.",
                "nails": "Молочный, нюдовый или оттенок из палитры комплекта.",
            },
        )
