import os
import psycopg2
import pandas as pd
from psycopg2 import sql

# === CONFIG ===
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "zHub",
    "user": "postgres",
    "password": os.environ.get("PG_PASSWORD")
}

### UPDATE THIS SECTION ###
CSV_FILE = r"C:\Users\Zef\Downloads\zRepo.Sims4\Sims4.owned.csv"
TARGET_SCHEMA = 'sims4'
TARGET_TABLE = 'owned'
JOB_NAME = 'INSERT'  # Options: INSERT, REPLACE, APPEND
### UPDATE THIS SECTION ###

# === SCRIPT ===
try:
    # Load CSV into DataFrame
    df = pd.read_csv(CSV_FILE)
    print(f"[INFO] Loaded {len(df)} rows from {CSV_FILE}")

    # Connect to PostgreSQL
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    print("[INFO] Connected to database")

    # Build dynamic SQL for schema.table
    full_table_name = sql.Identifier(TARGET_SCHEMA, TARGET_TABLE)

    if JOB_NAME.upper() == 'REPLACE':
        # Truncate table before insert
        truncate_query = sql.SQL("TRUNCATE TABLE {}").format(full_table_name)
        cur.execute(truncate_query)
        print(f"[INFO] Table {TARGET_SCHEMA}.{TARGET_TABLE} truncated")

    # Insert data row by row (safe, dynamic column names)
    columns = [sql.Identifier(col) for col in df.columns]
    insert_query = sql.SQL("""
        INSERT INTO {} ({})
        VALUES ({})
    """).format(
        full_table_name,
        sql.SQL(', ').join(columns),
        sql.SQL(', ').join(sql.Placeholder() * len(columns))
    )

    for row in df.itertuples(index=False, name=None):
        cur.execute(insert_query, row)

    conn.commit()
    print(f"[INFO] Inserted {len(df)} rows into {TARGET_SCHEMA}.{TARGET_TABLE}")

except Exception as e:
    print(f"[ERROR] {e}")

finally:
    if cur:
        cur.close()
    if conn:
        conn.close()
    print("[INFO] Database connection closed")
