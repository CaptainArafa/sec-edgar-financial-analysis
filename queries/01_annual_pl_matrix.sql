-- Description: 10-Year Annual Income Statement Matrix (2016–2026)
-- Pivots row-based SEC tags into clean P&L financial statement columns.

SELECT 
    c.ticker,
    c.company_name,
    v.fiscal_year,
    MAX(CASE WHEN v.tag IN ('Revenues', 'RevenueFromContractWithCustomerExcludingAssessedTax') THEN ROUND(v.amount_in_millions, 2) END) AS revenue_millions,
    MAX(CASE WHEN v.tag = 'GrossProfit' THEN ROUND(v.amount_in_millions, 2) END) AS gross_profit_millions,
    MAX(CASE WHEN v.tag = 'OperatingIncomeLoss' THEN ROUND(v.amount_in_millions, 2) END) AS operating_income_millions,
    MAX(CASE WHEN v.tag = 'NetIncomeLoss' THEN ROUND(v.amount_in_millions, 2) END) AS net_income_millions
FROM mv_10yr_financials v
JOIN dim_company c ON v.cik = c.cik
WHERE c.ticker IN ('NVDA', 'AAPL', 'MSFT', 'AMZN')
  AND v.form = '10-K'
GROUP BY c.ticker, c.company_name, v.fiscal_year
ORDER BY c.ticker, v.fiscal_year DESC;