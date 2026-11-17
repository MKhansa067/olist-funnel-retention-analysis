-- 03_retention_cohort.sql
-- Purpose : Monthly cohort retention by customer_unique_id.
-- Input   : orders, customers
-- Rules   : valid order = status not in (canceled, unavailable); cohort = first valid purchase month;
--           cohorts 2017-01..2018-08 only; orders after 2018-08-31 ignored;
--           month offset uses calendar month index (year*12 + month), so empty months are handled.

-- 0. View with the full cohort x month-offset grid (0 = cohort month)
CREATE VIEW IF NOT EXISTS v_cohort_retention AS
WITH RECURSIVE
valid AS (
  SELECT c.customer_unique_id AS cust,
         CAST(strftime('%Y', o.order_purchase_timestamp) AS INTEGER) * 12
       + CAST(strftime('%m', o.order_purchase_timestamp) AS INTEGER) AS m_idx
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
    AND o.order_purchase_timestamp < '2018-09-01'
),
activity AS (
  SELECT cust,
         m_idx,
         MIN(m_idx) OVER (PARTITION BY cust) AS cohort_idx
  FROM valid
),
cohorts AS (
  SELECT cohort_idx, COUNT(DISTINCT cust) AS cohort_size
  FROM activity
  WHERE m_idx = cohort_idx
    AND cohort_idx BETWEEN 2017 * 12 + 1 AND 2018 * 12 + 8
  GROUP BY cohort_idx
),
offsets(k) AS (
  SELECT 0
  UNION ALL
  SELECT k + 1 FROM offsets WHERE k < 19
),
cohort_activity AS (
  SELECT cohort_idx, m_idx - cohort_idx AS k, COUNT(DISTINCT cust) AS active
  FROM activity
  WHERE cohort_idx BETWEEN 2017 * 12 + 1 AND 2018 * 12 + 8
  GROUP BY cohort_idx, k
)
SELECT printf('%04d-%02d', (c.cohort_idx - 1) / 12, (c.cohort_idx - 1) % 12 + 1) AS cohort_month,
       c.cohort_size,
       o.k                                                   AS month_offset,
       COALESCE(a.active, 0)                                 AS active_customers,
       ROUND(100.0 * COALESCE(a.active, 0) / c.cohort_size, 2) AS retention_pct
FROM cohorts c
JOIN offsets o ON o.k <= (2018 * 12 + 8) - c.cohort_idx      -- only observable months
LEFT JOIN cohort_activity a ON a.cohort_idx = c.cohort_idx AND a.k = o.k;

-- A. Full cohort table (export for the heatmap)
SELECT * FROM v_cohort_retention
ORDER BY cohort_month, month_offset;

-- B. Pooled retention by month offset (all observable cohorts combined)
SELECT month_offset,
       SUM(cohort_size)       AS customers_observable,
       SUM(active_customers)  AS active_customers,
       ROUND(100.0 * SUM(active_customers) / SUM(cohort_size), 2) AS pooled_retention_pct
FROM v_cohort_retention
GROUP BY month_offset
ORDER BY month_offset;

-- C. Sanity check: these two numbers must be equal
SELECT SUM(cohort_size) AS from_view
FROM v_cohort_retention
WHERE month_offset = 0;

SELECT COUNT(*) AS independent_count
FROM (
  SELECT c.customer_unique_id
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
  GROUP BY c.customer_unique_id
  HAVING MIN(o.order_purchase_timestamp) >= '2017-01-01'
     AND MIN(o.order_purchase_timestamp) <  '2018-09-01'
);