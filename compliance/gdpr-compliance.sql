/*
Purpose: GDPR compliance monitoring queries
Author: Compliance Team
Date: 2025-07-13
Required Privileges: SELECT on users, user_data, access_logs tables
*/

-- 1. Right to be forgotten verification (check for data remnants)
SELECT 
    'Users marked for deletion but still in systems' AS check_type,
    COUNT(*) AS affected_records
FROM 
    users u
WHERE 
    u.deletion_request_date IS NOT NULL
    AND EXISTS (
        SELECT 1 FROM user_data ud 
        WHERE ud.user_id = u.user_id
    );

-- 2. Data access audit (who accessed personal data)
SELECT 
    al.access_time,
    al.accessor_id,
    u.username AS accessor_name,
    al.access_type,
    COUNT(DISTINCT al.record_id) AS personal_records_accessed,
    al.access_reason
FROM 
    access_logs al
JOIN 
    users u ON al.accessor_id = u.user_id
WHERE 
    al.access_time > CURRENT_DATE - INTERVAL 30 DAY
    AND al.data_category = 'PERSONAL'
GROUP BY 
    al.access_time, al.accessor_id, u.username, al.access_type, al.access_reason
ORDER BY 
    al.access_time DESC;

-- 3. Data export compliance (check for proper export logging)
SELECT 
    export_date,
    exporting_user,
    COUNT(*) AS records_exported,
    export_purpose,
    destination_country,
    CASE WHEN destination_country NOT IN ('EU', 'EEA') 
         THEN 'EXTRA CONTROLS NEEDED' ELSE 'OK' END AS transfer_assessment
FROM 
    data_exports
WHERE 
    export_date > CURRENT_DATE - INTERVAL 90 DAY
GROUP BY 
    export_date, exporting_user, export_purpose, destination_country
ORDER BY 
    export_date DESC;

-- 4. Consent management audit
SELECT 
    u.user_id,
    u.username,
    MAX(c.consent_date) AS last_consent_update,
    SUM(CASE WHEN c.consent_type = 'MARKETING' AND c.consent_given = 1 THEN 1 ELSE 0 END) AS marketing_consent,
    SUM(CASE WHEN c.consent_type = 'THIRD_PARTY' AND c.consent_given = 1 THEN 1 ELSE 0 END) AS third_party_consent,
    DATEDIFF(CURRENT_DATE, MAX(c.consent_date)) AS days_since_last_update
FROM 
    users u
LEFT JOIN 
    user_consents c ON u.user_id = c.user_id
GROUP BY 
    u.user_id, u.username
HAVING 
    days_since_last_update > 365 OR
    (marketing_consent = 1 AND DATEDIFF(CURRENT_DATE, MAX(c.consent_date)) > 90)
ORDER BY 
    days_since_last_update DESC;
