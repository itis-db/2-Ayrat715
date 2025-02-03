-- SELECT с использованием CTE

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*)    AS order_count,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    co.order_count,
    co.total_spent
FROM customers c
         JOIN customer_orders co ON c.customer_id = co.customer_id;

-- SELECT с использованием JOIN (соединение)
SELECT
    o.order_id,
    o.order_date,
    o.total_amount,
    o.is_paid,
    c.first_name AS customer_first_name,
    c.last_name  AS customer_last_name,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM orders o
         JOIN customers c       ON o.customer_id = c.customer_id
         JOIN order_items oi    ON o.order_id    = oi.order_id
         JOIN products p        ON oi.product_id = p.product_id;

-- SELECT с использованием UNION ALL (объединение)
SELECT
    phone AS contact_phone,
    'Customer' AS source
FROM customers
WHERE phone IS NOT NULL
UNION ALL
SELECT
    phone AS contact_phone,
    'Supplier' AS source
FROM suppliers
WHERE phone IS NOT NULL;
