/*
 * File:           sql_scripts/06_market_percentile_analysis.sql
 * Object:         Cross-Sectional Market Benchmarking & Window Analytics
 * Description:    Utilizes SQL window functions (NTILE, PERCENT_RANK, AVG OVER) to compute 
 *                 market-wide percentile ranks and baseline comparisons for single-quarter filings.
 */
WITH market_base AS (
    SELECT 
        company_name,
        cik,
        period,
        total_revenue,
        net_income,
        ROUND(CAST(net_income / NULLIF(total_revenue, 0) * 100 AS NUMERIC), 2) AS net_margin_pct,
        ROUND(CAST(current_assets / NULLIF(current_liabilities, 0) AS NUMERIC), 2) AS current_ratio
    FROM vw_pivoted_financial_matrix
    WHERE total_revenue IS NOT NULL 
      AND total_revenue > 0
      AND net_income IS NOT NULL
)
SELECT 
    company_name,
    cik,
    period,
    total_revenue,
    net_margin_pct,
    current_ratio,
    
    -- Market Averages (Explicit CAST to NUMERIC resolves PostgreSQL function signature error)
    ROUND(CAST(AVG(total_revenue) OVER () AS NUMERIC), 2) AS market_avg_revenue,
    ROUND(CAST(AVG(net_margin_pct) OVER () AS NUMERIC), 2) AS market_avg_margin_pct,
    
    -- Market Quartile and Percentile Ranks
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile,
    ROUND(CAST(PERCENT_RANK() OVER (ORDER BY net_margin_pct ASC) * 100 AS NUMERIC), 2) AS margin_percentile_rank
FROM market_base
ORDER BY total_revenue DESC;