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
- Monthly volume: 2017-11 = 7,544 orders (+63% vs 2017-10); 2017-12 = 5,673. Peak likely Black Friday (hypothesis, unverified).
- Unfinished orders are stale, not in flight: average age at snapshot 311-579 days (shipped 316, invoiced 353, processing 416). They never reached 'delivered' in the data
  (cannot tell lost vs unrecorded).
- Retention (20 cohorts, 2017-01..2018-08, 94,697 customers): pooled retention month 1 = 0.48%, month 2 = 0.34%, month 3 = 0.26%, month 6 = 0.23%, month 12 = 0.18%. Flat, very low curve. Offsets >= 13 are sparse (<= 25 customers) -> excluded from heatmap.
- Month-1 retention dipped for 2017-12..2018-02 cohorts (0.22-0.36%) vs 2017-08..2017-10 (0.68-0.71%); differences are small in absolute numbers (tens of customers) -> observation, not conclusion.
- v_order_base: 98,206 valid orders, 94,990 customers (valid = not canceled/unavailable, purchased before 2018-09-01).
- Customers: 92,103 one-time vs 2,887 repeat (3.04%); repeat = 5.66% of value; value per repeat customer ~1.9x (~308 vs ~161); avg order value 145.86 vs 161.22; avg review 4.18 vs 4.11.
- Categories: no category above 9.14% of value; top 15 ~76%. office_furniture has 22.64% low reviews (avg 3.62); bed_bath_table 16.47%, furniture_decor 15.92%, computers_accessories 15.69%.
- States: SP 37.35% of value; top 10 states 87.29%. RJ (3.90) and BA (3.88) have the lowest avg review.
- Late delivery (delivered orders, date-level comparison vs estimate): 6.77% late (6,534 of 96,470). Avg review 2.27 late vs 4.29 on time; low reviews 62.42% vs 9.27%. Monotone by lateness: 1-3 days 3.29, 4-7 days 2.10, 8+ days 1.70. Late orders ~ one third of all low reviews (derived estimate).
- 6-month repeat rate (first orders 2017-01..2018-02, delivered): all 1.77% (976 / 55,227); late 1.47% (54 / 3,667) vs on time 1.79% (922 / 51,560); difference ~0.32 pp, 95% CI roughly -0.1 to +0.7 pp (self-computed) -> no clear evidence of an effect. Observational data; association only.