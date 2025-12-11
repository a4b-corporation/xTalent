# Hybrid Eligibility Architecture - Detailed Design

**Version**: 1.0  
**Date**: 2025-12-11  
**Approach**: Option 3 - Hybrid (Default + Override)

---

## 🎯 Executive Summary

### Confirmed Approach

✅ **Hybrid Model**: 
- **Default Eligibility** at `LeaveClass`/`LeaveType` level
- **Override Eligibility** at individual rule level (`AccrualRule`, `CarryoverRule`, etc.)
- **Organizational Scope** (BU, LE, country, grade, etc.) managed by `EligibilityProfile` in **Core module**
- **Object Scope** (`leaveTypeId`, `leaveClassId`) remains in each rule

### Key Clarifications

| Scope Type | Location | Example | Purpose |
|------------|----------|---------|---------|
| **Object Scope** | Rule itself | `leaveTypeId`, `leaveClassId` | Link rule to business object |
| **Organizational Scope** | `EligibilityProfile` | `BU`, `LE`, `country`, `grade` | Define WHO is eligible |

---

## 🏗️ Architecture Design

### 1. Core Module - Eligibility Engine

```sql
-- Core Module: Eligibility Profile
CREATE TABLE core.eligibility_profile (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code              varchar(50) UNIQUE NOT NULL,
  name              varchar(255) NOT NULL,
  domain            varchar(50) NOT NULL,  -- ABSENCE | BENEFITS | COMPENSATION | CORE
  description       text,
  
  -- Dynamic criteria (organizational scope)
  rule_json         jsonb NOT NULL,
  -- Example: {
  --   "business_units": ["BU_SALES", "BU_TECH"],
  --   "legal_entities": ["LE_VN", "LE_SG"],
  --   "countries": ["VN", "SG"],
  --   "grades": ["G4", "G5", "M3", "M4", "M5"],
  --   "employment_types": ["FULL_TIME"],
  --   "min_tenure_months": 6,
  --   "departments": ["SALES", "MARKETING"]
  -- }
  
  priority          integer DEFAULT 10,
  is_active         boolean DEFAULT true,
  
  -- SCD Type 2
  effective_start_date date NOT NULL,
  effective_end_date   date,
  is_current_flag      boolean DEFAULT true,
  
  created_at        timestamp DEFAULT now(),
  updated_at        timestamp,
  
  CONSTRAINT chk_domain CHECK (domain IN ('ABSENCE', 'BENEFITS', 'COMPENSATION', 'CORE'))
);

-- Core Module: Cached Membership
CREATE TABLE core.eligibility_member (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id        uuid NOT NULL REFERENCES core.eligibility_profile(id),
  employee_id       uuid NOT NULL REFERENCES employment.employee(id),
  
  start_date        date NOT NULL,
  end_date          date,
  
  -- Evaluation metadata
  last_evaluated_at timestamp NOT NULL,
  evaluation_source varchar(50) NOT NULL,  -- AUTO | MANUAL | OVERRIDE
  evaluation_reason text,
  
  metadata          jsonb,
  
  CONSTRAINT uq_eligibility_member UNIQUE (profile_id, employee_id, start_date)
);

CREATE INDEX idx_eligibility_member_lookup 
  ON core.eligibility_member(profile_id, employee_id) 
  WHERE end_date IS NULL;

CREATE INDEX idx_eligibility_member_employee 
  ON core.eligibility_member(employee_id, profile_id) 
  WHERE end_date IS NULL;
```

---

### 2. TA Module - Absence with Hybrid Eligibility

#### LeaveClass with Default Eligibility

```sql
-- TA Module: Leave Class
CREATE TABLE absence.leave_class (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code              varchar(50) UNIQUE NOT NULL,
  name              varchar(255) NOT NULL,
  category          varchar(50) NOT NULL,  -- PAID | UNPAID | STATUTORY | SPECIAL
  
  -- ✅ NEW: Default eligibility for all rules under this class
  default_eligibility_profile_id uuid REFERENCES core.eligibility_profile(id),
  
  is_active         boolean DEFAULT true,
  effective_start_date date NOT NULL,
  effective_end_date   date,
  is_current_flag      boolean DEFAULT true,
  
  created_at        timestamp DEFAULT now(),
  updated_at        timestamp
);

-- TA Module: Leave Type
CREATE TABLE absence.leave_type (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  leave_class_id    uuid NOT NULL REFERENCES absence.leave_class(id),
  code              varchar(50) UNIQUE NOT NULL,
  name              varchar(255) NOT NULL,
  
  -- ✅ NEW: Default eligibility (can override class default)
  default_eligibility_profile_id uuid REFERENCES core.eligibility_profile(id),
  
  is_paid           boolean DEFAULT true,
  requires_approval boolean DEFAULT true,
  allows_half_day   boolean DEFAULT false,
  unit_of_measure   varchar(20) DEFAULT 'DAYS',  -- DAYS | HOURS
  
  is_active         boolean DEFAULT true,
  effective_start_date date NOT NULL,
  effective_end_date   date,
  is_current_flag      boolean DEFAULT true,
  
  created_at        timestamp DEFAULT now(),
  updated_at        timestamp
);
```

#### Rules with Override Eligibility

```sql
-- TA Module: Accrual Rule
CREATE TABLE absence.accrual_rule (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code              varchar(50) UNIQUE NOT NULL,
  name              varchar(255) NOT NULL,
  
  -- ✅ KEEP: Object scope (which leave type/class)
  leave_type_id     uuid REFERENCES absence.leave_type(id),
  leave_class_id    uuid REFERENCES absence.leave_class(id),
  
  -- ✅ NEW: Override eligibility (organizational scope)
  eligibility_profile_id uuid REFERENCES core.eligibility_profile(id),
  -- If NULL: use default from leave_type or leave_class
  
  -- Accrual configuration
  accrual_method    varchar(50) NOT NULL,  -- UPFRONT | MONTHLY | BIWEEKLY | WEEKLY
  accrual_amount    decimal(10,2) NOT NULL,
  accrual_period    varchar(20),  -- YEAR | MONTH | WEEK
  max_accrual_balance decimal(10,2),
  
  priority          integer DEFAULT 10,
  is_active         boolean DEFAULT true,
  effective_start_date date NOT NULL,
  effective_end_date   date,
  is_current_flag      boolean DEFAULT true,
  
  created_at        timestamp DEFAULT now(),
  updated_at        timestamp,
  
  CONSTRAINT chk_accrual_scope CHECK (
    (leave_type_id IS NOT NULL AND leave_class_id IS NULL) OR
    (leave_type_id IS NULL AND leave_class_id IS NOT NULL)
  )
);

-- TA Module: Carryover Rule
CREATE TABLE absence.carryover_rule (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code              varchar(50) UNIQUE NOT NULL,
  name              varchar(255) NOT NULL,
  
  -- ✅ KEEP: Object scope
  leave_type_id     uuid REFERENCES absence.leave_type(id),
  leave_class_id    uuid REFERENCES absence.leave_class(id),
  
  -- ✅ NEW: Override eligibility
  eligibility_profile_id uuid REFERENCES core.eligibility_profile(id),
  
  -- Carryover configuration
  carryover_type    varchar(50) NOT NULL,  -- NONE | UNLIMITED | LIMITED | EXPIRE_ALL | PAYOUT
  max_carryover_amount decimal(10,2),
  carryover_expiry_months integer,
  payout_rate       decimal(5,2),
  
  priority          integer DEFAULT 10,
  is_active         boolean DEFAULT true,
  effective_start_date date NOT NULL,
  effective_end_date   date,
  is_current_flag      boolean DEFAULT true,
  
  created_at        timestamp DEFAULT now(),
  updated_at        timestamp,
  
  CONSTRAINT chk_carryover_scope CHECK (
    (leave_type_id IS NOT NULL AND leave_class_id IS NULL) OR
    (leave_type_id IS NULL AND leave_class_id IS NOT NULL)
  )
);

-- Similar structure for:
-- - absence.limit_rule
-- - absence.overdraft_rule
-- - absence.proration_rule
-- - absence.rounding_rule
-- - absence.validation_rule
```

---

### 3. TR Module - Benefits with Hybrid Eligibility

```sql
-- TR Module: Benefit Plan
CREATE TABLE benefits.benefit_plan (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code              varchar(50) UNIQUE NOT NULL,
  name              varchar(255) NOT NULL,
  plan_type         varchar(50) NOT NULL,  -- HEALTH | DENTAL | LIFE | RETIREMENT
  
  -- ✅ NEW: Default eligibility for this plan
  default_eligibility_profile_id uuid REFERENCES core.eligibility_profile(id),
  
  is_active         boolean DEFAULT true,
  effective_start_date date NOT NULL,
  effective_end_date   date,
  is_current_flag      boolean DEFAULT true,
  
  created_at        timestamp DEFAULT now(),
  updated_at        timestamp
);

-- TR Module: Benefit Option (variants within a plan)
CREATE TABLE benefits.benefit_option (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  benefit_plan_id   uuid NOT NULL REFERENCES benefits.benefit_plan(id),
  code              varchar(50) NOT NULL,
  name              varchar(255) NOT NULL,
  
  -- ✅ NEW: Override eligibility (e.g., Premium tier only for senior staff)
  eligibility_profile_id uuid REFERENCES core.eligibility_profile(id),
  -- If NULL: use default from benefit_plan
  
  coverage_amount   decimal(15,2),
  employee_cost     decimal(10,2),
  employer_cost     decimal(10,2),
  
  is_active         boolean DEFAULT true,
  effective_start_date date NOT NULL,
  effective_end_date   date,
  is_current_flag      boolean DEFAULT true,
  
  created_at        timestamp DEFAULT now(),
  updated_at        timestamp,
  
  CONSTRAINT uq_benefit_option UNIQUE (benefit_plan_id, code)
);

-- TR Module: Compensation Plan
CREATE TABLE compensation.variable_pay_plan (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code              varchar(50) UNIQUE NOT NULL,
  name              varchar(255) NOT NULL,
  plan_type         varchar(50) NOT NULL,  -- BONUS | COMMISSION | STI | LTI
  
  -- ✅ NEW: Default eligibility
  default_eligibility_profile_id uuid REFERENCES core.eligibility_profile(id),
  
  is_active         boolean DEFAULT true,
  effective_start_date date NOT NULL,
  effective_end_date   date,
  is_current_flag      boolean DEFAULT true,
  
  created_at        timestamp DEFAULT now(),
  updated_at        timestamp
);

-- TR Module: Commission Tier
CREATE TABLE compensation.commission_tier (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  variable_pay_plan_id uuid NOT NULL REFERENCES compensation.variable_pay_plan(id),
  tier_name         varchar(100) NOT NULL,
  
  -- ✅ NEW: Override eligibility (e.g., different tiers for different levels)
  eligibility_profile_id uuid REFERENCES core.eligibility_profile(id),
  
  threshold_from    decimal(15,2),
  threshold_to      decimal(15,2),
  commission_rate   decimal(5,2),
  
  is_active         boolean DEFAULT true,
  
  created_at        timestamp DEFAULT now(),
  updated_at        timestamp
);
```

---

## 🔄 Eligibility Resolution Logic

### Algorithm: Find Effective Eligibility Profile

```javascript
/**
 * Resolve eligibility profile for a rule
 * Priority: Rule Override > LeaveType Default > LeaveClass Default
 */
function resolveEligibilityProfile(rule) {
  // 1. Check if rule has override
  if (rule.eligibility_profile_id) {
    return getEligibilityProfile(rule.eligibility_profile_id);
  }
  
  // 2. Check if LeaveType has default
  if (rule.leave_type_id) {
    const leaveType = getLeaveType(rule.leave_type_id);
    if (leaveType.default_eligibility_profile_id) {
      return getEligibilityProfile(leaveType.default_eligibility_profile_id);
    }
    
    // 3. Fall back to LeaveClass default
    const leaveClass = getLeaveClass(leaveType.leave_class_id);
    if (leaveClass.default_eligibility_profile_id) {
      return getEligibilityProfile(leaveClass.default_eligibility_profile_id);
    }
  }
  
  // 4. Check if rule is class-level
  if (rule.leave_class_id) {
    const leaveClass = getLeaveClass(rule.leave_class_id);
    if (leaveClass.default_eligibility_profile_id) {
      return getEligibilityProfile(leaveClass.default_eligibility_profile_id);
    }
  }
  
  // 5. No eligibility defined (apply to all)
  return null;
}

/**
 * Check if employee is eligible for a rule
 */
async function isEmployeeEligible(employeeId, rule) {
  const profile = resolveEligibilityProfile(rule);
  
  if (!profile) {
    return true; // No eligibility restriction
  }
  
  // Fast lookup in cached membership
  const member = await db.query(`
    SELECT 1 FROM core.eligibility_member
    WHERE profile_id = $1 
      AND employee_id = $2
      AND start_date <= CURRENT_DATE
      AND (end_date IS NULL OR end_date >= CURRENT_DATE)
  `, [profile.id, employeeId]);
  
  return member.rowCount > 0;
}
```

### SQL View: Effective Eligibility

```sql
-- Helper view to resolve effective eligibility for accrual rules
CREATE VIEW absence.accrual_rule_effective_eligibility AS
SELECT 
  ar.id AS accrual_rule_id,
  ar.code AS accrual_rule_code,
  COALESCE(
    ar.eligibility_profile_id,           -- 1. Rule override
    lt.default_eligibility_profile_id,   -- 2. LeaveType default
    lc.default_eligibility_profile_id    -- 3. LeaveClass default
  ) AS effective_eligibility_profile_id,
  CASE
    WHEN ar.eligibility_profile_id IS NOT NULL THEN 'RULE_OVERRIDE'
    WHEN lt.default_eligibility_profile_id IS NOT NULL THEN 'LEAVE_TYPE_DEFAULT'
    WHEN lc.default_eligibility_profile_id IS NOT NULL THEN 'LEAVE_CLASS_DEFAULT'
    ELSE 'NO_RESTRICTION'
  END AS eligibility_source
FROM absence.accrual_rule ar
LEFT JOIN absence.leave_type lt ON ar.leave_type_id = lt.id
LEFT JOIN absence.leave_class lc ON COALESCE(ar.leave_class_id, lt.leave_class_id) = lc.id
WHERE ar.is_current_flag = true;
```

---

## 📊 Examples

### Example 1: TA - Annual Leave with Different Accrual Rates

```yaml
# Setup
LeaveClass: PTO
  default_eligibility_profile_id: ELIG_ALL_FULLTIME
  # All full-time employees eligible by default

LeaveType: ANNUAL_LEAVE
  leave_class_id: PTO
  default_eligibility_profile_id: null  # Inherit from class

# Rules with different eligibility
AccrualRule: JUNIOR_ACCRUAL
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: ELIG_JUNIOR_STAFF  # Override
  accrual_amount: 1.0  # 12 days/year

AccrualRule: SENIOR_ACCRUAL
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: ELIG_SENIOR_STAFF  # Override
  accrual_amount: 1.25  # 15 days/year

CarryoverRule: STANDARD_CARRYOVER
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: null  # Use default (all full-time)
  max_carryover_amount: 5

# Eligibility Profiles
ELIG_ALL_FULLTIME:
  rule_json:
    employment_types: ["FULL_TIME"]

ELIG_JUNIOR_STAFF:
  rule_json:
    employment_types: ["FULL_TIME"]
    grades: ["G1", "G2", "G3"]

ELIG_SENIOR_STAFF:
  rule_json:
    employment_types: ["FULL_TIME"]
    grades: ["G4", "G5", "M3", "M4", "M5"]
```

**Result**:
- Junior staff (G1-G3): 12 days/year, can carry over 5 days
- Senior staff (G4+): 15 days/year, can carry over 5 days
- Part-time: Not eligible (no accrual)

### Example 2: TR - Health Insurance with Tiers

```yaml
# Setup
BenefitPlan: HEALTH_INSURANCE
  default_eligibility_profile_id: ELIG_ALL_EMPLOYEES

# Options with different eligibility
BenefitOption: BASIC_HEALTH
  benefit_plan_id: HEALTH_INSURANCE
  eligibility_profile_id: null  # Use default (all employees)
  coverage_amount: 50000

BenefitOption: PREMIUM_HEALTH
  benefit_plan_id: HEALTH_INSURANCE
  eligibility_profile_id: ELIG_SENIOR_STAFF  # Override
  coverage_amount: 100000

BenefitOption: EXECUTIVE_HEALTH
  benefit_plan_id: HEALTH_INSURANCE
  eligibility_profile_id: ELIG_EXECUTIVES  # Override
  coverage_amount: 200000

# Eligibility Profiles
ELIG_ALL_EMPLOYEES:
  rule_json:
    employment_types: ["FULL_TIME", "PART_TIME"]

ELIG_SENIOR_STAFF:
  rule_json:
    employment_types: ["FULL_TIME"]
    grades: ["G4", "G5", "M3", "M4"]

ELIG_EXECUTIVES:
  rule_json:
    employment_types: ["FULL_TIME"]
    grades: ["M5", "E1", "E2"]
```

**Result**:
- All employees: Can enroll in Basic Health
- Senior staff (G4+): Can choose Basic or Premium
- Executives (M5+): Can choose Basic, Premium, or Executive

### Example 3: Cross-Module - Same Eligibility Profile

```yaml
# One eligibility profile used across modules
ELIG_VIETNAM_SENIOR:
  domain: CORE  # Shared across modules
  rule_json:
    countries: ["VN"]
    grades: ["G4", "G5", "M3", "M4", "M5"]
    employment_types: ["FULL_TIME"]
    min_tenure_months: 12

# Used in TA
AccrualRule: VN_SENIOR_ACCRUAL
  eligibility_profile_id: ELIG_VIETNAM_SENIOR
  accrual_amount: 1.67

# Used in TR Benefits
BenefitOption: VN_PREMIUM_HEALTH
  eligibility_profile_id: ELIG_VIETNAM_SENIOR
  coverage_amount: 100000

# Used in TR Compensation
VariablePayPlan: VN_SENIOR_BONUS
  default_eligibility_profile_id: ELIG_VIETNAM_SENIOR
```

---

## 🎯 Benefits of Hybrid Approach

### 1. Flexibility

✅ **Simple cases**: Set default at LeaveClass/LeaveType, all rules inherit
✅ **Complex cases**: Override at rule level for specific scenarios

### 2. Maintainability

✅ **Bulk changes**: Update default eligibility, affects all rules
✅ **Specific changes**: Update rule override, doesn't affect others

### 3. Performance

✅ **Cached lookup**: O(1) performance via `eligibility_member` table
✅ **Minimal joins**: Resolution logic uses simple COALESCE

### 4. Consistency

✅ **Clear hierarchy**: Rule > LeaveType > LeaveClass
✅ **Explicit source**: Track where eligibility comes from

### 5. Reusability

✅ **Cross-module**: Same eligibility profile for TA, TR, etc.
✅ **DRY principle**: Define organizational scope once

---

## 🚀 Next Steps

1. **Update TA Ontology**: Reflect hybrid eligibility model
2. **Update TR Ontology**: Align with same pattern
3. **Create Core Eligibility Ontology**: Define shared entities
4. **Update DBML**: Implement schema changes
5. **Migration Plan**: Strategy to migrate existing data
6. **API Design**: Endpoints for eligibility management
7. **Documentation**: Update concept guides

---

## ✅ Summary

**Confirmed Architecture**:
- ✅ Hybrid eligibility (default + override)
- ✅ Organizational scope in `EligibilityProfile` (Core module)
- ✅ Object scope in rules (`leaveTypeId`, `leaveClassId`)
- ✅ Cross-module reusability
- ✅ Performance-optimized with cached membership
