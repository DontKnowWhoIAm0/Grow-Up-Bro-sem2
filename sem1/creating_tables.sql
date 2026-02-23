CREATE SCHEMA main;
CREATE SCHEMA refs;
CREATE SCHEMA links;

CREATE TABLE refs.sunlight (
    id SERIAL PRIMARY KEY,
    type VARCHAR(255) NOT NULL
);

CREATE TABLE refs.watering (
    id SERIAL PRIMARY KEY,
    type VARCHAR(255) NOT NULL
);

CREATE TABLE refs.temperature (
    id SERIAL PRIMARY KEY,
    type VARCHAR(255) NOT NULL
);

CREATE TABLE refs.safety (
    id SERIAL PRIMARY KEY,
    type VARCHAR(255) NOT NULL
);

CREATE TABLE refs.difficulty (
    id SERIAL PRIMARY KEY,
    type VARCHAR(255) NOT NULL
);

CREATE TABLE refs.size (
    id SERIAL PRIMARY KEY,
    type VARCHAR(255) NOT NULL
);

CREATE TABLE main.fertilizer (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	usage TEXT
);

CREATE TABLE main.plant (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	description TEXT,
	sunlight_id INT REFERENCES refs.sunlight(id),
    watering_id INT REFERENCES refs.watering(id),
    temperature_id INT REFERENCES refs.temperature(id),
    safety_id INT REFERENCES refs.safety(id),
    difficulty_id INT REFERENCES refs.difficulty(id),
    size_id INT REFERENCES refs.size(id),
    fertilizer_id INT REFERENCES main.fertilizer(id)
);

CREATE TABLE main.tip (
	id SERIAL PRIMARY KEY,
	tip_text TEXT NOT NULL
);

CREATE TABLE links.plant_tip (
	plant_id INT NOT NULL REFERENCES main.plant(id),
	tip_id INT NOT NULL REFERENCES main.tip(id),
	PRIMARY KEY (plant_id, tip_id)
);

CREATE TABLE refs.feature (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL, 
	description TEXT,
	intensity_level INT,
	safety_flag BOOLEAN,
	plant_part VARCHAR(255)
);

CREATE TABLE links.plant_feature (
	plant_id INT NOT NULL REFERENCES main.plant(id),
	feature_id INT NOT NULL REFERENCES refs.feature(id),
	PRIMARY KEY (plant_id, feature_id)
);
