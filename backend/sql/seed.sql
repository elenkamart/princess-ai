INSERT INTO clothing_categories (code, name_ru) VALUES
    ('top', 'Верх'),
    ('bottom', 'Низ'),
    ('dress', 'Платья'),
    ('outerwear', 'Верхняя одежда'),
    ('shoes', 'Обувь'),
    ('bag', 'Сумки'),
    ('accessory', 'Аксессуары')
ON CONFLICT (code) DO NOTHING;

INSERT INTO colors (code, name_ru, hex, temperature, intensity) VALUES
    ('ivory', 'Молочный', '#FFF8E7', 'neutral', 'light'),
    ('navy', 'Тёмно-синий', '#1B263B', 'cool', 'deep'),
    ('emerald', 'Изумрудный', '#0B6B53', 'cool', 'deep'),
    ('dusty_rose', 'Пыльная роза', '#C98B98', 'cool', 'muted'),
    ('chocolate', 'Шоколадный', '#5A3825', 'warm', 'deep')
ON CONFLICT (code) DO NOTHING;

INSERT INTO occasions (code, name_ru, formality_level, rules) VALUES
    ('casual', 'Повседневный образ', 1, '{"comfort_priority": true}'),
    ('work', 'Работа', 3, '{"avoid": ["too_revealing"]}'),
    ('date', 'Свидание', 3, '{"allow_accent": true}'),
    ('theatre', 'Театр', 4, '{"elegance_priority": true}'),
    ('wedding_guest', 'Гость на свадьбе', 4, '{"avoid": ["white_total_look"]}')
ON CONFLICT (code) DO NOTHING;

INSERT INTO style_rules (
    code, rule_type, conditions, effects, priority, explanation_key
) VALUES
(
    'pear_v_neck_positive',
    'body_shape',
    '{"body_type":"pear","category":"top","neckline":"v_neck"}',
    '{"score":8,"tags":["balances_upper_body","elongates_neck"]}',
    80,
    'pear_v_neck_positive'
),
(
    'pear_large_side_pockets_warning',
    'body_shape',
    '{"body_type":"pear","category":"bottom","pocket_type":"large_side_pockets"}',
    '{"score":-6,"tags":["adds_volume_to_hips"]}',
    70,
    'pear_large_pockets_warning'
),
(
    'hourglass_waist_definition',
    'body_shape',
    '{"body_type":"hourglass","waist":"defined"}',
    '{"score":10,"tags":["preserves_natural_balance"]}',
    90,
    'hourglass_waist_definition'
)
ON CONFLICT (code) DO NOTHING;
