## Аномалии и способы их решения

### Аномалии вставки
- В не нормализованной модели могли бы возникнуть аномалии вставки, когда невозможно было добавить совет или характеристику без указания связанного растения.
- В текущей нормализованной структуре эти проблемы не встречаются за счёт выделения отдельных справочных таблиц и связующих таблиц, которые позволяют добавлять данные независимо друг от друга.

### Аномалии обновления
- Проблема массового обновления повторяющихся данных устранена благодаря нормализованной структуре: повторяющиеся сведения вынесены в справочники, связаны через внешние ключи.
- Изменение, например, типа полива или сложности требует обновления только одного значения в справочнике.

### Аномалии удаления
- В структуре отсутствует потеря ценной информации, не связанной напрямую с удаляемой записью, благодаря выделению справочников.

## Нормализация структуры

- В исходной структуре ранее были созданы отдельные таблицы-справочники для всех повторяющихся видов данных (освещение (`refs.sunlight`), полив (`refs.watering`), безопасность (`refs.safety`), сложность (`refs.difficulty`), размер (`refs.size`), температура (`refs.temperature`) и др.).
- Для отношений многие-ко-многим так же имелись отдельные связующие таблицы (`links.plant_tip`, `links.plant_feature`).
- Все таблицы имеют первичные ключи, а все внешние ключи корректно ссылаются на соответствующие справочники. В `main.plant`:
```sql
sunlight_id INT REFERENCES refs.sunlight(id),
watering_id INT REFERENCES refs.watering(id),
temperature_id INT REFERENCES refs.temperature(id),
safety_id INT REFERENCES refs.safety(id),
difficulty_id INT REFERENCES refs.difficulty(id),
size_id INT REFERENCES refs.size(id),
fertilizer_id INT REFERENCES main.fertilizer(id)
```
- Добавлены ограничения целостности: `UNIQUE` ограничения на уникальные поля справочных таблиц, чтобы избежать дублирования. 
```sql
ALTER TABLE refs.sunlight ADD CONSTRAINT sunlight_type_unique UNIQUE (type);
ALTER TABLE refs.watering ADD CONSTRAINT watering_type_unique UNIQUE (type);
ALTER TABLE refs.temperature ADD CONSTRAINT temperature_type_unique UNIQUE (type);
ALTER TABLE refs.safety ADD CONSTRAINT safety_type_unique UNIQUE (type);
ALTER TABLE refs.difficulty ADD CONSTRAINT difficulty_type_unique UNIQUE (type);
ALTER TABLE refs.size ADD CONSTRAINT size_type_unique UNIQUE (type);
ALTER TABLE main.fertilizer ADD CONSTRAINT fertilizer_name_unique UNIQUE (name);
ALTER TABLE main.advice ADD CONSTRAINT advice_tip_text_unique UNIQUE (tip_text);
ALTER TABLE refs.feature ADD CONSTRAINT feature_name_unique UNIQUE (name);
```