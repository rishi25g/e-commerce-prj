{{ config(materialized='table') }}

-- Dimension table from product snapshot (SCD Type-2)
with product_history as (
    select
        dbt_scd_id as product_scd_key,
        product_id,
        product_category_name,
        product_name_lenght,         -- keep same if snapshot has typo
        product_description_lenght,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        dbt_valid_from,
        dbt_valid_to
    from {{ ref('product_snapshot') }}
)

select
    ph.product_scd_key,
    ph.product_id,
    ph.product_category_name,
    ph.product_name_lenght,
    ph.product_description_lenght,
    ph.product_photos_qty,
    ph.product_weight_g,
    ph.product_length_cm,
    ph.product_height_cm,
    ph.product_width_cm,
    ph.dbt_valid_from as record_valid_from,
    ph.dbt_valid_to as record_valid_to

from product_history ph


-- Grain: 1 row per product
-- Includes translated category name