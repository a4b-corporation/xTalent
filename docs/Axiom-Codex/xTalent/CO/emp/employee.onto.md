---
entity: Employee
domain: core-hr
module: CO
version: "1.0.0"
status: draft
owner: "Core HR Team"
tags:
  - core
  - employee
  - workforce

classification:
  type: AGGREGATE_ROOT
  category: Master

# === ATTRIBUTES ===
attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: "System-generated UUID"

  - name: employeeCode
    type: string
    required: true
    unique: true
    description: "Public identifier (e.g., EMP-0042). Unique within organization."
    format: "EMP-XXXX"

  - name: personId
    type: string
    required: true
    description: "FK to Person entity for personal data"

  - name: organizationId
    type: string
    required: true
    description: "FK to Organization (Legal Entity)"

  - name: hireDate
    type: date
    required: true
    description: "Official start of employment"

  - name: terminationDate
    type: date
    required: false
    description: "End of employment (set when terminated)"

  - name: originalHireDate
    type: date
    required: false
    description: "First hire date (preserved for rehires)"

  - name: seniority
    type: date
    required: false
    description: "Seniority date for benefits/tenure calculations"

  - name: employmentTypeCode
    type: string
    required: true
    description: "Full-time, Part-time, Contractor, etc."

  - name: employeeStatusCode
    type: enum
    required: true
    values: [PRE_HIRE, ONBOARDING, PROBATION, ACTIVE, ON_LEAVE, SUSPENDED, OFFBOARDING, TERMINATED]
    description: "Current lifecycle status"

  - name: probationEndDate
    type: date
    required: false
    description: "Expected end of probation period"

  - name: terminationReasonCode
    type: string
    required: false
    description: "Reason for termination"

  - name: terminationType
    type: enum
    required: false
    values: [VOLUNTARY, INVOLUNTARY, RETIREMENT, DEATH]
    description: "Category of termination"

  - name: rehireEligibility
    type: enum
    required: false
    values: [ELIGIBLE, NOT_ELIGIBLE, CONDITIONAL]
    description: "Eligibility for future rehire"

  - name: noticeStartDate
    type: date
    required: false
    description: "Start of notice period"

  - name: lastWorkingDate
    type: date
    required: false
    description: "Last day of actual work"

  - name: createdAt
    type: datetime
    required: true
    description: "Record creation timestamp"

  - name: updatedAt
    type: datetime
    required: true
    description: "Last update timestamp"

# === RELATIONSHIPS ===
relationships:
  - name: isPerson
    target: Person
    cardinality: many-to-one
    required: true
    inverse: hasEmployments
    description: "Personal data of the employee"

  - name: employedBy
    target: Organization
    cardinality: many-to-one
    required: true
    inverse: hasEmployees
    description: "Legal entity employing this person"

  - name: hasAssignments
    target: Assignment
    cardinality: one-to-many
    required: false
    inverse: assignedTo
    description: "Position assignments (one primary, may have secondary)"

  - name: hasContracts
    target: Contract
    cardinality: one-to-many
    required: false
    inverse: signedBy
    description: "Employment contracts"

  - name: reportsTo
    target: Employee
    cardinality: many-to-one
    required: false
    inverse: hasDirectReports
    description: "Direct supervisor/manager"

  - name: hasDirectReports
    target: Employee
    cardinality: one-to-many
    required: false
    inverse: reportsTo
    description: "Employees reporting to this manager"

# === LIFECYCLE ===
lifecycle:
  states: [PRE_HIRE, ONBOARDING, PROBATION, ACTIVE, ON_LEAVE, SUSPENDED, OFFBOARDING, TERMINATED]
  initial: PRE_HIRE
  terminal: [TERMINATED]
  transitions:
    - from: PRE_HIRE
      to: ONBOARDING
      trigger: startOnboarding
      guard: "All required documents collected"

    - from: ONBOARDING
      to: PROBATION
      trigger: completeOnboarding
      guard: "Onboarding tasks completed"

    - from: PROBATION
      to: ACTIVE
      trigger: confirmPermanent
      guard: "Probation period passed, performance OK"

    - from: PROBATION
      to: TERMINATED
      trigger: terminateProbation
      guard: "Probation failed or voluntary"

    - from: ACTIVE
      to: ON_LEAVE
      trigger: startLeave
      guard: "Leave approved"

    - from: ON_LEAVE
      to: ACTIVE
      trigger: returnFromLeave

    - from: ACTIVE
      to: SUSPENDED
      trigger: suspend
      guard: "Disciplinary action"

    - from: SUSPENDED
      to: ACTIVE
      trigger: reinstate

    - from: [ACTIVE, ON_LEAVE, SUSPENDED]
      to: OFFBOARDING
      trigger: initiateTermination
      guard: "Termination approved"

    - from: OFFBOARDING
      to: TERMINATED
      trigger: completeOffboarding
      guard: "Exit tasks completed, final pay processed"

# === POLICIES ===
policies:
  - name: uniqueEmployeeCode
    type: validation
    rule: "Employee code must be unique within organization"
    expression: "UNIQUE(organizationId, employeeCode)"

  - name: hireDateNotFuture
    type: validation
    rule: "Hire date cannot be in the future"
    expression: "hireDate <= TODAY()"

  - name: terminationRequiresReason
    type: validation
    rule: "Termination must have a reason code"
    expression: "IF status = TERMINATED THEN terminationReasonCode IS NOT NULL"

  - name: probationPeriod
    type: business
    rule: "Probation period is typically 60 days for Vietnam"
    expression: "probationEndDate = hireDate + 60 days"

  - name: dataRetention
    type: retention
    rule: "Terminated employee records retained for 10 years per Vietnam Labor Code"

  - name: salaryAccess
    type: access
    rule: "Compensation details visible only to HR, Finance, and direct management chain"
---

# Entity: Employee

## 1. Overview

### Business Context

An **Employee** represents a person who has an employment relationship with the organization. This entity is the **core of HR operations** - from hiring and payroll to performance management and offboarding. 

The Employee entity links personal data ([[Person]]) to organizational placement ([[Assignment]], [[Position]]), forming the foundation for all HR processes.

### Purpose

- Central source of truth for "who works here"
- Enables accurate headcount, labor cost, and compliance reporting
- Drives access control, payroll processing, and benefits eligibility

```mermaid
mindmap
  root((Employee))
    Identity
      employeeCode
      personId
      organizationId
    Employment
      hireDate
      employmentType
      status
    Lifecycle
      PRE_HIRE
      ONBOARDING
      PROBATION
      ACTIVE
      ON_LEAVE
      TERMINATED
    Relationships
      Person
      Organization
      Assignment
      Contract
      Manager
```

## 2. Attributes

| Attribute | Type | Required | PII | Description |
|-----------|------|----------|-----|-------------|
| id | UUID | Yes | No | System-generated unique identifier |
| employeeCode | String | Yes | No | Public identifier (EMP-XXXX) |
| personId | UUID | Yes | Yes | Link to Person for personal data |
| organizationId | UUID | Yes | No | Employing legal entity |
| hireDate | Date | Yes | No | Start of employment |
| terminationDate | Date | No | No | End of employment |
| originalHireDate | Date | No | No | First hire (for rehires) |
| seniority | Date | No | No | Tenure calculation date |
| employmentTypeCode | String | Yes | No | Full-time, Part-time, etc. |
| employeeStatusCode | Enum | Yes | No | Current lifecycle status |
| probationEndDate | Date | No | No | Probation end date |
| terminationReasonCode | String | No | No | Reason for exit |
| terminationType | Enum | No | No | Voluntary/Involuntary category |
| rehireEligibility | Enum | No | No | Future rehire eligibility |
| noticeStartDate | Date | No | No | Notice period start |
| lastWorkingDate | Date | No | No | Last day of work |
| createdAt | Datetime | Yes | No | Record creation time |
| updatedAt | Datetime | Yes | No | Last update time |

### Attribute Notes

- **PII Classification**: `personId` links to Person entity containing all PII data
- **employeeCode**: Public identifier, never changes even after termination
- **Status values**: See Lifecycle section for state machine

## 3. Relationships

```mermaid
erDiagram
    EMPLOYEE }o--|| PERSON : "isPerson"
    EMPLOYEE }o--|| ORGANIZATION : "employedBy"
    EMPLOYEE ||--o{ ASSIGNMENT : "hasAssignments"
    EMPLOYEE ||--o{ CONTRACT : "hasContracts"
    EMPLOYEE }o--o| EMPLOYEE : "reportsTo"
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Person]] | isPerson | n-1 | Personal data (name, DOB, contacts) |
| [[Organization]] | employedBy | n-1 | Employing legal entity |
| [[Assignment]] | hasAssignments | 1-n | Position placements |
| [[Contract]] | hasContracts | 1-n | Employment agreements |
| [[Employee]] | reportsTo | n-1 | Direct supervisor |

### Relationship Details

#### isPerson → [[Person]]
- **Purpose**: Separates personal data from employment data
- **Why**: Same Person can have multiple Employee records (different organizations, rehires)
- **Navigation**: `Employee.isPerson -> Person`
- **Cascade**: ON DELETE RESTRICT

#### employedBy → [[Organization]]
- **Purpose**: Links to employing legal entity
- **Why**: Determines tax jurisdiction, labor law, payroll processing
- **Navigation**: `Employee.employedBy -> Organization`

#### hasAssignments → [[Assignment]]
- **Purpose**: Links to position/job assignments
- **Why**: Employee may have multiple assignments (primary + secondary)
- **Navigation**: `Employee.hasAssignments -> Assignment[]`

#### reportsTo → [[Employee]]
- **Purpose**: Defines management hierarchy
- **Why**: Drives approval workflows, org chart, span of control
- **Self-reference**: CEO/Founders have null supervisor

## 4. Lifecycle

### State Machine

```mermaid
stateDiagram-v2
    [*] --> PRE_HIRE: create
    
    PRE_HIRE --> ONBOARDING: startOnboarding
    ONBOARDING --> PROBATION: completeOnboarding
    
    PROBATION --> ACTIVE: confirmPermanent
    PROBATION --> TERMINATED: terminateProbation
    
    ACTIVE --> ON_LEAVE: startLeave
    ON_LEAVE --> ACTIVE: returnFromLeave
    
    ACTIVE --> SUSPENDED: suspend
    SUSPENDED --> ACTIVE: reinstate
    
    ACTIVE --> OFFBOARDING: initiateTermination
    ON_LEAVE --> OFFBOARDING: initiateTermination
    SUSPENDED --> OFFBOARDING: initiateTermination
    
    OFFBOARDING --> TERMINATED: completeOffboarding
    
    TERMINATED --> [*]
```

### State Definitions

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **PRE_HIRE** | Accepted offer, not yet started | No system access, not in headcount |
| **ONBOARDING** | First days, completing setup | Limited access, training tasks |
| **PROBATION** | Trial period (60 days Vietnam) | Full access, interim review required |
| **ACTIVE** | Normal working status | Full access, included in all reports |
| **ON_LEAVE** | Approved temporary absence | Access may suspend, excluded from assignments |
| **SUSPENDED** | Disciplinary/investigation | Access suspended, payroll may pause |
| **OFFBOARDING** | Separation in progress | Access being revoked, exit tasks |
| **TERMINATED** | Employment ended | No access, retained for compliance |

### Transition Rules

| From | To | Trigger | Guard | Actor |
|------|-----|---------|-------|-------|
| PRE_HIRE | ONBOARDING | startOnboarding | All documents collected | HR |
| ONBOARDING | PROBATION | completeOnboarding | Onboarding tasks done | HR |
| PROBATION | ACTIVE | confirmPermanent | Probation passed | HR+Manager |
| PROBATION | TERMINATED | terminateProbation | Probation failed | HR |
| ACTIVE | ON_LEAVE | startLeave | Leave approved | System |
| ON_LEAVE | ACTIVE | returnFromLeave | Leave ended | System |
| ACTIVE | OFFBOARDING | initiateTermination | Termination approved | HR |
| OFFBOARDING | TERMINATED | completeOffboarding | Exit tasks done | HR |

## 5. Business Rules Reference

This entity is governed by:

| Rule ID | Policy | Description |
|---------|--------|-------------|
| BR-CO-001 | [[employee-lifecycle.brs.md]] | Employee status transition rules |
| BR-CO-002 | [[probation-rules.brs.md]] | Probation period requirements (60 days Vietnam) |
| BR-CO-003 | [[termination-rules.brs.md]] | Termination notice, reasons, eligibility |
| BR-CO-010 | [[data-retention.brs.md]] | 10-year retention for terminated records |

### Key Validation Rules

- **uniqueEmployeeCode**: Employee code unique within organization
- **hireDateNotFuture**: Cannot hire with future date
- **terminationRequiresReason**: Must specify reason code when terminating
- **probationPeriod**: Default 60 days per Vietnam Labor Code

---

## Examples

### Example 1: Standard Full-Time Employee

```yaml
employeeCode: EMP-0042
personId: "uuid-person-123"
organizationId: "uuid-vng-corp"
hireDate: "2023-01-15"
employmentTypeCode: "FULL_TIME"
employeeStatusCode: "ACTIVE"
probationEndDate: "2023-03-15"  # hireDate + 60 days
```

### Example 2: Employee on Maternity Leave

```yaml
employeeCode: EMP-0108
employeeStatusCode: "ON_LEAVE"
hireDate: "2020-06-01"
# Leave type tracked in TimeOff module, not Employee entity
```

### Example 3: Terminated Employee

```yaml
employeeCode: EMP-0033
employeeStatusCode: "TERMINATED"
hireDate: "2018-03-01"
terminationDate: "2024-12-31"
terminationReasonCode: "RESIGNATION"
terminationType: "VOLUNTARY"
rehireEligibility: "ELIGIBLE"
lastWorkingDate: "2024-12-31"
```

---

## Edge Cases & Exceptions

### Rehires

When a terminated employee is rehired:
- Create **new** Employee record with new employeeCode
- Set `originalHireDate` to first employment date
- Use `seniority` date per policy (may bridge service)
- Link via Person entity (same personId)

### Concurrent Employment

Same person working for multiple legal entities:
- Each entity has separate Employee record
- Same `personId`, different `organizationId`
- Different `employeeCode` per organization

### Transfer Between Entities

When employee transfers to different legal entity:
1. Terminate current Employee record (TRANSFERRED reason)
2. Create new Employee in target entity
3. May preserve `seniority` date if same company group
