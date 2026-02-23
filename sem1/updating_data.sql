UPDATE main.plant
SET description = 'Тропическое растение с большими резными листьями'
WHERE name = 'Монстера';

UPDATE main.plant
SET sunlight_id = 2
WHERE name = 'Сансевиерия';

UPDATE main.fertilizer
SET usage = 'Подкармливать растения каждые 2 недели, растворяя 1 столовую ложку на 1 литр воды'
WHERE name = 'Азофоска';

UPDATE main.tip
SET tip_text = 'Поливайте растения утром или вечером, чтобы избежать загнивания корней.'
WHERE id = 1;

UPDATE links.plant_tip
SET tip_id = 2
WHERE plant_id = 5 AND tip_id = 5;