/*
Purpose: Centralized logging schema for security and system events
Author: Security Team
Version: 1.0
Last Updated: 2025-07-13
*/

CREATE TABLE system_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    log_timestamp TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
    source_system VARCHAR(100) NOT NULL,
    log_level ENUM('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL') NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_code VARCHAR(30),
    message TEXT NOT NULL,
    source_ip VARCHAR(45),
    user_id VARCHAR(100),
    session_id VARCHAR(100),
    request_details JSON,
    metadata JSON,
    INDEX idx_log_timestamp (log_timestamp),
    INDEX idx_source_system (source_system),
    INDEX idx_event_type (event_type),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB;

CREATE TABLE firewall_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    event_time TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
    source_ip VARCHAR(45) NOT NULL,
    source_port INT,
    dest_ip VARCHAR(45) NOT NULL,
    dest_port INT NOT NULL,
    protocol VARCHAR(10) NOT NULL,
    action ENUM('ALLOW', 'DENY', 'DROP', 'REJECT') NOT NULL,
    rule_id VARCHAR(50),
    packet_size INT,
    country_code CHAR(2),
    asn VARCHAR(20),
    user_agent TEXT,
    threat_indicator BOOLEAN DEFAULT FALSE,
    threat_type VARCHAR(50),
    INDEX idx_event_time (event_time),
    INDEX idx_source_ip (source_ip),
    INDEX idx_dest_ip (dest_ip),
    INDEX idx_action (action),
    INDEX idx_threat (threat_indicator)
) ENGINE=InnoDB;

CREATE TABLE application_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    timestamp TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
    application VARCHAR(100) NOT NULL,
    component VARCHAR(100),
    user_id VARCHAR(100),
    session_id VARCHAR(100),
    log_level VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    exception TEXT,
    stack_trace TEXT,
    http_method VARCHAR(10),
    endpoint VARCHAR(255),
    status_code INT,
    duration_ms INT,
    client_ip VARCHAR(45),
    user_agent TEXT,
    additional_data JSON,
    INDEX idx_timestamp (timestamp),
    INDEX idx_application (application),
    INDEX idx_user_id (user_id),
    INDEX idx_status_code (status_code)
) ENGINE=InnoDB;

CREATE TABLE log_retention_policies (
    policy_id INT PRIMARY KEY AUTO_INCREMENT,
    log_type ENUM('SYSTEM', 'FIREWALL', 'APPLICATION', 'SECURITY') NOT NULL,
    retention_days INT NOT NULL,
    compression_enabled BOOLEAN DEFAULT TRUE,
    archive_location VARCHAR(255),
    last_rotation TIMESTAMP,
    next_rotation TIMESTAMP GENERATED ALWAYS AS (last_rotation + INTERVAL retention_days DAY),
    UNIQUE KEY uk_log_type (log_type)
) ENGINE=InnoDB;

-- Comments for documentation
COMMENT ON TABLE system_logs IS 'Centralized system event logging for all infrastructure components';
COMMENT ON TABLE firewall_logs IS 'Network firewall traffic logs with threat detection fields';
COMMENT ON TABLE application_logs IS 'Application-specific logs with runtime and API call details';
COMMENT ON TABLE log_retention_policies IS 'Configuration for log retention and rotation policies';
