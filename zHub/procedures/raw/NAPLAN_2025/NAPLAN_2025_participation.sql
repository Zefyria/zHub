CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS raw;

DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'raw', 'NAPLAN_2025_participation', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS raw.NAPLAN_2025_participation;

    CREATE TABLE raw.NAPLAN_2025_participation (
         calendar_year                      INTEGER
        ,year_level                         INTEGER
        ,domain                             VARCHAR(50)
        ,state_territory                    VARCHAR(50)
        ,student_attribute                  VARCHAR(50)
        ,subgroup                           VARCHAR(50)
        ,reporting_flag                     VARCHAR(1)
        ,enrolled_students                  NUMERIC(20,1)
        ,assessed_percent                   NUMERIC(21,16)
        ,exempt_percent                     NUMERIC(21,16)
        ,non_attempt_percent                NUMERIC(21,16)
        ,participation_percent              NUMERIC(21,16)
        ,absent_percent                     NUMERIC(21,16)
        ,withdrawn_percent                  NUMERIC(21,16)
        ,assessed_num                       NUMERIC(21,16)
        ,exempt_num                         NUMERIC(21,16)
        ,non_attempt_num                    NUMERIC(21,16)
        ,participation_num                  NUMERIC(21,16)
        ,absent_num                         NUMERIC(21,16)
        ,withdrawn_num                      NUMERIC(21,16)
        ,average_age                        VARCHAR(50)
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
