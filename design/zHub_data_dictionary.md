# Structure
```
zHub
│
├── raw
│	└── naplan_2025_results
│
├── staging							# temporary space for staging data
│
├── core
│
├── sims4
|	├── addon						# list of packs and kits with USA PC release date
|	├── addon_feature				# features introduced by addon
|	├── addon_integration			# integration with earlier addons
|	├── feature_limitation			# feature limitation by Sim life stage/state
|	└── owned						# flag = I own the sims4 addon
│
├── metadata
|	├── catalog
|	├── ingest_csv_headers          # for when an ingested csv's header row does not match db column names
|	└── logs
|
└── archive
	└── govhack2025_datasets
```

