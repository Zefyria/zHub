/*
find feature_id by name or type
*/

SELECT *
FROM sims4.addon_feature
--WHERE feature_id = 6
WHERE feature_name LIKE '%Wiggly%'
--WHERE feature_type LIKE '%%'
;