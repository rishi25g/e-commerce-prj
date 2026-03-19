# E-Commerce Data Analysis Project

## Overview
In this project, as part of the data-engineering team, you are tasked to build an end-to-end data pipeline and analysis workflow for a company. You'll start with raw data files, load them into a data warehouse, perform ELT processes, ensure data quality, and analyze the data in Python.

### Target Audience
We will present the project solution, key findings, and data-driven business recommendations to a mixed audience of business (e.g., CEO, CMO) and technical (e.g., CTO, VP of Engineering) executives. This presentation would translate the technical work and data analysis into a compelling business narrative.

## Our project must demonstrate
● Data modeling maturity

● ELT pipeline thinking

● Incremental processing

● Performance optimization

● Data quality handling

● production_style architecture

● Clear documentation

## Project Brief
Designed and implemented a scalable ELT data warehouse in BigQuery for a multi-source e-commerce dataset. Modeled 9 raw tables into a multi-fact star schema with partioned and clustered fact tables, enabling advanced analytics including revenue KPIs, customer lifetime value, and delivery performance analysis.
Final Architecture using BigQuery on Google Cloud platform
● CSV files (Cloud storage)

● BigQuery Raw dataset (staging layer - data cleaning)

● Transform Layer - snapshots -(Dimensions- SCD Type2)

● Mart Layer (Fact Tables-star schema)

● Data Quality checks using Great Expectations

● BI/Analytics

What Makes This “Data Engineer” Level?
Instead of just writing SQL, we use:

### Data Modeling
● Star schema

● Surrogate keys

● SCD Type 2 handling

● Grain definition

How dbt Handles SCD Automatically

After running:

dbt snapshot

dbt automatically creates metadata columns:
dbt_scd_id
dbt_updated_at
dbt_valid_from
dbt_valid_to



### Data Engineering Concepts
● Incremental loads

● Idempotent pipelines

● Hash-based change detection

● Partitioning & clustering

● Late-arriving dimensions

● Data quality validation

## Scalability Thinking
### BigQuery best practices:

● Partition on effective_start_date

● Cluster on business keys

● Avoid full table scans

● Use MERGE safely

● Reduce shuffle joins

### Technical Depth We Should Explain - Why BigQuery?
Because:
Serverless

Columnar storage

Automatic scaling

Good for analytics workloads

Key Note:

Implemented warehouse on Google BigQuery using partitioned and clustered tables for cost-efficient analytics.

## BUSINESS PROCESS
Main process E-commerce Orders
1 row per order item

This is correct because:

● one order can have multiple products

● Each product can have different sellers

● Each has its own frieght and price

## STAR SCHEMA DESIGN
### DIMENSION TABLES
dim_customer
dim_product
dim_seller
dim_date
dim_payment_type
dim_geolocation
### FACT TABLES
fact_order_items (main revenue table)
fact_payments
fact_reviews
# Complete dbt project folder structure




## 3. ETL & DBT Workflow

### **ETL Flow**

Raw CSV Files → BigQuery → DBT Staging → Snapshots → Dimension/Fact Tables → Data Quality(Great Expectations) → Python Analysis → Plots/Reports


### DBT Flow Diagram
    +---------------------+
    |   Raw CSV Files     |
    +----------+----------+
               |
               v
    +---------------------+
    |  BigQuery Load      |
    +----------+----------+
               |
               v
    +---------------------+
    |   DBT Staging       |
    +----------+----------+
               |
               v
    +---------------------+
    |    Snapshots        |
    +----------+----------+
               |
               v
    +---------------------+
    |  DBT Models         |
    |  - Dimensions       |
    |  - Facts            |
    +----------+----------+
               |
               v
    +---------------------+
    | Data Qualitychecks  |
    +----------+----------+
               |
               v
    +---------------------+
    | Python Analysis     |
    +---------------------+

    
---

## 4. Schema Diagram
             +------------------+
             |   Customers      |
             | customer_id (PK) |
             +--------+---------+
                      |
                      v
             +------------------+
             |    Orders        |
             | order_id (PK)    |
             | customer_id (FK) |
             +--------+---------+
                      |
                      v
             +------------------+
             |  Order_Items     |
             | order_item_id(PK)|
             | order_id (FK)    |
             | product_id (FK)  |
             +--------+---------+
                      |
                      v
             +------------------+
             |   Products       |
             | product_id (PK)  |
             | product_name     |
             | category_name    |
             +--------+---------+
                      |
                      v
             +------------------+
             | Category Translation |
             | product_category_name_english |
             +------------------+




---

## 5. Analysis Steps

1. **Load Cleaned CSVs**
    ```python
    import pandas as pd
    orders = pd.read_csv("data/olist_orders_clean.csv")
    order_items = pd.read_csv("data/olist_order_items_clean.csv")
    products = pd.read_csv("data/olist_products_clean.csv")
    customers = pd.read_csv("data/olist_customers_clean.csv")
    category_translation = pd.read_csv("data/olist_product_category_translation.csv")
    ```

2. **Merge Data**
    - Orders + Order Items → product-level orders  
    - Add product details + English category name  

3. **Top-Selling Product Categories/ Top Performing states**
    - Count by `product_category_name_english`  
    - Plot top 10 categories  

    ![Top Categories](presentation/top_categories.png)

4. **Monthly Sales Trends**
    - Aggregate orders by month  
    - Plot trends  

    ![Monthly Sales](presentation/monthly_sales_trends.png)

5. **Customer Segmentation**
    - Compute `total_orders` and `total_spend` per customer  
    -  plot segmentation  

    ![Customer Segmentation](presentation/customer_segmentation.png)

---

## 6. Insights & Recommendations

- **Top Categories:** Bed & Bath, Health & Beauty, Sports & Leisure  
- **Monthly Sales Trends:** Peaks indicate seasonal sales periods  
- **Customer Segmentation:** High-value customers identified for marketing  
- **Data Design:** Cleaned CSV + English category names make reports and analysis consistent

---

## 7. Tools & Justification

| Tool | Purpose |
|------|---------|
| Python + Pandas | Data processing, merging, analysis |
| Matplotlib / Seaborn | Charts & visualization |
| BigQuery | Centralized raw data storage |
| DBT | Modular transformations, snapshots, dimensions/facts |
| Great Expectations | Data quality validation |
| Draw.io  | Pipeline & schema visualization |

---

## 8. How to Run

1. Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
2. Run the analysis script:
    ```bash
    python myinsight.py
    ```
3. Check `presentation/` for generated charts and images

---

## 9. Requirements (`requirements.txt`)

python 3.11... and its libraries like pandas, numpy, matplotlib, seaborn

dbt requirement.txt




## 10. My customer value data is clearly right scewed

(dtype='object') count 98660.000000 mean 129.149770 std 193.633307 min 0.850000 25% 43.800000 50% 79.900000 75% 144.900000 max 6735.000000 Name: price, dtype: float64()

output analysis for customer value
mean   = 129
median = 79.9
max    = 6735

Key Observations
1. Mean > Median

 129 > 79.9

 This means a few large values are pulling the average up
 Classic sign of right skew

2. Huge gap between median and max

 79.9 → 6735

 Some customers spend extremely high amounts
 Long tail on the right side

3. Standard deviation is large

 std = 193

 High variation → another skew indicator

 Final Conclusion
 YES —  data is HIGHLY RIGHT-SKEWED

 Best for presentation 
 Easy to understand
 Business-friendly
 Clean visualization

 Note: Academic project for learning purpose 