-- Security Event Logging Schema
CREATE TABLE security_events (
    event_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_type VARCHAR(50) NOT NULL,          -- 'login', 'access', 'config_change', etc.
    event_subtype VARCHAR(50),                -- 'success', 'failed', 'denied', etc.
    source_ip VARCHAR(45) NOT NULL,            -- Supports IPv6 addresses
    user_id VARCHAR(100),                      -- Could be username, email, or ID
    target_resource VARCHAR(255),              -- What was accessed/changed
    details TEXT,                              -- Full event details
    severity ENUM('low', 'medium', 'high', 'critical'),
    is_malicious BOOLEAN DEFAULT FALSE,
    correlation_id VARCHAR(100)                -- For linking related events
);

-- Indexes for faster querying
CREATE INDEX idx_event_time ON security_events(event_time);
CREATE INDEX idx_event_type ON security_events(event_type);
CREATE INDEX idx_user_id ON security_events(user_id);
CREATE INDEX idx_source_ip ON security_events(source_ip);

-- User Access Audit Table
CREATE TABLE user_access_audit (
    audit_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(100) NOT NULL,
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_type VARCHAR(50) NOT NULL,          -- 'login', 'logout', 'privilege_change'
    action_status VARCHAR(20) NOT NULL,        -- 'success', 'failed'
    ip_address VARCHAR(45),
    user_agent TEXT,
    session_id VARCHAR(100)
);

COMMENT ON TABLE security_events IS 'Centralized security event logging table';
COMMENT ON TABLE user_access_audit IS 'Track all user authentication and authorization events';
