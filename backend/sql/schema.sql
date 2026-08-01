CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    birth_year SMALLINT,
    country CHAR(2),
    language VARCHAR(10) NOT NULL DEFAULT 'ru',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS style_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    height_cm NUMERIC(5,2),
    clothing_size VARCHAR(20),
    shoe_size VARCHAR(20),
    body_type VARCHAR(40) CHECK (
        body_type IN ('hourglass', 'pear', 'apple', 'rectangle', 'inverted_triangle')
    ),
    body_type_confidence NUMERIC(4,3) CHECK (
        body_type_confidence BETWEEN 0 AND 1
    ),
    color_season VARCHAR(20),
    color_temperature VARCHAR(20),
    preferred_fit VARCHAR(30),
    budget_level VARCHAR(30),
    onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bust_cm NUMERIC(5,2),
    waist_cm NUMERIC(5,2),
    hips_cm NUMERIC(5,2),
    shoulders_cm NUMERIC(5,2),
    inseam_cm NUMERIC(5,2),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS clothing_categories (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name_ru VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS colors (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name_ru VARCHAR(100) NOT NULL,
    hex CHAR(7),
    temperature VARCHAR(20),
    intensity VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS clothing_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_type VARCHAR(20) NOT NULL CHECK (owner_type IN ('wardrobe', 'catalog')),
    owner_id UUID,
    name TEXT NOT NULL,
    brand TEXT,
    category_id BIGINT REFERENCES clothing_categories(id),
    color_id BIGINT REFERENCES colors(id),
    neckline VARCHAR(50),
    sleeve VARCHAR(50),
    length VARCHAR(50),
    fit VARCHAR(50),
    pattern VARCHAR(50),
    season VARCHAR(50),
    price NUMERIC(12,2),
    currency CHAR(3),
    image_url TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS wardrobe_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    clothing_item_id UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
    size VARCHAR(30),
    condition VARCHAR(30),
    favorite BOOLEAN NOT NULL DEFAULT FALSE,
    times_worn INTEGER NOT NULL DEFAULT 0,
    last_worn_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, clothing_item_id)
);

CREATE TABLE IF NOT EXISTS style_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(100) UNIQUE NOT NULL,
    rule_type VARCHAR(50) NOT NULL,
    conditions JSONB NOT NULL,
    effects JSONB NOT NULL,
    priority INTEGER NOT NULL DEFAULT 50,
    explanation_key VARCHAR(150) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS occasions (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name_ru VARCHAR(100) NOT NULL,
    formality_level SMALLINT NOT NULL CHECK (formality_level BETWEEN 1 AND 5),
    rules JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS outfits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    occasion_id BIGINT REFERENCES occasions(id),
    style_code VARCHAR(50),
    score SMALLINT CHECK (score BETWEEN 0 AND 100),
    source VARCHAR(30) NOT NULL CHECK (
        source IN ('generated', 'user_created', 'stylist_curated')
    ),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS outfit_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    outfit_id UUID NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
    clothing_item_id UUID NOT NULL REFERENCES clothing_items(id),
    role VARCHAR(30) NOT NULL,
    position SMALLINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS outfit_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    outfit_id UUID UNIQUE NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
    body_fit_score NUMERIC(5,2) NOT NULL,
    color_score NUMERIC(5,2) NOT NULL,
    style_score NUMERIC(5,2) NOT NULL,
    occasion_score NUMERIC(5,2) NOT NULL,
    proportion_score NUMERIC(5,2) NOT NULL,
    compatibility_score NUMERIC(5,2) NOT NULL,
    accessories_score NUMERIC(5,2) NOT NULL,
    weather_score NUMERIC(5,2) NOT NULL,
    total_score SMALLINT NOT NULL CHECK (total_score BETWEEN 0 AND 100),
    explanation JSONB NOT NULL DEFAULT '[]'::jsonb
);

CREATE TABLE IF NOT EXISTS user_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    outfit_id UUID NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
    rating SMALLINT CHECK (rating BETWEEN 1 AND 5),
    liked BOOLEAN,
    wore_outfit BOOLEAN,
    purchased_items BOOLEAN,
    feedback_tags JSONB NOT NULL DEFAULT '[]'::jsonb,
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_clothing_items_category
    ON clothing_items(category_id);

CREATE INDEX IF NOT EXISTS idx_style_rules_type_active
    ON style_rules(rule_type, active);

CREATE INDEX IF NOT EXISTS idx_outfits_user_created
    ON outfits(user_id, created_at DESC);
