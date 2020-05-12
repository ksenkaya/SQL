-- Missing Value handling in PostgreSQL

-- Display NULLs as 'Missing'
SELECT s.category,
       COALESCE(s.category, 'Missing') AS category_filled
FROM sales s

-- Fill NULLs with Avg
SELECT s.amount ,
       coalesce(s.amount,
                  ( SELECT AVG(amount)
                   FROM sales) ) AS amount_filled
FROM sales s

-- Display NULLs as 0
SELECT
	product,
	(price - COALESCE(discount,0)) AS net_price
FROM
	items;

-- When performing outer joins that result in some unmatched rows, you can use COALESCE to replace the null values
WITH
daily_dpd AS
(
    SELECT
        driver_id,
        COUNT(DISTINCT tracking_id) AS num_delivered
    FROM
        deliveries
    WHERE
        day = DATE('2020-01-01')
    GROUP BY
        1
)

SELECT
    COALESCE(
        drivers.name,
        CAST(daily_dpd.driver_id AS VARCHAR)
    ) AS driver_name,
    daily_dpd.num_delivered
FROM
    daily_dpd
LEFT JOIN
    drivers
ON
    daily_dpd.driver_id = drivers.i
