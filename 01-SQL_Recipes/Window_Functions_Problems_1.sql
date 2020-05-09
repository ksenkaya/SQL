
-- Window Functions Practice Problems

-- Say we have a table salaries with data on employee salary and department in the following format:
  depname  | empno | salary |     
-----------+-------+--------+
 develop   |    11 |   5200 | 
 develop   |     7 |   4200 | 
 develop   |     9 |   4500 | 
 develop   |     8 |   6000 | 
 develop   |    10 |   5200 | 
 personnel |     5 |   3500 | 
 personnel |     2 |   3900 | 
 sales     |     3 |   4800 | 
 sales     |     1 |   5000 | 
 sales     |     4 |   4800 | 

-- #1: The empno with the highest salary
WITH max_salary AS
  (
  SELECT MAX(salary) AS max_salary
  FROM salaries
  )

SELECT 
	s.empno
FROM salaries s
JOIN max_salary ms 
	ON s.salary = ms.max_salary

-- Alternate solution using RANK()
WITH sal_rank AS 
  (SELECT 
    empno, 
    RANK() OVER(ORDER BY salary DESC) rnk
  FROM 
    salaries)
SELECT 
  empno
FROM
  sal_rank
WHERE 
  rnk = 1;

-- #2: Average salary per depname
SELECT 
    *,
    ROUND(AVG(salary),0) OVER (PARTITION BY depname) avg_salary
FROM
    salaries

-- #3: The rank of each employee based on their salary within their department
SELECT 
    *, 
    RANK() OVER(PARTITION BY depname ORDER BY salary DESC) salary_rank
 FROM  
    salaries 
