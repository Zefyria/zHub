CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS sims4;

DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'sims4', 'feature_limitation', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS sims4.feature_limitation;

    CREATE TABLE sims4.feature_limitation (
         feature_id                     INTEGER
        ,infant_flag                    VARCHAR(1)
        ,toddler_flag                   VARCHAR(1)
        ,child_flag                     VARCHAR(1)
        ,teen_flag                      VARCHAR(1)
        ,young_adult_flag               VARCHAR(1)
        ,adult_flag                     VARCHAR(1)
        ,elder_flag                     VARCHAR(1)
        ,pregnant_flag                  VARCHAR(1)
        ,vampire_flag                   VARCHAR(1)
        ,spellcaster_flag               VARCHAR(1)
        ,skeleton_flag                  VARCHAR(1)
        ,servo_flag                     VARCHAR(1)
        ,werewolf_flag                  VARCHAR(1)
        ,mermaid_flag                   VARCHAR(1)
        ,fairy_flag                     VARCHAR(1)
        ,except_flag                    VARCHAR(1)
        ,except_desc                    VARCHAR(255)
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
