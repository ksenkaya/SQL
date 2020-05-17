-- Create a basic 'sales' table

SET datestyle TO ymd;

DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    id          INTEGER PRIMARY KEY,
    branch      TEXT,
    sold_at     TIMESTAMP WITH TIME ZONE,
    customer    TEXT,
    product     TEXT,
    price       INTEGER,
    discount    INTEGER
);

-- Generate some data
INSERT INTO sales (id, branch, sold_at, customer, product, price, discount)
SELECT
    (SELECT MAX(id) FROM sales) + GENERATE_SERIES(1, 10000) AS id,
    (ARRAY['NY', 'LA'])[ceil(random() * 2)] AS branch,
    '2020-03-01 00:00:00 UTC'::timestamptz + interval '1 hour' * random() * 24 * 30 * 6 AS sold_at,
    (ARRAY['Bill', 'David', 'John', 'Lily'])[ceil(random() * 30)] AS customer,
    (ARRAY['Shoes', 'Shirt', 'Pants', 'Hat', 'Give Away'])[ceil(random() * 4)] AS product,
        ROUND(random() * 150 * 100)::integer / 10 * 10 AS price,
    0 AS discount;

-- Collect statistics for the table
ANALYZE sales;

-- Create some indexes
 CREATE INDEX sales_customer_ix ON sales(customer);
 CREATE INDEX sales_sold_at_ix ON sales(sold_at);

-- Some examples to play around with
-- #1: What is the discount rate on Shoes?
SELECT price,
       discount,
       discount / price::float * 100 AS discount_rate
FROM sales
WHERE product = 'Shoes';

-- #2: Find the average discount rate by product
-- Product “Give Away” price is zero and it causes the 'division by zero' error
-- Make discount rate zero for products with price zero
SELECT
 product,
 COALESCE(AVG(discount / NULLIF(price, 0)::float), 0) * 100
FROM sales
GROUP BY product;

-- #3: How many unique users purchased each product?
-- Aggregate functions ignore null values!
SELECT
 product,
 COUNT(*) AS cnt,
 COUNT(customer) AS cnt_customer
FROM sales
GROUP BY product;

-- #4: How many known customers purchased each product?
SELECT
 product,
 COUNT(customer) as known_customers,
 COUNT(*) - COUNT(customer) as unknown_customers
FROM sales
GROUP BY product;

-- #5: Sales by user
SELECT
 first_name || ' ' || last_name as full_name,
 count(*) as sales_by_user
FROM
 sales
GROUP BY
 1
ORDER BY
 sales_by_user DESC;
