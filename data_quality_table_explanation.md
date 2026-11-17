# 1 Data quality q1-q11
(tanda koma dan spasi adalah kolom yang terpisah, ditandai tanda titik koma untuk setiap kolom yang berbeda dalam satu tabel) temuan q1-q11:
1. q1: total_orders=99,441; null_purchase=0; null_approved=160; null_carrier=1,783; null_delivered=2,965; null_estimated=0.
2. q2: tbl= orders, customers; total_rows= 99,441, 99,441; distinct_keys= 99,441, 99,441.
3. q3: order_status= delivered, shipped, canceled, unavailable, invoiced, processing, created, approver; n= 96,478, 1,107, 625, 609, 314, 301, 5, 2; pct= 97,02, 1.11, 0.63, 0.61, 0.32, 0.3, 0.01, 0.
4. q4: first_order= 2016-09-04 21:15:19; last_order= 2018-10-17 17:30:18.
5. q5: approved_before_purchase= 0, carrier_before_approver= 1,359; carrier_before_purchase= 166; delivered_before_carrier= 23; delivered_before_purchase= 0.
6. q6: order_status= delivered, shipped, canceled, unavailable, invoiced, processing, created, approved; n= 96,478, 1,107, 625, 609, 314, 301, 5, 2; no_approved_date= 14, 0, 141, 0, 0, 0, 5, 0; no_carrier_date= 2, 0, 550, 609, 314, 301, 5, 2; no_delivery_date= 8, 1,107, 619, 609, 314, 301, 5, 2.
7. q7: rows_in_customers= 99,441; distinct_customer_id= 99,441; distinct_customer_unique_id= 96,096.
8. q8: n_orders= 1, 2, 3, 4, 5, 6, 7, 9, 17; customers= 93,099, 2,745, 203, 30, 8, 6, 3, 1, 1.
9. q9: items_without_order= 0.
10. q10: payment_rows= 103,886; orders_with_payment= 99,440.
11. q11: categories_without_translation= 2.

# 2 Data quality q14 and funnel A, B, C
q14: review_rows= 99,224; orders_reviewed= 98,673.
sqlite version= 3.53.2
funnel:

1. A: stage_no= 1, 2, 3, 4; stage= purchased, approved, shipped_to_carrier, delivered_to_customer; orders= 99,441, 99,281, 97,644, 96,461; pct_of_purchased= 100, 99.84, 98.19, 97; dropped_from_prev= NULL, 160, 1,637, 1,183; cinv_from_prev= NULL, 99.84, 98.35, 98.79.
2. B: last_stage_reached= 1_stopped_before_approval, 1_stopped_before_approval, 1_stopped_before_approval, 2_approved_not_shipped, 2_approved_not_shipped, 2_approved_not_shipped, 2_approved_not_shipped, 2_approved_not_shipped, 2_approved_not_shipped, 3_shipped_not_delivered, 3_shipped_not_delivered, 4_delivered, 4_delivered; order_status= canceled, delivered, created, unavailable, canceled, invoiced, processing, delivered, approved, shipped, canceled, delivered, delivered, canceled; n= 141, 14, 5, 609, 409, 314, 301, 2, 2, 1,107, 69, 7, 96,455, 6.
3. C: step= approved_to_carrier, carrier_to_delivered, purchase_to_approved, purchase_to_delivered; n_valid= 96,285, 96,452, 99,281, 96,476; median_days= 1.85, 7.1, 0.01, 10.22; mean_days= 2.86, 9.33, 0.43, 12.56; max_days= 125.8, 205.2, 187.9, 209.6.

# 3 Retention cohort
funnel D: order_status= shipped, invoiced, processing, created, approved; n= 1,107, 314, 301, 5, 2; earliest_purchase= 2016-09-04 21:15:19, 2016-10-04 13:02:10, 2016-10-05 22:44:13, 2017-11-06 13:12:34, 2017-02-06 20:18:17; latest_purchase= 2018-09-03 09:06:57, 2018-08-14 18:03:03, 2018-02-09 17:21:04, 2017-04-25 01:25:34; avg_age_days_at_snapshot= 316, 353, 416, 311, 579.

dua angka Q4 yang masih hilang:
q4: year_month= 2017-11, 2017-12; orders= 7,544, 5,673.

retention cohort:
0: 