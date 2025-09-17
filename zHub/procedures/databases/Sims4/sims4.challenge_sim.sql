CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS sims4;

DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'sims4', 'challenge_sim', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS sims4.challenge_sim;

    CREATE TABLE sims4.challenge_sim (
         sim_id                     INTEGER PRIMARY KEY
        ,challenge_id               INTEGER
        ,first_name                 VARCHAR(255)
        ,last_name                  VARCHAR(255)
        ,parent1_id                 INTEGER
        ,parent2_id                 INTEGER                 -- NULL implies CAS or world-generated Sim
        ,FOREIGN KEY (challenge_id) REFERENCES sims4.challenge(challenge_id)
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
