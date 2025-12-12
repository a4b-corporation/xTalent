# Benefits - Glossary

**Version**: 2.1  
**Last Updated**: 2025-12-11  
**Module**: Total Rewards (TR)  
**Sub-module**: Benefits

---

## Overview

Benefits manages employee benefit programs including health insurance, retirement plans, wellness programs, and perks. This sub-module provides:

- **Benefit Plans**: Medical, dental, vision, life, disability, retirement, wellness
- **Enrollment Management**: Open enrollment, new hire enrollment, qualifying life events
- **Dependent Coverage**: Spouse, children, domestic partners with eligibility tracking
- **Beneficiary Designation**: Primary and contingent beneficiaries for life/retirement
- **Reimbursements**: Medical, wellness, education, transportation expense reimbursements
- **Healthcare Claims**: Insurance claim submission and tracking

This sub-module is critical for **employee wellbeing** and **regulatory compliance**.

---

## Entities

### 1. BenefitPlan

**Definition**: Benefit plan definition for health, retirement, wellness, and other employee benefits.

**Purpose**: Defines available benefit programs with eligibility rules and coverage options.

**Key Characteristics**:
- Multiple plan categories (MEDICAL, DENTAL, VISION, LIFE, DISABILITY, RETIREMENT, WELLNESS)
- Flexible eligibility rules
- Multiple coverage options (employee only, family, etc.)
- Provider/carrier integration
- Premium cost sharing (employee, employer, shared)

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Unique plan code (e.g., MEDICAL_VN_2025) |
| `name` | string(255) | Yes | Plan name |
| `plan_category` | enum | Yes | MEDICAL, DENTAL, VISION, LIFE, DISABILITY, RETIREMENT, PERK, WELLNESS, EDUCATION, TRANSPORTATION |
| `provider_name` | string(255) | No | Insurance provider/carrier name |
| `sponsor_legal_entity_id` | UUID | No | FK to Core.LegalEntity (sponsoring entity) |
| `eligibility_rule_json` | jsonb | No | Eligibility criteria |
| `coverage_options_json` | jsonb | No | Available coverage options |
| `currency` | string(3) | No | Currency for premiums/costs |
| `premium_type` | enum | No | EMPLOYEE, EMPLOYER, SHARED |
| `effective_start_date` | date | Yes | When plan becomes active |
| `effective_end_date` | date | No | When plan expires |
| `is_active` | boolean | No | Active status |

**Eligibility Rule JSON**:

```yaml
eligibility_rule_json:
  employment_types: ["FULL_TIME"]
  min_tenure_months: 3
  grades: ["G3", "G4", "G5"]
  locations: ["VN", "SG"]
  exclude_probation: true
```

**Coverage Options JSON**:

```yaml
coverage_options_json:
  options:
    - code: "EMPLOYEE_ONLY"
      name: "Employee Only"
    - code: "EMPLOYEE_SPOUSE"
      name: "Employee + Spouse"
    - code: "EMPLOYEE_FAMILY"
      name: "Employee + Family"
```

**Business Rules**:
1. Plan code must be unique
2. Eligibility evaluated at enrollment time
3. Coverage options define employee choices
4. Premium type determines cost sharing

**Examples**:

```yaml
Example 1: Vietnam Medical Plan
  BenefitPlan:
    code: "MEDICAL_VN_2025"
    name: "Vietnam Medical Insurance 2025"
    plan_category: MEDICAL
    provider_name: "Bao Viet Insurance"
    sponsor_legal_entity_id: "VNG_CORP_UUID"
    eligibility_rule_json:
      employment_types: ["FULL_TIME"]
      min_tenure_months: 3
    coverage_options_json:
      options:
        - {code: "EMP_ONLY", name: "Employee Only"}
        - {code: "EMP_FAMILY", name: "Employee + Family"}
    currency: "VND"
    premium_type: SHARED

Example 2: Retirement Plan (401k)
  BenefitPlan:
    code: "401K_US_2025"
    name: "401(k) Retirement Plan"
    plan_category: RETIREMENT
    provider_name: "Fidelity"
    eligibility_rule_json:
      employment_types: ["FULL_TIME"]
      min_tenure_months: 0
    premium_type: EMPLOYEE
```

**Best Practices**:
- ✅ DO: Define clear eligibility criteria
- ✅ DO: Offer multiple coverage tiers
- ✅ DO: Review plans annually for competitiveness
- ❌ DON'T: Change eligibility mid-year without cause
- ❌ DON'T: Forget to update provider information

---

### 2. BenefitOption

**Definition**: Specific coverage option within a benefit plan with associated costs.

**Purpose**: Defines coverage tiers (employee only, family, etc.) and premium costs.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `plan_id` | UUID | Yes | FK to BenefitPlan |
| `code` | string(50) | Yes | Option code |
| `name` | string(200) | Yes | Option name |
| `coverage_tier` | enum | Yes | EMPLOYEE_ONLY, EMPLOYEE_SPOUSE, EMPLOYEE_CHILDREN, EMPLOYEE_FAMILY, EMPLOYEE_DOMESTIC_PARTNER |
| `cost_employee` | decimal(18,4) | No | Employee cost per period |
| `cost_employer` | decimal(18,4) | No | Employer cost per period |
| `currency` | string(3) | Yes | Currency code |
| `formula_json` | jsonb | No | Cost calculation formula |

**Formula JSON**:

```yaml
formula_json:
  base_cost: 500000
  per_dependent: 200000
  employee_contribution_pct: 0.30
  employer_contribution_pct: 0.70
```

**Business Rules**:
1. cost_employee + cost_employer = total premium
2. EMPLOYEE_FAMILY tier covers spouse + children
3. Costs can vary by employee demographics (age, location)

---

### 3. EligibilityProfile

**Definition**: Reusable eligibility rule profile that can be shared across multiple benefit plans.

**Purpose**: Centralizes common eligibility criteria for easier management.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Profile code (e.g., FULL_TIME_3M) |
| `name` | string(200) | Yes | Profile name |
| `rule_json` | jsonb | Yes | Eligibility rules |

**Rule JSON Structure**:

```yaml
rule_json:
  employment_types: ["FULL_TIME"]
  min_tenure_months: 3
  grades: ["G3", "G4", "G5"]
  job_levels: [3, 4, 5]
  locations: ["VN", "SG"]
  custom_rules:
    - field: "performance_rating"
      operator: ">="
      value: "MEETS"
```

---

### 4. PlanEligibility

**Definition**: Links benefit plans to eligibility profiles (many-to-many relationship).

**Purpose**: Allows flexible assignment of eligibility rules to plans.

**Attributes**:
- `plan_id`: FK to BenefitPlan
- `eligibility_id`: FK to EligibilityProfile

---

## Centralized Eligibility Architecture (v2.1+)

### Migration to Core Eligibility

**Status**: 🔄 In Progress - Migrating from TR-specific eligibility to centralized Core eligibility

**Background**: TR module originally had its own `EligibilityProfile` entity. As of v2.1, we are migrating to use the **Core Module's centralized Eligibility Engine** for better cross-module reusability and performance.

**Key Changes**:

1. **BenefitPlan**: 
   - ✅ NEW: `default_eligibility_profile_id` → FK to `Core.EligibilityProfile`
   - ⚠️ DEPRECATED: `eligibility_rule_json` → Use Core eligibility instead

2. **BenefitOption**:
   - ✅ NEW: `eligibility_profile_id` → Override plan default

3. **TR.EligibilityProfile**:
   - ⚠️ DEPRECATED: Use `Core.EligibilityProfile` instead

**Hybrid Eligibility Model**:

```yaml
BenefitPlan: Health Insurance
  default_eligibility_profile_id: "ELIG_ALL_FULLTIME"  # Default for all options
  
  BenefitOption: Basic
    eligibility_profile_id: null  # Inherits plan default
  
  BenefitOption: Premium
    eligibility_profile_id: "ELIG_SENIOR_STAFF"  # Override
  
  BenefitOption: Executive
    eligibility_profile_id: "ELIG_EXECUTIVES"  # Override
```

**Benefits of Centralized Approach**:
- ✅ **Reusability**: Same eligibility profile used across TA, TR, and other modules
- ✅ **Performance**: O(1) lookups via cached membership
- ✅ **Consistency**: Unified eligibility logic across system
- ✅ **Flexibility**: Hybrid model supports both simple and complex scenarios

**Migration Path**:
1. Create `Core.EligibilityProfile` matching existing `eligibility_rule_json`
2. Set `default_eligibility_profile_id` on BenefitPlan
3. Keep `eligibility_rule_json` for backward compatibility (deprecated)
4. Eventually remove `eligibility_rule_json` after full migration

**Reference**: See [Core Eligibility Engine Guide](../../CO/01-concept/11-eligibility-engine-guide.md) for detailed architecture.

---

## Summary (Part 1 of 3)

**Entities Covered**: 4 of 14
- BenefitPlan
- BenefitOption
- EligibilityProfile
- PlanEligibility

**Next**: EnrollmentPeriod, LifeEvent, EmployeeDependent, BenefitBeneficiary, Enrollment, ReimbursementRequest, ReimbursementLine, HealthcareClaimHeader, HealthcareClaimLine

---

**Document Status**: 🔄 In Progress (Part 1)  
**Coverage**: 4 of 14 entities documented  
**Last Updated**: 2025-12-04

### 5. EnrollmentPeriod

**Definition**: Open enrollment period defining when employees can enroll or change benefits.

**Purpose**: Manages enrollment windows for annual open enrollment, new hires, and special events.

**Key Characteristics**:
- Multiple period types (OPEN_ENROLLMENT, NEW_HIRE, QUALIFYING_EVENT, SPECIAL_ENROLLMENT)
- Automated reminder scheduling
- Auto-enrollment support
- Coverage effective date management

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Period code (e.g., OPEN_ENROLLMENT_2025) |
| `name` | string(200) | Yes | Period name |
| `period_type` | enum | Yes | OPEN_ENROLLMENT, NEW_HIRE, QUALIFYING_EVENT, SPECIAL_ENROLLMENT |
| `enrollment_start_date` | date | Yes | When enrollment opens |
| `enrollment_end_date` | date | Yes | When enrollment closes |
| `coverage_start_date` | date | Yes | When coverage begins |
| `coverage_end_date` | date | No | When coverage ends (NULL for ongoing) |
| `eligible_plans_json` | jsonb | No | Plans available during this period |
| `auto_enroll` | boolean | No | Auto-enroll eligible employees (default: false) |
| `reminder_schedule_json` | jsonb | No | Reminder schedule |
| `status` | enum | No | DRAFT, SCHEDULED, OPEN, CLOSED, CANCELLED |

**Reminder Schedule JSON**:

```yaml
reminder_schedule_json:
  reminders:
    - days_before_end: 30
      sent: false
    - days_before_end: 14
      sent: false
    - days_before_end: 7
      sent: false
    - days_before_end: 1
      sent: false
```

**Business Rules**:
1. enrollment_end_date must be before coverage_start_date
2. OPEN_ENROLLMENT typically annual (e.g., November for January coverage)
3. NEW_HIRE period for new employees (typically 30 days from hire)
4. QUALIFYING_EVENT triggered by life events

**Examples**:

```yaml
Example 1: Annual Open Enrollment
  EnrollmentPeriod:
    code: "OPEN_ENROLLMENT_2025"
    name: "2025 Annual Open Enrollment"
    period_type: OPEN_ENROLLMENT
    enrollment_start_date: "2024-11-01"
    enrollment_end_date: "2024-11-30"
    coverage_start_date: "2025-01-01"
    coverage_end_date: "2025-12-31"
    status: OPEN

Example 2: New Hire Enrollment
  EnrollmentPeriod:
    code: "NEW_HIRE_2025_Q1"
    name: "Q1 2025 New Hire Enrollment"
    period_type: NEW_HIRE
    enrollment_start_date: "2025-01-01"
    enrollment_end_date: "2025-03-31"
    coverage_start_date: "2025-01-01"
    auto_enroll: true
```

---

### 6. LifeEvent

**Definition**: Qualifying life events that trigger special enrollment periods.

**Purpose**: Tracks life events (marriage, birth, etc.) that allow mid-year benefit changes.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `event_type` | enum | Yes | MARRIAGE, DIVORCE, BIRTH, ADOPTION, DEATH_OF_DEPENDENT, LOSS_OF_COVERAGE, CHANGE_IN_EMPLOYMENT, RELOCATION, DISABILITY |
| `event_date` | date | Yes | Date event occurred |
| `reported_date` | date | Yes | Date employee reported event |
| `enrollment_deadline` | date | Yes | Deadline to make changes (typically event_date + 30 days) |
| `supporting_documents_json` | jsonb | No | Required documentation |
| `status` | enum | No | PENDING, VERIFIED, APPROVED, REJECTED, EXPIRED |
| `verified_by` | UUID | No | FK to Core.Employee (HR verifier) |
| `verified_date` | timestamp | No | When verified |

**Business Rules**:
1. enrollment_deadline typically 30 days from event_date
2. Supporting documents required for verification
3. VERIFIED status required before enrollment changes
4. Expired if not acted upon by deadline

**Examples**:

```yaml
Example: Birth of Child
  LifeEvent:
    employee_id: "EMP_001_UUID"
    event_type: BIRTH
    event_date: "2025-03-15"
    reported_date: "2025-03-20"
    enrollment_deadline: "2025-04-14"  # 30 days from event
    supporting_documents_json:
      documents:
        - type: "BIRTH_CERTIFICATE"
          uploaded: true
          url: "..."
    status: VERIFIED
```

---

### 7. EmployeeDependent

**Definition**: Employee dependents eligible for benefit coverage.

**Purpose**: Tracks dependent information, relationship, and eligibility status.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `full_name` | string(200) | Yes | Dependent's full legal name |
| `relationship` | enum | Yes | SPOUSE, DOMESTIC_PARTNER, CHILD, STEPCHILD, ADOPTED_CHILD, PARENT, SIBLING, OTHER |
| `date_of_birth` | date | Yes | Date of birth |
| `gender` | string(20) | No | Gender |
| `national_id` | string(50) | No | National ID/SSN (encrypted) |
| `is_student` | boolean | No | Full-time student status (default: false) |
| `is_disabled` | boolean | No | Disabled dependent (default: false) |
| `is_eligible` | boolean | No | Currently eligible (default: true) |
| `eligibility_end_date` | date | No | When eligibility ends (e.g., child turns 26) |
| `status` | enum | No | ACTIVE, INACTIVE, PENDING_VERIFICATION, INELIGIBLE |

**Business Rules**:
1. CHILD eligible until age 26 (US) or 21 (Vietnam)
2. STUDENT status extends eligibility to age 26
3. DISABLED dependents have no age limit
4. Supporting documents required for verification
5. Eligibility re-verified annually

**Examples**:

```yaml
Example 1: Child Dependent
  EmployeeDependent:
    employee_id: "EMP_001_UUID"
    full_name: "Nguyen Van B"
    relationship: CHILD
    date_of_birth: "2010-05-15"
    is_student: false
    is_eligible: true
    eligibility_end_date: "2031-05-15"  # Age 21 in Vietnam
    status: ACTIVE

Example 2: Spouse
  EmployeeDependent:
    full_name: "Tran Thi C"
    relationship: SPOUSE
    date_of_birth: "1985-08-20"
    is_eligible: true
    status: ACTIVE
```

---

### 8. BenefitBeneficiary

**Definition**: Beneficiaries for life insurance and retirement benefits.

**Purpose**: Designates who receives benefits in case of employee death.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `plan_id` | UUID | Yes | FK to BenefitPlan (LIFE or RETIREMENT) |
| `beneficiary_type` | enum | Yes | PRIMARY, CONTINGENT |
| `sequence` | integer | Yes | Order within type (1, 2, 3...) |
| `full_name` | string(200) | Yes | Beneficiary name |
| `relationship` | enum | Yes | SPOUSE, CHILD, PARENT, SIBLING, TRUST, ESTATE, OTHER |
| `allocation_percentage` | decimal(5,2) | Yes | Percentage of benefit (must sum to 100%) |
| `is_irrevocable` | boolean | No | Cannot be changed without consent (default: false) |
| `effective_date` | date | Yes | When designation becomes effective |
| `status` | enum | No | ACTIVE, INACTIVE, DECEASED |

**Business Rules**:
1. PRIMARY beneficiaries must sum to 100%
2. CONTINGENT beneficiaries receive if all PRIMARY deceased
3. CONTINGENT must also sum to 100%
4. IRREVOCABLE beneficiaries cannot be changed without consent

**Examples**:

```yaml
Example: Life Insurance Beneficiaries
  BenefitBeneficiary:
    - beneficiary_type: PRIMARY
      sequence: 1
      full_name: "Tran Thi C (Spouse)"
      relationship: SPOUSE
      allocation_percentage: 100.00
    
    - beneficiary_type: CONTINGENT
      sequence: 1
      full_name: "Nguyen Van B (Child)"
      relationship: CHILD
      allocation_percentage: 50.00
    
    - beneficiary_type: CONTINGENT
      sequence: 2
      full_name: "Nguyen Van D (Child)"
      relationship: CHILD
      allocation_percentage: 50.00
```

---

### 9. Enrollment

**Definition**: Employee benefit enrollment record tracking coverage elections.

**Purpose**: Records employee's benefit selections and coverage status.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `option_id` | UUID | Yes | FK to BenefitOption |
| `enrollment_period_id` | UUID | No | FK to EnrollmentPeriod |
| `life_event_id` | UUID | No | FK to LifeEvent (if triggered by event) |
| `coverage_start_date` | date | Yes | When coverage starts |
| `coverage_end_date` | date | No | When coverage ends (NULL = ongoing) |
| `status` | enum | No | ACTIVE, WAIVED, TERMINATED, PENDING, SUSPENDED |
| `waiver_reason` | string(200) | No | Reason for waiving coverage |
| `premium_employee` | decimal(18,4) | No | Employee premium per period |
| `premium_employer` | decimal(18,4) | No | Employer premium per period |
| `currency` | string(3) | Yes | Currency code |
| `covered_dependents_json` | jsonb | No | Dependents covered |

**Business Rules**:
1. Only one ACTIVE enrollment per plan per employee
2. WAIVED status requires waiver_reason
3. coverage_end_date must be after coverage_start_date
4. Premiums calculated from BenefitOption costs

**Examples**:

```yaml
Example: Family Medical Coverage
  Enrollment:
    employee_id: "EMP_001_UUID"
    option_id: "MEDICAL_FAMILY_UUID"
    enrollment_period_id: "OPEN_2025_UUID"
    coverage_start_date: "2025-01-01"
    status: ACTIVE
    premium_employee: 500000  # VND per month
    premium_employer: 1500000
    currency: "VND"
    covered_dependents_json:
      dependent_ids: ["DEP_001_UUID", "DEP_002_UUID"]
      count: 2
```

---

## Summary (Part 2 of 3)

**Entities Covered**: 9 of 14
- BenefitPlan, BenefitOption, EligibilityProfile, PlanEligibility
- EnrollmentPeriod, LifeEvent, EmployeeDependent, BenefitBeneficiary, Enrollment

**Next**: ReimbursementRequest, ReimbursementLine, HealthcareClaimHeader, HealthcareClaimLine, and final summary

---

**Document Status**: 🔄 In Progress (Part 2)  
**Coverage**: 9 of 14 entities documented  
**Last Updated**: 2025-12-04

### 10. ReimbursementRequest

**Definition**: Employee reimbursement request for medical, wellness, education, and other expenses.

**Purpose**: Manages employee expense reimbursement workflow with approval and payment tracking.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `option_id` | UUID | No | FK to BenefitOption (if related to benefit) |
| `request_type` | enum | Yes | EXPENSE, MEDICAL, WELLNESS, EDUCATION, TRANSPORTATION, CHILDCARE |
| `request_date` | date | Yes | Request submission date |
| `status` | enum | No | DRAFT, SUBMITTED, APPROVED, REJECTED, PAID, CANCELLED |
| `total_amount` | decimal(18,4) | Yes | Total requested amount |
| `approved_amount` | decimal(18,4) | No | Approved amount (may differ) |
| `currency` | string(3) | Yes | Currency code |
| `approver_id` | UUID | No | FK to Core.Employee (approver) |
| `decision_date` | timestamp | No | When decision was made |
| `payment_date` | date | No | When reimbursement was paid |
| `payment_method` | enum | No | BANK_TRANSFER, PAYROLL, CHECK, CASH |

**Business Rules**:
1. approved_amount <= total_amount
2. Cannot modify APPROVED or PAID request
3. Supporting documents required (receipts, invoices)
4. Approval required based on amount thresholds

**Examples**:

```yaml
Example: Medical Expense Reimbursement
  ReimbursementRequest:
    employee_id: "EMP_001_UUID"
    option_id: "MEDICAL_PLAN_UUID"
    request_type: MEDICAL
    request_date: "2025-03-15"
    total_amount: 2500000  # VND
    approved_amount: 2500000
    currency: "VND"
    status: APPROVED
    payment_method: BANK_TRANSFER
```

---

### 11. ReimbursementLine

**Definition**: Individual line item in reimbursement request.

**Purpose**: Supports multiple expenses per request with detailed tracking.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `request_id` | UUID | Yes | FK to ReimbursementRequest |
| `line_number` | integer | Yes | Line sequence (1, 2, 3...) |
| `description` | string(255) | Yes | Expense description |
| `expense_date` | date | Yes | When expense was incurred |
| `amount` | decimal(18,4) | Yes | Line amount |
| `currency` | string(3) | Yes | Currency code |
| `receipt_url` | string(500) | No | URL to receipt/invoice document |

**Examples**:

```yaml
Example: Multi-line Medical Reimbursement
  ReimbursementLine:
    - line_number: 1
      description: "Doctor consultation"
      expense_date: "2025-03-10"
      amount: 500000
      receipt_url: "https://..."
    
    - line_number: 2
      description: "Prescription medication"
      expense_date: "2025-03-10"
      amount: 2000000
      receipt_url: "https://..."
```

---

### 12. HealthcareClaimHeader

**Definition**: Healthcare insurance claim header tracking submission and payment status.

**Purpose**: Manages insurance claims submitted to providers for medical services.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `enrollment_id` | UUID | No | FK to Enrollment (related benefit) |
| `insurer_claim_id` | string(50) | No | Claim ID from insurance provider |
| `service_date` | date | Yes | Date of medical service |
| `provider_name` | string(255) | No | Healthcare provider name |
| `claim_status` | enum | No | SUBMITTED, IN_REVIEW, APPROVED, REJECTED, PAID, APPEALED |
| `amount` | decimal(18,4) | Yes | Total claim amount |
| `approved_amount` | decimal(18,4) | No | Approved amount by insurer |
| `paid_amount` | decimal(18,4) | No | Amount paid to provider/employee |
| `currency` | string(3) | Yes | Currency code |

**Business Rules**:
1. Claim must be linked to active enrollment
2. approved_amount <= amount
3. paid_amount <= approved_amount
4. Status workflow: SUBMITTED → IN_REVIEW → APPROVED → PAID

**Examples**:

```yaml
Example: Hospital Claim
  HealthcareClaimHeader:
    employee_id: "EMP_001_UUID"
    enrollment_id: "ENROLLMENT_UUID"
    insurer_claim_id: "BV-2025-123456"
    service_date: "2025-03-15"
    provider_name: "Vinmec Hospital"
    claim_status: APPROVED
    amount: 50000000  # VND
    approved_amount: 45000000
    paid_amount: 45000000
    currency: "VND"
```

---

### 13. HealthcareClaimLine

**Definition**: Individual procedure/service line in healthcare claim.

**Purpose**: Tracks specific medical procedures and charges within a claim.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `claim_header_id` | UUID | Yes | FK to HealthcareClaimHeader |
| `procedure_code` | string(50) | Yes | Medical procedure code (CPT, ICD-10) |
| `description` | text | No | Procedure description |
| `charge_amount` | decimal(18,4) | Yes | Provider charge amount |
| `allowed_amount` | decimal(18,4) | No | Insurance allowed amount |
| `currency` | string(3) | Yes | Currency code |

**Examples**:

```yaml
Example: Multi-procedure Claim
  HealthcareClaimLine:
    - procedure_code: "99213"
      description: "Office visit - established patient"
      charge_amount: 1500000
      allowed_amount: 1200000
    
    - procedure_code: "80053"
      description: "Comprehensive metabolic panel"
      charge_amount: 800000
      allowed_amount: 700000
```

---

### 14. Enrollment (Detailed)

**Additional Details for Enrollment Entity**

**Covered Dependents JSON**:

```yaml
covered_dependents_json:
  dependent_ids:
    - "DEP_001_UUID"  # Spouse
    - "DEP_002_UUID"  # Child 1
    - "DEP_003_UUID"  # Child 2
  count: 3
  coverage_tier: "EMPLOYEE_FAMILY"
```

**Workflow States**:
1. **PENDING**: Enrollment submitted, awaiting approval
2. **ACTIVE**: Coverage active and in effect
3. **WAIVED**: Employee declined coverage
4. **TERMINATED**: Coverage ended (termination, life event)
5. **SUSPENDED**: Temporarily suspended (leave of absence)

**Premium Calculation**:
- Employee premium deducted from payroll
- Employer premium paid directly to provider
- Total premium = employee + employer portions

---

## Summary

The Benefits sub-module provides **14 entities** that work together to manage:

1. **Plan Management**: BenefitPlan, BenefitOption, EligibilityProfile, PlanEligibility
2. **Enrollment**: EnrollmentPeriod, LifeEvent, Enrollment
3. **Dependents & Beneficiaries**: EmployeeDependent, BenefitBeneficiary
4. **Reimbursements**: ReimbursementRequest, ReimbursementLine
5. **Healthcare Claims**: HealthcareClaimHeader, HealthcareClaimLine

**Key Design Patterns**:
- ✅ Flexible eligibility rules with reusable profiles
- ✅ Multiple coverage tiers (employee, spouse, family)
- ✅ Life event tracking for mid-year changes
- ✅ Dependent age and eligibility management
- ✅ Beneficiary designation with primary/contingent
- ✅ Comprehensive reimbursement workflow
- ✅ Insurance claim integration

**Compliance Features**:
- ✅ HIPAA compliance for healthcare data
- ✅ Dependent eligibility verification
- ✅ Document management for proof
- ✅ Audit trail for all changes
- ✅ Age-based eligibility rules (26 for US, 21 for VN)

**Integration Points**:
- **Payroll Module**: Premium deductions from payroll
- **Core Module**: Employee, LegalEntity, Assignment linkages
- **Document Management**: Supporting documents for verification
- **Insurance Providers**: Claim submission and status tracking

**Typical Workflows**:

1. **Annual Open Enrollment**:
   - Create EnrollmentPeriod (OPEN_ENROLLMENT)
   - Employees review and select BenefitOptions
   - System creates/updates Enrollment records
   - Premiums effective on coverage_start_date

2. **New Hire Enrollment**:
   - Create EnrollmentPeriod (NEW_HIRE)
   - Auto-enroll in default options (if configured)
   - Employee can modify within 30 days
   - Coverage starts on hire date or first of month

3. **Qualifying Life Event**:
   - Employee reports LifeEvent (BIRTH, MARRIAGE, etc.)
   - HR verifies with supporting documents
   - Special enrollment period opens (30 days)
   - Employee adds dependents or changes coverage
   - Coverage changes effective from event date

4. **Medical Reimbursement**:
   - Employee submits ReimbursementRequest
   - Attaches receipts (ReimbursementLine)
   - Manager/HR approves
   - Payment processed via payroll or bank transfer

5. **Healthcare Claim**:
   - Employee receives medical service
   - Provider submits HealthcareClaimHeader to insurer
   - Insurer reviews and approves
   - Payment made to provider
   - Employee may have copay/deductible

---

**Document Status**: ✅ Complete  
**Coverage**: 14 of 14 entities documented  
**Last Updated**: 2025-12-04  
**Next Steps**: Create glossary-index.md to complete Phase 1
