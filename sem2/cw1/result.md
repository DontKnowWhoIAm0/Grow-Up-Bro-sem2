## Создание очереди

### Задание 1. Оптимизация простого запроса

Используйте таблицу `store_checks`.

Исходный запрос:
```sql
SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';
```

Что нужно сделать:
```text
1. Постройте план выполнения запроса до изменений.
2. Укажите:
   - какой тип сканирования использован;
   - какие из уже созданных индексов не помогают этому запросу;
   - почему планировщик выбирает именно такой план.
3. Создайте индекс, который лучше подходит под этот запрос.
4. Повторно постройте план выполнения.
5. Кратко объясните, что изменилось в плане и почему.
6. Ответьте, нужно ли после создания индекса выполнять ANALYZE, и зачем.
```

Ответ:
1. Постройте план выполнения запроса до изменений:
```sql
EXPLAIN ANALYZE
SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';
```

Результат:
```bash
Seq Scan on store_checks  (cost=0.00..1880.07 rows=1 width=26) (actual time=11.939..11.942 rows=3 loops=1)
   Filter: ((sold_at >= '2025-02-14 00:00:00'::timestamp without time zone) AND (sold_at < '2025-02-15 00:00:00'::timestamp without time zone) AND (shop_id = 77))
   Rows Removed by Filter: 70001
 Planning Time: 0.551 ms
 Execution Time: 12.082 ms
(5 rows)
```

2. Анализ плана:
- Использован Seq Scan
- Оба индекса не помогают, так как построены на тех столбцах, которые не используются в запросе
- Нет индексов, которые смогли бы ускорить обработку таблицы, поэтому используется просто последовательная проверка всех строк

3. Индекс:
```sql
CREATE INDEX idx_store_checks_shop_date ON store_checks (shop_id, sold_at);
```

4. Повторный план выполнения:
```sql
EXPLAIN ANALYZE
SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';
```

Результат:
```bash
 Index Scan using idx_store_checks_shop_date on store_checks  (cost=0.42..8.44 rows=1 width=26) (actual time=0.108..0.111 rows=3 loops=1)
   Index Cond: ((shop_id = 77) AND (sold_at >= '2025-02-14 00:00:00'::timestamp without time zone) AND (sold_at < '2025-02-15 00:00:00'::timestamp without time zone))
 Planning Time: 0.646 ms
 Execution Time: 0.144 ms
(4 rows)
```

5. Теперь сканирование изменилось на Index Scan, что ускоряет поиск нужных строк, так как появился индекс на те столбцы, которые используются в запросе.

6. Да, нужно, чтобы обновить статистику таблицы — эту информацию планировщик будет использовать бля выбора оптимального плана сканирования.



### Задание 2. Анализ и улучшение JOIN-запроса

Используйте таблицы `club_members` и `club_visits`.

Исходный запрос:

```sql
SELECT m.id, m.member_level, v.spend, v.visit_at
FROM club_members m
JOIN club_visits v ON v.member_id = m.id
WHERE m.member_level = 'premium'
  AND v.visit_at >= TIMESTAMP '2025-02-01 00:00:00'
  AND v.visit_at < TIMESTAMP '2025-02-10 00:00:00';
```

Что нужно сделать:

```text
1. Постройте план выполнения запроса до изменений.
2. Определите, какой тип JOIN использован.
3. Объясните, почему планировщик выбрал именно этот тип JOIN.
4. Укажите, какие существующие индексы полезны слабо или не полезны для этого запроса.
5. Предложите и создайте одно улучшение, которое может ускорить запрос.
   Допустимые варианты: новый индекс, другой более подходящий индекс, ANALYZE.
6. Повторно постройте план выполнения.
7. Кратко поясните, улучшился ли план и за счет чего.
8. Отдельно укажите, что означает преобладание shared hit или read в BUFFERS.
```

Ответ:
1. Постройте план выполнения запроса до изменений:
```sql
EXPLAIN ANALYZE
SELECT m.id, m.member_level, v.spend, v.visit_at
FROM club_members m
JOIN club_visits v ON v.member_id = m.id
WHERE m.member_level = 'premium'
  AND v.visit_at >= TIMESTAMP '2025-02-01 00:00:00'
  AND v.visit_at < TIMESTAMP '2025-02-10 00:00:00';
```

Результат:
```bash
 Hash Join  (cost=685.59..1794.91 rows=727 width=27) (actual time=10.912..18.155 rows=819 loops=1)
   Hash Cond: (v.member_id = m.id)
   ->  Bitmap Heap Scan on club_visits v  (cost=228.27..1308.95 rows=10912 width=22) (actual time=6.658..11.787 rows=10998 loops=1)
         Recheck Cond: ((visit_at >= '2025-02-01 00:00:00'::timestamp without time zone) AND (visit_at < '2025-02-10 00:00:00'::timestamp without time zone))
         Heap Blocks: exact=917
         ->  Bitmap Index Scan on idx_club_visits_visit_at  (cost=0.00..225.54 rows=10912 width=0) (actual time=6.476..6.477 rows=10998 loops=1)
               Index Cond: ((visit_at >= '2025-02-01 00:00:00'::timestamp without time zone) AND (visit_at < '2025-02-10 00:00:00'::timestamp without time zone))
   ->  Hash  (cost=439.00..439.00 rows=1466 width=13) (actual time=4.222..4.224 rows=1466 loops=1)
         Buckets: 2048  Batches: 1  Memory Usage: 85kB
         ->  Seq Scan on club_members m  (cost=0.00..439.00 rows=1466 width=13) (actual time=0.025..3.754 rows=1466 loops=1)
               Filter: (member_level = 'premium'::text)
               Rows Removed by Filter: 20534
 Planning Time: 1.000 ms
 Execution Time: 19.362 ms
(14 rows)
```

2. Используется Hash Join

3. Одна таблица большая, вторая — меньше, поэтому выгодно построить hash-таблицу по одной из них и искать строки по хэшу

4. Полезен частично idx_club_visits_visit_at, так как помогает искать по условию WHERE. Не полезен idx_club_members_full_name, так как имя в запросе не используется

5. Можно создать индекс по столбцу соединения и условию WHERE:
```sql
CREATE INDEX idx_club_visits_member_date ON club_visits (member_id, visit_at);
```

6. Повторный план:
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT m.id, m.member_level, v.spend, v.visit_at
FROM club_members m
JOIN club_visits v ON v.member_id = m.id
WHERE m.member_level = 'premium'
  AND v.visit_at >= TIMESTAMP '2025-02-01 00:00:00'
  AND v.visit_at < TIMESTAMP '2025-02-10 00:00:00';
```

Результат:
```bash
 Hash Join  (cost=685.59..1794.91 rows=727 width=27) (actual time=6.896..14.196 rows=819 loops=1)
   Hash Cond: (v.member_id = m.id)
   Buffers: shared hit=1112
   ->  Bitmap Heap Scan on club_visits v  (cost=228.27..1308.95 rows=10912 width=22) (actual time=1.894..5.973 rows=10998 loops=1)
         Recheck Cond: ((visit_at >= '2025-02-01 00:00:00'::timestamp without time zone) AND (visit_at < '2025-02-10 00:00:00'::timestamp without time zone))
         Heap Blocks: exact=917
         Buffers: shared hit=948
         ->  Bitmap Index Scan on idx_club_visits_visit_at  (cost=0.00..225.54 rows=10912 width=0) (actual time=1.684..1.685 rows=10998 loops=1)
               Index Cond: ((visit_at >= '2025-02-01 00:00:00'::timestamp without time zone) AND (visit_at < '2025-02-10 00:00:00'::timestamp without time zone))
               Buffers: shared hit=31
   ->  Hash  (cost=439.00..439.00 rows=1466 width=13) (actual time=4.960..4.962 rows=1466 loops=1)
         Buckets: 2048  Batches: 1  Memory Usage: 85kB
         Buffers: shared hit=164
         ->  Seq Scan on club_members m  (cost=0.00..439.00 rows=1466 width=13) (actual time=0.033..4.211 rows=1466 loops=1)
               Filter: (member_level = 'premium'::text)
               Rows Removed by Filter: 20534
               Buffers: shared hit=164
 Planning:
   Buffers: shared hit=28 read=6
 Planning Time: 1.095 ms
 Execution Time: 14.355 ms
(21 rows)
```

7. План не изменился, но время выполнения стало меньше.

8. Shared hit — считанные из кэша страницы, read — считанные из памяти. Преобладание shared hit показывает, что большая часть страниц была взята из буффера.



### Задание 3. MVCC и очистка

Используйте таблицу `warehouse_items`.

Последовательно выполните:

```sql
SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;

UPDATE warehouse_items
SET stock = stock - 2
WHERE id = 1;

SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;

DELETE FROM warehouse_items
WHERE id = 3;

SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;
```

Что нужно сделать:

```text
1. Опишите, что изменилось после UPDATE с точки зрения xmin, xmax и ctid.
2. Объясните, почему в модели MVCC UPDATE не является простым "перезаписыванием" строки.
3. Объясните, что произошло после DELETE и почему строка исчезла из обычного SELECT.
4. Кратко сравните:
   - VACUUM;
   - autovacuum;
   - VACUUM FULL.
5. Отдельно укажите, какой из этих механизмов может полностью блокировать таблицу.
```

Результаты выполнения запросов:
```bash
 xmin | xmax | ctid  | id |  title  | stock
------+------+-------+----+---------+-------
  738 |    0 | (0,1) |  1 | Cable   |    40
  738 |    0 | (0,2) |  2 | Adapter |    25
  738 |    0 | (0,3) |  3 | Hub     |    12
```

```bash
 xmin | xmax | ctid  | id |  title  | stock
------+------+-------+----+---------+-------
  747 |    0 | (0,4) |  1 | Cable   |    38
  738 |    0 | (0,2) |  2 | Adapter |    25
  738 |    0 | (0,3) |  3 | Hub     |    12
```

```bash
 xmin | xmax | ctid  | id |  title  | stock
------+------+-------+----+---------+-------
  747 |    0 | (0,4) |  1 | Cable   |    38
  738 |    0 | (0,2) |  2 | Adapter |    25
```

Ответ:
1. В xmax строки был записан id транзакции (747), которая выполнила UPDATE, создалась новая версия строки, в которой xmin равен ID этой транзакции (747). ctid в старой строке стало указывать на расположение новой версии (0,4), а в новой версии указывается расположение этой строки (тоже (0,4))

2. MVCC позволяет сохранять все версии строк. Если просто изменить запись, то историчность потеряется

3. После delete в xmax строки записался id транзакции, которая удалила ее. Фактически строка есть, но она стала невидимой, так как отмечена в xmax, поэтому select ее не вывел.

4. Сравнение:
- VACUUM освобождает место и удаляет id строк из индексов, но место не возвращается устройству, туда будут записываться новые данные. Происходит очистка мертвых строк.
- autovacuum — это фоновый процесс, который запускается, когда количество мертвых строк превышает установленный лимит. Он освобождает место в таблице (не возвращая его устройству), но не удаляет id строки из индексов
- VACUUM FULL перестраивает индексы и таблицы, удаляя мертвые строки, чтобы сам файл весил меньше

5. VACUUM FULL



### Задание 4. Блокировки строк

Используйте таблицу `booking_slots`.

Откройте две сессии к базе данных: `A` и `B`.

В сессии `A` выполните:

```sql
BEGIN;
SELECT * FROM booking_slots WHERE id = 1 FOR KEY SHARE;
```

В сессии `B` выполните:

```sql
DELETE FROM booking_slots
WHERE id = 1;
```

После наблюдения результата завершите сессию `A`:

```sql
ROLLBACK;
```

Затем повторите эксперимент.

В сессии `A` выполните:

```sql
BEGIN;
SELECT * FROM booking_slots WHERE id = 1 FOR NO KEY UPDATE;
```

В сессии `B` выполните:

```sql
UPDATE booking_slots
SET reserved_count = reserved_count + 1
WHERE id = 1;
```

После наблюдения результата завершите сессию `A`:

```sql
ROLLBACK;
```

Что нужно сделать:

```text
1. Опишите, что происходит с DELETE и UPDATE в сессии B в двух экспериментах.
2. Объясните, чем FOR KEY SHARE отличается от FOR NO KEY UPDATE по смыслу и по силе блокировки.
3. Укажите, почему обычный SELECT без FOR KEY SHARE/FOR NO KEY UPDATE ведет себя иначе.
4. Кратко поясните, где в прикладных сценариях может использоваться FOR NO KEY UPDATE.
```

Ответ:
1. В первом эксперименте сессией А строка блокируется, поэтому DELETE не выполняется сразу, а ставится на ожидание. Как только сессия А завершается, DELETE выполняется. Аналогично с UPDATE

2. FOR KEY SHARE слабее, чем FOR NO KEY UPDATE, так как FOR NO KEY UPDATE готовит строку к последующим изменениям

3. Обычный SELECT не устанавливает блокировку, что не мешает UPDATE и DELETE, так как данные для select берутся из снимка данных

4. FOR NO KEY UPDATE используется, если нужно безопасно изменять данные (например, при банковских операциях)



### Задание 5. Секционирование и partition pruning

Используйте таблицу-источник `shipment_stats_src`.

Сначала самостоятельно создайте секционированную таблицу `shipment_stats`:

```text
1. Таблица должна быть секционирована по LIST по полю region_code.
2. Создайте секции:
   - north;
   - south;
   - west;
   - DEFAULT.
3. Перенесите данные из shipment_stats_src в shipment_stats.
```

Постройте планы для двух запросов:

```sql
SELECT region_code, shipped_on, packages
FROM shipment_stats
WHERE region_code = 'north';
```

```sql
SELECT region_code, shipped_on, packages
FROM shipment_stats
WHERE shipped_on >= DATE '2025-02-10'
  AND shipped_on < DATE '2025-02-15';
```

Что нужно сделать:

```text
1. Для каждого запроса укажите, есть ли partition pruning.
2. Для каждого запроса укажите, сколько секций участвует в плане.
3. Объясните, почему в одном случае планировщик может отсечь секции, а в другом — нет.
4. Ответьте, связан ли pruning напрямую с наличием обычного индекса.
5. Кратко объясните, зачем в этом задании нужна секция DEFAULT.
```

Ответ:

Создание таблиц:
```sql
CREATE TABLE shipment_stats (
    region_code TEXT NOT NULL,
    shipped_on DATE NOT NULL,
    packages INTEGER NOT NULL,
    avg_weight NUMERIC(8,2)
)
PARTITION BY LIST (region_code);

CREATE TABLE shipment_stats_north
PARTITION OF shipment_stats
FOR VALUES IN ('north');

CREATE TABLE shipment_stats_south
PARTITION OF shipment_stats
FOR VALUES IN ('south');

CREATE TABLE shipment_stats_west
PARTITION OF shipment_stats
FOR VALUES IN ('west');

CREATE TABLE shipment_stats_default
PARTITION OF shipment_stats
DEFAULT;
```

Перенос данных:
```sql
INSERT INTO shipment_stats
SELECT *
FROM shipment_stats_src;
```

1. План выполнения первого запроса:
```sql
EXPLAIN
SELECT region_code, shipped_on, packages
FROM shipment_stats
WHERE region_code = 'north';
```

Результат:
```bash
Seq Scan on shipment_stats_north shipment_stats  (cost=0.00..17.25 rows=900 width=14)
   Filter: (region_code = 'north'::text)
(2 rows)
```

Partition pruning есть, используется только shipment_stats_north


План выполнения второго запроса:
```sql
EXPLAIN
SELECT region_code, shipped_on, packages
FROM shipment_stats
WHERE shipped_on >= DATE '2025-02-10'
  AND shipped_on < DATE '2025-02-15';
```

Результат:
```bash
 Append  (cost=0.00..64.73 rows=687 width=14)
   ->  Seq Scan on shipment_stats_north shipment_stats_1  (cost=0.00..19.50 rows=225 width=14)
         Filter: ((shipped_on >= '2025-02-10'::date) AND (shipped_on < '2025-02-15'::date))
   ->  Seq Scan on shipment_stats_south shipment_stats_2  (cost=0.00..19.50 rows=225 width=14)
         Filter: ((shipped_on >= '2025-02-10'::date) AND (shipped_on < '2025-02-15'::date))
   ->  Seq Scan on shipment_stats_west shipment_stats_3  (cost=0.00..19.50 rows=225 width=13)
         Filter: ((shipped_on >= '2025-02-10'::date) AND (shipped_on < '2025-02-15'::date))
   ->  Seq Scan on shipment_stats_default shipment_stats_4  (cost=0.00..2.80 rows=12 width=13)
         Filter: ((shipped_on >= '2025-02-10'::date) AND (shipped_on < '2025-02-15'::date))
(9 rows)
```

Partition pruning нет, так как в запросе нет условий на region_code.

2. В первом запросе участвует 1 секция, во втором — все 4.

3. Если в запросе есть условие с колонкой, по которой идет секционирование, то система определяет, в каких секциях точно нет нужных строк и не рассматривает их. Если в запросе нет условия по столбцу секционирования, то заранее узнать, где будут нужные данные невозможно, будут просматриваться все секции

4. Нет. Partition pruning идет по ключу секциноривания, а не по столбцу с индексом

5. В секцию default будут попадать все данные, у которых region_code не лежит в списке (north, south, west). Без нее данные с east пропадут.