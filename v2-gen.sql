-- Генерация данных для справочников: категории и поставщики (categories и suppliers)
-- Вставляем 5 категорий
INSERT INTO categories (category_name, description)
SELECT
    'Category ' || gs,
    'Description for category ' || gs
FROM generate_series(1, 5) AS gs;

-- Вставляем 10 поставщиков
INSERT INTO suppliers (name, contact_email, phone, rating)
SELECT
    'Supplier ' || gs,
    'supplier' || gs || '@example.com',
    '+7' || LPAD(floor(random()*10000000000)::text, 10, '0'),
    round((random()::numeric * 5), 2)
FROM generate_series(1, 10) AS gs;

-- Генерация данных для таблицы покупателей (customers)
-- Вставляем 100 покупателей
INSERT INTO customers (first_name, last_name, email, phone, registration_date)
SELECT
    'FirstName' || gs,
    'LastName'  || gs,
    'customer'  || gs || '@example.com',
    '+7' || LPAD(floor(random()*10000000000)::text, 10, '0'),
    current_date - (floor(random()*1000)::int)
FROM generate_series(1, 100) AS gs;

-- Генерация данных для таблицы товаров (products)
-- Вставляем 50 товаров, поля supplier_id и category_id выбираются так, чтобы ссылки были корректными
INSERT INTO products (product_name, description, price, in_stock, created_at, supplier_id, category_id)
SELECT
    'Product ' || gs,
    'Description for product ' || gs,
    round((random()::numeric * 10000) + 1, 2),                        -- price > 0
    (floor(random()*100))::int,                                          -- in_stock от 0 до 99
    now() - (floor(random()*100)::int || ' days')::interval,             -- created_at в последние 100 дней
    floor(random()*10 + 1)::int,                                         -- supplier_id от 1 до 10
    floor(random()*5 + 1)::int                                           -- category_id от 1 до 5
FROM generate_series(1, 50) AS gs;

-- Генерация данных для таблицы заказов (orders)
-- Вставляем 200 заказов, поле customer_id выбирается от 1 до 100
INSERT INTO orders (order_date, total_amount, is_paid, customer_id)
SELECT
            current_date - (floor(random()*100)::int) as order_date, -- order_date последние 100 дней
            round((random()::numeric * 10000) + 1, 2) as total_amount,
            (random() > 0.5) as is_paid,
            floor(random()*100 + 1)::int as customer_id
FROM generate_series(1, 200) AS gs;

-- Генерация данных для таблицы позиций заказов (order_items)
-- Для каждого заказа генерируем от 1 до 3 позиций
-- Для поля product_id выбирается число от 1 до 50, quantity — от 1 до 5, а unit_price — случайное значение > 0
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    o.order_id,
    floor(random()*50 + 1)::int as product_id,
    floor(random()*5 + 1)::int as quantity,
    round((random()::numeric * 500) + 1, 2) as unit_price
FROM orders o
         CROSS JOIN LATERAL generate_series(1, floor(random()*3 + 1)::int) AS gs;
