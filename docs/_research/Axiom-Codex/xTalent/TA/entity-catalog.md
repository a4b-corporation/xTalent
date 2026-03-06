---
domain: TIME_ABSENCE
module: TA
version: "1.0.0"
status: DRAFT
created: "2026-01-15"

# === ENTITY DATA ===
entities:
  # ==========================================
  # LEAVE MANAGEMENT
  # ==========================================
  
  - id: E-TA-001
    name: LeaveRequest
    type: AGGREGATE_ROOT
    category: Transaction
    definition: "A request by an employee for time off work. Central transactional entity for absence management."
    key_attributes:
      - id
      - requestNumber
      - employeeId
      - leaveTypeId
      - startDate
      - endDate
      - totalDays
      - reason
      - status
      - approverId
      - submittedAt
      - approvedAt
    relationships:
      - "requestedBy [[Employee]]"
      - "isTypeOf [[LeaveType]]"
      - "approvedBy [[Employee]]"
      - "affects [[LeaveBalance]]"
    lifecycle: "Draft → Submitted → Pending → Approved/Rejected → Cancelled"
    competitor_reference: "Workday: Time Off, SAP: Absence Request, Oracle: Absence"
    priority: MUST

  - id: E-TA-002
    name: LeaveBalance
    type: ENTITY
    category: Transaction
    definition: "Current leave entitlement balance for an employee by leave type."
    key_attributes:
      - id
      - employeeId
      - leaveTypeId
      - periodStart
      - periodEnd
      - entitled
      - taken
      - scheduled
      - available
      - carriedForward
      - expiring
      - lastCalculatedAt
    relationships:
      - "belongsTo [[Employee]]"
      - "forType [[LeaveType]]"
      - "calculatedFrom [[AccrualPlan]]"
    priority: MUST

  - id: E-TA-003
    name: LeaveType
    type: REFERENCE_DATA
    category: Config
    definition: "Classification of leave (Annual, Sick, Maternity, etc.) with associated rules."
    key_attributes:
      - id
      - code
      - name
      - description
      - category
      - isPaid
      - requiresApproval
      - requiresDocument
      - minNoticeDays
      - maxConsecutiveDays
      - accrualPlanId
      - status
    relationships:
      - "hasAccrualPlan [[AccrualPlan]]"
    priority: MUST

  - id: E-TA-004
    name: LeaveEntitlement
    type: ENTITY
    category: Transaction
    definition: "A specific leave allocation to an employee, either from accrual or manual grant."
    key_attributes:
      - id
      - employeeId
      - leaveTypeId
      - periodStart
      - periodEnd
      - entitlementType
      - days
      - grantedBy
      - reason
      - expiryDate
      - status
    relationships:
      - "belongsTo [[Employee]]"
      - "forType [[LeaveType]]"
    priority: SHOULD

  # ==========================================
  # ACCRUAL MANAGEMENT
  # ==========================================

  - id: E-TA-010
    name: AccrualPlan
    type: AGGREGATE_ROOT
    category: Config
    definition: "Rules defining how leave is earned over time."
    key_attributes:
      - id
      - code
      - name
      - description
      - leaveTypeId
      - accrualFrequency
      - accrualAmount
      - maxAccrual
      - carryForwardLimit
      - carryForwardExpiry
      - prorationRule
      - startingBalance
      - eligibilityRule
      - status
    relationships:
      - "appliesTo [[LeaveType]]"
      - "has many [[AccrualRule]]"
      - "assignedTo [[Employee]] via [[Assignment]]"
    priority: MUST

  - id: E-TA-011
    name: AccrualRule
    type: ENTITY
    category: Config
    definition: "Specific rule within an accrual plan (e.g., seniority tiers)."
    key_attributes:
      - id
      - accrualPlanId
      - ruleName
      - condition
      - accrualDays
      - priority
    relationships:
      - "belongsTo [[AccrualPlan]]"
    priority: MUST

  - id: E-TA-012
    name: AccrualEntry
    type: ENTITY
    category: Transaction
    definition: "A single accrual transaction (credit or debit) to an employee's leave balance."
    key_attributes:
      - id
      - employeeId
      - leaveTypeId
      - accrualPlanId
      - entryDate
      - entryType
      - days
      - description
      - source
      - referenceId
    relationships:
      - "belongsTo [[Employee]]"
      - "forType [[LeaveType]]"
      - "fromPlan [[AccrualPlan]]"
    priority: MUST

  # ==========================================
  # TIME TRACKING
  # ==========================================

  - id: E-TA-020
    name: TimeEntry
    type: AGGREGATE_ROOT
    category: Transaction
    definition: "A record of time worked by an employee for a specific date."
    key_attributes:
      - id
      - employeeId
      - entryDate
      - entryType
      - startTime
      - endTime
      - breakMinutes
      - totalHours
      - projectId
      - taskId
      - comments
      - status
      - approvedBy
    relationships:
      - "belongsTo [[Employee]]"
      - "partOf [[TimeCard]]"
      - "forProject [[Project]]"
    lifecycle: "Draft → Submitted → Approved → Processed"
    competitor_reference: "Workday: Time Entry, SAP: Time Recording"
    priority: MUST

  - id: E-TA-021
    name: TimeCard
    type: ENTITY
    category: Transaction
    definition: "Weekly or periodic summary of time entries for approval."
    key_attributes:
      - id
      - employeeId
      - periodStart
      - periodEnd
      - totalHours
      - regularHours
      - overtimeHours
      - status
      - approvedBy
      - approvedAt
    relationships:
      - "belongsTo [[Employee]]"
      - "contains [[TimeEntry]]"
    lifecycle: "Open → Submitted → Approved → Locked"
    priority: MUST

  - id: E-TA-022
    name: TimeEntryType
    type: REFERENCE_DATA
    category: Config
    definition: "Classification of time worked (Regular, Overtime, On-call, etc.)."
    key_attributes:
      - id
      - code
      - name
      - description
      - isOvertime
      - payMultiplier
      - countAsWorked
      - status
    priority: MUST

  - id: E-TA-023
    name: ClockPunch
    type: ENTITY
    category: Transaction
    definition: "A physical or digital clock in/out event."
    key_attributes:
      - id
      - employeeId
      - punchTime
      - punchType
      - deviceId
      - locationId
      - coordinates
      - status
    relationships:
      - "belongsTo [[Employee]]"
      - "atLocation [[Location]]"
    priority: SHOULD

  # ==========================================
  # SCHEDULING
  # ==========================================

  - id: E-TA-030
    name: WorkSchedule
    type: ENTITY
    category: Config
    definition: "A defined pattern of working hours."
    key_attributes:
      - id
      - code
      - name
      - description
      - hoursPerDay
      - hoursPerWeek
      - workDays
      - startTime
      - endTime
      - breakMinutes
      - isFlexible
      - status
    relationships:
      - "has many [[Shift]]"
      - "appliesTo [[Assignment]]"
    priority: MUST

  - id: E-TA-031
    name: Shift
    type: ENTITY
    category: Config
    definition: "A specific work period within a schedule."
    key_attributes:
      - id
      - code
      - name
      - startTime
      - endTime
      - breakMinutes
      - color
      - status
    relationships:
      - "partOf [[WorkSchedule]]"
    priority: SHOULD

  - id: E-TA-032
    name: ShiftAssignment
    type: ENTITY
    category: Transaction
    definition: "Assignment of a shift to an employee for a specific date."
    key_attributes:
      - id
      - employeeId
      - shiftId
      - assignmentDate
      - status
      - swappedWith
    relationships:
      - "assignedTo [[Employee]]"
      - "uses [[Shift]]"
    priority: SHOULD

  # ==========================================
  # HOLIDAY MANAGEMENT
  # ==========================================

  - id: E-TA-040
    name: HolidayCalendar
    type: AGGREGATE_ROOT
    category: Config
    definition: "A calendar of holidays applicable to a region or organization."
    key_attributes:
      - id
      - code
      - name
      - year
      - countryCode
      - regionCode
      - organizationId
      - status
    relationships:
      - "has many [[Holiday]]"
      - "appliesTo [[Organization]]"
    priority: MUST

  - id: E-TA-041
    name: Holiday
    type: ENTITY
    category: Config
    definition: "A specific non-working day."
    key_attributes:
      - id
      - calendarId
      - name
      - holidayDate
      - holidayType
      - isHalfDay
      - compensationDate
      - description
    relationships:
      - "belongsTo [[HolidayCalendar]]"
    priority: MUST

  # ==========================================
  # OVERTIME MANAGEMENT
  # ==========================================

  - id: E-TA-050
    name: OvertimeRequest
    type: AGGREGATE_ROOT
    category: Transaction
    definition: "A request for pre-approved overtime work."
    key_attributes:
      - id
      - requestNumber
      - employeeId
      - requestDate
      - plannedStart
      - plannedEnd
      - estimatedHours
      - actualHours
      - reason
      - projectId
      - status
      - approvedBy
    relationships:
      - "requestedBy [[Employee]]"
      - "approvedBy [[Employee]]"
      - "forProject [[Project]]"
    lifecycle: "Submitted → Approved/Rejected → Completed → Processed"
    priority: SHOULD

  - id: E-TA-051
    name: OvertimeRule
    type: REFERENCE_DATA
    category: Config
    definition: "Rules for overtime calculation and limits."
    key_attributes:
      - id
      - code
      - name
      - dailyLimit
      - weeklyLimit
      - monthlyLimit
      - yearlyLimit
      - rate1x5Threshold
      - rate2xThreshold
      - rate3xThreshold
      - requiresPreApproval
      - status
    priority: SHOULD

  # ==========================================
  # ABSENCE TRACKING
  # ==========================================

  - id: E-TA-060
    name: AbsenceRecord
    type: ENTITY
    category: Transaction
    definition: "A record of actual absence (after leave is taken or unplanned absence occurs)."
    key_attributes:
      - id
      - employeeId
      - absenceDate
      - absenceType
      - hours
      - leaveRequestId
      - isUnplanned
      - reason
      - status
    relationships:
      - "belongsTo [[Employee]]"
      - "linkedTo [[LeaveRequest]]"
    priority: SHOULD

  - id: E-TA-061
    name: AbsenceType
    type: REFERENCE_DATA
    category: Config
    definition: "Types of absences for tracking purposes."
    key_attributes:
      - id
      - code
      - name
      - description
      - category
      - isPlanned
      - affectsBalance
      - status
    priority: SHOULD
---

# Entity Catalog: Time & Absence

> **Note**: YAML above is for AI processing. Tables below for human reading.

## Entity Relationship Diagram

```mermaid
erDiagram
    Employee ||--o{ LeaveRequest : "submits"
    Employee ||--o{ LeaveBalance : "has"
    Employee ||--o{ TimeEntry : "records"
    Employee ||--o{ OvertimeRequest : "submits"
    
    LeaveType ||--o{ LeaveRequest : "classifies"
    LeaveType ||--o{ LeaveBalance : "measures"
    LeaveType ||--o| AccrualPlan : "has"
    
    AccrualPlan ||--o{ AccrualRule : "contains"
    AccrualPlan ||--o{ AccrualEntry : "generates"
    
    LeaveRequest }o--|| LeaveBalance : "affects"
    
    TimeEntry }o--|| TimeCard : "partOf"
    TimeEntry }o--|| TimeEntryType : "classifies"
    
    WorkSchedule ||--o{ Shift : "contains"
    Shift ||--o{ ShiftAssignment : "assigned"
    
    HolidayCalendar ||--o{ Holiday : "contains"
    
    OvertimeRequest }o--|| OvertimeRule : "follows"
```

---

## A. Leave Management

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-TA-001 | **[[LeaveRequest]]** | AGGREGATE_ROOT | Employee request for time off. Central transactional entity. |
| E-TA-002 | **[[LeaveBalance]]** | ENTITY | Current leave entitlement balance by type. |
| E-TA-003 | **[[LeaveType]]** | REFERENCE_DATA | Classification of leave (Annual, Sick, etc.). |
| E-TA-004 | **[[LeaveEntitlement]]** | ENTITY | Specific leave allocation to employee. |

---

## B. Accrual Management

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-TA-010 | **[[AccrualPlan]]** | AGGREGATE_ROOT | Rules for how leave is earned over time. |
| E-TA-011 | **[[AccrualRule]]** | ENTITY | Specific rule within accrual plan (seniority tiers). |
| E-TA-012 | **[[AccrualEntry]]** | ENTITY | Single accrual transaction (credit/debit). |

---

## C. Time Tracking

| ID | Entity | Lifecycle | Definition |
|----|--------|-----------|------------|
| E-TA-020 | **[[TimeEntry]]** | Draft → Submitted → Approved → Processed | Record of time worked for specific date. |
| E-TA-021 | **[[TimeCard]]** | Open → Submitted → Approved → Locked | Periodic summary of time entries. |
| E-TA-022 | **[[TimeEntryType]]** | - | Classification of time (Regular, OT, On-call). |
| E-TA-023 | **[[ClockPunch]]** | - | Physical/digital clock in/out event. |

---

## D. Scheduling

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-TA-030 | **[[WorkSchedule]]** | ENTITY | Defined pattern of working hours. |
| E-TA-031 | **[[Shift]]** | ENTITY | Specific work period within schedule. |
| E-TA-032 | **[[ShiftAssignment]]** | ENTITY | Assignment of shift to employee for date. |

---

## E. Holiday Management

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-TA-040 | **[[HolidayCalendar]]** | AGGREGATE_ROOT | Calendar of holidays for region/org. |
| E-TA-041 | **[[Holiday]]** | ENTITY | Specific non-working day. |

---

## F. Overtime Management

| ID | Entity | Lifecycle | Definition |
|----|--------|-----------|------------|
| E-TA-050 | **[[OvertimeRequest]]** | Submitted → Approved → Completed → Processed | Request for pre-approved overtime. |
| E-TA-051 | **[[OvertimeRule]]** | - | Rules for OT calculation and limits. |

---

## G. Absence Tracking

| ID | Entity | Type | Definition |
|----|--------|------|------------|
| E-TA-060 | **[[AbsenceRecord]]** | ENTITY | Record of actual absence (planned/unplanned). |
| E-TA-061 | **[[AbsenceType]]** | REFERENCE_DATA | Types of absences for tracking. |

---

## Summary Statistics

| Category | Count |
|----------|-------|
| AGGREGATE_ROOT | 5 |
| ENTITY | 11 |
| REFERENCE_DATA | 5 |
| **Total Entities** | **21** |

---

## Domain Terminology

| Term | Definition |
|------|------------|
| **Accrual** | Process of earning leave over time |
| **Entitlement** | Total leave days an employee is entitled to |
| **Balance** | Available days = Entitled - Taken - Scheduled |
| **Carry Forward** | Unused leave transferred to next period |
| **Proration** | Partial calculation for incomplete periods |
| **Time Card** | Summary of time entries for a period |
| **Clock Punch** | Record of clock-in or clock-out event |
