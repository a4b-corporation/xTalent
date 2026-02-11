# Authentication & Authorization

## Overview

The Time & Absence API uses **OAuth 2.0** with **JWT (JSON Web Tokens)** for authentication and a **role-based access control (RBAC)** model for authorization.

---

## Authentication Methods

### 1. OAuth 2.0 - Client Credentials Flow

**For server-to-server integrations** (e.g., payroll systems, HR platforms):

```http
POST https://auth.xtalent.vng.com/oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=your_client_id
&client_secret=your_client_secret
&scope=time:read time:write absence:read absence:write
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "time:read time:write absence:read absence:write"
}
```

### 2. OAuth 2.0 - Authorization Code Flow

**For user-facing applications** (web apps, mobile apps):

**Step 1: Authorization Request**
```
GET https://auth.xtalent.vng.com/oauth/authorize?
  response_type=code
  &client_id=your_client_id
  &redirect_uri=https://yourapp.com/callback
  &scope=time:read absence:read
  &state=random_state_string
```

**Step 2: Exchange Code for Token**
```http
POST https://auth.xtalent.vng.com/oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
&code=AUTH_CODE_FROM_STEP_1
&client_id=your_client_id
&client_secret=your_client_secret
&redirect_uri=https://yourapp.com/callback
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "time:read absence:read"
}
```

### 3. API Keys (Legacy)

For backward compatibility, API keys are supported but **not recommended** for new integrations:

```http
GET /api/v1/timesheets
X-API-Key: your_api_key_here
```

---

## Using Access Tokens

Include the access token in the `Authorization` header:

```http
GET /api/v1/timesheets
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Token Refresh

When the access token expires, use the refresh token:

```http
POST https://auth.xtalent.vng.com/oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token
&refresh_token=your_refresh_token
&client_id=your_client_id
&client_secret=your_client_secret
```

---

## Authorization Model

### Role-Based Access Control (RBAC)

The API enforces permissions based on user roles:

| Role | Description | Typical Permissions |
|------|-------------|---------------------|
| **Employee** | Standard employee | Read own timesheet, submit leave requests, clock in/out |
| **Manager** | Team manager | Read team timesheets, approve leave/timesheets, assign schedules |
| **HR Admin** | HR administrator | Full CRUD on shifts, patterns, policies, view all data |
| **Payroll Specialist** | Payroll processor | Read approved timesheets, export payroll data |
| **System Admin** | System administrator | Full access to all resources and configurations |
| **API Client** | Service account | Scope-based permissions (configured per client) |

### Permission Scopes

OAuth scopes control API access:

| Scope | Description |
|-------|-------------|
| `time:read` | Read time attendance data (shifts, schedules, timesheets) |
| `time:write` | Create/update time attendance data |
| `absence:read` | Read absence/leave data |
| `absence:write` | Create/update leave requests |
| `admin:time` | Full administrative access to time module |
| `admin:absence` | Full administrative access to absence module |
| `payroll:export` | Export data for payroll processing |
| `device:manage` | Manage time clock devices |

### Resource-Level Permissions

Beyond scopes, the API enforces resource-level permissions:

**Examples:**
- Employees can only read/update their own timesheets
- Managers can read/approve timesheets for their direct reports
- HR Admins can access all employee data

**Permission Check:**
```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "You do not have permission to access this resource",
    "requiredPermission": "time:write:all"
  }
}
```

---

## JWT Token Structure

### Token Claims

```json
{
  "sub": "emp_123456",
  "iss": "https://auth.xtalent.vng.com",
  "aud": "https://api.xtalent.vng.com",
  "exp": 1638363600,
  "iat": 1638360000,
  "scope": "time:read time:write absence:read",
  "roles": ["EMPLOYEE", "MANAGER"],
  "employeeId": "emp_123456",
  "legalEntityId": "le_001",
  "businessUnitId": "bu_sales"
}
```

### Claim Descriptions

- `sub`: Subject (employee ID or client ID)
- `iss`: Issuer (auth server URL)
- `aud`: Audience (API server URL)
- `exp`: Expiration timestamp
- `iat`: Issued at timestamp
- `scope`: OAuth scopes
- `roles`: User roles
- `employeeId`: Employee identifier
- `legalEntityId`: Legal entity context
- `businessUnitId`: Business unit context

---

## Security Best Practices

### 1. Token Storage
- **Never** store tokens in localStorage (vulnerable to XSS)
- Use **httpOnly cookies** for web applications
- Use **secure keychain/keystore** for mobile apps
- Rotate refresh tokens regularly

### 2. HTTPS Only
- All API calls **must** use HTTPS
- HTTP requests will be rejected with `426 Upgrade Required`

### 3. Token Expiration
- Access tokens expire in **1 hour** (3600 seconds)
- Refresh tokens expire in **30 days**
- Implement automatic token refresh logic

### 4. Scope Minimization
- Request only the scopes your application needs
- Use separate service accounts for different integrations

### 5. Secret Management
- **Never** commit client secrets to version control
- Use environment variables or secret management services (e.g., AWS Secrets Manager, HashiCorp Vault)
- Rotate secrets periodically

---

## Error Responses

### 401 Unauthorized
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired access token"
  }
}
```

**Common causes:**
- Missing `Authorization` header
- Expired access token
- Invalid token signature
- Token revoked

**Solution:** Refresh the access token or re-authenticate

### 403 Forbidden
```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "Insufficient permissions to perform this action",
    "requiredScope": "admin:time"
  }
}
```

**Common causes:**
- Token lacks required scope
- User role doesn't have permission
- Resource-level access denied

**Solution:** Request appropriate scopes or contact administrator

---

## API Key Management (Legacy)

### Creating API Keys

```http
POST /api/v1/api-keys
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "name": "Payroll Integration",
  "scopes": ["time:read", "payroll:export"],
  "expiresAt": "2026-12-01T00:00:00Z"
}
```

**Response:**
```json
{
  "data": {
    "id": "key_abc123",
    "key": "xta_live_abc123xyz...",
    "name": "Payroll Integration",
    "scopes": ["time:read", "payroll:export"],
    "createdAt": "2025-12-01T09:09:27Z",
    "expiresAt": "2026-12-01T00:00:00Z"
  }
}
```

> [!WARNING]
> The API key is shown only once. Store it securely immediately.

### Revoking API Keys

```http
DELETE /api/v1/api-keys/{keyId}
Authorization: Bearer {admin_token}
```

---

## Multi-Tenancy & Context

### Legal Entity Context

For multi-entity organizations, specify the legal entity context:

```http
GET /api/v1/timesheets
Authorization: Bearer {token}
X-Legal-Entity-Id: le_vn_001
```

If not specified, the API uses the user's default legal entity from the JWT token.

### Business Unit Context

For department-specific operations:

```http
GET /api/v1/schedules/assignments
Authorization: Bearer {token}
X-Business-Unit-Id: bu_sales_hanoi
```

---

## Testing Authentication

### Sandbox Environment

Use test credentials in the development environment:

```
Client ID: test_client_abc123
Client Secret: test_secret_xyz789
Auth URL: https://auth-dev.xtalent.vng.com
```

### Token Introspection

Verify token validity and claims:

```http
POST https://auth.xtalent.vng.com/oauth/introspect
Content-Type: application/x-www-form-urlencoded
Authorization: Basic {base64(client_id:client_secret)}

token=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "active": true,
  "scope": "time:read time:write",
  "client_id": "your_client_id",
  "exp": 1638363600,
  "sub": "emp_123456"
}
```

---

## Next Steps

- Review [Common Data Models](./02-common-models.md)
- Explore [Integration Guide](./19-integration-guide.md)
- Start with [Timesheet API](./07-timesheet-api.md)
