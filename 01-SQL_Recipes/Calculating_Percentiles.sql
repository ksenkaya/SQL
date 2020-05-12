-- Calculate Percentiles with percentile_cont

-- Suppose we have sales table in the format:
order_date | sale
------------+------
 2020-04-01 |  210
 2020-04-02 |  125
 2020-04-03 |  150
 2020-04-04 |  230
 2020-04-05 |  200
 2020-04-10 |  220
 2020-04-06 |   25
 2020-04-07 |  215
 2020-04-08 |  300
 2020-04-09 |  250

SELECT
  PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY duration) AS percentile_25,
  PERCENTILE_CONT(0.50) WITHIN GROUP(ORDER BY duration) AS percentile_50, --median
  PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY duration) AS percentile_75,
  PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY duration) AS percentile_95
from sales