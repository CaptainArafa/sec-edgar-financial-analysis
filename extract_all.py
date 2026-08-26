import os
import zipfile

raw_zips_dir = os.path.join("data", "raw_zips")
unzipped_dir = os.path.join("data", "unzipped")

os.makedirs(unzipped_dir, exist_ok=True)

# Find all zip files in raw_zips
zip_files = [f for f in os.listdir(raw_zips_dir) if f.endswith(".zip")]
print(f"=== Found {len(zip_files)} ZIP archives to extract ===")

for zip_filename in sorted(zip_files):
    quarter_name = os.path.splitext(zip_filename)[0]  # e.g., '2020q1'
    zip_path = os.path.join(raw_zips_dir, zip_filename)
    target_folder = os.path.join(unzipped_dir, quarter_name)
    
    if not os.path.exists(target_folder):
        print(f"[+] Extracting {zip_filename} ...")
        with zipfile.ZipFile(zip_path, "r") as z:
            z.extractall(target_folder)
        print(f"    -> Unpacked to {target_folder}")
    else:
        print(f"[*] {quarter_name} already extracted. Skipping.")

print("\n=== All extractions complete ===")