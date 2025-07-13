/*
Purpose: Detect potentially compromised accounts through suspicious login patterns
Author: Security Team
Date: 2025-07-13
Required Privileges: SELECT on security_events, users tables
Performance Notes: Requires indexes on (user_id, event_time)
*/

-- 1. Logins from unusual locations (geographic anomalies)
SELECT 
    u.user_id,
    u.username,
    COUNT(DISTINCT l.country) AS distinct_countries,
    GROUP_CONCAT(DISTINCT l.country ORDER BY l.country SEPARATOR ', ') AS countries,
    MIN(l.event_time) AS first_login,
    MAX(l.event_time) AS last_login
FROM 
    users u
JOIN 
    (SELECT user_id, event_time, country 
     FROM security_events 
     WHERE event_type = 'login' AND event_subtype = 'success') l 
    ON u.user_id = l.user_id
WHERE 
    u.last_login > CURRENT_DATE - INTERVAL 30 DAY
GROUP BY 
    u.user_id, u.username
HAVING 
    COUNT(DISTINCT l.country) > 2
ORDER BY 
    distinct_countries DESC;

-- 2. Impossible travel scenarios (logins from distant locations within short time)
SELECT 
    a.user_id,
    a.username,
    a.event_time AS first_login_time,
    a.country AS first_country,
    b.event_time AS second_login_time,
    b.country AS second_country,
    TIMESTAMPDIFF(MINUTE, a.event_time, b.event_time) AS minutes_between,
    /* Assume 500 miles/hour as reasonable travel speed threshold */
    CASE WHEN TIMESTAMPDIFF(MINUTE, a.event_time, b.event_time) < 
         (get_distance_miles(a.country, b.country)/500)*60 
         THEN 'IMPOSSIBLE TRAVEL' ELSE 'POSSIBLE' END AS travel_assessment
FROM 
    (SELECT se.*, u.username 
     FROM security_events se JOIN users u ON se.user_id = u.user_id
     WHERE event_type = 'login' AND event_subtype = 'success') a
JOIN 
    (SELECT se.* FROM security_events se 
     WHERE event_type = 'login' AND event_subtype = 'success') b
    ON a.user_id = b.user_id 
    AND a.event_time < b.event_time 
    AND a.country <> b.country
WHERE 
    a.event_time > CURRENT_DATE - INTERVAL 1 DAY
    AND b.event_time < a.event_time + INTERVAL 6 HOUR
ORDER BY 
    minutes_between ASC;
