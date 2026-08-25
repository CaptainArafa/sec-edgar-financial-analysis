/*
 * File:           sql_scripts/04_pivoted_financial_matrix.sql
 * Object:         vw_pivoted_financial_matrix (Database View)
 * Description:    Creates a persistent relational view transforming vertical XBRL 
 *                 tags into a horizontal financial matrix for target entities.
 */
CREATE OR REPLACE VIEW vw_pivoted_financial_matrix AS
SELECT 
    s.name AS company_name,
    s.cik,
    s.form,
    s.fy,
    s.period,
    MAX(CASE WHEN n.tag IN ('Revenues', 'RevenueFromContractWithCustomerExcludingAssessedTax') THEN n.value END) AS total_revenue,
    MAX(CASE WHEN n.tag = 'NetIncomeLoss' THEN n.value END) AS net_income,
    MAX(CASE WHEN n.tag = 'AssetsCurrent' THEN n.value END) AS current_assets,
    MAX(CASE WHEN n.tag = 'LiabilitiesCurrent' THEN n.value END) AS current_liabilities,
    MAX(CASE WHEN n.tag = 'Assets' THEN n.value END) AS total_assets,
    MAX(CASE WHEN n.tag = 'Liabilities' THEN n.value END) AS total_liabilities,
    MAX(CASE WHEN n.tag = 'StockholdersEquity' THEN n.value END) AS stockholders_equity
FROM sub s
INNER JOIN num n ON s.adsh = n.adsh
WHERE s.cik IN ('320193', '789019')
  AND s.form IN ('10-K', '10-Q')
GROUP BY 
    s.name, 
    s.cik, 
    s.form, 
    s.fy, 
    s.period;