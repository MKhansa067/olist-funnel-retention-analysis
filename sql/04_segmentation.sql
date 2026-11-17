-- 04_segmentation.sql
-- Purpose : Segment customers, categories and states.
-- Input   : orders, customers, order_payments, order_reviews, order_items, products, category_translation
-- Rules   : valid orders only (not canceled/unavailable), purchase < 2018-09-01;
--           one review per order (latest answer); payments summed per order;
--           category = category of the highest-priced item in the order.

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