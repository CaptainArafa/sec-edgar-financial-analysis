/*
 * File:           sql_scripts/03_raw_metric_extraction.sql
 * Object:         Raw US-GAAP Line Item Extraction
 * Description:    Joins submission metadata with numeric facts for target CIKs 
 *                 (Apple: 320193, Microsoft: 789019) to extract core statement metrics.
 */
SELECT 
    s.name,
    s.cik,
    s.form,
    s.period,
    n.tag,
    n.value,
    n.uom,
    n.qtrs
FROM sub s
INNER JOIN num n ON s.adsh = n.adsh
WHERE s.cik IN ('320193', '789019')
  AND s.form IN ('10-K', '10-Q')
  AND n.tag IN (
      'Revenues',
      'RevenueFromContractWithCustomerExcludingAssessedTax',
      'NetIncomeLoss',
      'AssetsCurrent',
      'LiabilitiesCurrent',
      'Assets',
      'Liabilities',
      'StockholdersEquity'
  )
ORDER BY s.name, n.tag;