import os
import pandas as pd
from sqlalchemy import create_engine

engine = create_engine(
    "postgresql://postgres:7676@localhost:5432/sec_edgar_db"
)
DATA_DIR = r"C:\Users\Youssef Arafa\Desktop\SEC_Project\data"

files_to_load = [
    ("tag.txt", "tag"),
    ("num.txt", "num"),
    ("pre.txt", "pre"),
]

for file_name, table_name in files_to_load:
  file_path = os.path.join(DATA_DIR, file_name)
  print(f"Streaming {file_name} into '{table_name}'...")

  # Read and insert in chunks to prevent memory crashes
  for i, chunk in enumerate(
      pd.read_csv(file_path, sep="\t", low_memory=False, chunksize=50000)
  ):
    chunk.to_sql(
        table_name,
        engine,
        if_exists="replace" if i == 0 else "append",
        index=False,
    )
    print(f"Loaded chunk {i+1} for {table_name}")

print("All remaining tables successfully loaded!")