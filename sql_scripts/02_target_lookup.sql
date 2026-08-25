/*
 * File:           sql_scripts/02_target_lookup.sql
 * Object:         Target Entity CIK & Accession Identification
 * Description:    Retrieves exact unpadded CIKs and accession numbers (adsh)
 *                 for target peer entities (Apple and Microsoft).
 */
SELECT 
    name, 
    cik, 
    adsh, 
    form, 
    fy, 
    period
FROM sub
WHERE (cik IN ('320193', '789019') OR name ILIKE '%APPLE%' OR name ILIKE '%MICROSOFT%')
  AND form IN ('10-K', '10-Q')
ORDER BY name, period DESC;