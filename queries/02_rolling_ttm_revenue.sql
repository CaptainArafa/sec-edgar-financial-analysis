-- Description: Quarterly TTM (Trailing Twelve Months) Revenue Window Calculation
-- Sums current quarter plus prior 3 quarters using a SQL window frame.

WITH quarterly_rev AS (
    SELECT 
        c.ticker,
        v.period_end_date,
        v.fiscal_year,
        v.fiscal_period,
        v.amount_in_millions AS q_revenue
    FROM mv_10yr_financials v
    JOIN dim_company c ON v.cik = c.cik
    WHERE c.ticker IN ('NVDA', 'AAPL', 'MSFT', 'AMZN')
      AND v.qtrs = 1
      AND v.tag IN ('Revenues', 'RevenueFromContractWithCustomerExcludingAssessedTax')
)
SELECT 
    ticker,
    period_end_date,
    fiscal_year,
    fiscal_period,
    ROUND(q_revenue, 2) AS qtr_revenue_millions,
    ROUND(SUM(q_revenue) OVER (
        PARTITION BY ticker 
        ORDER BY period_end_date 
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ), 2) AS ttm_revenue_millions
FROM quarterly_rev
ORDER BY ticker, period_end_date DESC;