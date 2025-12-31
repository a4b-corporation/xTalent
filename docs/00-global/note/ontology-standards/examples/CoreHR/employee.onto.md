---
entity: Employee
domain: core-hr
version: "1.0.0"
status: approved
owner: hr-team
tags: [core, workforce]

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated unique identifier

  - name: employeeCode
    type: string
    required: true
    unique: true
    description: Business identifier (e.g., EMP-0001)
    constraints:
      pattern: "^EMP-[0-9]{4}$"

  - name: firstName
    type: string
    required: true
    description: Legal first name

  - name: lastName
    type: string
    required: true
    description: Legal last name

  - name: email
    type: string
    required: true
    unique: true
    format: email
    description: Corporate email address

  - name: hireDate
    type: date
    required: true
    description: Date of employment start

  - name: terminationDate
    type: date
    required: false
    description: Date of employment end (null if active)

  - name: status
    type: enum
    required: true
    values: [onboarding, active, onLeave, offboarding, terminated]
    default: onboarding
    description: Current employment status

  - name: employeeType
    type: enum
    required: true
    values: [fullTime, partTime, contractor, intern]
    description: Type of employment

relationships:
  - name: belongsToDepartment
    target: Department
    cardinality: many-to-one
    required: true
    inverse: hasEmployees
    description: Primary department assignment

  - name: reportsTo
    target: Employee
    cardinality: many-to-one
    required: false
    inverse: hasDirectReports
    description: Direct supervisor (null for top-level)

  - name: hasDirectReports
    target: Employee
    cardinality: one-to-many
    required: false
    inverse: reportsTo
    description: Employees reporting to this person

  - name: holdsPosition
    target: Position
    cardinality: many-to-one
    required: true
    inverse: heldByEmployee
    description: Current position assignment

  - name: managesDepartments
    target: Department
    cardinality: one-to-many
    required: false
    inverse: managedBy
    description: Departments where this employee is the manager

lifecycle:
  states: [onboarding, active, onLeave, offboarding, terminated]
  initial: onboarding
  terminal: [terminated]
  transitions:
    - from: onboarding
      to: active
      trigger: completeOnboarding
      guard: "All required documents submitted"
    - from: active
      to: onLeave
      trigger: startLeave
    - from: onLeave
      to: active
      trigger: returnFromLeave
    - from: active
      to: offboarding
      trigger: initiateTermination
    - from: offboarding
      to: terminated
      trigger: completeOffboarding

actions:
  - name: hire
    description: Create new employee record
    requiredFields: [firstName, lastName, email, hireDate, departmentId, positionId]
    triggersTransition: null

  - name: promote
    description: Promote employee to new position
    affectsRelationships: [holdsPosition]

  - name: transfer
    description: Transfer to different department
    affectsRelationships: [belongsToDepartment, reportsTo]

  - name: terminate
    description: End employment
    requiredFields: [terminationDate, terminationReason]
    triggersTransition: initiateTermination

policies:
  - name: uniqueEmail
    type: validation
    rule: "Email must be unique across all employees"
    expression: "UNIQUE(email)"

  - name: hireDateNotFuture
    type: validation
    rule: "Hire date cannot be in the future"
    expression: "hireDate <= TODAY"

  - name: terminationAfterHire
    type: validation
    rule: "Termination date must be after hire date"
    expression: "terminationDate IS NULL OR terminationDate > hireDate"

  - name: salaryAccess
    type: access
    rule: "Only HR and direct manager can view compensation details"

  - name: dataRetention
    type: retention
    rule: "Terminated employee records retained for 7 years"
---

# Employee

## Overview

An **Employee** represents a person who has an employment relationship with the organization. This entity is the foundation of all HR processes—from hiring and payroll to performance management and offboarding. Every person working for the company, regardless of employment type, is represented as an Employee record.

## Business Context

### Key Stakeholders
- **HR Administrators**: Create employee records, manage lifecycle transitions, ensure data accuracy and compliance
- **Managers**: View their direct reports, approve requests, conduct performance reviews
- **Finance/Payroll**: Process compensation, tax withholdings, benefits deductions
- **Employees (Self)**: View and update personal information, submit requests
- **Executives**: View workforce analytics and organizational metrics

### Business Processes
This entity is central to:
- **Hiring & Onboarding**: New hire intake, document collection, system provisioning
- **Payroll Processing**: Compensation calculations, tax reporting, direct deposits
- **Benefits Administration**: Eligibility determination, enrollment, life event changes
- **Performance Management**: Review cycles, goal tracking, compensation adjustments
- **Workforce Planning**: Headcount tracking, org structure analysis, capacity planning
- **Compliance Reporting**: EEO, labor law, tax authority submissions

### Business Value
Employee data quality directly impacts payroll accuracy, compliance risk, and operational efficiency. A single source of truth for employee information eliminates data silos and enables integrated HR processes across the organization.

## Attributes Guide

### Identification
- **employeeCode**: The permanent business identifier assigned at hire. Format: EMP-XXXX (e.g., EMP-0042). This code appears on badges, reports, and external communications. Once assigned, it never changes—even after termination. This ensures historical records and audit trails remain traceable.
- **id**: System-generated UUID for internal database operations. Not visible to end users.

### Personal Information
- **firstName / lastName**: Legal name as it appears on government-issued identification. Used for payroll processing, tax forms (W-2, W-4), and official correspondence. Must match Social Security records exactly for tax compliance.
- **email**: Corporate email address in format firstname.lastname@company.com. Serves as primary communication channel, system login identifier, and calendar integration point. Must be unique across all employees (including terminated).

### Employment Dates
- **hireDate**: The official first day of employment. This date is critical because it determines:
  - Benefits eligibility waiting periods
  - PTO accrual start
  - Tenure calculations for vesting and service awards
  - Probationary period timing
  - Cannot be a future date (future hires remain in recruiting system)
- **terminationDate**: Last day of employment. Set only when employee is leaving. Used for:
  - Final paycheck calculation
  - Benefits continuation (COBRA) eligibility
  - PTO payout calculation
  - System access revocation timing

### Status & Classification
- **status**: Current state in the employment lifecycle (see Lifecycle section for details). Drives system behavior:
  - *onboarding*: Limited access, not in headcount
  - *active*: Full access, included in reports
  - *onLeave*: Access may be suspended, excluded from assignments
  - *offboarding*: Access being revoked
  - *terminated*: No access, retained for compliance

- **employeeType**: Classification that determines applicable policies and benefits:
  - *fullTime*: 40+ hours/week, full benefits eligible, standard employment protections
  - *partTime*: <30 hours/week, limited benefits, pro-rated PTO
  - *contractor*: No benefits, 1099 tax treatment, defined engagement period
  - *intern*: Temporary, educational focus, may convert to fullTime

## Relationships Explained

### Organizational Placement
- **belongsToDepartment** → [[Department]]: Every employee must be assigned to exactly one primary department. This determines:
  - Cost center allocation (whose budget pays their salary)
  - Default approval chain for requests
  - Reporting structure for analytics
  - Access permissions based on department
  
  When an employee transfers, this relationship changes to the new department, but history is preserved in the audit log.

### Reporting Structure
- **reportsTo** → [[Employee]]: Defines the direct supervisor in the management hierarchy. The supervisor:
  - Approves time-off requests
  - Conducts performance reviews
  - Approves expense reports
  - Is accountable for the employee's work output
  
  Only top-level executives (CEO, founders) have null for this relationship. The system prevents circular reporting (A reports to B who reports to A).

- **hasDirectReports** → [[Employee]]: Inverse relationship showing everyone who reports to this employee. Used to:
  - Identify managers for special permissions
  - Calculate span of control metrics
  - Route approval workflows
  - Filter dashboards to "my team"

### Role Definition
- **holdsPosition** → [[Position]]: Links the employee to their formal job role. The position defines:
  - Job title and level (Senior Engineer, Director)
  - Compensation band/range
  - Required qualifications
  - Organizational reporting line
  
  When promoted, the employee's position changes to reflect their new role. The position relationship history shows career progression.

### Department Management
- **managesDepartments** → [[Department]]: If this employee is a department head, links to the department(s) they manage. Most employees have none; managers typically have one; some senior leaders may manage multiple departments.

## Lifecycle & Workflows

### State Definitions

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **onboarding** | New hire completing paperwork, training, and setup | Limited system access (HR portal only), not counted in headcount reports, not available for project assignment |
| **active** | Normal working status | Full system access, included in all reports, can receive assignments and submit requests |
| **onLeave** | Approved extended absence (PTO, FMLA, sabbatical) | System access may be suspended, excluded from new assignments, included in headcount but flagged |
| **offboarding** | Separation process initiated, working notice period | Access being reduced, knowledge transfer in progress, final pay being calculated |
| **terminated** | Employment has ended | All access revoked, excluded from active reports, record retained for compliance |

### Transition Workflows

#### Hiring → Onboarding
**Trigger**: HR creates new employee record from approved job offer
**Who**: HR Administrator
**Process**:
1. Recruiting hands off accepted offer package
2. HR creates Employee record with required fields
3. System auto-generates employeeCode (EMP-XXXX)
4. Welcome email sent to personal email with portal access
5. Onboarding task checklist created

**Typical duration**: Created 1-2 weeks before start date

#### Onboarding → Active (completeOnboarding)
**Trigger**: All onboarding requirements completed
**Who**: HR Administrator with manager approval
**Prerequisites**:
- I-9 employment verification completed
- Tax forms (W-4) submitted
- Direct deposit enrolled
- Policy acknowledgments signed
- Required training completed
- IT equipment provisioned

**Process**:
1. HR verifies all checklist items complete
2. Manager confirms employee is ready
3. HR triggers `completeOnboarding` action
4. Status changes to `active`
5. Full system access provisioned
6. Employee appears in headcount reports

**Typical duration**: 1-5 business days from start date

#### Active → On Leave (startLeave)
**Trigger**: Approved leave request begins
**Who**: System (automatic) or HR Administrator
**Process**:
1. Leave request approved by manager
2. On leave start date, system changes status
3. Email notification sent to team
4. Out-of-office auto-reply may be enabled
5. Depending on leave type, system access may be suspended

**Return process**: On return date, status automatically changes back to `active` via `returnFromLeave`

#### Active → Offboarding (initiateTermination)
**Trigger**: Resignation submitted OR termination decision made
**Who**: HR Administrator
**Process**:
1. Resignation received or termination approved
2. HR sets terminationDate and reason
3. HR triggers `initiateTermination`
4. Status changes to `offboarding`
5. Offboarding checklist created:
   - Knowledge transfer tasks
   - Exit interview scheduled
   - Equipment return
   - Access revocation plan
6. Manager and IT notified

**Notice period**: Typically 2-4 weeks per policy/contract

#### Offboarding → Terminated (completeOffboarding)
**Trigger**: Last day of employment reached
**Who**: HR Administrator
**Prerequisites**:
- Exit interview completed (or waived)
- Equipment returned
- Final timesheet approved
- Knowledge transfer complete

**Process**:
1. On termination date, HR triggers `completeOffboarding`
2. All system access immediately revoked
3. Final paycheck initiated (includes PTO payout)
4. COBRA notification sent (if applicable)
5. Status changes to `terminated`
6. Record retained per data retention policy

## Actions & Operations

### hire
**Who**: HR Administrators only
**When**: New employee joining from approved job offer
**Required information**: firstName, lastName, email, hireDate, departmentId, positionId
**Optional**: employeeType (defaults to fullTime), reportsTo

**Process**:
1. Verify job offer is approved in recruiting system
2. Verify position is open and has headcount
3. Enter required fields
4. System validates email uniqueness, hire date not in future
5. System generates employeeCode
6. Record created in `onboarding` status

**Downstream effects**:
- IT receives equipment provisioning request
- Facilities notified for workspace setup
- New hire added to orientation schedule
- Manager notified of new team member
- Payroll notified of upcoming hire

### promote
**Who**: HR Administrator with VP approval for cross-level moves
**When**: Employee moving to higher level position (same or different department)
**Affects**: holdsPosition relationship

**Process**:
1. Verify target position is open
2. Verify employee meets qualifications
3. Set effective date for change
4. Update position relationship
5. Log change with previous position reference

**Downstream effects**:
- Compensation review workflow triggered
- Title updated in directory
- Org chart updated
- May trigger office/desk change
- Anniversary of promotion tracked

### transfer
**Who**: HR Administrator with both department managers' approval
**When**: Employee moving to different department (lateral or any direction)
**Affects**: belongsToDepartment, reportsTo relationships

**Process**:
1. Verify receiving department has headcount
2. Get approval from current and new managers
3. Set effective date
4. Update department relationship
5. Update reporting relationship to new manager
6. Update cost center allocation

**Downstream effects**:
- Access permissions updated for new department
- Budget allocation transferred
- Org chart updated
- May trigger location/desk change
- Historical department assignment preserved

### terminate
**Who**: HR Administrator only
**When**: Employment ending (voluntary resignation or involuntary termination)
**Required**: terminationDate, terminationReason

**Process**:
1. Verify no blocking conditions (active investigations, etc.)
2. Enter last day of work (terminationDate)
3. Select reason code (resignation, layoff, termination-for-cause, retirement, etc.)
4. System initiates offboarding workflow
5. Status changes to `offboarding`

**Downstream effects**:
- Exit interview scheduled
- IT creates access revocation plan
- Payroll calculates final check and PTO payout
- Benefits team initiates COBRA notification
- Manager receives offboarding checklist
- Recruiting notified if backfill needed

## Business Rules

### Data Integrity

#### Unique Email (uniqueEmail)
**Rule**: Each employee must have a unique corporate email address, even across terminated employees.
**Reason**: Email serves as system login and is used for historical audit trails. Reusing emails could cause access control issues and confuse audit logs.
**Violation**: System prevents save with error: "This email address is already in use."

#### Hire Date Validation (hireDateNotFuture)
**Rule**: Hire date cannot be set to a future date.
**Reason**: Employees should only exist in the HR system when they've actually started. Future hires remain in the recruiting/offer system until start date. This prevents premature access provisioning and incorrect headcount.
**Violation**: System prevents save with error: "Hire date cannot be in the future."

#### Termination Date Sequence (terminationAfterHire)
**Rule**: If a termination date is set, it must be after the hire date.
**Reason**: Logical integrity—an employee cannot leave before they started.
**Violation**: System prevents save with error: "Termination date must be after hire date."

### Compliance

#### Data Retention (dataRetention)
**Rule**: Terminated employee records must be retained for a minimum of 7 years.
**Regulation**: IRS record retention requirements, potential litigation hold periods, employment verification needs.
**Implementation**: Terminated records are archived but never deleted. Access restricted to HR, Legal, and Compliance teams. After 7 years, records may be purged following legal review.

### Security

#### Salary Access Control (salaryAccess)
**Rule**: Compensation information (salary, bonus, equity) is only visible to:
- HR Administrators
- Finance/Payroll team
- Employee's direct management chain (up to CEO)
- The employee themselves (their own data)
**Reason**: Salary information is highly confidential. Unauthorized disclosure can create legal liability, damage morale, and violate privacy expectations.
**Implementation**: Field-level security applied to compensation fields. All access logged in audit trail. Violations reported to Compliance.

## Examples

### Example 1: Standard Full-Time Employee
- **employeeCode**: EMP-0042
- **Name**: John Doe
- **email**: john.doe@company.com
- **employeeType**: fullTime
- **hireDate**: 2023-01-15
- **status**: active
- **Department**: Engineering (via belongsToDepartment)
- **Position**: Senior Software Engineer (via holdsPosition)
- **Reports to**: Jane Smith, Engineering Manager
- **Scenario**: John is a typical full-time employee who completed onboarding on his start date, has been active for over a year, and reports to his engineering manager.

### Example 2: Employee Currently on Leave
- **employeeCode**: EMP-0108
- **Name**: Sarah Wilson
- **email**: sarah.wilson@company.com
- **employeeType**: fullTime
- **hireDate**: 2021-06-01
- **status**: onLeave
- **Department**: Marketing
- **Position**: Marketing Director
- **Scenario**: Sarah is on parental leave since 2024-06-01 with expected return 2024-09-01. Her position is held, benefits continue, but system access is suspended. She does not appear on active project assignments but is still counted in headcount.

### Example 3: Terminated Employee (Historical)
- **employeeCode**: EMP-0015
- **Name**: Bob Johnson
- **email**: bob.johnson@company.com
- **employeeType**: fullTime
- **hireDate**: 2019-03-01
- **terminationDate**: 2024-02-28
- **status**: terminated
- **Scenario**: Bob resigned after 5 years. His record is retained for compliance. HR can still access for employment verification requests. His email cannot be reused for a new employee.

## Edge Cases & Exceptions

### Rehires
**Situation**: A previously terminated employee is hired again.
**Handling**: 
- Create a NEW employee record with new employeeCode
- Do NOT reactivate old record
- Link records via `previousEmployeeId` attribute (if tracking needed)
- Benefits eligibility rules may bridge service if break was short (<30 days typically)
- Original hire date preserved on old record; new record has new hire date

### Concurrent Employment (Rare)
**Situation**: Same person has legitimate employment with two entities in company group.
**Handling**:
- Allowed only for distinct legal entities (e.g., US subsidiary and UK subsidiary)
- Each entity has separate Employee record with unique employeeCode
- Global reporting handles deduplication via SSN/national ID
- Benefits coordination rules apply (no double-dipping)

### Acquisition Integration
**Situation**: Employees joining via company acquisition.
**Handling**:
- Bulk import with special `acquisitionSource` tag
- Original hire dates from acquired company preserved for tenure
- New employeeCodes assigned in our format
- Temporary dual-system period during integration
- Historical data migrated with acquisition date noted

### Contractor Conversion
**Situation**: Long-term contractor converting to full-time employee.
**Handling**:
- Create new Employee record with employeeType: fullTime
- Close contractor record (or terminate if tracked as employee)
- Hire date is conversion date (not original contractor start)
- Some companies track contractor tenure separately for recognition

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[Department]] | belongsTo / manages | Organizational unit for cost allocation and reporting |
| [[Position]] | holds | Job role defining title, level, and compensation band |
| [[Assignment]] | has many | Project or task allocations beyond primary role |
| [[TimeOffRequest]] | submits | Leave and PTO requests |
| [[PerformanceReview]] | receives | Annual/periodic performance evaluations |
| [[Compensation]] | has | Salary, bonus, equity details (separate for security) |
| [[EmergencyContact]] | has | Emergency contact information |
| [[Document]] | has | Uploaded documents (ID, certifications, etc.) |