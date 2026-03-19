{% snapshot seller_snapshot %}
{{
    config(
        target_schema='snapshots',
        unique_key='seller_id',
        strategy='check',
        check_cols=['seller_city', 'seller_zip_code_prefix', 'seller_state'],
        invalidate_hard_deletes=True
    )
}}

select
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
from {{ source('dbt_olist', 'sellers') }}

{% endsnapshot %}