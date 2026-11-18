"""Run every SQL file in sql/ against olist.db and export each result set to CSV.

Usage:
    python scripts/run_sql.py                     # full pipeline into output/
    python scripts/run_sql.py --out output_auto   # write elsewhere (e.g. to compare first)
    python scripts/run_sql.py --only 02 05        # only files whose name starts with 02 or 05
    python scripts/run_sql.py --clean             # delete old CSVs in the target subfolders first

Conventions in the SQL files:
    - Statements end with a semicolon.
    - A comment line of the form "-- A. Some title" or "-- Q12. Some title" right above a
      statement names its CSV (_A_some_title.csv). Statements without a label of their own
      reuse the previous label and get a _part2, _part3, ... suffix.
    - Statements that return no rows (CREATE VIEW, ...) are executed but not exported.
"""
import argparse
import csv
import re
import sqlite3
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# "-- A. title", "-- Q12. title", "-- E3. title", "-- 0. title"
LABEL_RE = re.compile(r"^--\s*((?:[A-Z]\d{0,2})|\d{1,2})\.\s+(.+)$")

# Expected values come from the verified analysis of the Kaggle Olist dataset.
CHECKS = [
    ("orders loaded",
     "SELECT COUNT(*) FROM orders",
     99441),
    ("funnel: orders delivered (strict stages)",
     """SELECT COUNT(*) FROM orders
        WHERE order_approved_at IS NOT NULL
          AND order_delivered_carrier_date IS NOT NULL
          AND order_delivered_customer_date IS NOT NULL""",
     96461),
    ("retention: customers in cohorts 2017-01..2018-08",
     "SELECT SUM(cohort_size) FROM v_cohort_retention WHERE month_offset = 0",
     94697),
    ("v_order_base: valid orders",
     "SELECT COUNT(*) FROM v_order_base",
     98206),
    ("v_order_base: repeat customers (2+ valid orders)",
     """SELECT COUNT(*) FROM (
          SELECT customer_unique_id FROM v_order_base
          GROUP BY customer_unique_id HAVING COUNT(*) > 1)""",
     2887),
    ("late delivered orders (date vs estimate)",
     """SELECT COUNT(*) FROM v_order_base
        WHERE order_delivered_customer_date IS NOT NULL
          AND julianday(date(order_delivered_customer_date))
            > julianday(date(order_estimated_delivery_date))""",
     6534),
]


def split_statements(sql_text):
    """Split SQL text into statements; comments stay attached to the statement below them."""
    statements, buf = [], ""
    for line in sql_text.splitlines(keepends=True):
        buf += line
        if sqlite3.complete_statement(buf):
            statements.append(buf.strip())
            buf = ""
    leftover = [ln for ln in buf.splitlines() if ln.strip() and not ln.strip().startswith("--")]
    if leftover:  # last statement without a closing semicolon
        statements.append(buf.strip())
    return statements


def leading_label(statement):
    """Return (label, title) from the comment block above the SQL, or None."""
    found = None
    for line in statement.splitlines():
        s = line.strip()
        if not s:
            continue
        if not s.startswith("--"):
            break
        m = LABEL_RE.match(s)
        if m:
            found = (m.group(1), m.group(2))
    return found


def slugify(text, max_len=40):
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")[:max_len].strip("_")


def drop_views(con):
    names = [r[0] for r in con.execute("SELECT name FROM sqlite_master WHERE type = 'view'")]
    for name in names:
        con.execute(f'DROP VIEW IF EXISTS "{name}"')


def run_file(con, sql_path, out_dir):
    statements = split_statements(sql_path.read_text(encoding="utf-8-sig"))
    current = None   # (label, slug) of the most recent labelled statement
    parts = {}       # label -> number of exported result sets so far
    exported = 0

    for i, stmt in enumerate(statements, start=1):
        found = leading_label(stmt)
        if found:
            current = (found[0], slugify(found[1]))
        label, slug = current if current else (f"stmt{i}", "")

        try:
            cur = con.execute(stmt)
            rows = cur.fetchall() if cur.description else None
        except sqlite3.Error as exc:
            preview = " ".join(stmt.split())[:140]
            sys.exit(f"\nERROR in {sql_path.name}, statement {i} (label {label}): {exc}\n  {preview}")

        if rows is None:
            print(f"  [{label}] executed (no result set)")
            continue

        parts[label] = parts.get(label, 0) + 1
        name = f"_{label}" + (f"_{slug}" if slug else "")
        if parts[label] > 1:
            name += f"_part{parts[label]}"
        path = out_dir / f"{name}.csv"

        out_dir.mkdir(parents=True, exist_ok=True)
        with path.open("w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([d[0] for d in cur.description])
            writer.writerows(rows)

        print(f"  [{label}] {len(rows):>6,} rows -> {path.relative_to(ROOT) if path.is_relative_to(ROOT) else path}")
        exported += 1
    return exported


def run_checks(con):
    print("\nReproducibility checks (expected values from the published analysis):")
    all_ok = True
    for name, query, expected in CHECKS:
        try:
            actual = con.execute(query).fetchone()[0]
        except sqlite3.Error:
            print(f"  SKIP  {name}: a required table or view is missing")
            continue
        ok = actual == expected
        all_ok &= ok
        print(f"  {'PASS' if ok else 'FAIL'}  {name}: expected {expected:,}, got {actual:,}"
              if isinstance(actual, int) else
              f"  {'PASS' if ok else 'FAIL'}  {name}: expected {expected}, got {actual}")
    return all_ok


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--db", type=Path, default=ROOT / "olist.db")
    ap.add_argument("--sql-dir", type=Path, default=ROOT / "sql")
    ap.add_argument("--out", type=Path, default=ROOT / "output")
    ap.add_argument("--only", nargs="+", metavar="PREFIX",
                    help="run only SQL files whose name starts with one of these prefixes")
    ap.add_argument("--clean", action="store_true",
                    help="delete existing CSVs in each target subfolder before exporting")
    ap.add_argument("--no-checks", action="store_true", help="skip the reproducibility checks")
    args = ap.parse_args()

    if not args.db.exists():
        sys.exit(f"Database not found: {args.db}\nRun scripts/load_data.py first.")

    files = sorted(args.sql_dir.glob("*.sql"))
    if args.only:
        files = [f for f in files if f.name.startswith(tuple(args.only))]
    if not files:
        sys.exit(f"No SQL files to run in {args.sql_dir}")

    start = time.time()
    con = sqlite3.connect(args.db)
    if not args.only:          # full run: rebuild every view from its SQL definition
        drop_views(con)

    total = 0
    for sql_path in files:
        out_dir = args.out / sql_path.stem
        if args.clean and out_dir.exists():
            for old in out_dir.glob("*.csv"):
                old.unlink()
        print(f"\n{sql_path.name}")
        total += run_file(con, sql_path, out_dir)
    con.commit()

    ok = True if args.no_checks else run_checks(con)
    con.close()
    print(f"\nDone: {total} CSV files in {time.time() - start:.1f}s -> {args.out}")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()