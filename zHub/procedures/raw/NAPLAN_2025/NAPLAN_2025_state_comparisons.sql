CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS raw;

DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'raw', 'NAPLAN_2025_state_comparisons', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS raw.NAPLAN_2025_state_comparisons;

    CREATE TABLE raw.NAPLAN_2025_state_comparisons (
         calendar_year                      INTEGER
        ,year_level                         INTEGER
        ,domain                             VARCHAR(50)
        ,state_territory                    VARCHAR(50)
        ,base_state_territory               VARCHAR(50)
        ,student_attribute                  VARCHAR(50)
        ,subgroup                           VARCHAR(50)
        ,measure                            VARCHAR(50)
        ,reporting_flag                     VARCHAR(1)
        ,measure_value                      NUMERIC(21,16)
        ,measure_value_ci                   NUMERIC(21,16)
        ,base_value                         NUMERIC(21,16)
        ,base_value_ci                      NUMERIC(21,16)
        ,diff                               NUMERIC(21,16)
        ,diff_ci                            NUMERIC(21,16)
        ,effect_size                        NUMERIC(21,16)
        ,significance_of_diff               INTEGER
        ,nature_of_diff                     INTEGER
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
