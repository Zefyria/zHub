CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS sims4;

DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'sims4', 'challenge_tracker', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS sims4.challenge_tracker;

    CREATE TABLE sims4.challenge_tracker (
         tracker_id                 SERIAL PRIMARY KEY
        ,sim_id                     INTEGER NOT NULL
        ,feature_id                 INTEGER NOT NULL
        ,level                      INTEGER
        ,max_flags                  CHAR(1)                 -- 'Y' = feature reached max level, 'N' = can still level up, NULL = N/A
        ,FOREIGN KEY (sim_id) REFERENCES sims4.challenge_sim(sim_id)
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
