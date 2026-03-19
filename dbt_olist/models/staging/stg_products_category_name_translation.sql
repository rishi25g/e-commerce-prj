{{ config(materialized='table') }}

-- Staging table for product category translation
select
    product_category_name,
    product_category_name_english
from {{ source('dbt_olist', 'products_category_name_translation') }}