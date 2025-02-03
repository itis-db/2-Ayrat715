drop table if exists order_items;
drop table if exists orders;
drop table if exists products;
drop table if exists customers;
drop table if exists suppliers;
drop table if exists categories;

-- Таблица покупателей
create table if not exists customers
(
    customer_id       serial primary key,
    first_name        varchar(50)   not null,
    last_name         varchar(50)   not null,
    email             varchar(100)  not null unique,
    phone             varchar(20),
    registration_date date          default current_date
    );

-- Таблица поставщиков
create table if not exists suppliers
(
    supplier_id  serial primary key,
    name         varchar(100) not null,
    contact_email varchar(100),
    phone         varchar(20),
    rating        numeric(3,2) check (rating between 0 and 5) default 0.0
    );

-- Таблица категорий товаров
create table if not exists categories
(
    category_id   serial primary key,
    category_name varchar(50) not null unique,
    description   text
    );

-- Таблица товаров
create table if not exists products
(
    product_id    serial primary key,
    product_name  varchar(100) not null,
    description   text,
    price         numeric(10,2) not null check (price > 0),
    in_stock      integer       not null default 0,
    created_at    timestamp     default current_timestamp,
    supplier_id   integer       not null references suppliers(supplier_id),
    category_id   integer       not null references categories(category_id)
    );

-- Таблица заказов
create table if not exists orders
(
    order_id     serial primary key,
    order_date   date          not null default current_date,
    total_amount numeric(10,2) not null check (total_amount >= 0),
    is_paid      boolean       default false,
    customer_id  integer       not null references customers(customer_id)
    );

-- Таблица позиций заказа (связующая таблица заказов и товаров)
create table if not exists order_items
(
    order_item_id serial primary key,
    order_id      integer not null references orders(order_id),
    product_id    integer not null references products(product_id),
    quantity      integer not null check (quantity > 0),
    unit_price    numeric(10,2) not null check (unit_price > 0)
    );

-- Добавляем покупателей
insert into customers (first_name, last_name, email, phone)
values ('Ayrat', 'Fakhrutdinov', 'fakhrutdinov@gmail.com', '+79871234567'),
       ('Amir', 'Kurmaev', 'kurmaev@gmail.com', '+79877654321');

-- Добавляем поставщиков
insert into suppliers (name, contact_email, phone, rating)
values ('Exist distributor', 'exist@example.com', '+78433334455', 3.5),
       ('Automir distributor', 'automir@example.com', '+78433334456', 4.0);

-- Добавляем категории товаров
insert into categories (category_name, description)
values ('Batteries', 'Batteries for automobiles'),
       ('Accessories', 'Various genres of books');

-- Добавляем товары (supplier_id и category_id ссылаются на ранее вставленные записи)
insert into products (product_name, description, price, in_stock, supplier_id, category_id)
values ('VARTA battery', 'Battery form Europe', 9999.99, 20, 1, 1),
       ('Chip varnish', 'Varnish for removing chips', 299.99, 500, 2, 2),
       ('EUROSTAR battery', 'Battery from Asia', 3999.99, 100, 2, 1);

-- Добавляем заказы (ссылка на покупателя)
insert into orders (order_date, total_amount, is_paid, customer_id)
values ('2025-01-25', 13299.98, true, 1),
       ('2025-01-26', 299.99, false, 2);

-- Добавляем позиции заказа (связь с заказом и товаром)
insert into order_items (order_id, product_id, quantity, unit_price)
values (1, 1, 1, 9999.99), -- 1 аккумулятор VARTA для заказа 1
       (1, 3, 1, 3999.99),  -- 1 аккумулятор EUROSTAR для заказа 1
       (2, 2, 1, 299.99); -- 1 лак для заказа 2
