-- Exploring Distributions by binning data in PostgreSQL

-- Suppose we have Stack Overflow data contains daily question counts through 2018-09-25 for all tags, but each tag has a different starting date

|    tag     |    date    | question_count | question_pct | unanswered_count | unanswered_pct |
|------------|------------|----------------|--------------|------------------|----------------|
| paypal     | 25/09/2018 |          18050 | 0.001093757  |             8402 | 0.001751857    |
| windows    | 25/09/2018 |           1452 | 8.80E-05     |              561 | 1.17E-04       |
| azure      | 24/09/2018 |            706 | 4.28E-05     |              278 | 5.80E-05       |
| amazon-rds | 24/09/2018 |            232 | 1.41E-05     |               77 | 1.61E-05       |
| sql-server | 23/09/2018 |           1400 | 8.48E-05     |              601 | 1.25E-04       |


-- Summarise the distribution of the number of questions with the tag "azure" on Stack Overflow per day by binning the data

WITH bins AS ( --  create bins of size 50 from 2200 to 3100.
      SELECT GENERATE_SERIES(2200, 3050, 50) AS lower,
             GENERATE_SERIES(2250, 3100, 50) AS upper),
    
     azure AS ( -- Start by selecting the minimum and maximum of the question_count column for the tag 'dropbox', so you know the range of values to cover with the bins
      SELECT question_count 
        FROM stackoverflow
       WHERE tag='azure') 

SELECT lower, upper, COUNT(question_count) 
  FROM bins
       LEFT JOIN azure
         ON question_count >= lower 
        AND question_count < upper
 GROUP BY lower, upper
 ORDER BY lower;