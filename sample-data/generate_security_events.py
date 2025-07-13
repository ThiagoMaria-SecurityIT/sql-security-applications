# generate_security_events.py
import random
from datetime import datetime, timedelta
import uuid

categories = {
    'authentication': ['success', 'failed', 'lockout'],
    'threat': ['sql_injection', 'xss', 'brute_force'],
    'configuration': ['firewall', 'permission'],
    'access': ['export', 'privileged'],
    'system': ['backup', 'alert']
}

print("""/* AUTO-GENERATED SECURITY EVENT DATA */\nDELETE FROM security_events;\nINSERT INTO security_events VALUES""")

base_date = datetime(2023, 1, 1)
for i in range(1, 301):
    # Randomize event type/subtype
    event_type = random.choice(list(categories.keys()))
    event_subtype = random.choice(categories[event_type])
    
    # Generate record
    print(f"({i}, ", end='')
    print(f"'{base_date + timedelta(seconds=random.randint(0, 15768000)}', ", end='')  # Random timestamp in 2023
    print(f"'{event_type}', '{event_subtype}', ", end='')
    print(f"'{'10.' if random.random() < 0.7 else '192.0.2.'}{random.randint(1, 254)}', ", end='')  # IP
    print(f"{f'user{random.randint(1, 200)}' if random.random() < 0.8 else 'NULL'}, ", end='')  # User
    print(f"'{random.choice(['CRM', 'API', 'Database', 'Firewall'])}', ", end='')  # Target
    print(f"'{event_subtype.upper()} event {uuid.uuid4().hex[:6]}', ", end='')  # Details
    print(f"'{random.choice(['low', 'medium', 'high', 'critical'])}, ", end='')  # Severity
    print(f"{str(random.random() < 0.15).upper()}, ", end='')  # is_malicious
    print(f"{f'corr-{uuid.uuid4().hex[:8]}' if random.random() < 0.3 else 'NULL'}){';' if i == 300 else ','}")
