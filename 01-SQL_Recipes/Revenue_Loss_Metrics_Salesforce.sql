/* Creating revenue loss related metrics by days over time with Salesforce data
# Opportunities in offboarding
# Opportunities in retention
# Opportunities running
Retention revenue, offboarding revenue, running revenue
*/

DROP TABLE IF EXISTS bi.revenue_loss;

CREATE TABLE bi.revenue_loss AS

-- Example of the revenue loss for the current date
SELECT
    CURRENT_DATE AS today,
    TO_CHAR(CURRENT_DATE, 'YYYY-MM') AS year_month,
    COUNT(CASE WHEN opps.status = 'OFFBOARDING' THEN opps.id ELSE NULL END) AS no_opps_offboarding,
    COUNT(CASE WHEN opps.status = 'RETENTION' THEN opps.id ELSE NULL END) AS no_opps_retention,
    COUNT(CASE WHEN opps.status = 'RUNNING' THEN opps.id ELSE NULL END) AS no_opps_running,
    SUM(CASE WHEN opps.status = 'RETENTION' THEN (CASE WHEN opps.grand_total IS NULL THEN opps.price_per_hour * t1.invoiced_hours ELSE opps.grand_total END) ELSE NULL END)::DECIMAL AS retention_revenue,
    SUM(CASE WHEN opps.status = 'OFFBOARDING' THEN (CASE WHEN opps.grand_total IS NULL THEN opps.price_per_hour * t1.invoiced_hours ELSE opps.grand_total END) ELSE NULL END)::DECIMAL AS offboarding_revenue,
    SUM(CASE WHEN opps.status = 'RUNNING' THEN (CASE WHEN opps.grand_total IS NULL THEN opps.price_per_hour * t1.invoiced_hours ELSE opps.grand_total END) ELSE NULL END)::DECIMAL AS running_revenue
FROM
    salesforce.opportunity opps
LEFT JOIN( -- Invoiced hours last month for each opportunities 
    SELECT
        TO_CHAR(effectivedate, 'YYYY-MM') AS year_month,
        SUM(o.order_duration)::DECIMAL AS invoiced_hours,
        o.opportunityid AS opportunities
           
    FROM
        salesforce.order o

    WHERE
        o.status IN ('INVOICED',
        'PENDING TO START',
        'CANCELLED CUSTOMER',
        'FULFILLED')
        AND o.type = 'b2b'
        AND o.professional IS NOT NULL
        AND o.test IS FALSE
        AND LEFT(o.locale, 2) = 'de, fr'
        AND o.effectivedate::TIMESTAMP >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
        AND o.effectivedate::TIMESTAMP < DATE_TRUNC('month', CURRENT_DATE)

    GROUP BY
        year_month,
        o.opportunityid) AS t1 ON
    t1.opportunities = opps.sfid
WHERE
    opps.test IS FALSE
    AND LEFT(opps.locale, 2) = 'de, fr'

GROUP BY
    TO_CHAR(CURRENT_DATE, 'YYYY-MM');
        
