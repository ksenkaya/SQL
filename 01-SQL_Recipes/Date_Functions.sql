
-- Commonly Used Date Functions in PostgreSQL

-- Suppose we have events table that contains users who created a profile, including start and end timestamps in the format:
| id   | started_at       | ended_at         |
| 4576 | 29/08/2013 14:13 | 29/08/2013 14:14 |
| 4607 | 29/08/2013 14:42 | 29/08/2013 14:43 |
| 4130 | 29/08/2013 10:16 | 29/08/2013 10:17 |
| 4251 | 29/08/2013 11:29 | 29/08/2013 11:30 |
| 4299 | 29/08/2013 12:02 | 29/08/2013 12:04 |


-- Difference between two dates in minutes or seconds
EXTRACT('EPOCH' FROM started_at - ended_at)

-- Difference between two dates in days
DATE_PART('day', ended_at - started_at)

-- Difference between two dates in weeks
TRUNC(DATE_PART('day', ended_at - started_at) / 7)

-- Difference between two dates in months
SELECT EXTRACT(YEAR FROM AGE(ended_at, started_at)) * 12 
	+ EXTRACT(MONTH FROM AGE(ended_at, started_at))

-- The average time to complete a profile each month
SELECT DATE_TRUNC('month',started_at) AS month,
       EXTRACT(EPOCH FROM AVG(AGE(ended_at,started_at))) AS avg_seconds
  FROM modeanalytics.profile_creation_events 
 GROUP BY 1
 ORDER BY 1  

-- Include today's date or time
SELECT CURRENT_DATE AS date,
       CURRENT_TIME AS time,
       CURRENT_TIMESTAMP AS timestamp,
       LOCALTIME AS localtime,
       LOCALTIMESTAMP AS localtimestamp,
       NOW() AS now

-- Some useful date functions
SELECT NOW()::timestamp AS now;
SELECT NOW()::DATE AS today;
SELECT DATE_TRUNC('month', now()) AS month_timestap;
SELECT DATE_TRUNC('hour', now()) AS hour_timestamp;

SELECT EXTRACT(month FROM NOW());
SELECT EXTRACT(dow from NOW());
SELECT EXTRACT(month FROM NOW());
SELECT EXTRACT(day FROM NOW()
SELECT TO_CHAR(NOW()::timestamp, 'YYYY-MM') AS year_month

-- Creating time series data for the next 12 months by days
    SELECT 
        date::date

    FROM generate_series
    (
      date_trunc('month', current_date)::date,
      (date_trunc('month', current_date) + interval '12 MONTH - 1 day')::date,
      '1 day'::interval
    )date
;
