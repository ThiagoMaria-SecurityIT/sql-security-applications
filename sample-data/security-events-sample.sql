/*
 * SECURITY EVENT SAMPLE DATA

 * Under construction - July 13, 2025

 * Purpose: Provides realistic but 100% synthetic security event data for testing.
 * 
 * IMPORTANT:
 * - All data is artificially generated
 * - No real individuals, organizations, or incidents are represented
 * - IPs use RFC 5737 TEST-NET ranges (192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24)
 * - Timestamps range from 2023-01-01 to present
 */

-- Clear existing test data (safe for development)
DELETE FROM security_events WHERE event_id < 10000;

-- Insert 300+ varied security events
INSERT INTO security_events 
(event_id, event_time, event_type, event_subtype, source_ip, user_id, target_resource, details, severity, is_malicious, correlation_id)
VALUES
-- =============================================
-- 1. Authentication Events (120 samples)
-- =============================================
-- Failed logins (40 samples)
(10001, '2023-01-05 08:23:45', 'authentication', 'failed', '192.0.2.15', 'user42', 'CRM', 'Invalid password', 'medium', FALSE, NULL),
(10002, '2023-01-05 08:24:01', 'authentication', 'failed', '192.0.2.15', 'user42', 'CRM', 'Invalid password', 'medium', FALSE, NULL),
(10003, '2023-01-05 08:24:17', 'authentication', 'failed', '192.0.2.15', 'user42', 'CRM', 'Invalid password', 'high', TRUE, 'brute-force-1'),

-- Successful logins (40 samples)
(10051, '2023-01-10 09:01:33', 'authentication', 'success', '203.0.113.78', 'admin7', 'Admin Panel', 'MFA verified', 'low', FALSE, NULL),
(10052, '2023-01-10 09:15:22', 'authentication', 'success', '198.51.100.22', 'user189', 'Mobile App', 'Biometric auth', 'low', FALSE, NULL),

-- Account lockouts (20 samples)
(10101, '2023-01-15 11:30:45', 'authentication', 'lockout', '192.0.2.89', 'user56', 'SSO Gateway', '5 failed attempts', 'high', FALSE, 'lockout-2023-01-56'),

-- Password resets (20 samples)
(10151, '2023-01-20 14:22:10', 'authentication', 'reset', '10.5.1.33', 'user12', 'Portal', 'Password changed', 'low', FALSE, NULL),

-- =============================================
-- 2. Threat Detection Events (90 samples)
-- =============================================
-- SQLi attempts (30 samples)
(10201, '2023-02-01 03:45:12', 'threat', 'sql_injection', '185.143.223.10', NULL, 'API Gateway', 'Detected "1=1" in query', 'critical', TRUE, 'sqli-attempt-5'),
(10202, '2023-02-01 03:47:33', 'threat', 'sql_injection', '185.143.223.10', NULL, 'API Gateway', 'UNION SELECT detected', 'critical', TRUE, 'sqli-attempt-6'),

-- XSS attempts (20 samples)
(10251, '2023-02-05 12:33:41', 'threat', 'xss', '45.227.253.18', NULL, 'Contact Form', '<script>alert()</script> payload', 'high', TRUE, 'xss-attempt-22'),

-- Brute force patterns (20 samples)
(10301, '2023-02-10 18:22:15', 'threat', 'brute_force', '192.0.2.67', NULL, 'VPN Portal', '15 failed attempts in 5m', 'critical', TRUE, 'vpn-brute-3'),

-- Malware detection (20 samples)
(10351, '2023-02-15 09:11:37', 'threat', 'malware', '198.51.100.204', 'user33', 'Workstation-45', 'Ransomware signature detected', 'critical', TRUE, 'malware-2023-02-33'),

-- =============================================
-- 3. Configuration Changes (60 samples)
-- =============================================
-- Firewall modifications (20 samples)
(10401, '2023-03-01 14:30:11', 'configuration', 'firewall', '10.10.1.5', 'sysadmin3', 'FW-Router01', 'Rule added: port 443', 'high', FALSE, 'change-443'),
(10402, '2023-03-01 14:31:22', 'configuration', 'firewall', '10.10.1.5', 'sysadmin3', 'FW-Router01', 'Rule removed: port 22', 'high', FALSE, 'change-ssh'),

-- User permission changes (20 samples)
(10451, '2023-03-05 11:05:33', 'configuration', 'permission', '10.8.2.7', 'admin1', 'AD Server', 'Added admin rights to user89', 'high', FALSE, 'perm-change-89'),

-- System patches (20 samples)
(10501, '2023-03-10 03:00:12', 'configuration', 'patch', '10.7.1.1', 'automation', 'WSUS Server', 'Applied MS23-011', 'medium', FALSE, 'patch-2023-03-011'),

-- =============================================
-- 4. Data Access Events (60 samples)
-- =============================================
-- Bulk exports (20 samples)
(10551, '2023-04-01 11:22:09', 'access', 'export', '10.10.2.7', 'analyst9', 'DB-Report', 'Exported 1000 customer records', 'medium', FALSE, 'export-2023-04'),
(10552, '2023-04-01 11:25:18', 'access', 'export', '10.10.2.7', 'analyst9', 'DB-Report', 'Exported payment history', 'high', FALSE, 'export-2023-04-payments'),

-- Privileged access (20 samples)
(10601, '2023-04-05 16:45:33', 'access', 'privileged', '10.5.1.12', 'dba2', 'Prod-DB-03', 'Executed schema change', 'high', FALSE, 'db-change-2023-04'),

-- Unusual access patterns (20 samples)
(10651, '2023-04-10 22:15:41', 'access', 'anomalous', '192.0.2.199', 'contractor5', 'HR-DB', 'Accessed records after hours', 'high', TRUE, 'hr-access-2023-04'),

-- =============================================
-- 5. System Events (70 samples)
-- =============================================
-- Backups (20 samples)
(10701, '2023-05-01 02:00:00', 'system', 'backup', '10.9.1.1', 'backup-svc', 'NAS-01', 'Full backup completed', 'low', FALSE, 'backup-2023-05'),

-- Restarts (20 samples)
(10751, '2023-05-05 04:30:22', 'system', 'restart', '10.10.1.1', 'automation', 'WebServer-02', 'Scheduled maintenance', 'medium', FALSE, 'maint-2023-05'),

-- Disk alerts (15 samples)
(10801, '2023-05-10 08:45:11', 'system', 'alert', '10.7.3.5', NULL, 'Fileserver-01', 'Disk 95% full', 'high', FALSE, 'disk-alert-2023-05'),

-- AV scans (15 samples)
(10851, '2023-05-15 12:30:45', 'system', 'scan', '10.6.2.8', 'av-svc', 'Workstation-78', 'Malware scan clean', 'low', FALSE, 'scan-2023-05-78');

-- Generate 200 additional random events
INSERT INTO security_events 
(event_time, event_type, event_subtype, source_ip, user_id, target_resource, details, severity, is_malicious)
SELECT 
    TIMESTAMPADD(SECOND, FLOOR(RAND() * 15768000), '2023-01-01 00:00:00'), -- Random timestamp in 2023
    ELT(FLOOR(RAND() * 5) + 1, 'authentication', 'threat', 'configuration', 'access', 'system'),
    CASE 
        WHEN event_type = 'authentication' THEN ELT(FLOOR(RAND() * 4) + 1, 'success', 'failed', 'lockout', 'reset')
        WHEN event_type = 'threat' THEN ELT(FLOOR(RAND() * 5) + 1, 'sql_injection', 'xss', 'brute_force', 'malware', 'phishing')
        WHEN event_type = 'configuration' THEN ELT(FLOOR(RAND() * 4) + 1, 'firewall', 'permission', 'patch', 'user')
        ELSE ELT(FLOOR(RAND() * 3) + 1, 'export', 'privileged', 'anomalous')
    END,
    CASE 
        WHEN FLOOR(RAND() * 10) > 7 THEN CONCAT('10.', FLOOR(RAND() * 10), '.', FLOOR(RAND() * 254)+1, '.', FLOOR(RAND() * 254)+1) -- Internal
        ELSE CONCAT(ELT(FLOOR(RAND() * 3) + 1, '192.0.2.', '198.51.100.', '203.0.113.'), FLOOR(RAND() * 254)+1) -- TEST-NET
    END,
    CASE WHEN FLOOR(RAND() * 10) > 3 THEN CONCAT('user', FLOOR(RAND() * 200)) ELSE NULL END,
    ELT(FLOOR(RAND() * 8) + 1, 'CRM', 'Admin Panel', 'API Gateway', 'Database', 'Fileserver', 'VPN', 'Workstation', 'Mobile App'),
    CONCAT('Sample ', event_type, ' event - ', UUID()),
    ELT(FLOOR(RAND() * 4) + 1, 'low', 'medium', 'high', 'critical'),
    FLOOR(RAND() * 10) = 9 -- 10% chance of being malicious
FROM 
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) a
    CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) b
    CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c;
