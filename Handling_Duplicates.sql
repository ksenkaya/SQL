
-- Handling duplicates in SQL

-- Say we have a users table in the format:
| id | username |        email        |
|----|----------|---------------------|
|  1 | Pete     | pete@example.com    |
|  6 | Pete     | pete@example.com    |
| 12 | Jessica  | jessica@example.com |
| 13 | Jessica  | jessica@example.com |
|  2 | Miles    | miles@example.com   |
|  9 | Miles    | miles@example.com   |


-- Find duplicate rows
SELECT username,
       email,
       COUNT(*)
FROM users
GROUP BY username,
         email 
HAVING COUNT(*) > 1;

-- Show all duplicate rows
WITH duplicates AS
  (
  SELECT username,
         email
   FROM users
   GROUP BY username,
            email 
   HAVING count(*) > 1)

SELECT a.*
FROM users a
JOIN duplicates b 
ON (a.firstname = b.firstname AND a.lastname = b.lastname)