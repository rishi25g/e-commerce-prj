{{ config(materialized='table') }}

with payments as (

    select
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    from {{ ref('stg_payments') }}

),

orders as (

    select
        order_id,
        customer_id,
        order_purchase_timestamp
    from {{ ref('stg_orders') }}

),

customer_history as (

    select
        dbt_scd_id,
        customer_id,
        customer_city,
        customer_state,
        dbt_valid_from,
        dbt_valid_to
    from {{ ref('customer_snapshot') }}

)

select

    -- fact grain
    p.order_id,
    p.payment_sequential as payment_id,

    -- surrogate key from snapshot
    ch.dbt_scd_id as customer_scd_id,

    -- payment attributes
    p.payment_type,
    p.payment_installments,
    cast(p.payment_value as float64) as payment_value,

    -- customer attributes at time of order
    ch.customer_city,
    ch.customer_state,

    -- timestamp reference
    timestamp(o.order_purchase_timestamp) as order_purchase_timestamp

from payments p

left join orders o
    on p.order_id = o.order_id

-- SCD Type 2 join
left join customer_history ch
    on o.customer_id = ch.customer_id
    and timestamp(o.order_purchase_timestamp) >= ch.dbt_valid_from
    and (
        timestamp(o.order_purchase_timestamp) < ch.dbt_valid_to
        or ch.dbt_valid_to is null
    )

-- Grain: 1 row per payment
-- Includes customer_id and purchase timestamp for analysis