-- UP Migration: Применение изменений
BEGIN;

-- Изменение типов столбцов

-- Изменяем тип столбца price в таблице products с numeric(10,2) на numeric(12,2)
ALTER TABLE products
    ALTER COLUMN price TYPE numeric(12,2);

-- Изменяем тип столбца rating в таблице suppliers с numeric(3,2) на numeric(4,2)
ALTER TABLE suppliers
    ALTER COLUMN rating TYPE numeric(4,2);

-- Добавление столбцов

-- Добавляем столбец middle_name в таблицу customers
ALTER TABLE customers
    ADD COLUMN middle_name varchar(50);

-- Добавляем столбец shipping_address в таблицу orders
ALTER TABLE orders
    ADD COLUMN shipping_address text NOT NULL DEFAULT 'Not Provided';

-- Добавляем столбец weight в таблицу products
ALTER TABLE products
    ADD COLUMN weight numeric(10,2) NOT NULL DEFAULT 0.01;

-- 3. Добавление ограничений

-- Добавляем ограничение для формата номера телефона в таблице customers
ALTER TABLE customers
    ADD CONSTRAINT chk_phone_format CHECK (phone ~ '^\+?[0-9]{10,15}$');

-- Добавляем ограничение для положительного значения веса в таблице products
ALTER TABLE products
    ADD CONSTRAINT chk_weight_positive CHECK (weight > 0);

-- Добавляем ограничение для того, чтобы дата заказа не была в будущем в таблице orders
ALTER TABLE orders
    ADD CONSTRAINT chk_order_date CHECK (order_date <= current_date);

COMMIT;

-------------------------------------------------

-- DOWN Migration: Откат изменений
BEGIN;

-- Удаляем добавленные ограничения

ALTER TABLE orders
    DROP CONSTRAINT IF EXISTS chk_order_date;

ALTER TABLE products
    DROP CONSTRAINT IF EXISTS chk_weight_positive;

ALTER TABLE customers
    DROP CONSTRAINT IF EXISTS chk_phone_format;

-- Удаляем добавленные столбцы

ALTER TABLE orders
    DROP COLUMN IF EXISTS shipping_address;

ALTER TABLE products
    DROP COLUMN IF EXISTS weight;

ALTER TABLE customers
    DROP COLUMN IF EXISTS middle_name;

-- Возвращаем исходные типы столбцов

-- Возвращаем тип столбца price в таблице products к numeric(10,2)
ALTER TABLE products
    ALTER COLUMN price TYPE numeric(10,2);

-- Возвращаем тип столбца rating в таблице suppliers к numeric(3,2)
ALTER TABLE suppliers
    ALTER COLUMN rating TYPE numeric(3,2);

COMMIT;
