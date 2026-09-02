# Security Policy

## Reporting Security Vulnerabilities

**⚠️ DO NOT open public GitHub issues for security vulnerabilities.**

If you discover a security vulnerability in GRIDWISE, please report it **privately** to:

📧 **Email**: fandinof302@gmail.com  
**Subject**: `[SECURITY] Vulnerability in GRIDWISE`

### What to Include

1. **Description** — Clear explanation of the vulnerability
2. **Location** — File path and line numbers (if applicable)
3. **Steps to Reproduce** — How to trigger the vulnerability
4. **Impact** — What could an attacker do?
5. **CVSS Score** — Severity assessment (if you can)
6. **Suggested Fix** — How to remediate (optional)

### Timeline

- **Day 0**: We receive your report
- **Day 1-2**: We acknowledge and begin investigation
- **Day 3-7**: We develop and test a fix
- **Day 7+**: We release a security patch
- **After patch**: You can publicly disclose (coordinated disclosure)

## Security Features

### Authentication & Authorization

✅ **Implemented:**
- Firebase Authentication (Email/Password, OAuth 2.0)
- JWT token-based sessions
- Role-Based Access Control (RBAC)
- Session timeout (30 minutes inactivity)
- Password requirements: min 8 chars, mix of upper/lower/numbers

❌ **Never:**
- Store passwords in plain text
- Send passwords via email
- Log sensitive credentials

### Data Protection

✅ **Implemented:**
- Firestore security rules (granular access control)
- HTTPS/TLS for all connections
- Data encryption at rest (Firebase default)
- Encrypted MQTT connections for IoT devices
- CORS properly configured (whitelist only trusted origins)

### API Security

✅ **Implemented:**
- Input validation on all endpoints
- Output encoding (prevents XSS)
- Rate limiting (10 requests/minute per IP)
- CSRF token protection
- Secure headers (CSP, X-Frame-Options, etc.)
- SQL injection prevention (we use NoSQL but still validate)

### Dependency Security

✅ **Practices:**
- Regular dependency updates
- Dependabot security alerts enabled
- npm audit regularly run
- Known vulnerabilities tracked
- Security patches applied within 7 days

### Secrets Management

✅ **Secure:**
- `.env` file in `.gitignore` (never committed)
- `.env.example` with placeholder values only
- Secrets rotated every 90 days
- GitHub Secrets for CI/CD
- No hardcoded API keys in code

❌ **Never do this:**
```javascript
// WRONG ❌
const apiKey = "sk_live_51234567890";
const password = "MySecretPassword123";

// CORRECT ✅
const apiKey = process.env.GEMINI_API_KEY;
const password = process.env.DB_PASSWORD;
```

### Network Security

✅ **Implemented:**
- HTTPS required (no HTTP)
- TLS 1.2+ for all connections
- Secure MQTT (mqtt:// → mqtts://)
- Firewall rules (production)
- DDoS protection (if behind CDN)
- API rate limiting

### Logging & Monitoring

✅ **Practices:**
- Login attempts logged
- API errors logged with context
- Security events logged separately
- Suspicious activity alerts
- Regular log review

⚠️ **Never log:**
- Passwords or API keys
- Credit card numbers
- PII (Personally Identifiable Information)
- Health data (if sensitive)

---

## Vulnerability Disclosure Process

### We Follow Responsible Disclosure

1. **Vulnerability Found** → Reporter sends private email
2. **Acknowledgment** → We confirm receipt within 24 hours
3. **Assessment** → We evaluate severity and impact
4. **Fix Development** → We create and test a patch
5. **Fix Release** → We publish security update
6. **Public Disclosure** → Vulnerability details disclosed (after patch)

### Responsible Disclosure Timeline

- **Low severity**: 30 days before public disclosure
- **Medium severity**: 14 days before public disclosure
- **High severity**: 7 days before public disclosure
- **Critical severity**: 1 day before public disclosure (emergency)

---

## Security Checklist for Developers

Before each commit:

- [ ] No API keys/passwords in code
- [ ] No `.env` file committed
- [ ] All inputs validated
- [ ] Outputs properly encoded
- [ ] No console.log() with sensitive data
- [ ] Error messages don't leak system info
- [ ] HTTPS/TLS used for external calls
- [ ] Rate limiting implemented (if needed)
- [ ] CORS properly configured
- [ ] Database queries parameterized
- [ ] Tests include security scenarios
- [ ] Dependencies are up-to-date

---

## Known Security Practices

### What We Do

✅ Validate input on client AND server  
✅ Use parameterized queries  
✅ Hash passwords with bcrypt  
✅ Use HTTPS everywhere  
✅ Implement CSRF protection  
✅ Add security headers  
✅ Regular dependency updates  
✅ Security code reviews  

### What We Avoid

❌ Storing passwords in plain text  
❌ Trusting client-side validation alone  
❌ Exposing stack traces to users  
❌ Hardcoding secrets  
❌ Using outdated libraries  
❌ Unnecessary user data collection  
❌ Insecure randomness  

---

## OWASP Top 10 Mitigations

| OWASP #1 | Broken Access Control | Firestore rules, RBAC, JWT tokens |
|----------|----------------------|----------------------------------|
| OWASP #2 | Cryptographic Failures | TLS, encryption at rest, bcrypt |
| OWASP #3 | Injection | Input validation, parameterized queries |
| OWASP #4 | Insecure Design | Security-first architecture review |
| OWASP #5 | Security Misconfiguration | Security hardening, regular audits |
| OWASP #6 | Vulnerable Components | Dependabot, npm audit, regular updates |
| OWASP #7 | Authentication Failures | Strong auth, session management, 2FA ready |
| OWASP #8 | Data Integrity Failures | Validation, encryption, integrity checks |
| OWASP #9 | Logging Failures | Security event logging, monitoring |
| OWASP #10 | SSRF | Input validation, allowlist URLs |

---

## Security Incident Response

### If You're Attacked

1. **Immediately**: Stop the attack if possible
2. **Document**: Note what happened, when, IP addresses
3. **Report**: Email security team (fandinof302@gmail.com)
4. **Preserve**: Keep logs and evidence
5. **Coordinate**: Work with us on response

### What We Do

1. **Confirm**: Investigate the incident
2. **Contain**: Limit damage if breach occurred
3. **Eradicate**: Remove the vulnerability
4. **Recover**: Restore normal operations
5. **Learn**: Post-incident review and improvements

---

## Bug Bounty (Future)

GRIDWISE plans to launch a bug bounty program. When available:

- Researchers can earn rewards for valid vulnerability reports
- Coordinated disclosure with timeline
- Recognition on GRIDWISE security page
- Details TBA

---

## Third-Party Security Audits

| Vendor | Service | Frequency |
|--------|---------|-----------|
| npm | Dependency scanning | Continuous |
| GitHub | CodeQL analysis | Per-commit |
| Dependabot | Vulnerability alerts | Daily |
| TBD | Professional audit | Quarterly |

---

## Support & Questions

- **Security questions?** Email: fandinof302@gmail.com
- **Vulnerability found?** See "Reporting Security Vulnerabilities" above
- **General help?** See [CONTRIBUTING.md](./CONTRIBUTING.md)

---

## Compliance & Standards

GRIDWISE follows:

- ✅ OWASP Top 10 2024
- ✅ NIST Cybersecurity Framework
- ✅ CWE/SANS Top 25
- ✅ Google Cloud Security Best Practices
- ✅ Firebase Security Best Practices

---

**Last Updated**: September 2, 2026  
**Policy Version**: 1.0

Thank you for helping keep GRIDWISE secure! 🔒
