CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS raw;

DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'raw', 'NAPLAN_2025_Results', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS raw.NAPLAN_2025_Results;

    CREATE TABLE raw.NAPLAN_2025_Results (
         calendar_year                      INTEGER
        ,year_level                         INTEGER
        ,domain                             VARCHAR(50)
        ,state_territory                    VARCHAR(50)
        ,student_attribute                  VARCHAR(50)
        ,subgroup                           VARCHAR(50)
        ,reporting_flag                     VARCHAR(10)
        ,enrolled_students                  NUMERIC(20,1)
        ,participation_percent              NUMERIC(21,16)
        ,participation_num                  NUMERIC(21,16)
        ,average_naplan_score               NUMERIC(21,16)
        ,average_naplan_score_ci            NUMERIC(21,16)
        ,naplan_score_stddev                NUMERIC(21,16)
        ,exempt_percent                     NUMERIC(21,16)
        ,needs_additional_support_percent   NUMERIC(21,16)
        ,developing_percent                 NUMERIC(21,16)
        ,strong_percent                     NUMERIC(21,16)
        ,exceeding_percent                  NUMERIC(21,16)
        ,exceeding_ci                       NUMERIC(21,16)
        ,strong_or_above_percent            NUMERIC(21,16)
        ,strong_or_above_ci                 NUMERIC(21,16)
        ,developing_or_above_percent        NUMERIC(21,16)
        ,developing_or_above_ci             NUMERIC(21,16)
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
