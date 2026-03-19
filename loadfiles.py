import os
import pandas as pd
from google.cloud import bigquery
from google.oauth2 import service_account
import warnings
warnings.filterwarnings("ignore", category=FutureWarning)


# -----------------------------
# 1. CONFIGURATION
# -----------------------------
PROJECT_ID = "stellar-state-488004-p8"
DATASET_ID = "olist_data"
CREDENTIALS_PATH = "/home/dsai/e-commerce-prj/keys/stellar-state-488004-p8-7e71d8e2bcb1.json"
DATA_FOLDER = "/home/dsai/e-commerce-prj/data"


# List of CSV files and corresponding BigQuery table names
Filecsv = [
    ("olist_customers_dataset.csv", "customers"),
    ("olist_geolocation_dataset.csv", "geolocation"),
    ("olist_order_items_dataset.csv", "order_items"),
    ("olist_order_payments_dataset.csv", "order_payments"),
    ("olist_order_reviews_dataset.csv", "order_reviews"),
    ("olist_orders_dataset.csv", "orders"),
    ("olist_products_dataset.csv", "products"),
    ("olist_sellers_dataset.csv", "sellers"),
    ("product_category_name_translation.csv", "products_category_name_translation"),
]


# -----------------------------
# 2. AUTHENTICATE TO GCP
# -----------------------------
credentials = service_account.Credentials.from_service_account_file(CREDENTIALS_PATH)

client = bigquery.Client(
    project=PROJECT_ID,
    credentials=credentials
)


# -----------------------------
# 3. CREATE DATASET (IF NOT EXISTS)
# -----------------------------
dataset = bigquery.Dataset(f"{PROJECT_ID}.{DATASET_ID}")
dataset.location = "US"

client.create_dataset(dataset, exists_ok=True)
print(f"Dataset '{DATASET_ID}' is ready.")

# -----------------------------
# 4. LOAD CSV FILES INTO BIGQUERY
# -----------------------------
job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    )

for file_name, table_name in Filecsv:
    file_path = f"{DATA_FOLDER}/{file_name}"
    table_id = f"{PROJECT_ID}.{DATASET_ID}.{table_name}"

    print(f"Loading {file_name} into table {table_name}...")
    # Read CSV
    df = pd.read_csv(file_path, encoding="utf-8-sig")

    # Drop existing table to avoid partitioning/schema conflicts
    client.delete_table(table_id, not_found_ok=True)
    #print(f"Loading {file_name} ... {table_name}")

    # Upload to BigQuery
    job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
    job.result()  # Wait until upload finishes
    table = client.get_table(table_id)
    print(f"Loaded {len(df)} rows into {table_name}")


print("All CSV files loaded successfully!")