import sqlite3
from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"
DB = ROOT / "olist.db"

FILES = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}

# Kode pos harus tetap teks agar angka nol di depan tidak hilang
ZIP_COLS = {
    "customer_zip_code_prefix": str,
    "seller_zip_code_prefix": str,
    "geolocation_zip_code_prefix": str,
}

INDEXES = [
    "CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id)",
    "CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status)",
    "CREATE INDEX IF NOT EXISTS idx_items_order ON order_items(order_id)",
    "CREATE INDEX IF NOT EXISTS idx_items_product ON order_items(product_id)",
    "CREATE INDEX IF NOT EXISTS idx_items_seller ON order_items(seller_id)",
    "CREATE INDEX IF NOT EXISTS idx_pay_order ON order_payments(order_id)",
    "CREATE INDEX IF NOT EXISTS idx_reviews_order ON order_reviews(order_id)",
    "CREATE INDEX IF NOT EXISTS idx_cust_id ON customers(customer_id)",
    "CREATE INDEX IF NOT EXISTS idx_cust_unique ON customers(customer_unique_id)",
    "CREATE INDEX IF NOT EXISTS idx_products_id ON products(product_id)",
]

def main():
    missing = [f for f in FILES.values() if not (DATA / f).exists()]
    if missing:
        raise SystemExit(f"File tidak ditemukan di {DATA}: {missing}")

    con = sqlite3.connect(DB)
    for table, fname in FILES.items():
        df = pd.read_csv(DATA / fname, dtype=ZIP_COLS)
        df.to_sql(table, con, if_exists="replace", index=False, chunksize=50_000)
        print(f"{table:<22} CSV rows: {len(df):>9,}")
    for stmt in INDEXES:
        con.execute(stmt)
    con.commit()

    print("\nJumlah baris di database:")
    for table in FILES:
        n = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        print(f"{table:<22} DB rows:  {n:>9,}")
    con.close()
    print("\nSelesai.")

if __name__ == "__main__":
    main()