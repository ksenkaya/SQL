
-- Cohort Analysis on Customer Behaviors

-- Suppose we have users table in the format:

| user_id | created_at       | company_id | language | activated_at     | state   |
| 0       | 01/01/2013 14:32 | 5373       | french   |                  | pending |
| 1       | 01/01/2013 09:56 | 1877       | indian   |                  | pending |
| 2       | 01/01/2013 18:20 | 6135       | english  | 01/01/2013 18:21 | active  |
| 3       | 01/01/2013 01:35 | 12910      | english  |                  | pending |
| 4       | 01/01/2013 05:35 | 8966       | english  | 01/01/2013 05:37 | active  |

-- Suppose we have events table in the format:
| user_id | min              | event_type  | event_name            | location      | device          |
| 13970   | 20/06/2014 16:14 | engagement  | send_message          | United States | iphone 5        |
| 17120   | 05/08/2014 18:50 | signup_flow | enter_info            | Saudi Arabia  | ipad air        |
| 15322   | 06/07/2014 15:19 | engagement  | login                 | Russia        | lenovo thinkpad |
| 12887   | 23/05/2014 08:09 | engagement  | search_autocomplete   | United States | macbook air     |
| 1304    | 16/05/2014 09:34 | engagement  | search_click_result_9 | United States | macbook air     |


-- #1: Retention Cohort: Retention rate by signup date

SELECT x.cohort AS "Date",
       MAX(x.period_age) OVER (PARTITION BY x.cohort) AS cutoff_age,
       x.period_age,
       x.unique_users,
       x.unique_users/MAX(x.unique_users) OVER (PARTITION BY x.cohort)::FLOAT AS retention_rate,
       MAX(x.unique_users) OVER (PARTITION BY x.cohort) AS "New Users"
  FROM (

SELECT DATE_TRUNC('week',u.activated_at) AS cohort,
       FLOOR(EXTRACT('day' FROM e.occurred_at - u.activated_at)/7) AS period_age,
       COUNT(DISTINCT u.user_id) AS unique_users
  FROM users u
  LEFT JOIN events e
    ON e.user_id = u.user_id
 WHERE u.activated_at IS NOT NULL
   AND u.activated_at >= '2014-05-01'
 GROUP BY 1,2
       ) x

 ORDER BY 1,2,3

-- #2: Retention rate by device
SELECT x.cohort AS "Device",
       MAX(x.period_age) OVER (PARTITION BY x.cohort) AS cutoff_age,
       x.period_age,
       x.unique_users,
       x.unique_users/MAX(x.unique_users) OVER (PARTITION BY x.cohort)::FLOAT AS retention_rate,
       MAX(x.unique_users) OVER (PARTITION BY x.cohort) AS "New Users"
  FROM (
SELECT e.device AS cohort,
       FLOOR(EXTRACT('day' FROM e.occurred_at - u.activated_at)/7) AS period_age,
       COUNT(DISTINCT u.user_id) AS tally
  FROM users u
  JOIN events e
    ON e.user_id = u.user_id
   AND e.event_name = 'complete_signup'
  LEFT JOIN events e
    ON e.user_id = u.user_id
 WHERE u.activated_at IS NOT NULL
   AND u.activated_at >= '2014-06-01'
 GROUP BY 1,2
       ) x
 ORDER BY 3,1


-- #3: Retention rate by the day of the week

WITH 

users_activated AS (
  SELECT user_id,
         activated_at
    FROM users
),

events_engagement AS (
  SELECT user_id,
         occurred_at,
         event_name
    FROM events
   WHERE event_type = 'engagement'
)

SELECT CASE WHEN dow = 0 THEN 'Sunday'
            WHEN dow = 1 THEN 'Monday'
            WHEN dow = 2 THEN 'Tuesday'
            WHEN dow = 3 THEN 'Wednesday'
            WHEN dow = 4 THEN 'Thursday'
            WHEN dow = 5 THEN 'Friday'
            WHEN dow = 6 THEN 'Saturday'
            ELSE 'error' END AS "Signup day",
       COUNT(*) AS num_users,
       COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '2 DAY' AND z.r_1_day > 0 THEN z.user_id ELSE NULL END)/
          (COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '2 DAY' THEN z.user_id ELSE NULL END) + 1)::FLOAT AS "1 day retention",
       COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '14 DAY' AND z.r_7_day > 0 THEN z.user_id ELSE NULL END)/
          (COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '14 DAY' THEN z.user_id ELSE NULL END) + 1)::FLOAT AS "7 day retention",
       COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '21 DAY' AND z.r_14_day > 0 THEN z.user_id ELSE NULL END)/
          (COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '21 DAY' THEN z.user_id ELSE NULL END) + 1)::FLOAT AS "14 day retention",
       COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '35 DAY' AND z.r_28_day > 0 THEN z.user_id ELSE NULL END)/
          (COUNT(CASE WHEN z.activated_at <= NOW() - INTERVAL '35 DAY' THEN z.user_id ELSE NULL END) + 1)::FLOAT AS "28 day retention"
  FROM (
SELECT u.user_id,
       EXTRACT('DOW' FROM u.activated_at) AS dow,
       u.activated_at,
       COUNT(CASE WHEN e.occurred_at >= u.activated_at + INTERVAL '1 DAY' AND e.occurred_at < u.activated_at + INTERVAL '2 DAY' 
                  THEN u.user_id ELSE NULL END) AS r_1_day,
       COUNT(CASE WHEN e.occurred_at >= u.activated_at + INTERVAL '7 DAY' AND e.occurred_at < u.activated_at + INTERVAL '14 DAY' 
                  THEN u.user_id ELSE NULL END) AS r_7_day,
       COUNT(CASE WHEN e.occurred_at >= u.activated_at + INTERVAL '14 DAY' AND e.occurred_at < u.activated_at + INTERVAL '21 DAY' 
                  THEN u.user_id ELSE NULL END) AS r_14_day,
       COUNT(CASE WHEN e.occurred_at >= u.activated_at + INTERVAL '28 DAY' AND e.occurred_at < u.activated_at + INTERVAL '35 DAY' 
                  THEN u.user_id ELSE NULL END) AS r_28_day
  FROM users_activated u
  LEFT JOIN events_engagement e
    ON e.user_id = u.user_id
   AND e.occurred_at >= u.activated_at
   AND e.occurred_at < u.activated_at + INTERVAL '35 DAY'
 WHERE u.activated_at IS NOT NULL
 GROUP BY 1,2,3
       ) z
 GROUP BY dow
 ORDER BY dow
