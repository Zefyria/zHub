DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'metadata', 'catalog', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS metadata.catalog;

    CREATE TABLE metadata.catalog (
         obj_id         SERIAL PRIMARY KEY
        ,db_name        VARCHAR(100) NOT NULL
        ,tb_name        VARCHAR(100) NOT NULL
        ,source_name    VARCHAR(100) NOT NULL
        ,source_url     VARCHAR(255)
        ,ingest_time    TIMESTAMP NOT NULL
        ,destroy_time   TIMESTAMP
        ,err_msg        TEXT
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
