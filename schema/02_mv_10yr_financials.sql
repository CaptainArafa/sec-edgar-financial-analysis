-- Description: Materialized View pre-aggregating 10-year SEC financial line items for instant query performance.

DROP MATERIALIZED VIEW IF EXISTS mv_10yr_financials CASCADE;

CREATE MATERIALIZED VIEW mv_10yr_financials AS
SELECT 
    c.cik,
    c.ticker,
    c.company_name,
    s.form,
    s.fy AS fiscal_year,
    s.fp AS fiscal_period,
    n.ddate AS period_end_date,
    n.tag,
    CAST(n.value AS NUMERIC) / 1000000.0 AS amount_in_millions,
    n.qtrs
FROM sub s
JOIN dim_company c ON s.cik = c.cik
JOIN num n ON s.adsh = n.adsh
WHERE s.form IN ('10-K', '10-Q')
  AND n.tag IN (
      'Revenues', 
      'RevenueFromContractWithCustomerExcludingAssessedTax',
      'OperatingIncomeLoss', 
      'NetIncomeLoss', 
      'GrossProfit'
  )
  AND n.qtrs IN (1, 4);

CREATE INDEX idx_mv_10yr_ticker_tag ON mv_10yr_financials(ticker, tag, fiscal_year);