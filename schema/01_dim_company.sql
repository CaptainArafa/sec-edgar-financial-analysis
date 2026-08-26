-- Description: Creates the primary CIK-to-Company dimension lookup table.

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

ALTER TABLE dim_company ADD PRIMARY KEY (cik);
CREATE INDEX IF NOT EXISTS idx_dim_company_name ON dim_company(company_name);