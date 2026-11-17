# Iterasi
## 1 Data quality q1-q11
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

## 2 Data quality q14 and funnel A, B, C
q14: review_rows= 99,224; orders_reviewed= 98,673.
sqlite version= 3.53.2
funnel:

1. A: stage_no= 1, 2, 3, 4; stage= purchased, approved, shipped_to_carrier, delivered_to_customer; orders= 99,441, 99,281, 97,644, 96,461; pct_of_purchased= 100, 99.84, 98.19, 97; dropped_from_prev= NULL, 160, 1,637, 1,183; cinv_from_prev= NULL, 99.84, 98.35, 98.79.
2. B: last_stage_reached= 1_stopped_before_approval, 1_stopped_before_approval, 1_stopped_before_approval, 2_approved_not_shipped, 2_approved_not_shipped, 2_approved_not_shipped, 2_approved_not_shipped, 2_approved_not_shipped, 2_approved_not_shipped, 3_shipped_not_delivered, 3_shipped_not_delivered, 4_delivered, 4_delivered; order_status= canceled, delivered, created, unavailable, canceled, invoiced, processing, delivered, approved, shipped, canceled, delivered, delivered, canceled; n= 141, 14, 5, 609, 409, 314, 301, 2, 2, 1,107, 69, 7, 96,455, 6.
3. C: step= approved_to_carrier, carrier_to_delivered, purchase_to_approved, purchase_to_delivered; n_valid= 96,285, 96,452, 99,281, 96,476; median_days= 1.85, 7.1, 0.01, 10.22; mean_days= 2.86, 9.33, 0.43, 12.56; max_days= 125.8, 205.2, 187.9, 209.6.

## 3 Retention cohort
uh oh aku belum refresh, itu masalah utamanya sehingga views tidak terupdate. Lanjut.

```markdown
funnel D: order_status= shipped, invoiced, processing, created, approved; n= 1,107, 314, 301, 5, 2; earliest_purchase= 2016-09-04 21:15:19, 2016-10-04 13:02:10, 2016-10-05 22:44:13, 2017-11-06 13:12:34, 2017-02-06 20:18:17; latest_purchase= 2018-09-03 09:06:57, 2018-08-14 18:03:03, 2018-02-09 17:21:04, 2017-04-25 01:25:34; avg_age_days_at_snapshot= 316, 353, 416, 311, 579.

dua angka Q4 yang masih hilang:
q4: year_month= 2017-11, 2017-12; orders= 7,544, 5,673.

retention cohort:
0: views v_cohort_retention sudah dibuat
A: full cohort tabel(data_explain/7-A_full_cohort_table.txt)
B: pooled retention(data_explain/7-B_pooled_retention.txt)
C: sanity check(data_explain/7-C_sanity_check):
|independent_count|
|-----------------|
|94,697           |

```

## 4
v_order_base sanity check: n_rows= 98,206; n_orders= 98,206; n_customers= 94,990.
A:
|segment     |customers|orders|total_value|pct_of_value|avg_order_value|avg_review|
|------------|---------|------|-----------|------------|---------------|----------|
|one_time    |92,103   |92,103|14,848,769 |94.34       |161.22         |4.11      |
|repeat_2plus|2,887    |6,103 |890,201    |5.66        |145.86         |4.18      |
B:

```
|category             |orders|total_value|pct_of_value|avg_order_value|avg_review|pct_low_review|
|---------------------|------|-----------|------------|---------------|----------|--------------|
|health_beauty        |8,766 |1,438,426  |9.14        |164.11         |4.19      |12.37         |
|watches_gifts        |5,587 |1,299,702  |8.26        |232.63         |4.08      |14.91         |
|bed_bath_table       |9,310 |1,242,110  |7.89        |133.42         |3.98      |16.47         |
|sports_leisure       |7,636 |1,146,781  |7.29        |150.18         |4.19      |12.39         |
|computers_accessories|6,635 |1,050,881  |6.68        |158.38         |4.04      |15.69         |
|furniture_decor      |6,306 |896,655    |5.7         |142.19         |4.04      |15.92         |
|housewares           |5,784 |771,622    |4.9         |133.41         |4.17      |12.52         |
|cool_stuff           |3,587 |704,631    |4.48        |196.44         |4.19      |11.86         |
|auto                 |3,855 |678,979    |4.31        |176.13         |4.11      |13.9          |
|garden_tools         |3,456 |575,888    |3.66        |166.63         |4.16      |12.69         |
|toys                 |3,839 |558,004    |3.55        |145.35         |4.21      |12.11         |
|baby                 |2,820 |479,426    |3.05        |170.01         |4.07      |15.13         |
|perfumery            |3,129 |449,715    |2.86        |143.72         |4.22      |12.83         |
|telephony            |4,163 |392,799    |2.5         |94.35          |4.02      |15.07         |
|office_furniture     |1,269 |343,150    |2.18        |270.41         |3.62      |22.64         |
```
C:
|customer_state|customers|orders|total_value|pct_of_value|avg_order_value|avg_review|avg_delivery_days|
|--------------|---------|------|-----------|------------|---------------|----------|-----------------|
|SP            |39,749   |41,126|5,878,770  |37.35       |142.95         |4.21      |8.8              |
|RJ            |12,242   |12,698|2,115,994  |13.44       |166.64         |3.9       |15.3             |
|MG            |11,134   |11,496|1,843,460  |11.71       |160.36         |4.16      |12               |
|RS            |5,234    |5,417 |877,804    |5.58        |162.05         |4.15      |15.3             |
|PR            |4,825    |4,983 |794,653    |5.05        |159.47         |4.21      |12               |
|SC            |3,502    |3,600 |608,181    |3.86        |168.94         |4.1       |15               |
|BA            |3,244    |3,344 |607,041    |3.86        |181.53         |3.88      |19.3             |
|DF            |2,058    |2,121 |351,488    |2.23        |165.72         |4.09      |13               |
|GO            |1,934    |1,998 |340,626    |2.16        |170.48         |4.07      |15.6             |
|ES            |1,950    |2,018 |323,106    |2.05        |160.11         |4.05      |15.8             |
E1:
|delivery_status |orders|pct_orders|reviewed|avg_review|pct_low_review|
|----------------|------|----------|--------|----------|--------------|
|late            |6,534 |6.77      |6,381   |2.27      |62.42         |
|on_time_or_early|89,936|93.23     |89,443  |4.29      |9.27          |
E2:
|delivery_bucket   |orders|reviewed|avg_review|pct_low_review|
|------------------|------|--------|----------|--------------|
|1_on_time_or_early|89,936|89,443  |4.29      |9.27          |
|2_late_1_3_days   |1,870 |1,852   |3.29      |32.13         |
|3_late_4_7_days   |1,802 |1,748   |2.1       |67.68         |
|4_late_8plus_days |2,862 |2,781   |1.7       |79.29         |
E3:
|delivery_status |customers|returned_within_6m|repeat_rate_6m_pct|
|----------------|---------|------------------|------------------|
|late            |3,667    |54                |1.47              |
|on_time_or_early|51,560   |922               |1.79              |
|all             |55,227   |976               |1.77              |
E4:
|category        |delivered_orders|pct_late|avg_review|avg_review_on_time|avg_review_late|
|----------------|----------------|--------|----------|------------------|---------------|
|baby            |2,761           |8.11    |4.12      |4.3               |2.07           |
|office_furniture|1,251           |8.07    |3.65      |3.76              |2.35           |
|electronics     |2,502           |7.67    |4.13      |4.27              |2.39           |
|health_beauty   |8,613           |7.54    |4.23      |4.38              |2.34           |
|bed_bath_table  |9,184           |7.48    |4.01      |4.15              |2.23           |
|watches_gifts   |5,476           |7.41    |4.12      |4.27              |2.2            |
|auto            |3,792           |7.33    |4.15      |4.3               |2.31           |
|furniture_decor |6,188           |7.24    |4.08      |4.21              |2.33           |
|unknown         |1,358           |7.14    |4.04      |4.19              |2.11           |
|telephony       |4,073           |7.14    |4.06      |4.18              |2.43           |
|garden_tools    |3,400           |6.62    |4.2       |4.33              |2.33           |
|stationery      |2,244           |6.6     |4.31      |4.45              |2.32           |
|sports_leisure  |7,492           |6.59    |4.23      |4.38              |2.17           |
|perfumery       |3,069           |6.58    |4.27      |4.41              |2.29           |
|toys            |3,787           |6.42    |4.24      |4.38              |2.13           |
E5:
|customer_state|delivered_orders|pct_late|avg_review|
|--------------|----------------|--------|----------|
|SP            |40,494          |4.49    |4.25      |
|RJ            |12,350          |12.11   |3.97      |
|MG            |11,354          |4.57    |4.19      |
|RS            |5,344           |6.08    |4.18      |
|PR            |4,923           |4.04    |4.24      |
|SC            |3,546           |8.21    |4.13      |
|BA            |3,256           |12.16   |3.93      |
|DF            |2,080           |5.67    |4.13      |
|ES            |1,995           |10.73   |4.08      |
|GO            |1,957           |6.54    |4.11      |
Konfirmasi skrip:
sudah execute dan menghasilkan file: chart_category_low_review.png, chart_funnel.png, chart_late_vs_review.png, chart_retention_heatmap.png, chart_retention_pooled.png. 
Deskripsi gambar:
1. chart_category_low_review: Low-review share, top 15 categories by order value: office_furniture=22.6%; bed_bath_table=16.5%; furniture_decor=15.9%; computers_accessories=15.7%; baby=15.1%; telephony=15.1%; watches_gifts=14.9%; auto=13.9%; perfumery=12.8%; garden_tools=12.7%; housewares=12.5%; sports_leisure=12.4%; health_beauty=12.4%; toys=12.1%; cool_stuff=11.9%.
2. chart_funnel: Order fulfilment funnel: 97.0% of orders reach the customer: purchased=99,441(100.00%); approved=99,281(99.84%); shipped to carrier=97,644(98.19%); delivered to customer=96,461(97.00%).
3. chart_late_vs_review:
- average review score: on time ot early=4.29 average review score; late 1-3 days=3.29 average review score; late 4-7 days=2.10 average review score; late 8+ days=1.70 average review score.
- share of low reviews: on time or early=9.3% orders with 1-2 star review(%); late 1-3 days=32.1% orders with 1-2 star review(%); late 4-7 days=67.7% orders with 1-2 star review(%); late 8+ days=79.3% orders with 1-2 star review(%).
4. chart_retention_heatmap: monthly_cohort_retention_heatmap.txt
5. chart_retention_pooled: pooled_retention_chart.txt