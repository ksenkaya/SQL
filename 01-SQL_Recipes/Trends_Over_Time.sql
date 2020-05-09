
-- Trends over time

-- Suppose we have orders table in the format:
| id | account_id | occurred_at      | total |
| 1  | 1001       | 06/10/2015 17:31 | 169   |
| 2  | 1011       | 05/11/2015 03:34 | 288   |
| 3  | 1021       | 04/12/2015 04:21 | 132   |
| 4  | 1031       | 02/01/2016 01:18 | 176   |
| 5  | 1041       | 01/02/2016 19:27 | 165   |
| 6  | 1051       | 02/03/2016 15:29 | 173   |

-- What orders were placed yesterday?
SELECT * 
  FROM orders
 WHERE DATE_TRUNC('day',occurred_at) = CURRENT_DATE - interval '1 day'

-- How many orders are placed each hour of the day?
SELECT EXTRACT(hour from occurred_at) AS hour,
       COUNT(*) AS orders
  FROM orders 
 GROUP BY hour
 ORDER BY hour

-- How many orders are placed each day/month/quarter?
SELECT DATE_TRUNC('day', occurred_at) AS day, --day can be replaced with month or quarter
       COUNT(id)
  FROM demo.orders
 WHERE occurred_at BETWEEN '2016-01-01' AND '2016-12-31'
 GROUP BY 1
 ORDER BY 1 DESC

-- What's the average weekday order volume?
SELECT AVG(orders) AS avg_orders_weekday
  FROM (
SELECT EXTRACT(dow from occurred_at) AS dow,
       DATE_TRUNC('day',occurred_at) AS day,
       COUNT(id) AS orders
  FROM orders
 GROUP BY dow,day) a
 WHERE dow NOT IN (0,6) -- to filter out Saturdays and Sundays




