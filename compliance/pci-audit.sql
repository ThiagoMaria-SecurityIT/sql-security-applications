/*
Purpose: PCI-DSS compliance audit queries
Author: Compliance Team
Date: 2025-07-13
Required Privileges: SELECT on payment_cards, access_logs, systems tables
*/

-- 1. PAN (Primary Account Number) storage verification
SELECT 
    'Cards stored with full PAN' AS check_type,
    COUNT(*) AS violations
FROM 
    payment_cards
WHERE 
    card_number NOT LIKE 'XXXX-XXXX-XXXX-%'
    AND card_number NOT LIKE '%%%%%%%%%%%%%';

-- 2. Access to cardholder data environment
SELECT 
    al.user_id,
    u.username,
    COUNT(*) AS access_count,
    MIN(al.access_time) AS first_access,
    MAX(al.access_time) AS last_access
FROM 
    access_logs al
JOIN 
    users u ON al.user_id = u.user_id
JOIN 
    systems s ON al.system_id = s.system_id
WHERE 
    s.environment = 'CARDHOLDER_DATA'
    AND al.access_time > CURRENT_DATE - INTERVAL 90 DAY
GROUP BY 
    al.user_id, u.username
ORDER BY 
    access_count DESC;

-- 3. Failed login attempts to sensitive systems
SELECT 
    se.source_ip,
    COUNT(*) AS failed_attempts,
    MIN(se.event_time) AS first_attempt,
    MAX(se.event_time) AS last_attempt,
    GROUP_CONCAT(DISTINCT se.user_id SEPARATOR ', ') AS attempted_users
FROM 
    security_events se
JOIN 
    systems s ON se.system_id = s.system_id
WHERE 
    se.event_type = 'login'
    AND se.event_subtype = 'failed'
    AND s.sensitivity_level = 'HIGH'
    AND se.event_time > CURRENT_DATE - INTERVAL 1 DAY
GROUP BY 
    se.source_ip
HAVING 
    COUNT(*) > 5
ORDER BY 
    failed_attempts DESC;

-- 4. Audit log coverage verification
SELECT 
    s.system_name,
    s.sensitivity_level,
    CASE 
        WHEN MAX(al.access_time) > CURRENT_TIMESTAMP - INTERVAL 1 DAY THEN 'OK'
        ELSE 'NO RECENT LOGS'
    END AS logging_status,
    MAX(al.access_time) AS last_logged_access
FROM 
    systems s
LEFT JOIN 
    access_logs al ON s.system_id = al.system_id
WHERE 
    s.sensitivity_level IN ('HIGH', 'MEDIUM')
GROUP BY 
    s.system_name, s.sensitivity_level
ORDER BY 
    logging_status, s.sensitivity_level DESC;

-- 5. Unencrypted sensitive data detection
SELECT 
    t.table_name,
    c.column_name,
    'Potential PCI violation' AS finding
FROM 
    information_schema.tables t
JOIN 
    information_schema.columns c ON t.table_name = c.table_name
WHERE 
    t.table_schema = DATABASE()
    AND c.column_name REGEXP 'pan|card|ccnum|cc_number|expdate|security_code|cvv'
    AND c.column_type NOT LIKE '%VARBINARY%'
    AND c.column_type NOT LIKE '%BLOB%';
