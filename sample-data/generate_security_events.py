# generate_security_events.py
import random
from datetime import datetime, timedelta
import uuid

# Event configuration
categories = {
    'authentication': {'success': 70, 'failed': 60, 'lockout': 20},
    'threat': {'sql_injection': 30, 'xss': 20, 'brute_force': 20},
    'configuration': {'firewall': 20, 'permission': 20},
    'access': {'export': 20, 'privileged': 15},
    'system': {'backup': 15, 'alert': 10}
}

print("""/* AUTO-GENERATED SECURITY EVENT DATA */
TRUNCATE TABLE security_events;
INSERT INTO security_events (event_id, event_time, event_type, event_subtype, source_ip, user_id, target_resource, details, severity, is_malicious, correlation_id) VALUES""")

base_date = datetime(2023, 1, 1)
event_id = 1

for event_type, subtypes in categories.items():
    for subtype, count in subtypes.items():
        for _ in range(count):
            # Generate random timestamp within 2023
            event_time = base_date + timedelta(seconds=random.randint(0, 31536000))
            
            # IP (70% internal, 30% TEST-NET)
            source_ip = (
                f"10.{random.randint(0, 255)}.{random.randint(0, 255)}.{random.randint(1, 254)}" 
                if random.random() < 0.7 
                else f"192.0.2.{random.randint(1, 254)}"
            )
            
            # User (80% have user_id)
            user_id = f"'user{random.randint(1, 200)}'" if random.random() < 0.8 else "NULL"
            
            # Target resource based on type
            target_resource = random.choice([
                'CRM', 'API Gateway', 'Database', 
                'Firewall', 'Admin Panel', 'Mobile App'
            ])
            
            # Contextual details
            details = (
                f"Failed login attempt {random.randint(1, 5)}" if subtype == 'failed' else
                f"Detected {subtype.replace('_', ' ')} pattern" if event_type == 'threat' else
                f"System {event_type} event {uuid.uuid4().hex[:6]}"
            )
            
            # Severity logic
            severity = (
                random.choice(['high', 'critical']) if event_type == 'threat' else
                'high' if subtype in ('lockout', 'privileged') else
                random.choice(['low', 'medium', 'high'])
            )
            
            # 15% malicious
            is_malicious = str(random.random() < 0.15).upper()
            
            # 30% have correlation IDs
            correlation_id = f"'corr-{uuid.uuid4().hex[:8]}'" if random.random() < 0.3 else "NULL"
            
            # Build the VALUES clause
            print(
                f"({event_id}, "
                f"'{event_time}', "
                f"'{event_type}', "
                f"'{subtype}', "
                f"'{source_ip}', "
                f"{user_id}, "
                f"'{target_resource}', "
                f"'{details}', "
                f"'{severity}', "
                f"{is_malicious}, "
                f"{correlation_id})"
                + (";" if event_id == 300 else ",")
            )
            
            event_id += 1
            if event_id > 300:
                break
        if event_id > 300:
            break
    if event_id > 300:
        break
