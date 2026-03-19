{{ config(materialized='view') }}

select *
from {{ source('dbt_olist', 'order_payments') }}