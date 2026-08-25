/*
 * File:           sql_scripts/04_pivoted_financial_matrix.sql
 * Object:         vw_pivoted_financial_matrix (Database View)
 * Description:    Pivots tall XBRL tag structures into a unified horizontal financial matrix 
 *                 with expanded US-GAAP taxonomy tag aliases.
 */
CREATE OR REPLACE VIEW vw_pivoted_financial_matrix AS
SELECT 
    s.name AS company_name,
    s.cik,
    s.form,
    s.fy,
    s.period,
    MAX(CASE WHEN n.tag IN (
        'Revenues', 
        'RevenueFromContractWithCustomerExcludingAssessedTax', 
        'SalesRevenueNet', 
        'RevenuesNetOfInterestExpense',
        'FinancialServicesRevenue'
    ) THEN n.value END) AS total_revenue,
    
    MAX(CASE WHEN n.tag IN (
        'NetIncomeLoss', 
        'ProfitLoss', 
        'NetIncomeLossAvailableToCommonStockholdersBasic'
    ) THEN n.value END) AS net_income,
    
    MAX(CASE WHEN n.tag IN (
        'AssetsCurrent'
    ) THEN n.value END) AS current_assets,
    
    MAX(CASE WHEN n.tag IN (
        'LiabilitiesCurrent'
    ) THEN n.value END) AS current_liabilities,
    
    MAX(CASE WHEN n.tag IN (
        'Assets'
    ) THEN n.value END) AS total_assets,
    
    MAX(CASE WHEN n.tag IN (
        'Liabilities'
    ) THEN n.value END) AS total_liabilities,
    
    MAX(CASE WHEN n.tag IN (
        'StockholdersEquity', 
        'StockholdersEquityIncludingPortionAttributableToNoncontrollingInterest'
    ) THEN n.value END) AS stockholders_equity
FROM sub s
INNER JOIN num n ON s.adsh = n.adsh
WHERE s.form IN ('10-K', '10-Q')
GROUP BY 
    s.name, 
    s.cik, 
    s.form, 
    s.fy, 
    s.period;