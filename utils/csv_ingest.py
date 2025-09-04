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
JOB_NAME = 'INSERT'
### UPDATE THIS SECTION ###


# === LOGGING FUNCTIONS ===
def log_start(conn, job_name, db_name, tb_name):
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
            VALUES (%s, %s, %s, 'RUNNING', NOW())
            RETURNING log_id
        """, (job_name, db_name, tb_name))
        log_id = cur.fetchone()[0]
        conn.commit()
        return log_id


def log_end(conn, log_id, status, err_msg=None):
    with conn.cursor() as cur:
        cur.execute("""
            UPDATE metadata.logs
            SET status = %s, end_time = NOW(), err_msg = %s
            WHERE log_id = %s
        """, (status, err_msg, log_id))
        conn.commit()


# === DATA INSERTION ===
def insert_data(df, conn, schema, table):
    # After reading CSV
    df.fillna('', inplace=True)

    # Optional: strip whitespace from all string columns
    for col in df.select_dtypes(include='object').columns:
        df[col] = df[col].str.strip()

    cols = list(df.columns)
    query = sql.SQL("INSERT INTO {}.{} ({}) VALUES ({})").format(
        sql.Identifier(schema),
        sql.Identifier(table),
        sql.SQL(', ').join(map(sql.Identifier, cols)),
        sql.SQL(', ').join(sql.Placeholder() * len(cols))
    )
    with conn.cursor() as cur:
        for row in df.itertuples(index=False, name=None):
            cur.execute(query, row)
    conn.commit()


# === MAIN ===
def main():
    conn = psycopg2.connect(**DB_CONFIG)
    log_id = None
    try:
        # start logging
        log_id = log_start(conn, JOB_NAME, TARGET_SCHEMA, TARGET_TABLE)

        # read CSV
        df = pd.read_csv(CSV_FILE)

        # no column renaming needed, CSV headers match DB
        # strip whitespace from string columns
        for col in df.select_dtypes(include='object').columns:
            df[col] = df[col].str.strip()

        # insert data
        insert_data(df, conn, TARGET_SCHEMA, TARGET_TABLE)

        # mark completed
        log_end(conn, log_id, 'COMPLETED')
        print("Data inserted successfully.")

    except Exception as e:
        # rollback in case of error
        conn.rollback()
        if log_id:
            log_end(conn, log_id, 'FAILED', str(e))
        print(f"Error: {e}")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
