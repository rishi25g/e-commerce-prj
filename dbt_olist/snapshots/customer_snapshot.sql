{% snapshot customer_snapshot %}
{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='check',
        check_cols=['customer_city', 'customer_unique_id',
        'customer_zip_code_prefix', 'customer_state'], invalidate_hard_deletes=True
    )
}}

select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
from {{ source('dbt_olist', 'customers') }}

{% endsnapshot %}



# List all the columns you need in your snapshot table.
# Only include columns that matter for your analytics or SCD tracking.
# check_cols still defines which columns trigger a new version row.

# Benefits of Explicit Column Selection
# Avoids unexpected errors if the source table changes.
# Makes snapshots easier to read and maintain.
# Helps dbt docs and lineage show exactly which columns are tracked.
# Improves performance (especially on wide tables).