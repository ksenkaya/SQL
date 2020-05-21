-- Calculating Relationships with Correlation Matrix in PostgreSQL

-- Suppose we have Fortune500 dataset, a list of the largest companies in the US published by Fortune Magazine below
-- Full dataset can be found here: https://www.kaggle.com/vineetjaiswal/fortune500-2017

| rank |          name           | revenues | revenues_change | profits | profits_change |
|------|-------------------------|----------|-----------------|---------|----------------|
|    1 | Wal-Mart Stores, Inc.   |   485873 |             0.8 |   13643 |           -7.2 |
|    2 | Berkshire Hathaway Inc. |   223604 |             6.1 |   24074 |              0 |
|    3 | Apple, Inc.             |   215639 |            -7.7 |   45687 |          -14.4 |
|    4 | Exxon Mobil Corporation |   205004 |           -16.7 |    7840 |          -51.5 |
|    5 | McKesson Corporation    |   192487 |             6.2 |    2258 |             53 |


-- Compute the correlations between each pair of profits, profits_change, and revenues_change from the Fortune 500 data

-- The resulting temporary table should have the following structure:
|     measure     | profits | profits_change | revenues_change |
|-----------------|---------|----------------|-----------------|
| profits         | 1.00    | #              | #               |
| profits_change  | #       | 1.00           | #               |
| revenues_change | #       | #              | 1.00            |


DROP TABLE IF EXISTS correlations;

CREATE TEMP TABLE correlations AS
SELECT 'profits'::varchar AS measure,
       CORR(profits, profits) AS profits,
       CORR(profits, profits_change) AS profits_change,
       CORR(profits, revenues_change) AS revenues_change
  FROM fortune500;

INSERT INTO correlations
-- Follow the pattern of the select statement above using profits_change instead of profits
SELECT 'profits_change'::varchar AS measure,
       CORR(profits_change, profits) AS profits,
       CORR(profits_change, profits_change) AS profits_change,
       CORR(profits_change, revenues_change) AS revenues_change
  FROM fortune500;

-- Repeat the above, but for revenues_change
INSERT INTO correlations
SELECT 'revenues_change'::varchar AS measure,
       CORR(revenues_change, profits) AS profits,
       CORR(revenues_change, profits_change) AS profits_change,
       CORR(revenues_change, revenues_change) AS revenues_change
  FROM fortune500;

-- Select each column, rounding the correlations
SELECT measure, 
       ROUND(profits::numeric, 2) AS profits,
       ROUND(profits_change::numeric, 2) AS profits_change,
       ROUND(revenues_change::numeric, 2) AS revenues_change
  FROM correlations;


-- Resulting table

|     measure     | profits | profits_change | revenues_change |
|-----------------|---------|----------------|-----------------|
| profits         |    1.00 |           0.02 |            0.02 |
| profits_change  |    0.02 |           1.00 |           -0.09 |
| revenues_change |    0.02 |          -0.09 |            1.00 |