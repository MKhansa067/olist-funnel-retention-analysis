## Data quality findings
- Date range: 2016-09-04 to 2018-10-17; excluded months: [TBD from Q4 monthly]
- order_status: delivered 97.02%, shipped 1.11%, canceled 0.63%, unavailable 0.61%, others <1%
- Illogical timestamps: 1,359 carrier-before-approved, 166 carrier-before-purchase, 23 delivered-before-carrier. Decision: keep orders in funnel; exclude negative
  durations from stage-time metrics only.
- Status vs timestamp mismatch: 8 delivered orders lack a delivery date; 6 canceled orders have one. Decision: funnel stages are based on timestamps, not status.
- customers: 99,441 customer_id vs 96,096 customer_unique_id -> retention uses customer_unique_id
- Repeat buyers: 2,997 of 96,096 customers (3.12%) have 2+ orders
- order_payments: 103,886 rows for 99,440 orders -> aggregate per order before joining
- order_reviews: [TBD] rows for [TBD] orders -> deduplicate before joining
- Categories: 2 without English translation -> COALESCE to Portuguese name
- Orders without items: 775 (603 unavailable, 164 canceled, 8 other) -> excluded from value/category analysis via INNER JOIN; kept in funnel.
- Repeat purchase: 2,888 customers have 2+ valid orders; of these, 869 placed the second order on the same day and 1,219 in the same month. Only 1,669 returned in a later month (this is what retention measures).
- Monthly volume: very low in 2016-09, 2016-10, 2016-12 (4, 324, 1) and 2018-09, 2018-10 (16, 4); 2016-11 has no orders. Decision: retention cohorts = 2017-01 to 2018-08 (20 cohorts); orders after 2018-08-31 excluded;
  month offset computed from calendar month index.
- Products: 610 of 32,951 (1.85%) have no category; 2 categories lack English translation
  -> COALESCE(english, portuguese, 'unknown').
- Funnel (timestamp-based, strict): purchased 99,441 -> approved 99,281 (99.84%) -> shipped 97,644 (98.19%)
  -> delivered 96,461 (97.00%). Total leakage 2,980 (3.00%).
- Largest leak: approved -> shipped, 1,637 orders (55% of all leakage): unavailable 609, canceled 409, invoiced 314, processing 301. 603 of 609 unavailable orders have no order_items (hypothesis: stock-outs).
- 1,183 orders shipped but not delivered: 1,107 have status 'shipped' [stale or in flight: TBD from Query D].
- Median days: purchase->approved 0.01, approved->carrier 1.85, carrier->delivered 7.1, purchase->delivered 10.22 (mean 12.56, max 209.6). Negative durations excluded: 1,359 (approved->carrier), 23 (carrier->delivered).
- order_reviews: 99,224 rows for 98,673 orders; 768 orders have no review. Rule: latest review_answer_timestamp per order; LEFT JOIN keeps unreviewed orders.