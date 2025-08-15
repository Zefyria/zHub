import pandas as pd
import os

# Full path to the Excel file
excel_file = r"C:\Users\Zef\Downloads\NAPLAN national results dataset.xlsx"

# Check if file exists
if not os.path.isfile(excel_file):
    print(f"ERROR: File does not exist: {excel_file}")
else:
    print(f"File found: {excel_file}\n")

    # Read all sheets into a dictionary of DataFrames
    all_sheets = pd.read_excel(excel_file, sheet_name=None)

    # Process each sheet
    for sheet_name, df in all_sheets.items():
        print(f"Processing Sheet: {sheet_name}")
        
        # Print column names
        print("Columns:", df.columns.tolist())
        
        # Print first 5 rows
        print(df.head(5), "\n")
        
        # Clean sheet name for filename (remove/replace spaces and special chars)
        safe_name = sheet_name.replace(" ", "_").replace("/", "_")
        csv_file = os.path.join(r"C:\Users\Zef\Downloads", f"{safe_name}.csv")
        
        # Save sheet as CSV
        df.to_csv(csv_file, index=False)
        print(f"Saved CSV: {csv_file}\n")
