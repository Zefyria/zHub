CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS scholarlib;

DO $$
DECLARE
    v_log_id INT;
BEGIN
    -- start log
    INSERT INTO metadata.logs (job_name, db_name, tb_name, status, start_time)
    VALUES ('CREATE', 'scholarlib', 'publication', 'RUNNING', NOW())
    RETURNING log_id INTO v_log_id;

    DROP TABLE IF EXISTS scholarlib.publication;

    CREATE TABLE scholarlib.publication (
         pub_id                     SERIAL PRIMARY KEY
        ,title TEXT NOT NULL
        ,authors TEXT
        ,year INT
        ,journal TEXT
        ,book_title TEXT
        ,volume TEXT
        ,issue TEXT
        ,pages TEXT
        ,publisher TEXT
        ,doi TEXT
        ,url TEXT
        ,isbn TEXT
        ,issn TEXT
        ,publication_type TEXT      -- 'article', 'book', 'book_chapter', 'thesis', 'dataset', 'report', 'web'
        ,abstract TEXT
        ,language TEXT
        ,file_path TEXT             -- optional: link to PDF or file
        ,pdf_hash TEXT              -- optional: deduplication
        ,added_on TIMESTAMP         DEFAULT now()
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
