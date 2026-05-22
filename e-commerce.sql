CREATE TABLE orders (
    order_id INT,
    created_at TIMESTAMP,
    website_session_id INT,
    user_id INT,
    primary_product_id INT,
    items_purchased INT,
    price_usd NUMERIC,
    cogs_usd NUMERIC
);

CREATE TABLE order_items (
    order_item_id INT,
    created_at TIMESTAMP,
    order_id INT,
    product_id INT,
    is_primary_item BOOLEAN,
    price_usd NUMERIC,
    cogs_usd NUMERIC
);

CREATE TABLE order_item_refunds (
    order_item_refund_id INT,
    created_at TIMESTAMP,
    order_item_id INT,
    order_id INT,
    refund_amount_usd NUMERIC
);

CREATE TABLE website_sessions (
    website_session_id INT,
    created_at TEXT,
    user_id INT,
    is_repeat_session INT,
    utm_source TEXT,
    utm_campaign TEXT,
    utm_content TEXT,
    device_type TEXT,
    http_referer TEXT
);

CREATE TABLE website_pageviews (
    website_pageview_id INT,
    created_at TIMESTAMP,
    website_session_id INT,
    pageview_url TEXT
);

CREATE TABLE products (
    product_id INT,
    created_at TIMESTAMP,
    product_name TEXT
);

DROP TABLE website_sessions;

SELECT * FROM orders
LIMIT 10;

-- DATA CLEANING

SELECT *
FROM orders
WHERE order_id IS NULL;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

--START ANALYSIS QUERIES

--Total Revenue
SELECT ROUND(SUM(price_usd),2) AS total_revenue
FROM orders;

--Total Orders
SELECT COUNT(order_id) AS total_orders
FROM orders;

--Monthly Revenue Trend
SELECT
    DATE_TRUNC('month', created_at) AS month,
    ROUND(SUM(price_usd),2) AS revenue
FROM orders
GROUP BY month
ORDER BY month;

--Top Selling Products
SELECT
    product_id,
    COUNT(*) AS total_sales
FROM order_items
GROUP BY product_id
ORDER BY total_sales DESC;

--Refund Rate
SELECT
    ROUND(
        COUNT(order_item_refund_id) * 100.0 /
        COUNT(DISTINCT order_items.order_item_id),
    2) AS refund_rate
FROM order_items
LEFT JOIN order_item_refunds
ON order_items.order_item_id =
order_item_refunds.order_item_id;

--Device Performance
SELECT
    device_type,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    ROUND(SUM(price_usd),2) AS revenue
FROM website_sessions
JOIN orders
ON website_sessions.website_session_id =
orders.website_session_id
GROUP BY device_type;

--Conversion Funnel
SELECT
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id =
orders.website_session_id;

--Export Final Tables for Power BI
--Best method 👇
--Create views.

CREATE VIEW monthly_revenue AS
SELECT
    DATE_TRUNC('month', created_at) AS month,
    ROUND(SUM(price_usd),2) AS revenue
FROM orders
GROUP BY month;