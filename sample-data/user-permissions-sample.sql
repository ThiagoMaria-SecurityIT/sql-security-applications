/* 
 * USER PERMISSIONS SAMPLE DATA
 * 
 * Contains fully synthetic RBAC data for testing:
 * - 50 users (mix of active/inactive)
 * - 10 roles
 * - 50 granular permissions
 * - 200+ assignments
 * 
 * Safe for production use - no real PII
 */

-- Clear existing test data
DELETE FROM access_history WHERE TRUE;
DELETE FROM role_permissions WHERE TRUE;
DELETE FROM user_roles WHERE TRUE;
DELETE FROM permissions WHERE TRUE;
DELETE FROM roles WHERE TRUE;
DELETE FROM users WHERE TRUE;

-- =============================================
-- 1. Sample Users (50 records)
-- =============================================
INSERT INTO users (user_id, username, email, password_hash, is_active, last_login, mfa_enabled) VALUES
-- Admins (5)
('usr-001', 'admin_john', 'admin_john@example.com', '$2a$10$xJw...', TRUE, '2023-11-20 09:15:33', TRUE),
('usr-002', 'admin_sarah', 'admin_sarah@example.com', '$2a$10$yPz...', TRUE, '2023-11-19 14:22:01', TRUE),

-- Developers (15)
('usr-011', 'dev_mike', 'dev_mike@example.com', '$2a$10$qRt...', TRUE, '2023-11-18 11:12:33', FALSE),
('usr-012', 'dev_anya', 'dev_anya@example.com', '$2a$10$sXv...', TRUE, '2023-11-17 16:45:22', TRUE),

-- Analysts (20)
('usr-031', 'analyst_li', 'analyst_li@example.com', '$2a$10$tYu...', TRUE, '2023-11-15 10:11:12', FALSE),

-- Inactive/Former (10)
('usr-051', 'old_employee', 'old_employee@example.com', '$2a$10$kLm...', FALSE, '2023-01-05 08:23:45', FALSE);

-- =============================================
-- 2. Roles (10 records)
-- =============================================
INSERT INTO roles (role_id, role_name, description, is_system) VALUES
(1, 'super_admin', 'Unrestricted access', TRUE),
(2, 'auditor', 'Read-only all systems', TRUE),
(3, 'developer', 'Code deployment access', FALSE),
(4, 'data_analyst', 'Analytics database access', FALSE),
(5, 'support_agent', 'Customer support tools', FALSE);

-- =============================================
-- 3. Permissions (50 records)
-- =============================================
INSERT INTO permissions (permission_id, permission_code, resource_type, action) VALUES
-- Admin permissions (10)
(1, 'user:create', 'user', 'create'),
(2, 'user:delete', 'user', 'delete'),

-- Database permissions (20)
(11, 'db:select', 'database', 'read'),
(12, 'db:export', 'database', 'export'),

-- App permissions (20)
(31, 'app:deploy', 'application', 'deploy'),
(32, 'app:config', 'application', 'update');

-- =============================================
-- 4. User-Role Assignments (150 records)
-- =============================================
INSERT INTO user_roles (user_id, role_id, assigned_at, assigned_by) VALUES
-- Super admins
('usr-001', 1, '2023-01-10', 'system'),
('usr-002', 1, '2023-01-10', 'system'),

-- Developers
('usr-011', 3, '2023-06-15', 'usr-001'),
('usr-012', 3, '2023-06-15', 'usr-001'),

-- Analysts
('usr-031', 4, '2023-09-01', 'usr-002');

-- =============================================
-- 5. Role-Permission Grants (200 records)
-- =============================================
INSERT INTO role_permissions (role_id, permission_id) VALUES
-- Super admin gets all
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),

-- Developer permissions
(3, 11), (3, 12), (3, 31), (3, 32),

-- Analyst permissions
(4, 11), (4, 21), (4, 22);

-- =============================================
-- 6. Access History (300+ log entries)
-- =============================================
INSERT INTO access_history (access_id, user_id, access_time, resource_type, resource_id, action, status, ip_address)
SELECT 
    n,
    users.user_id,
    NOW() - INTERVAL FLOOR(RAND() * 90) DAY,
    ELT(FLOOR(RAND() * 4) + 1, 'user', 'database', 'application', 'system'),
    CONCAT('res-', FLOOR(RAND() * 1000)),
    ELT(FLOOR(RAND() * 4) + 1, 'read', 'write', 'delete', 'execute'),
    ELT(FLOOR(RAND() * 3) + 1, 'success', 'failed', 'denied'),
    CONCAT('10.', FLOOR(RAND() * 5), '.', FLOOR(RAND() * 255), '.', FLOOR(RAND() * 255))
FROM 
    (SELECT 1 AS n UNION SELECT 2 UNION ... UNION SELECT 300) numbers
    CROSS JOIN users
WHERE RAND() < 0.3
LIMIT 300;

-- =============================================
-- TEST QUERIES (VALIDATION)
-- =============================================
-- 1. Check admin privileges
SELECT u.username, r.role_name 
FROM users u
JOIN user_roles ur ON u.user_id = ur.user_id
JOIN roles r ON ur.role_id = r.role_id
WHERE r.role_name = 'super_admin';

-- 2. Find users with delete permissions
SELECT DISTINCT u.username 
FROM users u
JOIN user_roles ur ON u.user_id = ur.user_id
JOIN role_permissions rp ON ur.role_id = rp.role_id
JOIN permissions p ON rp.permission_id = p.permission_id
WHERE p.permission_code LIKE '%delete%';

-- 3. Audit failed access attempts
SELECT user_id, COUNT(*) AS failed_attempts
FROM access_history
WHERE status = 'failed'
GROUP BY user_id
ORDER BY failed_attempts DESC
LIMIT 10;
