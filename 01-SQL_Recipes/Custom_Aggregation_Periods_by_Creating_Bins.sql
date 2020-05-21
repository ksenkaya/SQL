-- Custom aggregation periods by creating bins

-- Suppose we have a request table in the following format
|   id    | priority |       source        |     date_created     |    date_completed    |
|---------|----------|---------------------|----------------------|----------------------|
| 1340563 | NONE     | gov.publicstuff.com | 2016-01-13T15:03:18Z | 2016-01-19T16:51:26Z |
| 1826017 | MEDIUM   | Iframe              | 2016-08-12T14:35:12Z | 2016-08-27T07:00:27Z |
| 1849204 | MEDIUM   | Iframe              | 2016-08-22T09:07:45Z | 2016-08-24T07:05:32Z |
| 1880254 | MEDIUM   | iOS                 | 2016-09-01T09:03:54Z | 2016-09-01T16:52:40Z |
| 1972582 | MEDIUM   | Iframe              | 2016-09-19T01:46:41Z | 2016-09-27T11:28:50Z |


-- Problem: Find the median number of requests per day in each six month period from 2016-01-01 to 2018-06-30
-- Solution: Create bins with lower and upper bounds of time, and then summarise observations that fall in each bin

-- Create bins of 6 month intervals
WITH bins AS (
	 SELECT GENERATE_SERIES('2016-01-01',
                            '2018-01-01',
                            '6 months'::INTERVAL) AS lower,
            GENERATE_SERIES('2016-07-01',
                            '2018-07-01',
                            '6 months'::INTERVAL) AS upper), -- the upper bin values are exclusive, so the values need to be one day greater than the last day to be included in the bin.

-- The number of requests created per day
     daily_counts AS (
     SELECT day, COUNT(date_created) AS count
       FROM (
        SELECT GENERATE_SERIES('2016-01-01',
                                    '2018-06-30',
                                    '1 day'::INTERVAL)::DATE AS day
        ) AS daily_series

            LEFT JOIN request -- include days with no requests
            ON day = date_created::DATE
      GROUP BY day)

-- Assign each daily count to a single 6 month bin  
SELECT lower, 
       upper, 
       PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY count) AS median -- Compute median of count for each bin
  FROM bins
       LEFT JOIN daily_counts
       ON day >= lower
          AND day < upper
 GROUP BY lower, upper
 ORDER BY lower;