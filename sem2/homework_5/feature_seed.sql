INSERT INTO refs.sunlight (id, type) VALUES (1, 'Тень'), (2, 'Прямой свет') ON CONFLICT (id) DO UPDATE SET type = EXCLUDED.type;
INSERT INTO refs.watering (id, type) VALUES (1, 'Минимальный полив'), (2, 'Обильный полив') ON CONFLICT (id) DO UPDATE SET type = EXCLUDED.type;
INSERT INTO refs.temperature (id, type) VALUES (1, 'Холодостойкое'), (2, 'Теплолюбивое') ON CONFLICT (id) DO UPDATE SET type = EXCLUDED.type;
INSERT INTO refs.safety (id, type) VALUES (1, 'Безопасное'), (2, 'Токсичное') ON CONFLICT (id) DO UPDATE SET type = EXCLUDED.type;
INSERT INTO refs.difficulty (id, type) VALUES (1, 'Простое'), (2, 'Сложное') ON CONFLICT (id) DO UPDATE SET type = EXCLUDED.type;
INSERT INTO refs.size (id, type) VALUES (1, 'Маленькое'), (2, 'Большое') ON CONFLICT (id) DO UPDATE SET type = EXCLUDED.type;

INSERT INTO main.fertilizer (
    id, name, usage, created_at, price, production_period, composition, supported_sizes, popularity_index, discontinued_at
) VALUES
    (1, 'NitroBoost', 'Promotes leaf growth', NOW(), 12.50, '[2026-01-01,2026-12-31)'::daterange, '{"N":10,"P":5,"K":5}'::jsonb, '{"Small","Medium"}'::text[], 75, NULL),
    (2, 'FlowerMax', 'Enhances flowering', NOW(), 15.00, '[2026-03-01,2026-12-31)'::daterange, '{"N":5,"P":10,"K":5}'::jsonb, '{"Medium","Large"}'::text[], 90, NULL)
ON CONFLICT (id) DO UPDATE
SET 
    name = EXCLUDED.name,
    usage = EXCLUDED.usage,
    created_at = EXCLUDED.created_at,
    price = EXCLUDED.price,
    production_period = EXCLUDED.production_period,
    composition = EXCLUDED.composition,
    supported_sizes = EXCLUDED.supported_sizes,
    popularity_index = EXCLUDED.popularity_index,
    discontinued_at = EXCLUDED.discontinued_at;

INSERT INTO main.plant (
    id, name, description, sunlight_id, watering_id, temperature_id, safety_id, difficulty_id, size_id, fertilizer_id, created_at, deleted_at, 
    rating, care_level, tags, metadata, growth_period, greenhouse_zone
) VALUES
    (1, 'Роза', 'Красная декоративная роза', 2, 2, 2, 1, 2, 1, 1, NOW(), NULL, 4.5, 'Средний', ARRAY['цветущая','декоративная'], 
    '{"fragrance": "сильный", "thorns": true}'::jsonb, '[2026-03-01,2026-06-30)'::daterange, '(10,20)'::point),
    (2, 'Тюльпан', 'Весенний яркий тюльпан', 2, 1, 1, 1, 1, 2, 2, NOW(), NULL, 4.0, 'Простой', ARRAY['цветущий','первый'], 
    '{"fragrance": "слабый", "thorns": false}'::jsonb, '[2026-03-15,2026-05-30)'::daterange, '(5,15)'::point)
ON CONFLICT (id) DO UPDATE
SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    sunlight_id = EXCLUDED.sunlight_id,
    watering_id = EXCLUDED.watering_id,
    temperature_id = EXCLUDED.temperature_id,
    safety_id = EXCLUDED.safety_id,
    difficulty_id = EXCLUDED.difficulty_id,
    size_id = EXCLUDED.size_id,
    fertilizer_id = EXCLUDED.fertilizer_id,
    created_at = EXCLUDED.created_at,
    deleted_at = EXCLUDED.deleted_at,
    rating = EXCLUDED.rating,
    care_level = EXCLUDED.care_level,
    tags = EXCLUDED.tags,
    metadata = EXCLUDED.metadata,
    growth_period = EXCLUDED.growth_period,
    greenhouse_zone = EXCLUDED.greenhouse_zone;

INSERT INTO refs.feature (
    id, name, description, intensity_level, safety_flag, plant_part, created_at, rarity_score, extra_info, seasons, active_period, deprecated_at
) VALUES
    (1, 'Ароматное', 'Обладает приятным запахом', 3, true, 'Цветок', NOW(), 2, '{"notes": "Привлекает опылителей"}'::jsonb, 
    ARRAY['весна','лето'], '[2026-03-01,2026-08-31)'::daterange, NULL),
    (2, 'Колючее', 'Имеет острые шипы', 4, false, 'Стебель', NOW(), 3, '{"warning": "Осторожно при уходе"}'::jsonb,
     ARRAY['круглый год'], '[2026-01-01,2026-12-31)'::daterange, NULL),
    (3, 'Ядовитое', 'Содержит токсичные вещества', 5, false, 'Листья', NOW(), 4, '{"toxicity_level": "high"}'::jsonb,
     ARRAY['весна','лето','осень'], '[2026-02-01,2026-10-31)'::daterange, NULL)
ON CONFLICT (id) DO UPDATE
SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    intensity_level = EXCLUDED.intensity_level,
    safety_flag = EXCLUDED.safety_flag,
    plant_part = EXCLUDED.plant_part,
    created_at = EXCLUDED.created_at,
    rarity_score = EXCLUDED.rarity_score,
    extra_info = EXCLUDED.extra_info,
    seasons = EXCLUDED.seasons,
    active_period = EXCLUDED.active_period,
    deprecated_at = EXCLUDED.deprecated_at;

INSERT INTO links.plant_feature (plant_id, feature_id)
VALUES (1, 1), (1, 2), (2, 1), (2, 3)
ON CONFLICT (plant_id, feature_id) DO NOTHING;