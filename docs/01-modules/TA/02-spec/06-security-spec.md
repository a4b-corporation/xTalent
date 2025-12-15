# Security Specification - Time & Absence Module

**Version**: 2.0  
**Last Updated**: 2025-12-15  
**Module**: Time & Absence (TA)  
**Status**: Draft

---

## Document Information

- **Purpose**: Define security requirements for the TA module
- **Audience**: Security Engineers, Backend Developers, DevOps
- **Scope**: Authentication, authorization, data privacy, audit, performance
- **Compliance**: GDPR, SOC 2, ISO 27001

---

## Table of Contents

1. [Authentication](#authentication)
2. [Authorization](#authorization)
3. [Data Privacy](#data-privacy)
4. [Audit & Logging](#audit--logging)
5. [Performance & Availability](#performance--availability)
6. [Security Best Practices](#security-best-practices)

---

# Authentication

## OAuth 2.0

**Protocol**: OAuth 2.0 with JWT tokens

**Token Type**: Bearer token

**Token Lifetime**:
- Access token: 1 hour
- Refresh token: 30 days

**Token Format**: JWT (JSON Web Token)

**Token Claims**:
```json
{
  "sub": "user-uuid",
  "tenant_id": "tenant-uuid",
  "roles": ["EMPLOYEE", "MANAGER"],
  "permissions": ["ta:leave:read", "ta:leave:write"],
  "exp": 1702648800,
  "iat": 1702645200
}
```

**Token Validation**:
- Signature verification
- Expiration check
- Issuer validation
- Audience validation

---

## API Key Authentication

**Use Case**: External system integrations (time clocks, HRIS)

**Format**: `X-API-Key: {api_key}`

**Key Generation**: Cryptographically secure random (256-bit)

**Key Rotation**: Every 90 days

**Key Storage**: Encrypted in database

---

## Multi-Factor Authentication (MFA)

**Requirement**: Optional for employees, mandatory for HR/Admin

**Methods**:
- SMS OTP
- Authenticator app (TOTP)
- Email OTP

**MFA Bypass**: Not allowed for sensitive operations

---

# Authorization

## Role-Based Access Control (RBAC)

### Roles

| Role | Description | Permissions |
|------|-------------|-------------|
| EMPLOYEE | Regular employee | Own leave, attendance, timesheet |
| MANAGER | Team manager | Team leave approval, attendance review |
| HR | HR administrator | All employees, configuration, reports |
| ADMIN | System administrator | Full access, system configuration |

### Permission Matrix

| Resource | EMPLOYEE | MANAGER | HR | ADMIN |
|----------|----------|---------|----|----|
| Own Leave Request | CRUD | CRUD | CRUD | CRUD |
| Team Leave Request | R | CRUD | CRUD | CRUD |
| All Leave Requests | - | - | CRUD | CRUD |
| Leave Balance | R (own) | R (team) | CRUD | CRUD |
| Attendance Record | CRUD (own) | R (team) | CRUD | CRUD |
| Timesheet | CRUD (own) | Approve (team) | CRUD | CRUD |
| Configuration | - | - | CRUD | CRUD |
| Reports | R (own) | R (team) | R (all) | R (all) |

---

## Permission Checks

**Implementation**: Middleware/Interceptor

**Check Points**:
- API endpoint level
- Service method level
- Data row level

**Example**:
```javascript
@RequiresPermission("ta:leave:approve")
async approveLeaveRequest(requestId, approverId) {
  // Check if approver is current approver
  if (request.currentApproverId !== approverId) {
    throw new ForbiddenError("Not authorized to approve");
  }
  // Process approval
}
```

---

## Data Access Control

**Principle**: Least privilege

**Rules**:
- Employees can only access own data
- Managers can access team data
- HR can access all data
- Cross-tenant data access is forbidden

**Implementation**: Row-level security (RLS)

**Example Query**:
```sql
SELECT * FROM leave_requests
WHERE tenant_id = :tenant_id
  AND (
    employee_id = :user_id  -- Own requests
    OR current_approver_id = :user_id  -- Pending approvals
    OR :user_role IN ('HR', 'ADMIN')  -- HR/Admin
  )
```

---

# Data Privacy

## GDPR Compliance

### Personal Data Inventory

| Data Type | Category | Retention | Deletion |
|-----------|----------|-----------|----------|
| Employee Name | Personal | 7 years after termination | Anonymize |
| Email | Contact | 7 years after termination | Delete |
| Leave Reason | Sensitive | 7 years | Delete |
| Medical Certificates | Health | 7 years | Secure delete |
| Clock Location (GPS) | Location | 1 year | Delete |
| Biometric Data | Biometric | 1 year | Secure delete |

### Data Subject Rights

**Right to Access**: Employee can export all their data

**API**: `GET /api/v1/ta/gdpr/export`

**Response**: ZIP file with JSON data

**Right to Erasure**: Delete data after retention period

**Right to Rectification**: Employee can correct their data

**Right to Portability**: Export data in machine-readable format

---

## Data Masking

**Sensitive Fields**:
- Leave reason: Mask after 1 year
- Medical certificates: Redact after processing
- GPS coordinates: Truncate to city level after 30 days

**Masking Rules**:
```
Original: "Family emergency - father hospitalized"
Masked: "Personal leave"

Original: GPS (10.776889, 106.700890)
Masked: GPS (10.77, 106.70)
```

---

## Data Encryption

**At Rest**:
- Database: AES-256 encryption
- File storage: AES-256 encryption
- Backups: Encrypted

**In Transit**:
- TLS 1.3 for all API calls
- Certificate pinning for mobile apps

**Key Management**:
- AWS KMS or Azure Key Vault
- Key rotation: Every 90 days
- Separate keys per tenant

---

# Audit & Logging

## Audit Trail

**Events Logged**:
- All CRUD operations
- Authentication attempts
- Authorization failures
- Configuration changes
- Data exports

**Log Format**:
```json
{
  "timestamp": "2025-12-15T10:00:00Z",
  "eventType": "leave.request.approved",
  "userId": "uuid",
  "tenantId": "uuid",
  "resourceType": "LeaveRequest",
  "resourceId": "uuid",
  "action": "APPROVE",
  "before": { ... },
  "after": { ... },
  "ipAddress": "192.168.1.1",
  "userAgent": "Mozilla/5.0..."
}
```

**Storage**: Immutable append-only log

**Retention**: 7 years

**Access**: HR and Auditors only

---

## Security Logging

**Events Logged**:
- Failed login attempts
- Suspicious activity (e.g., rapid API calls)
- Permission violations
- Data access anomalies

**Alerting**:
- 5 failed logins → Lock account
- 10 permission violations/minute → Alert security team
- Data export > 1000 records → Alert HR

**SIEM Integration**: Forward logs to SIEM (Splunk, ELK)

---

## Compliance Logging

**SOC 2 Requirements**:
- Log all access to sensitive data
- Log all configuration changes
- Log all privileged operations

**ISO 27001 Requirements**:
- Log security events
- Log access control changes
- Regular log review

---

# Performance & Availability

## Performance Requirements

**API Response Time**:
- P50: < 200ms
- P95: < 500ms
- P99: < 1000ms

**Database Query Time**:
- Simple queries: < 50ms
- Complex queries: < 200ms
- Reports: < 5s

**Throughput**:
- 1000 requests/second per tenant
- 10,000 concurrent users

---

## Availability Requirements

**SLA**: 99.9% uptime (8.76 hours downtime/year)

**High Availability**:
- Multi-region deployment
- Active-active configuration
- Auto-failover

**Disaster Recovery**:
- RPO (Recovery Point Objective): 1 hour
- RTO (Recovery Time Objective): 4 hours
- Daily backups
- Cross-region replication

---

## Rate Limiting

**Per User**:
- 100 requests/minute
- 1000 requests/hour

**Per Tenant**:
- 1000 requests/minute
- 10,000 requests/hour

**Per IP**:
- 500 requests/minute

**Response**: HTTP 429 Too Many Requests

---

## DDoS Protection

**Measures**:
- CloudFlare or AWS Shield
- Rate limiting
- IP blacklisting
- CAPTCHA for suspicious traffic

---

# Security Best Practices

## Input Validation

**All Inputs**:
- Validate data type
- Validate length
- Validate format (regex)
- Sanitize HTML/SQL
- Reject unexpected fields

**Example**:
```javascript
// Validate leave request
if (!isValidUUID(leaveTypeId)) {
  throw new ValidationError("Invalid leave type ID");
}
if (startDate > endDate) {
  throw new ValidationError("Start date must be before end date");
}
if (reason.length > 500) {
  throw new ValidationError("Reason too long");
}
```

---

## SQL Injection Prevention

**Use Parameterized Queries**:
```javascript
// GOOD
db.query("SELECT * FROM leave_requests WHERE id = ?", [requestId]);

// BAD
db.query(`SELECT * FROM leave_requests WHERE id = '${requestId}'`);
```

---

## XSS Prevention

**Output Encoding**:
- HTML encode user input before display
- Use Content Security Policy (CSP)
- Sanitize rich text input

---

## CSRF Prevention

**CSRF Tokens**:
- Generate unique token per session
- Validate token on state-changing requests
- Use SameSite cookie attribute

---

## Secure Password Storage

**Hashing**: bcrypt with salt (cost factor: 12)

**Password Policy**:
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, symbols
- No common passwords
- Password history: Last 5 passwords

---

## Session Management

**Session Timeout**: 30 minutes of inactivity

**Concurrent Sessions**: Max 3 sessions per user

**Session Invalidation**: On logout, password change, role change

---

## Dependency Security

**Vulnerability Scanning**:
- Daily scan of dependencies
- Auto-update patch versions
- Manual review for major versions

**Tools**: Snyk, Dependabot, npm audit

---

## Security Headers

**Required Headers**:
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
Referrer-Policy: strict-origin-when-cross-origin
```

---

## Document Status

**Status**: Complete  
**Coverage**:
- ✅ Authentication (OAuth 2.0, API Key, MFA)
- ✅ Authorization (RBAC, Permissions)
- ✅ Data Privacy (GDPR, Encryption, Masking)
- ✅ Audit & Logging (Audit trail, Security logs)
- ✅ Performance & Availability (SLA, Rate limiting)
- ✅ Security Best Practices (Input validation, CSRF, XSS)

**Last Updated**: 2025-12-15  
**Compliance**: GDPR, SOC 2, ISO 27001
