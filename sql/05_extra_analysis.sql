-- 05_extra_analysis.sql
-- Purpose : Does late delivery hurt review score and 6-month repeat purchase?
-- Input   : v_order_base (see 04_segmentation.sql)

-- E1. On time vs late (delivered orders only)
WITH d AS (
  SELECT review_score,
         julianday(date(order_delivered_customer_date))
       - julianday(date(order_estimated_delivery_date)) AS days_vs_est
  FROM v_order_base
  WHERE order_delivered_customer_date IS NOT NULL
)
SELECT CASE WHEN days_vs_est <= 0 THEN 'on_time_or_early' ELSE 'late' END AS delivery_status,
       COUNT(*)                                                       AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)             AS pct_orders,
       COUNT(review_score)                                            AS reviewed,
       ROUND(AVG(review_score), 2)                                    AS avg_review,
       ROUND(100.0 * SUM(review_score <= 2) / COUNT(review_score), 2) AS pct_low_review
FROM d
GROUP BY delivery_status;

-- E2. By how many days late
WITH d AS (
  SELECT review_score,
         julianday(date(order_delivered_customer_date))
       - julianday(date(order_estimated_delivery_date)) AS days_vs_est
  FROM v_order_base
  WHERE order_delivered_customer_date IS NOT NULL
)
SELECT CASE WHEN days_vs_est <= 0 THEN '1_on_time_or_early'
            WHEN days_vs_est <= 3 THEN '2_late_1_3_days'
            WHEN days_vs_est <= 7 THEN '3_late_4_7_days'
            ELSE '4_late_8plus_days' END                               AS delivery_bucket,
       COUNT(*)                                                        AS orders,
       COUNT(review_score)                                             AS reviewed,
       ROUND(AVG(review_score), 2)                                     AS avg_review,
       ROUND(100.0 * SUM(review_score <= 2) / COUNT(review_score), 2)  AS pct_low_review
FROM d
GROUP BY delivery_bucket
ORDER BY delivery_bucket;

-- E3. 6-month repeat rate by delivery status of the customer's FIRST order
-- First orders in 2017-01..2018-02 only, so every customer has >= 6 months of follow-up (data ends 2018-08).
WITH ordered AS (
  SELECT customer_unique_id, order_id,
         order_purchase_timestamp, order_delivered_customer_date, order_estimated_delivery_date,
         CAST(strftime('%Y', order_purchase_timestamp) AS INTEGER) * 12
       + CAST(strftime('%m', order_purchase_timestamp) AS INTEGER) AS m_idx,
         ROW_NUMBER() OVER (PARTITION BY customer_unique_id
                            ORDER BY order_purchase_timestamp, order_id) AS rn
  FROM v_order_base
),
first_o AS (
  SELECT customer_unique_id, m_idx,
         CASE WHEN julianday(date(order_delivered_customer_date))
                 > julianday(date(order_estimated_delivery_date))
              THEN 'late' ELSE 'on_time_or_early' END AS delivery_status
  FROM ordered
  WHERE rn = 1
    AND order_purchase_timestamp >= '2017-01-01'
    AND order_purchase_timestamp <  '2018-03-01'
    AND order_delivered_customer_date IS NOT NULL
),
returned AS (
  SELECT DISTINCT f.customer_unique_id
  FROM first_o f
  JOIN ordered x
    ON x.customer_unique_id = f.customer_unique_id
   AND x.m_idx BETWEEN f.m_idx + 1 AND f.m_idx + 6
),
res AS (
  SELECT f.delivery_status, r.customer_unique_id AS ret
  FROM first_o f
  LEFT JOIN returned r ON r.customer_unique_id = f.customer_unique_id
)
SELECT delivery_status,
       COUNT(*)                                   AS customers,
       COUNT(ret)                                 AS returned_within_6m,
       ROUND(100.0 * COUNT(ret) / COUNT(*), 2)    AS repeat_rate_6m_pct
FROM res
GROUP BY delivery_status
UNION ALL
SELECT 'all',
       COUNT(*),
       COUNT(ret),
       ROUND(100.0 * COUNT(ret) / COUNT(*), 2)
FROM res;

-- E4. Is the low review rate in some categories explained by late delivery?
WITH d AS (
  SELECT category, review_score,
         CASE WHEN julianday(date(order_delivered_customer_date))
                 > julianday(date(order_estimated_delivery_date))
              THEN 1 ELSE 0 END AS is_late
  FROM v_order_base
  WHERE order_delivered_customer_date IS NOT NULL
)
SELECT category,
       COUNT(*)                                              AS delivered_orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2)             AS pct_late,
       ROUND(AVG(review_score), 2)                           AS avg_review,
       ROUND(AVG(CASE WHEN is_late = 0 THEN review_score END), 2) AS avg_review_on_time,
       ROUND(AVG(CASE WHEN is_late = 1 THEN review_score END), 2) AS avg_review_late
FROM d
GROUP BY category
HAVING COUNT(*) >= 1000
ORDER BY pct_late DESC
LIMIT 15;

-- E5. Late rate by state (top 10 states by delivered orders)
WITH d AS (
  SELECT customer_state, review_score,
         CASE WHEN julianday(date(order_delivered_customer_date))
                 > julianday(date(order_estimated_delivery_date))
              THEN 1 ELSE 0 END AS is_late
  FROM v_order_base
  WHERE order_delivered_customer_date IS NOT NULL
)
SELECT customer_state,
       COUNT(*)                                       AS delivered_orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 2)      AS pct_late,
       ROUND(AVG(review_score), 2)                    AS avg_review
FROM d
GROUP BY customer_state
ORDER BY delivered_orders DESC
LIMIT 10;