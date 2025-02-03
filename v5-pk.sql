-- Скрипт миграции

BEGIN;

-- Резервное копирование таблиц
CREATE TABLE IF NOT EXISTS customers_backup AS TABLE customers;
CREATE TABLE IF NOT EXISTS suppliers_backup AS TABLE suppliers;
CREATE TABLE IF NOT EXISTS categories_backup AS TABLE categories;
CREATE TABLE IF NOT EXISTS products_backup AS TABLE products;
CREATE TABLE IF NOT EXISTS orders_backup AS TABLE orders;
CREATE TABLE IF NOT EXISTS order_items_backup AS TABLE order_items;

-- Миграция таблицы customers
-- Используем email как доменный ключ

-- В таблице orders добавляем поле для связи с customers по email
ALTER TABLE orders ADD COLUMN customer_email varchar(100);

-- Переносим email покупателя в orders, сопоставляя по customer_id
UPDATE orders
SET customer_email = c.email
FROM customers c
WHERE orders.customer_id = c.customer_id;

-- Удаляем ограничение внешнего ключа
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_customer_id_fkey;

-- Удаляем старый столбец-ссылку customer_id из orders
ALTER TABLE orders DROP COLUMN customer_id;

-- В таблице customers удаляем суррогатный ключ
ALTER TABLE customers DROP CONSTRAINT IF EXISTS customers_pkey;
ALTER TABLE customers DROP COLUMN customer_id;

-- Назначаем email основным ключом в customers
ALTER TABLE customers ADD CONSTRAINT customers_pkey PRIMARY KEY (email);

-- Миграция таблицы suppliers
-- Используем name как доменный ключ

-- В products добавляем поле для хранения имени поставщика
ALTER TABLE products ADD COLUMN supplier_name varchar(100);

UPDATE products
SET supplier_name = s.name
FROM suppliers s
WHERE products.supplier_id = s.supplier_id;

-- Удаляем ограничение внешнего ключа на suppliers и сам столбец supplier_id в products
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_supplier_id_fkey;
ALTER TABLE products DROP COLUMN supplier_id;

-- В таблице suppliers удаляем суррогатный ключ
ALTER TABLE suppliers DROP CONSTRAINT IF EXISTS suppliers_pkey;
ALTER TABLE suppliers DROP COLUMN supplier_id;

-- Назначаем name основным ключом в suppliers
ALTER TABLE suppliers ADD CONSTRAINT suppliers_pkey PRIMARY KEY (name);

-- В products создаём новое ограничение, ссылающееся на suppliers по name
ALTER TABLE products ADD CONSTRAINT products_supplier_name_fkey FOREIGN KEY (supplier_name)
    REFERENCES suppliers(name);

-- Миграция таблицы categories
-- Используем category_name как доменный ключ

-- В products добавляем поле для хранения category_name
ALTER TABLE products ADD COLUMN category_name varchar(50);

UPDATE products
SET category_name = c.category_name
FROM categories c
WHERE products.category_id = c.category_id;

-- Удаляем ограничение внешнего ключа на categories и сам столбец category_id в products
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_id_fkey;
ALTER TABLE products DROP COLUMN category_id;

-- В таблице categories удаляем суррогатный ключ
ALTER TABLE categories DROP CONSTRAINT IF EXISTS categories_pkey;
ALTER TABLE categories DROP COLUMN category_id;

-- Назначаем category_name основным ключом в categories
ALTER TABLE categories ADD CONSTRAINT categories_pkey PRIMARY KEY (category_name);

-- В products создаём новое ограничение, ссылающееся на categories по category_name
ALTER TABLE products ADD CONSTRAINT products_category_name_fkey FOREIGN KEY (category_name)
    REFERENCES categories(category_name);

-- Миграция таблицы products
-- Используем product_name как доменный ключ

-- В order_items добавляем поле для хранения product_name
ALTER TABLE order_items ADD COLUMN product_name varchar(100);

UPDATE order_items
SET product_name = p.product_name
FROM products p
WHERE order_items.product_id = p.product_id;

-- Удаляем ограничение внешнего ключа на products в order_items и сам столбец product_id
ALTER TABLE order_items DROP CONSTRAINT IF EXISTS order_items_product_id_fkey;
ALTER TABLE order_items DROP COLUMN product_id;

-- В таблице products удаляем суррогатный ключ
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_pkey;
ALTER TABLE products DROP COLUMN product_id;

-- Назначаем product_name основным ключом в products
ALTER TABLE products ADD CONSTRAINT products_pkey PRIMARY KEY (product_name);

-- В order_items создаём ограничение внешнего ключа, ссылающееся на products по product_name
ALTER TABLE order_items ADD CONSTRAINT order_items_product_name_fkey FOREIGN KEY (product_name)
    REFERENCES products(product_name);

-- Миграция таблицы orders
-- Используем составной ключ (order_date, total_amount, is_paid, customer_email)
-- берем составной, потому что нет явного идентификатора в orders

-- Пока в таблице orders ещё есть столбец order_id (суррогатный ключ), используем его для обновления order_items
-- В order_items добавляем временные столбцы для доменного ключа заказа
ALTER TABLE order_items ADD COLUMN order_date date;
ALTER TABLE order_items ADD COLUMN total_amount numeric(10,2);
ALTER TABLE order_items ADD COLUMN is_paid boolean;
ALTER TABLE order_items ADD COLUMN customer_email varchar(100);

-- Обновляем данные в order_items, копируя значения из orders (используя пока ещё order_id)
UPDATE order_items oi
SET order_date = o.order_date,
    total_amount = o.total_amount,
    is_paid = o.is_paid,
    customer_email = o.customer_email
FROM orders o
WHERE oi.order_id = o.order_id;

-- Удаляем ограничение внешнего ключа в order_items по order_id и сам столбец order_id
ALTER TABLE order_items DROP CONSTRAINT IF EXISTS order_items_order_id_fkey;
ALTER TABLE order_items DROP COLUMN order_id;

-- В таблице orders удаляем суррогатный ключ
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_pkey;
ALTER TABLE orders DROP COLUMN order_id;

-- Назначаем составной ключ в orders
ALTER TABLE orders ADD CONSTRAINT orders_pkey PRIMARY KEY (order_date, total_amount, is_paid, customer_email);

-- В order_items создаём ограничение внешнего ключа, ссылающееся на orders по составному ключу
ALTER TABLE order_items ADD CONSTRAINT order_items_orders_fkey FOREIGN KEY (order_date, total_amount, is_paid, customer_email)
    REFERENCES orders(order_date, total_amount, is_paid, customer_email);

-- Миграция таблицы order_items
-- Используем составной ключ (order_date, total_amount, is_paid, customer_email, product_name, quantity, unit_price)
-- берем составной, потому что нет явного идентификатора в orders_items
ALTER TABLE order_items DROP CONSTRAINT IF EXISTS order_items_pkey;
ALTER TABLE order_items DROP COLUMN IF EXISTS order_item_id;

ALTER TABLE order_items ADD CONSTRAINT order_items_pkey PRIMARY KEY
    (order_date, total_amount, is_paid, customer_email, product_name, quantity, unit_price);

COMMIT;

-- Скрипт отката

BEGIN;

-- Удаляем преобразованные таблицы с новыми ключами
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS customers;

-- Восстанавливаем исходное состояние, переименовывая backup-таблицы в первоначальные имена
ALTER TABLE customers_backup RENAME TO customers;
ALTER TABLE suppliers_backup RENAME TO suppliers;
ALTER TABLE categories_backup RENAME TO categories;
ALTER TABLE products_backup RENAME TO products;
ALTER TABLE orders_backup RENAME TO orders;
ALTER TABLE order_items_backup RENAME TO order_items;

COMMIT;
