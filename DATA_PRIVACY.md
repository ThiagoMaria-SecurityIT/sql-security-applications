# DATA PRIVACY  

## Data Handling Standards

### 1. Personal Identifiable Information (PII) Protection
All SQL examples must demonstrate proper PII handling:

```sql
-- Correct: Data masking in queries
SELECT 
    user_id,
    CONCAT(LEFT(email, 3), '****@', SUBSTRING_INDEX(email, '@', -1)) AS masked_email,
    CONCAT('***-***-', RIGHT(ssn, 4)) AS masked_ssn
FROM users;

-- Avoid: Direct exposure of sensitive data
SELECT user_id, email, ssn FROM users;  -- NEVER use this in examples
```

### 2. Sample Data Requirements
All test data must use obviously fake values following these patterns:
- Emails: `testuser[1-100]@example.com`
- Phone numbers: `+1-555-01[0-9][0-9]-[0-9][0-9][0-9][0-9]`
- IP addresses: Use TEST-NET ranges (`192.0.2.0/24`, `198.51.100.0/24`)
- Credit cards: `4111-1111-1111-1111` (test Visa) or `5555-5555-5555-4444` (test Mastercard)

### 3. Compliance Demonstration Examples

#### GDPR Implementation
```sql
-- Right to Erasure implementation
CREATE PROCEDURE anon_user_data(IN p_user_id VARCHAR(100))
BEGIN
    -- Pseudonymize user data
    UPDATE users 
    SET email = CONCAT('anon_', p_user_id, '@example.com'),
        phone = CONCAT('+155501', FLOOR(RAND() * 900 + 100)),
        name = CONCAT('Anonymous ', FLOOR(RAND() * 1000))
    WHERE user_id = p_user_id;
    
    -- Maintain audit trail
    INSERT INTO erasure_log (user_id, erased_at, erased_by)
    VALUES (p_user_id, NOW(), CURRENT_USER());
END;

-- Data Portability example
SELECT 
    user_id,
    username,
    email,
    created_at,
    last_login
FROM users
WHERE user_id = '12345'
INTO OUTFILE '/secure_exports/user_12345_data.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"';
```

#### CCPA Implementation
```sql
-- Opt-Out Tracking
CREATE TABLE privacy_opt_outs (
    record_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(100) NOT NULL,
    opt_out_type ENUM('SALE', 'MARKETING', 'TRACKING') NOT NULL,
    opted_out_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verification_method VARCHAR(50),
    INDEX idx_user_optouts (user_id, opt_out_type)
);

-- Data Access Logging
CREATE PROCEDURE log_data_access(
    IN p_user_id VARCHAR(100),
    IN p_accessor_id VARCHAR(100),
    IN p_purpose VARCHAR(255)
)
BEGIN
    INSERT INTO data_access_logs (
        user_id,
        accessor_id,
        access_time,
        accessed_tables,
        access_purpose
    )
    SELECT 
        p_user_id,
        p_accessor_id,
        NOW(),
        GROUP_CONCAT(DISTINCT TABLE_NAME),
        p_purpose
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
    AND COLUMN_NAME IN ('email', 'phone', 'address', 'payment_info');
END;
```

## Security Best Practices

### Query Construction Standards
1. **Always use parameterized queries**:
```sql
-- Secure
PREPARE user_query FROM 'SELECT * FROM users WHERE user_id = ?';
SET @user_id = '12345';
EXECUTE user_query USING @user_id;

-- Insecure (SQL injection risk)
SET @sql = CONCAT('SELECT * FROM users WHERE user_id = \'', user_input, '\'');
PREPARE stmt FROM @sql;
EXECUTE stmt;
```

2. **Minimum data exposure**:
```sql
-- Good: Only request needed columns
SELECT user_id, access_level FROM users WHERE department = 'Finance';

-- Bad: Unrestricted data access
SELECT * FROM users WHERE department = 'Finance';
```

### Audit Requirements
All privacy-relevant queries must:
1. Include timestamp of access
2. Record the accessing user/application
3. Document the access purpose
4. Support correlation with consent records

```sql
-- Example audit table
CREATE TABLE privacy_audit_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    event_time TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
    user_id VARCHAR(100),
    action_type VARCHAR(50) NOT NULL,
    affected_record_type VARCHAR(50) NOT NULL,
    affected_record_id VARCHAR(100),
    query_executed TEXT,
    accessed_columns JSON,
    accessor_id VARCHAR(100) NOT NULL,
    accessor_ip VARCHAR(45) NOT NULL,
    compliance_reason VARCHAR(255),
    consent_reference VARCHAR(100),
    INDEX idx_privacy_events (user_id, event_time),
    INDEX idx_audit_actions (action_type, affected_record_type)
);
```

## Data Retention Rules

### Sample Retention Policies
```sql
-- GDPR Right to Be Forgotten implementation
CREATE EVENT purge_erased_users
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    -- Anonymize users marked for deletion after 30-day hold
    UPDATE users 
    SET 
        email = CONCAT('deleted_', user_id, '@example.invalid'),
        name = 'Deleted User',
        phone = NULL,
        is_active = FALSE,
        metadata = JSON_SET(metadata, '$.erasure_date', NOW())
    WHERE deletion_request_date < NOW() - INTERVAL 30 DAY
    AND is_active = TRUE;
    
    -- Log the erasure
    INSERT INTO erasure_audit (user_id, erased_at)
    SELECT user_id, NOW() 
    FROM users 
    WHERE deletion_request_date < NOW() - INTERVAL 30 DAY
    AND is_active = TRUE;
END;

-- Log retention policy
CREATE PROCEDURE rotate_logs()
BEGIN
    -- Archive logs older than 1 year
    INSERT INTO log_archive
    SELECT * FROM system_logs
    WHERE log_timestamp < NOW() - INTERVAL 1 YEAR;
    
    -- Delete archived logs
    DELETE FROM system_logs
    WHERE log_timestamp < NOW() - INTERVAL 1 YEAR;
    
    -- Compress archived logs
    UPDATE log_archive
    SET log_data = COMPRESS(log_data)
    WHERE compression_status = 'UNCOMPRESSED'
    AND archive_time < NOW() - INTERVAL 1 MONTH;
END;
```

## Testing Requirements

1. All privacy-related queries must be tested with:
   - Empty result sets
   - Partial matches
   - Full matches
   - SQL injection attempts

2. Sample test cases:
```sql
-- Test data minimization
EXPLAIN SELECT email FROM users WHERE user_id = 'test123';
-- Verify only 'email' column is accessed

-- Test pseudonymization
SELECT * FROM users WHERE user_id = 'anon_12345';
-- Verify no real PII is exposed

-- Test audit logging
CALL access_user_data('admin', '12345', 'GDPR request');
SELECT * FROM privacy_audit_log ORDER BY event_time DESC LIMIT 1;
-- Verify complete audit trail
```
