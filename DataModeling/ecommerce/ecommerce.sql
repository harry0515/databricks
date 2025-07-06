
--1. Track Daily Sales Totals by Product Category
SELECT
    d.full_date,
    p.product_category,
    SUM(f.sales_amount) AS total_sales
FROM
    Sales_Fact f
JOIN Date_Dim d ON f.date_key = d.date_key
JOIN Product_Dim p ON f.product_key = p.product_key
GROUP BY
    d.full_date, p.product_category
ORDER BY
    d.full_date, total_sales DESC;



--2. Analyze Customer Purchase History for Segmentation
SELECT
    c.customer_key,
    c.customer_name,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.sales_amount) AS total_spent,
    COUNT(DISTINCT p.product_category) AS distinct_categories
FROM
    Sales_Fact f
JOIN Customer_Dim c ON f.customer_key = c.customer_key
JOIN Product_Dim p ON f.product_key = p.product_key
GROUP BY
    c.customer_key, c.customer_name;


--3. Calculate Average Order Value (AOV) and Customer Lifetime Value (CLV)

SELECT
    AVG(order_total) AS avg_order_value
FROM (
    SELECT
        order_id,
        SUM(sales_amount) AS order_total
    FROM
        Sales_Fact
    GROUP BY
        order_id
) AS order_summary;


SELECT
    c.customer_key,
    c.customer_name,
    SUM(f.sales_amount) AS customer_lifetime_value
FROM
    Sales_Fact f
JOIN Customer_Dim c ON f.customer_key = c.customer_key
GROUP BY
    c.customer_key, c.customer_name;


--4. Monitor Product Inventory Levels

SELECT
    d.full_date,
    p.product_name,
    s.store_name,
    i.quantity_on_hand
FROM
    Inventory_Snapshot_Fact i
JOIN Date_Dim d ON i.date_key = d.date_key
JOIN Product_Dim p ON i.product_key = p.product_key
JOIN Store_Dim s ON i.store_key = s.store_key
WHERE
    d.full_date = CURRENT_DATE;



--5. Evaluate the Effectiveness of Marketing Campaigns
SELECT
    c.campaign_name,
    c.campaign_type,
    SUM(f.sales_amount) AS total_sales,
    COUNT(DISTINCT f.customer_key) AS unique_customers
FROM
    Sales_Fact f
JOIN Campaign_Dim c ON f.campaign_key = c.campaign_key
GROUP BY
    c.campaign_name, c.campaign_type
ORDER BY
    total_sales DESC;

--6. Inventory Turnover
SELECT
  SUM(cogs) / NULLIF(AVG(units_in_stock), 0) AS inventory_turnover
FROM fact_inventory
WHERE date BETWEEN DATE('now', '-12 months') AND DATE('now');


-- 7. Cart Abandonment Rate

WITH carts AS (
  SELECT user_id
  FROM fact_cart_events
  WHERE event_type = 'add_to_cart'
),
purchases AS (
  SELECT DISTINCT customer_id AS user_id
  FROM fact_orders
)
SELECT
  (COUNT(*) - COUNT(p.user_id)) * 1.0 / COUNT(*) AS abandonment_rate
FROM carts c
LEFT JOIN purchases p ON c.user_id = p.user_id;