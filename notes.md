## Data quality findings
- Date range: 2016-09-04 to 2018-10-17; excluded months: [TBD from Q4 monthly]
- order_status: delivered 97.02%, shipped 1.11%, canceled 0.63%, unavailable 0.61%, others <1%
- Illogical timestamps: 1,359 carrier-before-approved, 166 carrier-before-purchase,
  23 delivered-before-carrier. Decision: keep orders in funnel; exclude negative
  durations from stage-time metrics only.
- Status vs timestamp mismatch: 8 delivered orders lack a delivery date; 6 canceled orders have one.
  Decision: funnel stages are based on timestamps, not status.
- customers: 99,441 customer_id vs 96,096 customer_unique_id -> retention uses customer_unique_id
- Repeat buyers: 2,997 of 96,096 customers (3.12%) have 2+ orders
- order_payments: 103,886 rows for 99,440 orders -> aggregate per order before joining
- order_reviews: [TBD] rows for [TBD] orders -> deduplicate before joining
- Categories: 2 without English translation -> COALESCE to Portuguese name