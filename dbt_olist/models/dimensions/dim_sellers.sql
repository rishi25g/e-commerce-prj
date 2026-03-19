{{ config(materialized='table') }}

-- Standardize geolocation info if needed
with geo_summary as (
    select
        geolocation_zip_code_prefix as zip_prefix,
        avg(geolocation_lat) as latitude_center,
        avg(geolocation_lng) as longitude_center
    from {{ source('dbt_olist', 'geolocation') }}
    group by geolocation_zip_code_prefix
),

-- Bring in snapshot history for sellers
seller_versions as (
    select
        dbt_scd_id as seller_scd_key,
        seller_id,
        seller_zip_code_prefix,
        initcap(trim(seller_city)) as seller_city,
        upper(trim(seller_state)) as seller_state,
        dbt_valid_from,
        dbt_valid_to
    from {{ ref('seller_snapshot') }}
)

select
    sv.seller_scd_key,
    sv.seller_id,
    sv.seller_zip_code_prefix,
    sv.seller_city,
    sv.seller_state,
    gs.latitude_center as seller_latitude,
    gs.longitude_center as seller_longitude,
    sv.dbt_valid_from as record_valid_from,
    sv.dbt_valid_to as record_valid_to

from seller_versions sv

left join geo_summary gs
    on sv.seller_zip_code_prefix = gs.zip_prefix