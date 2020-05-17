-- Select randows rows to take a sample
-- Wiki: https://wiki.postgresql.org/wiki/TABLESAMPLE_Implementation

-- Create an 'items' table with a million random numbers and strings
CREATE TABLE items AS

  SELECT
    (random()*1000000)::integer AS n,
    md5(random()::text) AS s
  FROM
    GENERATE_SERIES(1,1000000);

-- Select 5 rows randomly
SELECT *
FROM mytable OFFSET floor(random()*N) 
LIMIT 5;

-- For big tables use TABLESAMPLE clause to retrieve a subset of the rows
SELECT * 
FROM items TABLESAMPLE SYSTEM (10);    --Returns about 10% of rows using SYSTEM method

SELECT *
FROM items TABLESAMPLE BERNOULLI (10); --Using BERNOULLI sampling method


