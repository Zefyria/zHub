/*
add a sim to a challenge
challenge_id = 1    "Completionist"
sim_id = 1          "John Allworth"
sim_id = 2          "Jane Allworth"
sim_id = 3          "Chris Allworth"
*/

INSERT INTO sims4.challenge_sim (challenge_id,first_name,last_name,parent1_id,parent2_id)
VALUES (
    -- sims_id INTEGER
     3
    -- challenge_id INTEGER
    ,1
    -- first_name VARCHAR(255)
    ,'Chris'
    -- last_name VARCHAR(255)
    ,'Allworth'
    -- parent1_id INTEGER
    ,1
    -- parent2_id INTEGER
    ,2
);

