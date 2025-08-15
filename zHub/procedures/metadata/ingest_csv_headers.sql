DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'metadata', 'ingest_csv_headers', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS metadata.ingest_csv_headers;

    CREATE TABLE metadata.ingest_csv_headers (
         db_name     VARCHAR(50) NOT NULL
        ,tb_name     VARCHAR(50) NOT NULL
        ,column_name VARCHAR(50) NOT NULL   -- target table column
        ,csv_header  VARCHAR(255) NOT NULL  -- corresponding CSV header
    );

    -- update log on success
    UPDATE metadata.logs
    SET status = 'COMPLETED', end_time = NOW()
    WHERE log_id = v_log_id;

EXCEPTION WHEN OTHERS THEN
    -- update log on failure
    UPDATE metadata.logs
    SET status = 'FAILED', end_time = NOW(), err_msg = SQLERRM
    WHERE log_id = v_log_id;

END$$;
