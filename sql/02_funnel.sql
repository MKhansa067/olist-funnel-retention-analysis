-- 02_funnel.sql
-- Purpose : Order fulfilment funnel, leakage by final status, and stage durations.
-- Input   : orders
-- Rules   : Stages are defined by timestamps (not by order_status) and are strictly sequential.

-- A. Strict funnel: purchased -> approved -> shipped -> delivered
WITH base AS (
  SELECT order_id,
         order_purchase_timestamp      AS t_purchase,
         order_approved_at             AS t_approved,
         order_delivered_carrier_date  AS t_carrier,
         order_delivered_customer_date AS t_delivered
  FROM orders
),
flags AS (
  SELECT 1 AS s1,
         CASE WHEN t_approved IS NOT NULL THEN 1 ELSE 0 END AS s2,
         CASE WHEN t_approved IS NOT NULL AND t_carrier IS NOT NULL
              THEN 1 ELSE 0 END AS s3,
         CASE WHEN t_approved IS NOT NULL AND t_carrier IS NOT NULL
               AND t_delivered IS NOT NULL THEN 1 ELSE 0 END AS s4
  FROM base
),
stages AS (
  SELECT 1 AS stage_no, 'purchased' AS stage, SUM(s1) AS orders FROM flags
  UNION ALL SELECT 2, 'approved',              SUM(s2) FROM flags
  UNION ALL SELECT 3, 'shipped_to_carrier',    SUM(s3) FROM flags
  UNION ALL SELECT 4, 'delivered_to_customer', SUM(s4) FROM flags
)
SELECT stage_no,
       stage,
       orders,
       ROUND(100.0 * orders / FIRST_VALUE(orders) OVER (ORDER BY stage_no), 2) AS pct_of_purchased,
       LAG(orders) OVER (ORDER BY stage_no) - orders                           AS dropped_from_prev,
       ROUND(100.0 * orders / LAG(orders) OVER (ORDER BY stage_no), 2)         AS conv_from_prev
FROM stages
ORDER BY stage_no;

-- B. Where do orders stop? Last stage reached x final status
SELECT CASE
         WHEN order_approved_at IS NULL             THEN '1_stopped_before_approval'
         WHEN order_delivered_carrier_date IS NULL  THEN '2_approved_not_shipped'
         WHEN order_delivered_customer_date IS NULL THEN '3_shipped_not_delivered'
         ELSE '4_delivered'
       END AS last_stage_reached,
       order_status,
       COUNT(*) AS n
FROM orders
GROUP BY last_stage_reached, order_status
ORDER BY last_stage_reached, n DESC;

-- C. Stage durations in days (negative durations from illogical timestamps are excluded)
WITH d AS (
  SELECT 'purchase_to_approved' AS step,
         julianday(order_approved_at) - julianday(order_purchase_timestamp) AS days
  FROM orders WHERE order_approved_at IS NOT NULL
  UNION ALL
  SELECT 'approved_to_carrier',
         julianday(order_delivered_carrier_date) - julianday(order_approved_at)
  FROM orders
  WHERE order_delivered_carrier_date IS NOT NULL AND order_approved_at IS NOT NULL
  UNION ALL
  SELECT 'carrier_to_delivered',
         julianday(order_delivered_customer_date) - julianday(order_delivered_carrier_date)
  FROM orders
  WHERE order_delivered_customer_date IS NOT NULL AND order_delivered_carrier_date IS NOT NULL
  UNION ALL
  SELECT 'purchase_to_delivered',
         julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)
  FROM orders WHERE order_delivered_customer_date IS NOT NULL
),
valid AS (
  SELECT step, days FROM d WHERE days >= 0
),
ranked AS (
  SELECT step, days,
         ROW_NUMBER() OVER (PARTITION BY step ORDER BY days) AS rn,
         COUNT(*)     OVER (PARTITION BY step)               AS cnt
  FROM valid
)
SELECT step,
       MAX(cnt)                                                          AS n_valid,
       ROUND(AVG(CASE WHEN rn IN ((cnt + 1) / 2, (cnt + 2) / 2) THEN days END), 2) AS median_days,
       ROUND(AVG(days), 2)                                               AS mean_days,
       ROUND(MAX(days), 1)                                               AS max_days
FROM ranked
GROUP BY step
ORDER BY step;