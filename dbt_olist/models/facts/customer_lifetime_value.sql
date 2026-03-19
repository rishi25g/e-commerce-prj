-- models/marts/facts/customer_lifetime_value.sql
SELECT
    customer_id,
    SUM(total_sale_amount) AS customer_lifetime_value,
    COUNT(DISTINCT order_id) AS total_orders,
    AVG(total_sale_amount) AS avg_order_value,
    MIN(CAST(order_purchase_timestamp AS TIMESTAMP)) AS first_order,
    MAX(CAST(order_purchase_timestamp AS TIMESTAMP)) AS last_order
FROM {{ ref('fact_sales') }}
GROUP BY customer_id


--or if i want monthly clv
-- SELECT
 --   customer_id,
 --   DATE_TRUNC(CAST(order_purchase_timestamp AS TIMESTAMP), MONTH) AS order_month,
--    SUM(total_sale_amount) AS monthly_clv
--FROM {{ ref('fact_sales') }}
--GROUP BY customer_id, order_month
--ORDER BY customer_id, order_month