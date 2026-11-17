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