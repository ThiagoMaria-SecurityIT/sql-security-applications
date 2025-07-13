-- Failed Login Analysis
-- Identifies potential brute force attacks or compromised accounts

SELECT 
    user_id,
    source_ip,
    COUNT(*) AS failed_attempts,
    MIN(event_time) AS first_attempt,
    MAX(event_time) AS last_attempt,
    TIMESTAMPDIFF(MINUTE, MIN(event_time), MAX(event_time)) AS minutes_span
FROM 
    security_events
WHERE 
    event_type = 'login' 
    AND event_subtype = 'failed'
    AND event_time >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY 
    user_id, source_ip
HAVING 
    COUNT(*) > 5  -- Threshold for suspicious activity
ORDER BY 
    failed_attempts DESC;

-- Additional detail for a specific suspicious IP
SELECT 
    event_time,
    user_id,
    details
FROM 
    security_events
WHERE 
    source_ip = '192.168.1.100'  -- Example IP from above query
    AND event_type = 'login'
    AND event_subtype = 'failed'
ORDER BY 
    event_time DESC
LIMIT 50;
