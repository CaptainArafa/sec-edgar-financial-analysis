import os
import io
import time
import pandas as pd
import psycopg2

print("=== Resuming SEC Bulk Data Ingestion (Remaining Quarters) ===")

DB_SETTINGS = {
    "dbname": "sec_edgar_db",
    "user": "postgres",
    "password": "7676",  
    "host": "localhost",
    "port": "5432"
}

unzipped_base = os.path.join("data", "unzipped")

# Target only the remaining quarters that failed or were skipped
remaining_quarters = ["2025q4", "2026q1", "2026q2"]

print(f"Resuming ingestion for: {remaining_quarters}")

conn = psycopg2.connect(**DB_SETTINGS)
cursor = conn.cursor()



start_time = time.time()

for idx, q in enumerate(remaining_quarters, start=1):
    q_path = os.path.join(unzipped_base, q)
    
    if not os.path.exists(q_path):
        print(f"[!] Folder {q} not found in {unzipped_base}, skipping.")
        continue

    print(f"\n[{idx}/{len(remaining_quarters)}] Ingesting Quarter: {q} ...")
    
    for tbl, filename in [('sub', 'sub.txt'), ('num', 'num.txt'), ('pre', 'pre.txt')]:
        file_path = os.path.join(q_path, filename)
        
        if os.path.exists(file_path):
            try:
                df = pd.read_csv(file_path, sep='\t', low_memory=False, dtype=str, on_bad_lines='skip')
                
                buffer = io.StringIO()
                df.to_csv(buffer, sep='\t', header=False, index=False, na_rep='')
                buffer.seek(0)
                
                cursor.copy_expert(f"COPY {tbl} FROM STDIN WITH (FORMAT csv, DELIMITER '\t', NULL '')", buffer)
                conn.commit()
                print(f"  -> Successfully loaded {filename} ({len(df):,} rows)")
            except Exception as e:
                conn.rollback()
                print(f"  [!] Error loading {filename} in {q}: {e}")
        else:
            print(f"  [!] Missing {filename} in {q}, skipping.")

cursor.close()
conn.close()

elapsed = round((time.time() - start_time) / 60, 2)
print(f"\n=== Resume Ingestion Complete in {elapsed} minutes ===")