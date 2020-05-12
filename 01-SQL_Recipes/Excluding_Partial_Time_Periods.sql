-- Excluding Partial Time Periods in Postgres

-- If you ran a query midweek, e.g. Wednesday, the current week would only return data from Monday through Wednesday (~3 days)
SELECT DATE_TRUNC('week', created_at), --hour, day, week, month, year
       COUNT(1)
FROM users
WHERE created_at > NOW() - INTERVAL '4 weeks'
GROUP BY 1;

-- Omit any data from the current incomplete week
-- Instead of looking back 4 weeks from NOW(), you can look back 4 weeks from the beginning of current week
SELECT DATE_TRUNC('week', created_at),
       COUNT(1)
FROM users
WHERE DATE_TRUNC('week', created_at) != DATE_TRUNC('week', NOW())
  AND created_at > DATE_TRUNC('week', NOW()) - INTERVAL '4 weeks'
GROUP BY 1;