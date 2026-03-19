# Step 1: Import libraries
import os
import pandas as pd
import matplotlib.pyplot as plt

import seaborn as sns

# Step 2: Load cleaned CSVs
orders = pd.read_csv("data/olist_orders_clean.csv")
customers = pd.read_csv("data/olist_customers_clean.csv")
order_items = pd.read_csv("data/olist_order_items_clean.csv")
products = pd.read_csv("data/olist_products_clean.csv")
category_translation = pd.read_csv("data/product_category_name_translation.csv")

# Convert date columns to datetime
orders['order_purchase_timestamp'] = pd.to_datetime(orders['order_purchase_timestamp'])
orders['order_delivered_customer_date'] = pd.to_datetime(orders['order_delivered_customer_date'])
orders['order_estimated_delivery_date'] = pd.to_datetime(orders['order_estimated_delivery_date'])

# Step 3: Merge orders with customers for analysis
orders_customers = orders.merge(customers, on='customer_id', how='left')
# Merge order_items with products to get product details
order_products = order_items.merge(products, on='product_id', how='left')

# Merge order_products with the translation CSV on 'product_category_name'
order_products = order_products.merge(
    category_translation, 
    on='product_category_name', 
    how='left'
)
order_products = order_products.merge(
    orders[['order_id', 'customer_id', 'order_purchase_timestamp']],
    on="order_id",
    how="left"
)

customers_full = pd.read_csv("data/olist_customers_clean.csv")

order_products = order_products.merge(
    customers_full[['customer_id', 'customer_state']],
    on="customer_id",
    how="left"
)
#print(order_products.columns)

# Step 4: Monthly Sales Trends
orders_customers['order_month'] = orders_customers['order_purchase_timestamp'].dt.to_period('M')
monthly_sales = orders_customers.groupby('order_month')['order_id'].count()

# Plot
plt.figure(figsize=(12,5))
monthly_sales.plot(kind='line', marker='o')
plt.title('Monthly Sales Trends')
plt.xlabel('Month')
plt.ylabel('Number of Orders')
plt.xticks(rotation=45)
plt.show()
#plt.savefig("monthly_sales.png", bbox_inches='tight')

# Step 5: Top-Selling Products
# Count orders per product category
# Count orders per English category
top_categories = order_products.groupby('product_category_name_english')['order_id'] \
                               .count() \
                               .sort_values(ascending=False) \
                               .head(10)

#print("Top 10 Product Categories Sold (English):")
#print(top_categories)

print("Top 10 Product Categories Sold:")
print(top_categories)

# step 6: plot pictures
plt.figure(figsize=(12,6))
top_categories.plot(kind='barh')
plt.title('Top 10 Product Categories Sold (English)')
plt.xlabel('Number of Orders')
plt.gca().invert_yaxis()  # largest on top
plt.show()
#plt.savefig("Top selling products", bbox_inches='tight')

# Step 6: Customer Segmentation by Purchase Behavior
customer_stats = orders_customers.groupby('customer_id').agg({
    'order_id': 'count',
    'order_purchase_timestamp': 'max'
}).rename(columns={'order_id': 'total_orders', 'order_purchase_timestamp': 'last_order_date'})

# Segmentation
def segment(row):
    if row['total_orders'] >= 10:
        return 'High Value'
    elif row['total_orders'] >= 3:
        return 'Medium Value'
    else:
        return 'Low Value'

customer_stats['segment'] = customer_stats.apply(segment, axis=1)

# Plot
segment_counts = customer_stats['segment'].value_counts()
plt.figure(figsize=(8,5))
segment_counts.plot(kind='bar', color=['green','orange','red'])
plt.title('Customer Segmentation')
plt.ylabel('Number of Customers')
plt.show()
#plt.savefig("customer segmentation", bbox_inches='tight')

# ------------------------------
# 4. Yearly Sales Trend (Top 5 States)
# ------------------------------

# Merge customer location
customers_full = pd.read_csv("data/olist_customers_clean.csv")

order_id = order_products.merge(
    customers_full[['customer_id', 'customer_state']],
    on='customer_id',
    how='left'
) 
#print(customers_full.columns)

# Extract year
order_products['year'] = order_products['order_purchase_timestamp'].dt.year

# Calculate total sales per state
state_sales = order_products.groupby('customer_state')['price'].sum()

# Get top 5 states
top_states = state_sales.sort_values(ascending=False).head(5).index

# Filter only top 5 states
top_state_data = order_products[order_products['customer_state'].isin(top_states)]

# Group by year and state
yearly_state_sales = (
    top_state_data.groupby(['year', 'customer_state'])['price']
    .sum()
    .reset_index()
)

# Pivot for plotting
pivot_table = yearly_state_sales.pivot(index='year', columns='customer_state', values='price')

# Plot
plt.figure(figsize=(12,6))
pivot_table.plot(marker='o')

plt.title("Yearly Sales Trend for Top 5 States")
plt.xlabel("Year")
plt.ylabel("Total Sales")
plt.legend(title="State")
plt.grid(True)

plt.tight_layout()
#plt.savefig("presentation/yearly_sales_top_states.png")
plt.show()

#print("Yearly sales trend plot saved.")

# ------------------------------
# 5. Customer Segmentation (5 Segments)
# ------------------------------

# Calculate total spend per customer
customer_value = (
    order_products.groupby('customer_id')['price']
    .sum()
    .reset_index()
)

# Create 5 segments using quantiles
customer_value['segment'] = pd.cut(
    customer_value['price'],
    bins=[0, 50, 150, 400, 1000, float('inf')],
    labels=['Low','Low-Mid','Mid','High','Premium']
)
#print(customer_value['price'].describe())

# Count customers in each segment
segment_counts = customer_value['segment'].value_counts().sort_index()

# Plot
plt.figure(figsize=(8,6))
segment_counts.plot(kind='bar')

plt.title("Customer Segmentation (5 Value Segments)")
plt.xlabel("Segment")
plt.ylabel("Number of Customers")

plt.xticks(rotation=45)
plt.tight_layout()
#plt.savefig("presentation/customer_segments_5groups.png")
plt.show()

#print("Customer segmentation (5 groups) plot saved.")