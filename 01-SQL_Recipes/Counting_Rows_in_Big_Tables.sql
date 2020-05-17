-- A faster way for counting rows in big tables in PostgreSQL 
-- Wiki: https://wiki.postgresql.org/wiki/Count_estimate

-- Create an 'items' table with a million random numbers and strings
CREATE TABLE bi.items AS

  SELECT
    (random()*1000000)::integer AS n,
    md5(random()::text) AS s
  FROM
    GENERATE_SERIES(1,1000000);

-- Getting the exact count
SELECT COUNT(*) AS exact_counts
FROM items;

-- Much more faster way to count estimate
SELECT reltuples AS estimate_count 
FROM pg_class 
WHERE relname = 'items';

-- In case there are multiple tables with the same name in different schemas
SELECT reltuples AS estimate_count 
FROM pg_class 
WHERE oid = 'bi.items'::regclass;
