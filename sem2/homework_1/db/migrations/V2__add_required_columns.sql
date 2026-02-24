ALTER TABLE main.plant
ADD COLUMN created_at TIMESTAMP, -- дата добавления растения в каталог
ADD COLUMN deleted_at TIMESTAMP NULL, -- дата удаления растения из каталога
ADD COLUMN rating NUMERIC(3,2), -- оценка растения
ADD COLUMN care_level VARCHAR(20), -- сложность ухода
ADD COLUMN tags TEXT[], -- метки для поиска по фильтрам
ADD COLUMN metadata JSONB, -- дополнительные характеристики
ADD COLUMN growth_period DATERANGE, -- период роста
ADD COLUMN greenhouse_zone POINT, -- подходящая зона в теплице
ADD COLUMN search_vector tsvector; 

ALTER TABLE main.fertilizer
ADD COLUMN created_at TIMESTAMP, -- дата добавления записи в каталог
ADD COLUMN price NUMERIC(8,2), -- цена
ADD COLUMN production_period DATERANGE, -- период выпуска партии
ADD COLUMN composition JSONB, -- состав
ADD COLUMN supported_sizes TEXT[], -- размеры подходящих растений
ADD COLUMN popularity_index INT, -- индекс популярности
ADD COLUMN discontinued_at TIMESTAMP NULL; -- дата удаления из каталога

ALTER TABLE main.tip
ADD COLUMN created_at TIMESTAMP, -- дата добавления
ADD COLUMN category VARCHAR(50), -- категория совета
ADD COLUMN importance_score INT, -- важность совета
ADD COLUMN metadata JSONB, -- дополнительные данные
ADD COLUMN valid_period DATERANGE, -- период актуальности
ADD COLUMN search_vector tsvector,
ADD COLUMN archived_at TIMESTAMP NULL; -- дата удаления

ALTER TABLE refs.feature
ADD COLUMN created_at TIMESTAMP, -- дата добавления
ADD COLUMN rarity_score INT, -- уровень редкости
ADD COLUMN extra_info JSONB, -- дополнительные данные
ADD COLUMN seasons TEXT[], -- сезоны, для которых характерна особенность
ADD COLUMN active_period DATERANGE, -- период активности особенности
ADD COLUMN deprecated_at TIMESTAMP NULL; 