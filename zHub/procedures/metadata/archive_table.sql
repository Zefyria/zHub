DO $$
DECLARE
    v_log_id INT;
    v_db_name VARCHAR(100) := 'govhack2025';    -- update as needed
    v_tb_name VARCHAR(100) := 'datasets';       -- update as needed
    v_archive_table TEXT;
    v_exists BOOLEAN;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('ARCHIVE', v_db_name, v_tb_name, 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    -- set archive table name: previousDB_previousTABLE
    v_archive_table := v_db_name || '_' || v_tb_name;

    -- copy table into archive
    EXECUTE format('CREATE TABLE %s.%s AS TABLE %I.%I',
        'archive', v_archive_table, v_db_name, v_tb_name);

    -- check if archived table exists
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'archive' 
        AND table_name = v_archive_table
    ) INTO v_exists;

    -- update log
    IF v_exists THEN
        -- drop original table only if archived table exists
        EXECUTE format('DROP TABLE %I.%I',
            v_db_name, v_tb_name);

        UPDATE metadata.logs
        SET status = 'COMPLETED', end_time = NOW()
        WHERE log_id = v_log_id;
    ELSE
        UPDATE metadata.logs
        SET status = 'FAILED',
            end_time = NOW(),
            err_msg = 'Archiving failed: ' || v_db_name || '.' || v_tb_name || ' -> ' || 'archive.' || v_archive_table
        WHERE log_id = v_log_id;
    END IF;

EXCEPTION WHEN OTHERS THEN
    -- update log on failure
    UPDATE metadata.logs
    SET status = 'FAILED', end_time = NOW(), err_msg = SQLERRM
    WHERE log_id = v_log_id;

END$$;
