import pandas as pd
import os
import numpy as np

# Path to your CSV file
csv_file = r"C:\Users\Zef\Downloads\zRepo.Sims4\Sims4.owned.csv"

# Check if file exists
if not os.path.isfile(csv_file):
    print(f"ERROR: File does not exist: {csv_file}")
    exit()

# Read CSV
df = pd.read_csv(csv_file)

print(f"CSV loaded: {csv_file}\n")

# Function to suggest PostgreSQL type
def suggest_pg_type(series):
    if pd.api.types.is_integer_dtype(series):
        return "INTEGER"
    elif pd.api.types.is_float_dtype(series):
        # get max number of decimals
        decimals = series.dropna().apply(lambda x: len(str(x).split(".")[1]) if "." in str(x) else 0)
        max_decimals = decimals.max() if not decimals.empty else 0
        return f"NUMERIC(20,{max_decimals})"
    else:
        max_len = series.dropna().astype(str).apply(len).max()
        return f"VARCHAR({max_len})" if max_len else "VARCHAR(50)"

# Show column info
print(f"{'Column':<30} {'Suggested PG Type':<20} {'Max Length / Decimals':<20}")
print("-"*70)

for col in df.columns:
    series = df[col]
    pg_type = suggest_pg_type(series)
    if "VARCHAR" in pg_type:
        max_len = series.dropna().astype(str).apply(len).max()
        print(f"{col:<30} {pg_type:<20} {max_len}")
    elif "NUMERIC" in pg_type:
        decimals = series.dropna().apply(lambda x: len(str(x).split(".")[1]) if "." in str(x) else 0)
        max_decimals = decimals.max() if not decimals.empty else 0
        print(f"{col:<30} {pg_type:<20} {max_decimals}")
    else:
        print(f"{col:<30} {pg_type:<20} N/A")

# Optionally, show first 5 rows
print("\nFirst 5 rows of data:")
print(df.head())
