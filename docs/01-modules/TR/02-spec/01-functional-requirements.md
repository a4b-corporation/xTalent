# TR Module - Functional Requirements

**Version**: 1.0  
**Last Updated**: 2025-12-08  
**Module**: Total Rewards (TR)  
**Status**: 🔄 In Progress

---

## 📋 Overview

This document defines all **functional requirements** for the Total Rewards module, organized by feature area (sub-module).

### Scope

The TR module manages:
- **Core Compensation**: Salary structures, grades, compensation cycles
- **Variable Pay**: Bonuses, equity, commissions
- **Benefits**: Health insurance, retirement, wellness programs
- **Recognition**: Points, rewards, perks
- **Offer Management**: Job offer packages
- **TR Statements**: Total rewards communication
- **Deductions**: Payroll deductions
- **Tax Withholding**: Tax calculations
- **Taxable Bridge**: Tax-related mappings
- **Audit**: Change tracking
- **Calculation Rules**: Formulas and rules engine

### Total Requirements

| Sub-Module | Requirements | Priority Distribution |
|------------|--------------|----------------------|
| Core Compensation | 18 | HIGH: 12, MEDIUM: 4, LOW: 2 |
| Variable Pay | 15 | HIGH: 10, MEDIUM: 3, LOW: 2 |
| Benefits | 20 | HIGH: 14, MEDIUM: 4, LOW: 2 |
| Recognition | 10 | MEDIUM: 6, LOW: 4 |
| Offer Management | 12 | HIGH: 8, MEDIUM: 3, LOW: 1 |
| TR Statement | 8 | MEDIUM: 5, LOW: 3 |
| Deductions | 10 | HIGH: 6, MEDIUM: 3, LOW: 1 |
| Tax Withholding | 12 | HIGH: 10, MEDIUM: 2 |
| Taxable Bridge | 6 | MEDIUM: 4, LOW: 2 |
| Audit | 8 | MEDIUM: 5, LOW: 3 |
| Calculation Rules | 12 | HIGH: 8, MEDIUM: 3, LOW: 1 |
| **TOTAL** | **131** | **HIGH: 68, MEDIUM: 37, LOW: 26** |

---

## 🎯 Feature Area 1: Core Compensation

### Overview

Core Compensation manages salary structures, pay components, grade systems, compensation cycles, and budget allocation.

**Related Entities**: SalaryBasis, PayComponentDefinition, GradeVersion, GradeLadder, PayRange, CompensationPlan, CompensationCycle, CompensationAdjustment, EmployeeCompensationSnapshot, BudgetAllocation

**Related Concept Guide**: [Compensation Management Guide](../01-concept/01-compensation-management-guide.md)

---

#### FR-TR-COMP-001: Salary Basis Management

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want to create and manage salary basis templates
So that I can standardize compensation structures across different employee types and countries
```

**Description**:
The system shall allow HR Administrators to create, configure, and manage salary basis templates that define how compensation is structured (frequency, currency, components).

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I create a new salary basis
- Then I must provide:
  * Unique code (e.g., MONTHLY_VN)
  * Name
  * Frequency (HOURLY, DAILY, MONTHLY, ANNUAL)
  * Currency (ISO 4217 code)
  * Effective start date
- And I can optionally configure:
  * Metadata (working days/month, standard hours, overtime multiplier)
  * Allow additional components flag
  * Effective end date
- And the system validates:
  * Code uniqueness
  * Valid currency code
  * Effective dates (start <= end)
- And I can add pay components to the basis
- And I can activate/deactivate the basis

**Dependencies**:
- Core module: Currency master data
- Core module: Legal Entity

**Business Rules**:
- BR-TR-COMP-001: Salary basis code must be unique
- BR-TR-COMP-002: Cannot modify active salary basis (create new version)
- BR-TR-COMP-003: Currency must match legal entity currency

**Related Entities**:
- SalaryBasis
- SalaryBasisComponentMap

**API Endpoints**:
- `POST /api/v1/compensation/salary-bases`
- `GET /api/v1/compensation/salary-bases`
- `GET /api/v1/compensation/salary-bases/{id}`
- `PUT /api/v1/compensation/salary-bases/{id}`
- `DELETE /api/v1/compensation/salary-bases/{id}` (soft delete)

---

#### FR-TR-COMP-002: Pay Component Definition

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want to define pay components (base salary, allowances, bonuses)
So that I can build flexible compensation packages
```

**Description**:
The system shall allow HR Administrators to define individual pay components with specific tax treatment, calculation methods, and proration rules.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I create a pay component
- Then I must provide:
  * Unique code (e.g., BASE_SALARY, LUNCH_ALLOWANCE)
  * Name
  * Component type (BASE, ALLOWANCE, BONUS, DEDUCTION, OVERTIME, COMMISSION)
  * Frequency (HOURLY, DAILY, MONTHLY, QUARTERLY, ANNUAL, ONE_TIME)
- And I can configure:
  * Tax treatment (FULLY_TAXABLE, TAX_EXEMPT, PARTIALLY_EXEMPT)
  * Tax exempt threshold (for PARTIALLY_EXEMPT)
  * Subject to social insurance (Yes/No)
  * SI calculation basis (FULL_AMOUNT, CAPPED, EXCLUDED)
  * Prorated flag
  * Proration method (CALENDAR_DAYS, WORKING_DAYS, NONE)
  * Calculation method (FIXED, FORMULA, PERCENTAGE, RATE_TABLE)
- And the system validates:
  * Component code uniqueness
  * Tax exempt threshold only when PARTIALLY_EXEMPT
  * SI basis required if subject to SI
- And I can activate/deactivate components

**Dependencies**:
- Tax configuration data

**Business Rules**:
- BR-TR-COMP-004: Component code must be unique
- BR-TR-COMP-005: Tax exempt threshold only applies to PARTIALLY_EXEMPT
- BR-TR-COMP-006: Cannot change tax treatment of active component without approval

**Related Entities**:
- PayComponentDefinition
- ComponentCalculationRule

**API Endpoints**:
- `POST /api/v1/compensation/pay-components`
- `GET /api/v1/compensation/pay-components`
- `GET /api/v1/compensation/pay-components/{id}`
- `PUT /api/v1/compensation/pay-components/{id}`

---

#### FR-TR-COMP-003: Grade Structure Management

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want to create and manage salary grades and career ladders
So that I can define career progression paths and pay ranges
```

**Description**:
The system shall allow HR Administrators to create grade structures, career ladders, and pay ranges using SCD Type 2 pattern for historical tracking.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I create a grade
- Then I must provide:
  * Grade code (e.g., G1, G2, M1)
  * Name
  * Job level (1-10)
  * Effective start date
- And the system automatically:
  * Assigns version number (1 for new grade)
  * Sets is_current_version = true
  * Generates unique ID
- When I update an existing grade
- Then the system:
  * Creates new version (version_number + 1)
  * Links to previous version (previous_version_id)
  * Sets previous version's effective_end_date
  * Sets previous version's is_current_version = false
- And I can create career ladders with:
  * Ladder code and name
  * Ladder type (MANAGEMENT, TECHNICAL, SPECIALIST, SALES, EXECUTIVE)
  * Grades in progression order
- And I can define pay ranges per grade with:
  * Scope (GLOBAL, LEGAL_ENTITY, BUSINESS_UNIT, POSITION)
  * Currency
  * Min, Mid, Max amounts
  * Effective dates
- And the system validates:
  * Min < Mid < Max
  * Range spread = (Max - Min) / Mid × 100
  * More specific scopes override broader scopes

**Dependencies**:
- Core module: Legal Entity, Business Unit

**Business Rules**:
- BR-TR-COMP-007: Only one current version per grade code
- BR-TR-COMP-008: Version chain must be unbroken
- BR-TR-COMP-009: Min < Mid < Max for pay ranges
- BR-TR-COMP-010: Position scope overrides BU > LE > Global

**Related Entities**:
- GradeVersion
- GradeLadder
- GradeLadderGrade
- GradeLadderStep
- PayRange

**API Endpoints**:
- `POST /api/v1/compensation/grades`
- `GET /api/v1/compensation/grades`
- `PUT /api/v1/compensation/grades/{id}` (creates new version)
- `POST /api/v1/compensation/career-ladders`
- `GET /api/v1/compensation/career-ladders`
- `POST /api/v1/compensation/pay-ranges`
- `GET /api/v1/compensation/pay-ranges`

---

#### FR-TR-COMP-004: Compensation Plan Setup

**Priority**: HIGH

**User Story**:
```
As a Compensation Manager
I want to create compensation plan templates
So that I can standardize different types of compensation reviews (merit, promotion, market adjustment)
```

**Description**:
The system shall allow Compensation Managers to create compensation plan templates defining eligibility rules, merit matrices, and approval thresholds.

**Acceptance Criteria**:
- Given I am a Compensation Manager
- When I create a compensation plan
- Then I must provide:
  * Unique code (e.g., MERIT_2025)
  * Name
  * Plan type (MERIT, PROMOTION, MARKET_ADJUSTMENT, NEW_HIRE, EQUITY_CORRECTION, AD_HOC)
  * Effective dates
- And I can configure:
  * Eligibility rules (JSON):
    - Min tenure months
    - Employment types
    - Grades
    - Performance rating minimum
    - Exclude probation flag
  * Guidelines (JSON):
    - Merit matrix (performance × compa-ratio → increase %)
    - Approval thresholds by increase %
    - Budget guidelines
- And the system validates:
  * Plan code uniqueness
  * Valid plan type
  * Effective dates
- And I can activate/deactivate plans

**Dependencies**:
- None

**Business Rules**:
- BR-TR-COMP-011: Plan code must be unique
- BR-TR-COMP-012: Merit matrix must cover all performance ratings
- BR-TR-COMP-013: Approval thresholds must be sequential

**Related Entities**:
- CompensationPlan

**API Endpoints**:
- `POST /api/v1/compensation/plans`
- `GET /api/v1/compensation/plans`
- `GET /api/v1/compensation/plans/{id}`
- `PUT /api/v1/compensation/plans/{id}`

---

#### FR-TR-COMP-005: Compensation Cycle Management

**Priority**: HIGH

**User Story**:
```
As a Compensation Manager
I want to create and manage compensation cycles
So that I can run annual merit reviews, promotions, and market adjustments
```

**Description**:
The system shall allow Compensation Managers to create compensation cycles, allocate budgets, and manage workflow states.

**Acceptance Criteria**:
- Given I am a Compensation Manager
- When I create a compensation cycle
- Then I must provide:
  * Plan ID (FK to CompensationPlan)
  * Unique code (e.g., MERIT_2025_Q1)
  * Name
  * Performance period (start and end dates)
  * Payout/effective date
  * Budget amount and currency
- And the system validates:
  * Period end > period start
  * Payout date >= period end
  * Budget amount > 0
- And I can manage cycle status:
  * DRAFT → OPEN → IN_REVIEW → APPROVED → CLOSED
  * Cannot reopen CLOSED cycle
- And I can allocate budget by:
  * Legal entity
  * Business unit
  * Department
  * Team
- And the system tracks:
  * Budget utilization in real-time
  * Number of adjustments (proposed, approved)
  * Workflow state history

**Dependencies**:
- FR-TR-COMP-004: Compensation Plan Setup
- Core module: Legal Entity, Business Unit

**Business Rules**:
- BR-TR-COMP-014: Period end must be after period start
- BR-TR-COMP-015: Cannot modify CLOSED cycle
- BR-TR-COMP-016: Budget utilization updated in real-time

**Related Entities**:
- CompensationCycle
- BudgetAllocation

**API Endpoints**:
- `POST /api/v1/compensation/cycles`
- `GET /api/v1/compensation/cycles`
- `GET /api/v1/compensation/cycles/{id}`
- `PUT /api/v1/compensation/cycles/{id}`
- `POST /api/v1/compensation/cycles/{id}/status` (change status)
- `POST /api/v1/compensation/cycles/{id}/budget-allocations`

---

#### FR-TR-COMP-006: Compensation Adjustment Proposal

**Priority**: HIGH

**User Story**:
```
As a Manager
I want to propose compensation adjustments for my team members
So that I can reward performance and retain talent
```

**Description**:
The system shall allow Managers to propose compensation adjustments within active cycles, with automatic calculation and validation against budget and guidelines.

**Acceptance Criteria**:
- Given I am a Manager
- And there is an active compensation cycle (status = OPEN)
- When I propose an adjustment for an employee
- Then I must provide:
  * Employee ID
  * Component ID (typically BASE_SALARY)
  * Proposed amount
  * Rationale code (MERIT, PROMOTION, MARKET, RETENTION)
  * Rationale text (justification)
- And the system automatically calculates:
  * Current amount (from EmployeeCompensationSnapshot)
  * Increase amount = proposed - current
  * Increase % = (proposed - current) / current × 100
- And the system validates:
  * Employee is eligible (per plan eligibility rules)
  * Proposed amount within pay range (min-max)
  * Budget availability in employee's pool
  * Increase % aligns with guidelines (warnings if outside)
- And I can save as DRAFT or submit as PENDING
- And the system determines approval routing based on:
  * Increase % vs approval thresholds
  * Manager hierarchy
- And I can view:
  * Budget impact
  * Guideline compliance
  * Compa-ratio before/after

**Dependencies**:
- FR-TR-COMP-005: Compensation Cycle Management
- FR-TR-COMP-003: Grade Structure (for pay ranges)
- Core module: Employee, Assignment

**Business Rules**:
- BR-TR-COMP-017: Employee must be eligible per plan rules
- BR-TR-COMP-018: Proposed amount must be within pay range
- BR-TR-COMP-019: Approval routing based on increase %
- BR-TR-COMP-020: Cannot modify APPROVED adjustment

**Related Entities**:
- CompensationAdjustment
- EmployeeCompensationSnapshot
- BudgetAllocation

**API Endpoints**:
- `POST /api/v1/compensation/adjustments`
- `GET /api/v1/compensation/adjustments`
- `GET /api/v1/compensation/adjustments/{id}`
- `PUT /api/v1/compensation/adjustments/{id}`
- `POST /api/v1/compensation/adjustments/{id}/submit`

---

#### FR-TR-COMP-007: Compensation Adjustment Approval

**Priority**: HIGH

**User Story**:
```
As a Director/VP
I want to review and approve compensation adjustments
So that I can ensure budget compliance and pay equity
```

**Description**:
The system shall route compensation adjustments for approval based on increase percentage and organizational hierarchy.

**Acceptance Criteria**:
- Given I am an Approver (Director/VP/CFO)
- When adjustments are submitted
- Then the system routes to me based on:
  * Approval thresholds (e.g., >5% requires Director, >10% requires VP)
  * Organizational hierarchy (my direct/indirect reports)
- And I can view:
  * Employee details
  * Current vs proposed compensation
  * Increase amount and %
  * Rationale
  * Budget impact
  * Pay equity analysis (vs peers)
  * Compa-ratio impact
- And I can:
  * Approve (status → APPROVED)
  * Reject (status → REJECTED, requires reason)
  * Request changes (status → DRAFT, with comments)
- And when I approve:
  * Budget utilization updated
  * Next approver notified (if multi-level)
  * Manager notified of approval
- And when all approvals complete:
  * Adjustment status → APPROVED
  * Ready for finalization

**Dependencies**:
- FR-TR-COMP-006: Compensation Adjustment Proposal
- Core module: Employee hierarchy

**Business Rules**:
- BR-TR-COMP-021: Approval routing per threshold configuration
- BR-TR-COMP-022: All required approvals must be obtained
- BR-TR-COMP-023: Cannot approve if budget exceeded (warning)

**Related Entities**:
- CompensationAdjustment
- BudgetAllocation

**API Endpoints**:
- `GET /api/v1/compensation/adjustments/pending-approval`
- `POST /api/v1/compensation/adjustments/{id}/approve`
- `POST /api/v1/compensation/adjustments/{id}/reject`
- `POST /api/v1/compensation/adjustments/{id}/request-changes`

---

#### FR-TR-COMP-008: Compensation Cycle Finalization

**Priority**: HIGH

**User Story**:
```
As a Compensation Manager
I want to finalize and close compensation cycles
So that approved adjustments take effect and employee compensation is updated
```

**Description**:
The system shall allow Compensation Managers to finalize cycles, creating compensation snapshots and updating employee records.

**Acceptance Criteria**:
- Given I am a Compensation Manager
- And a cycle is in APPROVED status
- And all adjustments are either APPROVED or REJECTED
- When I finalize the cycle
- Then the system:
  * Creates EmployeeCompensationSnapshot records for all APPROVED adjustments
  * Sets snapshot effective_start_date = cycle effective_date
  * Ends previous snapshots (sets effective_end_date = effective_date - 1 day)
  * Updates snapshot status: PLANNED → ACTIVE
  * Creates SalaryHistory records for audit
  * Generates payout file for payroll (if applicable)
  * Changes cycle status: APPROVED → CLOSED
- And I can view:
  * Summary report (total adjustments, total cost, avg increase %)
  * Employee list with before/after compensation
  * Budget utilization final report
- And the system prevents:
  * Reopening CLOSED cycle
  * Modifying finalized adjustments

**Dependencies**:
- FR-TR-COMP-007: Compensation Adjustment Approval
- Payroll module: For payout file generation

**Business Rules**:
- BR-TR-COMP-024: All adjustments must be approved/rejected before finalization
- BR-TR-COMP-025: Snapshots use SCD Type 2 pattern
- BR-TR-COMP-026: Cannot reopen CLOSED cycle

**Related Entities**:
- CompensationCycle
- CompensationAdjustment
- EmployeeCompensationSnapshot
- SalaryHistory

**API Endpoints**:
- `POST /api/v1/compensation/cycles/{id}/finalize`
- `GET /api/v1/compensation/cycles/{id}/summary`
- `GET /api/v1/compensation/cycles/{id}/payout-file`

---

#### FR-TR-COMP-009: Budget Tracking and Alerts

**Priority**: MEDIUM

**User Story**:
```
As a Compensation Manager
I want to track budget utilization in real-time
So that I can prevent over-allocation and manage costs
```

**Description**:
The system shall track budget utilization in real-time and send alerts when thresholds are reached.

**Acceptance Criteria**:
- Given a compensation cycle with budget allocations
- When adjustments are proposed or approved
- Then the system updates:
  * Allocated amount (total budget)
  * Utilized amount (sum of approved adjustments)
  * Utilization % = (utilized / allocated) × 100
  * Remaining amount = allocated - utilized
- And the system sends alerts when:
  * Utilization reaches 80% (Yellow alert)
  * Utilization reaches 95% (Red alert)
  * Utilization exceeds 100% (Critical alert)
- And I can view:
  * Budget dashboard by legal entity/BU/department
  * Utilization trends over time
  * Pending proposals impact on budget
- And I can:
  * Reallocate budget between pools
  * Request budget increase (approval workflow)
  * Export budget reports

**Dependencies**:
- FR-TR-COMP-005: Compensation Cycle Management

**Business Rules**:
- BR-TR-COMP-027: Utilization calculated in real-time
- BR-TR-COMP-028: Alerts sent at 80%, 95%, 100% thresholds
- BR-TR-COMP-029: Budget reallocation requires approval

**Related Entities**:
- BudgetAllocation
- CompensationCycle

**API Endpoints**:
- `GET /api/v1/compensation/cycles/{id}/budget-dashboard`
- `POST /api/v1/compensation/cycles/{id}/reallocate-budget`
- `GET /api/v1/compensation/budget-alerts`

---

#### FR-TR-COMP-010: Component Dependency Management

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to define dependencies between pay components
So that calculations execute in the correct order
```

**Description**:
The system shall allow HR Administrators to define calculation dependencies between pay components to ensure correct execution order.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I configure pay components
- Then I can define:
  * Component dependencies (Component A depends on Component B)
  * Calculation order (1, 2, 3, ...)
- And the system validates:
  * No circular dependencies
  * Calculation order is sequential
- And during payroll calculation:
  * Components execute in dependency order
  * Dependent components wait for prerequisite completion
- And I can view:
  * Dependency graph
  * Calculation sequence

**Dependencies**:
- FR-TR-COMP-002: Pay Component Definition

**Business Rules**:
- BR-TR-COMP-030: No circular dependencies allowed
- BR-TR-COMP-031: Calculation order must be sequential

**Related Entities**:
- ComponentDependency
- PayComponentDefinition

**API Endpoints**:
- `POST /api/v1/compensation/component-dependencies`
- `GET /api/v1/compensation/component-dependencies`
- `GET /api/v1/compensation/component-dependencies/graph`

---

#### FR-TR-COMP-011: Proration Rule Configuration

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to configure proration rules for pay components
So that partial period calculations are accurate
```

**Description**:
The system shall allow HR Administrators to configure proration rules with country-specific formulas.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I configure proration for a component
- Then I can specify:
  * Proration method (CALENDAR_DAYS, WORKING_DAYS, NONE)
  * Country-specific formula (JSON)
  * Rounding rules
- And the system applies proration when:
  * Employee hired mid-period
  * Employee terminated mid-period
  * Unpaid leave taken
  * Component added mid-period
- And I can test proration with:
  * Sample scenarios
  * Expected vs actual results

**Dependencies**:
- FR-TR-COMP-002: Pay Component Definition

**Business Rules**:
- BR-TR-COMP-032: Proration formula must be valid JSON
- BR-TR-COMP-033: Calendar days proration = days worked / days in period
- BR-TR-COMP-034: Working days proration = working days / standard working days

**Related Entities**:
- ProrationRule
- PayComponentDefinition

**API Endpoints**:
- `POST /api/v1/compensation/proration-rules`
- `GET /api/v1/compensation/proration-rules`
- `POST /api/v1/compensation/proration-rules/test`

---

#### FR-TR-COMP-012: Salary History Tracking

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to track complete salary change history
So that I can audit compensation decisions and generate reports
```

**Description**:
The system shall automatically track all salary changes with full audit trail.

**Acceptance Criteria**:
- Given any compensation adjustment is approved
- When the adjustment is finalized
- Then the system creates a SalaryHistory record with:
  * Employee ID
  * Component ID
  * Previous amount
  * New amount
  * Change amount
  * Change %
  * Effective date
  * Reason code
  * Source (cycle ID, offer ID, manual)
  * Approver
  * Timestamp
- And I can query history by:
  * Employee
  * Date range
  * Component
  * Reason code
- And I can generate reports:
  * Salary progression over time
  * Average increase by department
  * Promotion impact analysis

**Dependencies**:
- FR-TR-COMP-008: Compensation Cycle Finalization

**Business Rules**:
- BR-TR-COMP-035: History record created for every change
- BR-TR-COMP-036: History records are immutable

**Related Entities**:
- SalaryHistory
- EmployeeCompensationSnapshot

**API Endpoints**:
- `GET /api/v1/compensation/salary-history`
- `GET /api/v1/compensation/salary-history/employee/{id}`
- `GET /api/v1/compensation/salary-history/reports`

---

#### FR-TR-COMP-013: Pay Equity Analysis

**Priority**: HIGH

**User Story**:
```
As a Compensation Manager
I want to analyze pay equity across protected groups
So that I can identify and address pay gaps
```

**Description**:
The system shall provide pay equity analysis tools to identify compensation disparities.

**Acceptance Criteria**:
- Given I am a Compensation Manager
- When I run pay equity analysis
- Then I can analyze by:
  * Gender
  * Ethnicity
  * Age group
  * Location
  * Department
- And for each group, the system shows:
  * Average compensation
  * Median compensation
  * Min/Max compensation
  * Compa-ratio distribution
  * Gap % vs comparison group
- And I can control for:
  * Job level/grade
  * Tenure
  * Performance rating
  * Location
- And the system highlights:
  * Statistically significant gaps
  * Outliers
  * Trends over time
- And I can export:
  * Analysis reports
  * Anonymized data for external audit

**Dependencies**:
- Core module: Employee demographics
- FR-TR-COMP-003: Grade Structure

**Business Rules**:
- BR-TR-COMP-037: Analysis must control for legitimate factors
- BR-TR-COMP-038: Data must be anonymized for export
- BR-TR-COMP-039: Minimum group size for statistical significance

**Related Entities**:
- EmployeeCompensationSnapshot
- Core.Employee

**API Endpoints**:
- `POST /api/v1/compensation/pay-equity/analyze`
- `GET /api/v1/compensation/pay-equity/reports`
- `GET /api/v1/compensation/pay-equity/export`

---

#### FR-TR-COMP-014: Compa-Ratio Calculation

**Priority**: MEDIUM

**User Story**:
```
As a Manager
I want to view employee compa-ratios
So that I can understand position in pay range
```

**Description**:
The system shall automatically calculate and display compa-ratios for all employees.

**Acceptance Criteria**:
- Given an employee with compensation and grade
- When I view employee compensation
- Then the system displays:
  * Current salary
  * Grade pay range (min, mid, max)
  * Compa-ratio = (salary / midpoint) × 100
  * Position in range visualization
- And compa-ratio is color-coded:
  * < 80%: Red (below minimum)
  * 80-90%: Yellow (entry level)
  * 90-110%: Green (target range)
  * 110-120%: Yellow (above midpoint)
  * > 120%: Red (above maximum)
- And I can filter employees by:
  * Compa-ratio range
  * Department
  * Grade

**Dependencies**:
- FR-TR-COMP-003: Grade Structure (pay ranges)

**Business Rules**:
- BR-TR-COMP-040: Compa-ratio = (salary / grade midpoint) × 100
- BR-TR-COMP-041: Target compa-ratio is 90-110%

**Related Entities**:
- EmployeeCompensationSnapshot
- PayRange
- GradeVersion

**API Endpoints**:
- `GET /api/v1/compensation/employees/{id}/compa-ratio`
- `GET /api/v1/compensation/compa-ratio/dashboard`

---

#### FR-TR-COMP-015: Mass Compensation Upload

**Priority**: LOW

**User Story**:
```
As an HR Administrator
I want to upload compensation data in bulk
So that I can efficiently onboard new employees or make mass updates
```

**Description**:
The system shall support bulk upload of compensation data via CSV/Excel files.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I upload a compensation file
- Then the system:
  * Validates file format
  * Validates all data (employee IDs, amounts, dates)
  * Shows preview with validation results
  * Highlights errors
- And I can:
  * Fix errors inline
  * Download error report
  * Proceed with valid records only
- And upon confirmation:
  * Creates EmployeeCompensationSnapshot records
  * Creates SalaryHistory records
  * Sends notifications to affected employees
- And I can track:
  * Upload status
  * Success/failure count
  * Error log

**Dependencies**:
- Core module: Employee data

**Business Rules**:
- BR-TR-COMP-042: All records must pass validation
- BR-TR-COMP-043: Duplicate employee records rejected
- BR-TR-COMP-044: Effective dates must be valid

**Related Entities**:
- EmployeeCompensationSnapshot
- SalaryHistory

**API Endpoints**:
- `POST /api/v1/compensation/bulk-upload`
- `GET /api/v1/compensation/bulk-upload/{id}/status`
- `GET /api/v1/compensation/bulk-upload/{id}/errors`

---

#### FR-TR-COMP-016: Compensation Statement Generation

**Priority**: LOW

**User Story**:
```
As an Employee
I want to view my current compensation breakdown
So that I understand my total compensation package
```

**Description**:
The system shall generate compensation statements showing all pay components and total compensation.

**Acceptance Criteria**:
- Given I am an Employee
- When I view my compensation
- Then I see:
  * Base salary
  * All allowances
  * Recurring bonuses
  * Total monthly compensation
  * Total annual compensation
  * Grade and pay range
  * Compa-ratio
  * Last change date and amount
- And I can:
  * Download as PDF
  * View historical statements
  * Compare year-over-year

**Dependencies**:
- FR-TR-COMP-012: Salary History

**Business Rules**:
- BR-TR-COMP-045: Statement shows current active components only
- BR-TR-COMP-046: Sensitive data masked for non-owners

**Related Entities**:
- EmployeeCompensationSnapshot
- PayComponentDefinition

**API Endpoints**:
- `GET /api/v1/compensation/employees/{id}/statement`
- `GET /api/v1/compensation/employees/{id}/statement/pdf`
- `GET /api/v1/compensation/employees/{id}/statement/history`

---

#### FR-TR-COMP-017: Compensation Benchmarking

**Priority**: LOW

**User Story**:
```
As a Compensation Manager
I want to compare our compensation against market data
So that I can ensure competitive pay levels
```

**Description**:
The system shall support importing market data and comparing against internal compensation.

**Acceptance Criteria**:
- Given I am a Compensation Manager
- When I import market data
- Then I can map:
  * Market job titles to internal grades
  * Market locations to internal locations
  * Market data points (25th, 50th, 75th percentile)
- And I can compare:
  * Internal pay ranges vs market
  * Individual salaries vs market
  * By grade, department, location
- And the system shows:
  * Gap % (internal vs market)
  * Competitiveness rating
  * Recommendations for adjustments

**Dependencies**:
- FR-TR-COMP-003: Grade Structure

**Business Rules**:
- BR-TR-COMP-047: Market data must be from credible sources
- BR-TR-COMP-048: Comparison controls for job level and location

**Related Entities**:
- PayRange
- GradeVersion

**API Endpoints**:
- `POST /api/v1/compensation/market-data/import`
- `GET /api/v1/compensation/market-data/compare`
- `GET /api/v1/compensation/market-data/reports`

---

#### FR-TR-COMP-018: Compensation Approval Workflow Configuration

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to configure approval workflows for compensation changes
So that I can ensure proper governance and controls
```

**Description**:
The system shall allow HR Administrators to configure flexible approval workflows based on amount, percentage, and organizational hierarchy.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I configure approval workflows
- Then I can define:
  * Approval levels (Manager, Director, VP, CFO)
  * Thresholds by increase % or amount
  * Organizational hierarchy rules
  * Parallel vs sequential approval
- And I can configure:
  * Auto-approval conditions
  * Escalation rules (timeout)
  * Notification templates
- And the system validates:
  * No gaps in threshold coverage
  * Valid approver roles
- And I can test workflows with:
  * Sample scenarios
  * Expected routing

**Dependencies**:
- Core module: Employee hierarchy

**Business Rules**:
- BR-TR-COMP-049: Thresholds must be sequential
- BR-TR-COMP-050: All increases must have approval path
- BR-TR-COMP-051: Escalation after 5 business days

**Related Entities**:
- CompensationPlan
- CompensationAdjustment

**API Endpoints**:
- `POST /api/v1/compensation/approval-workflows`
- `GET /api/v1/compensation/approval-workflows`
- `PUT /api/v1/compensation/approval-workflows/{id}`
- `POST /api/v1/compensation/approval-workflows/test`

---

## Summary: Core Compensation

**Total Requirements**: 18  
**Priority Breakdown**:
- HIGH: 12 requirements
- MEDIUM: 4 requirements  
- LOW: 2 requirements

**Key Features**:
- Salary basis and component management
- Grade structures and career ladders
- Compensation cycles and adjustments
- Budget tracking and alerts
- Pay equity analysis
- Approval workflows

**Next Sub-Module**: Variable Pay (15 requirements)

---

*Document continues with remaining sub-modules...*

## 🎯 Feature Area 2: Variable Pay

### Overview

Variable Pay manages performance-based compensation including bonuses (STI/LTI), equity grants (RSU/Options), and sales commissions.

**Related Entities**: BonusPlan, BonusCycle, BonusPool, BonusAllocation, EquityGrant, EquityVestingEvent, EquityTransaction, CommissionPlan, CommissionTier, CommissionTransaction

**Related Concept Guide**: [Variable Pay Guide](../01-concept/02-variable-pay-guide.md)

---

#### FR-TR-VAR-001: Bonus Plan Setup

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want to create bonus plan templates
So that I can standardize STI, LTI, and other bonus programs
```

**Description**:
The system shall allow HR Administrators to create bonus plan templates defining bonus types, calculation formulas, eligibility rules, and performance multipliers.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I create a bonus plan
- Then I must provide:
  * Unique code (e.g., STI_2025, LTI_2025_2027)
  * Name
  * Bonus type (STI, LTI, COMMISSION, SPOT_BONUS, RETENTION, SIGN_ON)
  * Effective dates
- And I can configure:
  * Equity flag (whether bonus includes equity component)
  * Formula (JSON):
    - Base (ANNUAL_SALARY, MONTHLY_SALARY, FIXED_AMOUNT)
    - Target percentage
    - Performance multipliers by rating
    - Company multiplier range
  * Eligibility rules (JSON):
    - Min tenure months
    - Employment types
    - Grades
    - Performance rating minimum
    - Exclude probation
- And the system validates:
  * Plan code uniqueness
  * Valid bonus type
  * Formula completeness
  * Performance multipliers cover all ratings
- And I can activate/deactivate plans

**Dependencies**:
- None

**Business Rules**:
- BR-TR-VAR-001: Plan code must be unique
- BR-TR-VAR-002: STI typically annual, LTI multi-year
- BR-TR-VAR-003: Performance multipliers must cover all ratings
- BR-TR-VAR-004: Company multiplier range typically 0.8-1.2

**Related Entities**:
- BonusPlan

**API Endpoints**:
- `POST /api/v1/variable-pay/bonus-plans`
- `GET /api/v1/variable-pay/bonus-plans`
- `GET /api/v1/variable-pay/bonus-plans/{id}`
- `PUT /api/v1/variable-pay/bonus-plans/{id}`

---

#### FR-TR-VAR-002: Bonus Cycle Management

**Priority**: HIGH

**User Story**:
```
As a Compensation Manager
I want to create and manage bonus cycles
So that I can run annual STI and multi-year LTI programs
```

**Description**:
The system shall allow Compensation Managers to create bonus cycles with budget allocation and workflow management.

**Acceptance Criteria**:
- Given I am a Compensation Manager
- When I create a bonus cycle
- Then I must provide:
  * Plan ID (FK to BonusPlan)
  * Unique code (e.g., STI_2025_ANNUAL)
  * Name
  * Performance period (start and end dates)
  * Payout date
  * Budget amount and currency
- And I can configure:
  * Company multiplier (actual company performance)
  * Workflow state (DRAFT, OPEN, IN_REVIEW, APPROVED, PAID, CLOSED)
- And I can allocate budget by:
  * Legal entity (BonusPool)
  * Track utilization in real-time
- And the system validates:
  * Period end > period start
  * Payout date >= period end
  * Budget amount > 0
  * Company multiplier within plan range
- And I can manage cycle status transitions

**Dependencies**:
- FR-TR-VAR-001: Bonus Plan Setup
- Core module: Legal Entity

**Business Rules**:
- BR-TR-VAR-005: Period end must be after period start
- BR-TR-VAR-006: Cannot modify PAID or CLOSED cycle
- BR-TR-VAR-007: Company multiplier within plan-defined range

**Related Entities**:
- BonusCycle
- BonusPool

**API Endpoints**:
- `POST /api/v1/variable-pay/bonus-cycles`
- `GET /api/v1/variable-pay/bonus-cycles`
- `GET /api/v1/variable-pay/bonus-cycles/{id}`
- `PUT /api/v1/variable-pay/bonus-cycles/{id}`
- `POST /api/v1/variable-pay/bonus-cycles/{id}/status`

---

#### FR-TR-VAR-003: Bonus Allocation Proposal

**Priority**: HIGH

**User Story**:
```
As a Manager
I want to propose bonus amounts for my team
So that I can reward performance and align with company goals
```

**Description**:
The system shall allow Managers to propose bonus allocations with automatic calculation based on plan formula and performance ratings.

**Acceptance Criteria**:
- Given I am a Manager
- And there is an active bonus cycle (status = OPEN)
- When I propose a bonus for an employee
- Then the system automatically calculates:
  * Base amount (from salary or fixed amount)
  * Target bonus = base × target %
  * Performance multiplier (from employee's rating)
  * Company multiplier (from cycle)
  * Calculated bonus = target × performance multiplier × company multiplier
- And I can:
  * Accept calculated amount
  * Override with discretionary amount
  * Provide rationale/justification
- And the system validates:
  * Employee is eligible (per plan rules)
  * Budget availability in pool
  * Proposed amount reasonable (warnings if >150% of calculated)
- And I can save as DRAFT or submit as PENDING
- And the system determines approval routing

**Dependencies**:
- FR-TR-VAR-002: Bonus Cycle Management
- Performance Management module: Performance ratings

**Business Rules**:
- BR-TR-VAR-008: Employee must be eligible per plan rules
- BR-TR-VAR-009: Bonus = salary × target% × perf multiplier × co multiplier
- BR-TR-VAR-010: Manager discretion within reasonable bounds

**Related Entities**:
- BonusAllocation
- BonusPool
- EmployeeCompensationSnapshot

**API Endpoints**:
- `POST /api/v1/variable-pay/bonus-allocations`
- `GET /api/v1/variable-pay/bonus-allocations`
- `GET /api/v1/variable-pay/bonus-allocations/{id}`
- `PUT /api/v1/variable-pay/bonus-allocations/{id}`
- `POST /api/v1/variable-pay/bonus-allocations/{id}/calculate`

---

#### FR-TR-VAR-004: Bonus Approval Workflow

**Priority**: HIGH

**User Story**:
```
As a Director/VP
I want to review and approve bonus allocations
So that I can ensure budget compliance and fair distribution
```

**Description**:
The system shall route bonus allocations for approval based on amount thresholds and organizational hierarchy.

**Acceptance Criteria**:
- Given I am an Approver
- When bonus allocations are submitted
- Then the system routes to me based on:
  * Approval thresholds (amount or % of salary)
  * Organizational hierarchy
- And I can view:
  * Employee details and performance rating
  * Calculated vs proposed amount
  * Rationale
  * Budget impact
  * Peer comparison (fairness check)
- And I can:
  * Approve (status → APPROVED)
  * Reject (status → REJECTED, requires reason)
  * Request changes (status → DRAFT)
- And when I approve:
  * Budget utilization updated
  * Next approver notified (if multi-level)
- And when all approvals complete:
  * Allocation status → APPROVED
  * Ready for payout

**Dependencies**:
- FR-TR-VAR-003: Bonus Allocation Proposal

**Business Rules**:
- BR-TR-VAR-011: Approval routing per threshold configuration
- BR-TR-VAR-012: All required approvals must be obtained
- BR-TR-VAR-013: Cannot approve if budget exceeded (warning)

**Related Entities**:
- BonusAllocation
- BonusPool

**API Endpoints**:
- `GET /api/v1/variable-pay/bonus-allocations/pending-approval`
- `POST /api/v1/variable-pay/bonus-allocations/{id}/approve`
- `POST /api/v1/variable-pay/bonus-allocations/{id}/reject`

---

#### FR-TR-VAR-005: Bonus Payout Processing

**Priority**: HIGH

**User Story**:
```
As a Compensation Manager
I want to finalize bonus cycles and process payouts
So that employees receive their bonuses
```

**Description**:
The system shall allow Compensation Managers to finalize bonus cycles and generate payout files for payroll integration.

**Acceptance Criteria**:
- Given I am a Compensation Manager
- And a bonus cycle is in APPROVED status
- And all allocations are APPROVED or REJECTED
- When I finalize the cycle
- Then the system:
  * Generates payout file for payroll
  * Marks allocations as PAID
  * Changes cycle status: APPROVED → PAID
  * Creates audit records
- And I can view:
  * Summary report (total payout, avg bonus, by department)
  * Employee list with bonus amounts
  * Budget utilization final report
- And the payout file includes:
  * Employee ID
  * Bonus amount
  * Currency
  * Payout date
  * Tax treatment code
- And the system prevents:
  * Modifying PAID allocations
  * Reopening PAID cycle

**Dependencies**:
- FR-TR-VAR-004: Bonus Approval Workflow
- Payroll module: For payout file import

**Business Rules**:
- BR-TR-VAR-014: All allocations must be approved/rejected before payout
- BR-TR-VAR-015: Payout file format per payroll integration spec
- BR-TR-VAR-016: Cannot reopen PAID cycle

**Related Entities**:
- BonusCycle
- BonusAllocation

**API Endpoints**:
- `POST /api/v1/variable-pay/bonus-cycles/{id}/finalize`
- `GET /api/v1/variable-pay/bonus-cycles/{id}/payout-file`
- `GET /api/v1/variable-pay/bonus-cycles/{id}/summary`

---

#### FR-TR-VAR-006: Equity Grant Creation

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want to create equity grants for employees
So that I can provide long-term incentives and retention
```

**Description**:
The system shall allow HR Administrators to create equity grants (RSU, Options, SAR, Phantom Stock) with vesting schedules.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I create an equity grant
- Then I must provide:
  * Employee ID
  * Plan ID (FK to BonusPlan with equity_flag = true)
  * Grant number (unique, auto-generated)
  * Grant date
  * Unit type (RSU, OPTION, SAR, PHANTOM_STOCK)
  * Total units
  * Fair market value at grant date
- And for OPTIONS/SAR, I must provide:
  * Strike price (exercise price)
  * Expiry date (typically 10 years)
- And I can configure vesting schedule:
  * Type (TIME_BASED, PERFORMANCE_BASED, HYBRID)
  * Cliff months (e.g., 12 for 1-year cliff)
  * Total vesting period months (e.g., 48 for 4 years)
  * Vesting frequency (MONTHLY, QUARTERLY, ANNUAL)
- And the system automatically:
  * Generates vesting schedule (dates and units)
  * Sets status = ACTIVE
  * Calculates unvested units
- And the system validates:
  * Grant number uniqueness
  * Strike price <= FMV (for options)
  * Vesting schedule completeness
  * Total vesting units = total units

**Dependencies**:
- FR-TR-VAR-001: Bonus Plan Setup (equity plans)
- Core module: Employee

**Business Rules**:
- BR-TR-VAR-017: Grant number must be unique
- BR-TR-VAR-018: RSU has no strike price, Options require strike price
- BR-TR-VAR-019: Strike price typically = FMV at grant date
- BR-TR-VAR-020: Standard vesting: 4 years with 1-year cliff

**Related Entities**:
- EquityGrant
- BonusPlan

**API Endpoints**:
- `POST /api/v1/variable-pay/equity-grants`
- `GET /api/v1/variable-pay/equity-grants`
- `GET /api/v1/variable-pay/equity-grants/{id}`
- `PUT /api/v1/variable-pay/equity-grants/{id}`

---

#### FR-TR-VAR-007: Equity Vesting Event Processing

**Priority**: HIGH

**User Story**:
```
As the System
I want to automatically process vesting events
So that employees' vested equity is tracked accurately
```

**Description**:
The system shall automatically create and process vesting events based on grant vesting schedules.

**Acceptance Criteria**:
- Given an equity grant with vesting schedule
- When a vesting date arrives
- Then the system automatically:
  * Creates EquityVestingEvent record
  * Sets event type (SCHEDULED, CLIFF, or ACCELERATED)
  * Updates grant vested_units
  * Updates grant unvested_units
  * For RSU: Creates taxable event (vest = taxable income)
  * For Options: No tax event (tax on exercise)
- And for accelerated vesting (acquisition, termination):
  * HR can manually trigger acceleration
  * Specify acceleration reason
  * Vest all or partial unvested units
- And for forfeiture (bad leaver termination):
  * HR can create FORFEIT event
  * Negative vested_units (reversal)
  * Update grant status
- And the system validates:
  * Vesting date is valid
  * Units to vest <= unvested units
  * Acceleration reason required for ACCELERATED

**Dependencies**:
- FR-TR-VAR-006: Equity Grant Creation
- Payroll module: For RSU tax withholding

**Business Rules**:
- BR-TR-VAR-021: SCHEDULED events auto-created from vesting schedule
- BR-TR-VAR-022: RSU vesting creates immediate taxable event
- BR-TR-VAR-023: Option vesting creates exercise opportunity (not taxable)
- BR-TR-VAR-024: Forfeiture for bad leaver termination

**Related Entities**:
- EquityVestingEvent
- EquityGrant

**API Endpoints**:
- `GET /api/v1/variable-pay/equity-grants/{id}/vesting-events`
- `POST /api/v1/variable-pay/equity-grants/{id}/accelerate`
- `POST /api/v1/variable-pay/equity-grants/{id}/forfeit`

---

#### FR-TR-VAR-008: Option Exercise Processing

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to exercise my vested stock options
So that I can purchase company stock at the strike price
```

**Description**:
The system shall allow employees to exercise vested stock options and track the transactions.

**Acceptance Criteria**:
- Given I am an Employee
- And I have vested options
- When I exercise options
- Then I must specify:
  * Number of units to exercise (<= vested units)
- And the system calculates:
  * Exercise cost = units × strike price
  * Current FMV (from latest valuation)
  * Taxable gain = units × (FMV - strike price)
- And the system creates:
  * EquityTransaction record (type = EXERCISE)
  * Tax withholding record (for payroll)
- And the system updates:
  * Grant exercised_units += units
  * Grant vested_units -= units
- And I receive:
  * Confirmation with transaction details
  * Tax withholding amount
  * Stock certificate or account credit
- And the system validates:
  * Units <= vested units
  * Grant not expired
  * Employee has funds for exercise cost

**Dependencies**:
- FR-TR-VAR-007: Equity Vesting Event Processing
- Payroll module: For tax withholding

**Business Rules**:
- BR-TR-VAR-025: Can only exercise vested units
- BR-TR-VAR-026: Exercise cost = units × strike price
- BR-TR-VAR-027: Taxable gain = units × (FMV - strike)
- BR-TR-VAR-028: Tax withheld at exercise

**Related Entities**:
- EquityTransaction
- EquityGrant

**API Endpoints**:
- `POST /api/v1/variable-pay/equity-grants/{id}/exercise`
- `GET /api/v1/variable-pay/equity-transactions`
- `GET /api/v1/variable-pay/equity-transactions/{id}`

---

#### FR-TR-VAR-009: Commission Plan Setup

**Priority**: HIGH

**User Story**:
```
As a Sales Operations Manager
I want to create commission plan templates
So that I can standardize sales compensation structures
```

**Description**:
The system shall allow Sales Operations Managers to create commission plans with tiered rates and quota definitions.

**Acceptance Criteria**:
- Given I am a Sales Operations Manager
- When I create a commission plan
- Then I must provide:
  * Unique code (e.g., SALES_COMM_2025)
  * Name
  * Plan type (REVENUE_BASED, PROFIT_BASED, UNIT_BASED, HYBRID)
  * Quota type (INDIVIDUAL, TEAM, TERRITORY, PRODUCT)
  * Payment frequency (MONTHLY, QUARTERLY, ANNUAL)
  * Calculation method (FLAT_RATE, TIERED, ACCELERATOR, DECELERATOR)
- And I can configure formula (JSON):
  * For FLAT_RATE: base_rate, cap
  * For ACCELERATOR: base_rate, quota_threshold, accelerator rates, cap
  * For TIERED: see CommissionTier
- And I can set eligibility rules:
  * Departments (e.g., Sales)
  * Employment types
  * Min tenure
- And the system validates:
  * Plan code uniqueness
  * Formula completeness per calculation method
  * Rates are positive

**Dependencies**:
- None

**Business Rules**:
- BR-TR-VAR-029: Plan code must be unique
- BR-TR-VAR-030: TIERED plans require CommissionTier records
- BR-TR-VAR-031: ACCELERATOR increases rate above quota
- BR-TR-VAR-032: Cap limits maximum commission

**Related Entities**:
- CommissionPlan

**API Endpoints**:
- `POST /api/v1/variable-pay/commission-plans`
- `GET /api/v1/variable-pay/commission-plans`
- `GET /api/v1/variable-pay/commission-plans/{id}`
- `PUT /api/v1/variable-pay/commission-plans/{id}`

---

#### FR-TR-VAR-010: Commission Tier Configuration

**Priority**: MEDIUM

**User Story**:
```
As a Sales Operations Manager
I want to define commission tiers
So that I can reward over-achievement with higher rates
```

**Description**:
The system shall allow Sales Operations Managers to define commission tiers for tiered commission plans.

**Acceptance Criteria**:
- Given I am a Sales Operations Manager
- And I have a commission plan with TIERED calculation method
- When I create commission tiers
- Then I must provide for each tier:
  * Tier number (sequence: 1, 2, 3...)
  * Min achievement % (e.g., 0, 80, 100, 120)
  * Max achievement % (NULL for unlimited top tier)
  * Commission rate (e.g., 0.05 for 5%)
- And the system validates:
  * Tier numbers are sequential
  * No gaps in achievement % ranges
  * Rates are positive
  * Only top tier can have NULL max
- And I can view:
  * Tier structure visualization
  * Example calculations

**Dependencies**:
- FR-TR-VAR-009: Commission Plan Setup

**Business Rules**:
- BR-TR-VAR-033: Tier ranges must be contiguous
- BR-TR-VAR-034: Achievement % = (revenue / quota) × 100
- BR-TR-VAR-035: Commission calculated per tier

**Related Entities**:
- CommissionTier
- CommissionPlan

**API Endpoints**:
- `POST /api/v1/variable-pay/commission-plans/{id}/tiers`
- `GET /api/v1/variable-pay/commission-plans/{id}/tiers`
- `PUT /api/v1/variable-pay/commission-tiers/{id}`
- `DELETE /api/v1/variable-pay/commission-tiers/{id}`

---

#### FR-TR-VAR-011: Commission Transaction Processing

**Priority**: HIGH

**User Story**:
```
As a Sales Operations Manager
I want to calculate and process sales commissions
So that sales reps are compensated for their performance
```

**Description**:
The system shall calculate commissions based on sales data, quotas, and commission plans.

**Acceptance Criteria**:
- Given I am a Sales Operations Manager
- When I import sales data for a period
- Then for each sales rep:
  * System retrieves commission plan
  * Retrieves quota for period
  * Calculates achievement % = (revenue / quota) × 100
  * Determines applicable tier (for TIERED plans)
  * Calculates commission amount
  * Creates CommissionTransaction record
- And the transaction includes:
  * Employee ID
  * Plan ID
  * Period (start and end dates)
  * Revenue amount
  * Quota amount
  * Achievement %
  * Commission rate applied
  * Commission amount
  * Status (PENDING, APPROVED, PAID, DISPUTED)
- And I can:
  * Review all transactions
  * Approve/reject transactions
  * Handle disputes
  * Generate payout file
- And the system validates:
  * Sales data completeness
  * Quota assignment
  * Commission calculation accuracy

**Dependencies**:
- FR-TR-VAR-009: Commission Plan Setup
- FR-TR-VAR-010: Commission Tier Configuration
- CRM/Sales system: For sales data

**Business Rules**:
- BR-TR-VAR-036: Achievement % = (revenue / quota) × 100
- BR-TR-VAR-037: Tier determined by achievement %
- BR-TR-VAR-038: Commission = revenue × rate (or tiered calculation)
- BR-TR-VAR-039: Cannot modify APPROVED or PAID transactions

**Related Entities**:
- CommissionTransaction
- CommissionPlan
- CommissionTier

**API Endpoints**:
- `POST /api/v1/variable-pay/commission-transactions/import`
- `GET /api/v1/variable-pay/commission-transactions`
- `POST /api/v1/variable-pay/commission-transactions/{id}/approve`
- `POST /api/v1/variable-pay/commission-transactions/{id}/dispute`

---

#### FR-TR-VAR-012: Performance Rating Integration

**Priority**: MEDIUM

**User Story**:
```
As a Compensation Manager
I want to automatically import performance ratings
So that bonus calculations use accurate performance data
```

**Description**:
The system shall integrate with Performance Management module to import performance ratings for bonus calculations.

**Acceptance Criteria**:
- Given a performance review cycle is completed
- When I trigger rating import
- Then the system:
  * Retrieves latest performance ratings for all employees
  * Maps ratings to bonus plan performance multipliers
  * Validates rating values
  * Updates employee records
- And I can:
  * View import status
  * See employees with missing ratings
  * Manually override ratings (with justification)
- And the system validates:
  * Rating values are valid
  * Rating dates are current
  * All eligible employees have ratings

**Dependencies**:
- Performance Management module: Performance ratings
- FR-TR-VAR-003: Bonus Allocation Proposal

**Business Rules**:
- BR-TR-VAR-040: Ratings must be from current review cycle
- BR-TR-VAR-041: Missing ratings prevent bonus calculation
- BR-TR-VAR-042: Manual overrides require approval

**Related Entities**:
- BonusAllocation
- Core.Employee

**API Endpoints**:
- `POST /api/v1/variable-pay/performance-ratings/import`
- `GET /api/v1/variable-pay/performance-ratings/status`
- `POST /api/v1/variable-pay/performance-ratings/override`

---

#### FR-TR-VAR-013: Equity Cap Table Management

**Priority**: LOW

**User Story**:
```
As a Finance Manager
I want to track equity cap table
So that I can monitor ownership dilution and compliance
```

**Description**:
The system shall maintain an equity cap table showing total shares, grants, vested, exercised, and available pool.

**Acceptance Criteria**:
- Given equity grants exist
- When I view cap table
- Then I see:
  * Total authorized shares
  * Total granted shares
  * Total vested shares
  * Total exercised shares
  * Available pool (authorized - granted)
  * Ownership % by employee
- And I can filter by:
  * Grant type (RSU, Options)
  * Status (Active, Vested, Exercised)
  * Date range
- And I can export:
  * Cap table report
  * Ownership breakdown
  * Dilution analysis

**Dependencies**:
- FR-TR-VAR-006: Equity Grant Creation
- FR-TR-VAR-007: Equity Vesting Event Processing

**Business Rules**:
- BR-TR-VAR-043: Total granted <= total authorized
- BR-TR-VAR-044: Cap table updated in real-time
- BR-TR-VAR-045: Ownership % = (shares / total outstanding) × 100

**Related Entities**:
- EquityGrant
- EquityTransaction

**API Endpoints**:
- `GET /api/v1/variable-pay/cap-table`
- `GET /api/v1/variable-pay/cap-table/export`

---

#### FR-TR-VAR-014: Variable Pay Statement

**Priority**: LOW

**User Story**:
```
As an Employee
I want to view my variable pay summary
So that I understand my total compensation potential
```

**Description**:
The system shall generate variable pay statements showing bonuses, equity, and commissions.

**Acceptance Criteria**:
- Given I am an Employee
- When I view my variable pay
- Then I see:
  * Current year bonus (target and actual)
  * Equity grants summary:
    - Total granted
    - Vested
    - Unvested
    - Current value
  * Commission summary (if applicable):
    - YTD commission
    - Current period commission
    - Quota achievement
- And I can:
  * Download as PDF
  * View historical statements
  * See vesting schedule

**Dependencies**:
- FR-TR-VAR-003: Bonus Allocation
- FR-TR-VAR-006: Equity Grants
- FR-TR-VAR-011: Commission Transactions

**Business Rules**:
- BR-TR-VAR-046: Statement shows current active data only
- BR-TR-VAR-047: Equity value based on latest FMV

**Related Entities**:
- BonusAllocation
- EquityGrant
- CommissionTransaction

**API Endpoints**:
- `GET /api/v1/variable-pay/employees/{id}/statement`
- `GET /api/v1/variable-pay/employees/{id}/statement/pdf`

---

#### FR-TR-VAR-015: Bonus Budget Reallocation

**Priority**: MEDIUM

**User Story**:
```
As a Compensation Manager
I want to reallocate bonus budget between pools
So that I can optimize budget utilization
```

**Description**:
The system shall allow Compensation Managers to reallocate bonus budget between legal entity pools.

**Acceptance Criteria**:
- Given I am a Compensation Manager
- And a bonus cycle is OPEN or IN_REVIEW
- When I reallocate budget
- Then I must specify:
  * Source pool ID
  * Target pool ID
  * Amount to transfer
  * Reason/justification
- And the system validates:
  * Source pool has sufficient available budget
  * Pools belong to same cycle
  * Amount > 0
- And the system updates:
  * Source pool: budget_amount -= amount
  * Target pool: budget_amount += amount
  * Creates audit record
- And I can view:
  * Reallocation history
  * Current pool balances

**Dependencies**:
- FR-TR-VAR-002: Bonus Cycle Management

**Business Rules**:
- BR-TR-VAR-048: Reallocation requires approval
- BR-TR-VAR-049: Cannot reallocate from over-utilized pool
- BR-TR-VAR-050: Audit trail for all reallocations

**Related Entities**:
- BonusPool
- BonusCycle

**API Endpoints**:
- `POST /api/v1/variable-pay/bonus-pools/reallocate`
- `GET /api/v1/variable-pay/bonus-pools/reallocation-history`

---

## Summary: Variable Pay

**Total Requirements**: 15  
**Priority Breakdown**:
- HIGH: 10 requirements
- MEDIUM: 3 requirements  
- LOW: 2 requirements

**Key Features**:
- Bonus plans and cycles (STI/LTI)
- Equity grants and vesting (RSU/Options)
- Commission plans and processing
- Performance integration
- Cap table management

**Next Sub-Module**: Benefits (20 requirements)

---

*Document continues with remaining sub-modules...*

## 🎯 Feature Area 3: Benefits

### Overview

Benefits manages employee benefit programs including health insurance, retirement plans, wellness programs, and perks. This includes plan setup, enrollment management, dependent coverage, beneficiary designation, reimbursements, and healthcare claims.

**Related Entities**: BenefitPlan, BenefitOption, EligibilityProfile, PlanEligibility, EnrollmentPeriod, LifeEvent, EmployeeDependent, BenefitBeneficiary, Enrollment, ReimbursementRequest, ReimbursementLine, HealthcareClaimHeader, HealthcareClaimLine

**Related Concept Guide**: [Benefits Administration Guide](../01-concept/03-benefits-administration-guide.md)

---

#### FR-TR-BEN-001: Benefit Plan Setup

**Priority**: HIGH

**User Story**:
```
As a Benefits Administrator
I want to create and configure benefit plans
So that I can offer health, retirement, and wellness programs to employees
```

**Description**:
The system shall allow Benefits Administrators to create benefit plans with eligibility rules, coverage options, and premium configurations.

**Acceptance Criteria**:
- Given I am a Benefits Administrator
- When I create a benefit plan
- Then I must provide:
  * Unique code (e.g., MEDICAL_VN_2025)
  * Name
  * Plan category (MEDICAL, DENTAL, VISION, LIFE, DISABILITY, RETIREMENT, WELLNESS, PERK, EDUCATION, TRANSPORTATION)
  * Provider name (insurance carrier)
  * Sponsor legal entity
  * Currency
  * Effective dates
- And I can configure:
  * Premium type (EMPLOYEE, EMPLOYER, SHARED)
  * Eligibility rules (JSON or link to EligibilityProfile)
  * Coverage options (see FR-TR-BEN-002)
- And the system validates:
  * Plan code uniqueness
  * Valid plan category
  * Effective dates (start <= end)
  * Currency matches legal entity
- And I can activate/deactivate plans

**Dependencies**:
- Core module: Legal Entity
- FR-TR-ELIG-001: Eligibility Profile (if using shared profiles)

**Business Rules**:
- BR-TR-BEN-001: Plan code must be unique
- BR-TR-BEN-002: Eligibility evaluated at enrollment time
- BR-TR-BEN-003: Premium type determines cost sharing

**Related Entities**:
- BenefitPlan
- EligibilityProfile (optional)

**API Endpoints**:
- `POST /api/v1/benefits/plans`
- `GET /api/v1/benefits/plans`
- `GET /api/v1/benefits/plans/{id}`
- `PUT /api/v1/benefits/plans/{id}`

---

#### FR-TR-BEN-002: Benefit Coverage Options

**Priority**: HIGH

**User Story**:
```
As a Benefits Administrator
I want to define coverage options for benefit plans
So that employees can choose coverage levels (employee only, family, etc.)
```

**Description**:
The system shall allow Benefits Administrators to define coverage options (tiers) with associated costs for each benefit plan.

**Acceptance Criteria**:
- Given I am a Benefits Administrator
- And I have created a benefit plan
- When I add coverage options
- Then I must provide for each option:
  * Unique code (e.g., EMP_ONLY, EMP_FAMILY)
  * Name
  * Coverage tier (EMPLOYEE_ONLY, EMPLOYEE_SPOUSE, EMPLOYEE_CHILDREN, EMPLOYEE_FAMILY, EMPLOYEE_DOMESTIC_PARTNER)
  * Employee cost per period
  * Employer cost per period
  * Currency
- And I can optionally configure:
  * Cost formula (JSON) for dynamic pricing
  * Age-banded rates
  * Dependent count-based pricing
- And the system validates:
  * Option code unique within plan
  * Costs are non-negative
  * Total cost = employee cost + employer cost
- And I can view:
  * Cost comparison across options
  * Premium split (employee vs employer)

**Dependencies**:
- FR-TR-BEN-001: Benefit Plan Setup

**Business Rules**:
- BR-TR-BEN-004: Total cost = employee cost + employer cost
- BR-TR-BEN-005: EMPLOYEE_FAMILY tier covers spouse + children
- BR-TR-BEN-006: Costs can vary by demographics (age, location)

**Related Entities**:
- BenefitOption
- BenefitPlan

**API Endpoints**:
- `POST /api/v1/benefits/plans/{id}/options`
- `GET /api/v1/benefits/plans/{id}/options`
- `PUT /api/v1/benefits/options/{id}`
- `DELETE /api/v1/benefits/options/{id}`

---

#### FR-TR-BEN-003: Enrollment Period Management

**Priority**: HIGH

**User Story**:
```
As a Benefits Administrator
I want to create and manage enrollment periods
So that employees can enroll in benefits at appropriate times
```

**Description**:
The system shall allow Benefits Administrators to create enrollment periods for open enrollment, new hires, and special events.

**Acceptance Criteria**:
- Given I am a Benefits Administrator
- When I create an enrollment period
- Then I must provide:
  * Unique code (e.g., OPEN_ENROLLMENT_2025)
  * Name
  * Period type (OPEN_ENROLLMENT, NEW_HIRE, QUALIFYING_EVENT, SPECIAL_ENROLLMENT)
  * Enrollment start and end dates
  * Coverage start date
  * Coverage end date (optional, NULL for ongoing)
- And I can configure:
  * Eligible plans (JSON list or ALL)
  * Auto-enroll flag (for new hires)
  * Reminder schedule (JSON)
  * Status (DRAFT, SCHEDULED, OPEN, CLOSED, CANCELLED)
- And the system validates:
  * Period code uniqueness
  * Enrollment end <= coverage start
  * Reminder dates within enrollment period
- And I can manage status transitions:
  * DRAFT → SCHEDULED → OPEN → CLOSED
- And the system automatically:
  * Sends reminders per schedule
  * Opens/closes period on scheduled dates

**Dependencies**:
- FR-TR-BEN-001: Benefit Plan Setup

**Business Rules**:
- BR-TR-BEN-007: Enrollment end must be before coverage start
- BR-TR-BEN-008: OPEN_ENROLLMENT typically annual
- BR-TR-BEN-009: NEW_HIRE period for new employees (30 days)
- BR-TR-BEN-010: QUALIFYING_EVENT triggered by life events

**Related Entities**:
- EnrollmentPeriod

**API Endpoints**:
- `POST /api/v1/benefits/enrollment-periods`
- `GET /api/v1/benefits/enrollment-periods`
- `GET /api/v1/benefits/enrollment-periods/{id}`
- `PUT /api/v1/benefits/enrollment-periods/{id}`
- `POST /api/v1/benefits/enrollment-periods/{id}/status`

---

#### FR-TR-BEN-004: Employee Enrollment

**Priority**: HIGH

**User Story**:
```
As an Employee
I want to enroll in benefit plans
So that I can secure health insurance and other benefits for myself and my family
```

**Description**:
The system shall allow employees to enroll in benefit plans during active enrollment periods.

**Acceptance Criteria**:
- Given I am an Employee
- And there is an active enrollment period (status = OPEN)
- When I enroll in a benefit plan
- Then I can:
  * View all plans I'm eligible for
  * See plan details and coverage options
  * Select coverage option (e.g., Employee + Family)
  * Add covered dependents (if family coverage)
  * Review costs (employee and employer portions)
  * Submit enrollment
- And the system validates:
  * I am eligible for the plan
  * Enrollment period is OPEN
  * Selected dependents are eligible
  * I haven't already enrolled in this plan
- And the system creates:
  * Enrollment record (status = PENDING or ACTIVE)
  * Links to covered dependents
  * Premium deduction records
- And I receive:
  * Enrollment confirmation
  * Coverage summary
  * ID cards (if applicable)

**Dependencies**:
- FR-TR-BEN-003: Enrollment Period Management
- FR-TR-BEN-006: Dependent Management

**Business Rules**:
- BR-TR-BEN-011: Only one active enrollment per plan per employee
- BR-TR-BEN-012: Coverage starts on period coverage_start_date
- BR-TR-BEN-013: Premium deductions start on coverage start

**Related Entities**:
- Enrollment
- BenefitOption
- EmployeeDependent

**API Endpoints**:
- `GET /api/v1/benefits/employees/{id}/eligible-plans`
- `POST /api/v1/benefits/enrollments`
- `GET /api/v1/benefits/enrollments`
- `GET /api/v1/benefits/enrollments/{id}`

---

#### FR-TR-BEN-005: Enrollment Waiver

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to waive benefit coverage
So that I can decline plans when I have alternative coverage
```

**Description**:
The system shall allow employees to waive benefit coverage with documented reasons.

**Acceptance Criteria**:
- Given I am an Employee
- And there is an active enrollment period
- When I waive a benefit plan
- Then I must provide:
  * Plan to waive
  * Waiver reason (COVERED_BY_SPOUSE, GOVERNMENT_COVERAGE, PRIVATE_INSURANCE, OTHER)
  * Waiver reason text (detailed explanation)
- And I can optionally upload:
  * Proof of alternative coverage
- And the system creates:
  * Enrollment record with status = WAIVED
  * Waiver documentation
- And the system validates:
  * Waiver reason is provided
  * I haven't already enrolled or waived this plan
- And I receive:
  * Waiver confirmation
  * Reminder of annual re-enrollment requirement

**Dependencies**:
- FR-TR-BEN-003: Enrollment Period Management

**Business Rules**:
- BR-TR-BEN-014: Waiver requires reason
- BR-TR-BEN-015: Waiver must be renewed annually
- BR-TR-BEN-016: Can enroll later via qualifying life event

**Related Entities**:
- Enrollment

**API Endpoints**:
- `POST /api/v1/benefits/enrollments/waive`
- `GET /api/v1/benefits/enrollments/waivers`

---

#### FR-TR-BEN-006: Dependent Management

**Priority**: HIGH

**User Story**:
```
As an Employee
I want to add and manage my dependents
So that I can enroll them in family benefit coverage
```

**Description**:
The system shall allow employees to add, update, and remove dependents with eligibility validation.

**Acceptance Criteria**:
- Given I am an Employee
- When I add a dependent
- Then I must provide:
  * Full legal name
  * Relationship (SPOUSE, DOMESTIC_PARTNER, CHILD, STEPCHILD, ADOPTED_CHILD, PARENT, SIBLING, OTHER)
  * Date of birth
  * Gender (optional)
  * National ID/SSN (encrypted)
- And I can optionally provide:
  * Student status (for children 18-26)
  * Disability status (for disabled dependents)
- And I must upload:
  * Supporting documents (birth certificate, marriage certificate, etc.)
- And the system validates:
  * Dependent age eligibility (e.g., children < 21 or 26)
  * Student status if claiming student extension
  * Document completeness
- And the system calculates:
  * Eligibility end date (e.g., child turns 21/26)
- And I can:
  * Update dependent information
  * Remove dependent (with effective date)
  * View dependent eligibility status

**Dependencies**:
- None

**Business Rules**:
- BR-TR-BEN-017: CHILD eligible until age 26 (US) or 21 (Vietnam)
- BR-TR-BEN-018: STUDENT status extends eligibility to age 26
- BR-TR-BEN-019: DISABLED dependents have no age limit
- BR-TR-BEN-020: Supporting documents required for verification

**Related Entities**:
- EmployeeDependent

**API Endpoints**:
- `POST /api/v1/benefits/dependents`
- `GET /api/v1/benefits/dependents`
- `GET /api/v1/benefits/dependents/{id}`
- `PUT /api/v1/benefits/dependents/{id}`
- `DELETE /api/v1/benefits/dependents/{id}`

---

#### FR-TR-BEN-007: Dependent Verification

**Priority**: MEDIUM

**User Story**:
```
As a Benefits Administrator
I want to verify dependent eligibility annually
So that I can ensure only eligible dependents are covered
```

**Description**:
The system shall support annual dependent verification processes to validate continued eligibility.

**Acceptance Criteria**:
- Given I am a Benefits Administrator
- When I initiate annual verification
- Then the system:
  * Flags all dependents for verification
  * Sends notifications to employees (60 days before deadline)
  * Sends reminders (30, 14, 7 days before deadline)
- And employees must:
  * Upload current documents for each dependent
  * Confirm student status (if applicable)
  * Confirm disability status (if applicable)
- And I can:
  * Review submitted documents
  * Approve or reject verification
  * Request additional documents
- And the system automatically:
  * Removes unverified dependents after deadline
  * Adjusts coverage and premiums
  * Notifies employees of changes
- And I can generate:
  * Verification status report
  * Ineligible dependents report

**Dependencies**:
- FR-TR-BEN-006: Dependent Management

**Business Rules**:
- BR-TR-BEN-021: Annual verification required
- BR-TR-BEN-022: Unverified dependents removed after deadline
- BR-TR-BEN-023: Student status requires enrollment verification

**Related Entities**:
- EmployeeDependent

**API Endpoints**:
- `POST /api/v1/benefits/dependents/verification/initiate`
- `GET /api/v1/benefits/dependents/verification/status`
- `POST /api/v1/benefits/dependents/{id}/verify`

---

#### FR-TR-BEN-008: Life Event Processing

**Priority**: HIGH

**User Story**:
```
As an Employee
I want to report qualifying life events
So that I can make mid-year benefit changes
```

**Description**:
The system shall allow employees to report qualifying life events that trigger special enrollment periods.

**Acceptance Criteria**:
- Given I am an Employee
- When I report a life event
- Then I must provide:
  * Event type (MARRIAGE, DIVORCE, BIRTH, ADOPTION, DEATH_OF_DEPENDENT, LOSS_OF_COVERAGE, CHANGE_IN_EMPLOYMENT, RELOCATION, DISABILITY)
  * Event date
  * Supporting documents
- And the system:
  * Creates LifeEvent record (status = PENDING)
  * Calculates enrollment deadline (typically event_date + 30 days)
  * Requests document upload
- And I can upload:
  * Required documents (marriage cert, birth cert, etc.)
- And Benefits Admin can:
  * Review documents
  * Verify life event (status = VERIFIED)
  * Reject if invalid (status = REJECTED)
- And when verified:
  * Special enrollment period opens (30 days)
  * I can add/remove dependents
  * I can change coverage options
  * Changes effective from event date (retroactive)
- And the system validates:
  * Event reported within 30 days
  * Documents match event type
  * Changes align with event (e.g., add spouse for marriage)

**Dependencies**:
- FR-TR-BEN-006: Dependent Management
- FR-TR-BEN-004: Employee Enrollment

**Business Rules**:
- BR-TR-BEN-024: Life event must be reported within 30 days
- BR-TR-BEN-025: Enrollment deadline = event_date + 30 days
- BR-TR-BEN-026: Supporting documents required for verification
- BR-TR-BEN-027: Coverage changes effective from event date

**Related Entities**:
- LifeEvent
- Enrollment
- EmployeeDependent

**API Endpoints**:
- `POST /api/v1/benefits/life-events`
- `GET /api/v1/benefits/life-events`
- `GET /api/v1/benefits/life-events/{id}`
- `POST /api/v1/benefits/life-events/{id}/verify`
- `POST /api/v1/benefits/life-events/{id}/reject`

---

#### FR-TR-BEN-009: Beneficiary Designation

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to designate beneficiaries for life insurance and retirement plans
So that my benefits go to the right people if I die
```

**Description**:
The system shall allow employees to designate primary and contingent beneficiaries for life and retirement benefits.

**Acceptance Criteria**:
- Given I am an Employee
- And I am enrolled in a LIFE or RETIREMENT plan
- When I designate beneficiaries
- Then I can add:
  * PRIMARY beneficiaries (must total 100%)
  * CONTINGENT beneficiaries (must total 100%)
- And for each beneficiary, I provide:
  * Full legal name
  * Relationship (SPOUSE, CHILD, PARENT, SIBLING, TRUST, ESTATE, OTHER)
  * Allocation percentage
  * Irrevocable flag (default: false)
  * Effective date
- And the system validates:
  * PRIMARY percentages sum to 100%
  * CONTINGENT percentages sum to 100%
  * Percentages are positive
  * Irrevocable beneficiaries cannot be changed without consent
- And I can:
  * Update beneficiaries (if not irrevocable)
  * View beneficiary history
  * Print beneficiary designation form

**Dependencies**:
- FR-TR-BEN-004: Employee Enrollment

**Business Rules**:
- BR-TR-BEN-028: PRIMARY beneficiaries must sum to 100%
- BR-TR-BEN-029: CONTINGENT receive if all PRIMARY deceased
- BR-TR-BEN-030: CONTINGENT must also sum to 100%
- BR-TR-BEN-031: IRREVOCABLE beneficiaries cannot be changed without consent

**Related Entities**:
- BenefitBeneficiary
- Enrollment

**API Endpoints**:
- `POST /api/v1/benefits/enrollments/{id}/beneficiaries`
- `GET /api/v1/benefits/enrollments/{id}/beneficiaries`
- `PUT /api/v1/benefits/beneficiaries/{id}`
- `DELETE /api/v1/benefits/beneficiaries/{id}`

---

#### FR-TR-BEN-010: Reimbursement Request Submission

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to submit expense reimbursement requests
So that I can be reimbursed for medical, wellness, and education expenses
```

**Description**:
The system shall allow employees to submit reimbursement requests for eligible expenses with receipt uploads.

**Acceptance Criteria**:
- Given I am an Employee
- When I submit a reimbursement request
- Then I must provide:
  * Reimbursement type (MEDICAL, WELLNESS, EDUCATION, TRANSPORTATION, OTHER)
  * Request date
  * Total amount
  * Currency
  * Description
- And I can add multiple expense lines:
  * Expense date
  * Vendor/provider name
  * Description
  * Amount
  * Receipt upload
- And the system validates:
  * I am eligible for this reimbursement type
  * Total amount = sum of line amounts
  * Receipts uploaded for all lines
  * Amounts within annual limits
- And I can:
  * Save as DRAFT
  * Submit for approval (status = PENDING)
  * View request status
- And the system checks:
  * Annual limit remaining
  * Per-claim limit
  * Eligible expense categories

**Dependencies**:
- None

**Business Rules**:
- BR-TR-BEN-032: Receipts required for all expenses
- BR-TR-BEN-033: Expenses must be within annual limit
- BR-TR-BEN-034: Per-claim maximum applies
- BR-TR-BEN-035: Expenses must be within current year

**Related Entities**:
- ReimbursementRequest
- ReimbursementLine

**API Endpoints**:
- `POST /api/v1/benefits/reimbursements`
- `GET /api/v1/benefits/reimbursements`
- `GET /api/v1/benefits/reimbursements/{id}`
- `PUT /api/v1/benefits/reimbursements/{id}`
- `POST /api/v1/benefits/reimbursements/{id}/submit`

---

#### FR-TR-BEN-011: Reimbursement Approval

**Priority**: MEDIUM

**User Story**:
```
As a Manager/Benefits Administrator
I want to review and approve reimbursement requests
So that employees receive timely reimbursements
```

**Description**:
The system shall route reimbursement requests for approval based on amount thresholds.

**Acceptance Criteria**:
- Given I am an Approver
- When reimbursement requests are submitted
- Then the system routes to me based on:
  * Amount thresholds (e.g., <5M to Manager, >5M to HR)
  * Reimbursement type
- And I can view:
  * Employee details
  * Expense details and receipts
  * Amount requested
  * Annual limit utilization
- And I can:
  * Approve (status → APPROVED)
  * Reject (status → REJECTED, requires reason)
  * Request more information (status → PENDING_INFO)
- And when I approve:
  * Payment processed via payroll or bank transfer
  * Annual limit updated
  * Employee notified
- And when I reject:
  * Rejection reason sent to employee
  * Request closed

**Dependencies**:
- FR-TR-BEN-010: Reimbursement Request Submission

**Business Rules**:
- BR-TR-BEN-036: Approval routing per threshold configuration
- BR-TR-BEN-037: Cannot approve if exceeds annual limit
- BR-TR-BEN-038: Rejection requires reason

**Related Entities**:
- ReimbursementRequest

**API Endpoints**:
- `GET /api/v1/benefits/reimbursements/pending-approval`
- `POST /api/v1/benefits/reimbursements/{id}/approve`
- `POST /api/v1/benefits/reimbursements/{id}/reject`
- `POST /api/v1/benefits/reimbursements/{id}/request-info`

---

#### FR-TR-BEN-012: Healthcare Claim Submission

**Priority**: LOW

**User Story**:
```
As an Employee
I want to submit healthcare claims
So that I can get reimbursed for medical expenses
```

**Description**:
The system shall allow employees to submit healthcare claims for insurance reimbursement.

**Acceptance Criteria**:
- Given I am an Employee
- And I am enrolled in a MEDICAL, DENTAL, or VISION plan
- When I submit a healthcare claim
- Then I must provide:
  * Enrollment ID (which plan)
  * Service date
  * Provider name
  * Total amount
- And I can add claim lines:
  * Procedure code (CPT/ICD)
  * Description
  * Charge amount
- And I can upload:
  * Itemized bill
  * Explanation of Benefits (EOB)
- And the system:
  * Creates HealthcareClaimHeader and Lines
  * Sets status = SUBMITTED
  * Sends to insurance provider (if integrated)
- And I can:
  * Track claim status
  * View approved amount
  * View patient responsibility (copay/deductible)

**Dependencies**:
- FR-TR-BEN-004: Employee Enrollment

**Business Rules**:
- BR-TR-BEN-039: Claim must be for enrolled plan
- BR-TR-BEN-040: Service date within coverage period
- BR-TR-BEN-041: Procedure codes must be valid

**Related Entities**:
- HealthcareClaimHeader
- HealthcareClaimLine
- Enrollment

**API Endpoints**:
- `POST /api/v1/benefits/healthcare-claims`
- `GET /api/v1/benefits/healthcare-claims`
- `GET /api/v1/benefits/healthcare-claims/{id}`

---

#### FR-TR-BEN-013: Healthcare Claim Processing

**Priority**: LOW

**User Story**:
```
As a Benefits Administrator
I want to process healthcare claims
So that employees receive insurance reimbursements
```

**Description**:
The system shall process healthcare claims and track approval/payment status.

**Acceptance Criteria**:
- Given I am a Benefits Administrator
- When I review a healthcare claim
- Then I can:
  * View claim details and documents
  * Verify coverage and eligibility
  * Determine approved amount
  * Calculate patient responsibility
- And I can update claim status:
  * SUBMITTED → IN_REVIEW → APPROVED → PAID
  * Or SUBMITTED → IN_REVIEW → REJECTED
- And for APPROVED claims:
  * Enter approved amount
  * Enter patient copay/deductible
  * Process payment to provider or employee
- And for REJECTED claims:
  * Enter rejection reason
  * Notify employee
- And the system tracks:
  * Claim history
  * Payment status
  * Deductible accumulation

**Dependencies**:
- FR-TR-BEN-012: Healthcare Claim Submission

**Business Rules**:
- BR-TR-BEN-042: Approved amount <= charge amount
- BR-TR-BEN-043: Patient responsibility = charge - approved
- BR-TR-BEN-044: Deductible applies before coverage

**Related Entities**:
- HealthcareClaimHeader
- HealthcareClaimLine

**API Endpoints**:
- `GET /api/v1/benefits/healthcare-claims/pending-review`
- `POST /api/v1/benefits/healthcare-claims/{id}/approve`
- `POST /api/v1/benefits/healthcare-claims/{id}/reject`
- `POST /api/v1/benefits/healthcare-claims/{id}/pay`

---

#### FR-TR-BEN-014: Enrollment Reporting

**Priority**: MEDIUM

**User Story**:
```
As a Benefits Administrator
I want to generate enrollment reports
So that I can track participation and costs
```

**Description**:
The system shall provide comprehensive enrollment reporting and analytics.

**Acceptance Criteria**:
- Given I am a Benefits Administrator
- When I generate enrollment reports
- Then I can view:
  * Enrollment completion rate by department
  * Plan selection summary (by plan and option)
  * Dependent coverage analysis
  * Waiver analysis (reasons and trends)
  * Cost analysis (employee vs employer)
- And I can filter by:
  * Enrollment period
  * Legal entity
  * Department
  * Plan category
- And I can export:
  * Enrollment roster
  * Premium billing file
  * Carrier enrollment file (EDI 834)
- And reports show:
  * Total enrollments
  * Coverage tier distribution
  * Monthly/annual premium costs
  * Participation rates

**Dependencies**:
- FR-TR-BEN-004: Employee Enrollment

**Business Rules**:
- BR-TR-BEN-045: Reports reflect current active enrollments
- BR-TR-BEN-046: Cost calculations include all coverage tiers
- BR-TR-BEN-047: Carrier files follow EDI 834 format

**Related Entities**:
- Enrollment
- BenefitOption

**API Endpoints**:
- `GET /api/v1/benefits/reports/enrollment-summary`
- `GET /api/v1/benefits/reports/plan-selection`
- `GET /api/v1/benefits/reports/cost-analysis`
- `GET /api/v1/benefits/reports/export/carrier-file`

---

#### FR-TR-BEN-015: Premium Billing Reconciliation

**Priority**: MEDIUM

**User Story**:
```
As a Benefits Administrator
I want to reconcile premium billing with insurance carriers
So that I can ensure accurate payments
```

**Description**:
The system shall support monthly premium billing reconciliation with insurance providers.

**Acceptance Criteria**:
- Given I am a Benefits Administrator
- When I receive carrier invoice
- Then I can:
  * Import invoice data
  * Compare to system enrollment data
  * Identify discrepancies
- And the system shows:
  * System enrollment count by plan/option
  * Carrier invoice count by plan/option
  * Variance (system - carrier)
  * System premium total
  * Carrier invoice total
  * Variance amount
- And I can:
  * Drill down to employee-level differences
  * Identify missing enrollments
  * Identify extra charges
  * Export reconciliation report
- And I can resolve discrepancies:
  * Add missing enrollments to carrier
  * Remove terminated employees from carrier
  * Adjust effective dates
  * Request carrier corrections

**Dependencies**:
- FR-TR-BEN-004: Employee Enrollment

**Business Rules**:
- BR-TR-BEN-048: Reconciliation performed monthly
- BR-TR-BEN-049: Variance must be resolved before payment
- BR-TR-BEN-050: Effective date changes require carrier notification

**Related Entities**:
- Enrollment
- BenefitOption

**API Endpoints**:
- `POST /api/v1/benefits/billing/reconcile`
- `GET /api/v1/benefits/billing/reconciliation/{id}`
- `GET /api/v1/benefits/billing/discrepancies`

---

#### FR-TR-BEN-016: COBRA Administration

**Priority**: LOW

**User Story**:
```
As a Benefits Administrator
I want to manage COBRA continuation coverage
So that terminated employees can continue benefits
```

**Description**:
The system shall support COBRA administration for US employees (continuation coverage after termination).

**Acceptance Criteria**:
- Given I am a Benefits Administrator
- When an employee terminates
- Then the system:
  * Identifies COBRA-eligible enrollments (MEDICAL, DENTAL, VISION)
  * Generates COBRA notice (within 14 days)
  * Sends notice to employee
- And the employee can:
  * Elect COBRA continuation (within 60 days)
  * Select plans to continue
  * Pay premiums (102% of total cost)
- And the system:
  * Extends coverage (18-36 months based on qualifying event)
  * Tracks COBRA enrollment status
  * Generates monthly invoices
  * Processes payments
  * Terminates coverage for non-payment (30-day grace)
- And I can:
  * View COBRA participants
  * Track payment status
  * Generate COBRA reports

**Dependencies**:
- FR-TR-BEN-004: Employee Enrollment
- Core module: Employee termination events

**Business Rules**:
- BR-TR-BEN-051: COBRA notice within 14 days of termination
- BR-TR-BEN-052: Election period = 60 days from notice
- BR-TR-BEN-053: Premium = 102% of total cost
- BR-TR-BEN-054: Coverage duration: 18-36 months

**Related Entities**:
- Enrollment
- LifeEvent

**API Endpoints**:
- `POST /api/v1/benefits/cobra/generate-notice`
- `POST /api/v1/benefits/cobra/elect`
- `GET /api/v1/benefits/cobra/participants`
- `POST /api/v1/benefits/cobra/process-payment`

---

#### FR-TR-BEN-017: Benefit Statement Generation

**Priority**: LOW

**User Story**:
```
As an Employee
I want to view my benefits summary
So that I understand my total benefits package
```

**Description**:
The system shall generate benefit statements showing all enrolled plans and total value.

**Acceptance Criteria**:
- Given I am an Employee
- When I view my benefits
- Then I see:
  * All enrolled plans
  * Coverage options selected
  * Covered dependents
  * Employee premium cost
  * Employer premium cost
  * Total benefit value
- And I can:
  * Download as PDF
  * View historical statements
  * See coverage effective dates
- And the statement includes:
  * Medical/Dental/Vision coverage
  * Life insurance coverage amount
  * Retirement plan contributions
  * Wellness program participation
  * Total annual value

**Dependencies**:
- FR-TR-BEN-004: Employee Enrollment

**Business Rules**:
- BR-TR-BEN-055: Statement shows current active enrollments
- BR-TR-BEN-056: Total value = employee cost + employer cost
- BR-TR-BEN-057: Employer cost shown as benefit value

**Related Entities**:
- Enrollment
- BenefitOption

**API Endpoints**:
- `GET /api/v1/benefits/employees/{id}/statement`
- `GET /api/v1/benefits/employees/{id}/statement/pdf`

---

#### FR-TR-BEN-018: Eligibility Profile Management

**Priority**: HIGH

**User Story**:
```
As a Benefits Administrator
I want to create reusable eligibility profiles
So that I can standardize eligibility rules across multiple plans
```

**Description**:
The system shall allow Benefits Administrators to create and manage reusable eligibility profiles.

**Acceptance Criteria**:
- Given I am a Benefits Administrator
- When I create an eligibility profile
- Then I must provide:
  * Unique code (e.g., FULL_TIME_3M)
  * Name
  * Rule definition (JSON)
- And I can define rules:
  * Employment types
  * Min tenure months
  * Grades/job levels
  * Locations
  * Departments
  * Custom rules
- And I can:
  * Link profile to multiple plans
  * Update profile (affects all linked plans)
  * View plans using this profile
  * Preview membership (who is eligible)
- And the system validates:
  * Profile code uniqueness
  * Rule JSON is valid
  * No circular dependencies

**Dependencies**:
- See Eligibility Rules Guide

**Business Rules**:
- BR-TR-BEN-058: Profile code must be unique
- BR-TR-BEN-059: Updating profile affects all linked plans
- BR-TR-BEN-060: Eligibility evaluated at enrollment time

**Related Entities**:
- EligibilityProfile
- PlanEligibility
- BenefitPlan

**API Endpoints**:
- `POST /api/v1/benefits/eligibility-profiles`
- `GET /api/v1/benefits/eligibility-profiles`
- `GET /api/v1/benefits/eligibility-profiles/{id}`
- `PUT /api/v1/benefits/eligibility-profiles/{id}`
- `GET /api/v1/benefits/eligibility-profiles/{id}/preview`

---

#### FR-TR-BEN-019: Enrollment Change Tracking

**Priority**: MEDIUM

**User Story**:
```
As a Benefits Administrator
I want to track all enrollment changes
So that I can audit benefit elections and maintain compliance
```

**Description**:
The system shall maintain complete audit trail of all enrollment changes.

**Acceptance Criteria**:
- Given any enrollment change occurs
- When the change is saved
- Then the system creates audit record with:
  * Employee ID
  * Plan ID
  * Change type (NEW, CHANGE, TERMINATION, WAIVE)
  * Previous values
  * New values
  * Change reason
  * Effective date
  * Changed by (user ID)
  * Timestamp
- And I can query history by:
  * Employee
  * Plan
  * Date range
  * Change type
- And I can generate reports:
  * Enrollment changes by period
  * Life event-driven changes
  * Waiver trends
  * Dependent additions/removals

**Dependencies**:
- FR-TR-BEN-004: Employee Enrollment

**Business Rules**:
- BR-TR-BEN-061: Audit record for every change
- BR-TR-BEN-062: Audit records are immutable
- BR-TR-BEN-063: Retention period = 7 years

**Related Entities**:
- Enrollment
- LifeEvent

**API Endpoints**:
- `GET /api/v1/benefits/enrollments/{id}/history`
- `GET /api/v1/benefits/audit/enrollment-changes`
- `GET /api/v1/benefits/audit/reports`

---

#### FR-TR-BEN-020: Carrier File Export

**Priority**: MEDIUM

**User Story**:
```
As a Benefits Administrator
I want to export enrollment data to insurance carriers
So that carriers have accurate enrollment information
```

**Description**:
The system shall generate carrier enrollment files in EDI 834 format or custom CSV.

**Acceptance Criteria**:
- Given I am a Benefits Administrator
- When I export enrollment data
- Then I can specify:
  * Carrier/plan
  * Export period (month)
  * File format (EDI 834, CSV)
  * Change type (NEW, CHANGE, TERM, ALL)
- And the system generates file with:
  * Employee demographics
  * Coverage effective dates
  * Coverage tier
  * Dependent information
  * Premium amounts
- And the file includes:
  * New enrollments (adds)
  * Changes (coverage tier changes)
  * Terminations (removes)
- And I can:
  * Preview file before export
  * Download file
  * Send via SFTP (if configured)
  * Track export history

**Dependencies**:
- FR-TR-BEN-004: Employee Enrollment
- FR-TR-BEN-006: Dependent Management

**Business Rules**:
- BR-TR-BEN-064: EDI 834 format for US carriers
- BR-TR-BEN-065: CSV format for other carriers
- BR-TR-BEN-066: Monthly export cycle

**Related Entities**:
- Enrollment
- EmployeeDependent

**API Endpoints**:
- `POST /api/v1/benefits/carrier-files/generate`
- `GET /api/v1/benefits/carrier-files`
- `GET /api/v1/benefits/carrier-files/{id}/download`
- `POST /api/v1/benefits/carrier-files/{id}/send`

---

## Summary: Benefits

**Total Requirements**: 20  
**Priority Breakdown**:
- HIGH: 14 requirements
- MEDIUM: 4 requirements  
- LOW: 2 requirements

**Key Features**:
- Benefit plan and option setup
- Enrollment period management (open/new hire/life events)
- Employee enrollment and waivers
- Dependent and beneficiary management
- Reimbursements and healthcare claims
- Reporting and carrier integration
- COBRA administration
- Eligibility profile management

**Next Sub-Module**: Recognition (10 requirements)

---

*Document continues with remaining sub-modules...*

## 🎯 Feature Area 4: Recognition

### Overview

Recognition manages employee recognition programs including points-based rewards, awards, nominations, peer recognition, and redemption catalogs.

**Related Entities**: RecognitionProgram, RecognitionAward, RecognitionNomination, RecognitionTransaction, PointBalance, RedemptionCatalog, RedemptionItem, RedemptionOrder

**Related Concept Guide**: Recognition Programs Guide (to be created)

---

#### FR-TR-REC-001: Recognition Program Setup

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to create recognition programs
So that I can reward and motivate employees
```

**Description**:
The system shall allow HR Administrators to create recognition programs with points allocation rules and award criteria.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I create a recognition program
- Then I must provide:
  * Unique code (e.g., PEER_RECOGNITION_2025)
  * Name
  * Program type (PEER_TO_PEER, MANAGER_TO_EMPLOYEE, MILESTONE, PERFORMANCE, SPOT_AWARD)
  * Points currency name (e.g., "Stars", "Kudos")
  * Effective dates
- And I can configure:
  * Eligibility rules (who can give/receive)
  * Points allocation rules:
    - Max points per transaction
    - Max points per giver per month
    - Point value (e.g., 1 point = 1,000 VND)
  * Award categories
  * Approval required flag
- And the system validates:
  * Program code uniqueness
  * Valid program type
  * Points allocation rules are positive
- And I can activate/deactivate programs

**Dependencies**:
- None

**Business Rules**:
- BR-TR-REC-001: Program code must be unique
- BR-TR-REC-002: Points allocation limits prevent abuse
- BR-TR-REC-003: Approval required for high-value awards

**Related Entities**:
- RecognitionProgram

**API Endpoints**:
- `POST /api/v1/recognition/programs`
- `GET /api/v1/recognition/programs`
- `GET /api/v1/recognition/programs/{id}`
- `PUT /api/v1/recognition/programs/{id}`

---

#### FR-TR-REC-002: Award Definition

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to define recognition awards
So that employees can be recognized for specific achievements
```

**Description**:
The system shall allow HR Administrators to define recognition awards with criteria and point values.

**Acceptance Criteria**:
- Given I am an HR Administrator
- And I have created a recognition program
- When I define an award
- Then I must provide:
  * Award code (e.g., INNOVATION_AWARD)
  * Name
  * Description
  * Award category (INNOVATION, TEAMWORK, CUSTOMER_SERVICE, LEADERSHIP, VALUES, MILESTONE)
  * Point value
- And I can configure:
  * Eligibility criteria
  * Nomination required flag
  * Approval workflow
  * Frequency limit (e.g., once per quarter per employee)
  * Badge/icon
- And the system validates:
  * Award code unique within program
  * Point value within program limits
- And I can:
  * Activate/deactivate awards
  * View award history

**Dependencies**:
- FR-TR-REC-001: Recognition Program Setup

**Business Rules**:
- BR-TR-REC-004: Award code unique within program
- BR-TR-REC-005: Point value within program max
- BR-TR-REC-006: Frequency limits prevent duplicate awards

**Related Entities**:
- RecognitionAward
- RecognitionProgram

**API Endpoints**:
- `POST /api/v1/recognition/programs/{id}/awards`
- `GET /api/v1/recognition/programs/{id}/awards`
- `PUT /api/v1/recognition/awards/{id}`

---

#### FR-TR-REC-003: Peer Recognition

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to recognize my colleagues
So that I can appreciate their contributions
```

**Description**:
The system shall allow employees to give recognition to peers with points and messages.

**Acceptance Criteria**:
- Given I am an Employee
- And there is an active peer recognition program
- When I recognize a colleague
- Then I must provide:
  * Recipient employee ID
  * Award ID (from available awards)
  * Points to give (within my monthly limit)
  * Recognition message
  * Recognition reason/category
- And I can optionally:
  * Make recognition public or private
  * Tag with values (e.g., #Innovation, #Teamwork)
  * Upload photo/attachment
- And the system validates:
  * I have sufficient points to give
  * Recipient is eligible
  * Points within transaction limit
  * I haven't exceeded monthly limit
  * Cannot recognize myself
- And the system creates:
  * RecognitionTransaction (status = PENDING or APPROVED)
  * Deducts points from my balance (if applicable)
  * Adds points to recipient balance
- And the recipient receives:
  * Notification
  * Recognition badge
  * Points credit

**Dependencies**:
- FR-TR-REC-001: Recognition Program Setup
- FR-TR-REC-002: Award Definition

**Business Rules**:
- BR-TR-REC-007: Cannot recognize yourself
- BR-TR-REC-008: Points within monthly giver limit
- BR-TR-REC-009: Points within transaction limit
- BR-TR-REC-010: Public recognition visible to all

**Related Entities**:
- RecognitionTransaction
- PointBalance

**API Endpoints**:
- `POST /api/v1/recognition/give`
- `GET /api/v1/recognition/transactions`
- `GET /api/v1/recognition/my-points`

---

#### FR-TR-REC-004: Recognition Nomination

**Priority**: LOW

**User Story**:
```
As an Employee
I want to nominate colleagues for awards
So that exceptional contributions are recognized
```

**Description**:
The system shall allow employees to nominate colleagues for awards requiring approval.

**Acceptance Criteria**:
- Given I am an Employee
- And there is an award requiring nomination
- When I nominate a colleague
- Then I must provide:
  * Nominee employee ID
  * Award ID
  * Nomination reason (detailed justification)
  * Supporting evidence/examples
- And I can optionally:
  * Add co-nominators (multiple people nominating)
  * Upload supporting documents
- And the system creates:
  * RecognitionNomination (status = PENDING)
- And the nomination routes to:
  * Nominee's manager (for review)
  * HR/Awards committee (for approval)
- And approvers can:
  * Approve (creates RecognitionTransaction)
  * Reject (with reason)
  * Request more information
- And when approved:
  * Points awarded to nominee
  * Notification sent
  * Recognition published

**Dependencies**:
- FR-TR-REC-002: Award Definition

**Business Rules**:
- BR-TR-REC-011: Nomination requires detailed justification
- BR-TR-REC-012: Approval required for high-value awards
- BR-TR-REC-013: Cannot nominate yourself

**Related Entities**:
- RecognitionNomination
- RecognitionTransaction

**API Endpoints**:
- `POST /api/v1/recognition/nominations`
- `GET /api/v1/recognition/nominations`
- `POST /api/v1/recognition/nominations/{id}/approve`
- `POST /api/v1/recognition/nominations/{id}/reject`

---

#### FR-TR-REC-005: Point Balance Management

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to view my recognition points balance
So that I know how many points I have to give and redeem
```

**Description**:
The system shall track employee point balances for giving and receiving recognition.

**Acceptance Criteria**:
- Given I am an Employee
- When I view my points
- Then I see:
  * Total points received (lifetime)
  * Current redeemable balance
  * Points given this month
  * Monthly giving limit remaining
  * Points expiring soon (if applicable)
- And I can view:
  * Transaction history (received and given)
  * Recognition messages received
  * Badges/awards earned
- And the system tracks:
  * Points earned (from recognition received)
  * Points spent (from redemptions)
  * Points given (to others)
  * Points expired (if expiration policy exists)
- And I can filter history by:
  * Date range
  * Transaction type (earned, spent, given)
  * Award category

**Dependencies**:
- FR-TR-REC-003: Peer Recognition

**Business Rules**:
- BR-TR-REC-014: Balance = earned - spent - expired
- BR-TR-REC-015: Points may expire after 12 months (configurable)
- BR-TR-REC-016: Giving limit resets monthly

**Related Entities**:
- PointBalance
- RecognitionTransaction

**API Endpoints**:
- `GET /api/v1/recognition/employees/{id}/balance`
- `GET /api/v1/recognition/employees/{id}/transactions`
- `GET /api/v1/recognition/employees/{id}/badges`

---

#### FR-TR-REC-006: Redemption Catalog Management

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to manage redemption catalog
So that employees can redeem points for rewards
```

**Description**:
The system shall allow HR Administrators to manage redemption catalog with items and point costs.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I manage redemption catalog
- Then I can add items with:
  * Item code and name
  * Description
  * Category (GIFT_CARD, MERCHANDISE, EXPERIENCE, CHARITY, TIME_OFF, TRAINING)
  * Point cost
  * Monetary value (optional)
  * Stock quantity (if limited)
  * Image
  * Vendor/supplier info
- And I can configure:
  * Availability (active/inactive)
  * Eligibility rules (who can redeem)
  * Redemption limits (per employee per period)
  * Delivery method (DIGITAL, PHYSICAL, VOUCHER)
- And I can:
  * Update item details
  * Adjust point costs
  * Manage inventory
  * View redemption analytics
- And the system validates:
  * Item code uniqueness
  * Point cost is positive
  * Stock quantity tracked for limited items

**Dependencies**:
- None

**Business Rules**:
- BR-TR-REC-017: Item code must be unique
- BR-TR-REC-018: Point cost must be positive
- BR-TR-REC-019: Stock decrements on redemption

**Related Entities**:
- RedemptionCatalog
- RedemptionItem

**API Endpoints**:
- `POST /api/v1/recognition/catalog/items`
- `GET /api/v1/recognition/catalog/items`
- `PUT /api/v1/recognition/catalog/items/{id}`
- `DELETE /api/v1/recognition/catalog/items/{id}`

---

#### FR-TR-REC-007: Point Redemption

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to redeem my points for rewards
So that I can benefit from my recognition
```

**Description**:
The system shall allow employees to redeem points for catalog items.

**Acceptance Criteria**:
- Given I am an Employee
- And I have sufficient points
- When I redeem points
- Then I can:
  * Browse catalog items
  * Filter by category and point cost
  * View item details
  * Add items to cart
  * Checkout and confirm redemption
- And I must provide:
  * Delivery address (for physical items)
  * Contact information
- And the system validates:
  * I have sufficient points
  * Item is in stock (if limited)
  * I haven't exceeded redemption limits
- And the system creates:
  * RedemptionOrder (status = PENDING)
  * Deducts points from balance
  * Reserves stock (if applicable)
- And I receive:
  * Order confirmation
  * Delivery tracking (for physical items)
  * Digital code/voucher (for digital items)
- And the system processes:
  * Order fulfillment
  * Vendor notification
  * Delivery tracking

**Dependencies**:
- FR-TR-REC-005: Point Balance Management
- FR-TR-REC-006: Redemption Catalog Management

**Business Rules**:
- BR-TR-REC-020: Sufficient points required
- BR-TR-REC-021: Stock reserved on order creation
- BR-TR-REC-022: Points deducted immediately

**Related Entities**:
- RedemptionOrder
- PointBalance
- RedemptionItem

**API Endpoints**:
- `GET /api/v1/recognition/catalog/browse`
- `POST /api/v1/recognition/redemptions`
- `GET /api/v1/recognition/redemptions`
- `GET /api/v1/recognition/redemptions/{id}`

---

#### FR-TR-REC-008: Recognition Feed and Wall

**Priority**: LOW

**User Story**:
```
As an Employee
I want to view company-wide recognition feed
So that I can see who is being recognized and for what
```

**Description**:
The system shall provide a recognition feed showing public recognitions across the company.

**Acceptance Criteria**:
- Given I am an Employee
- When I view recognition feed
- Then I see:
  * Recent public recognitions
  * Giver and recipient names
  * Recognition message
  * Award/badge
  * Points given
  * Timestamp
  * Reactions/likes
- And I can:
  * Like/react to recognitions
  * Comment on recognitions
  * Filter by department/team
  * Filter by award category
  * Search by employee name
- And I can view:
  * Top recognized employees (leaderboard)
  * Most active givers
  * Trending awards
- And the feed shows:
  * Only public recognitions
  * Real-time updates
  * Pagination for older items

**Dependencies**:
- FR-TR-REC-003: Peer Recognition

**Business Rules**:
- BR-TR-REC-023: Only public recognitions shown
- BR-TR-REC-024: Private recognitions visible only to giver/recipient
- BR-TR-REC-025: Feed updates in real-time

**Related Entities**:
- RecognitionTransaction

**API Endpoints**:
- `GET /api/v1/recognition/feed`
- `POST /api/v1/recognition/transactions/{id}/like`
- `POST /api/v1/recognition/transactions/{id}/comment`
- `GET /api/v1/recognition/leaderboard`

---

#### FR-TR-REC-009: Recognition Analytics

**Priority**: LOW

**User Story**:
```
As an HR Administrator
I want to view recognition analytics
So that I can measure program effectiveness and engagement
```

**Description**:
The system shall provide analytics and reporting on recognition program usage and impact.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I view recognition analytics
- Then I see:
  * Total recognitions given (by period)
  * Total points distributed
  * Participation rate (% of employees giving/receiving)
  * Top givers and receivers
  * Recognition by department/team
  * Recognition by award category
  * Redemption rate (points redeemed vs earned)
  * Average points per recognition
- And I can:
  * Filter by date range
  * Filter by program/award
  * Filter by department/location
  * Export reports
  * View trends over time
- And I can analyze:
  * Engagement metrics
  * Program ROI
  * Award popularity
  * Redemption preferences

**Dependencies**:
- FR-TR-REC-003: Peer Recognition
- FR-TR-REC-007: Point Redemption

**Business Rules**:
- BR-TR-REC-026: Analytics updated daily
- BR-TR-REC-027: Participation rate = (active users / total employees) × 100
- BR-TR-REC-028: Redemption rate = (points redeemed / points earned) × 100

**Related Entities**:
- RecognitionTransaction
- RedemptionOrder
- PointBalance

**API Endpoints**:
- `GET /api/v1/recognition/analytics/overview`
- `GET /api/v1/recognition/analytics/participation`
- `GET /api/v1/recognition/analytics/trends`
- `GET /api/v1/recognition/analytics/export`

---

#### FR-TR-REC-010: Milestone Recognition

**Priority**: LOW

**User Story**:
```
As the System
I want to automatically recognize employee milestones
So that service anniversaries and achievements are celebrated
```

**Description**:
The system shall automatically recognize employee milestones (anniversaries, birthdays, achievements).

**Acceptance Criteria**:
- Given a recognition program with milestone awards
- When an employee reaches a milestone
- Then the system automatically:
  * Detects milestone (work anniversary, birthday, achievement)
  * Creates recognition transaction
  * Awards points
  * Sends notification to employee
  * Posts to recognition feed (if public)
- And milestones include:
  * Work anniversaries (1, 3, 5, 10, 15, 20+ years)
  * Birthdays
  * Certification achievements
  * Project completions
- And I can configure:
  * Milestone types to recognize
  * Point awards per milestone
  * Notification templates
  * Public vs private
- And the system:
  * Runs daily milestone check
  * Sends manager notification (to congratulate)
  * Tracks milestone history

**Dependencies**:
- FR-TR-REC-001: Recognition Program Setup
- Core module: Employee hire date, birthday

**Business Rules**:
- BR-TR-REC-029: Milestones detected daily
- BR-TR-REC-030: Points awarded automatically
- BR-TR-REC-031: Manager notified to congratulate

**Related Entities**:
- RecognitionTransaction
- RecognitionAward

**API Endpoints**:
- `POST /api/v1/recognition/milestones/configure`
- `GET /api/v1/recognition/milestones/upcoming`
- `POST /api/v1/recognition/milestones/process`

---

## Summary: Recognition

**Total Requirements**: 10  
**Priority Breakdown**:
- HIGH: 0 requirements
- MEDIUM: 6 requirements  
- LOW: 4 requirements

**Key Features**:
- Recognition programs and awards
- Peer-to-peer recognition
- Nominations and approvals
- Point balance tracking
- Redemption catalog and orders
- Recognition feed and analytics
- Milestone auto-recognition

---

## 🎯 Feature Area 5: Offer Management

### Overview

Offer Management handles job offer creation, approval, acceptance, and integration with onboarding. This includes offer templates, compensation packages, offer letters, e-signatures, and candidate communication.

**Related Entities**: OfferTemplate, OfferPackage, OfferComponent, OfferApproval, OfferAcceptance, OfferLetter

**Related Concept Guide**: Offer Management Guide (to be created)

---

#### FR-TR-OFFER-001: Offer Template Management

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want to create offer templates
So that I can standardize offer packages by role and level
```

**Description**:
The system shall allow HR Administrators to create offer templates with predefined compensation components.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I create an offer template
- Then I must provide:
  * Unique code (e.g., ENGINEER_L4_VN)
  * Name
  * Job family/role
  * Job level/grade
  * Location/legal entity
  * Employment type (FULL_TIME, PART_TIME, CONTRACT)
- And I can configure:
  * Salary basis
  * Compensation components:
    - Base salary (range: min-max)
    - Allowances (housing, transport, meal)
    - Signing bonus
    - Annual bonus target %
    - Equity grant (RSU/Options)
  * Benefits package
  * Probation period
  * Notice period
  * Start date flexibility
- And the system validates:
  * Template code uniqueness
  * Salary range (min < max)
  * Components align with grade pay range
- And I can:
  * Clone templates
  * Version templates
  * Activate/deactivate

**Dependencies**:
- FR-TR-COMP-001: Salary Basis
- FR-TR-COMP-002: Pay Components
- FR-TR-COMP-003: Grade Structure

**Business Rules**:
- BR-TR-OFFER-001: Template code must be unique
- BR-TR-OFFER-002: Salary range within grade pay range
- BR-TR-OFFER-003: Components must be active

**Related Entities**:
- OfferTemplate

**API Endpoints**:
- `POST /api/v1/offers/templates`
- `GET /api/v1/offers/templates`
- `GET /api/v1/offers/templates/{id}`
- `PUT /api/v1/offers/templates/{id}`
- `POST /api/v1/offers/templates/{id}/clone`

---

#### FR-TR-OFFER-002: Offer Package Creation

**Priority**: HIGH

**User Story**:
```
As a Hiring Manager
I want to create job offers for candidates
So that I can extend employment offers with competitive packages
```

**Description**:
The system shall allow Hiring Managers to create offer packages for candidates using templates.

**Acceptance Criteria**:
- Given I am a Hiring Manager
- And I have a candidate to hire
- When I create an offer
- Then I must provide:
  * Candidate ID (from ATS/Recruiting)
  * Job requisition ID
  * Template ID (or create custom)
  * Proposed start date
- And I can customize:
  * Base salary (within template range)
  * Each compensation component
  * Signing bonus amount
  * Equity grant units
  * Benefits selections
  * Probation period
  * Special terms/conditions
- And the system:
  * Validates salary within range
  * Calculates total compensation
  * Shows compa-ratio
  * Determines approval routing
- And I can:
  * Save as DRAFT
  * Preview offer letter
  * Submit for approval (status = PENDING)
- And the system creates:
  * OfferPackage record
  * OfferComponent records for each component
  * Approval workflow

**Dependencies**:
- FR-TR-OFFER-001: Offer Template Management
- Recruiting/ATS module: Candidate data

**Business Rules**:
- BR-TR-OFFER-004: Salary within template range (or requires exception approval)
- BR-TR-OFFER-005: Total comp calculated automatically
- BR-TR-OFFER-006: Approval routing based on offer value

**Related Entities**:
- OfferPackage
- OfferComponent
- OfferTemplate

**API Endpoints**:
- `POST /api/v1/offers/packages`
- `GET /api/v1/offers/packages`
- `GET /api/v1/offers/packages/{id}`
- `PUT /api/v1/offers/packages/{id}`
- `POST /api/v1/offers/packages/{id}/submit`

---

#### FR-TR-OFFER-003: Offer Approval Workflow

**Priority**: HIGH

**User Story**:
```
As a Director/VP
I want to review and approve job offers
So that I can ensure competitive and equitable compensation
```

**Description**:
The system shall route offers for approval based on offer value and organizational hierarchy.

**Acceptance Criteria**:
- Given I am an Approver
- When offers are submitted
- Then the system routes to me based on:
  * Total compensation value thresholds
  * Organizational hierarchy
  * Exception flags (out-of-range salary)
- And I can view:
  * Candidate information
  * Job details
  * Offer package details
  * Total compensation breakdown
  * Compa-ratio
  * Budget impact
  * Market comparison
- And I can:
  * Approve (status → APPROVED)
  * Reject (status → REJECTED, requires reason)
  * Request changes (status → DRAFT, with comments)
- And when I approve:
  * Next approver notified (if multi-level)
  * Hiring manager notified
- And when all approvals complete:
  * Offer status → APPROVED
  * Ready for offer letter generation

**Dependencies**:
- FR-TR-OFFER-002: Offer Package Creation

**Business Rules**:
- BR-TR-OFFER-007: Approval routing per threshold configuration
- BR-TR-OFFER-008: Out-of-range offers require exception approval
- BR-TR-OFFER-009: All required approvals must be obtained

**Related Entities**:
- OfferPackage
- OfferApproval

**API Endpoints**:
- `GET /api/v1/offers/packages/pending-approval`
- `POST /api/v1/offers/packages/{id}/approve`
- `POST /api/v1/offers/packages/{id}/reject`
- `POST /api/v1/offers/packages/{id}/request-changes`

---

#### FR-TR-OFFER-004: Offer Letter Generation

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want to generate offer letters
So that I can send formal employment offers to candidates
```

**Description**:
The system shall generate offer letters from approved offer packages using templates.

**Acceptance Criteria**:
- Given I am an HR Administrator
- And an offer is APPROVED
- When I generate offer letter
- Then the system:
  * Selects appropriate letter template (by country/role)
  * Populates candidate information
  * Populates job details
  * Populates compensation breakdown
  * Populates benefits summary
  * Populates terms and conditions
  * Generates PDF document
- And the letter includes:
  * Job title and department
  * Reporting manager
  * Start date
  * Work location
  * Employment type
  * Base salary and frequency
  * All allowances and bonuses
  * Equity grant details (if applicable)
  * Benefits overview
  * Probation period
  * Notice period
  * Acceptance deadline
  * E-signature section
- And I can:
  * Preview letter
  * Edit custom sections
  * Regenerate if needed
  * Send to candidate

**Dependencies**:
- FR-TR-OFFER-003: Offer Approval Workflow

**Business Rules**:
- BR-TR-OFFER-010: Letter template by country/legal entity
- BR-TR-OFFER-011: All compensation components listed
- BR-TR-OFFER-012: Acceptance deadline typically 7-14 days

**Related Entities**:
- OfferLetter
- OfferPackage

**API Endpoints**:
- `POST /api/v1/offers/packages/{id}/generate-letter`
- `GET /api/v1/offers/letters/{id}`
- `GET /api/v1/offers/letters/{id}/pdf`
- `POST /api/v1/offers/letters/{id}/send`

---

#### FR-TR-OFFER-005: Offer Delivery and Tracking

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want to send offers to candidates and track status
So that I can manage the offer process efficiently
```

**Description**:
The system shall send offer letters to candidates via email with e-signature capability and track status.

**Acceptance Criteria**:
- Given I am an HR Administrator
- And an offer letter is generated
- When I send the offer
- Then the system:
  * Sends email to candidate with:
    - Offer letter PDF attachment
    - E-signature link
    - Acceptance deadline
    - Contact information
  * Creates tracking record (status = SENT)
  * Sets expiry date
- And the candidate receives:
  * Email notification
  * Secure link to view/sign offer
  * Offer letter PDF
- And I can track:
  * Sent date/time
  * Viewed date/time (when candidate opens)
  * Signed date/time (when accepted)
  * Status (SENT, VIEWED, ACCEPTED, DECLINED, EXPIRED)
- And the system sends reminders:
  * 3 days before deadline
  * 1 day before deadline
- And I can:
  * Resend offer
  * Extend deadline
  * Withdraw offer

**Dependencies**:
- FR-TR-OFFER-004: Offer Letter Generation
- E-signature service integration

**Business Rules**:
- BR-TR-OFFER-013: Offer expires after deadline
- BR-TR-OFFER-014: Reminders sent automatically
- BR-TR-OFFER-015: Candidate can view unlimited times

**Related Entities**:
- OfferLetter
- OfferPackage

**API Endpoints**:
- `POST /api/v1/offers/letters/{id}/send`
- `GET /api/v1/offers/letters/{id}/status`
- `POST /api/v1/offers/letters/{id}/resend`
- `POST /api/v1/offers/letters/{id}/extend`
- `POST /api/v1/offers/letters/{id}/withdraw`

---

#### FR-TR-OFFER-006: Offer Acceptance

**Priority**: HIGH

**User Story**:
```
As a Candidate
I want to review and accept job offers
So that I can confirm my employment
```

**Description**:
The system shall allow candidates to review and accept offers via e-signature.

**Acceptance Criteria**:
- Given I am a Candidate
- And I received an offer
- When I access the offer link
- Then I can:
  * View offer letter
  * Review compensation details
  * Review benefits information
  * Download PDF
- And to accept, I must:
  * Review all sections
  * Provide e-signature
  * Confirm start date
  * Provide additional information (if required):
    - Emergency contact
    - Bank account (for payroll)
    - Tax information
- And the system:
  * Validates signature
  * Creates OfferAcceptance record
  * Updates offer status: SENT → ACCEPTED
  * Sends confirmation email
  * Notifies hiring manager and HR
- And I can also:
  * Decline offer (with optional reason)
  * Request clarification (sends message to HR)

**Dependencies**:
- FR-TR-OFFER-005: Offer Delivery
- E-signature service

**Business Rules**:
- BR-TR-OFFER-016: E-signature required for acceptance
- BR-TR-OFFER-017: Acceptance before deadline
- BR-TR-OFFER-018: Cannot accept after expiry

**Related Entities**:
- OfferAcceptance
- OfferLetter

**API Endpoints**:
- `GET /api/v1/offers/candidate/{token}` (public, tokenized)
- `POST /api/v1/offers/candidate/{token}/accept`
- `POST /api/v1/offers/candidate/{token}/decline`
- `POST /api/v1/offers/candidate/{token}/request-info`

---

#### FR-TR-OFFER-007: Offer Decline Handling

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to track offer declines and reasons
So that I can improve our offer competitiveness
```

**Description**:
The system shall track offer declines with reasons and enable analysis.

**Acceptance Criteria**:
- Given a candidate declines an offer
- When the decline is recorded
- Then the system:
  * Updates offer status: SENT → DECLINED
  * Records decline date
  * Records decline reason (if provided):
    - Compensation too low
    - Accepted another offer
    - Location/relocation
    - Role not suitable
    - Personal reasons
    - Other
  * Records detailed feedback (optional)
  * Notifies hiring manager and HR
- And I can:
  * View decline reasons
  * Analyze decline trends
  * Generate decline reports
  * Compare declined offers vs accepted
- And I can identify:
  * Common decline reasons
  * Compensation gaps
  * Competitive intelligence

**Dependencies**:
- FR-TR-OFFER-006: Offer Acceptance

**Business Rules**:
- BR-TR-OFFER-019: Decline reason categorized
- BR-TR-OFFER-020: Feedback optional but encouraged
- BR-TR-OFFER-021: Decline data used for analytics

**Related Entities**:
- OfferPackage
- OfferAcceptance

**API Endpoints**:
- `GET /api/v1/offers/declines`
- `GET /api/v1/offers/decline-analytics`
- `GET /api/v1/offers/decline-reports`

---

#### FR-TR-OFFER-008: Offer Expiry Management

**Priority**: MEDIUM

**User Story**:
```
As the System
I want to automatically expire offers after deadline
So that offers don't remain open indefinitely
```

**Description**:
The system shall automatically expire offers that are not accepted by the deadline.

**Acceptance Criteria**:
- Given an offer with acceptance deadline
- When the deadline passes
- And the offer is not accepted
- Then the system automatically:
  * Updates offer status: SENT → EXPIRED
  * Records expiry date
  * Sends notification to HR and hiring manager
  * Prevents candidate from accepting
- And HR can:
  * View expired offers
  * Extend deadline (reactivates offer)
  * Create new offer for same candidate
- And the system:
  * Runs daily expiry check
  * Processes all expired offers
  * Generates expiry report

**Dependencies**:
- FR-TR-OFFER-005: Offer Delivery

**Business Rules**:
- BR-TR-OFFER-022: Offers expire at deadline
- BR-TR-OFFER-023: Expired offers cannot be accepted
- BR-TR-OFFER-024: Extension requires HR approval

**Related Entities**:
- OfferPackage
- OfferLetter

**API Endpoints**:
- `POST /api/v1/offers/process-expiries`
- `GET /api/v1/offers/expired`
- `POST /api/v1/offers/packages/{id}/extend-deadline`

---

#### FR-TR-OFFER-009: Onboarding Integration

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want accepted offers to trigger onboarding
So that new hires are set up automatically
```

**Description**:
The system shall integrate with onboarding to create employee records from accepted offers.

**Acceptance Criteria**:
- Given an offer is accepted
- When I trigger onboarding
- Then the system:
  * Creates employee record in Core HRIS
  * Sets up compensation:
    - Creates EmployeeCompensationSnapshot
    - Links to salary basis and components
    - Sets effective date = start date
  * Enrolls in benefits (if applicable):
    - Creates new hire enrollment period
    - Auto-enrolls in default plans
  * Creates equity grants (if applicable)
  * Assigns to manager and department
  * Triggers onboarding workflow
- And the system transfers:
  * Personal information
  * Job details
  * Compensation package
  * Start date
  * Manager assignment
- And I can:
  * Preview employee record before creation
  * Make adjustments if needed
  * Complete onboarding setup

**Dependencies**:
- FR-TR-OFFER-006: Offer Acceptance
- Core HRIS: Employee management
- FR-TR-COMP-008: Compensation snapshots
- FR-TR-BEN-004: Benefits enrollment

**Business Rules**:
- BR-TR-OFFER-025: Employee created on start date
- BR-TR-OFFER-026: Compensation effective from start date
- BR-TR-OFFER-027: New hire enrollment period = 30 days

**Related Entities**:
- OfferPackage
- Core.Employee
- EmployeeCompensationSnapshot
- Enrollment

**API Endpoints**:
- `POST /api/v1/offers/packages/{id}/create-employee`
- `GET /api/v1/offers/packages/{id}/preview-employee`

---

#### FR-TR-OFFER-010: Offer Analytics and Reporting

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to view offer analytics
So that I can measure time-to-hire and offer competitiveness
```

**Description**:
The system shall provide analytics on offer process metrics and outcomes.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I view offer analytics
- Then I see:
  * Total offers made (by period)
  * Acceptance rate %
  * Decline rate %
  * Expiry rate %
  * Average time to accept (days)
  * Average offer value (by role/level)
  * Offer value distribution
  * Decline reasons breakdown
- And I can filter by:
  * Date range
  * Department
  * Job family/role
  * Location
  * Hiring manager
- And I can analyze:
  * Acceptance rate trends
  * Competitive positioning
  * Offer approval cycle time
  * Salary offer vs market
- And I can export:
  * Offer summary reports
  * Detailed offer data
  * Decline analysis

**Dependencies**:
- FR-TR-OFFER-002: Offer Package Creation
- FR-TR-OFFER-006: Offer Acceptance
- FR-TR-OFFER-007: Offer Decline

**Business Rules**:
- BR-TR-OFFER-028: Acceptance rate = (accepted / total) × 100
- BR-TR-OFFER-029: Time to accept = accept date - send date
- BR-TR-OFFER-030: Analytics updated daily

**Related Entities**:
- OfferPackage
- OfferAcceptance

**API Endpoints**:
- `GET /api/v1/offers/analytics/overview`
- `GET /api/v1/offers/analytics/acceptance-rate`
- `GET /api/v1/offers/analytics/decline-reasons`
- `GET /api/v1/offers/analytics/export`

---

#### FR-TR-OFFER-011: Offer Withdrawal

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to withdraw offers
So that I can cancel offers if circumstances change
```

**Description**:
The system shall allow HR to withdraw offers before acceptance.

**Acceptance Criteria**:
- Given I am an HR Administrator
- And an offer is SENT (not yet accepted)
- When I withdraw the offer
- Then I must provide:
  * Withdrawal reason
  * Notification to candidate (Yes/No)
- And the system:
  * Updates offer status: SENT → WITHDRAWN
  * Records withdrawal date and reason
  * Sends notification to candidate (if selected)
  * Notifies hiring manager
  * Prevents candidate from accepting
- And I can:
  * View withdrawn offers
  * Generate withdrawal reports
- And the system validates:
  * Offer not already accepted
  * Offer not already withdrawn

**Dependencies**:
- FR-TR-OFFER-005: Offer Delivery

**Business Rules**:
- BR-TR-OFFER-031: Cannot withdraw accepted offers
- BR-TR-OFFER-032: Withdrawal reason required
- BR-TR-OFFER-033: Candidate notification recommended

**Related Entities**:
- OfferPackage
- OfferLetter

**API Endpoints**:
- `POST /api/v1/offers/packages/{id}/withdraw`
- `GET /api/v1/offers/withdrawn`

---

#### FR-TR-OFFER-012: Offer Comparison Tool

**Priority**: LOW

**User Story**:
```
As a Hiring Manager
I want to compare multiple offer scenarios
So that I can make competitive offers within budget
```

**Description**:
The system shall provide tools to compare multiple offer scenarios side-by-side.

**Acceptance Criteria**:
- Given I am a Hiring Manager
- When I create offer scenarios
- Then I can:
  * Create multiple scenarios for same candidate
  * Adjust compensation components
  * Compare total compensation
  * Compare to market data
  * Compare to budget
- And I can view side-by-side:
  * Base salary
  * Total cash compensation
  * Total compensation (including equity)
  * Compa-ratio
  * Budget impact
  * Market positioning
- And I can:
  * Save scenarios
  * Share with approvers
  * Select scenario to convert to offer
- And the system shows:
  * Scenario comparison table
  * Visual charts
  * Recommendations

**Dependencies**:
- FR-TR-OFFER-002: Offer Package Creation

**Business Rules**:
- BR-TR-OFFER-034: Scenarios are drafts until selected
- BR-TR-OFFER-035: Only one scenario becomes actual offer
- BR-TR-OFFER-036: Scenarios help decision-making

**Related Entities**:
- OfferPackage

**API Endpoints**:
- `POST /api/v1/offers/scenarios`
- `GET /api/v1/offers/scenarios/compare`
- `POST /api/v1/offers/scenarios/{id}/convert-to-offer`

---

## Summary: Offer Management

**Total Requirements**: 12  
**Priority Breakdown**:
- HIGH: 8 requirements
- MEDIUM: 3 requirements  
- LOW: 1 requirement

**Key Features**:
- Offer templates and packages
- Offer approval workflows
- Offer letter generation and delivery
- E-signature and acceptance
- Decline tracking and analytics
- Onboarding integration
- Offer comparison tools

**Progress**: 75/131 FRs complete (57%)

**Next Sub-Modules**: TR Statement, Deductions, Tax Withholding, Taxable Bridge, Audit, Calculation Rules (56 FRs remaining)

---

*Document continues with remaining sub-modules...*

## 🎯 Feature Area 6: TR Statement

### Overview

TR Statement manages total rewards statements that communicate the full value of employee compensation and benefits packages. This includes statement generation, personalization, delivery, and analytics.

**Related Entities**: TRStatement, TRStatementSection, TRStatementDelivery

**Related Concept Guide**: TR Statement Guide (to be created)

---

#### FR-TR-STMT-001: TR Statement Template Management

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to create TR statement templates
So that I can communicate total rewards value to employees
```

**Description**:
The system shall allow HR Administrators to create and manage TR statement templates with customizable sections and branding.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I create a TR statement template
- Then I must provide:
  * Unique code (e.g., ANNUAL_TR_STMT_2025)
  * Name
  * Template type (ANNUAL, QUARTERLY, ON_DEMAND, NEW_HIRE)
  * Effective period
- And I can configure sections:
  * Base Compensation (salary, allowances)
  * Variable Pay (bonuses, equity, commissions)
  * Benefits (health, retirement, wellness)
  * Perks and Recognition
  * Professional Development
  * Total Rewards Value
- And I can customize:
  * Company branding (logo, colors)
  * Section order and visibility
  * Calculation methods
  * Messaging and descriptions
  * Charts and visualizations
- And the system validates:
  * Template code uniqueness
  * At least one section included
  * Valid calculation formulas
- And I can:
  * Preview template
  * Clone templates
  * Activate/deactivate

**Dependencies**:
- None

**Business Rules**:
- BR-TR-STMT-001: Template code must be unique
- BR-TR-STMT-002: Annual statements typically generated yearly
- BR-TR-STMT-003: Sections customizable per company needs

**Related Entities**:
- TRStatement (template)
- TRStatementSection

**API Endpoints**:
- `POST /api/v1/tr-statements/templates`
- `GET /api/v1/tr-statements/templates`
- `GET /api/v1/tr-statements/templates/{id}`
- `PUT /api/v1/tr-statements/templates/{id}`
- `POST /api/v1/tr-statements/templates/{id}/preview`

---

#### FR-TR-STMT-002: TR Statement Generation

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to generate TR statements for employees
So that they understand their total compensation value
```

**Description**:
The system shall generate personalized TR statements for employees based on templates and actual data.

**Acceptance Criteria**:
- Given I am an HR Administrator
- And I have a TR statement template
- When I generate statements
- Then I can specify:
  * Template to use
  * Target employees (all, department, specific list)
  * Statement period (e.g., 2025)
  * Generation date
- And the system:
  * Retrieves employee data for period
  * Calculates compensation components
  * Calculates benefits value
  * Calculates total rewards value
  * Generates PDF for each employee
- And each statement includes:
  * Employee name and details
  * Base compensation breakdown
  * Variable pay summary (bonuses, equity value)
  * Benefits value (employer contributions)
  * Total rewards value
  * Year-over-year comparison
  * Personalized message
- And I can:
  * Preview sample statements
  * Regenerate if needed
  * Batch generate for all employees
- And the system tracks:
  * Generation status
  * Errors/warnings
  * Completion percentage

**Dependencies**:
- FR-TR-STMT-001: TR Statement Template Management
- FR-TR-COMP-012: Salary History
- FR-TR-VAR-003: Bonus Allocations
- FR-TR-BEN-004: Benefit Enrollments

**Business Rules**:
- BR-TR-STMT-004: Statement data from actual records
- BR-TR-STMT-005: Benefits value = employer contributions
- BR-TR-STMT-006: Equity value at current FMV

**Related Entities**:
- TRStatement
- TRStatementSection

**API Endpoints**:
- `POST /api/v1/tr-statements/generate`
- `GET /api/v1/tr-statements/generation/{id}/status`
- `GET /api/v1/tr-statements`
- `GET /api/v1/tr-statements/{id}`

---

#### FR-TR-STMT-003: Statement Personalization

**Priority**: LOW

**User Story**:
```
As an HR Administrator
I want to personalize TR statements
So that employees receive relevant and engaging communications
```

**Description**:
The system shall support personalization of TR statements based on employee attributes and preferences.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I configure statement personalization
- Then I can:
  * Add personalized greeting (using employee name)
  * Include manager message
  * Customize sections by employee group:
    - Executives see equity details
    - Sales see commission details
    - All employees see base + benefits
  * Add conditional content:
    - Show equity only if employee has grants
    - Show commission only if sales role
    - Highlight changes from previous year
  * Include company-specific messaging
- And I can use variables:
  * {employee_name}
  * {manager_name}
  * {department}
  * {total_rewards_value}
  * {year_over_year_change}
- And the system:
  * Replaces variables with actual data
  * Shows/hides sections based on rules
  * Applies personalization during generation

**Dependencies**:
- FR-TR-STMT-002: TR Statement Generation

**Business Rules**:
- BR-TR-STMT-007: Personalization rules evaluated per employee
- BR-TR-STMT-008: Variables replaced with actual data
- BR-TR-STMT-009: Sections hidden if no data

**Related Entities**:
- TRStatement
- TRStatementSection

**API Endpoints**:
- `POST /api/v1/tr-statements/templates/{id}/personalization`
- `GET /api/v1/tr-statements/templates/{id}/personalization`

---

#### FR-TR-STMT-004: Statement Delivery

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to deliver TR statements to employees
So that they can access their total rewards information
```

**Description**:
The system shall deliver TR statements to employees via email and employee portal.

**Acceptance Criteria**:
- Given I am an HR Administrator
- And TR statements are generated
- When I deliver statements
- Then I can choose delivery method:
  * Email with PDF attachment
  * Email with portal link
  * Portal only (no email)
- And for email delivery:
  * System sends personalized email
  * Includes PDF attachment (password protected)
  * Includes link to view in portal
  * Tracks email delivery status
- And for portal delivery:
  * Statement available in employee self-service
  * Notification sent to employee
  * Employee can view online
  * Employee can download PDF
- And I can:
  * Schedule delivery date/time
  * Send test emails
  * Resend to specific employees
  * Track delivery status
- And the system tracks:
  * Sent date/time
  * Viewed date/time
  * Downloaded date/time
  * Delivery failures

**Dependencies**:
- FR-TR-STMT-002: TR Statement Generation
- Email service
- Employee self-service portal

**Business Rules**:
- BR-TR-STMT-010: PDF password = employee ID or custom
- BR-TR-STMT-011: Statements retained for 7 years
- BR-TR-STMT-012: Delivery tracking for compliance

**Related Entities**:
- TRStatement
- TRStatementDelivery

**API Endpoints**:
- `POST /api/v1/tr-statements/deliver`
- `GET /api/v1/tr-statements/delivery/{id}/status`
- `POST /api/v1/tr-statements/{id}/resend`

---

#### FR-TR-STMT-005: Employee Statement Access

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to view my TR statement
So that I understand my total compensation package
```

**Description**:
The system shall allow employees to view and download their TR statements via self-service portal.

**Acceptance Criteria**:
- Given I am an Employee
- When I access my TR statements
- Then I can:
  * View current year statement
  * View historical statements (past years)
  * Download PDF
  * Print statement
- And I see:
  * Total rewards value
  * Compensation breakdown
  * Benefits value
  * Year-over-year comparison
  * Interactive charts
- And I can:
  * Compare years side-by-side
  * View detailed breakdowns
  * Understand calculation methods
  * Access FAQs and explanations
- And the system:
  * Logs access for audit
  * Tracks views and downloads
  * Provides mobile-friendly view

**Dependencies**:
- FR-TR-STMT-004: Statement Delivery
- Employee self-service portal

**Business Rules**:
- BR-TR-STMT-013: Employees see only their own statements
- BR-TR-STMT-014: Historical statements available for 7 years
- BR-TR-STMT-015: Access logged for audit

**Related Entities**:
- TRStatement

**API Endpoints**:
- `GET /api/v1/tr-statements/employees/{id}/current`
- `GET /api/v1/tr-statements/employees/{id}/history`
- `GET /api/v1/tr-statements/{id}/pdf`

---

#### FR-TR-STMT-006: Statement Comparison

**Priority**: LOW

**User Story**:
```
As an Employee
I want to compare my TR statements across years
So that I can see how my compensation has grown
```

**Description**:
The system shall provide year-over-year comparison of TR statements.

**Acceptance Criteria**:
- Given I am an Employee
- And I have statements for multiple years
- When I compare statements
- Then I see side-by-side:
  * Base compensation (current vs previous)
  * Variable pay (current vs previous)
  * Benefits value (current vs previous)
  * Total rewards (current vs previous)
  * Change amount and percentage
- And I can view:
  * Visual charts showing growth
  * Detailed breakdown by component
  * Highlights of changes
- And the system shows:
  * Positive changes in green
  * Negative changes in red
  * Percentage increase/decrease
  * Reasons for changes (if available)

**Dependencies**:
- FR-TR-STMT-005: Employee Statement Access

**Business Rules**:
- BR-TR-STMT-016: Comparison requires 2+ years of data
- BR-TR-STMT-017: Changes calculated automatically
- BR-TR-STMT-018: Percentage = (current - previous) / previous × 100

**Related Entities**:
- TRStatement

**API Endpoints**:
- `GET /api/v1/tr-statements/employees/{id}/compare`

---

#### FR-TR-STMT-007: Statement Analytics

**Priority**: LOW

**User Story**:
```
As an HR Administrator
I want to view TR statement analytics
So that I can measure employee engagement and understanding
```

**Description**:
The system shall provide analytics on TR statement delivery and employee engagement.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I view statement analytics
- Then I see:
  * Total statements generated
  * Delivery success rate
  * Email open rate
  * Portal view rate
  * Download rate
  * Average time to first view
  * Engagement by department
- And I can:
  * Filter by period
  * Filter by department
  * Export analytics
  * View trends over time
- And I can analyze:
  * Which sections are most viewed
  * Employee feedback (if collected)
  * Statement effectiveness
  * Communication impact

**Dependencies**:
- FR-TR-STMT-004: Statement Delivery
- FR-TR-STMT-005: Employee Statement Access

**Business Rules**:
- BR-TR-STMT-019: Analytics updated daily
- BR-TR-STMT-020: View rate = (views / delivered) × 100
- BR-TR-STMT-021: Engagement metrics track employee understanding

**Related Entities**:
- TRStatement
- TRStatementDelivery

**API Endpoints**:
- `GET /api/v1/tr-statements/analytics/overview`
- `GET /api/v1/tr-statements/analytics/engagement`
- `GET /api/v1/tr-statements/analytics/export`

---

#### FR-TR-STMT-008: Statement Approval Workflow

**Priority**: LOW

**User Story**:
```
As an HR Administrator
I want to review statements before delivery
So that I can ensure accuracy and quality
```

**Description**:
The system shall support approval workflow for TR statements before delivery.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I generate statements
- Then I can:
  * Submit for review (status = PENDING_REVIEW)
  * Assign reviewers
  * Set review deadline
- And reviewers can:
  * Preview sample statements
  * Review calculations
  * Check data accuracy
  * Approve (status = APPROVED)
  * Reject (status = REJECTED, with comments)
  * Request changes
- And when approved:
  * Statements ready for delivery
  * Delivery can be scheduled
- And when rejected:
  * Generator notified
  * Statements must be regenerated
- And the system tracks:
  * Review status
  * Reviewer comments
  * Approval history

**Dependencies**:
- FR-TR-STMT-002: TR Statement Generation

**Business Rules**:
- BR-TR-STMT-022: Approval required before delivery
- BR-TR-STMT-023: Multiple reviewers supported
- BR-TR-STMT-024: All reviewers must approve

**Related Entities**:
- TRStatement

**API Endpoints**:
- `POST /api/v1/tr-statements/generation/{id}/submit-review`
- `GET /api/v1/tr-statements/pending-review`
- `POST /api/v1/tr-statements/generation/{id}/approve`
- `POST /api/v1/tr-statements/generation/{id}/reject`

---

## Summary: TR Statement

**Total Requirements**: 8  
**Priority Breakdown**:
- HIGH: 0 requirements
- MEDIUM: 5 requirements  
- LOW: 3 requirements

**Key Features**:
- Statement template management
- Personalized statement generation
- Multi-channel delivery (email, portal)
- Employee self-service access
- Year-over-year comparison
- Analytics and engagement tracking
- Approval workflows

---

## 🎯 Feature Area 7: Deductions

### Overview

Deductions manages payroll deductions including voluntary deductions, mandatory deductions, garnishments, and loan repayments. This includes deduction setup, rules, processing, and reconciliation.

**Related Entities**: DeductionType, DeductionRule, EmployeeDeduction, DeductionTransaction, Garnishment, LoanRepayment

**Related Concept Guide**: Deductions Guide (to be created)

---

#### FR-TR-DED-001: Deduction Type Setup

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want to define deduction types
So that I can configure various payroll deductions
```

**Description**:
The system shall allow HR Administrators to define deduction types with calculation rules and limits.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I create a deduction type
- Then I must provide:
  * Unique code (e.g., UNION_DUES, LOAN_REPAY, CHARITY)
  * Name
  * Deduction category (VOLUNTARY, MANDATORY, GARNISHMENT, LOAN, BENEFIT_PREMIUM, OTHER)
  * Calculation method (FIXED_AMOUNT, PERCENTAGE, FORMULA)
  * Frequency (MONTHLY, SEMI_MONTHLY, WEEKLY, ONE_TIME)
- And I can configure:
  * Priority/sequence (for deduction order)
  * Tax treatment (PRE_TAX, POST_TAX, TAX_EXEMPT)
  * Minimum deduction amount
  * Maximum deduction amount
  * Calculation formula (if FORMULA method)
  * Proration rules
  * Effective dates
- And the system validates:
  * Deduction code uniqueness
  * Valid calculation method
  * Min <= Max amounts
  * Valid priority (1-99)
- And I can activate/deactivate deduction types

**Dependencies**:
- None

**Business Rules**:
- BR-TR-DED-001: Deduction code must be unique
- BR-TR-DED-002: Priority determines deduction order
- BR-TR-DED-003: PRE_TAX deductions reduce taxable income
- BR-TR-DED-004: GARNISHMENTS have highest priority

**Related Entities**:
- DeductionType

**API Endpoints**:
- `POST /api/v1/deductions/types`
- `GET /api/v1/deductions/types`
- `GET /api/v1/deductions/types/{id}`
- `PUT /api/v1/deductions/types/{id}`

---

#### FR-TR-DED-002: Deduction Rule Configuration

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want to configure deduction rules
So that deductions are calculated correctly based on conditions
```

**Description**:
The system shall allow HR Administrators to configure deduction rules with conditions and calculations.

**Acceptance Criteria**:
- Given I am an HR Administrator
- And I have a deduction type
- When I configure deduction rules
- Then I can define:
  * Eligibility criteria:
    - Employment types
    - Departments
    - Locations
    - Grades
    - Custom conditions
  * Calculation rules:
    - Base amount (salary, gross pay, net pay)
    - Percentage or fixed amount
    - Minimum/maximum limits
    - Rounding rules
  * Timing rules:
    - Start conditions
    - End conditions
    - Frequency
    - Proration method
- And I can configure:
  * Insufficient funds handling (skip, partial, carry forward)
  * Arrears handling
  * Stop conditions (max total, end date)
- And the system validates:
  * Rules are complete
  * No conflicting rules
  * Calculation formulas are valid

**Dependencies**:
- FR-TR-DED-001: Deduction Type Setup

**Business Rules**:
- BR-TR-DED-005: Eligibility evaluated at deduction time
- BR-TR-DED-006: Calculation base configurable
- BR-TR-DED-007: Insufficient funds handling prevents negative pay

**Related Entities**:
- DeductionRule
- DeductionType

**API Endpoints**:
- `POST /api/v1/deductions/types/{id}/rules`
- `GET /api/v1/deductions/types/{id}/rules`
- `PUT /api/v1/deductions/rules/{id}`

---

#### FR-TR-DED-003: Employee Deduction Enrollment

**Priority**: HIGH

**User Story**:
```
As an Employee
I want to enroll in voluntary deductions
So that I can contribute to savings, charity, or other programs
```

**Description**:
The system shall allow employees to enroll in voluntary deductions via self-service.

**Acceptance Criteria**:
- Given I am an Employee
- When I enroll in a deduction
- Then I can:
  * View available voluntary deductions
  * See deduction details and rules
  * Select deduction type
  * Specify amount or percentage
  * Choose start date
  * Specify end date (optional)
- And I must provide:
  * Deduction amount (if FIXED_AMOUNT)
  * Deduction percentage (if PERCENTAGE)
  * Beneficiary information (if applicable, e.g., charity)
- And the system validates:
  * I am eligible for this deduction
  * Amount within min/max limits
  * Start date is valid
  * I don't exceed maximum deductions
- And the system creates:
  * EmployeeDeduction record (status = PENDING or ACTIVE)
  * Effective from specified start date
- And I can:
  * View my active deductions
  * Modify deduction amount (if allowed)
  * Cancel deduction (with notice period)

**Dependencies**:
- FR-TR-DED-001: Deduction Type Setup
- FR-TR-DED-002: Deduction Rule Configuration

**Business Rules**:
- BR-TR-DED-008: Voluntary deductions require employee consent
- BR-TR-DED-009: Changes effective next pay period
- BR-TR-DED-010: Cancellation notice period (typically 1 pay period)

**Related Entities**:
- EmployeeDeduction
- DeductionType

**API Endpoints**:
- `GET /api/v1/deductions/available`
- `POST /api/v1/deductions/employee-deductions`
- `GET /api/v1/deductions/employee-deductions`
- `PUT /api/v1/deductions/employee-deductions/{id}`
- `DELETE /api/v1/deductions/employee-deductions/{id}`

---

#### FR-TR-DED-004: Mandatory Deduction Assignment

**Priority**: HIGH

**User Story**:
```
As an HR Administrator
I want to assign mandatory deductions to employees
So that required deductions are processed automatically
```

**Description**:
The system shall allow HR Administrators to assign mandatory deductions (taxes, social insurance, etc.) to employees.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I assign a mandatory deduction
- Then I must provide:
  * Employee ID
  * Deduction type ID
  * Effective start date
  * Calculation parameters (if applicable)
- And the system:
  * Validates employee eligibility
  * Creates EmployeeDeduction record (status = ACTIVE)
  * Sets deduction as mandatory (cannot be cancelled by employee)
- And I can:
  * Bulk assign to multiple employees
  * Import from file
  * Auto-assign based on rules (e.g., all employees get social insurance)
- And the system automatically:
  * Assigns mandatory deductions to new hires
  * Adjusts based on employment changes
  * Terminates on employee termination

**Dependencies**:
- FR-TR-DED-001: Deduction Type Setup
- Core module: Employee data

**Business Rules**:
- BR-TR-DED-011: Mandatory deductions cannot be cancelled by employee
- BR-TR-DED-012: Auto-assignment based on eligibility rules
- BR-TR-DED-013: Terminated on employee termination

**Related Entities**:
- EmployeeDeduction
- DeductionType

**API Endpoints**:
- `POST /api/v1/deductions/employee-deductions/assign`
- `POST /api/v1/deductions/employee-deductions/bulk-assign`
- `POST /api/v1/deductions/employee-deductions/auto-assign`

---

#### FR-TR-DED-005: Deduction Processing

**Priority**: HIGH

**User Story**:
```
As a Payroll Administrator
I want to process deductions during payroll
So that deductions are calculated and applied correctly
```

**Description**:
The system shall calculate and process deductions during payroll cycle.

**Acceptance Criteria**:
- Given I am a Payroll Administrator
- When I run payroll
- Then the system:
  * Retrieves all active employee deductions
  * Sorts by priority (garnishments first, then others)
  * Calculates each deduction amount
  * Validates sufficient funds
  * Applies deductions in priority order
  * Creates DeductionTransaction records
  * Updates arrears if insufficient funds
- And for each deduction:
  * Calculates based on method (fixed, percentage, formula)
  * Applies min/max limits
  * Handles proration if mid-period start/end
  * Checks stop conditions (max total reached)
- And the system handles:
  * Insufficient funds (skip, partial, carry forward)
  * Arrears accumulation
  * Deduction limits
  * Tax impact (pre-tax vs post-tax)
- And I can:
  * Preview deductions before processing
  * Override deduction amounts (with reason)
  * Exclude specific deductions
  * Generate deduction report

**Dependencies**:
- FR-TR-DED-003: Employee Deduction Enrollment
- FR-TR-DED-004: Mandatory Deduction Assignment
- Payroll module: Payroll processing

**Business Rules**:
- BR-TR-DED-014: Deductions processed in priority order
- BR-TR-DED-015: Garnishments have highest priority
- BR-TR-DED-016: Net pay cannot be negative
- BR-TR-DED-017: Arrears carried forward to next period

**Related Entities**:
- DeductionTransaction
- EmployeeDeduction

**API Endpoints**:
- `POST /api/v1/deductions/process`
- `GET /api/v1/deductions/preview`
- `POST /api/v1/deductions/transactions/{id}/override`

---

#### FR-TR-DED-006: Garnishment Management

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to manage wage garnishments
So that I can comply with court orders and legal requirements
```

**Description**:
The system shall manage wage garnishments including court orders, child support, and tax levies.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I create a garnishment
- Then I must provide:
  * Employee ID
  * Garnishment type (CHILD_SUPPORT, TAX_LEVY, CREDITOR, STUDENT_LOAN, BANKRUPTCY)
  * Court order number
  * Issuing authority
  * Order date
  * Deduction amount or percentage
  * Maximum total (if applicable)
  * Effective dates
  * Priority (if multiple garnishments)
- And I can upload:
  * Court order document
  * Supporting documents
- And the system:
  * Creates Garnishment record
  * Creates EmployeeDeduction (highest priority)
  * Validates garnishment limits (federal/state)
  * Calculates disposable income
  * Applies garnishment percentage to disposable income
- And I can:
  * Track garnishment balance
  * Generate remittance reports
  * Process payments to agencies
  * Terminate garnishment when complete
- And the system enforces:
  * Federal garnishment limits (25% of disposable income)
  * State-specific limits
  * Priority rules (child support > tax levy > creditor)

**Dependencies**:
- FR-TR-DED-001: Deduction Type Setup
- FR-TR-DED-005: Deduction Processing

**Business Rules**:
- BR-TR-DED-018: Garnishments have highest priority
- BR-TR-DED-019: Federal limit = 25% of disposable income
- BR-TR-DED-020: Child support has priority over other garnishments
- BR-TR-DED-021: Disposable income = gross - mandatory deductions

**Related Entities**:
- Garnishment
- EmployeeDeduction
- DeductionTransaction

**API Endpoints**:
- `POST /api/v1/deductions/garnishments`
- `GET /api/v1/deductions/garnishments`
- `GET /api/v1/deductions/garnishments/{id}`
- `PUT /api/v1/deductions/garnishments/{id}`
- `POST /api/v1/deductions/garnishments/{id}/terminate`

---

#### FR-TR-DED-007: Loan Repayment Management

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to manage employee loan repayments
So that company loans are repaid through payroll deductions
```

**Description**:
The system shall manage employee loan repayments via payroll deductions.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I create a loan repayment
- Then I must provide:
  * Employee ID
  * Loan type (ADVANCE, EMERGENCY, RELOCATION, EDUCATION, OTHER)
  * Loan amount
  * Interest rate (if applicable)
  * Repayment amount per period
  * Start date
  * Number of installments or end date
- And the system:
  * Creates LoanRepayment record
  * Creates EmployeeDeduction
  * Calculates total repayment (principal + interest)
  * Generates repayment schedule
  * Tracks balance
- And for each payroll:
  * Deducts repayment amount
  * Updates loan balance
  * Tracks payments made
  * Stops when fully repaid
- And I can:
  * View loan balance
  * View payment history
  * Adjust repayment amount (with approval)
  * Handle early repayment
  * Handle missed payments
- And the system:
  * Sends reminders for upcoming payments
  * Alerts on missed payments
  * Calculates interest (if applicable)
  * Generates loan statements

**Dependencies**:
- FR-TR-DED-001: Deduction Type Setup
- FR-TR-DED-005: Deduction Processing

**Business Rules**:
- BR-TR-DED-022: Loan balance = principal + interest - payments
- BR-TR-DED-023: Deduction stops when fully repaid
- BR-TR-DED-024: Early repayment allowed
- BR-TR-DED-025: Missed payments tracked as arrears

**Related Entities**:
- LoanRepayment
- EmployeeDeduction
- DeductionTransaction

**API Endpoints**:
- `POST /api/v1/deductions/loans`
- `GET /api/v1/deductions/loans`
- `GET /api/v1/deductions/loans/{id}`
- `GET /api/v1/deductions/loans/{id}/schedule`
- `POST /api/v1/deductions/loans/{id}/early-repayment`

---

#### FR-TR-DED-008: Deduction Reconciliation

**Priority**: MEDIUM

**User Story**:
```
As a Payroll Administrator
I want to reconcile deductions with third parties
So that I can ensure accurate remittance
```

**Description**:
The system shall support reconciliation of deductions with third-party recipients (insurance carriers, government agencies, etc.).

**Acceptance Criteria**:
- Given I am a Payroll Administrator
- When I reconcile deductions
- Then I can:
  * Generate deduction summary by type
  * Generate remittance report
  * Compare to third-party invoices
  * Identify discrepancies
- And the system shows:
  * Total deducted by type
  * Number of employees
  * Deduction details by employee
  * Variance (if comparing to invoice)
- And I can:
  * Export remittance file
  * Generate payment voucher
  * Mark as reconciled
  * Track payment status
- And for each deduction type:
  * Benefit premiums → Insurance carrier
  * Union dues → Union
  * Charity → Charity organization
  * Garnishments → Court/Agency
  * Loans → Company (internal)
- And the system tracks:
  * Reconciliation history
  * Payment confirmations
  * Outstanding balances

**Dependencies**:
- FR-TR-DED-005: Deduction Processing

**Business Rules**:
- BR-TR-DED-026: Reconciliation performed monthly
- BR-TR-DED-027: Remittance due by specific dates
- BR-TR-DED-028: Variance must be resolved

**Related Entities**:
- DeductionTransaction

**API Endpoints**:
- `GET /api/v1/deductions/reconciliation/summary`
- `GET /api/v1/deductions/reconciliation/remittance`
- `POST /api/v1/deductions/reconciliation/mark-reconciled`
- `GET /api/v1/deductions/reconciliation/export`

---

#### FR-TR-DED-009: Deduction Arrears Management

**Priority**: MEDIUM

**User Story**:
```
As a Payroll Administrator
I want to manage deduction arrears
So that I can track and collect missed deductions
```

**Description**:
The system shall track and manage deduction arrears when deductions cannot be fully processed.

**Acceptance Criteria**:
- Given a deduction cannot be fully processed (insufficient funds)
- When arrears occur
- Then the system:
  * Records arrears amount
  * Updates employee deduction record
  * Tracks arrears balance
  * Attempts to collect in next period
- And I can configure:
  * Arrears handling method:
    - Carry forward to next period
    - Spread over multiple periods
    - Collect when funds available
  * Maximum arrears allowed
  * Arrears collection priority
- And I can:
  * View employees with arrears
  * View arrears by deduction type
  * Manually adjust arrears
  * Waive arrears (with approval)
- And the system:
  * Prioritizes arrears collection
  * Sends notifications to employees
  * Alerts when arrears exceed threshold
  * Generates arrears reports

**Dependencies**:
- FR-TR-DED-005: Deduction Processing

**Business Rules**:
- BR-TR-DED-029: Arrears accumulated when insufficient funds
- BR-TR-DED-030: Arrears collected in next period (if funds available)
- BR-TR-DED-031: Maximum arrears limit prevents excessive accumulation

**Related Entities**:
- EmployeeDeduction
- DeductionTransaction

**API Endpoints**:
- `GET /api/v1/deductions/arrears`
- `GET /api/v1/deductions/employees/{id}/arrears`
- `POST /api/v1/deductions/arrears/{id}/adjust`
- `POST /api/v1/deductions/arrears/{id}/waive`

---

#### FR-TR-DED-010: Deduction Reporting

**Priority**: LOW

**User Story**:
```
As an HR Administrator
I want to generate deduction reports
So that I can analyze deduction trends and compliance
```

**Description**:
The system shall provide comprehensive deduction reporting and analytics.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I generate deduction reports
- Then I can view:
  * Deduction summary by type
  * Deduction trends over time
  * Employee participation rates
  * Total deductions by department
  * Garnishment summary
  * Loan repayment summary
  * Arrears summary
- And I can filter by:
  * Date range
  * Deduction type
  * Department
  * Employee
  * Status (active, cancelled, completed)
- And I can generate:
  * Deduction detail report
  * Remittance report
  * Compliance report (garnishments)
  * Arrears report
  * Audit report
- And I can export:
  * Excel
  * PDF
  * CSV

**Dependencies**:
- FR-TR-DED-005: Deduction Processing

**Business Rules**:
- BR-TR-DED-032: Reports reflect actual deductions processed
- BR-TR-DED-033: Compliance reports for garnishments
- BR-TR-DED-034: Audit trail for all deduction changes

**Related Entities**:
- DeductionTransaction
- EmployeeDeduction

**API Endpoints**:
- `GET /api/v1/deductions/reports/summary`
- `GET /api/v1/deductions/reports/trends`
- `GET /api/v1/deductions/reports/compliance`
- `GET /api/v1/deductions/reports/export`

---

## Summary: Deductions

**Total Requirements**: 10  
**Priority Breakdown**:
- HIGH: 6 requirements
- MEDIUM: 3 requirements  
- LOW: 1 requirement

**Key Features**:
- Deduction type and rule configuration
- Employee voluntary deduction enrollment
- Mandatory deduction assignment
- Deduction processing and calculation
- Garnishment management (court orders)
- Loan repayment tracking
- Reconciliation with third parties
- Arrears management
- Comprehensive reporting

**Progress**: 93/131 FRs complete (71%)

**Remaining Sub-Modules**: Tax Withholding (12 FRs), Taxable Bridge (6 FRs), Audit (8 FRs), Calculation Rules (12 FRs) - 38 FRs remaining

---

*Document continues with remaining sub-modules...*

## 🎯 Feature Area 8: Tax Withholding

### Overview

Tax Withholding manages income tax calculations, withholding, and compliance across multiple countries. This includes tax configuration, calculation engines, filing, and reporting.

**Related Entities**: TaxJurisdiction, TaxBracket, TaxRule, EmployeeTaxProfile, TaxWithholdingTransaction, TaxFiling

**Related Concept Guide**: Tax Compliance Guide (to be created)

---

#### FR-TR-TAX-001: Tax Jurisdiction Configuration

**Priority**: HIGH

**User Story**:
```
As a Tax Administrator
I want to configure tax jurisdictions
So that I can manage tax rules for different countries and regions
```

**Description**:
The system shall allow Tax Administrators to configure tax jurisdictions with country-specific rules and rates.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- When I configure a tax jurisdiction
- Then I must provide:
  * Jurisdiction code (e.g., VN_NATIONAL, US_FEDERAL, US_CA_STATE)
  * Name
  * Country code (ISO 3166)
  * Jurisdiction type (NATIONAL, STATE, PROVINCE, CITY, LOCAL)
  * Tax authority name
  * Effective dates
- And I can configure:
  * Tax calculation method (PROGRESSIVE, FLAT, FORMULA)
  * Tax year (CALENDAR, FISCAL)
  * Filing frequency (MONTHLY, QUARTERLY, ANNUAL)
  * Withholding requirements
  * Compliance rules
- And the system validates:
  * Jurisdiction code uniqueness
  * Valid country code
  * Valid jurisdiction type
- And I can activate/deactivate jurisdictions

**Dependencies**:
- None

**Business Rules**:
- BR-TR-TAX-001: Jurisdiction code must be unique
- BR-TR-TAX-002: Multiple jurisdictions per country (federal, state, local)
- BR-TR-TAX-003: Effective dates manage rate changes

**Related Entities**:
- TaxJurisdiction

**API Endpoints**:
- `POST /api/v1/tax/jurisdictions`
- `GET /api/v1/tax/jurisdictions`
- `GET /api/v1/tax/jurisdictions/{id}`
- `PUT /api/v1/tax/jurisdictions/{id}`

---

#### FR-TR-TAX-002: Tax Bracket Management

**Priority**: HIGH

**User Story**:
```
As a Tax Administrator
I want to define tax brackets
So that progressive tax rates are calculated correctly
```

**Description**:
The system shall allow Tax Administrators to define tax brackets for progressive tax systems.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- And I have a tax jurisdiction with PROGRESSIVE method
- When I define tax brackets
- Then I must provide for each bracket:
  * Bracket number (sequence: 1, 2, 3...)
  * Min taxable income
  * Max taxable income (NULL for top bracket)
  * Tax rate (percentage)
  * Fixed amount (for cumulative calculation)
- And the system validates:
  * Brackets are sequential
  * No gaps in income ranges
  * Rates are between 0-100%
  * Only top bracket can have NULL max
- And I can:
  * Add/remove brackets
  * Update rates (creates new version)
  * View bracket structure
  * Test calculations
- And the system supports:
  * Multiple bracket sets per jurisdiction (e.g., single vs married)
  * Effective date versioning
  * Historical bracket retention

**Dependencies**:
- FR-TR-TAX-001: Tax Jurisdiction Configuration

**Business Rules**:
- BR-TR-TAX-004: Brackets must be contiguous
- BR-TR-TAX-005: Progressive calculation = sum of (bracket amount × rate)
- BR-TR-TAX-006: Bracket changes create new version

**Related Entities**:
- TaxBracket
- TaxJurisdiction

**API Endpoints**:
- `POST /api/v1/tax/jurisdictions/{id}/brackets`
- `GET /api/v1/tax/jurisdictions/{id}/brackets`
- `PUT /api/v1/tax/brackets/{id}`
- `DELETE /api/v1/tax/brackets/{id}`

---

#### FR-TR-TAX-003: Tax Rule Configuration

**Priority**: HIGH

**User Story**:
```
As a Tax Administrator
I want to configure tax rules
So that tax calculations follow country-specific regulations
```

**Description**:
The system shall allow Tax Administrators to configure tax rules including exemptions, allowances, and special calculations.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- When I configure tax rules
- Then I can define:
  * Personal allowance (standard deduction)
  * Dependent allowance (per dependent)
  * Special allowances (disability, age, etc.)
  * Tax credits
  * Exemptions
  * Calculation formulas
- And I can configure:
  * Eligibility criteria for each rule
  * Calculation method
  * Maximum amounts
  * Phase-out rules (income-based reduction)
  * Effective dates
- And the system validates:
  * Rule formulas are valid
  * Amounts are non-negative
  * Eligibility criteria are complete
- And I can:
  * Version rules (for annual changes)
  * Test rule application
  * View rule history

**Dependencies**:
- FR-TR-TAX-001: Tax Jurisdiction Configuration

**Business Rules**:
- BR-TR-TAX-007: Personal allowance reduces taxable income
- BR-TR-TAX-008: Tax credits reduce tax liability
- BR-TR-TAX-009: Exemptions exclude income from taxation

**Related Entities**:
- TaxRule
- TaxJurisdiction

**API Endpoints**:
- `POST /api/v1/tax/jurisdictions/{id}/rules`
- `GET /api/v1/tax/jurisdictions/{id}/rules`
- `PUT /api/v1/tax/rules/{id}`

---

#### FR-TR-TAX-004: Employee Tax Profile Management

**Priority**: HIGH

**User Story**:
```
As an Employee
I want to manage my tax profile
So that my tax withholding is calculated correctly
```

**Description**:
The system shall allow employees to manage their tax profiles including filing status, allowances, and additional withholding.

**Acceptance Criteria**:
- Given I am an Employee
- When I manage my tax profile
- Then I can provide:
  * Tax ID number (SSN, TIN, etc.)
  * Filing status (SINGLE, MARRIED, HEAD_OF_HOUSEHOLD, etc.)
  * Number of allowances/dependents
  * Additional withholding amount
  * Exemption claims (if applicable)
- And I can configure:
  * Multiple jurisdictions (if working in multiple states)
  * Tax residency status
  * Foreign tax credits
  * Special circumstances
- And the system validates:
  * Tax ID format per country
  * Valid filing status
  * Allowances are non-negative
- And I can:
  * View current tax profile
  * Update profile (effective next period)
  * View tax withholding estimate
  * Download tax forms (W-4, etc.)
- And the system:
  * Encrypts sensitive tax data
  * Tracks profile changes
  * Notifies payroll of changes

**Dependencies**:
- FR-TR-TAX-001: Tax Jurisdiction Configuration

**Business Rules**:
- BR-TR-TAX-010: Tax ID required for tax calculation
- BR-TR-TAX-011: Filing status affects tax brackets
- BR-TR-TAX-012: Profile changes effective next pay period

**Related Entities**:
- EmployeeTaxProfile

**API Endpoints**:
- `GET /api/v1/tax/employees/{id}/profile`
- `PUT /api/v1/tax/employees/{id}/profile`
- `GET /api/v1/tax/employees/{id}/estimate`

---

#### FR-TR-TAX-005: Tax Withholding Calculation

**Priority**: HIGH

**User Story**:
```
As a Payroll Administrator
I want to calculate tax withholding
So that correct taxes are deducted from employee pay
```

**Description**:
The system shall calculate tax withholding based on employee profiles, tax rules, and gross pay.

**Acceptance Criteria**:
- Given I am a Payroll Administrator
- When I run payroll
- Then the system:
  * Retrieves employee tax profile
  * Calculates gross taxable income
  * Applies tax-exempt deductions (pre-tax)
  * Applies personal allowances
  * Calculates taxable income
  * Applies tax brackets (progressive) or rate (flat)
  * Applies tax credits
  * Calculates net tax liability
  * Adds additional withholding
  * Creates TaxWithholdingTransaction
- And for each jurisdiction:
  * Federal/national tax
  * State/province tax
  * Local/city tax
  * Social insurance (if tax-based)
- And the system handles:
  * Multiple pay frequencies (monthly, semi-monthly, weekly)
  * Annualization for progressive rates
  * Proration for partial periods
  * Bonus/supplemental income (different rates)
- And I can:
  * Preview tax calculations
  * Override withholding (with reason)
  * Generate tax reports

**Dependencies**:
- FR-TR-TAX-002: Tax Bracket Management
- FR-TR-TAX-003: Tax Rule Configuration
- FR-TR-TAX-004: Employee Tax Profile
- Payroll module: Gross pay calculation

**Business Rules**:
- BR-TR-TAX-013: Taxable income = gross - pre-tax deductions - allowances
- BR-TR-TAX-014: Progressive tax calculated per bracket
- BR-TR-TAX-015: Supplemental income may have flat rate
- BR-TR-TAX-016: Annualization for monthly to annual conversion

**Related Entities**:
- TaxWithholdingTransaction
- EmployeeTaxProfile
- TaxBracket

**API Endpoints**:
- `POST /api/v1/tax/calculate`
- `GET /api/v1/tax/preview`
- `POST /api/v1/tax/transactions/{id}/override`

---

#### FR-TR-TAX-006: Tax Withholding Reporting

**Priority**: MEDIUM

**User Story**:
```
As a Tax Administrator
I want to generate tax withholding reports
So that I can file tax returns and remit payments
```

**Description**:
The system shall generate tax withholding reports for filing and remittance.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- When I generate tax reports
- Then I can generate:
  * Monthly withholding summary
  * Quarterly tax filing report
  * Annual tax summary
  * Employee-level tax detail
  * Jurisdiction-level summary
- And reports include:
  * Total gross wages
  * Total taxable wages
  * Total tax withheld (by jurisdiction)
  * Number of employees
  * Tax remittance due
- And I can:
  * Filter by period
  * Filter by jurisdiction
  * Filter by legal entity
  * Export to required formats (PDF, Excel, XML)
  * Generate filing forms (e.g., 941, W-2)
- And the system:
  * Validates data completeness
  * Flags discrepancies
  * Tracks filing status

**Dependencies**:
- FR-TR-TAX-005: Tax Withholding Calculation

**Business Rules**:
- BR-TR-TAX-017: Reports reflect actual withholding transactions
- BR-TR-TAX-018: Filing frequency per jurisdiction rules
- BR-TR-TAX-019: Remittance due by specific dates

**Related Entities**:
- TaxWithholdingTransaction
- TaxFiling

**API Endpoints**:
- `GET /api/v1/tax/reports/withholding-summary`
- `GET /api/v1/tax/reports/filing`
- `GET /api/v1/tax/reports/export`

---

#### FR-TR-TAX-007: Tax Form Generation

**Priority**: MEDIUM

**User Story**:
```
As an HR Administrator
I want to generate tax forms for employees
So that employees can file their tax returns
```

**Description**:
The system shall generate employee tax forms (W-2, 1099, etc.) for annual filing.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I generate tax forms
- Then I can generate:
  * W-2 (US employees)
  * 1099 (US contractors)
  * T4 (Canada)
  * P60 (UK)
  * Country-specific forms
- And each form includes:
  * Employee information
  * Employer information
  * Total wages/compensation
  * Tax withheld (federal, state, local)
  * Social security wages and tax
  * Medicare wages and tax
  * Other required fields
- And I can:
  * Generate for all employees
  * Generate for specific employees
  * Preview before finalizing
  * Regenerate if needed (before filing)
  * Deliver electronically or print
- And the system:
  * Validates form data
  * Generates PDF
  * Tracks generation and delivery
  * Supports e-filing formats

**Dependencies**:
- FR-TR-TAX-005: Tax Withholding Calculation

**Business Rules**:
- BR-TR-TAX-020: Forms generated annually
- BR-TR-TAX-021: Forms must be provided by Jan 31 (US)
- BR-TR-TAX-022: Corrections require amended forms

**Related Entities**:
- TaxWithholdingTransaction
- EmployeeTaxProfile

**API Endpoints**:
- `POST /api/v1/tax/forms/generate`
- `GET /api/v1/tax/forms`
- `GET /api/v1/tax/forms/{id}/pdf`
- `POST /api/v1/tax/forms/{id}/deliver`

---

#### FR-TR-TAX-008: Tax Reconciliation

**Priority**: MEDIUM

**User Story**:
```
As a Tax Administrator
I want to reconcile tax withholding
So that I can ensure accurate tax remittance
```

**Description**:
The system shall support tax reconciliation to verify withholding accuracy.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- When I reconcile taxes
- Then I can:
  * Compare system calculations to payroll actuals
  * Compare to tax authority records
  * Identify discrepancies
  * Generate variance reports
- And the system shows:
  * Total wages (system vs payroll)
  * Total tax withheld (system vs payroll)
  * Variance amount and percentage
  * Employee-level discrepancies
- And I can:
  * Drill down to transaction level
  * Adjust transactions (with approval)
  * Generate correction reports
  * Track reconciliation status
- And the system:
  * Flags significant variances
  * Suggests corrections
  * Maintains audit trail

**Dependencies**:
- FR-TR-TAX-005: Tax Withholding Calculation
- Payroll module: Payroll actuals

**Business Rules**:
- BR-TR-TAX-023: Reconciliation performed monthly/quarterly
- BR-TR-TAX-024: Variances must be resolved before filing
- BR-TR-TAX-025: Adjustments require approval

**Related Entities**:
- TaxWithholdingTransaction

**API Endpoints**:
- `POST /api/v1/tax/reconciliation/run`
- `GET /api/v1/tax/reconciliation/{id}`
- `GET /api/v1/tax/reconciliation/{id}/variances`
- `POST /api/v1/tax/reconciliation/{id}/adjust`

---

#### FR-TR-TAX-009: Tax Compliance Monitoring

**Priority**: MEDIUM

**User Story**:
```
As a Tax Administrator
I want to monitor tax compliance
So that I can identify and address compliance issues
```

**Description**:
The system shall monitor tax compliance and alert on potential issues.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- When I monitor compliance
- Then the system checks:
  * Missing tax profiles
  * Invalid tax IDs
  * Withholding anomalies (too high/low)
  * Filing deadlines approaching
  * Unfiled returns
  * Unpaid tax liabilities
- And the system alerts on:
  * Employees without tax profiles
  * Tax calculations outside normal range
  * Filing deadlines (30, 14, 7 days before)
  * Overdue filings
  * Reconciliation variances
- And I can:
  * View compliance dashboard
  * View alerts and warnings
  * Assign remediation tasks
  * Track resolution status
  * Generate compliance reports
- And the system:
  * Runs daily compliance checks
  * Sends email notifications
  * Escalates overdue items

**Dependencies**:
- FR-TR-TAX-004: Employee Tax Profile
- FR-TR-TAX-005: Tax Withholding Calculation
- FR-TR-TAX-006: Tax Reporting

**Business Rules**:
- BR-TR-TAX-026: Compliance checks run daily
- BR-TR-TAX-027: Alerts sent to tax administrators
- BR-TR-TAX-028: Critical issues escalated

**Related Entities**:
- EmployeeTaxProfile
- TaxWithholdingTransaction
- TaxFiling

**API Endpoints**:
- `GET /api/v1/tax/compliance/dashboard`
- `GET /api/v1/tax/compliance/alerts`
- `POST /api/v1/tax/compliance/alerts/{id}/resolve`

---

#### FR-TR-TAX-010: Tax Year-End Processing

**Priority**: HIGH

**User Story**:
```
As a Tax Administrator
I want to process year-end tax activities
So that I can close the tax year and prepare for filing
```

**Description**:
The system shall support year-end tax processing including form generation, filing, and year closure.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- When I process year-end
- Then I can:
  * Run year-end validation
  * Generate all employee tax forms (W-2, etc.)
  * Generate employer tax returns (941, etc.)
  * Reconcile annual totals
  * File electronically (if supported)
  * Close tax year
- And the system:
  * Validates all employee tax profiles complete
  * Validates all withholding transactions processed
  * Calculates annual totals
  * Generates required forms
  * Tracks filing status
  * Archives year-end data
- And I can:
  * Preview year-end reports
  * Correct errors before finalizing
  * Reopen year if needed (with approval)
  * Generate amended forms
- And the system prevents:
  * Closing year with incomplete data
  * Modifying closed year (without approval)

**Dependencies**:
- FR-TR-TAX-005: Tax Withholding Calculation
- FR-TR-TAX-007: Tax Form Generation

**Business Rules**:
- BR-TR-TAX-029: Year-end processing in January
- BR-TR-TAX-030: All forms generated before closing
- BR-TR-TAX-031: Closed year requires approval to reopen

**Related Entities**:
- TaxWithholdingTransaction
- TaxFiling

**API Endpoints**:
- `POST /api/v1/tax/year-end/validate`
- `POST /api/v1/tax/year-end/process`
- `POST /api/v1/tax/year-end/close`
- `POST /api/v1/tax/year-end/reopen`

---

#### FR-TR-TAX-011: Multi-Country Tax Support

**Priority**: LOW

**User Story**:
```
As a Tax Administrator
I want to manage taxes for multiple countries
So that I can support global workforce
```

**Description**:
The system shall support tax calculations for multiple countries with country-specific rules.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- When I configure multi-country taxes
- Then I can:
  * Configure jurisdictions per country
  * Define country-specific tax rules
  * Support different tax years (calendar vs fiscal)
  * Handle currency differences
  * Manage tax treaties (double taxation)
- And the system supports:
  * Vietnam: Progressive PIT, social insurance
  * US: Federal + state + local, FICA
  * Singapore: Progressive income tax, CPF
  * UK: PAYE, National Insurance
  * Other countries (extensible)
- And for each country:
  * Tax calculation engine
  * Form generation
  * Filing requirements
  * Compliance rules
- And I can:
  * View tax summary by country
  * Generate country-specific reports
  * Handle expatriate taxation

**Dependencies**:
- FR-TR-TAX-001: Tax Jurisdiction Configuration
- FR-TR-TAX-002: Tax Bracket Management

**Business Rules**:
- BR-TR-TAX-032: Each country has unique tax rules
- BR-TR-TAX-033: Tax treaties prevent double taxation
- BR-TR-TAX-034: Expatriates may have special rules

**Related Entities**:
- TaxJurisdiction
- TaxBracket
- TaxRule

**API Endpoints**:
- `GET /api/v1/tax/countries`
- `GET /api/v1/tax/countries/{code}/jurisdictions`
- `GET /api/v1/tax/countries/{code}/rules`

---

#### FR-TR-TAX-012: Tax Audit Trail

**Priority**: LOW

**User Story**:
```
As a Tax Administrator
I want to maintain tax audit trail
So that I can support tax audits and compliance reviews
```

**Description**:
The system shall maintain comprehensive audit trail for all tax-related activities.

**Acceptance Criteria**:
- Given any tax-related activity occurs
- When the activity is performed
- Then the system logs:
  * Activity type (calculation, profile change, override, etc.)
  * User who performed activity
  * Timestamp
  * Before/after values
  * Reason/justification
  * Related entities
- And I can:
  * Query audit trail by employee
  * Query by date range
  * Query by activity type
  * Query by user
  * Export audit reports
- And the system tracks:
  * Tax profile changes
  * Calculation overrides
  * Form generations
  * Filing submissions
  * Reconciliation adjustments
- And audit records are:
  * Immutable
  * Retained for 7 years
  * Exportable for audits

**Dependencies**:
- All tax-related features

**Business Rules**:
- BR-TR-TAX-035: All tax activities logged
- BR-TR-TAX-036: Audit records immutable
- BR-TR-TAX-037: Retention period = 7 years

**Related Entities**:
- All tax entities

**API Endpoints**:
- `GET /api/v1/tax/audit-trail`
- `GET /api/v1/tax/audit-trail/employee/{id}`
- `GET /api/v1/tax/audit-trail/export`

---

## Summary: Tax Withholding

**Total Requirements**: 12  
**Priority Breakdown**:
- HIGH: 10 requirements
- MEDIUM: 0 requirements  
- LOW: 2 requirements

**Key Features**:
- Tax jurisdiction and bracket configuration
- Tax rule management (allowances, credits, exemptions)
- Employee tax profile management
- Automated tax withholding calculation
- Tax reporting and form generation
- Reconciliation and compliance monitoring
- Year-end processing
- Multi-country support
- Comprehensive audit trail

---

## 🎯 Feature Area 9: Taxable Bridge

### Overview

Taxable Bridge manages the mapping between compensation components and tax treatment, ensuring correct tax calculations and reporting. This includes component-to-tax mapping, tax category assignment, and integration with payroll.

**Related Entities**: TaxableComponent, TaxCategory, ComponentTaxMapping, TaxableWageCalculation

**Related Concept Guide**: Tax Compliance Guide (to be created)

---

#### FR-TR-BRIDGE-001: Tax Category Definition

**Priority**: HIGH

**User Story**:
```
As a Tax Administrator
I want to define tax categories
So that I can classify compensation components for tax purposes
```

**Description**:
The system shall allow Tax Administrators to define tax categories for grouping compensation components.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- When I define a tax category
- Then I must provide:
  * Unique code (e.g., REGULAR_WAGES, SUPPLEMENTAL, FRINGE_BENEFIT)
  * Name
  * Description
  * Tax treatment (FULLY_TAXABLE, TAX_EXEMPT, PARTIALLY_EXEMPT)
  * Applicable jurisdictions
- And I can configure:
  * Subject to federal tax (Yes/No)
  * Subject to state tax (Yes/No)
  * Subject to local tax (Yes/No)
  * Subject to social insurance (Yes/No)
  * Subject to Medicare (Yes/No)
  * Reporting requirements (W-2 boxes, etc.)
- And the system validates:
  * Category code uniqueness
  * Valid tax treatment
  * At least one jurisdiction selected
- And I can activate/deactivate categories

**Dependencies**:
- FR-TR-TAX-001: Tax Jurisdiction Configuration

**Business Rules**:
- BR-TR-BRIDGE-001: Category code must be unique
- BR-TR-BRIDGE-002: Tax treatment determines calculation
- BR-TR-BRIDGE-003: Reporting requirements per tax authority

**Related Entities**:
- TaxCategory

**API Endpoints**:
- `POST /api/v1/tax-bridge/categories`
- `GET /api/v1/tax-bridge/categories`
- `GET /api/v1/tax-bridge/categories/{id}`
- `PUT /api/v1/tax-bridge/categories/{id}`

---

#### FR-TR-BRIDGE-002: Component Tax Mapping

**Priority**: HIGH

**User Story**:
```
As a Tax Administrator
I want to map compensation components to tax categories
So that tax calculations use correct treatment
```

**Description**:
The system shall allow Tax Administrators to map compensation components to tax categories.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- When I map a component to tax category
- Then I must provide:
  * Component ID (from PayComponentDefinition)
  * Tax category ID
  * Effective dates
  * Jurisdiction (if category-specific)
- And I can configure:
  * Percentage taxable (for partially exempt)
  * Exempt threshold (if applicable)
  * Special calculation rules
  * Reporting overrides
- And the system validates:
  * Component exists
  * Category exists
  * No duplicate mappings for same period
  * Effective dates don't overlap
- And I can:
  * View all mappings
  * Update mappings (creates new version)
  * View mapping history
  * Test tax calculations

**Dependencies**:
- FR-TR-COMP-002: Pay Component Definition
- FR-TR-BRIDGE-001: Tax Category Definition

**Business Rules**:
- BR-TR-BRIDGE-004: One active mapping per component per jurisdiction
- BR-TR-BRIDGE-005: Mapping changes create new version
- BR-TR-BRIDGE-006: Historical mappings retained for audit

**Related Entities**:
- ComponentTaxMapping
- PayComponentDefinition
- TaxCategory

**API Endpoints**:
- `POST /api/v1/tax-bridge/mappings`
- `GET /api/v1/tax-bridge/mappings`
- `GET /api/v1/tax-bridge/mappings/component/{id}`
- `PUT /api/v1/tax-bridge/mappings/{id}`

---

#### FR-TR-BRIDGE-003: Taxable Wage Calculation

**Priority**: HIGH

**User Story**:
```
As a Payroll Administrator
I want to calculate taxable wages
So that tax withholding is based on correct amounts
```

**Description**:
The system shall calculate taxable wages based on component tax mappings.

**Acceptance Criteria**:
- Given I am a Payroll Administrator
- When I calculate taxable wages
- Then the system:
  * Retrieves all compensation components for employee
  * Retrieves tax mappings for each component
  * Calculates taxable amount per component:
    - FULLY_TAXABLE: 100% of amount
    - TAX_EXEMPT: 0% of amount
    - PARTIALLY_EXEMPT: amount above threshold
  * Sums taxable amounts by jurisdiction:
    - Federal taxable wages
    - State taxable wages
    - Local taxable wages
    - Social insurance wages
    - Medicare wages
  * Creates TaxableWageCalculation record
- And the system handles:
  * Multiple components with different treatments
  * Pre-tax deductions (reduce taxable wages)
  * Post-tax deductions (don't reduce taxable wages)
  * Employer contributions (not taxable to employee)
- And I can:
  * Preview taxable wage calculation
  * View breakdown by component
  * Override calculations (with reason)

**Dependencies**:
- FR-TR-BRIDGE-002: Component Tax Mapping
- FR-TR-COMP-002: Pay Component Definition
- Payroll module: Component amounts

**Business Rules**:
- BR-TR-BRIDGE-007: Taxable wages = sum of taxable components
- BR-TR-BRIDGE-008: Pre-tax deductions reduce taxable wages
- BR-TR-BRIDGE-009: Employer contributions not taxable

**Related Entities**:
- TaxableWageCalculation
- ComponentTaxMapping
- PayComponentDefinition

**API Endpoints**:
- `POST /api/v1/tax-bridge/calculate-taxable-wages`
- `GET /api/v1/tax-bridge/taxable-wages/preview`
- `GET /api/v1/tax-bridge/taxable-wages/employee/{id}`

---

#### FR-TR-BRIDGE-004: Tax Reporting Integration

**Priority**: MEDIUM

**User Story**:
```
As a Tax Administrator
I want to integrate taxable wages with tax reporting
So that tax forms are populated correctly
```

**Description**:
The system shall integrate taxable wage calculations with tax reporting and form generation.

**Acceptance Criteria**:
- Given taxable wages are calculated
- When I generate tax reports/forms
- Then the system:
  * Maps taxable wages to report fields
  * Populates W-2 boxes (US):
    - Box 1: Federal wages
    - Box 3: Social security wages
    - Box 5: Medicare wages
    - Box 16: State wages
    - Box 18: Local wages
  * Populates country-specific forms
  * Validates totals
- And I can:
  * View mapping configuration
  * Test form population
  * Override field values (with reason)
  * Generate preview
- And the system:
  * Tracks which components contribute to which boxes
  * Validates required fields populated
  * Flags discrepancies

**Dependencies**:
- FR-TR-BRIDGE-003: Taxable Wage Calculation
- FR-TR-TAX-007: Tax Form Generation

**Business Rules**:
- BR-TR-BRIDGE-010: W-2 boxes populated from taxable wages
- BR-TR-BRIDGE-011: All required fields must have values
- BR-TR-BRIDGE-012: Overrides require approval

**Related Entities**:
- TaxableWageCalculation
- ComponentTaxMapping

**API Endpoints**:
- `GET /api/v1/tax-bridge/reporting/mapping`
- `POST /api/v1/tax-bridge/reporting/test`
- `POST /api/v1/tax-bridge/reporting/override`

---

#### FR-TR-BRIDGE-005: Fringe Benefit Valuation

**Priority**: MEDIUM

**User Story**:
```
As a Tax Administrator
I want to value fringe benefits
So that taxable fringe benefits are reported correctly
```

**Description**:
The system shall calculate taxable value of fringe benefits.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- When I configure fringe benefits
- Then I can define:
  * Benefit type (COMPANY_CAR, HOUSING, MEALS, etc.)
  * Valuation method (FAIR_MARKET_VALUE, COST, FORMULA)
  * Taxable percentage
  * Exclusion rules
- And the system calculates:
  * Fair market value (if applicable)
  * Taxable portion
  * Excludable amount
  * Net taxable benefit
- And I can configure:
  * Company car: Personal use percentage
  * Housing: Fair rental value
  * Meals: De minimis exclusion
  * Other benefits: Custom formulas
- And the system:
  * Adds taxable benefits to W-2
  * Includes in taxable wages
  * Tracks benefit usage
  * Generates benefit reports

**Dependencies**:
- FR-TR-BRIDGE-001: Tax Category Definition
- FR-TR-BRIDGE-003: Taxable Wage Calculation

**Business Rules**:
- BR-TR-BRIDGE-013: Fringe benefits taxable unless excluded
- BR-TR-BRIDGE-014: Valuation per IRS/tax authority rules
- BR-TR-BRIDGE-015: De minimis benefits excluded

**Related Entities**:
- TaxableComponent
- ComponentTaxMapping

**API Endpoints**:
- `POST /api/v1/tax-bridge/fringe-benefits`
- `GET /api/v1/tax-bridge/fringe-benefits`
- `POST /api/v1/tax-bridge/fringe-benefits/calculate`

---

#### FR-TR-BRIDGE-006: Tax Treatment Validation

**Priority**: LOW

**User Story**:
```
As a Tax Administrator
I want to validate tax treatment
So that I can ensure compliance and accuracy
```

**Description**:
The system shall validate tax treatment of compensation components.

**Acceptance Criteria**:
- Given I am a Tax Administrator
- When I run tax treatment validation
- Then the system checks:
  * All components have tax mappings
  * Tax categories are appropriate
  * Taxable wage calculations are correct
  * No conflicting mappings
  * Compliance with tax rules
- And the system flags:
  * Components without tax mapping
  * Unusual tax treatment
  * Potential compliance issues
  * Calculation anomalies
- And I can:
  * View validation results
  * Generate validation report
  * Resolve flagged issues
  * Track validation history
- And the system:
  * Runs validation monthly
  * Sends alerts for critical issues
  * Provides remediation guidance

**Dependencies**:
- FR-TR-BRIDGE-002: Component Tax Mapping
- FR-TR-BRIDGE-003: Taxable Wage Calculation

**Business Rules**:
- BR-TR-BRIDGE-016: All components must have tax mapping
- BR-TR-BRIDGE-017: Validation run before tax filing
- BR-TR-BRIDGE-018: Critical issues must be resolved

**Related Entities**:
- ComponentTaxMapping
- TaxableWageCalculation

**API Endpoints**:
- `POST /api/v1/tax-bridge/validate`
- `GET /api/v1/tax-bridge/validation/{id}`
- `GET /api/v1/tax-bridge/validation/issues`

---

## Summary: Taxable Bridge

**Total Requirements**: 6  
**Priority Breakdown**:
- HIGH: 3 requirements
- MEDIUM: 2 requirements  
- LOW: 1 requirement

**Key Features**:
- Tax category definition
- Component-to-tax mapping
- Taxable wage calculation
- Tax reporting integration
- Fringe benefit valuation
- Tax treatment validation

**Progress**: 111/131 FRs complete (85%)

**Remaining Sub-Modules**: Audit (8 FRs), Calculation Rules (12 FRs) - 20 FRs remaining

---

*Document continues with remaining sub-modules...*

## 🎯 Feature Area 10: Audit

### Overview

Audit manages comprehensive audit trails for all TR module activities, ensuring compliance, traceability, and data integrity. This includes change tracking, approval history, data retention, and audit reporting.

**Related Entities**: AuditLog, ChangeHistory, ApprovalHistory, DataRetentionPolicy

**Related Concept Guide**: Audit and Compliance Guide (to be created)

---

#### FR-TR-AUDIT-001: Change Tracking

**Priority**: MEDIUM

**User Story**:
```
As a System Administrator
I want to track all changes to TR data
So that I can maintain audit trail for compliance
```

**Description**:
The system shall automatically track all changes to TR module entities with complete before/after values.

**Acceptance Criteria**:
- Given any TR entity is created, updated, or deleted
- When the change occurs
- Then the system creates AuditLog record with:
  * Entity type (e.g., CompensationAdjustment, BenefitPlan)
  * Entity ID
  * Action (CREATE, UPDATE, DELETE)
  * User ID (who made change)
  * Timestamp
  * Before values (JSON)
  * After values (JSON)
  * Change reason (if provided)
  * IP address
  * Session ID
- And the system tracks changes to:
  * Compensation adjustments
  * Benefit enrollments
  * Deductions
  * Tax profiles
  * Offers
  * All master data
- And I can:
  * Query audit logs by entity
  * Query by user
  * Query by date range
  * Query by action type
  * Export audit reports
- And audit records are:
  * Immutable (cannot be modified)
  * Retained per retention policy
  * Encrypted for sensitive data

**Dependencies**:
- All TR module features

**Business Rules**:
- BR-TR-AUDIT-001: All changes automatically logged
- BR-TR-AUDIT-002: Audit records immutable
- BR-TR-AUDIT-003: Sensitive data encrypted in audit logs
- BR-TR-AUDIT-004: Retention period = 7 years minimum

**Related Entities**:
- AuditLog
- All TR entities

**API Endpoints**:
- `GET /api/v1/audit/logs`
- `GET /api/v1/audit/logs/entity/{type}/{id}`
- `GET /api/v1/audit/logs/user/{id}`
- `GET /api/v1/audit/logs/export`

---

#### FR-TR-AUDIT-002: Approval History Tracking

**Priority**: MEDIUM

**User Story**:
```
As a Compliance Officer
I want to track all approval decisions
So that I can audit approval workflows
```

**Description**:
The system shall track complete approval history for all approval workflows.

**Acceptance Criteria**:
- Given any approval decision is made
- When the approval/rejection occurs
- Then the system creates ApprovalHistory record with:
  * Entity type (CompensationAdjustment, Offer, etc.)
  * Entity ID
  * Approval level
  * Approver ID
  * Decision (APPROVED, REJECTED, DELEGATED)
  * Decision date
  * Comments
  * Routing rules applied
  * Previous approver (if delegated)
- And the system tracks:
  * Compensation adjustment approvals
  * Offer approvals
  * Bonus allocation approvals
  * Deduction approvals
  * All approval workflows
- And I can:
  * View complete approval chain
  * See approval timeline
  * Identify bottlenecks
  * Generate approval reports
  * Analyze approval patterns
- And the system shows:
  * Average approval time
  * Approval rate by approver
  * Rejection reasons
  * Delegation patterns

**Dependencies**:
- FR-TR-COMP-007: Compensation Adjustment Approval
- FR-TR-OFFER-003: Offer Approval
- FR-TR-VAR-004: Bonus Approval

**Business Rules**:
- BR-TR-AUDIT-005: All approval decisions logged
- BR-TR-AUDIT-006: Approval history immutable
- BR-TR-AUDIT-007: Complete approval chain visible

**Related Entities**:
- ApprovalHistory
- CompensationAdjustment
- OfferPackage
- BonusAllocation

**API Endpoints**:
- `GET /api/v1/audit/approvals`
- `GET /api/v1/audit/approvals/entity/{type}/{id}`
- `GET /api/v1/audit/approvals/approver/{id}`
- `GET /api/v1/audit/approvals/analytics`

---

#### FR-TR-AUDIT-003: Data Access Logging

**Priority**: MEDIUM

**User Story**:
```
As a Security Administrator
I want to log data access
So that I can detect unauthorized access to sensitive data
```

**Description**:
The system shall log all access to sensitive TR data for security monitoring.

**Acceptance Criteria**:
- Given a user accesses sensitive data
- When the access occurs
- Then the system logs:
  * User ID
  * Data type (salary, tax ID, etc.)
  * Entity ID
  * Access type (VIEW, EXPORT, PRINT)
  * Timestamp
  * IP address
  * Access reason (if required)
- And sensitive data includes:
  * Employee salaries
  * Tax IDs
  * Bank account numbers
  * Benefit elections
  * Performance ratings
- And I can:
  * Monitor access patterns
  * Detect unusual access
  * Generate access reports
  * Alert on suspicious activity
- And the system:
  * Flags access outside business hours
  * Flags bulk exports
  * Flags access to terminated employees
  * Sends alerts for violations

**Dependencies**:
- All TR module features with sensitive data

**Business Rules**:
- BR-TR-AUDIT-008: Sensitive data access logged
- BR-TR-AUDIT-009: Access logs retained 7 years
- BR-TR-AUDIT-010: Suspicious access triggers alerts

**Related Entities**:
- AuditLog

**API Endpoints**:
- `GET /api/v1/audit/access-logs`
- `GET /api/v1/audit/access-logs/user/{id}`
- `GET /api/v1/audit/access-logs/suspicious`

---

#### FR-TR-AUDIT-004: Compliance Audit Reports

**Priority**: MEDIUM

**User Story**:
```
As a Compliance Officer
I want to generate compliance audit reports
So that I can demonstrate regulatory compliance
```

**Description**:
The system shall generate comprehensive compliance audit reports.

**Acceptance Criteria**:
- Given I am a Compliance Officer
- When I generate audit reports
- Then I can generate:
  * Compensation change audit
  * Benefit enrollment audit
  * Tax compliance audit
  * Deduction audit
  * Approval workflow audit
  * Data access audit
- And each report includes:
  * Report period
  * Total transactions
  * Changes by type
  * Approval statistics
  * Compliance violations (if any)
  * Remediation actions
- And I can:
  * Filter by date range
  * Filter by entity type
  * Filter by user
  * Export to PDF/Excel
  * Schedule recurring reports
- And the system:
  * Validates data completeness
  * Highlights anomalies
  * Provides drill-down capability
  * Supports external auditor access

**Dependencies**:
- FR-TR-AUDIT-001: Change Tracking
- FR-TR-AUDIT-002: Approval History

**Business Rules**:
- BR-TR-AUDIT-011: Reports reflect actual audit data
- BR-TR-AUDIT-012: External auditors have read-only access
- BR-TR-AUDIT-013: Reports support regulatory requirements

**Related Entities**:
- AuditLog
- ApprovalHistory

**API Endpoints**:
- `POST /api/v1/audit/reports/generate`
- `GET /api/v1/audit/reports`
- `GET /api/v1/audit/reports/{id}/export`

---

#### FR-TR-AUDIT-005: Data Retention Management

**Priority**: LOW

**User Story**:
```
As a System Administrator
I want to manage data retention policies
So that I can comply with legal requirements
```

**Description**:
The system shall manage data retention policies for TR data.

**Acceptance Criteria**:
- Given I am a System Administrator
- When I configure retention policies
- Then I can define:
  * Entity type
  * Retention period (years)
  * Archive method (ARCHIVE, DELETE, ANONYMIZE)
  * Legal hold flag
- And I can configure policies for:
  * Compensation data: 7 years
  * Tax data: 7 years
  * Benefit data: 7 years
  * Audit logs: 7 years
  * Temporary data: 1 year
- And the system:
  * Automatically archives old data
  * Prevents deletion of data on legal hold
  * Anonymizes data after retention period
  * Maintains audit trail of retention actions
- And I can:
  * View retention status
  * Place legal holds
  * Restore archived data
  * Generate retention reports

**Dependencies**:
- All TR module features

**Business Rules**:
- BR-TR-AUDIT-014: Minimum retention = 7 years
- BR-TR-AUDIT-015: Legal hold prevents deletion
- BR-TR-AUDIT-016: Archived data accessible for audits

**Related Entities**:
- DataRetentionPolicy
- All TR entities

**API Endpoints**:
- `POST /api/v1/audit/retention-policies`
- `GET /api/v1/audit/retention-policies`
- `POST /api/v1/audit/retention/archive`
- `POST /api/v1/audit/retention/legal-hold`

---

#### FR-TR-AUDIT-006: Version History

**Priority**: LOW

**User Story**:
```
As an HR Administrator
I want to view version history
So that I can see how data has changed over time
```

**Description**:
The system shall maintain version history for key TR entities.

**Acceptance Criteria**:
- Given I am an HR Administrator
- When I view version history
- Then I can see:
  * All versions of entity
  * Version number
  * Effective dates
  * Changed by
  * Change timestamp
  * What changed (diff view)
- And I can view history for:
  * Compensation plans
  * Benefit plans
  * Tax rules
  * Deduction types
  * Offer templates
- And I can:
  * Compare versions side-by-side
  * Restore previous version
  * View change summary
  * Export version history
- And the system:
  * Uses SCD Type 2 for temporal data
  * Maintains complete version chain
  * Prevents version gaps

**Dependencies**:
- FR-TR-AUDIT-001: Change Tracking

**Business Rules**:
- BR-TR-AUDIT-017: Version chain must be complete
- BR-TR-AUDIT-018: Current version clearly marked
- BR-TR-AUDIT-019: Restore creates new version

**Related Entities**:
- ChangeHistory
- GradeVersion (example)

**API Endpoints**:
- `GET /api/v1/audit/versions/{type}/{id}`
- `GET /api/v1/audit/versions/{type}/{id}/compare`
- `POST /api/v1/audit/versions/{type}/{id}/restore`

---

#### FR-TR-AUDIT-007: Audit Trail Export

**Priority**: LOW

**User Story**:
```
As a Compliance Officer
I want to export audit trails
So that I can provide data to external auditors
```

**Description**:
The system shall support export of audit trails in various formats.

**Acceptance Criteria**:
- Given I am a Compliance Officer
- When I export audit trails
- Then I can:
  * Select date range
  * Select entity types
  * Select users
  * Choose export format (CSV, Excel, JSON, PDF)
  * Include/exclude sensitive data
- And the export includes:
  * All audit log records
  * Approval history
  * Access logs
  * Change history
- And I can:
  * Schedule recurring exports
  * Export to secure location (SFTP)
  * Encrypt export files
  * Generate export manifest
- And the system:
  * Validates export completeness
  * Logs export activity
  * Supports large exports (pagination)
  * Provides download links

**Dependencies**:
- FR-TR-AUDIT-001: Change Tracking
- FR-TR-AUDIT-002: Approval History

**Business Rules**:
- BR-TR-AUDIT-020: Exports include all selected data
- BR-TR-AUDIT-021: Sensitive data requires approval
- BR-TR-AUDIT-022: Export activity logged

**Related Entities**:
- AuditLog
- ApprovalHistory

**API Endpoints**:
- `POST /api/v1/audit/export`
- `GET /api/v1/audit/export/{id}/status`
- `GET /api/v1/audit/export/{id}/download`

---

#### FR-TR-AUDIT-008: Audit Alerting

**Priority**: LOW

**User Story**:
```
As a Security Administrator
I want to receive alerts for audit events
So that I can respond to compliance issues quickly
```

**Description**:
The system shall send alerts for critical audit events.

**Acceptance Criteria**:
- Given I am a Security Administrator
- When I configure audit alerts
- Then I can define alerts for:
  * Unauthorized data access
  * Bulk data exports
  * Failed approval attempts
  * Unusual compensation changes
  * Tax calculation errors
  * Compliance violations
- And I can configure:
  * Alert conditions (thresholds, patterns)
  * Alert recipients
  * Alert channels (email, SMS, dashboard)
  * Alert severity (INFO, WARNING, CRITICAL)
  * Alert frequency (real-time, daily digest)
- And the system:
  * Evaluates alert conditions continuously
  * Sends notifications immediately for critical alerts
  * Batches non-critical alerts
  * Tracks alert resolution
- And I can:
  * View alert history
  * Acknowledge alerts
  * Assign alerts for investigation
  * Generate alert reports

**Dependencies**:
- FR-TR-AUDIT-001: Change Tracking
- FR-TR-AUDIT-003: Data Access Logging

**Business Rules**:
- BR-TR-AUDIT-023: Critical alerts sent immediately
- BR-TR-AUDIT-024: Alert conditions configurable
- BR-TR-AUDIT-025: Alert history retained

**Related Entities**:
- AuditLog

**API Endpoints**:
- `POST /api/v1/audit/alerts/configure`
- `GET /api/v1/audit/alerts`
- `POST /api/v1/audit/alerts/{id}/acknowledge`

---

## Summary: Audit

**Total Requirements**: 8  
**Priority Breakdown**:
- HIGH: 0 requirements
- MEDIUM: 5 requirements  
- LOW: 3 requirements

**Key Features**:
- Comprehensive change tracking
- Approval history tracking
- Data access logging
- Compliance audit reports
- Data retention management
- Version history
- Audit trail export
- Audit alerting

---

## 🎯 Feature Area 11: Calculation Rules

### Overview

Calculation Rules manages the formula engine, calculation rules, and business logic for all TR calculations. This includes formula definition, versioning, testing, performance optimization, and integration with payroll.

**Related Entities**: CalculationFormula, FormulaVersion, FormulaVariable, CalculationRule, RuleTest, FormulaExecution

**Related Concept Guide**: Calculation Engine Guide (to be created)

---

#### FR-TR-CALC-001: Formula Definition

**Priority**: HIGH

**User Story**:
```
As a Compensation Administrator
I want to define calculation formulas
So that I can automate complex compensation calculations
```

**Description**:
The system shall allow administrators to define calculation formulas using a formula language.

**Acceptance Criteria**:
- Given I am a Compensation Administrator
- When I create a formula
- Then I must provide:
  * Unique code (e.g., MERIT_INCREASE_CALC)
  * Name
  * Description
  * Formula expression
  * Return type (NUMBER, PERCENTAGE, BOOLEAN, TEXT)
  * Category (COMPENSATION, TAX, BENEFIT, DEDUCTION)
- And I can use:
  * Arithmetic operators (+, -, *, /, %)
  * Comparison operators (=, !=, >, <, >=, <=)
  * Logical operators (AND, OR, NOT)
  * Functions (IF, MAX, MIN, ROUND, SUM, AVG, etc.)
  * Variables (salary, performance_rating, compa_ratio, etc.)
  * Constants
- And the system validates:
  * Formula syntax
  * Variable references
  * Return type consistency
  * No circular dependencies
- And I can:
  * Test formula with sample data
  * View formula documentation
  * Version formulas
  * Activate/deactivate

**Dependencies**:
- None

**Business Rules**:
- BR-TR-CALC-001: Formula code must be unique
- BR-TR-CALC-002: Formula syntax must be valid
- BR-TR-CALC-003: Variables must be defined
- BR-TR-CALC-004: No circular dependencies

**Related Entities**:
- CalculationFormula

**API Endpoints**:
- `POST /api/v1/calculation/formulas`
- `GET /api/v1/calculation/formulas`
- `GET /api/v1/calculation/formulas/{id}`
- `PUT /api/v1/calculation/formulas/{id}`
- `POST /api/v1/calculation/formulas/{id}/validate`

---

#### FR-TR-CALC-002: Variable Management

**Priority**: HIGH

**User Story**:
```
As a Compensation Administrator
I want to define formula variables
So that formulas can reference dynamic data
```

**Description**:
The system shall allow administrators to define variables for use in formulas.

**Acceptance Criteria**:
- Given I am a Compensation Administrator
- When I define a variable
- Then I must provide:
  * Variable name (e.g., base_salary, tenure_months)
  * Data type (NUMBER, TEXT, DATE, BOOLEAN)
  * Source (EMPLOYEE, ASSIGNMENT, COMPENSATION, PERFORMANCE, CUSTOM)
  * Source field/path
  * Default value (optional)
- And I can define:
  * Employee variables: hire_date, department, grade
  * Compensation variables: salary, compa_ratio, last_increase
  * Performance variables: rating, score, rank
  * Custom variables: calculated fields
- And the system:
  * Validates variable names (no spaces, reserved words)
  * Validates data types
  * Resolves variable values at runtime
  * Caches frequently used variables
- And I can:
  * View all variables
  * Test variable resolution
  * Document variables
  * Version variables

**Dependencies**:
- FR-TR-CALC-001: Formula Definition

**Business Rules**:
- BR-TR-CALC-005: Variable names must be unique
- BR-TR-CALC-006: Variable source must be valid
- BR-TR-CALC-007: Variables resolved at execution time

**Related Entities**:
- FormulaVariable

**API Endpoints**:
- `POST /api/v1/calculation/variables`
- `GET /api/v1/calculation/variables`
- `GET /api/v1/calculation/variables/{id}`
- `POST /api/v1/calculation/variables/{id}/test`

---

#### FR-TR-CALC-003: Calculation Rule Engine

**Priority**: HIGH

**User Story**:
```
As a Compensation Administrator
I want to define calculation rules
So that I can implement complex business logic
```

**Description**:
The system shall provide a rule engine for defining conditional calculation logic.

**Acceptance Criteria**:
- Given I am a Compensation Administrator
- When I create a calculation rule
- Then I must provide:
  * Rule code and name
  * Rule type (MERIT_MATRIX, BONUS_CALC, TAX_CALC, PRORATION, etc.)
  * Conditions (IF-THEN-ELSE logic)
  * Actions (formulas to execute)
  * Priority/sequence
- And I can define:
  * Merit matrix rules:
    - IF performance = "Exceeds" AND compa_ratio < 90% THEN increase = 8%
    - IF performance = "Meets" AND compa_ratio 90-110% THEN increase = 4%
  * Bonus calculation rules:
    - IF achievement >= 120% THEN bonus = target * 1.5
    - IF achievement >= 100% THEN bonus = target * 1.0
  * Tax calculation rules:
    - IF taxable_income > threshold THEN apply_bracket
  * Proration rules:
    - IF start_date > period_start THEN prorate_by_days
- And the system:
  * Evaluates conditions in priority order
  * Executes matching actions
  * Supports nested conditions
  * Logs rule execution
- And I can:
  * Test rules with sample data
  * View rule execution trace
  * Version rules
  * Activate/deactivate

**Dependencies**:
- FR-TR-CALC-001: Formula Definition
- FR-TR-CALC-002: Variable Management

**Business Rules**:
- BR-TR-CALC-008: Rules evaluated in priority order
- BR-TR-CALC-009: First matching rule wins (unless configured otherwise)
- BR-TR-CALC-010: Rule execution logged for audit

**Related Entities**:
- CalculationRule

**API Endpoints**:
- `POST /api/v1/calculation/rules`
- `GET /api/v1/calculation/rules`
- `GET /api/v1/calculation/rules/{id}`
- `POST /api/v1/calculation/rules/{id}/test`
- `POST /api/v1/calculation/rules/{id}/execute`

---

#### FR-TR-CALC-004: Formula Versioning

**Priority**: MEDIUM

**User Story**:
```
As a Compensation Administrator
I want to version formulas
So that I can manage formula changes over time
```

**Description**:
The system shall support versioning of formulas and rules.

**Acceptance Criteria**:
- Given I am a Compensation Administrator
- When I update a formula
- Then the system:
  * Creates new version (version_number + 1)
  * Links to previous version
  * Sets effective dates
  * Marks current version
- And I can:
  * View version history
  * Compare versions
  * Activate specific version
  * Rollback to previous version
- And the system:
  * Uses correct version based on effective date
  * Maintains version chain
  * Prevents version gaps
  * Archives old versions
- And I can configure:
  * Version effective dates
  * Version approval workflow
  * Version testing requirements

**Dependencies**:
- FR-TR-CALC-001: Formula Definition

**Business Rules**:
- BR-TR-CALC-011: Only one active version per effective date
- BR-TR-CALC-012: Version chain must be complete
- BR-TR-CALC-013: Historical versions retained

**Related Entities**:
- FormulaVersion

**API Endpoints**:
- `GET /api/v1/calculation/formulas/{id}/versions`
- `POST /api/v1/calculation/formulas/{id}/versions`
- `POST /api/v1/calculation/formulas/{id}/versions/{version}/activate`

---

#### FR-TR-CALC-005: Formula Testing

**Priority**: HIGH

**User Story**:
```
As a Compensation Administrator
I want to test formulas
So that I can ensure calculations are correct before deployment
```

**Description**:
The system shall provide comprehensive formula testing capabilities.

**Acceptance Criteria**:
- Given I am a Compensation Administrator
- When I test a formula
- Then I can:
  * Create test cases with input values
  * Define expected output
  * Run tests
  * View actual vs expected results
  * Save test cases for regression
- And I can test:
  * Individual formulas
  * Calculation rules
  * Complete calculation flows
- And the system:
  * Executes formula with test data
  * Compares actual vs expected
  * Highlights failures
  * Provides execution trace
  * Logs test results
- And I can:
  * Create test suites
  * Run batch tests
  * Schedule automated tests
  * Generate test reports
- And the system validates:
  * Edge cases (min, max, zero, null)
  * Boundary conditions
  * Error handling

**Dependencies**:
- FR-TR-CALC-001: Formula Definition
- FR-TR-CALC-003: Calculation Rule Engine

**Business Rules**:
- BR-TR-CALC-014: All formulas must pass tests before activation
- BR-TR-CALC-015: Test cases retained for regression
- BR-TR-CALC-016: Critical formulas require approval after testing

**Related Entities**:
- RuleTest
- CalculationFormula

**API Endpoints**:
- `POST /api/v1/calculation/tests`
- `GET /api/v1/calculation/tests`
- `POST /api/v1/calculation/tests/{id}/run`
- `GET /api/v1/calculation/tests/{id}/results`

---

#### FR-TR-CALC-006: Formula Execution Engine

**Priority**: HIGH

**User Story**:
```
As the System
I want to execute formulas efficiently
So that calculations complete quickly during payroll
```

**Description**:
The system shall provide a high-performance formula execution engine.

**Acceptance Criteria**:
- Given a formula needs to be executed
- When execution is triggered
- Then the system:
  * Parses formula expression
  * Resolves variables
  * Evaluates expression
  * Returns result
  * Logs execution (if configured)
- And the engine supports:
  * Synchronous execution (immediate)
  * Asynchronous execution (batch)
  * Parallel execution (multiple employees)
  * Cached execution (repeated calculations)
- And the engine optimizes:
  * Variable resolution (caching)
  * Expression parsing (compilation)
  * Execution plan (query optimization)
  * Memory usage
- And the engine handles:
  * Errors gracefully (try-catch)
  * Timeouts (max execution time)
  * Recursion limits
  * Division by zero
  * Null values
- And I can:
  * Monitor execution performance
  * View execution logs
  * Debug formula execution
  * Optimize slow formulas

**Dependencies**:
- FR-TR-CALC-001: Formula Definition
- FR-TR-CALC-002: Variable Management

**Business Rules**:
- BR-TR-CALC-017: Execution timeout = 30 seconds
- BR-TR-CALC-018: Errors logged and returned
- BR-TR-CALC-019: Null values handled per configuration

**Related Entities**:
- FormulaExecution
- CalculationFormula

**API Endpoints**:
- `POST /api/v1/calculation/execute`
- `POST /api/v1/calculation/execute/batch`
- `GET /api/v1/calculation/execution/{id}`

---

#### FR-TR-CALC-007: Calculation Audit Trail

**Priority**: MEDIUM

**User Story**:
```
As a Compensation Manager
I want to see calculation audit trail
So that I can understand how values were calculated
```

**Description**:
The system shall maintain audit trail for all calculations.

**Acceptance Criteria**:
- Given a calculation is executed
- When execution completes
- Then the system logs:
  * Formula/rule used
  * Input variables and values
  * Calculation steps
  * Result
  * Execution time
  * Timestamp
  * Triggered by (user/system)
- And I can:
  * View calculation history for employee
  * See detailed execution trace
  * Replay calculations
  * Export calculation logs
- And the system shows:
  * Which formula version was used
  * Variable values at execution time
  * Intermediate calculation steps
  * Final result
- And I can:
  * Filter by employee
  * Filter by formula
  * Filter by date range
  * Search by result value

**Dependencies**:
- FR-TR-CALC-006: Formula Execution Engine

**Business Rules**:
- BR-TR-CALC-020: All calculations logged
- BR-TR-CALC-021: Calculation logs retained 7 years
- BR-TR-CALC-022: Logs support audit requirements

**Related Entities**:
- FormulaExecution

**API Endpoints**:
- `GET /api/v1/calculation/audit/executions`
- `GET /api/v1/calculation/audit/employee/{id}`
- `GET /api/v1/calculation/audit/formula/{id}`

---

#### FR-TR-CALC-008: Formula Library

**Priority**: MEDIUM

**User Story**:
```
As a Compensation Administrator
I want to access a formula library
So that I can reuse common formulas
```

**Description**:
The system shall provide a library of pre-built formulas for common calculations.

**Acceptance Criteria**:
- Given I am a Compensation Administrator
- When I browse formula library
- Then I can find formulas for:
  * Merit increase calculations
  * Bonus calculations
  * Compa-ratio calculations
  * Proration calculations
  * Tax calculations
  * Deduction calculations
- And each formula includes:
  * Name and description
  * Formula expression
  * Required variables
  * Example usage
  * Test cases
  * Documentation
- And I can:
  * Search formulas by keyword
  * Filter by category
  * Preview formula
  * Copy to my formulas
  * Customize copied formula
- And the library includes:
  * Standard formulas (system-provided)
  * Custom formulas (user-created, shared)
  * Industry best practices

**Dependencies**:
- FR-TR-CALC-001: Formula Definition

**Business Rules**:
- BR-TR-CALC-023: Library formulas are templates
- BR-TR-CALC-024: Copying creates new formula
- BR-TR-CALC-025: Library updated with releases

**Related Entities**:
- CalculationFormula

**API Endpoints**:
- `GET /api/v1/calculation/library`
- `GET /api/v1/calculation/library/{id}`
- `POST /api/v1/calculation/library/{id}/copy`

---

#### FR-TR-CALC-009: Formula Documentation

**Priority**: LOW

**User Story**:
```
As a Compensation Administrator
I want to document formulas
So that others can understand and maintain them
```

**Description**:
The system shall support comprehensive formula documentation.

**Acceptance Criteria**:
- Given I am a Compensation Administrator
- When I document a formula
- Then I can provide:
  * Purpose and description
  * Business logic explanation
  * Variable definitions
  * Example calculations
  * Edge cases
  * Change history
  * Related formulas
- And the system:
  * Generates documentation from formula metadata
  * Supports markdown formatting
  * Links to related entities
  * Versions documentation with formula
- And I can:
  * Export documentation (PDF, HTML)
  * Share documentation
  * Print documentation
  * Search documentation
- And documentation includes:
  * Auto-generated sections (syntax, variables)
  * User-provided sections (business logic, examples)
  * System-generated sections (version history, usage)

**Dependencies**:
- FR-TR-CALC-001: Formula Definition

**Business Rules**:
- BR-TR-CALC-026: Documentation versioned with formula
- BR-TR-CALC-027: Critical formulas require documentation
- BR-TR-CALC-028: Documentation accessible to all users

**Related Entities**:
- CalculationFormula

**API Endpoints**:
- `GET /api/v1/calculation/formulas/{id}/documentation`
- `PUT /api/v1/calculation/formulas/{id}/documentation`
- `GET /api/v1/calculation/formulas/{id}/documentation/export`

---

#### FR-TR-CALC-010: Performance Optimization

**Priority**: MEDIUM

**User Story**:
```
As a System Administrator
I want to optimize formula performance
So that calculations complete quickly
```

**Description**:
The system shall provide tools for optimizing formula performance.

**Acceptance Criteria**:
- Given I am a System Administrator
- When I analyze formula performance
- Then I can view:
  * Execution time statistics
  * Slowest formulas
  * Most frequently executed formulas
  * Resource usage (CPU, memory)
  * Bottlenecks
- And I can:
  * Profile formula execution
  * Identify optimization opportunities
  * Test optimizations
  * Compare before/after performance
- And the system provides:
  * Caching recommendations
  * Query optimization suggestions
  * Index recommendations
  * Parallelization opportunities
- And I can optimize:
  * Variable resolution (caching)
  * Expression parsing (compilation)
  * Database queries (indexing)
  * Batch processing (parallelization)
- And the system:
  * Monitors performance continuously
  * Alerts on performance degradation
  * Suggests optimizations
  * Tracks optimization impact

**Dependencies**:
- FR-TR-CALC-006: Formula Execution Engine

**Business Rules**:
- BR-TR-CALC-029: Performance monitored continuously
- BR-TR-CALC-030: Slow formulas flagged (>5 seconds)
- BR-TR-CALC-031: Optimizations tested before deployment

**Related Entities**:
- FormulaExecution

**API Endpoints**:
- `GET /api/v1/calculation/performance/statistics`
- `GET /api/v1/calculation/performance/slow-formulas`
- `POST /api/v1/calculation/performance/profile`

---

#### FR-TR-CALC-011: Formula Dependency Management

**Priority**: LOW

**User Story**:
```
As a Compensation Administrator
I want to manage formula dependencies
So that I can understand formula relationships
```

**Description**:
The system shall track and manage dependencies between formulas.

**Acceptance Criteria**:
- Given I am a Compensation Administrator
- When I view formula dependencies
- Then I can see:
  * Formulas that this formula depends on
  * Formulas that depend on this formula
  * Variables used by this formula
  * Rules that use this formula
- And the system:
  * Builds dependency graph
  * Detects circular dependencies
  * Validates dependency chain
  * Alerts on breaking changes
- And I can:
  * View dependency tree
  * Analyze impact of changes
  * Test dependency chain
  * Export dependency report
- And when I modify a formula:
  * System shows dependent formulas
  * Warns of potential impacts
  * Requires testing of dependents
  * Tracks cascade changes

**Dependencies**:
- FR-TR-CALC-001: Formula Definition

**Business Rules**:
- BR-TR-CALC-032: No circular dependencies allowed
- BR-TR-CALC-033: Dependency changes require testing
- BR-TR-CALC-034: Breaking changes require approval

**Related Entities**:
- CalculationFormula

**API Endpoints**:
- `GET /api/v1/calculation/formulas/{id}/dependencies`
- `GET /api/v1/calculation/formulas/{id}/dependents`
- `POST /api/v1/calculation/formulas/{id}/impact-analysis`

---

#### FR-TR-CALC-012: Calculation Scheduling

**Priority**: LOW

**User Story**:
```
As a Payroll Administrator
I want to schedule calculations
So that batch calculations run automatically
```

**Description**:
The system shall support scheduling of batch calculations.

**Acceptance Criteria**:
- Given I am a Payroll Administrator
- When I schedule a calculation
- Then I can specify:
  * Calculation type (merit, bonus, tax, etc.)
  * Schedule (daily, weekly, monthly, one-time)
  * Execution time
  * Target employees (all, department, specific list)
  * Notification recipients
- And the system:
  * Executes calculations on schedule
  * Handles failures gracefully
  * Retries on transient errors
  * Sends notifications on completion
- And I can:
  * View scheduled calculations
  * Monitor execution status
  * View execution history
  * Cancel scheduled executions
  * Modify schedules
- And the system:
  * Queues calculations for execution
  * Processes in priority order
  * Limits concurrent executions
  * Logs all executions

**Dependencies**:
- FR-TR-CALC-006: Formula Execution Engine

**Business Rules**:
- BR-TR-CALC-035: Scheduled calculations run automatically
- BR-TR-CALC-036: Failed calculations retried 3 times
- BR-TR-CALC-037: Notifications sent on completion/failure

**Related Entities**:
- FormulaExecution

**API Endpoints**:
- `POST /api/v1/calculation/schedules`
- `GET /api/v1/calculation/schedules`
- `PUT /api/v1/calculation/schedules/{id}`
- `DELETE /api/v1/calculation/schedules/{id}`

---

## Summary: Calculation Rules

**Total Requirements**: 12  
**Priority Breakdown**:
- HIGH: 8 requirements
- MEDIUM: 0 requirements  
- LOW: 4 requirements

**Key Features**:
- Formula definition and management
- Variable management
- Rule engine with conditional logic
- Formula versioning
- Comprehensive testing
- High-performance execution engine
- Calculation audit trail
- Formula library and documentation
- Performance optimization
- Dependency management
- Calculation scheduling

---

## 🎉 Document Complete!

**Total Functional Requirements**: 131  
**Priority Breakdown**:
- HIGH: 68 requirements (52%)
- MEDIUM: 37 requirements (28%)
- LOW: 26 requirements (20%)

**Sub-Modules Completed**: 11
1. ✅ Core Compensation (18 FRs)
2. ✅ Variable Pay (15 FRs)
3. ✅ Benefits (20 FRs)
4. ✅ Recognition (10 FRs)
5. ✅ Offer Management (12 FRs)
6. ✅ TR Statement (8 FRs)
7. ✅ Deductions (10 FRs)
8. ✅ Tax Withholding (12 FRs)
9. ✅ Taxable Bridge (6 FRs)
10. ✅ Audit (8 FRs)
11. ✅ Calculation Rules (12 FRs)

**Next Steps**:
1. Review and refine functional requirements
2. Create Business Rules document (04-business-rules.md)
3. Create Data Specification document (03-data-specification.md)
4. Create API Specification document (02-api-specification.md)
5. Create Integration Specification (05-integration-spec.md)
6. Create Security Specification (06-security-spec.md)
7. Create End-to-End Scenarios (03-scenarios/)
8. Create Integration Guide (INTEGRATION-GUIDE.md)
9. Create Feature List (FEATURE-LIST.yaml)

---

**Document Status**: ✅ COMPLETE  
**Version**: 1.0  
**Last Updated**: 2025-12-08  
**Total Pages**: ~350 pages (estimated)  
**Total Business Rules**: ~300+ rules referenced  
**Total API Endpoints**: ~250+ endpoints defined

