-- 1. Создание таблицы для гостей вечеринки
CREATE TABLE guest_list (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    contact_email VARCHAR(100) NOT NULL UNIQUE,
    arrived BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT check_name_non_empty 
		CHECK (COALESCE(NULLIF(TRIM(full_name), ''), 'default_value') != 'default_value'),
    CONSTRAINT check_email_non_empty 
		CHECK (COALESCE(NULLIF(TRIM(contact_email), ''), 'default_value') != 'default_value')
);

-- 2. Создание пользователя "manager" и предоставление прав
CREATE USER event_manager WITH PASSWORD 'qwerty';
GRANT USAGE ON SCHEMA public TO event_manager;
GRANT SELECT, INSERT ON TABLE guest_list TO event_manager;
GRANT USAGE, SELECT ON SEQUENCE guest_list_id_seq TO event_manager;

-- 3. Создание представления с именами гостей
CREATE VIEW guest_names AS
SELECT full_name
FROM guest_list;

-- 4. Создание пользователя "guard" с ограниченными правами
CREATE USER event_guard WITH PASSWORD 'ytrewq';
GRANT SELECT ON guest_names TO event_guard; 

-- Также предоставляем доступ к таблице guest_list, если нужен доступ напрямую
GRANT SELECT ON guest_list TO event_guard;

-- 5. Вставка записей в таблицу гостей под ролью "event_manager"
SET ROLE event_manager;

INSERT INTO guest_list (full_name, contact_email) VALUES 
    ('Charles', 'charles_ny@yahoo.com'),
    ('Charles', 'mix_tape_charles@google.com'),
    ('Teona', 'miss_teona_99@yahoo.com');

-- 6. Проверка прав доступа для пользователя "event_guard"
SET ROLE event_guard;
SELECT * 
FROM guest_names;
SELECT * 
FROM guest_list;

-- 7. Переключение на роль "postgres" для выполнения административных операций
SET ROLE postgres;

-- 8. Создание процедуры для завершения вечеринки
CREATE OR REPLACE PROCEDURE end_party() AS $$
BEGIN
    -- Проверка и создание таблицы для черного списка
    CREATE TABLE IF NOT EXISTS blacklist (
        id SERIAL PRIMARY KEY,
        email VARCHAR(100) NOT NULL
    );

    -- Перенос тех, кто не пришел, в черный список
    INSERT INTO blacklist (email)
    SELECT contact_email
	FROM guest_list 
	WHERE arrived = FALSE;

    -- Очистка списка гостей
    DELETE FROM guest_list;
END;
$$ LANGUAGE plpgsql;

-- 9. Создание функции для регистрации новых гостей
CREATE OR REPLACE FUNCTION register_guest(name VARCHAR, email VARCHAR)
RETURNS BOOLEAN AS $$
BEGIN
    -- Проверка наличия таблицы black_list
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'blacklist') THEN
        -- Проверка, если пользователь в черном списке
        IF EXISTS (SELECT 1 FROM blacklist WHERE email = email) THEN
            RETURN FALSE;
        END IF;
    ELSE
        -- Добавление гостя в список
        INSERT INTO guest_list (full_name, contact_email) VALUES (name, email);
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 10. Регистрация нового гостя
SELECT register_guest('Petr', 'korol_party@yandex.ru');

-- 11. Обновление статуса тех, кто пришел на вечеринку
UPDATE guest_list SET arrived = TRUE 
WHERE contact_email IN ('mix_tape_charles@google.com', 'miss_teona_99@yahoo.com');

-- 12. Завершение вечеринки и добавление не пришедших в черный список
CALL end_party();
