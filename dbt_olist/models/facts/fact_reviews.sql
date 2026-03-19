{{ config(materialized='table') }}

with reviews as (

    select
        review_id,
        order_id,
        review_score,
        review_comment_message,
        review_creation_date,
        review_answer_timestamp
    from {{ ref('stg_reviews') }}

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
    r.review_id,
    r.order_id,

    -- surrogate key
    ch.dbt_scd_id as customer_scd_id,

    -- review attributes
    r.review_score,
    r.review_comment_message,
    timestamp(r.review_creation_date) as review_creation_date,
    timestamp(r.review_answer_timestamp) as review_answer_timestamp,

    -- customer attributes at time of order
    ch.customer_city,
    ch.customer_state

from reviews r

left join orders o
    on r.order_id = o.order_id

-- SCD Type 2 join
left join customer_history ch
    on o.customer_id = ch.customer_id
    and timestamp(o.order_purchase_timestamp) >= ch.dbt_valid_from
    and (
        timestamp(o.order_purchase_timestamp) < ch.dbt_valid_to
        or ch.dbt_valid_to is null
    )

-- Grain: 1 row per review
-- Includes customer_id and purchase date for joining with other facts
-- Review fact joins stg_reviews → dim_customers
-- Materialized as table for repeated analytics queries