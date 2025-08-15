import pandas as pd
import os

# Full path to the Excel file
excel_file = r"C:\Users\Zef\Downloads\NAPLAN national results dataset.xlsx"

# Check if file exists
if not os.path.isfile(excel_file):
    print(f"ERROR: File does not exist: {excel_file}")
else:
    print(f"File found: {excel_file}\n")

    # Load Excel file
    xls = pd.ExcelFile(excel_file)

    # Print all sheet names
    print("Sheets available:", xls.sheet_names)

    # Read the first sheet (default)
    df = pd.read_excel(excel_file, sheet_name=xls.sheet_names[0])

    # Show column names
    print("\nColumn Names:")
    print(df.columns.tolist())

    # Show first 10 rows
    print("\nFirst 10 Rows:")
    print(df.head(10))
