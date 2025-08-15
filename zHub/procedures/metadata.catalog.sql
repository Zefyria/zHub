DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- Insert start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'metadata', 'catalog', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    -- If metadata.catalog exists, archive it into staging.catalog
    IF EXISTS (SELECT 1 FROM information_schema.tables 
               WHERE table_schema = 'metadata' AND table_name = 'catalog') THEN
        -- Drop staging.catalog if exists to avoid conflict
        IF EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_schema = 'staging' AND table_name = 'catalog') THEN
            EXECUTE 'DROP TABLE staging.catalog';
        END IF;

        -- Create a copy of metadata.catalog in staging
        EXECUTE 'CREATE TABLE staging.catalog AS TABLE metadata.catalog';
    END IF;

    -- Drop the original metadata.catalog
    DROP TABLE IF EXISTS metadata.catalog;

    -- Create fresh metadata.catalog
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

    -- Update log on success
    UPDATE metadata.logs
    SET status = 'COMPLETED', end_time = NOW()
    WHERE log_id = v_log_id;

EXCEPTION WHEN OTHERS THEN
    -- Update log on failure
    UPDATE metadata.logs
    SET status = 'FAILED', end_time = NOW(), err_msg = SQLERRM
    WHERE log_id = v_log_id;

END$$;
