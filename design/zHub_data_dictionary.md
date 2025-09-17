# Structure
```
zHub
│
├── raw
│	└── naplan_2025_results
│
├── staging											# temporary space for staging data
│
├── core
│
├── metadata
|	├── catalog
|	├── ingest_csv_headers          				# match ingested csv headers to db column names
|	└── logs
|
├── scholarlib
|	├── publication					# fact table	# publication bibliography
|	└── engagement									# my notes on publications
|
├── sims4
|	├── addon						# fact table	# list of packs and kits with USA PC release date
|	├── addon_feature				# tact table	# features introduced by addon
|	├── addon_integration			# fact table	# integration with earlier addons
|	├── feature_limitation			# fact table	# feature limitation by Sim life stage/state
|	├── owned										# flag = I own the sims4 addon
|	├── challenge									# challenge details
|	├── challenge_sim								# challenge Sim details (linked to sims4.challenge)
|	└── challenge_tracker							# challenge features list (linked to sims4.challenge_sim)
│
└── archive
	└── govhack2025_datasets						# Press Any Key For Answers (PAKFA)
```

