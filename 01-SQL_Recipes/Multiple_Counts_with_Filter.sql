-- Using 'Filter' to have multiple counts in PostgreSQL
SELECT
  COUNT(1), -- Count all users
  COUNT(1) FILTER (WHERE gender = 'male'), -- Count male users
  COUNT(1) FILTER (WHERE beta IS TRUE) -- Count beta users
  COUNT(1) FILTER (WHERE active IS TRUE and beta IS FALSE) -- Count active non-beta users
from users

-- Another example
SELECT
 COUNT(*),
 SUM(CASE WHEN customer IS NULL THEN 1 ELSE 0 END),
 SUM(CASE WHEN customer IS NOT NULL THEN 1 ELSE 0 END)
FROM
 sale;

-- Instead
SELECT
 COUNT(*) AS sales_count,
 COUNT(*) FILTER (WHERE customer IS NULL) AS sales_count,
 COUNT(*) FILTER (WHERE customer IS NOT NULL)
FROM
 sale;
