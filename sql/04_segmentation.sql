-- 04_segmentation.sql
-- Purpose : Segment customers, categories and states.
-- Input   : orders, customers, order_payments, order_reviews, order_items, products, category_translation
-- Rules   : valid orders only (not canceled/unavailable), purchase < 2018-09-01;
--           one review per order (latest answer); payments summed per order;
--           category = category of the highest-priced item in the order.

-- 0 . View with one row per order, including customer, state, order value, review score and category
CREATE VIEW IF NOT EXISTS v_order_base AS
WITH pay AS (
  SELECT order_id, SUM(payment_value) AS order_value
  FROM order_payments
  GROUP BY order_id
),
rev AS (
  SELECT order_id, review_score
  FROM (
    SELECT order_id, review_score,
           ROW_NUMBER() OVER (PARTITION BY order_id
                              ORDER BY review_answer_timestamp DESC, review_id DESC) AS rn
    FROM order_reviews
  )
  WHERE rn = 1
),
prim AS (
  SELECT order_id, product_id
  FROM (
    SELECT order_id, product_id,
           ROW_NUMBER() OVER (PARTITION BY order_id
                              ORDER BY price DESC, order_item_id) AS rn
    FROM order_items
  )
  WHERE rn = 1
)
SELECT o.order_id,
       c.customer_unique_id,
       c.customer_state,
       o.order_status,
       o.order_purchase_timestamp,
       o.order_delivered_customer_date,
       o.order_estimated_delivery_date,
       p.order_value,
       r.review_score,
       COALESCE(t.product_category_name_english,
                pr.product_category_name,
                CASE WHEN pm.product_id IS NULL THEN 'no_items' ELSE 'unknown' END) AS category
FROM orders o
JOIN customers c        ON c.customer_id = o.customer_id
LEFT JOIN pay p         ON p.order_id = o.order_id
LEFT JOIN rev r         ON r.order_id = o.order_id
LEFT JOIN prim pm       ON pm.order_id = o.order_id
LEFT JOIN products pr   ON pr.product_id = pm.product_id
LEFT JOIN category_translation t ON t.product_category_name = pr.product_category_name
WHERE o.order_status NOT IN ('canceled', 'unavailable')
  AND o.order_purchase_timestamp < '2018-09-01';

-- Sanity check
SELECT COUNT(*) AS n_rows,
       COUNT(DISTINCT order_id) AS n_orders,
       COUNT(DISTINCT customer_unique_id) AS n_customers
FROM v_order_base;

-- A. One-time vs repeat customers
WITH cust AS (
  SELECT customer_unique_id, COUNT(*) AS n_orders
  FROM v_order_base
  GROUP BY customer_unique_id
)
SELECT CASE WHEN c.n_orders = 1 THEN 'one_time' ELSE 'repeat_2plus' END AS segment,
       COUNT(DISTINCT b.customer_unique_id)                              AS customers,
       COUNT(*)                                                          AS orders,
       ROUND(SUM(b.order_value), 0)                                      AS total_value,
       ROUND(100.0 * SUM(b.order_value) / SUM(SUM(b.order_value)) OVER (), 2) AS pct_of_value,
       ROUND(AVG(b.order_value), 2)                                      AS avg_order_value,
       ROUND(AVG(b.review_score), 2)                                     AS avg_review
FROM v_order_base b
JOIN cust c USING (customer_unique_id)
GROUP BY segment;

-- B. Top 15 categories by value (category of the highest-priced item per order)
SELECT category,
       COUNT(*)                                                           AS orders,
       ROUND(SUM(order_value), 0)                                         AS total_value,
       ROUND(100.0 * SUM(order_value) / SUM(SUM(order_value)) OVER (), 2) AS pct_of_value,
       ROUND(AVG(order_value), 2)                                         AS avg_order_value,
       ROUND(AVG(review_score), 2)                                        AS avg_review,
       ROUND(100.0 * SUM(review_score <= 2) / COUNT(review_score), 2)     AS pct_low_review
FROM v_order_base
GROUP BY category
ORDER BY total_value DESC
LIMIT 15;

-- C. Top 10 states by value
SELECT customer_state,
       COUNT(DISTINCT customer_unique_id)                                 AS customers,
       COUNT(*)                                                           AS orders,
       ROUND(SUM(order_value), 0)                                         AS total_value,
       ROUND(100.0 * SUM(order_value) / SUM(SUM(order_value)) OVER (), 2) AS pct_of_value,
       ROUND(AVG(order_value), 2)                                         AS avg_order_value,
       ROUND(AVG(review_score), 2)                                        AS avg_review,
       ROUND(AVG(julianday(order_delivered_customer_date)
               - julianday(order_purchase_timestamp)), 1)                 AS avg_delivery_days
FROM v_order_base
GROUP BY customer_state
ORDER BY total_value DESC
LIMIT 10;