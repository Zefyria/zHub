import os
import psycopg2
import pandas as pd
from psycopg2 import sql
from dotenv import load_dotenv
from datetime import datetime

# ---------- CONFIG ----------
load_dotenv()
PG_PASSWORD = os.environ.get("PG_PASSWORD")
if not PG_PASSWORD:
    raise ValueError("Environment variable PG_PASSWORD not set")

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "user": "postgres",
    "password": PG_PASSWORD
}

EXPORT_ROOT = os.path.join(os.getcwd(), "backup")
os.makedirs(EXPORT_ROOT, exist_ok=True)

TIMESTAMP = datetime.now().strftime("%Y%m%d_%H%M%S")

# ---------- LOGGING ----------
def log(conn, job_name, db_name, tb_name, status, log_id=None, err_msg=None):
    """Insert or update a log entry."""
    with conn.cursor() as cur:
        if log_id is None:
            cur.execute("""
                INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
                VALUES (%s, %s, %s, %s, NOW())
                RETURNING log_id
            """, (job_name, db_name, tb_name, status))
            log_id = cur.fetchone()[0]
        else:
            cur.execute("""
                UPDATE metadata.logs
                SET status = %s, end_time = NOW(), err_msg = %s
                WHERE log_id = %s
            """, (status, err_msg, log_id))
    conn.commit()
    return log_id

# ---------- DB FUNCTIONS ----------
def get_databases(conn):
    """Return a list of database names (excluding system DBs)."""
    with conn.cursor() as cur:
        cur.execute("""
            SELECT datname
            FROM pg_database
            WHERE datistemplate = false
              AND datname NOT IN ('postgres')
        """)
        return [row[0] for row in cur.fetchall()]

def get_schemas(conn):
    """Return a list of schemas in the current database."""
    with conn.cursor() as cur:
        cur.execute("""
            SELECT schema_name
            FROM information_schema.schemata
            WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
        """)
        return [row[0] for row in cur.fetchall()]

def get_tables(conn, schema):
    """Return list of tables in a schema."""
    with conn.cursor() as cur:
        cur.execute("""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = %s
              AND table_type='BASE TABLE'
        """, (schema,))
        return [row[0] for row in cur.fetchall()]

def create_folder(path):
    os.makedirs(path, exist_ok=True)
    print(f"Created folder: {path}")

# ---------- EXPORT FUNCTION ----------
def export_table_to_csv(db_conn, schema, table, export_root, timestamp, log_conn):
    """Export a single table to CSV and log progress."""
    db_name = db_conn.get_dsn_parameters()['dbname']
    schema_folder = os.path.join(export_root, schema)
    table_folder = os.path.join(schema_folder, table)
    create_folder(schema_folder)
    create_folder(table_folder)

    filename = f"{timestamp}_{db_name}.{table}.csv"
    filepath = os.path.join(table_folder, filename)

    log_id = log(log_conn, 'BACKUP', db_name, f"{schema}.{table}", 'RUNNING')
    try:
        query = sql.SQL("SELECT * FROM {}.{}").format(sql.Identifier(schema), sql.Identifier(table))
        df = pd.read_sql(query.as_string(db_conn), db_conn)
        df.to_csv(filepath, index=False)
        log(log_conn, 'BACKUP', db_name, f"{schema}.{table}", 'COMPLETED', log_id)
        print(f"Exported {schema}.{table} to {filepath}")
    except Exception as e:
        log(log_conn, 'BACKUP', db_name, f"{schema}.{table}", 'FAILED', log_id, str(e))
        print(f"Failed to export {schema}.{table}: {e}")

# ---------- MAIN ----------
def main():
    # Connection for logging only (central database)
    log_conn = psycopg2.connect(**{**DB_CONFIG, "dbname": "zHub"})
    # Initial connection to list databases
    conn = psycopg2.connect(**{**DB_CONFIG, "dbname": "postgres"})
    try:
        databases = get_databases(conn)
        print(f"Databases found: {databases}")

        for db in databases:
            db_conn = psycopg2.connect(**{**DB_CONFIG, "dbname": db})
            try:
                schemas = get_schemas(db_conn)
                for schema in schemas:
                    tables = get_tables(db_conn, schema)
                    for table in tables:
                        export_table_to_csv(db_conn, schema, table, EXPORT_ROOT, TIMESTAMP, log_conn)
            finally:
                db_conn.close()
    finally:
        conn.close()
        log_conn.close()

if __name__ == "__main__":
    main()
# ---------- END ----------