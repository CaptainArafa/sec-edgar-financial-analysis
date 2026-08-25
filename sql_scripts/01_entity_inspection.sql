/*
 * File:           sql_scripts/01_entity_inspection.sql
 * Object:         Entity & CIK Format Verification
 * Description:    Inspects distinct company names, CIK string formatting, 
 *                 and filing types present in the submission table.
 */
SELECT DISTINCT 
    name, 
    cik, 
    form, 
    fy, 
    period
FROM sub
WHERE form IN ('10-K', '10-Q')
ORDER BY name ASC
LIMIT 25;