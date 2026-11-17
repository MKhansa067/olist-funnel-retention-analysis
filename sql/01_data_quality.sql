-- 01_data_quality.sql
-- Purpose : Check data quality before funnel and retention analysis.
-- Input   : olist.db (loaded by scripts/load_data.py)
-- Output  : Query results only; findings are recorded in notes.md

-- Q1. Null counts on order timestamps
SELECT
  COUNT(*)                                    AS total_orders,
  SUM(order_purchase_timestamp      IS NULL)  AS null_purchase,
  SUM(order_approved_at             IS NULL)  AS null_approved,
  SUM(order_delivered_carrier_date  IS NULL)  AS null_carrier,
  SUM(order_delivered_customer_date IS NULL)  AS null_delivered,
  SUM(order_estimated_delivery_date IS NULL)  AS null_estimated
FROM orders;

-- Q2. Duplicate check on primary keys
SELECT 'orders' AS tbl, COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS distinct_keys
FROM orders
UNION ALL
SELECT 'customers', COUNT(*), COUNT(DISTINCT customer_id) FROM customers;

-- Q3. Order status distribution
SELECT
  order_status,
  COUNT(*) AS n,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY n DESC;

-- Q4. Purchase date range and monthly volume
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM orders;

SELECT strftime('%Y-%m', order_purchase_timestamp) AS year_month,
       COUNT(*) AS orders
FROM orders
GROUP BY year_month
ORDER BY year_month;

-- Q5. Illogical date sequences (each count should ideally be 0)
SELECT
  SUM(order_approved_at             < order_purchase_timestamp)     AS approved_before_purchase,
  SUM(order_delivered_carrier_date  < order_approved_at)            AS carrier_before_approved,
  SUM(order_delivered_carrier_date  < order_purchase_timestamp)     AS carrier_before_purchase,
  SUM(order_delivered_customer_date < order_delivered_carrier_date) AS delivered_before_carrier,
  SUM(order_delivered_customer_date < order_purchase_timestamp)     AS delivered_before_purchase
FROM orders;

-- Q6. Status vs missing delivery date (are statuses consistent with timestamps?)
SELECT
  order_status,
  COUNT(*)                                      AS n,
  SUM(order_approved_at             IS NULL)    AS no_approved_date,
  SUM(order_delivered_carrier_date  IS NULL)    AS no_carrier_date,
  SUM(order_delivered_customer_date IS NULL)    AS no_delivery_date
FROM orders
GROUP BY order_status
ORDER BY n DESC;

-- Q7. customer_id vs customer_unique_id
SELECT
  COUNT(*)                            AS rows_in_customers,
  COUNT(DISTINCT customer_id)         AS distinct_customer_id,
  COUNT(DISTINCT customer_unique_id)  AS distinct_customer_unique_id
FROM customers;

-- Q8. Orders per real person (distribution of repeat purchase)
WITH per_person AS (
  SELECT c.customer_unique_id,
         COUNT(DISTINCT o.order_id) AS n_orders
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
)
SELECT n_orders, COUNT(*) AS customers
FROM per_person
GROUP BY n_orders
ORDER BY n_orders;

-- Q9. Referential integrity: orders vs order_items
SELECT COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL;

SELECT COUNT(*) AS items_without_order
FROM order_items i
LEFT JOIN orders o ON i.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Q10. Reviews and payments: one row per order?
SELECT COUNT(*) AS review_rows,
       COUNT(DISTINCT order_id) AS orders_reviewed
FROM order_reviews;

SELECT COUNT(*) AS payment_rows,
       COUNT(DISTINCT order_id) AS orders_with_payment
FROM order_payments;

-- Q11. Product categories: nulls and missing translations
SELECT COUNT(*) AS total_products,
       SUM(product_category_name IS NULL) AS null_category
FROM products;

SELECT COUNT(DISTINCT p.product_category_name) AS categories_without_translation
FROM products p
LEFT JOIN category_translation t
  ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;
