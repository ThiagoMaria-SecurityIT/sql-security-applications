# Data Privacy Guidelines

## Handling Sensitive Information

When contributing SQL queries that might handle personal data:

1. Always demonstrate data minimization techniques
2. Include examples of data anonymization:
   ```sql
   -- Good practice: Anonymize data in results
   SELECT 
       CONCAT(SUBSTRING(email, 1, 3), '***@domain.com') AS masked_email,
       user_role
   FROM users;
