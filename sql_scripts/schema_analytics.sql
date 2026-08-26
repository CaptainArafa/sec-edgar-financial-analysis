-- 1. Create CIK Dimension Lookup Table
DROP TABLE IF EXISTS dim_company CASCADE;

CREATE TABLE dim_company AS
SELECT DISTINCT ON (cik)
    cik,
    name AS company_name,
    sic AS industry_code,
    ein AS tax_id,
    countryba AS country
FROM sub
WHERE cik IS NOT NULL
ORDER BY cik, period DESC;

-- Add Primary Key and Index
ALTER TABLE dim_company ADD PRIMARY KEY (cik);
CREATE INDEX IF NOT EXISTS idx_dim_company_name ON dim_company(company_name);

-- 2. Create 10-Year Financial Statement Core View
CREATE OR REPLACE VIEW v_10yr_financials AS
SELECT 
    c.cik,
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