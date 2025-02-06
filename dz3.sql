--Таблица "заявка"
create table bid (
	id serial primary key, 
	product_type varchar(50),
	client_name varchar(100),
	is_company boolean,
	amount numeric(12,2)
);

insert into bid (product_type, client_name, is_company, amount) values
('credit', 'Petrov Petr Petrovich', false, 1000000),
('credit', 'Coca cola', true, 100000000),
('deposit', 'Soho bank', true, 12000000),
('deposit', 'Kaspi bank', true, 18000000),
('deposit', 'Miksumov Anar Raxogly', false, 500000),
('debit_card', 'Miksumov Anar Raxogly', false, 0),
('credit_card', 'Kipu Masa Masa', false, 5000),
('credit_card', 'Popova Yana Andreevna', false, 25000),
('credit_card', 'Miksumov Anar Raxogly', false, 30000),
('debit_card', 'Saronova Olga Olegovna', false, 0);

--Скрипт №1 - Распределение заявок по продуктовым таблицам
DO $$ 
DECLARE 
    product TEXT;
    isCompany BOOLEAN;
    tableName TEXT;
BEGIN
    FOR product, isCompany IN (SELECT DISTINCT product_type, is_company FROM bid) LOOP
        IF isCompany THEN
            tableName := 'company_' || product;
        ELSE
            tableName := 'person_' || product;
        END IF;

        EXECUTE 'CREATE TABLE IF NOT EXISTS ' || tableName || ' (
            id SERIAL PRIMARY KEY,
            client_name VARCHAR(100),
            amount NUMERIC(12,2)
        )';

        EXECUTE 'INSERT INTO ' || tableName || ' (client_name, amount)
            SELECT client_name, amount FROM bid WHERE product_type = $1 AND is_company = $2'
        USING product, isCompany;
    END LOOP;
END $$;


DO $$ 
DECLARE 
    base_rate NUMERIC := 0.1;
    total_interest NUMERIC := 0;
BEGIN
    CREATE TABLE IF NOT EXISTS credit_percent (
        client_name VARCHAR(100),
        interest_amount NUMERIC(12,2)
    );

    INSERT INTO credit_percent (client_name, interest_amount)
    SELECT client_name, (amount * base_rate) / 365 FROM company_credit;

    INSERT INTO credit_percent (client_name, interest_amount)
    SELECT client_name, (amount * (base_rate + 0.05)) / 365 FROM person_credit;

    SELECT SUM(interest_amount) INTO total_interest FROM credit_percent;

    RAISE NOTICE 'Всего начислено: %', total_interest;
END $$;

CREATE OR REPLACE VIEW company_bids AS
SELECT * FROM bid WHERE is_company = true;
