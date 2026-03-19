{{ config(materialized='view') }}

select *
from {{ source('dbt_olist', 'orders') }}