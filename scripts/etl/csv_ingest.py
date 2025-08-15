import pandas as pd
import psycopg2
from psycopg2 import sql
from datetime import datetime

# File path
csv_file = r"C:\Users\Zef\Downloads\NAPLAN_Results.csv"

# Read CSV
df = pd.read_csv(csv_file)

# Database connection parameters
conn_params = {
    "host": "localhost",
    "port": 5432,
    "dbname": "zHub",
    "user": "postgres",
    "password": "zef"
}

try:
    # Connect to PostgreSQL
    conn = psycopg2.connect(**conn_params)
    conn.autocommit = False  # for transaction
    cur = conn.cursor()

    # Insert log for INSERT start
    cur.execute("""
        INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
        VALUES (%s, %s, %s, %s, %s)
        RETURNING log_id
    """, ('INSERT', 'raw', 'NAPLAN_2025_Results', 'RUNNING', datetime.now()))
    log_id = cur.fetchone()[0]

    # Prepare insert statement dynamically
    cols = df.columns.tolist()
    insert_sql = sql.SQL("INSERT INTO raw.NAPLAN_2025_Results ({}) VALUES ({})").format(
        sql.SQL(', ').join(map(sql.Identifier, cols)),
        sql.SQL(', ').join(sql.Placeholder() * len(cols))
    )

    # Insert each row
    for i, row in df.iterrows():
        cur.execute(insert_sql, row.tolist())

    # Update log as completed
    cur.execute("""
        UPDATE metadata.logs
        SET status = 'COMPLETED', end_time = %s
        WHERE log_id = %s
    """, (datetime.now(), log_id))

    conn.commit()
    print(f"Inserted {len(df)} rows and updated log {log_id}.")

except Exception as e:
    # On error, update log as failed
    if 'cur' in locals() and 'log_id' in locals():
        cur.execute("""
            UPDATE metadata.logs
            SET status = 'FAILED', end_time = %s, err_msg = %s
            WHERE log_id = %s
        """, (datetime.now(), str(e), log_id))
        conn.commit()
    print("Error:", e)

finally:
    if 'cur' in locals():
        cur.close()
    if 'conn' in locals():
        conn.close()
