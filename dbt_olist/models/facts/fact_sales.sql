SELECT

    {{ dbt_utils.generate_surrogate_key([
        'oi.order_id',
        'oi.product_id'
    ]) }} AS sales_id,

    oi.order_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,

    o.order_purchase_timestamp,

    oi.price,
    oi.freight_value,

    oi.price + oi.freight_value AS total_sale_amount   -- one of our requirement in step 3
    -- This gives you the total value for each product line, which is now ready for aggregation.
FROM {{ ref('stg_order_items') }} oi
JOIN {{ ref('stg_orders') }} o
ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered'


-- filter invalid orders like canceled or unavailable