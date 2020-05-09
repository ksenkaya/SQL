
-- Moving Average calculation in SQL

-- Say we have table signups in the form:
| date       | sign_ups |
|------------|----------|
| 2018-01-01 | 10       |
| 2018-01-02 | 20       |
| 2018-01-03 | 50       |
| ...        | ...      |
| 2018-10-01 | 35       |

-- 7-day moving average of daily sign-ups
SELECT 
  a.date, 
  AVG(b.sign_ups) AS average_sign_ups 
FROM signups a 
JOIN signups b 
  ON a.date <= b.date + interval '6 days' 
  	AND a.date >= b.date
GROUP BY 
  a.date