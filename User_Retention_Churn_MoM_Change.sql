/*
A few common metrics in customer analytics — retention, churn, and month over month change — and how to build them in SQL. 
*/

-- Say we have a table logins in the form: 
| user_id | date       |
|---------|------------|
| 1       | 2018-07-01 |
| 234     | 2018-07-02 |
| 3       | 2018-07-02 |
| 1       | 2018-07-02 |
| ...     | ...        |
| 234     | 2018-10-04 |

-- User retention
-- Number of retained users per month: How many users were active both last month and this month?
SELECT 
    DATE_TRUNC('month', a.date) AS month_timestamp, 
    COUNT(DISTINCT a.user_id) AS retained_users 
 FROM 
    logins a 
 JOIN 
    logins b 
 ON a.user_id = b.user_id 
    AND DATE_TRUNC('month', a.date) = DATE_TRUNC('month', b.date) + interval '1 month'
 GROUP BY 
    1

-- The number of churned users: How many users last month did not come back this month?
SELECT 
    DATE_TRUNC('month', a.date) AS month_timestamp, 
    COUNT(DISTINCT b.user_id) AS churned_users 
FROM 
    logins a 
FULL OUTER JOIN logins b 
	ON a.user_id = b.user_id 
        AND DATE_TRUNC('month', a.date) = DATE_TRUNC('month', b.date) + interval '1 month'
WHERE 
    a.user_id IS NULL 
GROUP BY 
    DATE_TRUNC('month', a.date)


 -- MoM Percent Change for monthly active users
 WITH mom_change AS 
(
  SELECT
    DATE_TRUNC('month', date) AS month_timestamp,
    COUNT(DISTINCT user_id) AS unique_users
  FROM 
    logins 
  GROUP BY 
    month_timestamp
  )
 
 SELECT
    a.month_timestamp AS previous_month, 
    a.unique_users AS previous_unique_users, 
    b.month_timestamp AS current_month, 
    b.unique_users AS current_unique_users, 
    ROUND(100.0*(b.unique_users - a.unique_users)/a.unique_users,2) AS percent_change 
 FROM mom_change a 
 JOIN mom_change b
 ON a.month_timestamp = b.month_timestamp - interval '1 month'
 