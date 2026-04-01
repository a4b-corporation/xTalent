# Glossary - Payroll Assignment Bounded Context

> **Bounded Context**: Payroll Assignment (BC-004)
> **Module**: Payroll (PR)
> **Phase**: Domain Architecture (Step 3)
> **Date**: 2026-03-31

---

## Ubiquitous Language

This glossary defines the terms used within the Payroll Assignment bounded context. All team members should use these terms consistently when discussing employee-to-payroll mapping.

---

## Entities

### PayGroup

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **PayGroup** | Group of employees assigned to the same PayProfile and PayCalendar for payroll processing. | Not PayProfile (configuration). Not PayCalendar (scheduling). Not Worker (employee). |
| **groupCode** | Unique identifier for the pay group. Human-readable like "GRP_STAFF". | Must be unique per tenant. |
| **groupName** | Human-readable name like "Staff Group - HQ". | For display and documentation. |
| **payProfileId** | Reference to PayProfile from Payroll Configuration BC. | Determines pay elements and rules for group. |
| **payCalendarId** | Reference to PayCalendar from Payroll Calendar BC. | Determines pay periods for group. |
| **description** | Optional description of group purpose. | Free text. |
| **isActive** | Flag indicating group is available for employee assignment. | False after deletion. |
| **createdAt** | Timestamp when group was created. | For audit. |
| **createdBy** | User who created the group. | For audit. |

**Lifecycle States**:
- **Active**: isActive = true, employees can be assigned
- **Inactive**: isActive = false, historical reference only

**Business Rules**:
- BR-PG-001: Employee can only be in one pay group at a time
- BR-PG-002: PayProfile must be active for assignment
- BR-PG-003: PayCalendar must be active for assignment

---

### PayGroupAssignment

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **PayGroupAssignment** | Assignment of an employee (Worker) to a PayGroup. | Not PayElementAssignment (element to profile). Not EmploymentAssignment (HR). |
| **assignmentId** | Unique identifier for the assignment. | System-generated UUID. |
| **employeeId** | Reference to Worker from Core HR (CO) module. | Not owned by this module. Reference only. |
| **assignmentDate** | Date when employee was assigned to the group. | For payroll eligibility start. |
| **removalDate** | Date when employee was removed from the group. Nullable for ongoing assignments. | Set when transferred to another group. |
| **assignmentReason** | Reason for assignment (e.g., "New hire", "Promotion"). | Optional but recommended. |
| **removalReason** | Reason for removal (e.g., "Transfer", "Termination"). | Required when removalDate is set. |
| **isCurrent** | Flag indicating this is the current active assignment. | For quick query. |

**Assignment History**:
- An employee can have multiple assignments over time (history)
- Only one assignment can have isCurrent = true
- Assignment history preserved for audit and retroactive calculations

---

## Value Objects

### AssignmentReason

| Value | Definition |
|-------|------------|
| **NEW_HIRE** | Employee newly hired |
| **TRANSFER** | Employee transferred between groups |
| **PROMOTION** | Employee promoted to different profile |
| **REORGANIZATION** | Organizational restructuring |
| **PROFILE_CHANGE** | Profile change for same group |
| **OTHER** | Other reason (requires explanation) |

### RemovalReason

| Value | Definition |
|-------|------------|
| **TRANSFER** | Transferred to another pay group |
| **TERMINATION** | Employee terminated |
| **PROMOTION** | Promoted to different group |
| **REORGANIZATION** | Organizational restructuring |
| **OTHER** | Other reason (requires explanation) |

---

## Events

### PayGroup Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **PayGroupCreated** | A new pay group was created with profile and calendar. | Group creation. |
| **PayGroupUpdated** | Pay group attributes were modified. | Profile or calendar change. |
| **PayGroupDeleted** | Pay group was soft-deleted. | Preserves assignments. |

### PayGroupAssignment Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **EmployeeAssignedToGroup** | An employee was assigned to the pay group. | New assignment created. |
| **EmployeeRemovedFromGroup** | An employee was removed from the pay group. | Assignment ended. |
| **EmployeeTransferred** | Employee transferred between pay groups. | Two assignment changes. |

---

## Commands

| Command | Actor | Description |
|---------|-------|-------------|
| **CreatePayGroup** | Payroll Admin | Create pay group with profile and calendar |
| **UpdatePayGroup** | Payroll Admin | Update group attributes |
| **DeletePayGroup** | Payroll Admin | Soft delete group |
| **AssignEmployeeToGroup** | Payroll Admin | Assign employee to group |
| **RemoveEmployeeFromGroup** | Payroll Admin | Remove employee from group |
| **TransferEmployee** | Payroll Admin | Transfer employee between groups |
| **QueryPayGroup** | Payroll Admin | Get group with assignments |
| **QueryEmployeeAssignment** | Payroll Admin | Get employee's current group |
| **QueryAssignmentHistory** | Payroll Admin | Get employee's assignment history |

---

## Business Rules Detail

### BR-PG-001: Single Employee Assignment

```
Employee EMP001 current assignments:
  Group GRP_STAFF, assignmentDate: 2026-01-15, isCurrent: true

Attempt to assign EMP001 to GRP_EXEC:
  Validation check: Employee already in GRP_STAFF
  Result: Assignment rejected
  Error: "Employee already assigned to pay group GRP_STAFF"

To assign to new group:
  Step 1: Remove from GRP_STAFF with removalDate
  Step 2: Assign to GRP_EXEC with assignmentDate (must be after removalDate)
```

### BR-PG-002: Active Profile Required

```
PayGroup creation attempt:
  payProfileId: PROFILE_OLD (isActive: false)
  
Validation check: Profile must be active
Result: Creation rejected
Error: "Pay profile must be active for assignment"
```

### BR-PG-003: Active Calendar Required

```
PayGroup creation attempt:
  payCalendarId: CAL_2025 (isActive: false, fiscalYear: 2025)
  
Validation check: Calendar must be active
Result: Creation rejected
Error: "Pay calendar must be active for assignment"
```

---

## Integration Points

### Inbound Integrations

| Source | Data | Purpose |
|--------|------|---------|
| Core HR (CO) | Worker (employeeId) | Employee reference |
| Payroll Configuration | PayProfile | Profile reference |
| Payroll Calendar | PayCalendar | Calendar reference |

### Outbound Integrations

| Target | Data | Purpose |
|--------|------|---------|
| Calculation Engine | Employee-Profile mapping | Payroll calculation input |
| Audit Trail | Assignment events | Audit logging |

---

## Example PayGroup

### Staff Group Configuration

```
PayGroup {
  groupCode: "GRP_STAFF_HQ",
  groupName: "Staff Group - Headquarters",
  payProfileId: "PROFILE_STAFF",
  payCalendarId: "CAL_2026_HQ",
  isActive: true
}

PayGroupAssignments:
[
  { employeeId: "EMP001", assignmentDate: "2026-01-15", isCurrent: true },
  { employeeId: "EMP002", assignmentDate: "2026-01-20", isCurrent: true },
  { employeeId: "EMP003", assignmentDate: "2026-02-01", isCurrent: true }
]
```

### Executive Group Configuration

```
PayGroup {
  groupCode: "GRP_EXEC_HQ",
  groupName: "Executive Group - Headquarters",
  payProfileId: "PROFILE_EXEC",
  payCalendarId: "CAL_2026_HQ",
  isActive: true
}

PayGroupAssignments:
[
  { employeeId: "EMP010", assignmentDate: "2026-01-01", isCurrent: true },
  { employeeId: "EMP011", assignmentDate: "2026-01-01", isCurrent: true }
]
```

---

## Assignment History Example

### Employee Transfer Scenario

```
Employee EMP001 assignment history:

Period 1 (2025):
  Group: GRP_STAFF_OLD
  Assignment: 2025-01-15
  Removal: 2025-12-31
  Removal reason: PROFILE_CHANGE

Period 2 (2026):
  Group: GRP_STAFF_HQ
  Assignment: 2026-01-01
  Removal: 2026-06-30
  Removal reason: PROMOTION

Period 3 (Current):
  Group: GRP_EXEC_HQ
  Assignment: 2026-07-01
  Removal: null (ongoing)
  isCurrent: true
```

---

## Query Examples

### Query Employee Current Group

```
Query: Employee EMP001 current assignment

Result:
{
  groupCode: "GRP_EXEC_HQ",
  groupName: "Executive Group - Headquarters",
  payProfileId: "PROFILE_EXEC",
  payCalendarId: "CAL_2026_HQ",
  assignmentDate: "2026-07-01",
  assignmentReason: "PROMOTION"
}
```

### Query Group Members

```
Query: PayGroup GRP_STAFF_HQ current members

Result:
[
  { employeeId: "EMP002", fullName: "Nguyen Van B", assignmentDate: "2026-01-20" },
  { employeeId: "EMP003", fullName: "Le Thi C", assignmentDate: "2026-02-01" },
  { employeeId: "EMP004", fullName: "Tran Van D", assignmentDate: "2026-02-15" }
]

Note: EMP001 was removed (not included in current members)
```

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent