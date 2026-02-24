INSERT INTO main.fertilizer (
    name, usage, created_at, price, production_period, composition, supported_sizes, popularity_index, discontinued_at
)
SELECT
    'Fertilizer ' || gs AS name,
    'Использовать ' || gs || ' раз в неделю' AS usage,
    NOW() - (random() * interval '365 days') AS created_at,
    ROUND((10 + random() * 90)::numeric, 2) AS price, -- цена 10–100
    daterange(
        (NOW() - (random() * interval '365 days'))::date,
        (NOW() + (random() * interval '365 days'))::date
    ) AS production_period,
    jsonb_build_object(
        'N', ROUND((random()*10)::numeric,1),
        'P', ROUND((random()*10)::numeric,1),
        'K', ROUND((random()*10)::numeric,1)
    ) AS composition,
    ARRAY[ (ARRAY['Small','Medium','Large'])[floor(random()*3+1)::int] ]::TEXT[] AS supported_sizes,
    FLOOR(1 + random() * 100) AS popularity_index,
    CASE WHEN random() < 0.1 THEN NOW() - (random() * interval '100 days') ELSE NULL END AS discontinued_at -- NULL
FROM generate_series(1, 250000) gs;

INSERT INTO main.plant (
    name, description, sunlight_id, watering_id, temperature_id, safety_id, difficulty_id, size_id,
    fertilizer_id, created_at, deleted_at, rating, care_level, tags, metadata, growth_period, greenhouse_zone, search_vector
)
SELECT
    'Plant ' || gs AS name,
    'Описание растения ' || gs AS description,
    1 + floor(random()*3)::INT AS sunlight_id, -- низкая кардинальность
    1 + floor(random()*3)::INT AS watering_id, -- низкая кардинальность
    1 + floor(random()*3)::INT AS temperature_id, -- низкая кардинальность
    1 + floor(random()*2)::INT AS safety_id, -- низкая кардинальность
    1 + floor(random()*3)::INT AS difficulty_id, -- низкая кардинальность
    1 + floor(random()*3)::INT AS size_id, -- низкая кардинальность
    1 + floor(random()*250000)::INT AS fertilizer_id, -- высокая кардинальность
    NOW() - (random() * interval '365 days') AS created_at,
    CASE WHEN random() < 0.1 THEN NOW() - (random() * interval '100 days') ELSE NULL END AS deleted_at, -- NULL
    ROUND((random()*5)::numeric,2) AS rating,
    (ARRAY['Low','Medium','High'])[floor(random()*3+1)] AS care_level,
    ARRAY[ (ARRAY['indoor','outdoor','flowering','edible','herb'])[floor(random()*5+1)::int] ]::TEXT[] AS tags,
    jsonb_build_object(
        'height', ROUND((random()*100)::numeric,1),
        'width', ROUND((random()*50)::numeric,1),
        'color', (ARRAY['red','green','blue','yellow','purple'])[floor(random()*5+1)]
    ) AS metadata,
    daterange(
        (NOW() - (random() * interval '100 days'))::date,
        (NOW() + (random() * interval '200 days'))::date
    ) AS growth_period,
    point(random()*100, random()*50) AS greenhouse_zone,
    to_tsvector('russian', 'Plant ' || gs || ' ' || 'Описание растения') AS search_vector
FROM generate_series(1, 250000) gs;

INSERT INTO main.tip (
    tip_text, created_at, category, importance_score, metadata, valid_period, search_vector, archived_at
)
SELECT
    'Совет по уходу ' || gs AS tip_text,
    NOW() - (random() * interval '365 days') AS created_at,
    (ARRAY['watering','fertilizer','light','temperature','safety'])[floor(random()*5+1)] AS category,
    FLOOR(random()*10+1) AS importance_score,
    jsonb_build_object('duration_days', FLOOR(random()*30)) AS metadata,
    daterange(
        (NOW() - (random() * interval '100 days'))::date,
        (NOW() + (random() * interval '200 days'))::date
    ) AS valid_period,
    to_tsvector('russian', 'Совет по уходу ' || gs) AS search_vector,
    CASE WHEN random() < 0.1 THEN NOW() - (random() * interval '50 days') ELSE NULL END AS archived_at -- NULL
FROM generate_series(1, 250000) gs;

-- Сильно неравномерное распределение (Zipf)
INSERT INTO links.plant_tip (plant_id, tip_id)
SELECT
    1 + floor(POWER(random(), 2) * 250000)::INT AS plant_id, -- 70% попадет в 10% растений
    1 + floor(random()*250000)::INT AS tip_id
FROM generate_series(1, 300000) gs
ON CONFLICT (plant_id, tip_id) DO NOTHING;

INSERT INTO refs.feature (
    name, description, intensity_level, safety_flag, plant_part, created_at, rarity_score, extra_info, seasons, active_period, deprecated_at
)
SELECT
    'Feature ' || gs AS name,
    'Описание особенности ' || gs AS description,
    FLOOR(random()*5+1) AS intensity_level,
    (random() < 0.1) AS safety_flag,
    (ARRAY['leaf','stem','root','flower','fruit'])[floor(random()*5+1)] AS plant_part,
    NOW() - (random() * interval '365 days') AS created_at,
    FLOOR(random()*100+1) AS rarity_score,
    jsonb_build_object('notes','Extra info '||gs) AS extra_info,
    ARRAY[(ARRAY['spring','summer','autumn','winter'])[floor(random()*4+1)]] AS seasons,
    daterange(
        (NOW() - (random() * interval '100 days'))::date,
        (NOW() + (random() * interval '200 days'))::date
    ) AS active_period,
    CASE WHEN random() < 0.05 THEN NOW() - (random() * interval '50 days') ELSE NULL END AS deprecated_at
FROM generate_series(1, 100000) gs;

INSERT INTO links.plant_feature (plant_id, feature_id)
SELECT
    1 + floor(random()*250000)::INT AS plant_id,
    1 + floor(random()*100000)::INT AS feature_id
FROM generate_series(1, 300000) gs
ON CONFLICT (plant_id, feature_id) DO NOTHING;