-- Analysing Business Metrics in SQL

/*
The key metrics that businesses use to measure performance and how to calculate them in SQL.
Such as revenue, cost, profit, the number of registrations, the number of active users, user base growth rate, order growth rate, retention rate, 
 average revenue per user, average orders per user etc.
*/

-- Suppose we have a food delivery company's data with a few tables, 'meals', 'orders' and 'stock' in the following format

-- Meals table
| meal_id |         eatery         | meal_price | meal_cost |
|---------|------------------------|------------|-----------|
|       0 | Leaning Tower of Pizza |        4.2 |      1.35 |
|       1 | Leaning Tower of Pizza |        3.5 |      1.25 |
|       2 | Pastaficio             |        4.5 |       1.5 |
|       3 | McBurgers              |        6.8 |       3.2 |

-- Orders table
| order_date | user_id | order_id | meal_id | order_quantity |
|------------|---------|----------|---------|----------------|
| 2018-06-01 |       0 |        0 |       4 |              3 |
| 2018-06-01 |       0 |        0 |      14 |              2 |
| 2018-06-01 |       1 |        0 |      15 |              1 |
| 2018-06-01 |       2 |        1 |       7 |              1 |

-- Stock table
| stocking_date | meal_id | stocked_quantity |
|---------------|---------|------------------|
| 2018-06-01    |       0 |               75 |
| 2018-06-01    |       1 |               45 |
| 2018-06-01    |       2 |               56 |
| 2018-06-01    |       3 |               35 |


-- Revenue, cost, and profit

-- #1: Revenue per week for each week in June 2018
SELECT DATE_TRUNC('week', order_date)::DATE AS delivr_week,
       SUM(meal_price*order_quantity) AS revenue
  FROM meals
  JOIN orders ON meals.meal_id = orders.meal_id
WHERE DATE_TRUNC('month', order_date) = '2018-06-01'
GROUP BY delivr_week
ORDER BY delivr_week;

-- #2: Profit per eatery
WITH revenue AS (
  SELECT eatery,
         SUM(meal_price*order_quantity) AS revenue
    FROM meals
    JOIN orders ON meals.meal_id = orders.meal_id
   GROUP BY eatery),

  cost AS (
  SELECT eatery,
         SUM(meal_cost*stocked_quantity) AS cost
    FROM meals
    JOIN stock ON meals.meal_id = stock.meal_id
   GROUP BY eatery)

   SELECT revenue.eatery,
          revenue - cost AS profit
     FROM revenue
     JOIN cost ON revenue.eatery = cost.eatery
    ORDER BY profit DESC;

-- #3: Profit per month
WITH revenue AS ( 
	SELECT
		DATE_TRUNC('month', order_date):: DATE AS delivr_month,
		SUM(meal_price*order_quantity) AS revenue
	FROM meals
	JOIN orders ON meals.meal_id = orders.meal_id
	GROUP BY delivr_month),

  cost AS (
 	SELECT
		DATE_TRUNC('month', stocking_date):: DATE AS delivr_month,
		SUM(meal_cost*stocked_quantity) AS cost
	FROM meals
    JOIN stock ON meals.meal_id = stock.meal_id
	GROUP BY delivr_month)

SELECT
	revenue.delivr_month,
	revenue - cost AS profit
FROM revenue
JOIN cost ON revenue.delivr_month = cost.delivr_month
ORDER BY revenue.delivr_month;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- User-centric metrics

-- #1: Registrations by month
WITH reg_dates AS (
  SELECT
    user_id,
    MIN(order_date) AS reg_date
  FROM orders
  GROUP BY user_id)

SELECT
  DATE_TRUNC('month', reg_date)::DATE AS delivr_month,
  COUNT(DISTINCT user_id) AS regs
FROM reg_dates
GROUP BY delivr_month
ORDER BY delivr_month; 

-- #2: Monthly active users (MAU)
SELECT
  DATE_TRUNC('month', order_date)::DATE AS delivr_month,
  COUNT(DISTINCT user_id) AS mau
FROM orders
GROUP BY delivr_month
ORDER BY delivr_month;

-- #2: Running total of registrations by month
WITH reg_dates AS (
  SELECT
    user_id,
    MIN(order_date) AS reg_date
  FROM orders
  GROUP BY user_id),

  regs AS (
  SELECT
    DATE_TRUNC('month', reg_date)::DATE AS delivr_month,
    COUNT(DISTINCT user_id) AS regs
  FROM reg_dates
  GROUP BY delivr_month)

SELECT
  delivr_month,
  SUM(regs) OVER (ORDER BY delivr_month) AS regs_rt
FROM regs
ORDER BY delivr_month; 

-- #3: MAUs and the previous month's MAU for every month
WITH mau AS (
  SELECT
    DATE_TRUNC('month', order_date)::DATE AS delivr_month,
    COUNT(DISTINCT user_id) AS mau
  FROM orders
  GROUP BY delivr_month)

SELECT
  delivr_month,
  mau,
  COALESCE(
    LAG(mau) OVER (ORDER BY delivr_month),
  0) AS last_mau
FROM mau

ORDER BY delivr_month;

-- #4: MoM monthly active users growth rate
WITH mau AS (
  SELECT
    DATE_TRUNC('month', order_date)::DATE AS delivr_month,
    COUNT(DISTINCT user_id) AS mau
  FROM orders
  GROUP BY delivr_month),

  mau_with_lag AS (
  SELECT
    delivr_month,
    mau,
    GREATEST(
      LAG(mau) OVER (ORDER BY delivr_month),
    1) AS last_mau
  FROM mau)

SELECT
  delivr_month,
  ROUND(
    (mau - last_mau)::NUMERIC / last_mau,
  2) AS growth
FROM mau_with_lag
ORDER BY delivr_month;

-- #5: MoM order growth rates
WITH orders AS (
  SELECT
    DATE_TRUNC('month', order_date)::DATE AS delivr_month,
    COUNT(DISTINCT order_id) AS orders
  FROM orders
  GROUP BY delivr_month),

  orders_with_lag AS (
  SELECT
    delivr_month,
    -- Fetch each month's current and previous orders
    orders,
    COALESCE(
      LAG(orders) OVER (ORDER BY delivr_month ASC),
    1) AS last_orders
  FROM orders)

SELECT
  delivr_month,
  ROUND(
    (orders - last_orders) :: NUMERIC / last_orders,
  2) AS growth
FROM orders_with_lag
ORDER BY delivr_month;

-- #6: MoM retention rates
WITH user_monthly_activity AS (
  SELECT DISTINCT
    DATE_TRUNC('month', order_date)::DATE AS delivr_month,
    user_id
  FROM orders)

SELECT
  previous.delivr_month,
  ROUND(
    COUNT(DISTINCT current.user_id)::NUMERIC / 
    GREATEST(COUNT(DISTINCT previous.user_id), 1),
  2) AS retention_rate
FROM user_monthly_activity AS previous
LEFT JOIN user_monthly_activity AS current
ON previous.user_id = current.user_id
AND previous.delivr_month = (current.delivr_month - INTERVAL '1 month')

GROUP BY previous.delivr_month
ORDER BY previous.delivr_month;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Performance per unit, as opposed to overall performance and distributions

-- #1: Average Revenue Per User (ARPU)
WITH kpi AS (
  SELECT
    user_id,
    SUM(m.meal_price * o.order_quantity) AS revenue
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY user_id)

SELECT ROUND(AVG(revenue::NUMERIC), 2) AS arpu
FROM kpi;

-- #2: ARPU per week
WITH kpi AS (
  SELECT
    DATE_TRUNC('week', order_date)::date AS delivr_week,
    SUM(meal_price*order_quantity) AS revenue,
    COUNT(DISTINCT user_id) AS users
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY delivr_week)

SELECT
  delivr_week,
  ROUND(
    revenue::numeric / nullif(users, 1),
  2) AS arpu
FROM kpi
ORDER BY delivr_week ASC;

-- #3: Average orders per user
WITH kpi AS (
  SELECT
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT user_id) AS users
  FROM orders)

SELECT
  ROUND(
    orders::numeric / users,
  2) AS arpu
FROM kpi;

-- #3: the distribution of revenues: a frequency table of revenues by user
WITH user_revenues AS (
  SELECT
    user_id,
    SUM(meal_price*order_quantity) AS revenue
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY user_id)

SELECT
  ROUND(revenue::NUMERIC, -2) AS revenue_100,
  COUNT(DISTINCT user_id) AS users
FROM user_revenues
GROUP BY revenue_100
ORDER BY revenue_100 ASC;

-- #4: Histogram of orders by user
WITH user_orders AS (
  SELECT
    user_id,
    COUNT(DISTINCT order_id) AS orders
  FROM orders
  GROUP BY user_id)

SELECT
  orders,
  COUNT(DISTINCT user_id) AS users
FROM user_orders
GROUP BY orders
ORDER BY orders ASC;

-- #5: Bucketing users by revenue
-- Split the users into low, mid, and high-revenue buckets, and return the count of users in each group

WITH user_revenues AS (
  SELECT
    -- Select the user IDs and the revenues they generate
    user_id,
    SUM(meal_price*order_quantity) AS revenue
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY user_id)

SELECT
  CASE
    WHEN revenue < 150 THEN 'Low-revenue users'
    WHEN revenue < 300 THEN 'Mid-revenue users'
    ELSE 'High-revenue users'
  END AS revenue_group,
  COUNT(DISTINCT user_id) AS users
FROM user_revenues
GROUP BY revenue_group;

-- #6: Bucketing users by orders

WITH user_orders AS (
  SELECT
    user_id,
    COUNT(DISTINCT order_id) AS orders
  FROM orders
  GROUP BY user_id)

SELECT
  CASE
    WHEN orders < 8 THEN 'Low-orders users'
    WHEN orders < 15 THEN 'Mid-orders users'
    ELSE 'High-orders users'
  END AS order_group,
  COUNT(DISTINCT user_id) AS users
FROM user_orders
GROUP BY order_group;

-- #7: Revenue quartiles
-- Calculate the first, second, and third revenue quartiles, as well as the average.

WITH user_revenues AS (
  SELECT
    user_id,
    SUM(meal_price*order_quantity) AS revenue
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY user_id)

SELECT
  ROUND(
    percentile_cont(0.25) WITHIN GROUP (ORDER BY revenue)::NUMERIC,
  2) AS revenue_p25,
  ROUND(
    percentile_cont(0.5) WITHIN GROUP (ORDER BY revenue)::NUMERIC,
  2) AS revenue_p50,
  ROUND(
    percentile_cont(0.75) WITHIN GROUP (ORDER BY revenue)::NUMERIC,
  2) AS revenue_p75,
  ROUND(AVG(revenue)::NUMERIC, 2) AS avg_revenue
FROM user_revenues;

-- #8: The count of users in the revenue IQR (Interquartile range, all data between the 1st and 3rd quartiles)

WITH user_revenues AS (
  SELECT
    user_id,
    SUM(m.meal_price * o.order_quantity) AS revenue
  FROM meals AS m
  JOIN orders AS o ON m.meal_id = o.meal_id
  GROUP BY user_id),

  quartiles AS (
  SELECT
    ROUND(
      PERCENTILE_CONT(0.25) WITHIN GROUP
      (ORDER BY revenue ASC) :: NUMERIC,
    2) AS revenue_p25,
    ROUND(
      PERCENTILE_CONT(0.75) WITHIN GROUP
      (ORDER BY revenue ASC) :: NUMERIC,
    2) AS revenue_p75
  FROM user_revenues)

SELECT
  COUNT(DISTINCT user_id) AS users
FROM user_revenues
CROSS JOIN quartiles

WHERE revenue :: NUMERIC >= revenue_p25
  AND revenue :: NUMERIC <= revenue_p75;
