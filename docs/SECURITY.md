# Security Policy

## Reporting Vulnerabilities

If you discover any security issues in our SQL examples or schemas:

1. Please DO NOT create a public issue
2. Email Thisecurapps_767@proton.me with details
3. Include "SQL Security Repo" in the subject line

We will respond within 48 hours to acknowledge your report.

## Security Best Practices

All SQL in this repository should:

1. Follow the principle of least privilege
2. Include appropriate WHERE clauses to prevent full table scans in production
3. Avoid direct string concatenation with user input
4. Include warnings about potential performance impacts

## Data Protection

- Example queries should never contain real credentials
- Sample data must be completely synthetic
- All identifiers should be obviously fake (e.g., 'example.com', 'testuser')
