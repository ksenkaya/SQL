-- Finding missing dates

-- Suppose we have a requests table which includes a date_created timestamp from when each request was created in the following format
-- There are few days with no requests

|   id    | priority |       source        |     date_created     |    date_completed    |
|---------|----------|---------------------|----------------------|----------------------|
| 1340563 | NONE     | gov.publicstuff.com | 2016-01-13T15:03:18Z | 2016-01-19T16:51:26Z |
| 1826017 | MEDIUM   | Iframe              | 2016-08-12T14:35:12Z | 2016-08-27T07:00:27Z |
| 1849204 | MEDIUM   | Iframe              | 2016-08-22T09:07:45Z | 2016-08-24T07:05:32Z |
| 1880254 | MEDIUM   | iOS                 | 2016-09-01T09:03:54Z | 2016-09-01T16:52:40Z |
| 1972582 | MEDIUM   | Iframe              | 2016-09-19T01:46:41Z | 2016-09-27T11:28:50Z |

-- Generates all dates from min to max with date_created
 SELECT day
  FROM (
  	SELECT GENERATE_SERIES(MIN(date_created),
                               MAX(date_created),
                               '1 day')::DATE AS day
          FROM request
          ) AS all_dates

 WHERE day NOT IN
       (
       	SELECT date_created::DATE
          FROM request
          );

-- If we want to find the average number of requests created per day for each month with missing dates

-- generates all days from 2016-01-01 to 2018-06-30
WITH all_days AS 
     (SELECT generate_series('2016-01-01',
                             '2018-06-30',
                             '1 day'::interval) AS date),

     -- compute daily counts
     daily_count AS 
     (SELECT DATE_TRUNC('day', date_created) AS day,
             COUNT(*) AS count
        FROM requests
       GROUP BY day)

-- Aggregate daily counts by month
SELECT DATE_TRUNC('month', date) AS month,
       AVG(COALESCE(count, 0)) AS average
  FROM all_days
       LEFT JOIN daily_count
       ON all_days.date=daily_count.day
 GROUP BY month
 ORDER BY month; 