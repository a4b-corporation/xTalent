# Audit - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-04  
**Module**: Total Rewards (TR)  
**Sub-module**: Audit

---

## Overview

Audit provides comprehensive audit trail for all Total Rewards transactions and changes for compliance and security.

---

## Entity

### AuditLog

**Definition**: Comprehensive audit log for all Total Rewards module changes and transactions.

**Purpose**: Maintains complete audit trail for compliance, security, and troubleshooting.

**Key Characteristics**:
- Records all CREATE, UPDATE, DELETE operations
- Captures who, what, when, where
- Stores before/after values for changes
- Supports compliance requirements (SOX, GDPR, etc.)
- Immutable records (write-once, never delete)

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `entity_type` | string(100) | Yes | Entity name (e.g., "OfferPackage", "BonusAllocation") |
| `entity_id` | UUID | Yes | ID of affected record |
| `operation` | enum | Yes | CREATE, UPDATE, DELETE, APPROVE, REJECT, SEND, CANCEL |
| `user_id` | UUID | Yes | FK to Core.Employee (who performed action) |
| `user_role` | string(50) | No | User's role at time of action |
| `timestamp` | timestamp | Yes | When action occurred (default: now()) |
| `ip_address` | string(50) | No | IP address of user |
| `user_agent` | string(500) | No | Browser/client information |
| `before_value` | jsonb | No | Record state before change (for UPDATE) |
| `after_value` | jsonb | No | Record state after change (for UPDATE/CREATE) |
| `changed_fields` | jsonb | No | List of fields changed (for UPDATE) |
| `reason` | text | No | Reason for change (if provided) |
| `session_id` | UUID | No | User session ID |
| `transaction_id` | UUID | No | Database transaction ID |
| `metadata` | jsonb | No | Additional context |

**Business Rules**:
1. Every sensitive operation must be logged
2. Audit logs are immutable (no updates or deletes)
3. Retention period: 7 years minimum (compliance requirement)
4. Logs encrypted at rest
5. Access restricted to authorized personnel only

**Examples**:

```yaml
Example 1: Offer Package Approval
  AuditLog:
    entity_type: "OfferPackage"
    entity_id: "OFFER_UUID"
    operation: APPROVE
    user_id: "HR_DIRECTOR_UUID"
    user_role: "HR_DIRECTOR"
    timestamp: "2025-03-15T14:30:00Z"
    ip_address: "192.168.1.100"
    before_value:
      status: "PENDING"
      approved_by: null
    after_value:
      status: "APPROVED"
      approved_by: "HR_DIRECTOR_UUID"
      approved_at: "2025-03-15T14:30:00Z"
    changed_fields: ["status", "approved_by", "approved_at"]
    reason: "Approved after salary negotiation"

Example 2: Bonus Allocation Update
  AuditLog:
    entity_type: "BonusAllocation"
    entity_id: "BONUS_UUID"
    operation: UPDATE
    user_id: "MANAGER_UUID"
    user_role: "MANAGER"
    timestamp: "2025-03-20T10:15:00Z"
    before_value:
      proposed_amount: 5000000
      performance_multiplier: 1.0
    after_value:
      proposed_amount: 6000000
      performance_multiplier: 1.2
    changed_fields: ["proposed_amount", "performance_multiplier"]
    reason: "Adjusted based on Q4 performance review"

Example 3: Compensation Adjustment Deletion
  AuditLog:
    entity_type: "CompensationAdjustment"
    entity_id: "ADJUSTMENT_UUID"
    operation: DELETE
    user_id: "ADMIN_UUID"
    user_role: "SYSTEM_ADMIN"
    timestamp: "2025-03-25T16:45:00Z"
    before_value:
      employee_id: "EMP_001_UUID"
      proposed_amount: 55000000
      status: "DRAFT"
    after_value: null
    reason: "Duplicate entry - employee transferred to different BU"
```

**Audit Queries**:

```sql
-- Who changed this offer package?
SELECT user_id, operation, timestamp, changed_fields
FROM AuditLog
WHERE entity_type = 'OfferPackage' AND entity_id = 'OFFER_UUID'
ORDER BY timestamp;

-- All bonus changes in March 2025
SELECT entity_id, user_id, operation, changed_fields
FROM AuditLog
WHERE entity_type = 'BonusAllocation'
  AND timestamp BETWEEN '2025-03-01' AND '2025-03-31'
ORDER BY timestamp DESC;

-- Track compensation history for employee
SELECT entity_type, operation, before_value, after_value, timestamp
FROM AuditLog
WHERE after_value->>'employee_id' = 'EMP_001_UUID'
  AND entity_type IN ('CompensationAdjustment', 'EmployeeCompensationSnapshot')
ORDER BY timestamp;
```

**Compliance Features**:
- ✅ **SOX Compliance**: Complete financial transaction audit trail
- ✅ **GDPR**: Track all personal data access and changes
- ✅ **HIPAA**: Audit healthcare benefit data access
- ✅ **Labor Law**: Compensation change documentation
- ✅ **Internal Audit**: Fraud detection and investigation

**Security**:
- Logs encrypted at rest (AES-256)
- Access restricted via RBAC
- Tamper-evident (hash chain)
- Separate database for isolation
- Regular backup and archival

---

## Summary

**1 entity** providing comprehensive audit trail for Total Rewards module.

**Key Features**:
- ✅ Complete change tracking (who, what, when, where)
- ✅ Before/after value capture
- ✅ Immutable records
- ✅ 7-year retention
- ✅ Compliance support (SOX, GDPR, HIPAA)
- ✅ Security and fraud detection

**Critical for**:
- Regulatory compliance
- Security audits
- Fraud investigation
- Troubleshooting
- Legal disputes

---

**Document Status**: ✅ Complete  
**Coverage**: 1 of 1 entity documented  
**Last Updated**: 2025-12-04
