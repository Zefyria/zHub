/* returns all sims in a challenge with their progress */

SELECT
    c.challenge_name
    ,s.first_name
    ,s.last_name
    ,f.feature_type
    ,f.feature_name
    ,t.level
    ,t.max_flags
FROM sims4.challenge AS c
INNER JOIN sims4.challenge_sim AS s
ON c.challenge_id = s.challenge_id
INNER JOIN sims4.challenge_tracker AS t
ON s.sim_id = t.sim_id
INNER JOIN sims4.addon_feature AS f
ON t.feature_id = f.feature_id
WHERE c.challenge_id = 1 -- "Completionist"
ORDER BY t.tracker_id ASC -- chronological order as added to tracker
;

SELECT DISTINCT
     'earned' AS status
    ,COUNT(feature_id)
FROm sims4.challenge_tracker
WHERE sim_id = 1

UNION ALL

SELECT DISTINCT
     'available' AS status
    ,COUNT(feature_id)
FROM sims4.addon_feature
;
