/*
 * File:           sql_scripts/05_financial_ratio_analysis.sql
 * Object:         Financial Ratio Analytics & Liquidity Assessment
 * Description:    Calculates core financial ratios from vw_pivoted_financial_matrix 
 *                 filtering for valid income statement entries.
 */
SELECT 
    company_name,
    period,
    total_revenue,
    net_income,
    
    -- Liquidity Metrics
    (current_assets - current_liabilities) AS working_capital,
    ROUND(CAST(current_assets / NULLIF(current_liabilities, 0) AS NUMERIC), 2) AS current_ratio,
    
    -- Profitability Metrics
    ROUND(CAST(net_income / NULLIF(total_revenue, 0) * 100 AS NUMERIC), 2) AS net_profit_margin_pct,
    ROUND(CAST(net_income / NULLIF(total_assets, 0) * 100 AS NUMERIC), 2) AS return_on_assets_pct,
    
    -- Leverage & Solvency Metrics
    ROUND(CAST(total_liabilities / NULLIF(stockholders_equity, 0) AS NUMERIC), 2) AS debt_to_equity_ratio,
    ROUND(CAST(total_liabilities / NULLIF(total_assets, 0) * 100 AS NUMERIC), 2) AS debt_ratio_pct
FROM vw_pivoted_financial_matrix
WHERE total_revenue IS NOT NULL 
  AND net_income IS NOT NULL
ORDER BY total_revenue DESC;