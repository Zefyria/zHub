DROP TABLE IF EXISTS metadata.logs;

CREATE TABLE metadata.logs (
     log_id         SERIAL PRIMARY KEY
    ,job_name       VARCHAR(100) NOT NULL
    ,db_name        VARCHAR(100) NOT NULL
    ,tb_name        VARCHAR(100) NOT NULL
    ,status         VARCHAR(20)
    ,start_time     TIMESTAMP NOT NULL
    ,end_time       TIMESTAMP
    ,err_msg        TEXT
)
;