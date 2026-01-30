---
domain: Total Rewards
module: TR
version: "1.0.0"
status: DRAFT
created: "2026-01-30"

# === ENTITY DATA ===
entities:
  # ========================================
  # A. COMPENSATION DOMAIN ENTITIES
  # ========================================
  
  # --- Compensation Master Data ---
  - id: E-TR-001
    name: CompensationPlan
    type: AGGREGATE_ROOT
    category: Master
    stability: HIGH
    change_frequency: YEARLY
    definition: "Master definition of a compensation plan including rules for salary, bonus, equity, and other pay elements"
    key_attributes:
      - id
      - plan_code
      - plan_name
      - plan_type
      - effective_date
      - currency
      - status
    relationships:
      - "has many [[CompensationComponent]]"
      - "has many [[CompensationAssignment]]"
      - "belongs to [[LegalEntity]]"
    dependencies:
      upstream: ["Core.LegalEntity", "Core.Currency"]
      downstream: ["Payroll.EarningsCode", "Finance.CostCenter"]
    lifecycle: "Draft → Active → Archived"
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Salary Basis + Plans, Workday: Compensation Plans, SAP: Compensation Plan"
    decision_ref: null

  - id: E-TR-002
    name: SalaryStructure
    type: AGGREGATE_ROOT
    category: Master
    stability: HIGH
    change_frequency: YEARLY
    definition: "Hierarchical salary structure defining pay grades, ranges, and steps for an organization"
    key_attributes:
      - id
      - structure_code
      - structure_name
      - currency
      - effective_date
      - grade_count
      - status
    relationships:
      - "has many [[SalaryGrade]]"
      - "has many [[SalaryRange]]"
      - "belongs to [[LegalEntity]]"
    dependencies:
      upstream: ["Core.LegalEntity"]
      downstream: ["Core.JobProfile", "CompensationAssignment"]
    lifecycle: "Draft → Active → Superseded"
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Grade Structure, Workday: Salary Plan, SAP: Pay Structure"
    decision_ref: null

  - id: E-TR-003
    name: SalaryGrade
    type: ENTITY
    category: Master
    stability: HIGH
    change_frequency: YEARLY
    definition: "Individual grade level within a salary structure with defined pay ranges"
    key_attributes:
      - id
      - grade_code
      - grade_name
      - sequence
      - min_salary
      - mid_salary
      - max_salary
    relationships:
      - "belongs to [[SalaryStructure]]"
      - "has many [[SalaryStep]]"
    dependencies:
      upstream: ["SalaryStructure"]
      downstream: ["Core.JobProfile", "CompensationAssignment"]
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Grade, Workday: Grade, SAP: Pay Grade"

  - id: E-TR-004
    name: CompensationComponent
    type: ENTITY
    category: Master
    stability: MEDIUM
    change_frequency: QUARTERLY
    definition: "Individual pay element that makes up total compensation such as base salary, housing allowance, transport allowance"
    key_attributes:
      - id
      - component_code
      - component_name
      - component_type
      - frequency
      - taxable
      - si_applicable
      - calculation_method
    relationships:
      - "belongs to [[CompensationPlan]]"
      - "has many [[CompensationAssignment]]"
    dependencies:
      upstream: ["CompensationPlan"]
      downstream: ["Payroll.EarningsCode", "Finance.GLAccount"]
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Element, Workday: Compensation Element, SAP: Wage Type"

  - id: E-TR-005
    name: BonusPlan
    type: AGGREGATE_ROOT
    category: Master
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "Variable pay plan defining bonus structure, targets, and payout rules"
    key_attributes:
      - id
      - plan_code
      - plan_name
      - bonus_type
      - target_percentage
      - calculation_basis
      - payout_frequency
      - eligibility_rules
    relationships:
      - "has many [[BonusTarget]]"
      - "belongs to [[CompensationPlan]]"
    dependencies:
      upstream: ["Performance.Goal", "Performance.Rating"]
      downstream: ["Payroll.EarningsCode"]
    lifecycle: "Draft → Active → Closed"
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Bonus Plan, Workday: Bonus Plan, SAP: Variable Pay"

  # --- Compensation Transactional ---
  - id: E-TR-006
    name: CompensationAssignment
    type: AGGREGATE_ROOT
    category: Transaction
    stability: MEDIUM
    change_frequency: REALTIME
    definition: "Assignment of compensation plan and components to an employee with effective dating"
    key_attributes:
      - id
      - employee_id
      - plan_id
      - grade_id
      - base_salary
      - currency
      - effective_date
      - end_date
      - status
    relationships:
      - "belongs to [[Employee]]"
      - "references [[CompensationPlan]]"
      - "references [[SalaryGrade]]"
      - "has many [[ComponentAssignment]]"
    dependencies:
      upstream: ["Core.Employee", "CompensationPlan", "SalaryGrade"]
      downstream: ["Payroll.EmployeeEarning", "TotalRewardsStatement"]
    lifecycle: "Pending → Active → Ended"
    pii_sensitivity: HIGH
    competitor_reference: "Oracle: Salary, Workday: Compensation, SAP: Infotype 0008"

  - id: E-TR-007
    name: SalaryHistory
    type: ENTITY
    category: Transaction
    stability: HIGH
    change_frequency: REALTIME
    definition: "Historical record of all salary changes for an employee including reason and approver"
    key_attributes:
      - id
      - employee_id
      - effective_date
      - previous_salary
      - new_salary
      - change_reason
      - change_percentage
      - approved_by
    relationships:
      - "belongs to [[Employee]]"
      - "references [[CompensationAssignment]]"
    dependencies:
      upstream: ["CompensationAssignment"]
      downstream: ["Reporting.CompensationAnalytics"]
    pii_sensitivity: HIGH
    competitor_reference: "Oracle: Salary History, Workday: Compensation History"

  - id: E-TR-008
    name: CompensationReview
    type: AGGREGATE_ROOT
    category: Transaction
    stability: MEDIUM
    change_frequency: QUARTERLY
    definition: "Periodic compensation review cycle for merit increases, promotions, and adjustments"
    key_attributes:
      - id
      - review_cycle_code
      - review_name
      - start_date
      - end_date
      - budget_amount
      - budget_type
      - status
    relationships:
      - "has many [[CompensationReviewDetail]]"
      - "belongs to [[LegalEntity]]"
    dependencies:
      upstream: ["Performance.ReviewCycle", "Finance.Budget"]
      downstream: ["CompensationAssignment", "Payroll.PayrollRun"]
    lifecycle: "Planning → InProgress → Approved → Executed"
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Compensation Cycle, Workday: Compensation Review, SAP: Compensation Planning"

  # ========================================
  # B. BENEFITS DOMAIN ENTITIES
  # ========================================

  - id: E-TR-009
    name: BenefitProgram
    type: AGGREGATE_ROOT
    category: Master
    stability: HIGH
    change_frequency: YEARLY
    definition: "Top-level grouping of benefit plans offered to employees (e.g., Standard Health Program)"
    key_attributes:
      - id
      - program_code
      - program_name
      - effective_date
      - end_date
      - eligibility_rule_id
      - status
    relationships:
      - "has many [[BenefitPlan]]"
      - "has many [[EligibilityRule]]"
    dependencies:
      upstream: ["Core.LegalEntity"]
      downstream: ["BenefitEnrollment"]
    lifecycle: "Draft → Active → Expired"
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Benefit Program, Workday: Benefit Group, SAP: Benefit Area"

  - id: E-TR-010
    name: BenefitPlan
    type: ENTITY
    category: Master
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "Specific benefit plan within a program (e.g., Premium Health Insurance, Basic Dental)"
    key_attributes:
      - id
      - plan_code
      - plan_name
      - plan_type
      - carrier_id
      - premium_employee
      - premium_employer
      - coverage_start_rule
    relationships:
      - "belongs to [[BenefitProgram]]"
      - "has many [[BenefitOption]]"
      - "references [[BenefitCarrier]]"
    dependencies:
      upstream: ["BenefitProgram", "BenefitCarrier"]
      downstream: ["BenefitEnrollment", "Payroll.Deduction"]
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Benefit Plan, Workday: Benefit Plan, SAP: Benefit Plan"

  - id: E-TR-011
    name: BenefitOption
    type: ENTITY
    category: Master
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "Coverage option/tier within a benefit plan (e.g., Employee Only, Employee + Spouse)"
    key_attributes:
      - id
      - option_code
      - option_name
      - coverage_level
      - employee_cost
      - employer_cost
      - flex_credits_required
    relationships:
      - "belongs to [[BenefitPlan]]"
    dependencies:
      upstream: ["BenefitPlan"]
      downstream: ["BenefitElection"]
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Plan Option, Workday: Coverage Level, SAP: Plan Option"

  - id: E-TR-012
    name: EligibilityRule
    type: AGGREGATE_ROOT
    category: Config
    stability: MEDIUM
    change_frequency: QUARTERLY
    definition: "Rule set defining who is eligible for a benefit program based on employment criteria"
    key_attributes:
      - id
      - rule_code
      - rule_name
      - criteria
      - waiting_period_days
      - employment_type_filter
      - job_level_filter
    relationships:
      - "used by [[BenefitProgram]]"
      - "used by [[BenefitPlan]]"
    dependencies:
      upstream: ["Core.EmploymentType", "Core.JobLevel"]
      downstream: ["BenefitEnrollment"]
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Eligibility Profile, Workday: Eligibility Rule, SAP: Eligibility Criteria"

  - id: E-TR-013
    name: BenefitEnrollment
    type: AGGREGATE_ROOT
    category: Transaction
    stability: LOW
    change_frequency: REALTIME
    definition: "Employee's enrollment in a benefit program including selected plans and elections"
    key_attributes:
      - id
      - employee_id
      - program_id
      - enrollment_event_id
      - enrollment_date
      - coverage_start_date
      - status
    relationships:
      - "belongs to [[Employee]]"
      - "references [[BenefitProgram]]"
      - "has many [[BenefitElection]]"
      - "triggered by [[LifeEvent]]"
    dependencies:
      upstream: ["Core.Employee", "BenefitProgram", "LifeEvent"]
      downstream: ["Payroll.Deduction", "BenefitCarrier"]
    lifecycle: "Pending → Active → Terminated"
    pii_sensitivity: HIGH
    competitor_reference: "Oracle: Benefit Enrollment, Workday: Benefit Event, SAP: Enrollment"

  - id: E-TR-014
    name: BenefitElection
    type: ENTITY
    category: Transaction
    stability: LOW
    change_frequency: REALTIME
    definition: "Specific plan and option elected by employee within an enrollment"
    key_attributes:
      - id
      - enrollment_id
      - plan_id
      - option_id
      - employee_contribution
      - employer_contribution
      - effective_date
    relationships:
      - "belongs to [[BenefitEnrollment]]"
      - "references [[BenefitPlan]]"
      - "references [[BenefitOption]]"
    dependencies:
      upstream: ["BenefitEnrollment", "BenefitPlan", "BenefitOption"]
      downstream: ["Payroll.Deduction"]
    pii_sensitivity: HIGH
    competitor_reference: "Oracle: Election, Workday: Coverage, SAP: Election"

  - id: E-TR-015
    name: LifeEvent
    type: AGGREGATE_ROOT
    category: Transaction
    stability: LOW
    change_frequency: REALTIME
    definition: "Qualifying life event that triggers benefits enrollment/change window (e.g., marriage, birth)"
    key_attributes:
      - id
      - employee_id
      - event_type
      - event_date
      - documentation_required
      - enrollment_window_end
      - status
    relationships:
      - "belongs to [[Employee]]"
      - "triggers [[BenefitEnrollment]]"
    dependencies:
      upstream: ["Core.Employee"]
      downstream: ["BenefitEnrollment"]
    lifecycle: "Reported → Verified → Applied → Closed"
    pii_sensitivity: HIGH
    competitor_reference: "Oracle: Life Event, Workday: Benefit Event, SAP: Life Event"

  - id: E-TR-016
    name: Dependent
    type: ENTITY
    category: Master
    stability: MEDIUM
    change_frequency: REALTIME
    definition: "Dependent individual covered under employee's benefit plans (spouse, child, etc.)"
    key_attributes:
      - id
      - employee_id
      - relationship_type
      - first_name
      - last_name
      - date_of_birth
      - gender
      - ssn_or_id
    relationships:
      - "belongs to [[Employee]]"
      - "enrolled in [[BenefitElection]]"
    dependencies:
      upstream: ["Core.Employee"]
      downstream: ["BenefitElection", "BenefitCarrier"]
    pii_sensitivity: HIGH
    competitor_reference: "Oracle: Contact, Workday: Dependent, SAP: Dependent"

  # ========================================
  # C. RECOGNITION DOMAIN ENTITIES
  # ========================================

  - id: E-TR-017
    name: RecognitionProgram
    type: AGGREGATE_ROOT
    category: Master
    stability: HIGH
    change_frequency: YEARLY
    definition: "Recognition program defining types of awards, nominating rules, and budget"
    key_attributes:
      - id
      - program_code
      - program_name
      - program_type
      - budget_amount
      - budget_period
      - approval_required
      - status
    relationships:
      - "has many [[AwardType]]"
      - "has many [[RecognitionAward]]"
    dependencies:
      upstream: ["Core.LegalEntity", "Finance.Budget"]
      downstream: ["RecognitionAward", "Payroll.EarningsCode"]
    lifecycle: "Draft → Active → Closed"
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Celebrate Program, SAP: Spot Award Program, Workday: Recognition Program"

  - id: E-TR-018
    name: AwardType
    type: ENTITY
    category: Config
    stability: HIGH
    change_frequency: YEARLY
    definition: "Type of recognition award available (monetary, points, certificate, public kudos)"
    key_attributes:
      - id
      - award_code
      - award_name
      - award_category
      - is_monetary
      - default_value
      - requires_approval
      - taxable
    relationships:
      - "belongs to [[RecognitionProgram]]"
      - "linked to [[CompanyValue]]"
    dependencies:
      upstream: ["RecognitionProgram"]
      downstream: ["RecognitionAward"]
    pii_sensitivity: NONE
    competitor_reference: "Oracle: Award Type, SAP: Spot Award Type"

  - id: E-TR-019
    name: RecognitionAward
    type: AGGREGATE_ROOT
    category: Transaction
    stability: LOW
    change_frequency: REALTIME
    definition: "Individual recognition given to an employee including giver, message, and value"
    key_attributes:
      - id
      - recipient_id
      - giver_id
      - program_id
      - award_type_id
      - message
      - value_amount
      - points_value
      - award_date
      - status
    relationships:
      - "given to [[Employee]]"
      - "given by [[Employee]]"
      - "references [[RecognitionProgram]]"
      - "references [[AwardType]]"
    dependencies:
      upstream: ["Core.Employee", "RecognitionProgram", "AwardType"]
      downstream: ["Payroll.EarningsCode", "SocialFeed"]
    lifecycle: "Pending → Approved → Delivered → Redeemed"
    pii_sensitivity: LOW
    competitor_reference: "Oracle: Celebration, SAP: Spot Award, Workday: Recognition"

  - id: E-TR-020
    name: MilestoneEvent
    type: ENTITY
    category: Transaction
    stability: MEDIUM
    change_frequency: REALTIME
    definition: "Automated milestone celebration (work anniversary, birthday, promotion)"
    key_attributes:
      - id
      - employee_id
      - milestone_type
      - milestone_date
      - years_of_service
      - celebration_status
      - award_id
    relationships:
      - "belongs to [[Employee]]"
      - "triggers [[RecognitionAward]]"
    dependencies:
      upstream: ["Core.Employee", "Core.HireDate"]
      downstream: ["RecognitionAward", "SocialFeed"]
    pii_sensitivity: LOW
    competitor_reference: "Oracle: Service Award, SAP: Anniversary, Workday: Milestone"

  # ========================================
  # D. ANALYTICS & REPORTING ENTITIES
  # ========================================

  - id: E-TR-021
    name: TotalRewardsStatement
    type: AGGREGATE_ROOT
    category: Transaction
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "Comprehensive statement showing employee's total compensation including all reward elements"
    key_attributes:
      - id
      - employee_id
      - statement_period
      - statement_date
      - total_compensation
      - total_benefits
      - total_recognition
      - document_url
      - status
    relationships:
      - "belongs to [[Employee]]"
      - "aggregates [[CompensationAssignment]]"
      - "aggregates [[BenefitEnrollment]]"
      - "aggregates [[RecognitionAward]]"
    dependencies:
      upstream: ["CompensationAssignment", "BenefitEnrollment", "RecognitionAward"]
      downstream: ["Employee Self-Service"]
    lifecycle: "Generated → Published → Viewed"
    pii_sensitivity: HIGH
    competitor_reference: "Oracle: Total Comp Statement, Workday: Total Rewards, SAP: Compensation Statement"

  - id: E-TR-022
    name: PayEquityAnalysis
    type: AGGREGATE_ROOT
    category: Transaction
    stability: MEDIUM
    change_frequency: QUARTERLY
    definition: "Analysis of pay equity across demographics including gap calculations"
    key_attributes:
      - id
      - analysis_date
      - scope
      - demographic_category
      - median_gap
      - mean_gap
      - compa_ratio_avg
      - status
    relationships:
      - "analyzes [[CompensationAssignment]]"
    dependencies:
      upstream: ["CompensationAssignment", "Core.Employee"]
      downstream: ["Reporting.PayEquityDashboard"]
    pii_sensitivity: MEDIUM
    competitor_reference: "Workday: Pay Equity Dashboard, Oracle: Pay Equity"

  # ========================================
  # E. REFERENCE DATA
  # ========================================

  - id: E-TR-023
    name: PayFrequency
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: RARE
    definition: "Pay frequency options (Monthly, Bi-weekly, Weekly, etc.)"
    key_attributes:
      - code
      - name
      - periods_per_year
      - active
    dependencies:
      upstream: []
      downstream: ["CompensationPlan", "CompensationAssignment"]
    pii_sensitivity: NONE

  - id: E-TR-024
    name: CompensationType
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: RARE
    definition: "Type of compensation (Fixed, Variable, One-time, Recurring)"
    key_attributes:
      - code
      - name
      - category
      - active
    dependencies:
      upstream: []
      downstream: ["CompensationComponent"]
    pii_sensitivity: NONE

  - id: E-TR-025
    name: BenefitCoverageLevel
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: YEARLY
    definition: "Coverage levels for benefits (Employee Only, Employee+Spouse, Family)"
    key_attributes:
      - code
      - name
      - tier_level
      - active
    dependencies:
      upstream: []
      downstream: ["BenefitOption"]
    pii_sensitivity: NONE

  - id: E-TR-026
    name: RecognitionCategory
    type: REFERENCE_DATA
    category: Config
    stability: MEDIUM
    change_frequency: YEARLY
    definition: "Categories for recognition (Achievement, Milestone, Values, Teamwork)"
    key_attributes:
      - code
      - name
      - description
      - icon
      - active
    dependencies:
      upstream: []
      downstream: ["AwardType"]
    pii_sensitivity: NONE

  - id: E-TR-027
    name: LifeEventType
    type: REFERENCE_DATA
    category: Config
    stability: HIGH
    change_frequency: YEARLY
    definition: "Types of qualifying life events (Marriage, Birth, Death, Job Change)"
    key_attributes:
      - code
      - name
      - enrollment_window_days
      - documentation_required
      - active
    dependencies:
      upstream: []
      downstream: ["LifeEvent"]
    pii_sensitivity: NONE

  - id: E-TR-028
    name: MinimumWageRegion
    type: REFERENCE_DATA
    category: Config
    stability: LOW
    change_frequency: YEARLY
    definition: "Vietnam regional minimum wage rates (Region I-IV)"
    key_attributes:
      - region_code
      - region_name
      - effective_date
      - minimum_wage_amount
      - trained_worker_premium
    dependencies:
      upstream: []
      downstream: ["CompensationAssignment (validation)"]
    pii_sensitivity: NONE
    competitor_reference: "Vietnam Labor Law specific"

  - id: E-TR-029
    name: SocialInsuranceRate
    type: REFERENCE_DATA
    category: Config
    stability: LOW
    change_frequency: YEARLY
    definition: "Vietnam social insurance contribution rates and salary caps"
    key_attributes:
      - effective_date
      - bhxh_employer_rate
      - bhxh_employee_rate
      - bhyt_employer_rate
      - bhyt_employee_rate
      - bhtn_employer_rate
      - bhtn_employee_rate
      - salary_cap_multiplier
    dependencies:
      upstream: []
      downstream: ["Payroll.SICalculation"]
    pii_sensitivity: NONE
    competitor_reference: "Vietnam SI Law 2024"
---

# Entity Catalog: Total Rewards (TR)

> **Note**: YAML above is for AI processing. Tables and diagrams below for human reading.

---

## A. Core Master Data - Compensation

| ID | Entity | Stability | Frequency | PII | Definition |
|----|--------|-----------|-----------|-----|------------|
| E-TR-001 | **[[CompensationPlan]]** | HIGH | YEARLY | NONE | Master compensation plan with rules for salary, bonus, equity |
| E-TR-002 | **[[SalaryStructure]]** | HIGH | YEARLY | NONE | Hierarchical salary structure with grades and ranges |
| E-TR-003 | **[[SalaryGrade]]** | HIGH | YEARLY | NONE | Individual grade level with min/mid/max salary |
| E-TR-004 | **[[CompensationComponent]]** | MEDIUM | QUARTERLY | NONE | Individual pay elements (base, allowance, etc.) |
| E-TR-005 | **[[BonusPlan]]** | MEDIUM | YEARLY | NONE | Variable pay plan with targets and payout rules |

**Key Relationships:**
- CompensationPlan has many CompensationComponents
- SalaryStructure has many SalaryGrades
- BonusPlan links to Performance.Rating

**Competitor Mapping:**
- Oracle: Salary Basis, Grade Structure, Elements
- Workday: Compensation Plans, Grades, Compensation Elements
- SAP: Pay Structure, Wage Types, Variable Pay

---

## B. Core Master Data - Benefits

| ID | Entity | Stability | Frequency | PII | Definition |
|----|--------|-----------|-----------|-----|------------|
| E-TR-009 | **[[BenefitProgram]]** | HIGH | YEARLY | NONE | Top-level benefit program grouping |
| E-TR-010 | **[[BenefitPlan]]** | MEDIUM | YEARLY | NONE | Specific benefit plan with carrier and premiums |
| E-TR-011 | **[[BenefitOption]]** | MEDIUM | YEARLY | NONE | Coverage option/tier within a plan |
| E-TR-012 | **[[EligibilityRule]]** | MEDIUM | QUARTERLY | NONE | Rules defining benefits eligibility |
| E-TR-016 | **[[Dependent]]** | MEDIUM | REALTIME | HIGH | Dependent individuals for coverage |

---

## C. Core Master Data - Recognition

| ID | Entity | Stability | Frequency | PII | Definition |
|----|--------|-----------|-----------|-----|------------|
| E-TR-017 | **[[RecognitionProgram]]** | HIGH | YEARLY | NONE | Recognition program with budget and rules |
| E-TR-018 | **[[AwardType]]** | HIGH | YEARLY | NONE | Types of recognition awards |

---

## D. Transactional Entities

| ID | Entity | Stability | Frequency | Lifecycle | PII |
|----|--------|-----------|-----------|-----------|-----|
| E-TR-006 | **[[CompensationAssignment]]** | MEDIUM | REALTIME | Pending → Active → Ended | HIGH |
| E-TR-007 | **[[SalaryHistory]]** | HIGH | REALTIME | (Immutable audit) | HIGH |
| E-TR-008 | **[[CompensationReview]]** | MEDIUM | QUARTERLY | Planning → InProgress → Approved → Executed | NONE |
| E-TR-013 | **[[BenefitEnrollment]]** | LOW | REALTIME | Pending → Active → Terminated | HIGH |
| E-TR-014 | **[[BenefitElection]]** | LOW | REALTIME | (Part of Enrollment) | HIGH |
| E-TR-015 | **[[LifeEvent]]** | LOW | REALTIME | Reported → Verified → Applied → Closed | HIGH |
| E-TR-019 | **[[RecognitionAward]]** | LOW | REALTIME | Pending → Approved → Delivered → Redeemed | LOW |
| E-TR-020 | **[[MilestoneEvent]]** | MEDIUM | REALTIME | Auto-generated | LOW |
| E-TR-021 | **[[TotalRewardsStatement]]** | MEDIUM | YEARLY | Generated → Published → Viewed | HIGH |
| E-TR-022 | **[[PayEquityAnalysis]]** | MEDIUM | QUARTERLY | Generated | MEDIUM |

---

## E. Reference/Config Data

| ID | Entity | Frequency | Definition |
|----|--------|-----------|------------|
| E-TR-023 | **[[PayFrequency]]** | RARE | Monthly, Bi-weekly, Weekly |
| E-TR-024 | **[[CompensationType]]** | RARE | Fixed, Variable, One-time |
| E-TR-025 | **[[BenefitCoverageLevel]]** | YEARLY | Employee Only, Family, etc. |
| E-TR-026 | **[[RecognitionCategory]]** | YEARLY | Achievement, Milestone, Values |
| E-TR-027 | **[[LifeEventType]]** | YEARLY | Marriage, Birth, Death, etc. |
| E-TR-028 | **[[MinimumWageRegion]]** | YEARLY | Vietnam regional minimum wages |
| E-TR-029 | **[[SocialInsuranceRate]]** | YEARLY | Vietnam SI contribution rates |

---

## F. Entity Relationships

```mermaid
erDiagram
    %% Compensation Domain
    CompensationPlan ||--o{ CompensationComponent : "has many"
    CompensationPlan ||--o{ CompensationAssignment : "has many"
    SalaryStructure ||--o{ SalaryGrade : "has many"
    SalaryGrade ||--o{ CompensationAssignment : "used by"
    BonusPlan ||--|| CompensationPlan : "belongs to"
    
    CompensationAssignment ||--o{ SalaryHistory : "tracks"
    CompensationReview ||--o{ CompensationAssignment : "updates"
    
    %% Benefits Domain
    BenefitProgram ||--o{ BenefitPlan : "has many"
    BenefitPlan ||--o{ BenefitOption : "has many"
    BenefitProgram ||--o{ EligibilityRule : "uses"
    
    BenefitEnrollment }|--|| BenefitProgram : "enrolls in"
    BenefitEnrollment ||--o{ BenefitElection : "has many"
    BenefitElection }|--|| BenefitOption : "selects"
    LifeEvent ||--o{ BenefitEnrollment : "triggers"
    
    BenefitEnrollment }o--o{ Dependent : "covers"
    
    %% Recognition Domain
    RecognitionProgram ||--o{ AwardType : "defines"
    RecognitionProgram ||--o{ RecognitionAward : "has many"
    RecognitionAward }|--|| AwardType : "uses"
    MilestoneEvent ||--o| RecognitionAward : "triggers"
    
    %% Analytics
    TotalRewardsStatement }|--|| CompensationAssignment : "includes"
    TotalRewardsStatement }|--|| BenefitEnrollment : "includes"
    TotalRewardsStatement }o--o{ RecognitionAward : "includes"
    
    %% Cross-Domain (External)
    Employee ||--o{ CompensationAssignment : "has"
    Employee ||--o{ BenefitEnrollment : "has"
    Employee ||--o{ RecognitionAward : "receives"
    Employee ||--o{ Dependent : "has"
```

---

## G. Change Frequency Analysis

### Architecture Implications

| Frequency | Count | Entities | Recommended Architecture |
|-----------|-------|----------|-------------------------|
| **RARE** (< 5yr) | 2 | PayFrequency, CompensationType | Hard-coded enum, schema migrations |
| **YEARLY** | 13 | Plans, Structures, Programs, Rates | Configuration tables, admin UI, versioning |
| **QUARTERLY** | 4 | Components, Rules, Reviews, Analysis | Rule engine, workflow, config-driven |
| **REALTIME** | 10 | Assignments, Enrollments, Awards | Event-driven, state machines, audit trail |

**High-Change Entities Requiring Special Attention:**
- **LifeEvent, BenefitEnrollment, RecognitionAward** - Need flexible state machines
- **MinimumWageRegion, SocialInsuranceRate** - Need effective-dated versioning for Vietnam regulations
- **CompensationComponent** - May change with new allowance types

---

## H. Cross-Domain Dependency Map

```mermaid
graph LR
    subgraph "Upstream Dependencies"
        CO[Core HR: Employee, Job]
        ORG[Organization: Legal Entity]
        PM[Performance: Rating, Goals]
        FIN[Finance: Budget, Cost Center]
    end
    
    subgraph "Total Rewards Entities"
        COMP[Compensation Entities]
        BEN[Benefits Entities]
        REC[Recognition Entities]
        STMT[Rewards Statement]
    end
    
    subgraph "Downstream Consumers"
        PY[Payroll: Earnings/Deductions]
        RPT[Reporting: Dashboards]
        CARRIER[Benefits Carriers]
    end
    
    CO -->|Employee, Job| COMP
    CO -->|Employee| BEN
    CO -->|Employee| REC
    ORG -->|Legal Entity| COMP
    PM -->|Rating| COMP
    FIN -->|Budget| COMP
    FIN -->|Budget| REC
    
    COMP -->|Salary, Bonus| PY
    BEN -->|Deductions| PY
    REC -->|Awards| PY
    
    COMP --> STMT
    BEN --> STMT
    REC --> STMT
    
    BEN -->|Enrollment| CARRIER
    STMT --> RPT
```

**Risk Analysis:**
- If **Core.Employee** termination logic changes → Must update BenefitEnrollment termination
- If **Performance.Rating** scale changes → Must update BonusPlan calculations
- If **Payroll.EarningsCode** structure changes → Impact on CompensationComponent mapping

---

## I. PII Sensitivity Summary

| Level | Count | Entities | Compliance Requirement |
|-------|-------|----------|------------------------|
| **HIGH** | 8 | CompensationAssignment, SalaryHistory, BenefitEnrollment, BenefitElection, LifeEvent, Dependent, TotalRewardsStatement | Encryption at rest, access control, audit logging, consent management |
| **MEDIUM** | 1 | PayEquityAnalysis | Aggregate data only, no individual identification |
| **LOW** | 2 | RecognitionAward, MilestoneEvent | Standard data protection |
| **NONE** | 18 | Master data, Reference data | No special handling required |

**GDPR/PDPA Considerations:**
- Salary data requires explicit consent for processing
- Right to access: TotalRewardsStatement provides export
- Right to delete: Must handle with retention requirements
