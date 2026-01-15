---
domain: TIME_ABSENCE
module: TA
version: "1.0.0"
status: DRAFT
created: "2026-01-15"

# === FEATURE DATA ===
capabilities:
  # ==========================================
  # LEAVE MANAGEMENT
  # ==========================================
  - name: "Leave Management"
    description: "Handle leave requests, approvals, and balance tracking."
    features:
      - id: FR-TA-001
        name: "Submit Leave Request"
        description: "As an Employee, I want to submit a leave request so that I can take time off work."
        priority: MUST
        type: Workflow
        competitor_reference: "Workday: Request Time Off, SAP: Absence Request"
        related_entities:
          - "[[LeaveRequest]]"
          - "[[LeaveBalance]]"
          - "[[LeaveType]]"
        sub_features:
          - "Select leave type"
          - "Choose date range"
          - "View available balance"
          - "Add reason/comments"
          - "Attach documents (if required)"
          - "Submit for approval"
          - "Receive confirmation"

      - id: FR-TA-002
        name: "Approve/Reject Leave Request"
        description: "As a Manager, I want to approve or reject leave requests so that team coverage is maintained."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[LeaveRequest]]"
          - "[[Employee]]"
        sub_features:
          - "View pending requests"
          - "Check team calendar"
          - "Approve with comments"
          - "Reject with reason"
          - "Delegate approval"
          - "Bulk approve"

      - id: FR-TA-003
        name: "View Leave Balance"
        description: "As an Employee, I want to view my leave balance so that I know how many days I have available."
        priority: MUST
        type: Functional
        related_entities:
          - "[[LeaveBalance]]"
          - "[[LeaveType]]"
        sub_features:
          - "View by leave type"
          - "See accrued vs taken"
          - "View scheduled leaves"
          - "Check expiring balance"
          - "View carry forward"

      - id: FR-TA-004
        name: "Cancel Leave Request"
        description: "As an Employee, I want to cancel a submitted leave request so that I can change my plans."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[LeaveRequest]]"
          - "[[LeaveBalance]]"
        sub_features:
          - "Cancel pending request"
          - "Request cancellation of approved leave"
          - "Automatic balance adjustment"

      - id: FR-TA-005
        name: "View Team Absence Calendar"
        description: "As a Manager, I want to view my team's absence calendar so that I can plan work coverage."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[LeaveRequest]]"
          - "[[Employee]]"
        sub_features:
          - "Calendar view of absences"
          - "Filter by department/team"
          - "View overlap warnings"
          - "Export calendar"

      - id: FR-TA-006
        name: "View Leave History"
        description: "As an Employee, I want to view my leave history so that I can track my time off patterns."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[LeaveRequest]]"

      - id: FR-TA-007
        name: "Assign Substitute"
        description: "As an Employee, I want to assign a substitute during my absence so that my responsibilities are covered."
        priority: COULD
        type: Functional
        related_entities:
          - "[[LeaveRequest]]"
          - "[[Employee]]"

  # ==========================================
  # ACCRUAL MANAGEMENT
  # ==========================================
  - name: "Accrual Management"
    description: "Configure and manage leave accrual plans and calculations."
    features:
      - id: FR-TA-010
        name: "Configure Accrual Plan"
        description: "As an HR Admin, I want to configure accrual plans so that leave is calculated correctly."
        priority: MUST
        type: Functional
        related_entities:
          - "[[AccrualPlan]]"
          - "[[AccrualRule]]"
          - "[[LeaveType]]"
        sub_features:
          - "Define accrual frequency"
          - "Set accrual amount"
          - "Configure seniority tiers"
          - "Set carry forward rules"
          - "Define expiry rules"
          - "Set proration method"

      - id: FR-TA-011
        name: "Assign Accrual Plan to Employee"
        description: "As an HR Admin, I want to assign accrual plans to employees so that they receive correct entitlements."
        priority: MUST
        type: Functional
        related_entities:
          - "[[AccrualPlan]]"
          - "[[Employee]]"
          - "[[Assignment]]"

      - id: FR-TA-012
        name: "Run Accrual Calculation"
        description: "As an HR Admin, I want to run accrual calculations so that balances are updated."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[AccrualPlan]]"
          - "[[AccrualEntry]]"
          - "[[LeaveBalance]]"
        sub_features:
          - "Scheduled auto-run"
          - "Manual trigger"
          - "Retroactive calculation"
          - "Preview before commit"

      - id: FR-TA-013
        name: "Grant Manual Entitlement"
        description: "As an HR Admin, I want to manually grant leave so that special allocations are recorded."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[LeaveEntitlement]]"
          - "[[LeaveBalance]]"
        sub_features:
          - "Grant additional days"
          - "Deduct days (adjustment)"
          - "Record reason"
          - "Set expiry if applicable"

      - id: FR-TA-014
        name: "Process Year-End Carry Forward"
        description: "As an HR Admin, I want to process year-end so that carry forwards are calculated."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[LeaveBalance]]"
          - "[[AccrualPlan]]"
        sub_features:
          - "Calculate unused leave"
          - "Apply carry forward limits"
          - "Set expiry dates"
          - "Archive previous year"

  # ==========================================
  # TIME TRACKING
  # ==========================================
  - name: "Time Tracking"
    description: "Record and manage employee working hours."
    features:
      - id: FR-TA-020
        name: "Clock In/Out"
        description: "As an Employee, I want to clock in and out so that my work hours are tracked."
        priority: MUST
        type: Functional
        competitor_reference: "Workday: Time Tracking, SAP: Digital Punch"
        related_entities:
          - "[[ClockPunch]]"
          - "[[TimeEntry]]"
        sub_features:
          - "Mobile clock-in"
          - "Web clock-in"
          - "Location capture"
          - "Break tracking"
          - "Missed punch handling"

      - id: FR-TA-021
        name: "Submit Time Entry"
        description: "As an Employee, I want to submit my time entries so that my work is recorded."
        priority: MUST
        type: Functional
        related_entities:
          - "[[TimeEntry]]"
          - "[[TimeCard]]"
        sub_features:
          - "Enter hours per day"
          - "Assign to project/task"
          - "Add comments"
          - "Submit for approval"

      - id: FR-TA-022
        name: "Approve Time Card"
        description: "As a Manager, I want to approve time cards so that payroll can be processed."
        priority: MUST
        type: Workflow
        related_entities:
          - "[[TimeCard]]"
          - "[[TimeEntry]]"
        sub_features:
          - "Review time entries"
          - "Check against schedule"
          - "Approve/reject entries"
          - "Add corrections"
          - "Bulk approval"

      - id: FR-TA-023
        name: "View Timesheet"
        description: "As an Employee, I want to view my timesheet so that I can review my recorded hours."
        priority: MUST
        type: Functional
        related_entities:
          - "[[TimeCard]]"
          - "[[TimeEntry]]"

      - id: FR-TA-024
        name: "Correct Time Entry"
        description: "As a Manager, I want to correct time entries so that errors are fixed."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[TimeEntry]]"
        sub_features:
          - "Edit submitted entry"
          - "Add missing punch"
          - "Record audit trail"

  # ==========================================
  # SCHEDULING
  # ==========================================
  - name: "Scheduling"
    description: "Manage work schedules and shift assignments."
    features:
      - id: FR-TA-030
        name: "Define Work Schedule"
        description: "As an HR Admin, I want to define work schedules so that employees have clear working hours."
        priority: MUST
        type: Functional
        related_entities:
          - "[[WorkSchedule]]"
          - "[[Shift]]"
        sub_features:
          - "Set daily hours"
          - "Define work days"
          - "Configure breaks"
          - "Create shifts"

      - id: FR-TA-031
        name: "Assign Schedule to Employee"
        description: "As an HR Admin, I want to assign work schedules so that employees know their hours."
        priority: MUST
        type: Functional
        related_entities:
          - "[[WorkSchedule]]"
          - "[[Assignment]]"

      - id: FR-TA-032
        name: "Manage Shift Roster"
        description: "As a Manager, I want to manage shift roster so that coverage is planned."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[ShiftAssignment]]"
          - "[[Shift]]"
        sub_features:
          - "Create weekly roster"
          - "Copy previous week"
          - "Auto-generate from pattern"
          - "Publish roster"

      - id: FR-TA-033
        name: "Request Shift Swap"
        description: "As an Employee, I want to request a shift swap so that I can adjust my schedule."
        priority: COULD
        type: Workflow
        related_entities:
          - "[[ShiftAssignment]]"
        sub_features:
          - "Find available swaps"
          - "Request swap with colleague"
          - "Manager approval"

  # ==========================================
  # HOLIDAY MANAGEMENT
  # ==========================================
  - name: "Holiday Management"
    description: "Manage public and company holidays."
    features:
      - id: FR-TA-040
        name: "Manage Holiday Calendar"
        description: "As an HR Admin, I want to manage holiday calendars so that non-working days are defined."
        priority: MUST
        type: Functional
        related_entities:
          - "[[HolidayCalendar]]"
          - "[[Holiday]]"
        sub_features:
          - "Create calendar by year"
          - "Add public holidays"
          - "Add company holidays"
          - "Set regional variations"
          - "Define compensation days"

      - id: FR-TA-041
        name: "View Holiday Calendar"
        description: "As an Employee, I want to view the holiday calendar so that I can plan my time off."
        priority: MUST
        type: Functional
        related_entities:
          - "[[HolidayCalendar]]"
          - "[[Holiday]]"

      - id: FR-TA-042
        name: "Assign Calendar to Organization"
        description: "As an HR Admin, I want to assign calendars to organizations so that correct holidays apply."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[HolidayCalendar]]"
          - "[[Organization]]"

  # ==========================================
  # OVERTIME MANAGEMENT
  # ==========================================
  - name: "Overtime Management"
    description: "Track and control overtime work."
    features:
      - id: FR-TA-050
        name: "Submit Overtime Request"
        description: "As an Employee, I want to submit an overtime request so that I can work extra hours."
        priority: SHOULD
        type: Workflow
        related_entities:
          - "[[OvertimeRequest]]"
          - "[[OvertimeRule]]"
        sub_features:
          - "Request date and hours"
          - "Specify reason"
          - "Check against limits"
          - "Submit for approval"

      - id: FR-TA-051
        name: "Approve Overtime Request"
        description: "As a Manager, I want to approve overtime requests so that extra work is authorized."
        priority: SHOULD
        type: Workflow
        related_entities:
          - "[[OvertimeRequest]]"
        sub_features:
          - "Review request"
          - "Check department limit"
          - "Approve/reject"

      - id: FR-TA-052
        name: "Configure Overtime Rules"
        description: "As an HR Admin, I want to configure overtime rules so that limits and rates are defined."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[OvertimeRule]]"
        sub_features:
          - "Set daily/weekly/monthly limits"
          - "Define rate multipliers"
          - "Configure pre-approval requirement"

      - id: FR-TA-053
        name: "Track Overtime Usage"
        description: "As an HR Admin, I want to track overtime usage so that compliance is monitored."
        priority: SHOULD
        type: Reporting
        related_entities:
          - "[[OvertimeRequest]]"
          - "[[TimeEntry]]"
        sub_features:
          - "Dashboard of OT hours"
          - "Alert on limit breach"
          - "Monthly report"

  # ==========================================
  # COMPLIANCE & REPORTING
  # ==========================================
  - name: "Compliance & Reporting"
    description: "Ensure compliance and generate reports."
    features:
      - id: FR-TA-060
        name: "Attendance Report"
        description: "As a Manager, I want to generate attendance reports so that I can monitor punctuality."
        priority: SHOULD
        type: Reporting
        related_entities:
          - "[[TimeEntry]]"
          - "[[ClockPunch]]"

      - id: FR-TA-061
        name: "Leave Summary Report"
        description: "As an HR Admin, I want to generate leave reports so that I can analyze absence patterns."
        priority: SHOULD
        type: Reporting
        related_entities:
          - "[[LeaveRequest]]"
          - "[[LeaveBalance]]"

      - id: FR-TA-062
        name: "Accrual Report"
        description: "As an HR Admin, I want to generate accrual reports so that I can verify calculations."
        priority: SHOULD
        type: Reporting
        related_entities:
          - "[[AccrualEntry]]"
          - "[[LeaveBalance]]"

      - id: FR-TA-063
        name: "Compliance Dashboard"
        description: "As an HR Admin, I want to view compliance dashboard so that I can monitor labor law adherence."
        priority: SHOULD
        type: Functional
        related_entities:
          - "[[OvertimeRule]]"
          - "[[TimeEntry]]"
        sub_features:
          - "Working hours violations"
          - "Overtime limit breaches"
          - "Leave policy adherence"

# === BUSINESS RULES ===
business_rules:
  - id: BR-TA-001
    title: "No Overlapping Leave"
    description: "An employee cannot have overlapping approved leave requests."
    category: Validation
    severity: BLOCK
    related_entities:
      - "[[LeaveRequest]]"

  - id: BR-TA-002
    title: "Minimum Notice Period"
    description: "Leave requests must be submitted with minimum notice (e.g., 2 days for annual leave)."
    category: Validation
    severity: WARN
    related_entities:
      - "[[LeaveRequest]]"
      - "[[LeaveType]]"

  - id: BR-TA-003
    title: "Insufficient Balance"
    description: "Leave requests cannot exceed available balance (for deducted leave types)."
    category: Validation
    severity: BLOCK
    related_entities:
      - "[[LeaveRequest]]"
      - "[[LeaveBalance]]"

  - id: BR-TA-004
    title: "Probation Leave Restriction"
    description: "Employees on probation cannot apply for annual leave."
    category: Eligibility
    severity: BLOCK
    related_entities:
      - "[[LeaveRequest]]"
      - "[[Assignment]]"

  - id: BR-TA-005
    title: "Manager Cannot Self-Approve"
    description: "Managers cannot approve their own leave requests."
    category: Approval
    severity: BLOCK
    related_entities:
      - "[[LeaveRequest]]"

  - id: BR-TA-006
    title: "Carry Forward Limit"
    description: "Maximum 3 days can be carried forward to next year (Vietnam)."
    category: Compliance
    severity: WARN
    related_entities:
      - "[[LeaveBalance]]"
      - "[[AccrualPlan]]"

  - id: BR-TA-007
    title: "Daily Overtime Limit"
    description: "Overtime cannot exceed 4 hours per day (Vietnam labor law)."
    category: Compliance
    severity: BLOCK
    related_entities:
      - "[[OvertimeRequest]]"
      - "[[TimeEntry]]"

  - id: BR-TA-008
    title: "Monthly Overtime Limit"
    description: "Overtime cannot exceed 40 hours per month (Vietnam labor law)."
    category: Compliance
    severity: BLOCK
    related_entities:
      - "[[OvertimeRequest]]"
      - "[[TimeEntry]]"

  - id: BR-TA-009
    title: "Sick Leave Documentation"
    description: "Sick leave exceeding 3 days requires medical certificate."
    category: Validation
    severity: WARN
    related_entities:
      - "[[LeaveRequest]]"
      - "[[LeaveType]]"

  - id: BR-TA-010
    title: "Time Entry Deadline"
    description: "Time entries must be submitted within 7 days of work date."
    category: Validation
    severity: WARN
    related_entities:
      - "[[TimeEntry]]"
      - "[[TimeCard]]"

  - id: BR-TA-011
    title: "Holiday Leave Calculation"
    description: "Leave days calculation must exclude public holidays."
    category: Calculation
    severity: BLOCK
    related_entities:
      - "[[LeaveRequest]]"
      - "[[HolidayCalendar]]"

  - id: BR-TA-012
    title: "Seniority Leave Increment"
    description: "Additional 1 day annual leave per 5 years of service (Vietnam)."
    category: Accrual
    severity: MUST
    related_entities:
      - "[[AccrualPlan]]"
      - "[[AccrualRule]]"
---

# Feature Catalog: Time & Absence

> **Note**: YAML above is for AI processing. Tables below for human reading.

## Feature Overview Mindmap

```mermaid
mindmap
  root((Time & Absence Features))
    Leave Management
      Submit Leave
      Approve Leave
      View Balance
      Cancel Leave
      Team Calendar
      Leave History
    Accrual Management
      Configure Plans
      Assign Plans
      Run Calculation
      Grant Entitlement
      Year-End Process
    Time Tracking
      Clock In/Out
      Submit Time
      Approve Time Card
      View Timesheet
      Correct Entry
    Scheduling
      Define Schedule
      Assign Schedule
      Manage Roster
      Shift Swap
    Holiday
      Manage Calendar
      View Calendar
      Assign Calendar
    Overtime
      Submit OT Request
      Approve OT
      Configure Rules
      Track Usage
    Reporting
      Attendance
      Leave Summary
      Accrual Report
      Compliance
```

---

## Capability: Leave Management

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TA-001 | **Submit Leave Request** | As an Employee, I want to submit a leave request... | MUST | Workflow |
| FR-TA-002 | **Approve/Reject Leave** | As a Manager, I want to approve or reject leave... | MUST | Workflow |
| FR-TA-003 | **View Leave Balance** | As an Employee, I want to view my leave balance... | MUST | Functional |
| FR-TA-004 | **Cancel Leave Request** | As an Employee, I want to cancel submitted leave... | MUST | Workflow |
| FR-TA-005 | **View Team Absence Calendar** | As a Manager, I want to view team absences... | SHOULD | Functional |
| FR-TA-006 | **View Leave History** | As an Employee, I want to view my leave history... | SHOULD | Functional |
| FR-TA-007 | **Assign Substitute** | As an Employee, I want to assign a substitute... | COULD | Functional |

---

## Capability: Accrual Management

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TA-010 | **Configure Accrual Plan** | As an HR Admin, I want to configure accrual plans... | MUST | Functional |
| FR-TA-011 | **Assign Accrual Plan** | As an HR Admin, I want to assign plans to employees... | MUST | Functional |
| FR-TA-012 | **Run Accrual Calculation** | As an HR Admin, I want to run accrual calculation... | MUST | Workflow |
| FR-TA-013 | **Grant Manual Entitlement** | As an HR Admin, I want to manually grant leave... | SHOULD | Functional |
| FR-TA-014 | **Year-End Carry Forward** | As an HR Admin, I want to process year-end... | MUST | Workflow |

---

## Capability: Time Tracking

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TA-020 | **Clock In/Out** | As an Employee, I want to clock in/out... | MUST | Functional |
| FR-TA-021 | **Submit Time Entry** | As an Employee, I want to submit time entries... | MUST | Functional |
| FR-TA-022 | **Approve Time Card** | As a Manager, I want to approve time cards... | MUST | Workflow |
| FR-TA-023 | **View Timesheet** | As an Employee, I want to view my timesheet... | MUST | Functional |
| FR-TA-024 | **Correct Time Entry** | As a Manager, I want to correct time entries... | SHOULD | Functional |

---

## Capability: Scheduling

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TA-030 | **Define Work Schedule** | As an HR Admin, I want to define work schedules... | MUST | Functional |
| FR-TA-031 | **Assign Schedule** | As an HR Admin, I want to assign schedules... | MUST | Functional |
| FR-TA-032 | **Manage Shift Roster** | As a Manager, I want to manage shift roster... | SHOULD | Functional |
| FR-TA-033 | **Request Shift Swap** | As an Employee, I want to swap shifts... | COULD | Workflow |

---

## Capability: Holiday Management

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TA-040 | **Manage Holiday Calendar** | As an HR Admin, I want to manage holidays... | MUST | Functional |
| FR-TA-041 | **View Holiday Calendar** | As an Employee, I want to view holidays... | MUST | Functional |
| FR-TA-042 | **Assign Calendar** | As an HR Admin, I want to assign calendars... | SHOULD | Functional |

---

## Capability: Overtime Management

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TA-050 | **Submit Overtime Request** | As an Employee, I want to request overtime... | SHOULD | Workflow |
| FR-TA-051 | **Approve Overtime** | As a Manager, I want to approve overtime... | SHOULD | Workflow |
| FR-TA-052 | **Configure OT Rules** | As an HR Admin, I want to configure OT rules... | SHOULD | Functional |
| FR-TA-053 | **Track OT Usage** | As an HR Admin, I want to track overtime... | SHOULD | Reporting |

---

## Capability: Compliance & Reporting

| ID | Feature | Description | Priority | Type |
|----|---------|-------------|----------|------|
| FR-TA-060 | **Attendance Report** | As a Manager, I want attendance reports... | SHOULD | Reporting |
| FR-TA-061 | **Leave Summary Report** | As an HR Admin, I want leave reports... | SHOULD | Reporting |
| FR-TA-062 | **Accrual Report** | As an HR Admin, I want accrual reports... | SHOULD | Reporting |
| FR-TA-063 | **Compliance Dashboard** | As an HR Admin, I want compliance dashboard... | SHOULD | Functional |

---

## Business Rules Summary

| ID | Rule | Category | Severity |
|----|------|----------|----------|
| BR-TA-001 | No overlapping approved leaves | Validation | BLOCK |
| BR-TA-002 | Minimum notice period for leave | Validation | WARN |
| BR-TA-003 | Cannot exceed available balance | Validation | BLOCK |
| BR-TA-004 | Probation: no annual leave | Eligibility | BLOCK |
| BR-TA-005 | Manager cannot self-approve | Approval | BLOCK |
| BR-TA-006 | Carry forward max 3 days | Compliance | WARN |
| BR-TA-007 | Daily OT limit: 4 hours | Compliance | BLOCK |
| BR-TA-008 | Monthly OT limit: 40 hours | Compliance | BLOCK |
| BR-TA-009 | Sick leave >3 days needs certificate | Validation | WARN |
| BR-TA-010 | Time entry within 7 days | Validation | WARN |
| BR-TA-011 | Exclude holidays from leave calc | Calculation | BLOCK |
| BR-TA-012 | +1 day per 5 years seniority | Accrual | MUST |

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Capabilities | 7 |
| Features | 30 |
| Business Rules | 12 |
| Priority MUST | 18 |
| Priority SHOULD | 10 |
| Priority COULD | 2 |

---

## Required Document Mapping

### Features → feat.md Files

| Feature | Axiom File | Priority |
|---------|-----------|----------|
| Submit Leave (FR-TA-001,002,004) | `submit-leave-request.feat.md` | MUST |
| View Balance (FR-TA-003,006) | `view-leave-balance.feat.md` | MUST |
| Team Calendar (FR-TA-005) | `team-absence-calendar.feat.md` | SHOULD |
| Accrual Config (FR-TA-010-014) | `manage-accrual-plans.feat.md` | MUST |
| Time Entry (FR-TA-020-024) | `time-tracking.feat.md` | MUST |
| Scheduling (FR-TA-030-033) | `manage-schedules.feat.md` | SHOULD |
| Holiday (FR-TA-040-042) | `manage-holidays.feat.md` | MUST |
| Overtime (FR-TA-050-053) | `overtime-management.feat.md` | SHOULD |
| Reports (FR-TA-060-063) | `ta-reports.feat.md` | SHOULD |

### Business Rules → brs.md Files

| Area | Axiom File | Priority |
|------|-----------|----------|
| Leave Policy | `leave-policy.brs.md` | MUST |
| Accrual Rules | `accrual-rules.brs.md` | MUST |
| Overtime Rules | `overtime-rules.brs.md` | MUST |
| Time Tracking | `time-tracking-rules.brs.md` | SHOULD |

### Workflows → flow.md Files

| Workflow | Axiom File | Priority |
|----------|-----------|----------|
| Leave Submission | `submit-leave-flow.flow.md` | MUST |
| Leave Approval | `approve-leave-flow.flow.md` | MUST |
| Accrual Calculation | `calculate-accrual-flow.flow.md` | MUST |
| Time Entry | `submit-time-flow.flow.md` | MUST |
| OT Request | `overtime-request-flow.flow.md` | SHOULD |
| Leave Cancellation | `cancel-leave-flow.flow.md` | SHOULD |
