CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS Sims4;

DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'Sims4', 'addon', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS Sims4.addon;

    CREATE TABLE Sims4.addon (
         addon_id                       INTEGER
        ,addon_name                     VARCHAR(50)
        ,addon_type                     VARCHAR(25)     CHECK (addon_type IN ('Base Game','Creator Kit','Event','Expansion Pack','Free Pack','Game Pack','Kit','Stuff Pack'))
        ,release_date                   DATE
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
