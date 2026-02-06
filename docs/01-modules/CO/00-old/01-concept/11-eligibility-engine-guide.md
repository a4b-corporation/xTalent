# Eligibility Engine Guide

**Version**: 1.0  
**Last Updated**: 2025-12-11  
**Audience**: Business Users, HR Administrators, Technical Users  
**Reading Time**: 20-30 minutes

---

## 📋 Overview

This guide explains the **Eligibility Engine** - a centralized system for managing eligibility criteria across all HR modules (Time & Absence, Total Rewards, etc.). The engine uses a **Hybrid Model** combining default eligibility with rule-level overrides and **Dynamic Group** evaluation with cached membership.

### What You'll Learn
- How eligibility works across modules
- Hybrid Model: Default + Override pattern
- Organizational Scope vs Object Scope
- Dynamic Group evaluation and caching
- Best practices for eligibility management

### Prerequisites
- Basic understanding of HR concepts
- Familiarity with organizational structures (BU, LE, grades)

---

## 🎯 The Problem with Module-Specific Eligibility

### Traditional Approach (Embedded Eligibility)

Most HR systems embed eligibility criteria directly in each rule:

```yaml
# TA Module - Accrual Rule (Traditional)
AccrualRule:
  leaveTypeId: "ANNUAL_LEAVE"
  accrualAmount: 1.67
  # Eligibility embedded in rule
  applicableCountries: ["VN", "SG"]
  applicableGrades: ["G4", "G5"]
  minTenureMonths: 6
  employmentTypes: ["FULL_TIME"]
```

**Problems with this approach**:

❌ **Duplication** - Same eligibility criteria repeated across multiple rules  
❌ **Inconsistency** - Different rules may have slightly different criteria  
❌ **Hard to maintain** - Changing eligibility requires updating many rules  
❌ **No reusability** - Cannot share eligibility across modules  
❌ **Poor performance** - Must evaluate criteria every time

**Example Problem**:
```
Senior Staff eligibility:
- TA Module: grades G4+ for annual leave
- TR Module: grades G4+ for premium health insurance  
- TR Module: grades G4+ for senior bonus plan

→ Same criteria defined 3 times!
→ If grade structure changes, update 3+ places
```

---

## ✨ The xTalent Solution: Centralized Eligibility Engine

### Core Concept: Separation of Concerns

**Organizational Scope** (WHO is eligible):
- Managed by `EligibilityProfile` in Core module
- Business Unit, Legal Entity, Country
- Grade, Department, Employment Type
- Tenure, Performance Rating

**Object Scope** (WHAT they're eligible for):
- Managed by consuming entity
- `leaveTypeId`, `benefitPlanId`, `compensationPlanId`
- Stays in the rule/policy itself

```yaml
# NEW Approach: Separated Concerns

# WHO is eligible (Core Module)
EligibilityProfile: ELIG_SENIOR_STAFF
  domain: CORE  # Shared across modules
  rule_json:
    grades: ["G4", "G5", "M3", "M4", "M5"]
    employment_types: ["FULL_TIME"]
    min_tenure_months: 12

# WHAT they're eligible for (TA Module)
AccrualRule:
  leaveTypeId: "ANNUAL_LEAVE"  # Object scope
  eligibility_profile_id: "ELIG_SENIOR_STAFF"  # WHO
  accrualAmount: 1.67

# Same eligibility used in TR Module
BenefitOption:
  benefitPlanId: "HEALTH_INSURANCE"  # Object scope
  eligibility_profile_id: "ELIG_SENIOR_STAFF"  # WHO
  coverage: 100000
```

---

## 📊 The 3 Core Entities

### 1. EligibilityProfile (Dynamic Rules)

**Purpose**: Defines WHO is eligible using dynamic criteria.

```yaml
EligibilityProfile:
  code: "ELIG_VN_SENIOR"
  name: "Vietnam Senior Staff"
  domain: "CORE"  # or ABSENCE, BENEFITS, COMPENSATION
  
  rule_json:
    countries: ["VN"]
    grades: ["G4", "G5", "M3", "M4", "M5"]
    employment_types: ["FULL_TIME"]
    min_tenure_months: 12
    business_units: ["BU_TECH", "BU_SALES"]
  
  is_active: true
```

**Key Features**:
- ✅ Dynamic criteria in JSON
- ✅ Domain-specific or shared (CORE)
- ✅ Versioned with SCD Type 2
- ✅ Reusable across modules

---

### 2. EligibilityMember (Cached Membership)

**Purpose**: Fast O(1) eligibility lookups via cached results.

```yaml
EligibilityMember:
  profile_id: "ELIG_VN_SENIOR"
  employee_id: "EMP_001"
  start_date: 2025-01-01
  end_date: null  # Currently eligible
  last_evaluated_at: 2025-01-01T10:00:00Z
  evaluation_source: AUTO  # or MANUAL, OVERRIDE
```

**Why Caching?**
- ❌ **Without cache**: Evaluate rules every time → Slow
- ✅ **With cache**: Lookup in table → Fast O(1)

**Update Triggers**:
- Employee data changes (grade, location, tenure)
- Eligibility profile rules updated
- Manual HR override

---

### 3. EligibilityEvaluation (Audit Trail)

**Purpose**: Complete audit log of all evaluations.

```yaml
EligibilityEvaluation:
  profile_id: "ELIG_VN_SENIOR"
  employee_id: "EMP_001"
  evaluated_at: 2025-01-01T10:00:00Z
  evaluation_result: ELIGIBLE
  evaluation_reason: "Grade=G4, Country=VN, Tenure=15 months"
  triggered_by: EMPLOYEE_CHANGE  # or RULE_CHANGE, MANUAL
```

**Use Cases**:
- Compliance reporting
- Troubleshooting eligibility issues
- Understanding historical changes

---

## 🔄 Hybrid Model: Default + Override

### The Pattern

Eligibility can be set at multiple levels with override capability:

```
LeaveClass (default_eligibility_profile_id)
  ↓
LeaveType (default_eligibility_profile_id) - can override class
  ↓
AccrualRule (eligibility_profile_id) - can override type
```

### Resolution Logic

```
1. Check if rule has eligibility_profile_id
   → YES: Use this (OVERRIDE) ✅
   → NO: Continue to step 2

2. Check if LeaveType has default_eligibility_profile_id
   → YES: Use this (TYPE DEFAULT) ✅
   → NO: Continue to step 3

3. Check if LeaveClass has default_eligibility_profile_id
   → YES: Use this (CLASS DEFAULT) ✅
   → NO: No restriction (ALL ELIGIBLE) ✅
```

### Example: Simple Case (All Rules Use Default)

```yaml
LeaveClass: PTO
  default_eligibility_profile_id: "ELIG_ALL_FULLTIME"

LeaveType: ANNUAL_LEAVE
  leave_class_id: PTO
  default_eligibility_profile_id: null  # Inherit from class

AccrualRule: STANDARD
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: null  # Inherit from type → class
  accrual_amount: 1.67

CarryoverRule: STANDARD
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: null  # Inherit from type → class
  max_carryover: 5
```

**Result**: All rules use `ELIG_ALL_FULLTIME` (full-time employees only)

---

### Example: Complex Case (Different Rules, Different Eligibility)

```yaml
LeaveClass: PTO
  default_eligibility_profile_id: "ELIG_ALL_FULLTIME"

LeaveType: ANNUAL_LEAVE
  leave_class_id: PTO
  default_eligibility_profile_id: null

# Junior staff: 12 days/year
AccrualRule: JUNIOR_ACCRUAL
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: "ELIG_JUNIOR"  # OVERRIDE
  accrual_amount: 1.0

# Senior staff: 15 days/year
AccrualRule: SENIOR_ACCRUAL
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: "ELIG_SENIOR"  # OVERRIDE
  accrual_amount: 1.25

# Everyone can carry over
CarryoverRule: STANDARD
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: null  # Use default (all full-time)
  max_carryover: 5

# Eligibility Profiles
ELIG_JUNIOR:
  rule_json: {grades: ["G1", "G2", "G3"]}

ELIG_SENIOR:
  rule_json: {grades: ["G4", "G5", "M3", "M4", "M5"]}

ELIG_ALL_FULLTIME:
  rule_json: {employment_types: ["FULL_TIME"]}
```

**Result**:
- Employee G2: Gets JUNIOR_ACCRUAL (12 days), can carry over 5
- Employee G5: Gets SENIOR_ACCRUAL (15 days), can carry over 5
- Part-time: No accrual (not in ELIG_ALL_FULLTIME)

---

## 🌐 Cross-Module Usage

### TA Module (Time & Absence)

```yaml
# Leave Class with default eligibility
LeaveClass: SICK_LEAVE
  default_eligibility_profile_id: "ELIG_ALL_EMPLOYEES"

# Accrual rule with override
AccrualRule: SICK_ACCRUAL_SENIOR
  leave_type_id: "SICK_LEAVE"
  eligibility_profile_id: "ELIG_SENIOR_STAFF"  # Override
  accrual_amount: 1.0
```

### TR Module (Benefits)

```yaml
# Benefit plan with default eligibility
BenefitPlan: HEALTH_INSURANCE
  default_eligibility_profile_id: "ELIG_ALL_EMPLOYEES"

# Premium tier with override
BenefitOption: PREMIUM_HEALTH
  benefit_plan_id: "HEALTH_INSURANCE"
  eligibility_profile_id: "ELIG_SENIOR_STAFF"  # Override
  coverage: 100000
```

### TR Module (Compensation)

```yaml
# Variable pay plan with default eligibility
VariablePayPlan: ANNUAL_BONUS
  default_eligibility_profile_id: "ELIG_ALL_FULLTIME"

# Senior bonus tier with override
CommissionTier: SENIOR_TIER
  variable_pay_plan_id: "ANNUAL_BONUS"
  eligibility_profile_id: "ELIG_SENIOR_STAFF"  # Override
  bonus_percentage: 20
```

---

## ⚡ Dynamic Group Evaluation

### How It Works

```
1. Employee data changes (e.g., promoted to G4)
   ↓
2. System identifies affected eligibility profiles
   ↓
3. Evaluate employee against each profile's rule_json
   ↓
4. Update EligibilityMember (add/remove membership)
   ↓
5. Log evaluation in EligibilityEvaluation
```

### Evaluation Triggers

| Trigger | Example | Action |
|---------|---------|--------|
| **Employee Change** | Promoted to G4 | Re-evaluate all profiles |
| **Rule Change** | Profile criteria updated | Re-evaluate all members |
| **Manual** | HR adds exception | Create manual membership |
| **Scheduled** | Nightly batch job | Re-evaluate all |

### Performance Optimization

```yaml
# Checking eligibility (Fast O(1))
SELECT 1 FROM core.eligibility_member
WHERE profile_id = 'ELIG_SENIOR_STAFF'
  AND employee_id = 'EMP_001'
  AND start_date <= CURRENT_DATE
  AND (end_date IS NULL OR end_date >= CURRENT_DATE)

# Result: Instant lookup, no rule evaluation needed!
```

---

## 💡 Best Practices

### When to Use Default vs Override

**Use Default** (at Class/Type level):
- ✅ Most rules share same eligibility
- ✅ Simple, consistent eligibility
- ✅ Easier maintenance

**Use Override** (at Rule level):
- ✅ Different rules need different eligibility
- ✅ Tiered benefits/policies
- ✅ Special cases or exceptions

### Domain Selection

- **CORE domain**: For profiles shared across modules
  - Example: `ELIG_SENIOR_STAFF` used by TA, TR, etc.
- **Module-specific domain**: For module-only profiles
  - Example: `ELIG_MATERNITY_LEAVE` (ABSENCE domain)

### Naming Conventions

```yaml
# Good naming
ELIG_SENIOR_STAFF          # Clear, descriptive
ELIG_VN_FULLTIME           # Country + employment type
ELIG_TECH_MANAGER          # Department + level

# Bad naming
ELIG_001                   # Not descriptive
SENIOR                     # Missing prefix
VN_EMP                     # Unclear
```

---

## 🔄 Complete Workflow Examples

### Example 1: New Employee Becomes Eligible

```yaml
# Day 1: New hire (G3, Vietnam, Full-time)
Employee: EMP_001
  grade: G3
  country: VN
  employment_type: FULL_TIME
  hire_date: 2025-01-01
  tenure_months: 0

# Evaluation
EligibilityProfile: ELIG_VN_FULLTIME
  rule_json:
    countries: ["VN"]
    employment_types: ["FULL_TIME"]
  
  → Employee matches! ✅

EligibilityMember:
  profile_id: ELIG_VN_FULLTIME
  employee_id: EMP_001
  start_date: 2025-01-01
  evaluation_source: AUTO

# Day 365: Promoted to G4
Employee: EMP_001
  grade: G4  # Changed!
  tenure_months: 12

# Re-evaluation
EligibilityProfile: ELIG_SENIOR_STAFF
  rule_json:
    grades: ["G4", "G5"]
    min_tenure_months: 12
  
  → Employee now matches! ✅

EligibilityMember:
  profile_id: ELIG_SENIOR_STAFF
  employee_id: EMP_001
  start_date: 2025-01-01  # Backdated to promotion
  evaluation_source: AUTO
```

---

### Example 2: Rule Change Affects Members

```yaml
# Before: Senior staff = G4+
EligibilityProfile: ELIG_SENIOR_STAFF
  rule_json:
    grades: ["G4", "G5", "M3", "M4", "M5"]

# Members: 150 employees

# After: Change to G5+ only
EligibilityProfile: ELIG_SENIOR_STAFF
  rule_json:
    grades: ["G5", "M3", "M4", "M5"]  # G4 removed!

# System re-evaluates all 150 members
# - G4 employees: Membership ended
# - G5+ employees: Membership continues

EligibilityMember: (G4 employee)
  end_date: 2025-01-15  # Membership ended
  
EligibilityEvaluation:
  evaluation_result: NOT_ELIGIBLE
  evaluation_reason: "Grade=G4, no longer matches (requires G5+)"
  triggered_by: RULE_CHANGE
```

---

## 🛠️ Technical Implementation

### SQL Helper View

```sql
-- Resolve effective eligibility for accrual rules
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
    WHEN lt.default_eligibility_profile_id IS NOT NULL THEN 'TYPE_DEFAULT'
    WHEN lc.default_eligibility_profile_id IS NOT NULL THEN 'CLASS_DEFAULT'
    ELSE 'NO_RESTRICTION'
  END AS eligibility_source
FROM absence.accrual_rule ar
LEFT JOIN absence.leave_type lt ON ar.leave_type_id = lt.id
LEFT JOIN absence.leave_class lc ON COALESCE(ar.leave_class_id, lt.leave_class_id) = lc.id
WHERE ar.is_current_flag = true;
```

### Application Logic

```javascript
// Check if employee is eligible for a rule
async function isEmployeeEligible(employeeId, ruleId) {
  // 1. Get effective eligibility profile
  const profile = await resolveEligibilityProfile(ruleId);
  
  if (!profile) {
    return true; // No restriction
  }
  
  // 2. Fast lookup in cached membership
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

---

## ⚠️ Common Pitfalls

### Pitfall 1: Mixing Object and Organizational Scope

❌ **Wrong**:
```yaml
EligibilityProfile:
  rule_json:
    leave_type_id: "ANNUAL_LEAVE"  # NO! This is object scope
    grades: ["G4", "G5"]
```

✅ **Correct**:
```yaml
EligibilityProfile:
  rule_json:
    grades: ["G4", "G5"]  # Only organizational scope

AccrualRule:
  leave_type_id: "ANNUAL_LEAVE"  # Object scope stays here
  eligibility_profile_id: "ELIG_SENIOR"
```

### Pitfall 2: Not Using Cached Membership

❌ **Wrong** (Slow):
```javascript
// Evaluate rules every time
function isEligible(employee, profile) {
  return evaluateRules(employee, profile.rule_json);
}
```

✅ **Correct** (Fast):
```javascript
// Use cached membership
function isEligible(employeeId, profileId) {
  return lookupMembership(employeeId, profileId);
}
```

### Pitfall 3: Forgetting to Re-evaluate

❌ **Wrong**:
```javascript
// Update employee grade but don't trigger re-evaluation
await updateEmployeeGrade(employeeId, newGrade);
// Eligibility now out of sync!
```

✅ **Correct**:
```javascript
// Update and trigger re-evaluation
await updateEmployeeGrade(employeeId, newGrade);
await triggerEligibilityEvaluation(employeeId);
```

---

## 🔗 Related Documentation

### Core Module
- [Core Ontology](../00-ontology/core-ontology.yaml) - EligibilityProfile entity
- [Eligibility Glossary](../00-ontology/glossary-eligibility.md) - Detailed definitions
- [Core Database Design](../03-design/1.Core.V4.dbml) - Schema design

### TA Module
- [TA Ontology](../../TA/00-ontology/time-absence-ontology.yaml) - Absence rules
- [TA Concept Guide](../../TA/01-concept/02-conceptual-guide.md) - Absence concepts

### TR Module
- [TR Eligibility Rules Guide](../../TR/01-concept/09-eligibility-rules-guide.md) - TR-specific usage
- [TR Ontology](../../TR/00-ontology/tr-ontology.yaml) - Benefits/compensation

---

**Document Version**: 1.0  
**Created**: 2025-12-11  
**Maintained By**: Documentation Team  
**Last Review**: 2025-12-11
