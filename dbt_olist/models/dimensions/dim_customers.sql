{{ config(materialized='table') }}

-- Compute representative coordinates for each zip code
with geo_summary as (

    select
        geolocation_zip_code_prefix as zip_prefix,
        avg(geolocation_lat) as latitude_center,
        avg(geolocation_lng) as longitude_center
    from {{ source('dbt_olist', 'geolocation') }}
    group by geolocation_zip_code_prefix

),

-- Bring in snapshot history for customers
customer_versions as (

    select
        dbt_scd_id as customer_scd_key,
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        dbt_updated_at,
        dbt_valid_from,
        dbt_valid_to
    from {{ ref('customer_snapshot') }}

)

select
    cv.customer_scd_key,
    cv.customer_id,
    cv.customer_unique_id,
    cv.customer_zip_code_prefix,
    cv.customer_city,
    cv.customer_state,
    gs.latitude_center as customer_latitude,
    gs.longitude_center as customer_longitude,
    cv.dbt_valid_from as record_valid_from,
    cv.dbt_valid_to as record_valid_to

from customer_versions cv

left join geo_summary gs
    on cv.customer_zip_code_prefix = gs.zip_prefix


-- Grain: 1 row per customer
-- Primary key: customer_id

-- Cleaning & enrichment:
-- Standardized city capitalization (initcap)
-- State codes uppercased (upper)
-- Minimal null handling assumed (could add coalesce if needed)