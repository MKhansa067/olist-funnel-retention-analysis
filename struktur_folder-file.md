# Struktur Folder & File — `olist-funnel-retention`

Proyek analisis data e-commerce Olist (Brasil) yang mencakup: pemuatan data CSV ke SQLite, pemeriksaan kualitas data, analisis funnel pemenuhan pesanan, retensi kohort pelanggan, segmentasi, dan analisis tambahan (dampak keterlambatan pengiriman). Documentation ini dibuat dengan membaca seluruh struktur folder/file di root proyek (folder internal `.git` tidak didokumentasikan).

> Root: `D:\My-Career\Portfolio\DANA\olist-funnel-retention`
> Dibuat: 2026-11-18

---

## 1. Pohon Struktur (Ringkas)

```
olist-funnel-retention/
├── .gitignore
├── README.md                        (isi lengkap: pendekatan, temuan, rekomendasi)
├── requirements.txt                 (pandas, matplotlib, numpy)
├── CV_BULLET.txt                    (ringkasan untuk CV: 2 poin temuan utama)
├── SUMMARY.md                       (ringkasan eksekutif + rekomendasi RICE)
├── struktur_folder-file.md          (file ini)
├── brazilian_e-commerce_public_dataset.zip  (arsip sumber data, 44,7 MB)
├── olist.db                         (SQLite hasil load CSV, 152 MB, diabaikan git)
├── assets/                          (1 subfolder charts)
│   └── charts/
│       ├── chart_category_low_review.png
│       ├── chart_funnel.png
│       ├── chart_late_vs_review.png
│       ├── chart_retention_heatmap.png
│       ├── chart_retention_pooled.png
│       ├── monthly_cohort_retention_heatmap.txt
│       └── pooled_retention_chart.txt
├── data/                            (9 file CSV sumber, diabaikan .gitignore)
│   ├── olist_customers_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   └── product_category_name_translation.csv
├── docs/                            (dokumen & screenshot)
│   ├── notes.md                     (catatan data quality + ringkasan hasil analisis)
│   ├── olist-db_column_context.md   (konteks 9 tabel & tipe kolom DB)
│   ├── table_explanation.md         (catatan iterasi q1–q14, funnel, cohort, segmentasi + angka)
│   ├── data_explain/                (11 file TXT hasil analisis)
│   │   ├── 7-A_full_cohort_table.txt
│   │   ├── 7-B_pooled_retention.txt
│   │   ├── 7-C_sanity_check.txt
│   │   ├── 8-A_one-time_vs_repeat_customers.txt
│   │   ├── 8-B_top_15_categories_by_value_category_of_the_highest_priced.txt
│   │   ├── 8-C_top_10_states_by_value.txt
│   │   ├── 9-E1_on_time_vs_late_delivered_orders_only.txt
│   │   ├── 9-E2_by_how_many_days_late.txt
│   │   ├── 9-E3_6_month_repeat_rate_by_delivery_status_of_the_customer_s.txt
│   │   ├── 9-E4_Is_the_low_review_rate_in_some_categories_explained_by_late__202611172000.txt
│   │   └── 9-E5_Late_rate_by_state_top_10_states_by_delivered_orders_WITH_d__202611172013.txt
│   └── screenshots/                 (39 file PNG)
│       ├── 1-load_data-py.png
│       ├── 2-load_dbeaver.png
│       ├── 3-sql_verification.png
│       ├── 4-data_peek.png
│       ├── 5-data_quality_q1.png
│       ├── 5-data_quality_q2.png
│       ├── 5-data_quality_q3.png
│       ├── 5-data_quality_q4(1-first and last order).png
│       ├── 5-data_quality_q4(2-year month and orders).png
│       ├── 5-data_quality_q4(3-two lost data).png
│       ├── 5-data_quality_q5.png
│       ├── 5-data_quality_q6.png
│       ├── 5-data_quality_q7.png
│       ├── 5-data_quality_q8.png
│       ├── 5-data_quality_q9.png
│       ├── 5-data_quality_q10.png
│       ├── 5-data_quality_q11.png
│       ├── 5-data_quality_q12.png
│       ├── 5-data_quality_q13.png
│       ├── 5-data_quality_q14.png
│       ├── 5-data_quality_q14(2).png
│       ├── 6-funnel_A.png
│       ├── 6-funnel_B.png
│       ├── 6-funnel_C.png
│       ├── 6-funnel_D.png
│       ├── 7-retention_cohort_0.png
│       ├── 7-retention_cohort_A.png
│       ├── 7-retention_cohort_B.png
│       ├── 7-retention_cohort_C.png
│       ├── 8-segmentation_0.png
│       ├── 8-segmentation_A.png
│       ├── 8-segmentation_B.png
│       ├── 8-segmentation_C.png
│       ├── 8-segmentation(sanity check).png
│       ├── 9-extra_analysis_E1.png
│       ├── 9-extra_analysis_E2.png
│       ├── 9-extra_analysis_E3.png
│       ├── 9-extra_analysis_E4.png
│       └── 9-extra_analysis_E5.png
├── output/                          (5 subfolder, 30 file CSV hasil export query)
│   ├── 01_data_quality/             (15 CSV: _Q1.._Q14, termasuk 2 varian Q14)
│   ├── 02_funnel/                   (4 CSV: _A.._D)
│   ├── 03_retention_cohort/         (3 CSV: _A.._C)
│   ├── 04_segmentation/             (3 CSV: _A.._C)
│   └── 05_extra_analysis/           (5 CSV: _E1.._E5)
├── scripts/                         (2 file Python)
│   ├── load_data.py
│   └── make_charts.py
└── sql/                             (6 file SQL)
    ├── 00_schema_and_load.sql
    ├── 01_data_quality.sql
    ├── 02_funnel.sql
    ├── 03_retention_cohort.sql
    ├── 04_segmentation.sql
    └── 05_extra_analysis.sql
```

---

## 2. File di Root

| File | Deskripsi |
|---|---|
| `.gitignore` | Mengabaikan `data/*.csv`, `*.db`, `__pycache__/`, `.ipynb_checkpoints/`, `*.zip` |
| `README.md` | Dokumentasi lengkap: pendekatan, temuan, rekomendasi RICE, cara reproduksi |
| `requirements.txt` | Dependensi Python: `pandas`, `matplotlib`, `numpy` |
| `CV_BULLET.txt` | Ringkasan untuk CV (2 poin temuan utama) |
| `SUMMARY.md` | Ringkasan eksekutif + rekomendasi RICE (3 rekomendasi) |
| `struktur_folder-file.md` | File dokumentasi struktur folder ini |
| `brazilian_e-commerce_public_dataset.zip` | Arsip dataset publik e-commerce Brasil (sumber data, 44,7 MB) |
| `olist.db` | Database SQLite hasil load dari CSV (152 MB, diabaikan git) |

---

## 3. Folder `assets/` — Grafik (1 subfolder `charts/`)

`assets/charts/` berisi 5 file PNG dan 2 file TXT:

| File | Deskripsi |
|---|---|
| `chart_funnel.png` | Grafik funnel pemenuhan pesanan |
| `chart_retention_heatmap.png` | Heatmap retensi kohort |
| `chart_retention_pooled.png` | Grafik retensi pooled |
| `chart_late_vs_review.png` | Grafik keterlambatan vs review |
| `chart_category_low_review.png` | Grafik low-review share per kategori |
| `monthly_cohort_retention_heatmap.txt` | Data tabel heatmap retensi kohort bulanan |
| `pooled_retention_chart.txt` | Data tabel retensi pooled |

---

## 4. Folder `data/` — Data Mentah (9 CSV)

File CSV diabaikan oleh `.gitignore`; berasal dari arsip `brazilian_e-commerce_public_dataset.zip`.

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

---

## 5. Folder `docs/` — Dokumen dan Screenshot

### File teks di root `docs/`

| File | Deskripsi |
|---|---|
| `notes.md` | Catatan temuan data quality + ringkasan semua hasil analisis (funnel, retention, segmentasi, late delivery) |
| `olist-db_column_context.md` | Konteks 9 tabel & tipe kolom database Olist |
| `table_explanation.md` | Catatan iterasi (q1–q14, funnel, cohort, segmentasi) beserta angka hasil |

### Subfolder `docs/data_explain/` — Penjelasan/Tekst Hasil Analisis (11 TXT)

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

### Subfolder `docs/screenshots/` — Dokumentasi Visual (39 PNG)

Screenshot terurut sesuai alur kerja: load data → verifikasi DB/SQL → peek data → data quality Q1–Q14 → funnel A–D → retention cohort 0,A,B,C → segmentation 0,A,B,C,(sanity check) → extra analysis E1–E5.

---

## 6. Folder `output/` — Hasil Export Query SQL (30 CSV, 5 subfolder)

Nama file diawali `_` dan diakhiri timestamp `YYYYMMDDHHmm`.

### `output/01_data_quality/` (15 file)

| File | Topik |
|---|---|
| `_Q1_Null_counts_on_order_timestamps...` | Null timestamps pada order |
| `_Q2_Duplicate_check_on_primary_keys...` | Cek duplikasi primary key |
| `_Q3_Order_status_distribution...` | Distribusi status order |
| `_Q4_SELECT_strftime_Y_m_order_purchase_timestamp...` | Volume order bulanan |
| `_Q5_Illogical_date_sequences...` | Urutan tanggal tidak logis |
| `_Q6_Status_vs_missing_delivery_date...` | Konsistensi status vs tanggal delivery |
| `_Q7_customers...` | Pelanggan unik |
| `_Q8_Orders_per_real_person...` | Distribusi repeat purchase per orang |
| `_Q9_SELECT_COUNT_AS_items_without_order...` | Item tanpa order |
| `_Q10_order_payments...` | Pembayaran order |
| `_Q11_SELECT_COUNT_DISTINCT_p_product_category_name...` | Kategori tanpa terjemahan |
| `_Q12_Timing_of_the_second_order_among_repeat_customers...` | Timing order kedua pelanggan repeat |
| `_Q13_Which_orders_have_no_items...` | Order tanpa item |
| `_Q14_order_reviews...` | Review order |
| `_Q14_SELECT_COUNT_AS_total_products...` | Produk tanpa kategori |

### `output/02_funnel/` (4 file)

| File | Isi |
|---|---|
| `_A_stages...` | Funnel purchased→approved→shipped→delivered |
| `_B_Where_do_orders_stop...` | Tahap terakhir reached × status akhir |
| `_C_Stage_durations_in_days...` | Durasi tiap tahap (hari) |
| `_D_Are_unfinished_orders_stale...` | Order belum selesai: stale vs in-flight |

### `output/03_retention_cohort/` (3 file)

| File | Isi |
|---|---|
| `_A_v_cohort_retention...` | Tabel kohort penuh |
| `_B_Pooled_retention_by_month_offset...` | Retensi pooled per month offset |
| `_C_SELECT_COUNT_AS_independent_count...` | Sanity check pelanggan independen |

### `output/04_segmentation/` (3 file)

| File | Isi |
|---|---|
| `_A_One_time_vs_repeat_customers...` | One-time vs repeat customer |
| `_B_Top_15_categories_by_value...` | 15 kategori teratas |
| `_C_Top_10_states_by_value...` | 10 state teratas |

### `output/05_extra_analysis/` (5 file)

| File | Isi |
|---|---|
| `_E1_On_time_vs_late_delivered_orders_only...` | On-time vs late delivered orders (review) |
| `_E2_By_how_many_days_late...` | Review per hari keterlambatan |
| `_E3_6_month_repeat_rate_by_delivery_status...` | Repeat rate 6 bulan per status pengiriman |
| `_E4_Is_the_low_review_rate_in_some_categories_explained_by_late...` | Review rendah kategori vs keterlambatan |
| `_E5_Late_rate_by_state_top_10_states...` | Tingkat keterlambatan per state (10 teratas) |

---

## 7. Folder `scripts/` — Skrip Python (2 file)

| File | Deskripsi |
|---|---|
| `load_data.py` | Membaca 9 CSV dari `data/` dengan pandas (kolom ZIP sebagai teks), membuat/mengisi `olist.db` (SQLite) |
| `make_charts.py` | Membaca CSV dari `output/`, membuat grafik dengan matplotlib (backend Agg), menyimpan ke `assets/charts/` |

---

## 8. Folder `sql/` — Kueri Analitik (6 file)

| File | Tujuan |
|---|---|
| `00_schema_and_load.sql` | Verifikasi schema/row count tiap tabel setelah load |
| `01_data_quality.sql` | Q1–Q14: cek kualitas data sebelum analisis |
| `02_funnel.sql` | Funnel pemenuhan order berbasis timestamp, kebocoran per status, durasi tahap |
| `03_retention_cohort.sql` | Kohort retensi bulanan per `customer_unique_id` (2017-01 s.d. 2018-08) + view `v_cohort_retention` |
| `04_segmentation.sql` | Segmentasi pelanggan/kategori/state + view `v_order_base` |
| `05_extra_analysis.sql` | E1–E5: dampak keterlambatan pengiriman terhadap review & repeat rate 6 bulan |

---

## 9. Ringkasan Jumlah

| Lokasi | Jenis | Jumlah |
|---|---|---|
| Root | File | 8 |
| `assets/charts/` | PNG + TXT | 7 (5 PNG, 2 TXT) |
| `data/` | CSV | 9 |
| `docs/` (root) | MD | 3 |
| `docs/data_explain/` | TXT | 11 |
| `docs/screenshots/` | PNG | 39 |
| `output/` | CSV (5 subfolder) | 30 |
| `scripts/` | Python | 2 |
| `sql/` | SQL | 6 |
| **Total** | **File (tanpa `.git`)** | **115** |

Alur kerja: `zip/CSV` → `scripts/load_data.py` → `olist.db` → `sql/*.sql` → `output/*.csv` → `scripts/make_charts.py` → `assets/charts/*.png`, dengan catatan di `docs/notes.md`, `docs/table_explanation.md`, `docs/olist-db_column_context.md`, dan `docs/data_explain/*.txt`.
