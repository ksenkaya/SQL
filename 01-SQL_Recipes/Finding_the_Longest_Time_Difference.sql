-- Find the longest time difference

-- Suppose we have a requests table in the following format
|   id    | priority |       source        |     date_created     |    date_completed    |
|---------|----------|---------------------|----------------------|----------------------|
| 1340563 | NONE     | gov.publicstuff.com | 2016-01-13T15:03:18Z | 2016-01-19T16:51:26Z |
| 1826017 | MEDIUM   | Iframe              | 2016-08-12T14:35:12Z | 2016-08-27T07:00:27Z |
| 1849204 | MEDIUM   | Iframe              | 2016-08-22T09:07:45Z | 2016-08-24T07:05:32Z |
| 1880254 | MEDIUM   | iOS                 | 2016-09-01T09:03:54Z | 2016-09-01T16:52:40Z |
| 1972582 | MEDIUM   | Iframe              | 2016-09-19T01:46:41Z | 2016-09-27T11:28:50Z |

-- What is the longest time between requests submitted?

-- Compute the gaps
WITH request_gaps AS (
        SELECT date_created,
               LAG(date_created) OVER (ORDER BY date_created) AS previous,
               date_created - LAG(date_created) OVER (ORDER BY date_created) AS gap
          FROM request)

SELECT *
  FROM request_gaps
 WHERE gap = (
 	SELECT MAX(gap)
                FROM request_gaps
                );