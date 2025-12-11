# Eligibility Sub-Module - Glossary

**Version**: 1.0  
**Last Updated**: 2025-12-11  
**Sub-Module**: Eligibility Engine (Cross-Module)

---

## 📋 Overview

The Eligibility sub-module provides a centralized engine for managing eligibility criteria across all HR modules. It uses a **Hybrid Model** combining default eligibility at Class/Type level with rule-level overrides, and implements **Dynamic Group** evaluation with cached membership for performance.

**Key Innovation**: Separates **Organizational Scope** (WHO is eligible) from **Object Scope** (WHAT they're eligible for).

### Entities (3)
1. **EligibilityProfile** - Dynamic eligibility rules
2. **EligibilityMember** - Cached membership (performance)
3. **EligibilityEvaluation** - Audit trail

---

## 🔑 Key Entities

### EligibilityProfile

**Definition**: Defines eligibility criteria for HR programs using dynamic rules based on organizational attributes.

**Purpose**:
- Centralize eligibility management across modules
- Define WHO is eligible (organizational scope)
- Support reusability across TA, TR, and other modules
- Enable Hybrid Model (default + override)

**Key Attributes**:
- `code` - Unique identifier (e.g., `ELIG_SENIOR_STAFF`)
- `name` - Display name
- `domain` - Which module uses this (`ABSENCE`, `BENEFITS`, `COMPENSATION`, `CORE`)
- `rule_json` - Dynamic criteria (JSONB)
- `priority` - Evaluation order
- `is_active` - Active status
- SCD Type 2 fields

**Rule JSON Structure**:
```json
{
  "business_units": ["BU_SALES", "BU_TECH"],
  "legal_entities": ["LE_VN", "LE_SG"],
  "countries": ["VN", "SG"],
  "grades": ["G4", "G5", "M3", "M4", "M5"],
  "employment_types": ["FULL_TIME"],
  "min_tenure_months": 6,
  "departments": ["SALES", "MARKETING"],
  "custom_rules": {
    "performance_rating_min": 3.5
  }
}
```

**Domain Types**:
- `ABSENCE` - Used by TA module (leave policies)
- `BENEFITS` - Used by TR module (benefit plans)
- `COMPENSATION` - Used by TR module (variable pay)
- `CORE` - Shared across all modules

**Business Rules**:
- ✅ `rule_json` contains organizational scope only
- ✅ Object scope (e.g., `leaveTypeId`) stored in consuming entity
- ✅ CORE domain profiles can be used by any module
- ✅ Code must be unique across all domains
- ✅ Evaluation uses cached membership for O(1) performance

**Example**:
```yaml
EligibilityProfile:
  code: "ELIG_SENIOR_STAFF"
  name: "Senior Staff (Grade 4+)"
  domain: "CORE"
  rule_json:
    grades: ["G4", "G5", "M3", "M4", "M5"]
    employment_types: ["FULL_TIME"]
    min_tenure_months: 12
```

---

### EligibilityMember

**Definition**: Cached membership list storing which employees currently match an eligibility profile.

**Purpose**:
- Fast O(1) eligibility lookups
- Avoid re-evaluating rules on every check
- Track eligibility history
- Support audit and reporting

**Key Attributes**:
- `profile_id` - Which eligibility profile
- `employee_id` - Which employee
- `start_date` - When eligibility began
- `end_date` - When ended (NULL if active)
- `last_evaluated_at` - Last evaluation timestamp
- `evaluation_source` - How determined (`AUTO`, `MANUAL`, `OVERRIDE`)
- `evaluation_reason` - Why added/removed

**Evaluation Sources**:
- `AUTO` - System-evaluated based on rule_json
- `MANUAL` - HR manually added employee
- `OVERRIDE` - Exception/special case

**Business Rules**:
- ✅ `end_date` NULL means currently eligible
- ✅ No overlapping active memberships for same profile + employee
- ✅ Updated automatically when employee data changes
- ✅ Updated when profile rules change
- ✅ Immutable history (use SCD Type 2 pattern)

**Example**:
```yaml
EligibilityMember:
  profile_id: "ELIG_SENIOR_STAFF"
  employee_id: "EMP_001"
  start_date: 2025-01-01
  end_date: null  # Currently eligible
  evaluation_source: AUTO
  evaluation_reason: "Promoted to G4"
```

---

### EligibilityEvaluation

**Definition**: Audit log of all eligibility evaluations.

**Purpose**:
- Complete audit trail for compliance
- Troubleshooting eligibility issues
- Understanding why employee was/wasn't eligible
- Tracking evaluation triggers

**Key Attributes**:
- `profile_id` - Which profile evaluated
- `employee_id` - Which employee evaluated
- `evaluated_at` - When evaluated
- `evaluation_result` - `ELIGIBLE` or `NOT_ELIGIBLE`
- `evaluation_reason` - Why (which criteria matched/failed)
- `triggered_by` - What caused evaluation
- `metadata` - Detailed evaluation context

**Trigger Types**:
- `EMPLOYEE_CHANGE` - Employee data changed (grade, location, etc.)
- `RULE_CHANGE` - Eligibility profile rules updated
- `MANUAL` - HR manually triggered
- `SCHEDULED` - Batch re-evaluation job

**Business Rules**:
- ✅ Immutable audit log (no updates/deletes)
- ✅ Created every time eligibility evaluated
- ✅ Stores evaluation details in metadata
- ✅ Used for compliance reporting

**Example**:
```yaml
EligibilityEvaluation:
  profile_id: "ELIG_SENIOR_STAFF"
  employee_id: "EMP_001"
  evaluated_at: 2025-01-01T10:00:00Z
  evaluation_result: ELIGIBLE
  evaluation_reason: "Grade=G4, EmploymentType=FULL_TIME, Tenure=15 months"
  triggered_by: EMPLOYEE_CHANGE
  metadata:
    criteria_checked:
      grades: PASS
      employment_types: PASS
      min_tenure_months: PASS
```

---

## 🎯 Core Concepts

### Organizational Scope vs Object Scope

**Organizational Scope** (in `EligibilityProfile`):
- **WHO** is eligible
- Business Unit, Legal Entity, Country
- Grade, Department, Employment Type
- Tenure, Performance Rating
- Stored in `rule_json`

**Object Scope** (in consuming entity):
- **WHAT** they're eligible for
- `leaveTypeId`, `leaveClassId` (TA module)
- `benefitPlanId`, `benefitOptionId` (TR module)
- Stored in the rule/policy entity itself

**Example**:
```yaml
# Organizational Scope (EligibilityProfile)
ELIG_VN_SENIOR:
  rule_json:
    countries: ["VN"]
    grades: ["G4", "G5"]

# Object Scope (AccrualRule)
AccrualRule:
  leaveTypeId: "ANNUAL_LEAVE"  # WHAT
  eligibilityProfileId: "ELIG_VN_SENIOR"  # WHO
  accrualAmount: 1.67
```

---

### Hybrid Model: Default + Override

**Pattern**: Eligibility can be set at multiple levels with override capability.

**Hierarchy** (TA module example):
```
LeaveClass (default_eligibility_profile_id)
  ↓
LeaveType (default_eligibility_profile_id) - can override class
  ↓
AccrualRule (eligibility_profile_id) - can override type
```

**Resolution Logic**:
1. Check if rule has `eligibility_profile_id` → Use this (OVERRIDE)
2. Else check if LeaveType has `default_eligibility_profile_id` → Use this
3. Else check if LeaveClass has `default_eligibility_profile_id` → Use this
4. Else no restriction (all eligible)

**Example**:
```yaml
LeaveClass: PTO
  default_eligibility: ELIG_ALL_FULLTIME

LeaveType: ANNUAL_LEAVE
  leaveClassId: PTO
  default_eligibility: null  # Inherit from class

AccrualRule: JUNIOR_ACCRUAL
  leaveTypeId: ANNUAL_LEAVE
  eligibility: ELIG_JUNIOR  # Override
  accrualAmount: 1.0

AccrualRule: SENIOR_ACCRUAL
  leaveTypeId: ANNUAL_LEAVE
  eligibility: ELIG_SENIOR  # Override
  accrualAmount: 1.25

CarryoverRule: STANDARD
  leaveTypeId: ANNUAL_LEAVE
  eligibility: null  # Use default (ELIG_ALL_FULLTIME)
  maxCarryover: 5
```

**Result**:
- Junior staff: 12 days/year (ELIG_JUNIOR)
- Senior staff: 15 days/year (ELIG_SENIOR)
- All full-time: Can carry over 5 days (ELIG_ALL_FULLTIME)

---

### Dynamic Group Evaluation

**Concept**: Eligibility determined by evaluating employee attributes against profile rules.

**Evaluation Process**:
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

**Performance Optimization**:
- ✅ Evaluation happens asynchronously
- ✅ Results cached in `EligibilityMember`
- ✅ Eligibility checks use cached data (O(1))
- ✅ Batch re-evaluation for rule changes

---

## 🔄 Cross-Module Usage

### TA Module (Time & Absence)

**Entities Using Eligibility**:
- `LeaveClass` - Default eligibility for all leave types in class
- `LeaveType` - Default eligibility for all rules under type
- `AccrualRule` - Override eligibility for accrual
- `CarryoverRule` - Override eligibility for carryover
- `LimitRule`, `OverdraftRule`, etc.

**Example**:
```yaml
LeaveClass: PTO
  default_eligibility_profile_id: "ELIG_ALL_FULLTIME"

AccrualRule: SENIOR_ACCRUAL
  leaveTypeId: "ANNUAL_LEAVE"
  eligibility_profile_id: "ELIG_SENIOR_STAFF"
  accrualAmount: 1.67
```

---

### TR Module (Total Rewards)

**Entities Using Eligibility**:
- `BenefitPlan` - Default eligibility for all options
- `BenefitOption` - Override eligibility for specific tier
- `VariablePayPlan` - Default eligibility for compensation
- `CommissionTier` - Override eligibility for tier

**Example**:
```yaml
BenefitPlan: HEALTH_INSURANCE
  default_eligibility_profile_id: "ELIG_ALL_EMPLOYEES"

BenefitOption: PREMIUM_HEALTH
  benefitPlanId: "HEALTH_INSURANCE"
  eligibility_profile_id: "ELIG_SENIOR_STAFF"
  coverage: 100000
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

- Use `CORE` domain for profiles shared across modules
- Use specific domain (`ABSENCE`, `BENEFITS`) for module-specific profiles
- CORE profiles can be used by any module

### Performance Optimization

- ✅ Always use cached membership (`EligibilityMember`)
- ✅ Never evaluate rules in real-time for eligibility checks
- ✅ Schedule batch re-evaluations during off-hours
- ✅ Index `profile_id` and `employee_id` for fast lookups

---

## ⚠️ Important Notes

### Migration from Module-Specific Eligibility

**Before** (TA module):
```yaml
AccrualRule:
  leaveTypeId: "ANNUAL_LEAVE"
  minTenureMonths: 6
  employmentTypes: ["FULL_TIME"]
  applicableCountries: ["VN"]
```

**After** (Centralized):
```yaml
EligibilityProfile:
  code: "ELIG_VN_FULLTIME"
  rule_json:
    countries: ["VN"]
    employment_types: ["FULL_TIME"]
    min_tenure_months: 6

AccrualRule:
  leaveTypeId: "ANNUAL_LEAVE"
  eligibility_profile_id: "ELIG_VN_FULLTIME"
```

### Evaluation Triggers

System automatically re-evaluates when:
- Employee grade changes
- Employee location/BU changes
- Employment type changes
- Tenure milestone reached
- Eligibility profile rules updated

---

## 🔗 Related Glossaries

- **Employment** - Employee entity used in eligibility checks
- **JobPosition** - Grade, JobLevel used in criteria
- **BusinessUnit** - BU used in organizational scope
- **LegalEntity** - LE used in organizational scope

---

**Document Version**: 1.0  
**Last Review**: 2025-12-11
