-- admin — полный доступ
CREATE ROLE admin LOGIN PASSWORD 'admin_pass';
-- все права на все схемы
GRANT ALL PRIVILEGES ON SCHEMA main TO admin;
GRANT ALL PRIVILEGES ON SCHEMA refs TO admin;
GRANT ALL PRIVILEGES ON SCHEMA links TO admin;
-- все права на все существующие таблицы в схемах
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA main TO admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA refs TO admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA links TO admin;
-- все права для всех создаваемых в будущем таблиц
ALTER DEFAULT PRIVILEGES IN SCHEMA main GRANT ALL PRIVILEGES ON TABLES TO admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA refs GRANT ALL PRIVILEGES ON TABLES TO admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA links GRANT ALL PRIVILEGES ON TABLES TO admin;
-- права на sequence для добавления данных
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA main TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA refs TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA links TO admin;

-- analyst — только чтение данных для обработки и анализа
CREATE ROLE analyst LOGIN PASSWORD 'analyst_pass';
-- право на использование объектов внутри схем (нет прав на создание таблиц)
GRANT USAGE ON SCHEMA main TO analyst;
GRANT USAGE ON SCHEMA refs TO analyst;
GRANT USAGE ON SCHEMA links TO analyst;
-- право только читать все существующие таблицы
GRANT SELECT ON ALL TABLES IN SCHEMA main TO analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA refs TO analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA links TO analyst;
-- все сздаваемые в будущем таблицы будут доступны только для чтения
ALTER DEFAULT PRIVILEGES IN SCHEMA main GRANT SELECT ON TABLES TO analyst;
ALTER DEFAULT PRIVILEGES IN SCHEMA refs GRANT SELECT ON TABLES TO analyst;
ALTER DEFAULT PRIVILEGES IN SCHEMA links GRANT SELECT ON TABLES TO analyst;

-- lab_assistant — добавление новых растений, удобрений и советов
CREATE ROLE lab_assistant LOGIN PASSWORD 'lab_assistant_pass';
-- право на использование объектов внутри схем (нет прав на создание таблиц)
GRANT USAGE ON SCHEMA main TO lab_assistant;
GRANT USAGE ON SCHEMA refs TO lab_assistant;
GRANT USAGE ON SCHEMA links TO lab_assistant;
-- право на чтение, добавление и изменение данных в основных таблицах
GRANT SELECT, INSERT, UPDATE ON TABLE main.plant TO lab_assistant;
GRANT SELECT, INSERT, UPDATE ON TABLE main.tip TO lab_assistant;
GRANT SELECT, INSERT, UPDATE ON TABLE main.fertilizer TO lab_assistant;
GRANT SELECT, INSERT, UPDATE ON TABLE links.plant_tip TO lab_assistant;
GRANT SELECT, INSERT, UPDATE ON TABLE links.plant_feature TO lab_assistant;
-- право только чтения в справочниках
GRANT SELECT ON ALL TABLES IN SCHEMA refs TO lab_assistant;
-- для новых таблиц в main право на чтение, добавление и изменение данных, для новых таблиц в refs — только чтение
ALTER DEFAULT PRIVILEGES IN SCHEMA main GRANT SELECT, INSERT, UPDATE ON TABLES TO lab_assistant;
ALTER DEFAULT PRIVILEGES IN SCHEMA refs GRANT SELECT ON TABLES TO lab_assistant;
-- права на sequence, чтобы вставлять новые записи
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA main TO lab_assistant;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA links TO lab_assistant;