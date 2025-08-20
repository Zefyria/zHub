CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS {TARGET_DATABASE};

DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('{CREATE/INSERT/UPDATE}', '{TARGET_DATABASE}', '{TARGET_TABLE}', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS {TARGET_DATABASE}.{TARGET_TABLE};

    CREATE TABLE {TARGET_DATABASE}.{TARGET_TABLE} (
         col_int                        INTEGER
        ,col_varchar                    VARCHAR(50)
        ,col_flag                       VARCHAR(1)
        ,col_num                        NUMERIC(21,16)
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
