-- This tells dbt to create a table in BigQuery (not a view).
-- For fact tables, table is good if your dataset is moderately large; 
-- for huge tables, you might use incremental.

{{ config(materialized='table') }}

with order_items as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        price,
        freight_value
    from {{ ref('stg_order_items') }}

),

orders as (

    select
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date
    from {{ ref('stg_orders') }}

),

customer_history as (

    select
        dbt_scd_id,
        customer_id,
        dbt_valid_from,
        dbt_valid_to
    from {{ ref('customer_snapshot') }}

),

seller_history as (

    select
        dbt_scd_id,
        seller_id,
        dbt_valid_from,
        dbt_valid_to
    from {{ ref('seller_snapshot') }}

),

product_dim as (

    select
        product_id,
        product_category_name,
        --product_category_name_english
    from {{ ref('dim_products') }}

)

select

    -- Order grain
    oi.order_id,
    oi.order_item_id,

    -- Dimension surrogate keys
    ch.dbt_scd_id as customer_scd_id,
    sh.dbt_scd_id as seller_scd_id,

    -- Product attributes
    oi.product_id,
    p.product_category_name,
    --p.product_category_name_english,

    -- Order attributes
    o.order_status,
    timestamp(o.order_purchase_timestamp) as order_purchase_timestamp,
    timestamp(o.order_approved_at) as order_approved_at,
    timestamp(o.order_delivered_carrier_date) as order_delivered_carrier_date,
    timestamp(o.order_delivered_customer_date) as order_delivered_customer_date,
    timestamp(o.order_estimated_delivery_date) as order_estimated_delivery_date,

    -- Metrics
    cast(oi.price as float64) as price,
    cast(oi.freight_value as float64) as freight_value,
    cast(oi.price as float64) + cast(oi.freight_value as float64) as total_order_value

from order_items oi

left join orders o
    on oi.order_id = o.order_id

left join product_dim p
    on oi.product_id = p.product_id

-- Customer SCD join
left join customer_history ch
    on o.customer_id = ch.customer_id
    and timestamp(o.order_purchase_timestamp) >= ch.dbt_valid_from
    and (
        timestamp(o.order_purchase_timestamp) < ch.dbt_valid_to
        or ch.dbt_valid_to is null
    )

-- Seller SCD join
left join seller_history sh
    on oi.seller_id = sh.seller_id
    and timestamp(o.order_purchase_timestamp) >= sh.dbt_valid_from
    and (
        timestamp(o.order_purchase_timestamp) < sh.dbt_valid_to
        or sh.dbt_valid_to is null
    )

    
-- Grain: 1 row per order item (typical for e-commerce fact tables).
-- All joins use ref() → dbt will build models in correct order.
-- Materialization: table → stored as a BigQuery table in your mart dataset.
-- Dimensions referenced here (dim_products, dim_customers, dim_sellers) must exist before running this fact table.



-- Check
-- Grain: Each row represents one order item → good.
-- All joins are LEFT JOIN → ensures fact table keeps all order items even if dimension info is missing. 
-- Referencing: Uses ref() → correct dbt practice. 
-- Dimensional integrity: Joins dimensions correctly using foreign keys (customer_id, product_id, seller_id). 