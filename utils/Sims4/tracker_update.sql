/*
add a feature to a sim
sim_id = 1          "John Allworth"
sim_id = 2          "Jane Allworth"
sim_id = 3          "Chris Allworth"
*/

INSERT INTO sims4.challenge_tracker (sim_id,feature_id,level,max_flags)
VALUES (
    -- sim_id INTEGER NOT NULL
     3
    -- feature_id INTEGER NOT NULL
    ,104
    -- level INTEGER
    ,NULL
    -- max_flags CHAR(1) 'Y' = feature reached max level, 'N' = can still level up, NULL = N/A
    ,NULL
);
/*
-- update a sim's progress on a feature
UPDATE sims4.challenge_tracker
SET level = 2
WHERE sim_id = 2
AND feature_id = 49
;
*/