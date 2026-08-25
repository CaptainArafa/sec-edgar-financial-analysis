/*
 * File:           sql_scripts/06_yoy_growth_analysis.sql
 * Object:         Year-over-Year (YoY) Growth Analytics
 * Description:    Computes growth metrics using immutable CIK partitioning and 
 *                 explicit prior-period metric output.
 */
WITH ordered_metrics AS (
    SELECT 
        company_name,
        cik,
        period,
        total_revenue,
        net_income,
        LAG(total_revenue) OVER (PARTITION BY cik ORDER BY period ASC) AS prev_period_revenue,
        LAG(net_income) OVER (PARTITION BY cik ORDER BY period ASC) AS prev_period_net_income
    FROM vw_pivoted_financial_matrix
    WHERE total_revenue IS NOT NULL
)
SELECT 
    company_name,
    cik,
    period,
    total_revenue,
    prev_period_revenue,
    CASE 
        WHEN prev_period_revenue IS NULL THEN NULL
        ELSE ROUND(CAST((total_revenue - prev_period_revenue) / NULLIF(prev_period_revenue, 0) * 100 AS NUMERIC), 2)
    END AS revenue_yoy_growth_pct,
    net_income,
    prev_period_net_income,
    CASE 
        WHEN prev_period_net_income IS NULL THEN NULL
        ELSE ROUND(CAST((net_income - prev_period_net_income) / NULLIF(ABS(prev_period_net_income), 0) * 100 AS NUMERIC), 2)
    END AS net_income_yoy_growth_pct
FROM ordered_metrics
ORDER BY company_name, period DESC;