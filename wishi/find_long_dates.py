import pandas as pd

# used to find which varchar(8) rows were failing in dim_dates seed
csv = pd.read_csv('seeds/dim_dates.csv')

n=0
for idx, row in csv.iterrows():
    print(idx, type(idx))
    n+=1
    if n>50:
        break

id_cols = [col for col in csv.columns if "_id" in col]

for row in csv.itertuples(index=True):
    idx = row.Index
    for col in id_cols:
        val = getattr(row, col)
        val_str = str(val) if pd.notnull(val) else ""
        if len(val_str) > 8:
            print(f"Row {idx}: column '{col}' has length {len(val_str)} → {val_str!r}")