import psycopg2
import requests

print("=== Fetching Official SEC Ticker Mappings ===")

DB_SETTINGS = {
    "dbname": "sec_edgar_db",
    "user": "postgres",
    "password": "7676",
    "host": "localhost",
    "port": "5432"
}

url = "https://www.sec.gov/files/company_tickers.json"
headers = {"User-Agent": "Youssef Arafa student@guc.edu.eg"}

res = requests.get(url, headers=headers)
if res.status_code != 200:
    raise Exception(f"Failed to fetch SEC tickers: Status {res.status_code}")

data = res.json()

conn = psycopg2.connect(**DB_SETTINGS)
cursor = conn.cursor()

# Ensure ticker column and index exist
cursor.execute("ALTER TABLE dim_company ADD COLUMN IF NOT EXISTS ticker VARCHAR(10);")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_dim_company_ticker ON dim_company(ticker);")
conn.commit()

print("Updating dim_company table with ticker symbols...")

for item in data.values():
    ticker = item["ticker"]
    raw_cik = str(item["cik_str"]).lstrip('0')  # Unpadded e.g. '320193'
    padded_cik = raw_cik.zfill(10)               # Padded e.g. '0000320193'
    
    cursor.execute(
        """
        UPDATE dim_company 
        SET ticker = %s 
        WHERE LTRIM(CAST(cik AS TEXT), '0') = %s 
           OR cik = %s 
           OR cik = %s;
        """,
        (ticker, raw_cik, raw_cik, padded_cik)
    )

conn.commit()

# Verify total tickers populated
cursor.execute("SELECT COUNT(*) FROM dim_company WHERE ticker IS NOT NULL;")
total_mapped = cursor.fetchone()[0]

cursor.close()
conn.close()

print(f"=== Successfully mapped {total_mapped:,} company tickers ===")