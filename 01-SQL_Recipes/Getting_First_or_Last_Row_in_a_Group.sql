
-- Getting the first/last row in a group

-- Find the employee with the highest salary for each department

-- Say we have a table employees in the following format:
id |      name      |      department      | salary 
----+----------------+----------------------+--------
  1 | Carl Frazier   | Engineering          |   3052
  2 | Richard Fox    | Product Management   |  13449
  3 | Carolyn Carter | Engineering          |   8366
  4 | Benjamin Brown | Business Development |   7386
  5 | Diana Fisher   | Services             |  10419

-- Solution #1: Subquery
SELECT  * 
FROM employees 
WHERE (department, salary) IN
  (
    SELECT 
    	department, 
    	MAX(salary) 
    FROM employees
    GROUP BY department
  )
ORDER BY department;

-- Solution #2: ROW_NUMBER()
WITH ranked_employees AS
  ( 
  	SELECT *,
  			ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rank_in_dep                  
   FROM employees
   )
SELECT *
FROM ranked_employees
WHERE rank_in_dep = 1
ORDER BY department;

-- Solution #3: DISTINCT ON
-- PostgreSQL has a special nonstandard clause to find the first row in a group
-- Field in DISTINCT ON must be in ORDER BY
-- Can control first / last using sort order (ASC / DESC)
SELECT DISTINCT ON (department) *
FROM employees
ORDER BY department,
         salary DESC;
