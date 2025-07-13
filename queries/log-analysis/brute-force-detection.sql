/*
Purpose: Identify potential brute force attacks against user accounts
Author: Security Team
Date: 2025-07-13
Required Privileges: SELECT on security_events table
Performance Notes: Index on (event_type, event_subtype, source_ip, event_time) recommended
*/

-- 1. Classic brute force patterns (many failures from single IP)
SELECT 
    source_ip,
    COUNT(DISTINCT user_id) AS targeted_accounts,
    COUNT(*) AS total_attempts,
    MIN(event_time) AS first_attempt,
    MAX(event_time) AS last_attempt,
    TIMESTAMPDIFF(MINUTE, MIN(event_time), MAX(event_time)) AS duration_minutes,
    /* Calculate attempts per minute */
    COUNT(*)/GREATEST(1, TIMESTAMPDIFF(MINUTE, MIN(event_time), MAX(event_time))) AS attempts_per_minute
FROM 
    security_events
WHERE 
    event_type = 'login'
    AND event_subtype = 'failed'
    AND event_time > CURRENT_TIMESTAMP - INTERVAL 15 MINUTE
GROUP BY 
    source_ip
HAVING 
    COUNT(*) > 10  -- Threshold for brute force
ORDER BY 
    total_attempts DESC;

-- 2. Distributed brute force (many IPs targeting single account)
SELECT 
    user_id,
    COUNT(DISTINCT source_ip) AS attacking_ips,
    COUNT(*) AS total_attempts,
    MIN(event_time) AS first_attempt,
    MAX(event_time) AS last_attempt,
    GROUP_CONCAT(DISTINCT source_ip SEPARATOR ', ') AS ip_list
FROM 
    security_events
WHERE 
    event_type = 'login'
    AND event_subtype = 'failed'
    AND event_time > CURRENT_TIMESTAMP - INTERVAL 1 HOUR
GROUP BY 
    user_id
HAVING 
    COUNT(DISTINCT source_ip) > 3  -- Multiple IPs targeting same account
ORDER BY 
    attacking_ips DESC;

-- 3. Password spray detection (single IP trying common passwords across accounts)
SELECT 
    source_ip,
    COUNT(DISTINCT user_id) AS accounts_targeted,
    COUNT(*) AS total_attempts,
    SUM(CASE WHEN details LIKE '%CommonPassword1%' THEN 1 ELSE 0 END) AS CommonPassword1_attempts,
    SUM(CASE WHEN details LIKE '%Welcome123%' THEN 1 ELSE 0 END) AS Welcome123_attempts,
    SUM(CASE WHEN details LIKE '%Password2023%' THEN 1 ELSE 0 END) AS Password2023_attempts
FROM 
    security_events
WHERE 
    event_type = 'login'
    AND event_subtype = 'failed'
    AND event_time > CURRENT_TIMESTAMP - INTERVAL 24 HOUR
GROUP BY 
    source_ip
HAVING 
    COUNT(DISTINCT user_id) > 5  # Targeting many accounts
    AND (
        SUM(CASE WHEN details LIKE '%CommonPassword1%' THEN 1 ELSE 0 END) > 0 OR
        SUM(CASE WHEN details LIKE '%Welcome123%' THEN 1 ELSE 0 END) > 0 OR
        SUM(CASE WHEN details LIKE '%Password2023%' THEN 1 ELSE 0 END) > 0
    )
ORDER BY 
    accounts_targeted DESC;
