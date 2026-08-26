-- Description: YoY (Year-over-Year) Revenue Growth % Calculation
-- Uses LAG() analytic function to calculate top-line growth rate percentage.

WITH annual_rev AS (
    SELECT 
        c.ticker,
        v.fiscal_year,
        MAX(v.amount_in_millions) AS annual_revenue
    FROM mv_10yr_financials v
    JOIN dim_company c ON v.cik = c.cik
    WHERE c.ticker IN ('NVDA', 'AAPL', 'MSFT', 'AMZN')
      AND v.form = '10-K'
      AND v.tag IN ('Revenues', 'RevenueFromContractWithCustomerExcludingAssessedTax')
    GROUP BY c.ticker, v.fiscal_year
)
SELECT 
    ticker,
    fiscal_year,
    ROUND(annual_revenue, 2) AS revenue_millions,
    ROUND(LAG(annual_revenue, 1) OVER (PARTITION BY ticker ORDER BY fiscal_year), 2) AS prior_year_revenue,
    ROUND(
        ((annual_revenue - LAG(annual_revenue, 1) OVER (PARTITION BY ticker ORDER BY fiscal_year)) / 
        NULLIF(LAG(annual_revenue, 1) OVER (PARTITION BY ticker ORDER BY fiscal_year), 0)) * 100, 
        2
    ) AS yoy_growth_pct
FROM annual_rev
ORDER BY ticker, fiscal_year DESC;