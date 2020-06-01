-- Pivoting tables in PostgreSQL with CROSSTAB() function
-- Pivoting converts a 'long' table into a 'wide' one because they're usually easier to scan

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


-- #1: Pivoting user revenues by month using CROSSTAB() extension
-- Pivot the user revenues by month query so that the user ID is a row and each month from June to August 2018 is a column, detailing the first 5 user ID

CREATE EXTENSION IF NOT EXISTS tablefunc; -- Import tablefunc

SELECT * FROM CROSSTAB($$
  SELECT
    user_id,
    DATE_TRUNC('month', order_date)::DATE AS delivr_month,
    SUM(meal_price * order_quantity)::FLOAT AS revenue
  FROM meals
  JOIN orders ON meals.meal_id = orders.meal_id
 WHERE user_id IN (0, 1, 2, 3, 4)
   AND order_date < '2018-09-01'
 GROUP BY user_id, delivr_month
 ORDER BY user_id, delivr_month;
$$)
-- Select user ID and the months from June to August 2018
AS ct (user_id INT,
       "2018-06-01" FLOAT,
       "2018-07-01" FLOAT,
       "2018-08-01" FLOAT)
ORDER BY user_id ASC;


-- #2: The total costs by eatery in November and December 2018, then pivot by month

CREATE EXTENSION IF NOT EXISTS tablefunc; -- Import tablefunc

SELECT * FROM CROSSTAB($$
  SELECT
    eatery,
    DATE_TRUNC('month', stocking_date):: DATE AS delivr_month,
    SUM(meal_cost * stocked_quantity):: FLOAT AS cost
  FROM meals
  JOIN stock ON meals.meal_id = stock.meal_id

  WHERE DATE_TRUNC('month', stocking_date) > '2018-10-01'
  GROUP BY eatery, delivr_month
  ORDER BY eatery, delivr_month;
$$)

AS ct (eatery TEXT,
       "2018-11-01" FLOAT,
       "2018-12-01" FLOAT)
ORDER BY eatery ASC;


-- #3: the rankings of eateries by the number of unique users who order from them by quarter

CREATE EXTENSION IF NOT EXISTS tablefunc;

-- Pivot the previous query by quarter
SELECT * FROM CROSSTAB($$
  WITH eatery_users AS  (
    SELECT
      eatery,
      -- Format the order date so "2018-06-01" becomes "Q2 2018"
      TO_CHAR(order_date, '"Q"Q YYYY') AS delivr_quarter, -- To render the first Q as a character, not the pattern, surround it with double quotes
      COUNT(DISTINCT user_id) AS users
    FROM meals
    JOIN orders ON meals.meal_id = orders.meal_id
    GROUP BY eatery, delivr_quarter
    ORDER BY delivr_quarter, users)

  SELECT
    eatery,
    delivr_quarter,
    RANK() OVER  -- Rank rows, partition by quarter and order by users
      (PARTITION BY delivr_quarter
       ORDER BY users DESC) :: INT AS users_rank
  FROM eatery_users
  ORDER BY eatery, delivr_quarter;
$$)
-- Select the columns of the pivoted table
AS  ct (eatery TEXT,
        "Q2 2018" INT,
        "Q3 2018" INT,
        "Q4 2018" INT)
ORDER BY "Q4 2018";
