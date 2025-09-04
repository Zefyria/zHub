CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS scholarlib;

DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'scholarlib', 'engagement', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS scholarlib.engagement;

    CREATE TABLE scholarlib.engagement (
         eng_id                     SERIAL PRIMARY KEY
        ,pub_id                     INTEGER
        ,eng_date                   DATE
        ,status                     TEXT -- 'skimmed', 'read', 'cited', 'recommended', 'bookmarked', 'downloaded'
        ,read_on                    DATE
        ,summarised_on              DATE
        ,summary                    TEXT
        ,notes                      TEXT
        ,tags                       TEXT[]
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
