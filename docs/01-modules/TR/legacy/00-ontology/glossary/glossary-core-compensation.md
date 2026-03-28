# Core Compensation - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-04  
**Module**: Total Rewards (TR)  
**Sub-module**: Core Compensation

---

## Overview

Core Compensation manages the foundational elements of employee pay structures, including:
- **Salary Basis**: Templates defining how compensation is structured (monthly, hourly, etc.)
- **Pay Components**: Individual elements of compensation (base salary, allowances, bonuses)
- **Grade System**: Salary grades, career ladders, and pay ranges
- **Compensation Cycles**: Merit reviews, promotions, and market adjustments
- **Budget Management**: Allocation and tracking of compensation budgets

This sub-module provides the building blocks for all compensation calculations and serves as the foundation for payroll integration.

---

## Entities

### 1. SalaryBasis

**Definition**: A template that defines the structure and frequency of employee compensation.

**Purpose**: Standardizes how compensation is calculated across different employee types, countries, and legal entities.

**Key Characteristics**:
- Supports multiple pay frequencies (hourly, daily, monthly, annual)
- Multi-currency support for global operations
- Component-based architecture for flexibility
- Country-specific configuration via metadata

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Unique code (e.g., MONTHLY_VN, HOURLY_US) |
| `name` | string(200) | Yes | Display name |
| `frequency` | enum | Yes | HOURLY, DAILY, WEEKLY, BIWEEKLY, SEMIMONTHLY, MONTHLY, ANNUAL |
| `currency` | string(3) | Yes | ISO 4217 currency code |
| `allow_components` | boolean | No | Whether additional components can be added (default: true) |
| `metadata` | jsonb | No | Country-specific rules and configuration |
| `effective_start_date` | date | Yes | When this basis becomes active |
| `effective_end_date` | date | No | When this basis expires |

**Relationships**:

| Relationship | Target Entity | Cardinality | Description |
|--------------|---------------|-------------|-------------|
| `components` | SalaryBasisComponentMap | 1:N | Pay components included in this basis |
| `calculationRules` | BasisCalculationRule | 1:N | Calculation rules for this basis |

**Business Rules**:
1. Salary basis code must be unique across the system
2. Frequency must align with country labor standards
3. Currency must match the legal entity's currency
4. Components can be added dynamically if `allow_components = true`

**Examples**:

```yaml
Example 1: Vietnam Monthly Salary Basis
  SalaryBasis:
    code: "MONTHLY_VN"
    name: "Vietnam Monthly Salary"
    frequency: MONTHLY
    currency: "VND"
    allow_components: true
    metadata:
      country: "VN"
      working_days_per_month: 26
      standard_hours_per_month: 208

Example 2: US Hourly Wage Basis
  SalaryBasis:
    code: "HOURLY_US"
    name: "US Hourly Wage"
    frequency: HOURLY
    currency: "USD"
    allow_components: true
    metadata:
      country: "US"
      overtime_multiplier: 1.5
```

**Best Practices**:
- ✅ DO: Create separate salary bases for different countries/regions
- ✅ DO: Use descriptive codes that include country and frequency
- ❌ DON'T: Mix multiple currencies in the same salary basis
- ❌ DON'T: Change frequency of an active salary basis (create new version instead)

**Related Entities**:
- PayComponentDefinition - Defines individual pay components
- SalaryBasisComponentMap - Maps components to salary basis
- BasisCalculationRule - Calculation rules for the basis

---

### 2. PayComponentDefinition

**Definition**: Individual compensation element such as base salary, allowance, bonus, or deduction.

**Purpose**: Provides modular building blocks for total compensation packages with specific tax and calculation rules.

**Key Characteristics**:
- Supports multiple component types (BASE, ALLOWANCE, BONUS, DEDUCTION, etc.)
- Configurable tax treatment and social insurance rules
- Flexible calculation methods (fixed, formula, percentage, rate table)
- Proration support for partial periods

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Unique code (e.g., BASE_SALARY, LUNCH_ALLOWANCE) |
| `name` | string(200) | Yes | Display name |
| `component_type` | enum | Yes | BASE, ALLOWANCE, BONUS, EQUITY, DEDUCTION, OVERTIME, COMMISSION |
| `frequency` | enum | Yes | HOURLY, DAILY, MONTHLY, QUARTERLY, ANNUAL, ONE_TIME |
| `taxable` | boolean | No | Whether component is taxable (default: true) |
| `prorated` | boolean | No | Whether prorated for partial periods (default: true) |
| `calculation_method` | enum | No | FIXED, FORMULA, PERCENTAGE, HOURLY, DAILY, RATE_TABLE |
| `proration_method` | enum | No | CALENDAR_DAYS, WORKING_DAYS, NONE |
| `tax_treatment` | enum | No | FULLY_TAXABLE, TAX_EXEMPT, PARTIALLY_EXEMPT |
| `tax_exempt_threshold` | decimal(18,4) | No | Tax-exempt amount (e.g., 730,000 VND for lunch) |
| `is_subject_to_si` | boolean | No | Subject to social insurance (default: false) |
| `si_calculation_basis` | enum | No | FULL_AMOUNT, CAPPED, EXCLUDED |

**Business Rules**:
1. Component code must be unique
2. Tax-exempt threshold only applies when `tax_treatment = PARTIALLY_EXEMPT`
3. SI calculation basis required if `is_subject_to_si = true`
4. Proration method required if `prorated = true`

**Examples**:

```yaml
Example 1: Base Salary (Vietnam)
  PayComponentDefinition:
    code: "BASE_SALARY"
    name: "Base Salary"
    component_type: BASE
    frequency: MONTHLY
    taxable: true
    prorated: true
    proration_method: CALENDAR_DAYS
    tax_treatment: FULLY_TAXABLE
    is_subject_to_si: true
    si_calculation_basis: CAPPED

Example 2: Lunch Allowance (Vietnam - Tax Exempt)
  PayComponentDefinition:
    code: "LUNCH_ALLOWANCE"
    name: "Lunch Allowance"
    component_type: ALLOWANCE
    frequency: MONTHLY
    taxable: true
    tax_treatment: PARTIALLY_EXEMPT
    tax_exempt_threshold: 730000  # VND per month
    is_subject_to_si: false
```

**Best Practices**:
- ✅ DO: Use clear, standardized component codes
- ✅ DO: Configure tax treatment according to local regulations
- ✅ DO: Set proration rules appropriate for component type
- ❌ DON'T: Change tax treatment of active components without legal review
- ❌ DON'T: Mix different calculation methods in the same component

**Related Entities**:
- SalaryBasis - Groups components into compensation structures
- ComponentCalculationRule - Detailed calculation logic
- ComponentDependency - Defines calculation order dependencies

---

## References

- **Ontology**: tr-ontology.yaml (lines 149-1450)
- **Concept Guides**: 
  - ../01-concept/01-compensation-fundamentals.md (to be created)
  - ../01-concept/02-salary-structures.md (to be created)
- **Specifications**:
  - ../02-spec/01-functional-requirements.md (to be created)
  - ../02-spec/04-business-rules.md (to be created)

---

**Document Status**: Phase 1 - In Progress  
**Coverage**: 2 of 14 entities documented  
**Next**: GradeVersion, PayRange, CompensationPlan

### 3. SalaryBasisComponentMap

**Definition**: Mapping table that associates pay components with salary bases and defines component-specific rules.

**Purpose**: Allows flexible configuration of which components are included in each salary basis, with ability to override default settings.

**Key Characteristics**:
- Many-to-many relationship between SalaryBasis and PayComponentDefinition
- Component-level overrides for proration and calculation
- Defines calculation order for dependent components
- Controls mandatory vs optional components

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `salary_basis_id` | UUID | Yes | FK to SalaryBasis |
| `component_id` | UUID | Yes | FK to PayComponentDefinition |
| `mandatory_flag` | boolean | No | Whether component is required (default: false) |
| `sort_order` | integer | No | Display order in basis |
| `enable_proration` | boolean | No | Override component's proration setting |
| `proration_method` | enum | No | CALENDAR_DAYS, WORKING_DAYS, NONE |
| `calculation_order` | integer | No | Execution sequence (1=first, 2=second, etc.) |
| `custom_formula_json` | jsonb | No | Basis-specific formula override |

**Relationships**:

| Relationship | Target Entity | Cardinality | Description |
|--------------|---------------|-------------|-------------|
| `salaryBasis` | SalaryBasis | N:1 | Parent salary basis |
| `component` | PayComponentDefinition | N:1 | Pay component |

**Business Rules**:
1. Each component can appear only once per salary basis
2. Calculation order determines execution sequence
3. Custom formula overrides component's default formula
4. Mandatory components cannot be removed from employee compensation

**Examples**:

```yaml
Example: Vietnam Monthly Basis with Components
  SalaryBasisComponentMap:
    - salary_basis_id: "MONTHLY_VN_UUID"
      component_id: "BASE_SALARY_UUID"
      mandatory_flag: true
      calculation_order: 1
      sort_order: 1
    
    - salary_basis_id: "MONTHLY_VN_UUID"
      component_id: "LUNCH_ALLOWANCE_UUID"
      mandatory_flag: false
      calculation_order: 2
      sort_order: 2
      enable_proration: true
      proration_method: WORKING_DAYS
```

**Best Practices**:
- ✅ DO: Set calculation_order for components with dependencies
- ✅ DO: Mark base salary as mandatory
- ❌ DON'T: Create circular dependencies in calculation order
- ❌ DON'T: Override proration without business justification

---

### 4. GradeVersion

**Definition**: Versioned salary grade definition using SCD Type 2 pattern to maintain complete history.

**Purpose**: Tracks grade changes over time while preserving historical data for reporting and compliance.

**Key Characteristics**:
- SCD Type 2 implementation with version chain
- Supports career progression and job leveling
- Links to pay ranges and career ladders
- Maintains audit trail of all grade changes

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `grade_code` | string(20) | Yes | Grade code (e.g., G1, G2, M1, T5) |
| `name` | string(100) | Yes | Grade name |
| `description` | text | No | Detailed description |
| `job_level` | integer | No | Hierarchy level (1=entry, 10=executive) |
| `sort_order` | integer | No | Display order |
| `effective_start_date` | date | Yes | When this version becomes active |
| `effective_end_date` | date | No | When this version expires (NULL for current) |
| `version_number` | integer | No | SCD Type 2 version (default: 1) |
| `previous_version_id` | UUID | No | FK to previous version |
| `is_current_version` | boolean | No | True for current version only (default: true) |

**Relationships**:

| Relationship | Target Entity | Cardinality | Description |
|--------------|---------------|-------------|-------------|
| `previousVersion` | GradeVersion | N:1 | Previous version in SCD chain |
| `payRanges` | PayRange | 1:N | Pay ranges for this grade |
| `ladderGrades` | GradeLadderGrade | 1:N | Career ladder assignments |

**Business Rules**:
1. Only one current version per grade_code (is_current_version = true)
2. effective_end_date must be NULL for current version
3. New version's effective_start_date = previous version's effective_end_date + 1 day
4. Version chain must be unbroken

**Examples**:

```yaml
Example: Grade Evolution
  GradeVersion (Version 1 - Historical):
    grade_code: "G5"
    name: "Grade 5 - Senior Professional"
    job_level: 5
    effective_start_date: "2023-01-01"
    effective_end_date: "2024-12-31"
    version_number: 1
    is_current_version: false
  
  GradeVersion (Version 2 - Current):
    grade_code: "G5"
    name: "Grade 5 - Senior Professional (Enhanced)"
    job_level: 5
    effective_start_date: "2025-01-01"
    effective_end_date: null
    version_number: 2
    previous_version_id: "G5_V1_UUID"
    is_current_version: true
```

**Best Practices**:
- ✅ DO: Create new version when changing grade structure
- ✅ DO: Maintain version chain integrity
- ✅ DO: Document reason for grade changes in metadata
- ❌ DON'T: Delete historical grade versions
- ❌ DON'T: Modify effective dates of closed versions

---

### 5. GradeLadder

**Definition**: Career progression path defining how employees advance through salary grades.

**Purpose**: Structures career development by defining grade sequences for different career tracks.

**Key Characteristics**:
- Supports multiple ladder types (Management, Technical, Specialist, Sales, Executive)
- Defines progression sequence within career track
- Links grades in hierarchical order
- Enables career planning and succession management

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Unique ladder code |
| `name` | string(200) | Yes | Ladder name |
| `description` | text | No | Detailed description |
| `ladder_type` | enum | No | MANAGEMENT, TECHNICAL, SPECIALIST, SALES, EXECUTIVE |
| `metadata` | jsonb | No | Additional configuration |
| `effective_start_date` | date | Yes | When ladder becomes active |
| `effective_end_date` | date | No | When ladder expires |
| `is_active` | boolean | No | Active status (default: true) |

**Relationships**:

| Relationship | Target Entity | Cardinality | Description |
|--------------|---------------|-------------|-------------|
| `grades` | GradeLadderGrade | 1:N | Grades in this ladder |
| `steps` | GradeLadderStep | 1:N | Salary steps within grades |

**Business Rules**:
1. Ladder code must be unique
2. Ladder type determines applicable career paths
3. Grades must be ordered by seniority (sort_order)
4. One employee can be on multiple ladders (e.g., technical + management)

**Examples**:

```yaml
Example 1: Technical Career Ladder
  GradeLadder:
    code: "TECH_LADDER"
    name: "Technical Career Path"
    ladder_type: TECHNICAL
    description: "Individual contributor technical progression"
    grades:
      - G1: Junior Engineer
      - G2: Engineer
      - G3: Senior Engineer
      - G4: Staff Engineer
      - G5: Principal Engineer

Example 2: Management Career Ladder
  GradeLadder:
    code: "MGMT_LADDER"
    name: "Management Career Path"
    ladder_type: MANAGEMENT
    description: "People management progression"
    grades:
      - M1: Team Lead
      - M2: Manager
      - M3: Senior Manager
      - M4: Director
      - M5: VP
```

**Best Practices**:
- ✅ DO: Create separate ladders for different career tracks
- ✅ DO: Define clear progression criteria
- ✅ DO: Allow lateral movement between ladders
- ❌ DON'T: Create too many ladder types (keep it simple)
- ❌ DON'T: Skip grades in progression path

---


### 6. GradeLadderGrade

**Definition**: Associates grades with career ladders in specific progression order.

**Purpose**: Defines the sequence of grades within a career track for promotion planning.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `ladder_id` | UUID | Yes | FK to GradeLadder |
| `grade_v_id` | UUID | Yes | FK to GradeVersion |
| `sort_order` | integer | No | Position in ladder (1=entry, higher=senior) |

**Business Rules**:
1. Each grade can appear only once per ladder
2. Sort order determines progression sequence
3. Gaps in sort order are allowed (for future grades)

---

### 7. GradeLadderStep

**Definition**: Salary steps within a grade for incremental progression.

**Purpose**: Allows salary increases within the same grade level without promotion.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `ladder_id` | UUID | Yes | FK to GradeLadder |
| `grade_v_id` | UUID | Yes | FK to GradeVersion |
| `step_number` | integer | Yes | Step number within grade (1, 2, 3...) |
| `step_name` | string(100) | No | Optional name (e.g., Entry, Mid, Senior) |
| `step_amount` | decimal(18,4) | No | Salary amount for this step |
| `currency` | string(3) | No | Currency code |
| `effective_start_date` | date | Yes | When step becomes active |
| `effective_end_date` | date | No | When step expires |

**Examples**:

```yaml
Example: Grade 5 with 3 Steps
  GradeLadderStep:
    - step_number: 1
      step_name: "G5 Entry"
      step_amount: 25000000  # VND
      currency: "VND"
    - step_number: 2
      step_name: "G5 Mid"
      step_amount: 30000000
    - step_number: 3
      step_name: "G5 Senior"
      step_amount: 35000000
```

---

### 8. PayRange

**Definition**: Defines minimum, midpoint, and maximum salary for a grade at different organizational scopes.

**Purpose**: Establishes compensation boundaries and ensures pay equity across the organization.

**Key Characteristics**:
- Multi-scope support (Global, Legal Entity, Business Unit, Position)
- Min-Mid-Max structure for flexibility
- Range spread calculation for market competitiveness
- Currency-specific ranges

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `grade_v_id` | UUID | Yes | FK to GradeVersion |
| `scope_type` | enum | Yes | GLOBAL, LEGAL_ENTITY, BUSINESS_UNIT, POSITION |
| `scope_uuid` | UUID | Yes | ID of scope entity |
| `currency` | string(3) | Yes | Currency code |
| `min_amount` | decimal(18,4) | Yes | Minimum salary |
| `mid_amount` | decimal(18,4) | Yes | Midpoint salary (market rate) |
| `max_amount` | decimal(18,4) | Yes | Maximum salary |
| `range_spread_pct` | decimal(5,2) | No | Calculated: (max-min)/mid*100 |
| `effective_start_date` | date | Yes | When range becomes active |
| `effective_end_date` | date | No | When range expires |

**Business Rules**:
1. min_amount < mid_amount < max_amount (enforced by CHECK constraint)
2. range_spread_pct = (max_amount - min_amount) / mid_amount * 100
3. Currency must match scope entity currency
4. More specific scopes override broader scopes (Position > BU > LE > Global)

**Examples**:

```yaml
Example 1: Global Pay Range for Grade 5
  PayRange:
    grade_v_id: "G5_UUID"
    scope_type: GLOBAL
    scope_uuid: "GLOBAL_SCOPE_UUID"
    currency: "USD"
    min_amount: 80000
    mid_amount: 100000
    max_amount: 120000
    range_spread_pct: 40.0  # (120k-80k)/100k*100

Example 2: Vietnam-specific Pay Range
  PayRange:
    grade_v_id: "G5_UUID"
    scope_type: LEGAL_ENTITY
    scope_uuid: "VNG_CORP_UUID"
    currency: "VND"
    min_amount: 25000000
    mid_amount: 30000000
    max_amount: 35000000
    range_spread_pct: 33.33
```

**Best Practices**:
- ✅ DO: Review and update ranges annually for market competitiveness
- ✅ DO: Use midpoint as target for fully competent performers
- ✅ DO: Keep range spread between 30-50% for most grades
- ❌ DON'T: Set ranges too narrow (limits flexibility)
- ❌ DON'T: Allow salaries outside min-max without exception approval

---

### 9. CompensationPlan

**Definition**: Template defining compensation review plan type and eligibility rules.

**Purpose**: Structures different types of compensation reviews (merit, promotion, market adjustment).

**Key Characteristics**:
- Multiple plan types for different scenarios
- Configurable eligibility rules
- Merit matrices and guidelines
- Approval threshold configuration

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Unique plan code |
| `name` | string(200) | Yes | Plan name |
| `description` | text | No | Detailed description |
| `plan_type` | enum | Yes | MERIT, PROMOTION, MARKET_ADJUSTMENT, NEW_HIRE, EQUITY_CORRECTION, AD_HOC |
| `eligibility_rule` | jsonb | No | Who is eligible (tenure, performance, etc.) |
| `guideline_json` | jsonb | No | Merit matrices, guidelines, approval thresholds |
| `effective_start_date` | date | Yes | When plan becomes active |
| `effective_end_date` | date | No | When plan expires |
| `is_active` | boolean | No | Active status (default: true) |

**Relationships**:

| Relationship | Target Entity | Cardinality | Description |
|--------------|---------------|-------------|-------------|
| `cycles` | CompensationCycle | 1:N | Specific instances of this plan |

**Examples**:

```yaml
Example: Annual Merit Plan
  CompensationPlan:
    code: "MERIT_2025"
    name: "2025 Annual Merit Review"
    plan_type: MERIT
    eligibility_rule:
      min_tenure_months: 6
      performance_rating_min: 3
      employment_status: ACTIVE
    guideline_json:
      merit_matrix:
        - performance: 5, compa_ratio: "<90%", increase: "8-10%"
        - performance: 5, compa_ratio: "90-110%", increase: "6-8%"
        - performance: 4, compa_ratio: "<90%", increase: "5-7%"
      approval_thresholds:
        manager: "0-5%"
        director: "5-10%"
        vp: ">10%"
```

**Best Practices**:
- ✅ DO: Define clear eligibility criteria
- ✅ DO: Use merit matrices for consistency
- ✅ DO: Set approval thresholds based on increase size
- ❌ DON'T: Make eligibility rules too complex
- ❌ DON'T: Change guidelines mid-cycle

---


### 10. CompensationCycle

**Definition**: Specific instance of a compensation plan for a defined time period with budget and workflow management.

**Purpose**: Manages the execution of compensation reviews including budget tracking and approval workflows.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `plan_id` | UUID | Yes | FK to CompensationPlan |
| `code` | string(50) | Yes | Cycle identifier (e.g., MERIT_2025_Q1) |
| `name` | string(200) | Yes | Cycle name |
| `period_start` | date | Yes | Review period start |
| `period_end` | date | Yes | Review period end |
| `effective_date` | date | Yes | When adjustments take effect |
| `budget_amount` | decimal(18,4) | No | Total budget |
| `budget_currency` | string(3) | No | Budget currency |
| `workflow_state` | jsonb | No | Current workflow state and history |
| `status` | enum | No | DRAFT, OPEN, IN_REVIEW, APPROVED, CLOSED, CANCELLED |

**Business Rules**:
1. period_end must be after period_start
2. effective_date typically after period_end
3. Cannot reopen CLOSED cycle
4. Budget tracking updates in real-time as adjustments are approved

**Examples**:

```yaml
Example: 2025 Q1 Merit Cycle
  CompensationCycle:
    plan_id: "MERIT_2025_UUID"
    code: "MERIT_2025_Q1"
    name: "Q1 2025 Merit Review"
    period_start: "2025-01-01"
    period_end: "2025-03-31"
    effective_date: "2025-04-01"
    budget_amount: 5000000000  # 5B VND
    budget_currency: "VND"
    status: OPEN
```

---

### 11. CompensationAdjustment

**Definition**: Individual compensation adjustment proposal within a cycle with approval workflow.

**Purpose**: Tracks proposed salary changes from current to new amounts with full audit trail.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `cycle_id` | UUID | Yes | FK to CompensationCycle |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `assignment_id` | UUID | Yes | FK to Core.Assignment |
| `component_id` | UUID | Yes | FK to PayComponentDefinition |
| `current_amount` | decimal(18,4) | No | Current component amount |
| `proposed_amount` | decimal(18,4) | Yes | Proposed new amount |
| `increase_amount` | decimal(18,4) | No | Computed: proposed - current |
| `increase_pct` | decimal(7,4) | No | Computed: (proposed - current) / current * 100 |
| `currency` | string(3) | Yes | Currency code |
| `rationale_code` | string(50) | No | Reason code (MERIT, PROMOTION, MARKET) |
| `rationale_text` | text | No | Detailed rationale |
| `approval_status` | enum | No | DRAFT, PENDING, APPROVED, REJECTED, WITHDRAWN |
| `approver_emp_id` | UUID | No | FK to Core.Employee (approver) |
| `decision_date` | timestamp | No | When decision was made |

**Business Rules**:
1. increase_amount = proposed_amount - current_amount
2. increase_pct = (proposed_amount - current_amount) / current_amount * 100
3. Cannot modify APPROVED adjustment
4. Approval required based on increase percentage (per plan guidelines)

**Examples**:

```yaml
Example: Merit Increase
  CompensationAdjustment:
    cycle_id: "MERIT_2025_Q1_UUID"
    employee_id: "EMP_001_UUID"
    component_id: "BASE_SALARY_UUID"
    current_amount: 30000000
    proposed_amount: 32400000
    increase_amount: 2400000
    increase_pct: 8.0
    currency: "VND"
    rationale_code: "MERIT"
    rationale_text: "Excellent performance, exceeded all KPIs"
    approval_status: APPROVED
```

---

### 12. EmployeeCompensationSnapshot

**Definition**: Point-in-time snapshot of employee compensation created from approved adjustments.

**Purpose**: Maintains current and historical compensation data using SCD Type 2 pattern.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `assignment_id` | UUID | Yes | FK to Core.Assignment |
| `component_id` | UUID | Yes | FK to PayComponentDefinition |
| `amount` | decimal(18,4) | Yes | Component amount |
| `currency` | string(3) | Yes | Currency code |
| `frequency` | enum | Yes | HOURLY, DAILY, MONTHLY, ANNUAL |
| `status` | enum | Yes | PLANNED, ACTIVE, EXPIRED |
| `source_type` | enum | No | COMP_ADJUSTMENT, OFFER_PACKAGE, MASS_UPLOAD, MANUAL |
| `source_ref` | string(100) | No | Reference to source record |
| `effective_start_date` | date | Yes | When snapshot becomes active |
| `effective_end_date` | date | No | When snapshot expires (NULL for ACTIVE) |

**Business Rules**:
1. Only one ACTIVE snapshot per employee+component at any time
2. effective_end_date must be NULL for ACTIVE status
3. New snapshot automatically ends previous snapshot (SCD Type 2)
4. Used by payroll for current compensation retrieval

---

### 13. BudgetAllocation

**Definition**: Budget allocation and utilization tracking by organizational scope.

**Purpose**: Monitors budget spending during compensation cycles to prevent over-allocation.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `cycle_id` | UUID | Yes | FK to CompensationCycle |
| `scope_type` | enum | Yes | GLOBAL, LEGAL_ENTITY, BUSINESS_UNIT, DEPARTMENT, TEAM |
| `scope_uuid` | UUID | No | ID of scope entity |
| `allocated_amount` | decimal(18,4) | Yes | Budget allocated |
| `utilized_amount` | decimal(18,4) | No | Budget used (default: 0) |
| `utilization_pct` | decimal(5,2) | No | Computed: (utilized/allocated)*100 |
| `currency` | string(3) | Yes | Currency code |

**Business Rules**:
1. utilization_pct = (utilized_amount / allocated_amount) * 100
2. utilized_amount cannot exceed allocated_amount (warning, not hard block)
3. Real-time updates as adjustments are approved

---

### 14. ComponentDependency & ProrationRule & SalaryHistory

**ComponentDependency**: Defines calculation order dependencies between pay components.

**ProrationRule**: Structured proration rules for partial period calculations with country-specific formulas.

**SalaryHistory**: Dedicated salary change history for audit and reporting, complementing EmployeeCompensationSnapshot.

*(See tr-ontology.yaml lines 1167-1450 for full details)*

---

## Summary

The Core Compensation sub-module provides **14 entities** that work together to manage:

1. **Structure**: SalaryBasis, PayComponentDefinition, SalaryBasisComponentMap
2. **Grades & Ranges**: GradeVersion, GradeLadder, GradeLadderGrade, GradeLadderStep, PayRange
3. **Cycles & Adjustments**: CompensationPlan, CompensationCycle, CompensationAdjustment
4. **Tracking**: EmployeeCompensationSnapshot, BudgetAllocation, SalaryHistory
5. **Rules**: ComponentDependency, ProrationRule

**Key Design Patterns**:
- ✅ SCD Type 2 for historical tracking (GradeVersion, EmployeeCompensationSnapshot)
- ✅ Flexible component-based architecture
- ✅ Multi-scope support (Global → Legal Entity → Business Unit → Position)
- ✅ Real-time budget tracking
- ✅ Comprehensive audit trail

---

**Document Status**: ✅ Complete  
**Coverage**: 14 of 14 entities documented  
**Last Updated**: 2025-12-04  
**Next Steps**: Create glossary-calculation-rules.md
