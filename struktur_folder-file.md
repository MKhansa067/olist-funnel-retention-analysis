# Struktur Folder & File — `olist-funnel-retention`

Proyek analisis data e-commerce Olist (Brasil) yang mencakup: pemuatan data CSV ke SQLite, pemeriksaan kualitas data, analisis funnel pemenuhan pesanan, retensi kohort pelanggan, segmentasi, dan analisis tambahan (dampak keterlambatan pengiriman). Documentation ini dibuat dengan membaca seluruh struktur folder/file di root proyek (folder internal `.git` tidak didokumentasikan).

> Root: `D:\My-Career\Portfolio\DANA\olist-funnel-retention`
> Dibuat: 2026-11-17

---

## 1. Pohon Struktur (Ringkas)

```
olist-funnel-retention/
├── .gitignore
├── README.md                         (kosong)
├── requirements.txt
├── notes.md
├── olist-db_column_context.md
├── table_explanation.md
├── brazilian_e-commerce_public_dataset.zip
├── olist.db
├── assets/                           (35 file PNG)
│   ├── 1-load_data-py.png
│   ├── 2-load_dbeaver.png
│   ├── 3-sql_verification.png
│   ├── 4-data_peek.png
│   ├── 5-data_quality_q*.png         (17 screenshot)
│   ├── 6-funnel_A..D.png             (4 grafik)
│   ├── 7-retention_cohort_0,A,B,C.png(4 grafik)
│   ├── 8-segmentation_*.png          (5 grafik)
│   └── 9-extra_analysis_E1..E5.png   (5 grafik)
├── data/                             (9 file CSV sumber)
│   ├── olist_customers_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   └── product_category_name_translation.csv
├── data_explain/                     (10 file TXT)
│   ├── 7-A_full_cohort_table.txt
│   ├── 7-B_pooled_retention.txt
│   ├── 7-C_sanity_check.txt
│   ├── 8-A_one-time_vs_repeat_customers.txt
│   ├── 8-B_top_15_categories_by_value_category_of_the_highest_priced.txt
│   ├── 8-C_top_10_states_by_value.txt
│   └── 9-E1..E5_*.txt
├── output/                           (5 subfolder, 29 file CSV hasil query)
│   ├── 01_data_quality/              (14 CSV: _Q1.._Q14)
│   ├── 02_funnel/                    (4 CSV: _A.._D)
│   ├── 03_retention_cohort/          (3 CSV: _A.._C)
│   ├── 04_segmentation/              (3 CSV: _A.._C)
│   └── 05_extra_analysis/            (5 CSV: _E1.._E5)
├── scripts/                          (2 file Python)
│   ├── load_data.py
│   └── make_charts.py
└── sql/                              (6 file SQL)
    ├── 00_schema_and_load.sql
    ├── 01_data_quality.sql
    ├── 02_funnel.sql
    ├── 03_retention_cohort.sql
    ├── 04_segmentation.sql
    └── 05_extra_analysis.sql
```

---

## 2. File di Root

| File | Ukuran | Deskripsi |
|---|---|---|
| `.gitignore` | 51 B | Mengabaikan `data/*.csv`, `*.db`, `__pycache__/`, `.ipynb_checkpoints/` |
| `README.md` | 0 B | File kosong (belum diisi) |
| `requirements.txt` | 17 B | Dependensi Python: `pandas`, `matplotlib` |
| `notes.md` | 4,6 KB | Catatan temuan data quality + ringkasan semua hasil analisis (funnel, retention, segmentasi, late delivery) |
| `olist-db_column_context.md` | 1,5 KB | Konteks 9 tabel & tipe kolom database Olist |
| `table_explanation.md` | 10 KB | Catatan iterasi (q1–q14, funnel, cohort, segmentasi) beserta angka hasil |
| `brazilian_e-commerce_public_dataset.zip` | 44,7 MB | Arsip dataset publik e-commerce Brasil (sumber data) |
| `olist.db` | 152 MB | Database SQLite hasil load dari CSV (diabaikan git) |

---

## 3. Folder `assets/` — Dokumentasi Visual (35 PNG)

| File | Deskripsi |
|---|---|
| `1-load_data-py.png` | Screenshot proses load data via `load_data.py` |
| `2-load_dbeaver.png` | Screenshot verifikasi database di DBeaver |
| `3-sql_verification.png` | Screenshot verifikasi query SQL |
| `4-data_peek.png` | Screenshot tampilan awal data |
| `5-data_quality_q1.png` … `5-data_quality_q14.png` | Screenshot hasil tiap query data quality Q1–Q14 (termasuk `q14(2)`, dan `q4(1-first and last order)`, `q4(2-year month and orders)`, `q4(3-two lost data)`) |
| `6-funnel_A.png`, `6-funnel_B.png`, `6-funnel_C.png`, `6-funnel_D.png` | Grafik funnel strict, titik kebocoran, durasi tahap, dan status order yang belum selesai |
| `7-retention_cohort_0.png`, `7-retention_cohort_A.png`, `7-retention_cohort_B.png`, `7-retention_cohort_C.png` | Grafik retensi kohort (heatmap, pooled retention, sanity check) |
| `8-segmentation(sanity check).png`, `8-segmentation_0.png`, `8-segmentation_A.png`, `8-segmentation_B.png`, `8-segmentation_C.png` | Grafik segmentasi pelanggan, kategori, dan negara bagian |
| `9-extra_analysis_E1.png` … `9-extra_analysis_E5.png` | Grafik analisis tambahan: on-time vs late, hari keterlambatan, repeat rate, review, late rate per state |

Daftar lengkap nama file di folder ini:

```
1-load_data-py.png
2-load_dbeaver.png
3-sql_verification.png
4-data_peek.png
5-data_quality_q1.png
5-data_quality_q10.png
5-data_quality_q11.png
5-data_quality_q12.png
5-data_quality_q13.png
5-data_quality_q14(2).png
5-data_quality_q14.png
5-data_quality_q2.png
5-data_quality_q3.png
5-data_quality_q4(1-first and last order).png
5-data_quality_q4(2-year month and orders).png
5-data_quality_q4(3-two lost data).png
5-data_quality_q5.png
5-data_quality_q6.png
5-data_quality_q7.png
5-data_quality_q8.png
5-data_quality_q9.png
6-funnel_A.png
6-funnel_B.png
6-funnel_C.png
6-funnel_D.png
7-retention_cohort_0.png
7-retention_cohort_A.png
7-retention_cohort_B.png
7-retention_cohort_C.png
8-segmentation(sanity check).png
8-segmentation_0.png
8-segmentation_A.png
8-segmentation_B.png
8-segmentation_C.png
9-extra_analysis_E1.png
9-extra_analysis_E2.png
9-extra_analysis_E3.png
9-extra_analysis_E4.png
9-extra_analysis_E5.png
```

---

## 4. Folder `data/` — Data Mentah (9 CSV)

| File | Isi / Peran |
|---|---|
| `olist_customers_dataset.csv` | `customer_id`, `customer_unique_id`, lokasi pelanggan (ZIP, kota, state) |
| `olist_geolocation_dataset.csv` | Prefiks ZIP → latitude, longitude, kota, state |
| `olist_orders_dataset.csv` | Order + 4 timestamp (purchase, approved, delivered carrier, delivered customer) + estimasi & status |
| `olist_order_items_dataset.csv` | Item per order: product_id, seller_id, shipping limit, price, freight |
| `olist_order_payments_dataset.csv` | Pembayaran per order (sequential, tipe, cicilan, nilai) |
| `olist_order_reviews_dataset.csv` | Review: skor, judul, pesan, tanggal dibuat & dijawab |
| `olist_products_dataset.csv` | Produk: kategori, dimensi, berat, panjang deskripsi |
| `olist_sellers_dataset.csv` | Penjual: ZIP, kota, state |
| `product_category_name_translation.csv` | Terjemahan nama kategori Portugis → Inggris |

> File CSV diabaikan oleh `.gitignore`; berada di dalam arsip `brazilian_e-commerce_public_dataset.zip`.

---

## 5. Folder `data_explain/` — Penjelasan/Tekst Hasil Analisis (10 TXT)

| File | Deskripsi |
|---|---|
| `7-A_full_cohort_table.txt` | Tabel kohort lengkap (cohort × month offset) |
| `7-B_pooled_retention.txt` | Retensi pooled per month offset |
| `7-C_sanity_check.txt` | Sanity check jumlah pelanggan independen (94.697) |
| `8-A_one-time_vs_repeat_customers.txt` | Segmentasi pelanggan one-time vs repeat |
| `8-B_top_15_categories_by_value_category_of_the_highest_priced.txt` | 15 kategori teratas berdasarkan nilai |
| `8-C_top_10_states_by_value.txt` | 10 state teratas berdasarkan nilai |
| `9-E1_on_time_vs_late_delivered_orders_only.txt` | Perbandingan on-time vs late (review) |
| `9-E2_by_how_many_days_late.txt` | Review berdasarkan jumlah hari keterlambatan |
| `9-E3_6_month_repeat_rate_by_delivery_status_of_the_customer_s.txt` | Repeat rate 6 bulan per status pengiriman |
| `9-E4_Is_the_low_review_rate_in_some_categories_explained_by_late__202611172000.txt` | Uji apakah review rendah di kategori tertentu dijelaskan oleh keterlambatan |
| `9-E5_Late_rate_by_state_top_10_states_by_delivered_orders_WITH_d__202611172013.txt` | Tingkat keterlambatan per state (10 state teratas) |

---

## 6. Folder `output/` — Hasil Export Query SQL (29 CSV)

Nama file diawali `_` dan diakhiri timestamp `YYYYMMDDHHmm` (hasil export dari SQLite/DBeaver).

### `output/01_data_quality/` (14 file)
```
_Q10_order_payments_202611171941.csv
_Q11_SELECT_COUNT_DISTINCT_p_product_category_name_AS_categories_wit_202611171942.csv
_Q12_Timing_of_the_second_order_among_repeat_customers_same_day__202611171942.csv
_Q13_Which_orders_have_no_items_SELECT_o_order_status_COUNT_AS_o_202611171942.csv
_Q14_order_reviews_202611171943.csv
_Q14_SELECT_COUNT_AS_total_products_SUM_product_category_name_IS_NUL_202611171943.csv
_Q1_Null_counts_on_order_timestamps_SELECT_COUNT_AS_total_orders_202611171933.csv
_Q2_Duplicate_check_on_primary_keys_SELECT_orders_AS_tbl_COUNT_A_202611171935.csv
_Q3_Order_status_distribution_SELECT_order_status_COUNT_AS_n_ROU_202611171936.csv
_Q4_SELECT_strftime_Y_m_order_purchase_timestamp_AS_year_month_COUN_202611171936.csv
_Q5_Illogical_date_sequences_each_count_should_ideally_be_0_SELE_202611171936.csv
_Q6_Status_vs_missing_delivery_date_are_statuses_consistent_with_202611171937.csv
_Q7_customers_202611171938.csv
_Q8_Orders_per_real_person_distribution_of_repeat_purchase_WITH__202611171939.csv
_Q9_SELECT_COUNT_AS_items_without_order_FROM_order_items_i_LEFT_JOI_202611171940.csv
```
Isi: null timestamp, duplikat primary key, distribusi status, volume bulanan, urutan tanggal tidak logis, konsistensi status vs tanggal, customer unik, distribusi repeat order, item tanpa order, payment rows, kategori tanpa terjemahan, timing order kedua, order tanpa item, review, produk tanpa kategori.

### `output/02_funnel/` (4 file)
```
_A_stages_202611171947.csv
_B_Where_do_orders_stop_Last_stage_reached_x_final_status_SELECT_202611171948.csv
_C_Stage_durations_in_days_negative_durations_from_illogical_tim_202611171948.csv
_D_Are_unfinished_orders_stale_real_leakage_or_recent_still_in_f_202611171948.csv
```
Isi: (A) funnel purchased→approved→shipped→delivered, (B) tahap terakhir × status akhir, (C) durasi tiap tahap, (D) order belum selesai (stale vs in-flight).

### `output/03_retention_cohort/` (3 file)
```
_A_v_cohort_retention_202611171949.csv
_B_Pooled_retention_by_month_offset_all_observable_cohorts_combi_202611171949.csv
_C_SELECT_COUNT_AS_independent_count_FROM_SELECT_c_customer_unique_202611171950.csv
```
Isi: tabel kohort penuh, retensi pooled, sanity check pelanggan independen.

### `output/04_segmentation/` (3 file)
```
_A_One_time_vs_repeat_customers_WITH_cust_AS_SELECT_customer_uni_202611171951.csv
_B_Top_15_categories_by_value_category_of_the_highest_priced_ite_202611171952.csv
_C_Top_10_states_by_value_SELECT_customer_state_COUNT_DISTINCT_c_202611171952.csv
```
Isi: one-time vs repeat, kategori teratas, state teratas.

### `output/05_extra_analysis/` (5 file)
```
_E1_On_time_vs_late_delivered_orders_only_WITH_d_AS_SELECT_revie_202611171953.csv
_E2_By_how_many_days_late_WITH_d_AS_SELECT_review_score_julianda_202611171953.csv
_E3_6_month_repeat_rate_by_delivery_status_of_the_customer_s_FIR_202611171954.csv
_E4_Is_the_low_review_rate_in_some_categories_explained_by_late__202611172000.csv
_E5_Late_rate_by_state_top_10_states_by_delivered_orders_WITH_d__202611172014.csv
```
Isi: analisis dampak keterlambatan pengiriman terhadap review dan repeat purchase.

---

## 7. Folder `scripts/` — Skrip Python (2 file)

| File | Deskripsi |
|---|---|
| `load_data.py` | Membaca 9 CSV dari `data/` dengan `pandas`, menjaga kolom ZIP tetap teks, lalu membuat/mengisi `olist.db` (SQLite) |
| `make_charts.py` | Membaca CSV dari `output/`, membuat grafik dengan `matplotlib` (backend `Agg`) lalu menyimpannya ke `assets/` |

---

## 8. Folder `sql/` — Kueri Analitik (6 file)

| File | Tujuan |
|---|---|
| `00_schema_and_load.sql` | Verifikasi schema/row count tiap tabel setelah load |
| `01_data_quality.sql` | Q1–Q14: cek kualitas data sebelum analisis (output ke `notes.md`) |
| `02_funnel.sql` | Funnel pemenuhan order berbasis timestamp, kebocoran per status, durasi tahap |
| `03_retention_cohort.sql` | Kohort retensi bulanan per `customer_unique_id` (2017-01 s.d. 2018-08) + view `v_cohort_retention` |
| `04_segmentation.sql` | Segmentasi pelanggan/kategori/state + view `v_order_base` |
| `05_extra_analysis.sql` | E1–E5: apakah keterlambatan pengiriman menurunkan review & repeat rate 6 bulan |

---

## 9. Ringkasan Jumlah

| Lokasi | Jenis | Jumlah |
|---|---|---|
| Root | File | 8 |
| `assets/` | PNG | 35 |
| `data/` | CSV | 9 |
| `data_explain/` | TXT | 10 |
| `output/` | CSV (5 subfolder) | 29 |
| `scripts/` | Python | 2 |
| `sql/` | SQL | 6 |
| **Total** | **File (tanpa `.git`)** | **99** |

Alur kerja: `zip/CSV` → `scripts/load_data.py` → `olist.db` → `sql/*.sql` → `output/*.csv` → `scripts/make_charts.py` → `assets/*.png`, dengan catatan di `notes.md`, `table_explanation.md`, `olist-db_column_context.md`, dan `data_explain/*.txt`.
