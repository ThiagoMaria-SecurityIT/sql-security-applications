-- User Privilege Audit
-- Identifies users with excessive permissions or dormant admin accounts

-- Active users with admin privileges
SELECT 
    u.user_id,
    u.username,
    u.last_login,
    COUNT(DISTINCT p.permission) AS permission_count,
    SUM(CASE WHEN p.permission LIKE '%admin%' THEN 1 ELSE 0 END) AS admin_permissions,
    GROUP_CONCAT(DISTINCT p.permission ORDER BY p.permission SEPARATOR ', ') AS permissions
FROM 
    users u
JOIN 
    user_permissions p ON u.user_id = p.user_id
WHERE 
    u.is_active = 1
GROUP BY 
    u.user_id, u.username, u.last_login
HAVING 
    SUM(CASE WHEN p.permission LIKE '%admin%' THEN 1 ELSE 0 END) > 0
ORDER BY 
    permission_count DESC;

-- Dormant admin accounts (not logged in for 90+ days)
SELECT 
    u.user_id,
    u.username,
    u.last_login,
    DATEDIFF(CURRENT_DATE, u.last_login) AS days_since_login,
    GROUP_CONCAT(DISTINCT p.permission ORDER BY p.permission SEPARATOR ', ') AS permissions
FROM 
    users u
JOIN 
    user_permissions p ON u.user_id = p.user_id
WHERE 
    u.is_active = 1
    AND p.permission LIKE '%admin%'
    AND u.last_login < DATE_SUB(CURRENT_DATE, INTERVAL 90 DAY)
GROUP BY 
    u.user_id, u.username, u.last_login
ORDER BY 
    days_since_login DESC;

-- Orphaned accounts (users with permissions but marked inactive)
SELECT 
    u.user_id,
    u.username,
    u.last_login,
    GROUP_CONCAT(DISTINCT p.permission ORDER BY p.permission SEPARATOR ', ') AS permissions
FROM 
    users u
JOIN 
    user_permissions p ON u.user_id = p.user_id
WHERE 
    u.is_active = 0
GROUP BY 
    u.user_id, u.username, u.last_login;
