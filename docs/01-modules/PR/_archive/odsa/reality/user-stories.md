# User Stories - Payroll Module (PR)

> **Module**: Payroll (PR)
> **Phase**: Reality (Step 2)
> **Date**: 2026-03-31
> **Version**: 1.0

---

## Overview

This document contains user stories derived from the Business Requirements Document. Each story follows the format:

- **As a** [actor]
- **I want to** [action]
- **So that** [benefit]

Acceptance Criteria use Gherkin format:
- **Given** [precondition]
- **When** [action]
- **Then** [expected result]

---

## Actors

| Actor | Description |
|-------|-------------|
| Payroll Admin | Primary user - configures pay elements, profiles, statutory rules |
| HR Manager | Reviews and approves configurations |
| Finance Controller | Configures GL mappings |
| Compliance Officer | Validates statutory rules |
| System | Automated processes |

---

## Epic 1: Pay Element Configuration

### US-001: Create Pay Element

**Priority**: P0 | **Story Points**: 5

**As a** Payroll Admin  
**I want to** create a new pay element with classification and calculation type  
**So that** I can define payroll components for the organization

**Acceptance Criteria**:

```gherkin
Scenario: Create pay element with all required fields
  Given I am logged in as Payroll Admin
  And I have permission to create pay elements
  When I create a pay element with:
    | elementCode    | SALARY_BASIC |
    | elementName    | Basic Salary |
    | classification | EARNING |
    | calculationType | FIXED |
    | statutoryFlag  | false |
    | taxableFlag    | true |
  Then the pay element is created successfully
  And the element has effectiveStartDate set to today
  And the element has effectiveEndDate as null
  And the element has isCurrentFlag = true
  And an audit log entry is created

Scenario: Duplicate element code is rejected
  Given I am logged in as Payroll Admin
  And a pay element with code "SALARY_BASIC" already exists
  When I create a pay element with code "SALARY_BASIC"
  Then the creation fails
  And an error message "Element code must be unique" is displayed

Scenario: Missing required fields show validation errors
  Given I am logged in as Payroll Admin
  When I create a pay element without elementCode
  Then the creation fails
  And an error message "Element code is required" is displayed
```

---

### US-002: Update Pay Element with Version Tracking

**Priority**: P0 | **Story Points**: 8

**As a** Payroll Admin  
**I want to** update a pay element with version tracking  
**So that** I can maintain historical records for audit and retroactive calculations

**Acceptance Criteria**:

```gherkin
Scenario: Update creates new version
  Given I am logged in as Payroll Admin
  And a pay element "SALARY_BASIC" exists with:
    | elementName | Basic Salary |
    | version     | 1 |
    | isCurrentFlag | true |
  When I update the element name to "Basic Monthly Salary" 
    And I provide change reason "Name clarification"
  Then a new version is created with:
    | version     | 2 |
    | elementName | Basic Monthly Salary |
    | isCurrentFlag | true |
  And the previous version has:
    | version     | 1 |
    | isCurrentFlag | false |
    | effectiveEndDate | today |
  And an audit log entry is created

Scenario: Preview changes before committing
  Given I am logged in as Payroll Admin
  And a pay element exists
  When I modify the element and select "Preview"
  Then I see a comparison of old and new values
  And I can choose to commit or cancel

Scenario: Effective date is in future
  Given I am logged in as Payroll Admin
  And a pay element exists
  When I update the element with effective date "2026-04-01"
  Then the new version is created
  And the current version remains active until 2026-03-31
```

---

### US-003: Soft Delete Pay Element

**Priority**: P0 | **Story Points**: 3

**As a** Payroll Admin  
**I want to** soft delete a pay element  
**So that** I can remove unused elements while preserving audit trail

**Acceptance Criteria**:

```gherkin
Scenario: Soft delete unused element
  Given I am logged in as Payroll Admin
  And a pay element "BONUS_OLD" exists
  And the element is not assigned to any active pay profile
  When I delete the element
  Then the element is marked as inactive
  And all historical versions are preserved
  And the element is excluded from active queries
  And an audit log entry is created

Scenario: Cannot delete element in use
  Given I am logged in as Payroll Admin
  And a pay element "SALARY_BASIC" exists
  And the element is assigned to an active pay profile
  When I attempt to delete the element
  Then the deletion fails
  And an error message "Cannot delete element in use by active profile" is displayed
  And the element remains active
```

---

### US-004: View Pay Element Classification Impact

**Priority**: P1 | **Story Points**: 2

**As a** Payroll Admin  
**I want to** understand how pay element classification affects gross and net pay  
**So that** I can correctly classify elements

**Acceptance Criteria**:

```gherkin
Scenario: EARNING classification increases gross and net
  Given I am viewing pay element creation
  When I select classification "EARNING"
  Then I see impact description "Increases Gross Pay, Increases Net Pay"

Scenario: DEDUCTION classification decreases gross and net
  Given I am viewing pay element creation
  When I select classification "DEDUCTION"
  Then I see impact description "Decreases Gross Pay, Decreases Net Pay"

Scenario: TAX classification decreases net only
  Given I am viewing pay element creation
  When I select classification "TAX"
  Then I see impact description "No Gross Impact, Decreases Net Pay"

Scenario: EMPLOYER_CONTRIBUTION is employer only
  Given I am viewing pay element creation
  When I select classification "EMPLOYER_CONTRIBUTION"
  Then I see impact description "Employer Cost Only, No Employee Impact"
```

---

## Epic 2: Pay Structure Configuration

### US-005: Create Pay Profile

**Priority**: P0 | **Story Points**: 5

**As a** Payroll Admin  
**I want to** create a pay profile to bundle pay elements and rules  
**So that** I can assign consistent payroll configuration to groups of employees

**Acceptance Criteria**:

```gherkin
Scenario: Create pay profile with required attributes
  Given I am logged in as Payroll Admin
  And I have permission to create pay profiles
  And legal entity "VN_HQ" exists
  And pay frequency "MONTHLY" exists
  When I create a pay profile with:
    | profileCode   | PROFILE_STAFF |
    | profileName   | Staff Profile |
    | legalEntityId | VN_HQ |
    | payFrequencyId | MONTHLY |
  Then the pay profile is created successfully
  And the profile has effectiveStartDate set to today
  And the profile has isCurrentFlag = true
  And an audit log entry is created

Scenario: Profile code must be unique per legal entity
  Given I am logged in as Payroll Admin
  And a pay profile "PROFILE_STAFF" exists for legal entity "VN_HQ"
  When I create a pay profile with:
    | profileCode   | PROFILE_STAFF |
    | legalEntityId | VN_HQ |
  Then the creation fails
  And an error message "Profile code must be unique per legal entity" is displayed

Scenario: Legal entity must exist
  Given I am logged in as Payroll Admin
  When I create a pay profile with legal entity "NONEXISTENT"
  Then the creation fails
  And an error message "Legal entity not found" is displayed
```

---

### US-006: Assign Pay Element to Profile

**Priority**: P0 | **Story Points**: 5

**As a** Payroll Admin  
**I want to** assign pay elements to a pay profile with priority and optional overrides  
**So that** I can define the payroll components for a group of employees

**Acceptance Criteria**:

```gherkin
Scenario: Assign element with priority
  Given I am logged in as Payroll Admin
  And a pay profile "PROFILE_STAFF" exists
  And a pay element "SALARY_BASIC" exists and is active
  When I assign element "SALARY_BASIC" to profile with:
    | priority | 10 |
  Then the assignment is created
  And the element is included in the profile

Scenario: Assign element with formula override
  Given I am logged in as Payroll Admin
  And a pay profile "PROFILE_STAFF" exists
  And a pay element "OT_REGULAR" exists with formula "hours * rate"
  When I assign element "OT_REGULAR" to profile with:
    | priority | 20 |
    | formulaOverride | "hours * rate * 1.5" |
  Then the assignment is created
  And the formula override replaces the element default

Scenario: Cannot assign same element twice
  Given I am logged in as Payroll Admin
  And pay element "SALARY_BASIC" is already assigned to profile "PROFILE_STAFF"
  When I attempt to assign "SALARY_BASIC" again
  Then the assignment fails
  And an error message "Element already assigned to profile" is displayed

Scenario: Cannot assign inactive element
  Given I am logged in as Payroll Admin
  And a pay element "BONUS_OLD" is inactive
  When I attempt to assign "BONUS_OLD" to profile
  Then the assignment fails
  And an error message "Cannot assign inactive element" is displayed
```

---

### US-007: Create Pay Calendar

**Priority**: P0 | **Story Points**: 5

**As a** Payroll Admin  
**I want to** create a pay calendar with pay periods  
**So that** I can define when payroll is processed for each period

**Acceptance Criteria**:

```gherkin
Scenario: Create calendar with auto-generated periods
  Given I am logged in as Payroll Admin
  And legal entity "VN_HQ" exists
  And pay frequency "MONTHLY" exists
  When I create a pay calendar with:
    | calendarCode  | CAL_2026 |
    | calendarName  | Calendar 2026 |
    | legalEntityId | VN_HQ |
    | payFrequencyId | MONTHLY |
    | fiscalYear    | 2026 |
  Then the calendar is created
  And 12 monthly periods are auto-generated
  And each period has:
    | periodNumber | Sequential 1-12 |
    | periodStartDate | First day of month |
    | periodEndDate | Last day of month |
    | cutOffDate | 25th of month |
    | payDate | Last day of month |

Scenario: Adjust individual period dates
  Given I am logged in as Payroll Admin
  And a pay calendar "CAL_2026" exists
  When I adjust period 1 with:
    | cutOffDate | 2026-01-23 |
    | payDate | 2026-01-30 |
  Then the period is updated
  And validation confirms cut-off before pay date

Scenario: Period dates must be sequential
  Given I am logged in as Payroll Admin
  And a pay calendar has period 1 ending on 2026-01-31
  When I set period 2 to start on 2026-02-02
  Then a warning "Period dates are not sequential" is displayed
```

---

### US-008: Create Pay Group and Assign Employees

**Priority**: P0 | **Story Points**: 5

**As a** Payroll Admin  
**I want to** create a pay group and assign employees  
**So that** employees receive the correct payroll configuration

**Acceptance Criteria**:

```gherkin
Scenario: Create pay group with profile and calendar
  Given I am logged in as Payroll Admin
  And a pay profile "PROFILE_STAFF" exists
  And a pay calendar "CAL_2026" exists
  When I create a pay group with:
    | groupCode   | GRP_STAFF |
    | groupName   | Staff Group |
    | payProfileId | PROFILE_STAFF |
    | payCalendarId | CAL_2026 |
  Then the pay group is created successfully
  And an audit log entry is created

Scenario: Assign employee to pay group
  Given I am logged in as Payroll Admin
  And a pay group "GRP_STAFF" exists
  And an employee "EMP001" exists
  When I assign employee "EMP001" to pay group "GRP_STAFF"
  Then the assignment is created
  And the employee is linked to the profile and calendar

Scenario: Employee can only be in one pay group
  Given I am logged in as Payroll Admin
  And employee "EMP001" is already in pay group "GRP_STAFF"
  When I attempt to assign "EMP001" to pay group "GRP_EXEC"
  Then the assignment fails
  And an error message "Employee already assigned to pay group GRP_STAFF" is displayed

Scenario: Profile and calendar must be active
  Given I am logged in as Payroll Admin
  And pay profile "PROFILE_OLD" is inactive
  When I attempt to create a pay group with profile "PROFILE_OLD"
  Then the creation fails
  And an error message "Profile must be active" is displayed
```

---

## Epic 3: Statutory Rule Management

### US-009: Create Statutory Rule

**Priority**: P0 | **Story Points**: 8

**As a** Payroll Admin  
**I want to** create statutory rules for Vietnam social insurance and tax  
**So that** payroll calculations comply with government regulations

**Acceptance Criteria**:

```gherkin
Scenario: Create BHXH Employee rule
  Given I am logged in as Payroll Admin
  When I create a statutory rule with:
    | ruleCode      | BHXH_EE |
    | ruleName      | Social Insurance Employee |
    | statutoryType | BHXH |
    | partyType     | EMPLOYEE |
    | rateType      | FIXED_RATE |
    | rate          | 0.08 |
    | ceilingAmount | 36000000 |
    | effectiveStartDate | 2026-01-01 |
  Then the rule is created successfully
  And the rule has version 1
  And an audit log entry is created

Scenario: Create BHXH Employer rule
  Given I am logged in as Payroll Admin
  When I create a statutory rule with:
    | ruleCode      | BHXH_ER |
    | ruleName      | Social Insurance Employer |
    | statutoryType | BHXH |
    | partyType     | EMPLOYER |
    | rateType      | FIXED_RATE |
    | rate          | 0.175 |
    | ceilingAmount | 36000000 |
    | effectiveStartDate | 2026-01-01 |
  Then the rule is created successfully

Scenario: Rate must be between 0 and 1
  Given I am logged in as Payroll Admin
  When I create a statutory rule with rate "1.5"
  Then the creation fails
  And an error message "Rate must be between 0 and 1" is displayed

Scenario: Ceiling amount required for social insurance
  Given I am logged in as Payroll Admin
  When I create a statutory rule with:
    | statutoryType | BHXH |
    | partyType     | EMPLOYEE |
    | ceilingAmount | null |
  Then the creation fails
  And an error message "Ceiling amount required for social insurance" is displayed
```

---

### US-010: Configure PIT Progressive Brackets

**Priority**: P0 | **Story Points**: 8

**As a** Payroll Admin  
**I want to** configure progressive tax brackets for PIT  
**So that** income tax is calculated correctly according to Vietnam regulations

**Acceptance Criteria**:

```gherkin
Scenario: Configure 7 PIT brackets
  Given I am logged in as Payroll Admin
  When I create a PIT rule with brackets:
    | bracket | minAmount | maxAmount | rate |
    | 1       | 0         | 5000000    | 0.05 |
    | 2       | 5000001   | 10000000   | 0.10 |
    | 3       | 10000001  | 18000000   | 0.15 |
    | 4       | 18000001  | 32000000   | 0.20 |
    | 5       | 32000001  | 52000000   | 0.25 |
    | 6       | 52000001  | 80000000   | 0.30 |
    | 7       | 80000001  | null       | 0.35 |
  Then the PIT rule is created with all 7 brackets
  And bracket 7 has no upper limit

Scenario: Brackets must cover full range
  Given I am logged in as Payroll Admin
  When I create a PIT rule with brackets that have a gap
  Then a warning "Brackets do not cover full income range" is displayed

Scenario: Set exemption amounts
  Given I am logged in as Payroll Admin
  And a PIT rule exists
  When I set exemptions:
    | personalExemption | 11000000 |
    | dependentExemption | 4400000 |
  Then the exemptions are saved with the PIT rule

Scenario: Dependent exemption calculation
  Given I am logged in as Payroll Admin
  And a PIT rule exists with dependentExemption = 4400000
  When an employee has 2 dependents
  Then the total dependent exemption is 8800000
```

---

### US-011: Update Statutory Rule with Versioning

**Priority**: P0 | **Story Points**: 5

**As a** Payroll Admin  
**I want to** update statutory rules when government rates change  
**So that** the system always uses current rates while preserving history

**Acceptance Criteria**:

```gherkin
Scenario: Rate change creates new version
  Given I am logged in as Payroll Admin
  And BHXH_EE rule exists with rate 0.08
  When I update the rule with:
    | rate | 0.085 |
    | effectiveStartDate | 2026-07-01 |
    | changeReason | "Government rate increase" |
  Then a new version is created
  And the old version has effectiveEndDate = 2026-06-30
  And the new version has effectiveStartDate = 2026-07-01
  And an audit log entry is created

Scenario: Query version by effective date
  Given I am logged in as Payroll Admin
  And BHXH_EE rule has:
    | version 1 | rate 0.08 | until 2026-06-30 |
    | version 2 | rate 0.085 | from 2026-07-01 |
  When I query the rule for date "2026-05-15"
  Then I get version 1 with rate 0.08
  When I query the rule for date "2026-08-01"
  Then I get version 2 with rate 0.085

Scenario: Overlapping effective dates rejected
  Given I am logged in as Payroll Admin
  And BHXH_EE rule version 1 is effective 2026-01-01 to 2026-06-30
  When I create a new version with effectiveStartDate "2026-06-15"
  Then the creation fails
  And an error message "Version effective dates overlap" is displayed
```

---

## Epic 4: Formula Engine

### US-012: Define Calculation Formula

**Priority**: P1 | **Story Points**: 13

**As a** Payroll Admin  
**I want to** define calculation formulas for pay elements  
**So that** I can create custom calculation logic

**Acceptance Criteria**:

```gherkin
Scenario: Create arithmetic formula
  Given I am logged in as Payroll Admin
  When I create a formula:
    | name | BHXH Employee |
    | expression | "{SALARY_BASIC}" * 0.08 |
  Then the formula is created
  And syntax validation passes

Scenario: Create conditional formula
  Given I am logged in as Payroll Admin
  When I create a formula:
    | name | OT Calculation |
    | expression | "IF({hours} > 8, {hours} * 1.5, {hours})" |
  Then the formula is created
  And syntax validation passes

Scenario: Create lookup formula
  Given I am logged in as Payroll Admin
  And a lookup table "TAX_TABLE" exists
  When I create a formula:
    | name | Tax Lookup |
    | expression | "LOOKUP(TAX_TABLE, {taxable_income})" |
  Then the formula is created

Scenario: Create progressive formula for PIT
  Given I am logged in as Payroll Admin
  And PIT brackets are configured
  When I create a formula:
    | name | PIT Calculation |
    | expression | "PROGRESSIVE(PIT_BRACKETS, {taxable_income})" |
  Then the formula is created

Scenario: Formula can reference other elements
  Given I am logged in as Payroll Admin
  And pay element "SALARY_BASIC" exists
  When I create a formula referencing "{SALARY_BASIC}"
  Then the formula is created
  And reference validation passes

Scenario: Invalid syntax rejected
  Given I am logged in as Payroll Admin
  When I create a formula with invalid expression "({salary * 0.08"
  Then the creation fails
  And an error message "Invalid formula syntax" is displayed
```

---

### US-013: Validate Formula

**Priority**: P1 | **Story Points**: 8

**As a** Payroll Admin  
**I want to** validate formulas before saving  
**So that** I can catch errors before they affect calculations

**Acceptance Criteria**:

```gherkin
Scenario: Syntax validation
  Given I am logged in as Payroll Admin
  When I enter formula "{SALARY_BASIC} * 0.08"
  And I click "Validate"
  Then the system validates syntax
  And displays "Syntax valid"

Scenario: Reference validation
  Given I am logged in as Payroll Admin
  And pay element "SALARY_BASIC" exists
  And pay element "NONEXISTENT" does not exist
  When I enter formula "{SALARY_BASIC} + {NONEXISTENT}"
  And I click "Validate"
  Then the system displays warning "Element NONEXISTENT not found"

Scenario: Circular reference detection
  Given I am logged in as Payroll Admin
  And formula A references formula B
  And formula B references formula A
  When I click "Validate"
  Then the system displays error "Circular reference detected: A -> B -> A"

Scenario: Division by zero detection
  Given I am logged in as Payroll Admin
  When I enter formula "{SALARY_BASIC} / 0"
  And I click "Validate"
  Then the system displays error "Division by zero"

Scenario: Preview with sample values
  Given I am logged in as Payroll Admin
  And a formula "{SALARY_BASIC} * 0.08" exists
  When I provide sample value SALARY_BASIC = 10000000
  And I click "Preview"
  Then the system displays result "800000"
```

---

## Epic 5: Validation Framework

### US-014: Configuration Validation

**Priority**: P0 | **Story Points**: 8

**As a** Payroll Admin  
**I want to** receive validation feedback when configuring payroll  
**So that** I can prevent errors before they affect calculations

**Acceptance Criteria**:

```gherkin
Scenario: Field validation on input
  Given I am creating a pay element
  When I enter rate "-0.05"
  Then an inline error "Rate must be non-negative" is displayed

Scenario: Cross-field validation on save
  Given I am creating a statutory rule
  When I enter:
    | effectiveStartDate | 2026-06-01 |
    | effectiveEndDate   | 2026-05-01 |
  And I click "Save"
  Then an error "End date must be after start date" is displayed
  And the save is blocked

Scenario: Entity validation on save
  Given I am creating a pay profile
  And I have not assigned any pay elements
  When I click "Save"
  Then a warning "Profile has no pay elements assigned" is displayed
  And I can acknowledge and save

Scenario: Cross-entity validation
  Given I am deleting a pay element
  And the element is assigned to an active pay profile
  When I click "Delete"
  Then an error "Element is in use by active profile PROFILE_STAFF" is displayed
  And the deletion is blocked

Scenario: Business rule validation
  Given I am creating a statutory rule
  And the rate does not match current government rate
  When I click "Save"
  Then a warning "Rate differs from government rate 8%. Are you sure?" is displayed
  And I can acknowledge and save
```

---

### US-015: Conflict Detection

**Priority**: P1 | **Story Points**: 8

**As a** Payroll Admin  
**I want to** be alerted when configuration conflicts exist  
**So that** I can resolve them before they cause problems

**Acceptance Criteria**:

```gherkin
Scenario: Overlapping version conflict
  Given I am updating a statutory rule
  And version 1 is effective 2026-01-01 to 2026-06-30
  When I create version 2 with effectiveStartDate "2026-06-15"
  Then the system detects conflict
  And displays "Version overlaps with existing version"

Scenario: Conflicting statutory rules
  Given I am creating a statutory rule
  And a BHXH_EE rule already exists for the same period
  When I create another BHXH_EE rule
  Then the system detects conflict
  And displays "Duplicate statutory rule type for employee"

Scenario: Dependency cycle detection
  Given I am creating formulas
  And formula A references formula B
  When I update formula B to reference formula A
  Then the system detects cycle
  And displays "Circular dependency detected"

Scenario: Manual conflict resolution
  Given the system has detected a conflict
  When I choose to override
  Then the system allows save with acknowledgment
  And logs the override decision
```

---

## Epic 6: Version Management

### US-016: View Version History

**Priority**: P0 | **Story Points**: 5

**As a** Payroll Admin  
**I want to** view the version history of any entity  
**So that** I can understand how configuration has changed over time

**Acceptance Criteria**:

```gherkin
Scenario: List all versions of an entity
  Given I am logged in as Payroll Admin
  And a pay element "SALARY_BASIC" has 3 versions
  When I view the element's version history
  Then I see all 3 versions listed
  And each version shows:
    | versionNumber |
    | effectiveStartDate |
    | effectiveEndDate |
    | createdBy |
    | createdAt |
    | changeReason |

Scenario: View version details
  Given I am viewing version history
  When I select version 2
  Then I see all attributes for that version
  And I see what changed from version 1

Scenario: Compare two versions
  Given I am viewing version history
  When I select versions 1 and 2 and click "Compare"
  Then I see a side-by-side comparison
  And changed fields are highlighted

Scenario: Export version history
  Given I am viewing version history
  When I click "Export"
  Then I can download version history as CSV or PDF
```

---

### US-017: Query Version by Date

**Priority**: P0 | **Story Points**: 5

**As a** Payroll Admin  
**I want to** query what the configuration was at any point in time  
**So that** I can investigate historical payroll issues

**Acceptance Criteria**:

```gherkin
Scenario: Query current version
  Given I am logged in as Payroll Admin
  And a pay element has:
    | version 1 | effective 2026-01-01 to 2026-06-30 |
    | version 2 | effective 2026-07-01 to null |
  When I query the current version
  Then I get version 2

Scenario: Query historical version by date
  Given I am logged in as Payroll Admin
  And a pay element has:
    | version 1 | effective 2026-01-01 to 2026-06-30 |
    | version 2 | effective 2026-07-01 to null |
  When I query for date "2026-04-15"
  Then I get version 1

Scenario: Query entire configuration snapshot
  Given I am logged in as Payroll Admin
  When I query configuration snapshot for date "2026-03-01"
  Then I get all pay elements, profiles, and statutory rules effective on that date
```

---

## Epic 7: Integration Interfaces

### US-018: Receive Worker Data from Core HR

**Priority**: P0 | **Story Points**: 8

**As a** System  
**I want to** receive worker data from Core HR (CO) module  
**So that** I can validate payroll configuration references

**Acceptance Criteria**:

```gherkin
Scenario: Receive worker data via API
  Given CO module sends worker data
  When the API endpoint receives:
    | workerId | EMP001 |
    | fullName | Nguyen Van A |
    | legalEntityId | VN_HQ |
    | assignmentId | ASG001 |
  Then the worker reference is cached
  And the worker is available for pay group assignment

Scenario: Validate legal entity reference
  Given a pay profile references legal entity "VN_HQ"
  And CO module confirms "VN_HQ" exists
  Then the reference is valid

Scenario: Handle missing worker data
  Given I attempt to assign employee to pay group
  And the employee does not exist in CO data
  Then an error "Employee not found in Core HR" is returned
  And the assignment is rejected
```

---

### US-019: Receive Time Data from Time & Absence

**Priority**: P0 | **Story Points**: 8

**As a** System  
**I want to** receive time data from Time & Absence (TA) module  
**So that** I can configure time-based pay elements

**Acceptance Criteria**:

```gherkin
Scenario: Receive attendance data batch
  Given TA module sends daily attendance
  When the batch API receives attendance records:
    | employeeId | date | regularHours | otHours |
    | EMP001     | 2026-01-15 | 8 | 2 |
  Then the attendance data is cached
  And the data is available for OT element configuration

Scenario: Receive leave data batch
  Given TA module sends leave records
  When the batch API receives leave records:
    | employeeId | leaveType | hours |
    | EMP001     | ANNUAL    | 8 |
  Then the leave data is cached
  And the data is available for leave element configuration

Scenario: Validate data completeness
  Given TA module sends incomplete time data
  When required fields are missing
  Then an error is returned to TA module
  And the data is rejected
```

---

### US-020: Receive Compensation Data from Total Rewards

**Priority**: P0 | **Story Points**: 8

**As a** System  
**I want to** receive compensation data from Total Rewards (TR) module  
**So that** I can map salary and allowances to pay elements

**Acceptance Criteria**:

```gherkin
Scenario: Receive salary data
  Given TR module sends compensation data
  When the API receives:
    | employeeId | componentType | amount | frequency |
    | EMP001     | BASE_SALARY   | 20000000 | MONTHLY |
  Then the compensation data is cached
  And the data is available for pay element mapping

Scenario: Map salary to pay element
  Given TR sends BASE_SALARY for employee
  And pay element "SALARY_BASIC" exists with mapping to BASE_SALARY
  Then the salary is available for calculation

Scenario: Real-time sync on compensation change
  Given an employee's salary is changed in TR
  When TR sends the update notification
  Then the payroll configuration is validated
  And any affected profiles are flagged for review
```

---

### US-021: Configure GL Mapping

**Priority**: P1 | **Story Points**: 5

**As a** Finance Controller  
**I want to** configure GL account mappings for pay elements  
**So that** payroll costs are posted to the correct accounts

**Acceptance Criteria**:

```gherkin
Scenario: Create GL mapping
  Given I am logged in as Finance Controller
  And a pay element "SALARY_BASIC" exists
  When I create a GL mapping:
    | payElementId | SALARY_BASIC |
    | glAccountCode | 6221 |
    | costCenter | CC001 |
    | debitCredit | DEBIT |
  Then the mapping is created
  And an audit log entry is created

Scenario: Multiple GL splits
  Given I am logged in as Finance Controller
  And a pay element "SALARY_BASIC" exists
  When I create multiple GL mappings:
    | glAccountCode | percentage |
    | 6221 | 70 |
    | 6222 | 30 |
  Then both mappings are created
  And validation confirms total = 100%

Scenario: Cost center allocation
  Given I am logged in as Finance Controller
  When I create GL mapping with cost center "CC001"
  Then the mapping includes cost center for allocation

Scenario: Export GL mapping for finance system
  Given GL mappings are configured
  When Finance system requests GL mappings
  Then an export file is generated
  And the file contains all active mappings
```

---

### US-022: Configure Banking Templates

**Priority**: P1 | **Story Points**: 5

**As a** Payroll Admin  
**I want to** configure bank file templates  
**So that** payment files can be generated for different banks

**Acceptance Criteria**:

```gherkin
Scenario: Create bank template
  Given I am logged in as Payroll Admin
  When I create a bank template:
    | templateCode | VCB_TRANSFER |
    | templateName | Vietcombank Transfer |
    | bankCode | VCB |
    | fileFormat | CSV |
  Then the template is created

Scenario: Configure field mappings
  Given I am logged in as Payroll Admin
  And a bank template "VCB_TRANSFER" exists
  When I configure field mappings:
    | sourceField | targetField | position |
    | employeeBankAccount | AccountNo | 1 |
    | paymentAmount | Amount | 2 |
    | employeeName | BeneficiaryName | 3 |
  Then the field mappings are saved

Scenario: Template preview
  Given a bank template is configured
  When I click "Preview"
  Then I see a sample output file with mapped fields

Scenario: Multiple bank formats
  Given I am logged in as Payroll Admin
  When I create templates for different banks
  Then each template can have different formats (CSV, FIXED, XML)
```

---

## Epic 8: Audit Trail

### US-023: View Configuration Audit Log

**Priority**: P0 | **Story Points**: 5

**As a** HR Manager  
**I want to** view audit logs of all configuration changes  
**So that** I can track who changed what and when

**Acceptance Criteria**:

```gherkin
Scenario: View all configuration changes
  Given I am logged in as HR Manager
  When I access the audit log
  Then I see a list of all configuration changes
  And each entry shows:
    | entityType | PayElement |
    | entityId | SALARY_BASIC |
    | operation | UPDATE |
    | changedBy | admin@company.com |
    | changedAt | 2026-03-31 14:30:00 |

Scenario: Filter by entity type
  Given I am viewing audit log
  When I filter by entity type "PayElement"
  Then I see only PayElement changes

Scenario: Filter by date range
  Given I am viewing audit log
  When I filter by date range "2026-01-01" to "2026-03-31"
  Then I see only changes within that range

Scenario: View change details
  Given I am viewing audit log
  When I click on an UPDATE entry
  Then I see:
    | oldValue | Previous value as JSON |
    | newValue | New value as JSON |
    | changeReason | "Rate update per government regulation" |
```

---

### US-024: Export Audit Trail

**Priority**: P1 | **Story Points**: 3

**As a** Compliance Officer  
**I want to** export audit trail for external audit  
**So that** I can provide compliance evidence

**Acceptance Criteria**:

```gherkin
Scenario: Export audit trail as CSV
  Given I am logged in as Compliance Officer
  When I filter audit log by date range
  And I click "Export CSV"
  Then a CSV file is downloaded
  And the file contains all filtered entries

Scenario: Export audit trail as PDF
  Given I am logged in as Compliance Officer
  When I filter audit log by date range
  And I click "Export PDF"
  Then a PDF report is generated
  And the report includes:
    | Header | Company name, date range |
    | Summary | Total changes by type |
    | Details | All entries with old/new values |

Scenario: Filter by operation type
  Given I am viewing audit log
  When I filter by operation "UPDATE"
  Then I see only update operations
```

---

## Summary

### Story Count by Priority

| Priority | Count |
|----------|-------|
| P0 | 17 |
| P1 | 7 |
| Total | 24 |

### Story Count by Epic

| Epic | Count |
|------|-------|
| Epic 1: Pay Element Configuration | 4 |
| Epic 2: Pay Structure Configuration | 4 |
| Epic 3: Statutory Rule Management | 3 |
| Epic 4: Formula Engine | 2 |
| Epic 5: Validation Framework | 2 |
| Epic 6: Version Management | 2 |
| Epic 7: Integration Interfaces | 5 |
| Epic 8: Audit Trail | 2 |
| Total | 24 |

### Coverage Matrix

| BRD Requirement | User Story |
|-----------------|------------|
| FR-001 Create Pay Element | US-001 |
| FR-002 Update Pay Element | US-002 |
| FR-003 Delete Pay Element | US-003 |
| FR-004 Pay Element Classification | US-004 |
| FR-005 Create Pay Profile | US-005 |
| FR-006 Pay Element Assignment | US-006 |
| FR-007 Pay Calendar Management | US-007 |
| FR-008 Pay Group Configuration | US-008 |
| FR-009 Create Statutory Rule | US-009 |
| FR-010 PIT Progressive Brackets | US-010 |
| FR-011 Statutory Rule Versioning | US-011 |
| FR-012 Formula Definition | US-012 |
| FR-013 Formula Validation | US-013 |
| FR-014 Configuration Validation | US-014 |
| FR-015 Conflict Detection | US-015 |
| FR-016 SCD-2 Versioning | US-016 |
| FR-017 Version Query | US-017 |
| FR-018 Core HR Integration | US-018 |
| FR-019 Time Integration | US-019 |
| FR-020 Total Rewards Integration | US-020 |
| FR-021 GL Integration | US-021 |
| FR-022 Banking Integration | US-022 |
| FR-023 Audit Log | US-023 |
| FR-024 Audit Query | US-024 |

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Business Analyst Agent