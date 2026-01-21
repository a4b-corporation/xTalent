# Integration Map

> **Core HR (CO) Module** | Cross-Module Integration Architecture
> Date: 2026-01-19

---

## Overview

Core HR (CO) is the foundation module providing employee data to Time & Absence (TA), Total Rewards (TR), and Payroll (PR). This document defines integration patterns, event contracts, and data dependencies.

```mermaid
graph TB
    subgraph "CO: Core HR"
        Worker
        WorkRelationship
        Employee
        Assignment
        Contract
        Position
        LegalEntity
        BusinessUnit
        WorkLocation
    end
    
    subgraph "TA: Time & Absence"
        TimeRecord
        LeaveRequest
        Schedule
    end
    
    subgraph "TR: Total Rewards"
        Compensation
        Benefit
        SalaryGrade
    end
    
    subgraph "PR: Payroll"
        PayRun
        PayElement
        SIContribution
    end
    
    Employee -->|Events| TA
    Employee -->|Events| TR
    Employee -->|Events| PR
    Assignment -->|Events| TA
    Contract -->|Events| PR
    WorkRelationship -->|Events| PR
```

---

## Integration Patterns

### Pattern 1: API Sync (Real-time Queries)

| Use Case | Consumer | CO Endpoint | Data |
|----------|----------|-------------|------|
| Employee lookup | TA, TR, PR | `GET /employees/{id}` | Employee, Worker name |
| Position info | TR | `GET /positions/{id}` | Job, SalaryGrade |
| Assignment details | TA | `GET /assignments/{id}` | WorkLocation, Schedule |
| Manager lookup | All | `GET /assignments/{id}/supervisor` | Supervisor chain |

### Pattern 2: Event-Driven (Async Notifications)

| Event | Publisher | Consumers | Use Case |
|-------|-----------|-----------|----------|
| `employee.hired` | CO | TA, TR, PR | New employee setup |
| `employee.terminated` | CO | TA, TR, PR | Exit processing |
| `assignment.created` | CO | TA | Time rules assignment |
| `assignment.ended` | CO | TA | Stop time tracking |
| `contract.signed` | CO | PR | Salary setup |
| `contract.renewed` | CO | PR | Salary adjustment |
| `workrelationship.terminated` | CO | PR | Final pay processing |

### Pattern 3: Batch (Bulk Transfers)

| Use Case | From | To | Frequency |
|----------|------|-------|-----------|
| Headcount report | CO | Finance | Daily |
| Statutory report | CO | Government | Monthly |
| SI registration | CO | BHXH Portal | On-demand |
| Payroll data sync | CO | PR | Per pay period |

---

## Event Contract Specifications

### Event: employee.hired

```yaml
event: employee.hired
version: "1.0"
producer: CO
consumers: [TA, TR, PR]

payload:
  employeeId: string
  workerId: string
  legalEntityCode: string
  employeeCode: string
  hireDate: date
  workerCategoryCode: string
  employeeClassCode: string
  
  # Assignment context
  assignmentId: string
  positionId: string
  businessUnitId: string
  workLocationId: string
  managerId: string
  
  # Contract context
  contractId: string
  contractTypeCode: string
  probationEndDate: date?

consumer_actions:
  TA:
    - Create TimeProfile for employee
    - Assign default schedule based on WorkLocation
    - Initialize leave balances
  TR:
    - Create Compensation record
    - Determine benefit eligibility
    - Link to SalaryGrade via Position
  PR:
    - Create PayrollAssignment
    - Register for SI/tax
    - Add to next PayRun
```

### Event: employee.terminated

```yaml
event: employee.terminated
version: "1.0"
producer: CO
consumers: [TA, TR, PR]

payload:
  employeeId: string
  terminationDate: date
  terminationReasonCode: string
  lastWorkingDate: date
  finalPayDate: date
  
  # Entitlements
  unusedLeaveBalance: number
  severanceEligibility: boolean

consumer_actions:
  TA:
    - Close all active time records
    - Calculate final leave balance
    - Stop future schedule assignments
  TR:
    - End compensation record
    - Process benefit termination
    - Calculate final entitlements
  PR:
    - Calculate final pay
    - Include severance if eligible
    - Process SI de-registration
```

### Event: assignment.created

```yaml
event: assignment.created
version: "1.0"
producer: CO
consumers: [TA]

payload:
  assignmentId: string
  employeeId: string
  positionId: string
  businessUnitId: string
  workLocationId: string
  startDate: date
  isPrimary: boolean
  fte: number
  supervisorAssignmentId: string

consumer_actions:
  TA:
    - Determine time policy from WorkLocation
    - Assign shift schedule if applicable
    - Set attendance rules
```

### Event: contract.signed

```yaml
event: contract.signed
version: "1.0"
producer: CO
consumers: [PR]

payload:
  contractId: string
  employeeId: string
  contractTypeCode: string
  startDate: date
  endDate: date?
  
  # Salary info (from contract template)
  baseSalary: Money
  workScheduleTypeCode: string
  probationDays: number?
  probationSalaryPercent: number?

consumer_actions:
  PR:
    - Create SalaryElement from baseSalary
    - Apply probation salary if applicable
    - Set payroll calendar per schedule
```

### Event: workrelationship.terminated

```yaml
event: workrelationship.terminated
version: "1.0"
producer: CO
consumers: [PR]

payload:
  workRelationshipId: string
  workerId: string
  legalEntityCode: string
  relationshipTypeCode: string
  terminationDate: date
  terminationReasonCode: string

consumer_actions:
  PR:
    - If EMPLOYEE: Process final payroll
    - If EMPLOYEE: SI de-registration
    - Archive payroll history
```

---

## Data Dependency Graph

### CO → TA Dependencies

```mermaid
flowchart LR
    subgraph "CO provides"
        A1[Employee]
        A2[Assignment]
        A3[WorkLocation]
        A4[Position]
    end
    
    subgraph "TA uses for"
        B1[Time Policy]
        B2[Schedule Assignment]
        B3[Attendance Rules]
        B4[Leave Eligibility]
    end
    
    A1 --> B4
    A2 --> B1 & B2
    A3 --> B3
    A4 --> B4
```

| CO Entity | TA Depends On | For |
|-----------|---------------|-----|
| Employee | Status, Class | Leave eligibility, active tracking |
| Assignment | Primary, Location | Schedule, time rules |
| WorkLocation | Type, Timezone | Attendance zones, clock policies |
| Position | Level, Category | Overtime eligibility |

### CO → TR Dependencies

```mermaid
flowchart LR
    subgraph "CO provides"
        C1[Employee]
        C2[Position]
        C3[Contract]
        C4[WorkRelationship]
    end
    
    subgraph "TR uses for"
        D1[Compensation Plan]
        D2[Salary Grade]
        D3[Benefit Eligibility]
        D4[Award Programs]
    end
    
    C1 --> D1 & D3
    C2 --> D2
    C3 --> D1
    C4 --> D3
```

| CO Entity | TR Depends On | For |
|-----------|---------------|-----|
| Employee | Tenure, Status | Compensation history |
| Position | Job, Grade | Salary range |
| Contract | Type, Dates | Salary effective dates |
| WorkRelationship | Type | Benefit eligibility (EMPLOYEE only) |

### CO → PR Dependencies

```mermaid
flowchart LR
    subgraph "CO provides"
        E1[Employee]
        E2[Contract]
        E3[WorkRelationship]
        E4[LegalEntity]
    end
    
    subgraph "PR uses for"
        F1[Payroll Processing]
        F2[Tax Calculation]
        F3[SI Contribution]
        F4[Statutory Reporting]
    end
    
    E1 --> F1
    E2 --> F1 & F2
    E3 --> F3
    E4 --> F4
```

| CO Entity | PR Depends On | For |
|-----------|---------------|-----|
| Employee | Code, Status | Payroll inclusion |
| Contract | Salary, Schedule | Pay calculation |
| WorkRelationship | Type | SI applicability |
| LegalEntity | TaxId, Country | Tax jurisdiction |

---

## Cross-Module Data Flow

### Hire Flow

```mermaid
sequenceDiagram
    participant User as HR Admin
    participant CO as Core HR
    participant TA as Time & Absence
    participant TR as Total Rewards
    participant PR as Payroll
    
    User->>CO: Create Employee
    CO->>CO: Create WorkRelationship, Contract, Assignment
    CO-->>TA: employee.hired event
    CO-->>TR: employee.hired event
    CO-->>PR: contract.signed event
    
    TA->>TA: Create TimeProfile, Schedule
    TR->>TR: Create Compensation, Benefits
    PR->>PR: Create PayrollAssignment, SI Registration
```

### Termination Flow

```mermaid
sequenceDiagram
    participant User as HR Admin
    participant CO as Core HR
    participant TA as Time & Absence
    participant TR as Total Rewards
    participant PR as Payroll
    
    User->>CO: Initiate Termination
    CO->>CO: Set terminationDate, update status
    CO-->>TA: employee.terminated event
    CO-->>TR: employee.terminated event
    CO-->>PR: workrelationship.terminated event
    
    TA->>TA: Close time records, calculate leave balance
    TA-->>PR: Leave payout amount
    TR->>TR: End compensation, benefits
    PR->>PR: Calculate final pay, SI deregistration
```

---

## API Contract Summary

| Endpoint | Method | Consumer | Response |
|----------|--------|----------|----------|
| `/api/v1/employees/{id}` | GET | TA, TR, PR | Employee with Worker details |
| `/api/v1/employees/{id}/assignment` | GET | TA | Current primary assignment |
| `/api/v1/employees/{id}/contract` | GET | PR | Active contract |
| `/api/v1/positions/{id}` | GET | TR | Position with Job, Grade |
| `/api/v1/work-locations/{id}` | GET | TA | WorkLocation with policies |
| `/api/v1/legal-entities/{code}` | GET | PR | LegalEntity for tax |

---

## Event Bus Configuration

| Topic | Partition Key | Retention | Consumers |
|-------|---------------|-----------|-----------|
| `co.employee.lifecycle` | employeeId | 7 days | TA, TR, PR |
| `co.assignment.changes` | assignmentId | 7 days | TA |
| `co.contract.events` | contractId | 30 days | PR |
| `co.workrelationship.events` | workRelationshipId | 30 days | PR |
