ALTER TABLE main.fertilizer ADD COLUMN type VARCHAR(100);
ALTER TABLE refs.feature DROP COLUMN plant_part;
ALTER TABLE refs.feature ALTER COLUMN intensity_level TYPE VARCHAR(255);
ALTER TABLE main.tip RENAME TO advice;