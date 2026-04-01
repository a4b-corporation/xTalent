# Glossary - Audit Trail Bounded Context

> **Bounded Context**: Audit Trail (BC-007)
> **Module**: Payroll (PR)
> **Phase**: Domain Architecture (Step 3)
> **Date**: 2026-03-31

---

## Ubiquitous Language

This glossary defines the terms used within the Audit Trail bounded context. All team members should use these terms consistently when discussing configuration change tracking and compliance auditing.

---

## Entities

### AuditLog

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **AuditLog** | Container for audit entries for a specific scope (tenant, legal entity). Append-only log. | Not AuditEntry (individual entry). Not transaction log. |
| **logId** | Unique identifier for the audit log. | System-generated UUID. |
| **scopeType** | Scope of the log: TENANT, LEGAL_ENTITY, MODULE. | For partitioning. |
| **scopeId** | Identifier of the scope (tenantId, legalEntityId). | For filtering. |
| **createdAt** | Timestamp when log was created. | For tracking. |

---

### AuditEntry

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **AuditEntry** | Individual immutable audit record capturing a configuration change. | Not AuditLog (container). Not version (SCD-2). Immutable. |
| **entryId** | Unique identifier for the audit entry. | System-generated UUID. |
| **entityType** | Type of entity changed: PayElement, PayProfile, StatutoryRule, etc. | For filtering. |
| **entityId** | Identifier of entity changed (elementCode, profileCode, etc.). | For reference. |
| **entityName** | Human-readable name of entity for display. | For readability. |
| **operation** | Operation type: CREATE, UPDATE, DELETE, ASSIGN, UNASSIGN, VERSION_CREATE. | For categorization. |
| **changedBy** | User who performed the change (userId or email). | For accountability. |
| **changedByName** | Human-readable name of user. | For display. |
| **changedAt** | Timestamp when change occurred. | For timeline. |
| **oldValue** | Previous state as JSON (null for CREATE). | For comparison. |
| **newValue** | New state as JSON (null for DELETE). | For comparison. |
| **changedFields** | List of fields that changed. | For quick reference. |
| **changeReason** | Reason for change (required for versioned entities). | For compliance. |
| **versionId** | Reference to SCD-2 version (if applicable). | For version tracking. |
| **sessionId** | Session ID for correlation. | For grouping related changes. |
| **ipAddress** | IP address of user. | For security audit. |
| **notes** | Additional notes or comments. | Optional. |

**Immutability**: Audit entries cannot be modified or deleted. This is a compliance requirement.

---

### AuditReport

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **AuditReport** | Generated report from audit log query for export or review. | Not AuditLog. Not AuditEntry. Generated artifact. |
| **reportId** | Unique identifier for the report. | System-generated UUID. |
| **reportName** | Human-readable name like "Audit Report Q1 2026". | For display. |
| **reportType** | Type: SUMMARY, DETAIL, COMPARISON, COMPLIANCE. | For categorization. |
| **generatedAt** | Timestamp when report was generated. | For tracking. |
| **generatedBy** | User who requested the report. | For accountability. |
| **dateRangeStart** | Start date of audit entries included. | For filtering. |
| **dateRangeEnd** | End date of audit entries included. | For filtering. |
| **entityTypes** | Entity types included (optional filter). | For filtering. |
| **format** | Output format: CSV, PDF, JSON. | For export. |
| **entryCount** | Number of entries in report. | For summary. |
| **filePath** | Path to generated file. | For retrieval. |

---

## Value Objects

### OperationType

| Value | Definition | Trigger |
|-------|------------|---------|
| **CREATE** | New entity created | First creation |
| **UPDATE** | Entity modified | Attribute change |
| **DELETE** | Entity soft-deleted | Soft delete |
| **ASSIGN** | Assignment created | PayElement to Profile, Employee to Group |
| **UNASSIGN** | Assignment removed | Removal from Profile/Group |
| **VERSION_CREATE** | New version created | SCD-2 versioning |
| **VALIDATE** | Validation performed | Validation operation |
| **EXPORT** | Data exported | Export operation |

### EntityType

| Value | Definition |
|-------|------------|
| **PayElement** | Pay element entity |
| **PayProfile** | Pay profile entity |
| **PayFormula** | Pay formula entity |
| **StatutoryRule** | Statutory rule entity |
| **PayCalendar** | Pay calendar entity |
| **PayGroup** | Pay group entity |
| **GLMappingPolicy** | GL mapping policy entity |
| **BankTemplate** | Bank template entity |
| **ValidationRule** | Validation rule entity |
| **PayElementAssignment** | Element assignment |
| **PayGroupAssignment** | Group assignment |

### ReportType

| Value | Definition |
|-------|------------|
| **SUMMARY** | Summary statistics by type, user, date |
| **DETAIL** | Full detail of all entries |
| **COMPARISON** | Before/after comparison view |
| **COMPLIANCE** | Compliance-focused report for auditors |

---

## Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **AuditEntryCreated** | An audit entry was created for a configuration change. | Automatic logging. |
| **AuditLogQueried** | Audit log was queried by user. | Query operation logged. |
| **AuditReportGenerated** | An audit report was generated. | Export operation. |
| **AuditReportExported** | An audit report was exported/downloaded. | Download action. |
| **AuditEntryViewed** | An audit entry was viewed by user. | View action. |
| **AuditComparisonViewed** | Version comparison was viewed. | Comparison action. |

---

## Commands

| Command | Actor | Description |
|---------|-------|-------------|
| **QueryAuditLog** | HR Manager, Compliance Officer | Query audit entries with filters |
| **FilterAuditLogByDate** | HR Manager | Filter by date range |
| **FilterAuditLogByEntity** | HR Manager | Filter by entity type |
| **FilterAuditLogByUser** | HR Manager | Filter by user |
| **FilterAuditLogByOperation** | Compliance Officer | Filter by operation type |
| **ViewAuditEntry** | HR Manager | View single entry details |
| **CompareAuditEntries** | Payroll Admin | Compare before/after for entry |
| **GenerateAuditReport** | Compliance Officer | Generate audit report |
| **ExportAuditReport** | Compliance Officer | Export report in specified format |
| **GetAuditSummary** | HR Manager | Get summary statistics |
| **GetEntityHistory** | Payroll Admin | Get full history for one entity |

---

## Audit Entry Examples

### PayElement Creation Audit

```
AuditEntry {
  entryId: "audit-001",
  entityType: PayElement,
  entityId: "SALARY_BASIC",
  entityName: "Basic Salary",
  operation: CREATE,
  changedBy: "admin@company.com",
  changedByName: "Nguyen Van Admin",
  changedAt: "2026-03-31T10:30:00Z",
  oldValue: null,
  newValue: {
    "elementCode": "SALARY_BASIC",
    "elementName": "Basic Salary",
    "classification": "EARNING",
    "calculationType": "FIXED",
    "statutoryFlag": false,
    "taxableFlag": true,
    "isActive": true,
    "effectiveStartDate": "2026-03-31",
    "effectiveEndDate": null,
    "isCurrentFlag": true
  },
  changedFields: ["all"],
  changeReason: "Initial setup for 2026 payroll",
  versionId: null,
  sessionId: "session-123",
  ipAddress: "192.168.1.100",
  notes: "Created during payroll configuration setup"
}
```

### PayElement Update Audit

```
AuditEntry {
  entryId: "audit-002",
  entityType: PayElement,
  entityId: "BHXH_EE",
  entityName: "Social Insurance Employee",
  operation: VERSION_CREATE,
  changedBy: "admin@company.com",
  changedAt: "2026-06-30T14:00:00Z",
  oldValue: {
    "rate": 0.08,
    "effectiveEndDate": null,
    "isCurrentFlag": true
  },
  newValue: {
    "rate": 0.085,
    "effectiveStartDate": "2026-07-01",
    "effectiveEndDate": null,
    "isCurrentFlag": true,
    "versionReason": "Government rate increase per Decree 2026"
  },
  changedFields: ["rate", "effectiveStartDate", "effectiveEndDate", "isCurrentFlag"],
  changeReason: "Government rate increase per Decree 2026",
  versionId: "BHXH_EE_V2",
  sessionId: "session-456",
  ipAddress: "192.168.1.100"
}
```

### Employee Assignment Audit

```
AuditEntry {
  entryId: "audit-003",
  entityType: PayGroupAssignment,
  entityId: "EMP001",
  entityName: "Nguyen Van A",
  operation: ASSIGN,
  changedBy: "admin@company.com",
  changedAt: "2026-01-15T09:00:00Z",
  oldValue: null,
  newValue: {
    "employeeId": "EMP001",
    "payGroupId": "GRP_STAFF_HQ",
    "assignmentDate": "2026-01-15",
    "assignmentReason": "NEW_HIRE",
    "isCurrent": true
  },
  changedFields: ["all"],
  changeReason: "New employee assignment",
  versionId: null,
  sessionId: "session-789",
  ipAddress: "192.168.1.100"
}
```

---

## Query Examples

### Query by Date Range

```
Query: Audit entries from 2026-01-01 to 2026-03-31

Result:
[
  { entityType: PayElement, operation: CREATE, count: 15 },
  { entityType: PayProfile, operation: CREATE, count: 3 },
  { entityType: PayGroupAssignment, operation: ASSIGN, count: 50 },
  { entityType: StatutoryRule, operation: CREATE, count: 4 }
]

Total entries: 72
```

### Query by Entity

```
Query: Audit entries for PayElement "BHXH_EE"

Result:
[
  { entryId: "audit-001", operation: CREATE, changedAt: "2026-01-01", changedBy: "admin" },
  { entryId: "audit-002", operation: VERSION_CREATE, changedAt: "2026-06-30", changedBy: "admin" }
]

History shows: Created Jan 1, Rate updated June 30
```

### Query by User

```
Query: Audit entries by "admin@company.com" in March 2026

Result:
[
  { entityType: PayElement, entityId: "SALARY_BASIC", operation: CREATE, changedAt: "2026-03-31" },
  { entityType: PayProfile, entityId: "PROFILE_STAFF", operation: CREATE, changedAt: "2026-03-31" },
  { entityType: PayGroupAssignment, entityId: "EMP050", operation: ASSIGN, changedAt: "2026-03-15" }
]

Total actions: 3
```

---

## Report Examples

### Summary Report

```
AuditReport {
  reportType: SUMMARY,
  dateRangeStart: "2026-01-01",
  dateRangeEnd: "2026-03-31",
  generatedAt: "2026-03-31T15:00:00Z",
  generatedBy: "compliance@company.com",
  
  summary: {
    totalEntries: 72,
    byEntityType: {
      PayElement: 15,
      PayProfile: 3,
      StatutoryRule: 4,
      PayGroupAssignment: 50
    },
    byOperation: {
      CREATE: 22,
      ASSIGN: 50
    },
    byUser: {
      "admin@company.com": 60,
      "hr@company.com": 12
    },
    byDate: {
      "2026-01-01": 10,
      "2026-01-15": 25,
      "2026-02-01": 15,
      "2026-03-31": 22
    }
  }
}
```

### Compliance Report

```
AuditReport {
  reportType: COMPLIANCE,
  dateRangeStart: "2026-01-01",
  dateRangeEnd: "2026-12-31",
  generatedAt: "2026-12-31T18:00:00Z",
  
  complianceChecks: {
    statutoryRuleChanges: [
      { rule: "BHXH_EE", rateChange: "8% to 8.5%", effective: "2026-07-01", reason: "Government decree" }
    ],
    versionHistoryComplete: true,
    auditTrailIntegrity: true,
    noUnauthorizedDeletes: true
  },
  
  auditorNotes: "All configuration changes properly documented with reasons. Statutory rate changes aligned with government regulations."
}
```

---

## Integration Points

### Inbound Integrations

| Source | Data | Purpose |
|--------|------|---------|
| All BCs | Entity change events | Audit entry creation |
| System | Session context | User tracking |

### Outbound Integrations

| Target | Data | Purpose |
|--------|------|---------|
| External Auditor | Audit report export | Compliance audit |
| HR Manager | Audit query UI | Review and investigation |
| Compliance Officer | Compliance report | Compliance verification |

---

## Retention Policy

| Entry Type | Retention Period | Notes |
|------------|------------------|-------|
| CREATE entries | Permanent | Never deleted |
| UPDATE entries | Permanent | Never deleted |
| DELETE entries | Permanent | Never deleted |
| Query logs | 1 year | Optional, for security |
| Export logs | 1 year | For audit tracking |

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent