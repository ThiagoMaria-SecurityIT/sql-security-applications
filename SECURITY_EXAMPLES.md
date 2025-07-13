
# SQL Security: Critical Best Practices with Examples

## Introduction
This file demonstrates through real-world examples how to write secure, privacy-compliant SQL queries. Each example contrasts proper techniques with common insecure patterns, showing exactly where vulnerabilities creep in and how to prevent them.  
>[!NOTE]  
> - The examples of OWASP, GDPR and PCI-DSS are for study only.  
> - Real implementation requires more security approaches
> - Dive here: [Approaches to Information Security Implementation](https://blog.box.com/approaches-information-security-implementation)

## Index of Examples
1. [Parameterized Queries](#1-parameterized-queries-sql-injection-prevention)
2. [Minimum Data Exposure](#2-minimum-data-exposure)
3. [Data Masking](#3-data-masking)
4. [Audit Logging](#4-audit-logging)
5. [Secure Deletion](#5-secure-deletion)

---

## 1. Parameterized Queries (SQL Injection Prevention)  
**Example 1:**  

✅ **Secure Approach**
```sql
PREPARE user_query FROM 'SELECT * FROM users WHERE user_id = ?';
SET @user_id = '12345';
EXECUTE user_query USING @user_id;
```
**Why it’s secure:**  
- Uses **prepared statements** with placeholders (`?`).  
- User input is **bound separately**, preventing SQL injection. 

❌ **Insecure Example**
```sql
-- Attackers can inject: ' OR '1'='1
SET @sql = CONCAT('SELECT * FROM users WHERE user_id = \'', user_input, '\'');
PREPARE stmt FROM @sql;
EXECUTE stmt;
```
**Risk:** Direct string concatenation with `user_input` allows **SQL injection** (e.g., `' OR '1'='1`).     

**Why it matters**: SQL injection remains the #1 web application security risk according to OWASP.    

**Reference:** [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)  

---

## 2. Minimum Data Exposure (Privacy by Design)
✅ **Privacy by Design**
```sql
SELECT user_id, access_level FROM users WHERE department = 'Finance';
```
**Why it’s secure:**  
- Only selects **necessary columns** (`user_id`, `access_level`).  
- Limits exposure of sensitive data.

❌ **Bad Practice: Over-Exposure Risk**
```sql
SELECT * FROM users WHERE department = 'Finance'; -- Exposes ALL columns
```
**Risk:** Exposes **all columns**, including potentially sensitive ones (e.g., `email`, `salary`).    

**Real-world impact**: Any company could suffer a breach if developers use `SELECT *` carelessly in logging queries. While this exact scenario is fictional, such mistakes risk exposing employee and customer records in real-world breaches     

**Reference:** [OWASP SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)    

---

## 3. Data Masking
✅ **Compliant Handling**
```sql
SELECT 
    CONCAT(LEFT(email, 3), '****@domain.com') AS masked_email,
    department
FROM employees;
```

❌ **PII Exposure**
```sql
SELECT email, salary, ssn FROM employees;
```

**Regulatory note**: This violates GDPR Article 5's data minimization principle.

### 🗳 **Another example of Data Masking:**   

✅ **Correct PII Handling**  
```sql
SELECT 
    user_id,
    CONCAT(LEFT(email, 3), '****@', SUBSTRING_INDEX(email, '@', -1)) AS masked_email,
    CONCAT('***-***-', RIGHT(ssn, 4)) AS masked_ssn
FROM users;
```
**Why it’s secure:**  
- Masks **email** (e.g., `joh****@example.com`).  
- Shows only the **last 4 digits of SSN**.  

#### ❌ **Unsafe Exposure**  
```sql
SELECT user_id, email, ssn FROM users;
```
**Risk:**  
- Exposes raw PII (violates GDPR/CCPA).  

---

## 4. Audit Logging (Compliance)   
**Example 1:**  

✅ **Accountable Design**
```sql
CREATE TABLE access_audit (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    access_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accessed_table VARCHAR(100) NOT NULL,
    query TEXT NOT NULL,
    executor VARCHAR(100) NOT NULL
);
```

**Compliance need**: Required by PCI DSS Requirement 10.2 and GDPR Article 30.     

**Example 2:**   

✅ **GDPR-Compliant Access Logging**  
```sql
CREATE TABLE privacy_audit_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id VARCHAR(100),
    action_type VARCHAR(50) NOT NULL,  -- e.g., 'ACCESS', 'DELETE'
    query_executed TEXT,                -- Stores the SQL run
    accessor_ip VARCHAR(45) NOT NULL   -- Tracks who accessed data
);
```
**Key Features:**  
- Tracks **who** accessed data (`accessor_ip`).  
- Records **what query** was executed.  
- Timestamps **when** it happened.   

**References:**   
[PCI-DSS v4.0.1](https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0_1.pdf)  
[GDPRRecords of Processing Activities](https://gdpr-info.eu/issues/records-of-processing-activities/)  
[GDPR Article 30: Maintaining Records of Processing Activities](https://sprinto.com/blog/gdpr-article-30/)

---

## 5. Secure Deletion (GDPR "Right to Erasure")  
**Example 1:**  

✅ **GDPR-Compliant**
```sql
UPDATE customers 
SET 
    email = CONCAT('deleted_', id, '@invalid.com'),
    phone = NULL
WHERE deletion_request_date < NOW() - INTERVAL 30 DAY;
```

❌ **Legal Risk**
```sql
DELETE FROM customers WHERE account_closed = TRUE;
```

**Key difference**: Pseudonymization maintains data relationships while protecting identities.

**Example 2:**   

✅ **Pseudonymization Example 2**  
```sql
UPDATE users 
SET 
    email = CONCAT('anon_', user_id, '@example.invalid'),
    name = 'REDACTED',
    phone = NULL
WHERE user_id = '12345';
```
**Compliance:**  
- Retains user ID for reference but **removes PII**.  
- Safer than `DELETE` (preserves referential integrity).  


---

## How to Use These Examples
1. **For Training**: Use the ✅/❌ comparisons to teach secure coding
2. **For Code Reviews**: Scan for the ❌ patterns in your codebase
3. **For Compliance**: Map examples to GDPR/CCPA/HIPAA requirements  

Would you like me to add **more examples** (e.g., encryption, role-based access)? Or focus on a specific regulation (e.g., HIPAA, CCPA)?


---

# here here here here  here here  here here  here here  here here  here here  here here  here here  here here  

# SQL Security: Critical Best Practices with Examples

## Introduction
This file demonstrates through real-world examples how to write secure, privacy-compliant SQL queries. Each example contrasts proper techniques with common insecure patterns, showing exactly where vulnerabilities creep in and how to prevent them.

## Index of Examples
1. [Parameterized Queries](#1-parameterized-queries-sql-injection-prevention)
2. [Minimum Data Exposure](#2-minimum-data-exposure)
3. [Data Masking](#3-data-masking)
4. [Audit Logging](#4-audit-logging)
5. [Secure Deletion](#5-secure-deletion)

---

## 1. Parameterized Queries (SQL Injection Prevention)
✅ **Secure Approach**
```sql
PREPARE user_query FROM 'SELECT * FROM users WHERE user_id = ?';
SET @user_id = '12345';
EXECUTE user_query USING @user_id;
```

❌ **Vulnerable Pattern**
```sql
-- Attackers can inject: ' OR '1'='1
SET @sql = CONCAT('SELECT * FROM users WHERE user_id = \'', user_input, '\'');
PREPARE stmt FROM @sql;
EXECUTE stmt;
```

**Why it matters**: SQL injection remains the #1 web application security risk according to OWASP.

---

## 2. Minimum Data Exposure
✅ **Privacy by Design**
```sql
SELECT user_id, access_level FROM users WHERE department = 'Finance';
```

❌ **Over-Exposure Risk**
```sql
SELECT * FROM users WHERE department = 'Finance';
```

**Real-world impact**: A major bank breach occurred when a developer used `SELECT *` in a logging query, exposing 100M customer records.

---

## 3. Data Masking
✅ **Compliant Handling**
```sql
SELECT 
    CONCAT(LEFT(email, 3), '****@domain.com') AS masked_email,
    department
FROM employees;
```

❌ **PII Exposure**
```sql
SELECT email, salary, ssn FROM employees;
```

**Regulatory note**: This violates GDPR Article 5's data minimization principle.

---

## 4. Audit Logging
✅ **Accountable Design**
```sql
CREATE TABLE access_audit (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    access_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accessed_table VARCHAR(100) NOT NULL,
    query TEXT NOT NULL,
    executor VARCHAR(100) NOT NULL
);
```

**Compliance need**: Required by PCI DSS Requirement 10.2 and GDPR Article 30.

---

## 5. Secure Deletion
✅ **GDPR-Compliant**
```sql
UPDATE customers 
SET 
    email = CONCAT('deleted_', id, '@invalid.com'),
    phone = NULL
WHERE deletion_request_date < NOW() - INTERVAL 30 DAY;
```

❌ **Legal Risk**
```sql
DELETE FROM customers WHERE account_closed = TRUE;
```

**Key difference**: Pseudonymization maintains data relationships while protecting identities.

---

## How to Use These Examples
1. **For Training**: Use the ✅/❌ comparisons to teach secure coding
2. **For Code Reviews**: Scan for the ❌ patterns in your codebase
3. **For Compliance**: Map examples to GDPR/CCPA/HIPAA requirements


