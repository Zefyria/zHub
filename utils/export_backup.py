import os
import psycopg2
import pandas as pd
from dotenv import load_dotenv
from datetime import datetime
from psycopg2 import sql

# ---------- CONFIG ----------
load_dotenv()
password = os.environ.get("PG_PASSWORD")

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "zHub",  # main database with your schemas
    "user": "postgres",
    "password": password
}

EXPORT_ROOT = os.path.join(os.getcwd(), "backup")
os.makedirs(EXPORT_ROOT, exist_ok=True)

# ---------- FUNCTIONS ----------
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

def get_schemas(conn):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT schema_name
            FROM information_schema.schemata
            WHERE schema_name NOT IN ('information_schema','pg_catalog','pg_toast')
        """)
        return [row[0] for row in cur.fetchall()]

def get_tables(conn, schema):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = %s AND table_type='BASE TABLE'
        """, (schema,))
        return [row[0] for row in cur.fetchall()]

def create_folder(path):
    """Create folder if it doesn't exist and print alert."""
    if not os.path.exists(path):
        os.makedirs(path)
        print(f"Created folder: {path}")

def export_table(conn, schema, table, folder, timestamp):
    log_id = None
    try:
        # Start log
        log_id = log_start(conn, 'BACKUP', schema, table)

        # Build SQL query
        query = sql.SQL("SELECT * FROM {}.{}").format(sql.Identifier(schema), sql.Identifier(table))
        # Read table into DataFrame
        df = pd.read_sql(query.as_string(conn), conn)

        # File path with timestamp
        file_name = f"{timestamp}_{schema}.{table}.csv"
        file_path = os.path.join(folder, file_name)

        # Export CSV
        df.to_csv(file_path, index=False)
        print(f"Exported {schema}.{table} to {file_path}")

        # Log completed
        log_end(conn, log_id, 'COMPLETED')
    except Exception as e:
        if log_id:
            log_end(conn, log_id, 'FAILED', str(e))
        print(f"Failed to export {schema}.{table}: {e}")

# ---------- MAIN ----------
def main():
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")

    conn = psycopg2.connect(**DB_CONFIG)
    try:
        schemas = get_schemas(conn)
        for schema in schemas:
            schema_folder = os.path.join(EXPORT_ROOT, schema)
            create_folder(schema_folder)

            tables = get_tables(conn, schema)
            
            if not tables:
                print(f"Schema '{schema}' has no tables.")
                continue  # skip to next schema

            for table in tables:
                table_folder = os.path.join(schema_folder, table)
                create_folder(table_folder)

                # Export table to CSV with logging
                export_table(conn, schema, table, table_folder, timestamp)
    finally:
        conn.close()

# ---------- ENTRY POINT ----------
if __name__ == "__main__":
    main()
