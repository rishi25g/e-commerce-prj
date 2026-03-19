{{ config(materialized='table') }}

-- Dim Dates: A complete date dimension for time-based analysis
-- Generates dates dynamically from 2015-01-01 to today

with date_range as (
    select day as full_date
    from unnest(generate_date_array(date '2015-01-01', current_date())) as day
)

select
    full_date as date_key,                          -- primary key for joins
    extract(year from full_date) as year,
    extract(quarter from full_date) as quarter,
    extract(month from full_date) as month,
    extract(day from full_date) as day,
    extract(dayofweek from full_date) as day_of_week,
    format_date('%B', full_date) as month_name,    -- full month name
    format_date('%A', full_date) as day_name,      -- day of week name
    case when extract(dayofweek from full_date) in (1,7) then true else false end as is_weekend
from date_range
where full_date <= current_date()
order by full_date

-- Grain: 1 row per date
-- Safe for aggregations over time
-- Scans stg_orders once to get min/max order date