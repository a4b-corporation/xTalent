# Use Case Flow - Query Audit Trail

> **Use Case**: UC-AT-001 Query Audit Trail
> **Bounded Context**: Audit Trail (BC-007)
> **Module**: Payroll (PR)
> **Priority**: P0
> **Story Points**: 5

---

## Overview

This flow documents the process of querying the audit trail for configuration changes with various filters.

---

## Actors

| Actor | Role |
|-------|------|
| HR Manager | Primary actor - queries audit trail |
| Compliance Officer | Secondary actor - exports audit reports |
| AuditLog Aggregate | Manages audit queries |

---

## Preconditions

1. HR Manager is logged in with audit query permission
2. Audit entries exist for configuration changes

---

## Postconditions

1. Audit entries returned matching filter criteria
2. Each entry shows entity, operation, user, timestamp
3. Detail view available showing before/after values
4. Export option available

---

## Happy Path

```mermaid
sequenceDiagram
    actor HR as HR Manager
    participant UI as UI Layer
    participant API as API Layer
    participant AL as AuditLog Aggregate
    participant DB as Database
    
    HR->>UI: Navigate to Audit Trail
    UI->>API: GET /audit-log/recent
    API->>AL: QueryAuditLog command (default filters)
    AL->>DB: SELECT recent entries
    DB-->>AL: Entry list
    AL-->>API: Audit entries
    API-->>UI: Audit log display
    UI->>HR: Display recent changes
    
    HR->>UI: Apply date filter
    Note over HR,UI: dateRange: 2026-01-01 to 2026-03-31
    
    UI->>API: GET /audit-log?startDate=2026-01-01&endDate=2026-03-31
    API->>AL: FilterAuditLogByDate command
    AL->>DB: SELECT entries in date range
    DB-->>AL: Filtered entries
    AL-->>API: Audit entries
    API-->>UI: Filtered results
    UI->>HR: Display filtered audit log
    
    HR->>UI: Click on entry for detail
    UI->>API: GET /audit-log/entries/{entryId}
    API->>AL: ViewAuditEntry command
    AL->>DB: SELECT entry details
    DB-->>AL: Full entry with oldValue/newValue
    AL-->>API: Entry detail
    API-->>UI: Entry detail data
    UI->>HR: Display change comparison
    
    Note over UI: Shows:<br/>- Old value (JSON)<br/>- New value (JSON)<br/>- Changed fields highlighted<br/>- Change reason<br/>- User and timestamp
```

---

## Filter Variations

### Filter by Entity Type

```mermaid
sequenceDiagram
    actor HR as HR Manager
    participant UI as UI Layer
    participant API as API Layer
    participant AL as AuditLog Aggregate
    participant DB as Database
    
    HR->>UI: Select entity type "PayElement"
    UI->>API: GET /audit-log?entityType=PayElement
    API->>AL: FilterAuditLogByEntity command
    AL->>DB: SELECT entries where entityType = PayElement
    DB-->>AL: PayElement entries
    AL-->>API: Filtered entries
    API-->>UI: PayElement audit log
    UI->>HR: Display PayElement changes only
```

### Filter by User

```mermaid
sequenceDiagram
    actor HR as HR Manager
    participant UI as UI Layer
    participant API as API Layer
    participant AL as AuditLog Aggregate
    participant DB as Database
    
    HR->>UI: Select user "admin@company.com"
    UI->>API: GET /audit-log?changedBy=admin@company.com
    API->>AL: FilterAuditLogByUser command
    AL->>DB: SELECT entries where changedBy = admin
    DB-->>AL: User's entries
    AL-->>API: Filtered entries
    API-->>UI: User audit log
    UI->>HR: Display changes by specific user
```

### Filter by Operation Type

```mermaid
sequenceDiagram
    actor CO as Compliance Officer
    participant UI as UI Layer
    participant API as API Layer
    participant AL as AuditLog Aggregate
    participant DB as Database
    
    CO->>UI: Select operation "UPDATE"
    UI->>API: GET /audit-log?operation=UPDATE
    API->>AL: FilterAuditLogByOperation command
    AL->>DB: SELECT entries where operation = UPDATE
    DB-->>AL: Update entries
    AL-->>API: Filtered entries
    API-->>UI: Update audit log
    UI->>CO: Display all updates
```

---

## Export Flow

```mermaid
sequenceDiagram
    actor CO as Compliance Officer
    participant UI as UI Layer
    participant API as API Layer
    participant AL as AuditLog Aggregate
    participant DB as Database
    
    CO->>UI: Apply filters for export
    Note over CO,UI: Date range + entity types
    
    CO->>UI: Click Export CSV
    UI->>API: POST /audit-log/export?format=CSV
    API->>AL: GenerateAuditReport command
    AL->>DB: SELECT filtered entries
    DB-->>AL: Entry data
    AL->>AL: Generate CSV file
    AL->>DB: INSERT AuditReport record
    AL-->>API: Report with file path
    API-->>UI: Export ready
    UI->>CO: Download CSV file
    
    Note over AL: CSV contains:<br/>- Entry ID<br/>- Entity Type<br/>- Entity ID<br/>- Operation<br/>- Changed By<br/>- Changed At<br/>- Change Reason<br/>- Changed Fields
```

---

## API Contract

### Query Request

```http
GET /api/v1/audit-log?startDate=2026-01-01&endDate=2026-03-31&entityType=PayElement&page=1&size=50
```

### Query Response

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "total": 15,
  "page": 1,
  "size": 50,
  "entries": [
    {
      "entryId": "audit-001",
      "entityType": "PayElement",
      "entityId": "SALARY_BASIC",
      "entityName": "Basic Salary",
      "operation": "CREATE",
      "changedBy": "admin@company.com",
      "changedByName": "Nguyen Van Admin",
      "changedAt": "2026-03-31T10:30:00Z",
      "changeReason": "Initial setup",
      "changedFields": ["all"]
    },
    {
      "entryId": "audit-002",
      "entityType": "PayElement",
      "entityId": "BHXH_EE",
      "entityName": "Social Insurance Employee",
      "operation": "VERSION_CREATE",
      "changedBy": "admin@company.com",
      "changedAt": "2026-06-30T14:00:00Z",
      "changeReason": "Government rate increase",
      "changedFields": ["rate", "effectiveStartDate"]
    }
  ]
}
```

### Entry Detail Request

```http
GET /api/v1/audit-log/entries/audit-002
```

### Entry Detail Response

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "entryId": "audit-002",
  "entityType": "PayElement",
  "entityId": "BHXH_EE",
  "operation": "VERSION_CREATE",
  "changedBy": "admin@company.com",
  "changedAt": "2026-06-30T14:00:00Z",
  "oldValue": {
    "rate": 0.08,
    "effectiveEndDate": null,
    "isCurrentFlag": true
  },
  "newValue": {
    "rate": 0.085,
    "effectiveStartDate": "2026-07-01",
    "effectiveEndDate": null,
    "isCurrentFlag": true
  },
  "changedFields": ["rate", "effectiveStartDate"],
  "changeReason": "Government rate increase per Decree 2026",
  "versionId": "BHXH_EE_V2",
  "sessionId": "session-456",
  "ipAddress": "192.168.1.100"
}
```

---

## Audit Entry Display

| Column | Description |
|--------|-------------|
| Entry ID | Unique identifier |
| Entity Type | PayElement, PayProfile, etc. |
| Entity ID | Code of entity changed |
| Entity Name | Human-readable name |
| Operation | CREATE, UPDATE, DELETE, ASSIGN |
| Changed By | User email |
| Changed At | Timestamp |
| Change Reason | Reason for change |
| Changed Fields | List of modified fields |

---

## Summary Statistics

```mermaid
sequenceDiagram
    actor HR as HR Manager
    participant UI as UI Layer
    participant API as API Layer
    participant AL as AuditLog Aggregate
    
    HR->>UI: View Audit Summary
    UI->>API: GET /audit-log/summary
    API->>AL: GetAuditSummary command
    AL-->>API: Summary statistics
    API-->>UI: Summary data
    UI->>HR: Display summary dashboard
    
    Note over UI: Dashboard shows:<br/>- Total entries by date range<br/>- By entity type (pie chart)<br/>- By operation type (bar chart)<br/>- By user (table)<br/>- Recent activity timeline
```

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent