-- Creating Date Dimension for any date range in Postgres

SELECT
  to_char(dimension_date, 'YYYYMMDD')::integer as date_id,
  dimension_date,
  to_char(dimension_date, 'YYYY')::integer as year,
  to_char(dimension_date, 'Q')::integer as quarter,
  to_char(dimension_date, 'MM')::integer as month,
  to_char(dimension_date, 'DD')::integer as day,
  to_char(dimension_date, 'Q')::integer * 10000 + to_char(dimension_date, 'MMDD')::integer as quarter_month_day,
  to_char(dimension_date, 'MMDD')::integer as month_day,
  to_char(dimension_date, 'Month') as month_name,
  to_char(dimension_date, 'Mon') as month_abbreviation,
  to_char(dimension_date, 'Day') as weekday_name,
  to_char(dimension_date, 'Dy') as weekday_abbreviation,
  to_char(dimension_date, 'W')::integer as week_in_month,
  to_char(dimension_date, 'WW')::integer as week_in_year,
  to_char(dimension_date, 'D')::integer as day_in_week,
  (dimension_date + 1) - to_date((date_part('year', dimension_date)::integer * 10000 + 101)::char(8),'YYYYMMDD') as day_in_year,
  case when to_char(dimension_date - INTERVAL '1 day','D')::integer < 6 then 1 else 0 end as is_working_day,
  to_char(dimension_date, 'YYYY')::integer - to_char(dimension_date - (day_in_dimension - 1), 'YYYY')::integer + 1 as year_in_dimension,
  (to_char(dimension_date, 'YYYY')::integer - to_char(dimension_date - (day_in_dimension - 1), 'YYYY')::integer) * 12 + to_char(dimension_date, 'MM')::integer as month_in_dimension,
  day_in_dimension,
  to_char(dimension_date, 'IYYY')::integer as iso_year,
  to_char(dimension_date, 'IW')::integer as iso_week_in_year,
  (to_char(dimension_date, 'IW')::integer - 1) * 7 + to_char(dimension_date - INTERVAL '1 day','D')::integer as iso_day_in_year,
  to_char(dimension_date - INTERVAL '1 day','D')::integer iso_day_in_week
FROM
  (
    SELECT
      date_trunc('day', generated_date):: date as dimension_date,
      (row_number() OVER ())::integer as day_in_dimension
    FROM
      generate_series( '2010-01-01'::timestamp, '2030-12-31'::timestamp, '1 day'::interval) generated_date
  ) time_series
