# Leave Policy Configuration Guide

**Version**: 1.0  
**Last Updated**: 2025-12-12  
**Audience**: HR Administrators, System Configurators  
**Reading Time**: 30-40 minutes

---

## 📋 Overview

This guide explains how to configure leave policies using the TA module's flexible rule system. You'll learn how to set up leave classes, leave types, and bind rules at different levels to create sophisticated leave policies that meet your organization's needs.

### What You'll Learn

- Understanding the rule architecture and binding hierarchy
- Configuring leave classes and types
- Working with 8 rule types (Eligibility, Validation, Accrual, Carryover, Limit, Overdraft, Proration, Rounding)
- Priority-based rule resolution
- Integration with centralized eligibility architecture
- Common policy scenarios and best practices

### Prerequisites

- Basic understanding of leave management concepts
- Familiarity with the [Concept Overview](./01-concept-overview.md)
- Access to HR Administrator role

---

## 🏗️ Rule Architecture Overview

The TA module uses a **flexible, multi-level rule binding system** that allows you to create reusable rules and apply them at different levels of the leave hierarchy.

### Three-Level Hierarchy

```
LeaveClass (e.g., "Paid Time Off")
    ↓
LeaveType (e.g., "Annual Leave", "Sick Leave")
    ↓
Rules (Eligibility, Validation, Accrual, etc.)
```

### Rule Binding Levels

Rules can be bound at three levels, with **priority-based resolution**:

1. **Class-Level Binding** (Priority 10)
   - Rule applies to ALL leave types in the class
   - Example: "All PTO requires 6 months tenure"

2. **Type-Level Binding** (Priority 20)
   - Rule applies to specific leave type
   - Overrides class-level rules
   - Example: "Sick leave requires 3 months tenure" (overrides class rule)

3. **Rule-Level Override** (Priority 30)
   - Highest priority
   - Used for exceptions
   - Example: "Executives exempt from tenure requirement"

### Priority Resolution

When multiple rules apply, the system uses **priority** to determine which rule wins:

```yaml
Priority 30 (Rule-level override) → Highest priority, always wins
Priority 20 (Type-level binding) → Overrides class-level
Priority 10 (Class-level binding) → Default, lowest priority
```

---

## 📦 Leave Class Configuration

### What is a Leave Class?

A **Leave Class** is a high-level grouping of similar leave types. It allows you to apply common policies across multiple leave types.

### Common Leave Classes

| Class Code | Name | Category | Typical Leave Types |
|------------|------|----------|---------------------|
| `PTO` | Paid Time Off | PAID | Annual, Sick, Personal |
| `UNPAID` | Unpaid Leave | UNPAID | Unpaid Personal, LWOP |
| `STATUTORY` | Statutory Leave | STATUTORY | Maternity, Paternity, Bereavement |
| `SPECIAL` | Special Leave | SPECIAL | Study, Sabbatical, Military |

### Creating a Leave Class

**Step 1: Define Basic Information**

```yaml
LeaveClass:
  code: "PTO"
  name: "Paid Time Off"
  description: "Paid leave for rest, personal matters, and illness"
  category: PAID
  isActive: true
  effectiveDate: 2025-01-01
  displayOrder: 1
```

**Step 2: Bind Class-Level Rules**

Bind rules that apply to ALL leave types in this class:

```yaml
# Eligibility: All PTO requires 6 months tenure
EligibilityRule:
  code: "PTO_TENURE_6M"
  name: "PTO Requires 6 Months Tenure"
  leaveClassId: "PTO_CLASS_ID"  # Binds to class
  ruleType: TENURE
  minTenureMonths: 6
  priority: 10  # Class-level priority

# Validation: All PTO requires 7 days advance notice
ValidationRule:
  code: "PTO_ADVANCE_7D"
  name: "PTO Requires 7 Days Notice"
  leaveClassId: "PTO_CLASS_ID"
  ruleType: ADVANCE_NOTICE
  advanceNoticeDays: 7
  priority: 10
```

---

## 📝 Leave Type Configuration

### What is a Leave Type?

A **Leave Type** is a specific category of leave (Annual, Sick, Maternity, etc.) with its own balance tracking and rules.

### Creating a Leave Type

**Step 1: Define Basic Information**

```yaml
LeaveType:
  code: "ANNUAL"
  name: "Annual Leave"
  leaveClassId: "PTO_CLASS_ID"
  description: "Paid vacation time for rest and recreation"
  isPaid: true
  requiresApproval: true
  requiresDocumentation: false
  allowsHalfDay: true
  allowsHourly: false
  unitOfMeasure: DAYS
  color: "#4CAF50"  # Green
  icon: "beach_access"
  isActive: true
  effectiveDate: 2025-01-01
```

**Step 2: Bind Type-Specific Rules**

Override class rules or add type-specific rules:

```yaml
# Override class eligibility for Annual Leave
EligibilityRule:
  code: "ANNUAL_TENURE_3M"
  name: "Annual Leave Requires 3 Months Tenure"
  leaveTypeId: "ANNUAL_TYPE_ID"  # Binds to type
  ruleType: TENURE
  minTenureMonths: 3
  priority: 20  # Type-level priority (overrides class)

# Type-specific validation
ValidationRule:
  code: "ANNUAL_MAX_CONSECUTIVE"
  name: "Annual Leave Max 15 Consecutive Days"
  leaveTypeId: "ANNUAL_TYPE_ID"
  ruleType: MAX_CONSECUTIVE_DAYS
  maxConsecutiveDays: 15
  priority: 20
```

---

## 🔑 The 8 Rule Types

### 1. Eligibility Rules

**Purpose**: Determine WHO can use a leave type

**Integration**: Uses centralized `EligibilityProfile` from Core module

**Hybrid Model**:
- Can reference `EligibilityProfile` (recommended)
- Can define inline criteria (legacy)

**Example 1: Using EligibilityProfile** (Recommended)

```yaml
EligibilityRule:
  code: "ANNUAL_ELIGIBILITY"
  name: "Annual Leave Eligibility"
  leaveTypeId: "ANNUAL_TYPE_ID"
  ruleType: CUSTOM
  # Reference centralized eligibility profile
  eligibilityProfileId: "PROFILE_FULLTIME_6M"
  priority: 20
```

**Example 2: Inline Criteria** (Legacy)

```yaml
EligibilityRule:
  code: "SICK_ELIGIBILITY"
  name: "Sick Leave Eligibility"
  leaveTypeId: "SICK_TYPE_ID"
  ruleType: TENURE
  minTenureMonths: 3
  priority: 20
```

**Common Eligibility Criteria**:
- Tenure (e.g., 6 months service)
- Employment type (Full-time, Part-time, Contract)
- Location (Country, State, Office)
- Department or Business Unit
- Job Level or Grade

**Best Practice**: Use `EligibilityProfile` for complex, reusable eligibility logic. See [Eligibility Engine Guide](../../CO/01-concept/11-eligibility-engine-guide.md).

---

### 2. Validation Rules

**Purpose**: Validate leave requests before submission

**Rule Types**:

#### Advance Notice

```yaml
ValidationRule:
  code: "ANNUAL_ADVANCE_14D"
  name: "Annual Leave Requires 14 Days Notice"
  leaveTypeId: "ANNUAL_TYPE_ID"
  ruleType: ADVANCE_NOTICE
  advanceNoticeDays: 14
  errorMessage: "Annual leave must be requested at least 14 days in advance"
  priority: 20
```

#### Max Consecutive Days

```yaml
ValidationRule:
  code: "ANNUAL_MAX_15D"
  name: "Annual Leave Max 15 Consecutive Days"
  leaveTypeId: "ANNUAL_TYPE_ID"
  ruleType: MAX_CONSECUTIVE_DAYS
  maxConsecutiveDays: 15
  errorMessage: "Cannot request more than 15 consecutive days of annual leave"
  priority: 20
```

#### Blackout Period

```yaml
ValidationRule:
  code: "ANNUAL_YEAREND_BLACKOUT"
  name: "Annual Leave Blackout - Year End"
  leaveTypeId: "ANNUAL_TYPE_ID"
  ruleType: BLACKOUT_PERIOD
  blackoutStartDate: 2025-12-20
  blackoutEndDate: 2025-12-31
  errorMessage: "Annual leave cannot be taken during year-end close (Dec 20-31)"
  priority: 20
```

#### Documentation Required

```yaml
ValidationRule:
  code: "SICK_DOCUMENTATION_3D"
  name: "Sick Leave Documentation Required > 3 Days"
  leaveTypeId: "SICK_TYPE_ID"
  ruleType: DOCUMENTATION_REQUIRED
  documentationThresholdDays: 3
  errorMessage: "Medical certificate required for sick leave exceeding 3 days"
  priority: 20
```

---

### 3. Accrual Rules

**Purpose**: Define how leave balance is earned over time

**Accrual Methods**:

#### Upfront Allocation

```yaml
AccrualRule:
  code: "ANNUAL_UPFRONT_20D"
  name: "Annual Leave - 20 Days Upfront"
  leaveTypeId: "ANNUAL_TYPE_ID"
  accrualMethod: UPFRONT
  accrualAmount: 20
  accrualPeriod: YEAR
  accrualStartDate: YEAR_START
  isProrated: true
  priority: 20
```

**Behavior**: Employee receives full 20 days on January 1st (or prorated if joining mid-year)

#### Monthly Accrual

```yaml
AccrualRule:
  code: "ANNUAL_MONTHLY_1.67D"
  name: "Annual Leave - 1.67 Days per Month"
  leaveTypeId: "ANNUAL_TYPE_ID"
  accrualMethod: MONTHLY
  accrualAmount: 1.67
  accrualPeriod: MONTH
  maxAccrualBalance: 30  # Cap at 30 days
  accrualStartDate: HIRE_DATE
  waitingPeriodMonths: 3  # Start accruing after 3 months
  priority: 20
```

**Behavior**: Employee accrues 1.67 days on the 1st of each month, starting 3 months after hire date

#### Tenure-Based Accrual

```yaml
# 0-5 years: 15 days
AccrualRule:
  code: "ANNUAL_0_5Y_15D"
  name: "Annual Leave - 15 Days (0-5 years)"
  leaveTypeId: "ANNUAL_TYPE_ID"
  accrualMethod: UPFRONT
  accrualAmount: 15
  accrualPeriod: YEAR
  # Eligibility: Tenure < 5 years
  priority: 20

# 5+ years: 20 days
AccrualRule:
  code: "ANNUAL_5Y_20D"
  name: "Annual Leave - 20 Days (5+ years)"
  leaveTypeId: "ANNUAL_TYPE_ID"
  accrualMethod: UPFRONT
  accrualAmount: 20
  accrualPeriod: YEAR
  # Eligibility: Tenure >= 5 years
  priority: 25  # Higher priority
```

---

### 4. Carryover Rules

**Purpose**: Handle unused leave at period end

**Carryover Types**:

#### Unlimited Carryover

```yaml
CarryoverRule:
  code: "ANNUAL_UNLIMITED_CARRYOVER"
  name: "Annual Leave - Unlimited Carryover"
  leaveTypeId: "ANNUAL_TYPE_ID"
  carryoverType: UNLIMITED
  priority: 20
```

**Behavior**: All unused days carry to next year indefinitely

#### Limited Carryover

```yaml
CarryoverRule:
  code: "ANNUAL_LIMITED_5D"
  name: "Annual Leave - Max 5 Days Carryover"
  leaveTypeId: "ANNUAL_TYPE_ID"
  carryoverType: LIMITED
  maxCarryoverAmount: 5
  carryoverExpiryMonths: 3  # Carried days expire after 3 months
  priority: 20
```

**Behavior**: 
- Max 5 days carry to next year
- Excess days expire on Dec 31
- Carried days must be used within 3 months (by Mar 31)

#### Expire All

```yaml
CarryoverRule:
  code: "SICK_EXPIRE_ALL"
  name: "Sick Leave - Use It or Lose It"
  leaveTypeId: "SICK_TYPE_ID"
  carryoverType: EXPIRE_ALL
  resetPeriod: YEAR
  priority: 20
```

**Behavior**: All unused sick leave expires on Dec 31

#### Payout

```yaml
CarryoverRule:
  code: "ANNUAL_PAYOUT_100PCT"
  name: "Annual Leave - 100% Payout"
  leaveTypeId: "ANNUAL_TYPE_ID"
  carryoverType: PAYOUT
  payoutRate: 1.0  # 100% of daily rate
  priority: 20
```

**Behavior**: Unused days paid out at 100% of daily salary

---

### 5. Limit Rules

**Purpose**: Restrict leave usage

**Limit Types**:

#### Max Per Year

```yaml
LimitRule:
  code: "ANNUAL_MAX_20D_YEAR"
  name: "Annual Leave - Max 20 Days per Year"
  leaveTypeId: "ANNUAL_TYPE_ID"
  limitType: MAX_PER_YEAR
  limitAmount: 20
  limitPeriod: YEAR
  priority: 20
```

#### Max Per Request

```yaml
LimitRule:
  code: "SICK_MAX_5D_REQUEST"
  name: "Sick Leave - Max 5 Days per Request"
  leaveTypeId: "SICK_TYPE_ID"
  limitType: MAX_PER_REQUEST
  limitAmount: 5
  limitPeriod: REQUEST
  priority: 20
```

#### Min Per Request

```yaml
LimitRule:
  code: "ANNUAL_MIN_0.5D"
  name: "Annual Leave - Min 0.5 Days (Half Day)"
  leaveTypeId: "ANNUAL_TYPE_ID"
  limitType: MIN_PER_REQUEST
  limitAmount: 0.5
  limitPeriod: REQUEST
  priority: 20
```

---

### 6. Overdraft Rules

**Purpose**: Allow negative balance (advance leave)

**Example: Allow Overdraft**

```yaml
OverdraftRule:
  code: "ANNUAL_OVERDRAFT_5D"
  name: "Annual Leave - Allow 5 Days Overdraft"
  leaveTypeId: "ANNUAL_TYPE_ID"
  allowOverdraft: true
  maxOverdraftAmount: 5
  overdraftRepaymentRequired: true
  repaymentMethod: AUTO_DEDUCT  # Deduct from future accruals
  requiresApproval: true
  approvalLevel: HR
  priority: 20
```

**Behavior**:
- Employee can go -5 days
- Requires HR approval
- Future accruals automatically repay overdraft

**Example: No Overdraft**

```yaml
OverdraftRule:
  code: "SICK_NO_OVERDRAFT"
  name: "Sick Leave - No Overdraft Allowed"
  leaveTypeId: "SICK_TYPE_ID"
  allowOverdraft: false
  priority: 20
```

---

### 7. Proration Rules

**Purpose**: Adjust allocation for mid-period joiners or part-time employees

**Proration Types**:

#### Start Date Proration

```yaml
ProrationRule:
  code: "ANNUAL_START_DATE_PRORATION"
  name: "Annual Leave - Prorated by Start Date"
  leaveTypeId: "ANNUAL_TYPE_ID"
  prorationType: START_DATE
  prorationMethod: MONTHLY
  roundingRuleId: "ROUND_UP_RULE_ID"
  priority: 20
```

**Example**:
- Annual allocation: 20 days
- Employee starts July 1 (6 months remaining)
- Prorated allocation: 20 × (6/12) = 10 days

#### Schedule Proration (Part-Time)

```yaml
ProrationRule:
  code: "ANNUAL_SCHEDULE_PRORATION"
  name: "Annual Leave - Prorated by Schedule"
  leaveTypeId: "ANNUAL_TYPE_ID"
  prorationType: SCHEDULE
  prorationMethod: DAILY
  roundingRuleId: "ROUND_NEAREST_HALF_ID"
  priority: 20
```

**Example**:
- Annual allocation: 20 days
- Employee works 50% (3 days/week)
- Prorated allocation: 20 × 0.5 = 10 days

---

### 8. Rounding Rules

**Purpose**: Handle fractional leave amounts

**Rounding Methods**:

#### Round Up

```yaml
RoundingRule:
  code: "ANNUAL_ROUND_UP"
  name: "Annual Leave - Round Up"
  leaveTypeId: "ANNUAL_TYPE_ID"
  roundingMethod: UP
  decimalPlaces: 0
  priority: 20
```

**Example**: 1.67 days → 2 days

#### Round to Nearest Half

```yaml
RoundingRule:
  code: "ANNUAL_ROUND_NEAREST_HALF"
  name: "Annual Leave - Round to Nearest 0.5"
  leaveTypeId: "ANNUAL_TYPE_ID"
  roundingMethod: NEAREST_HALF
  decimalPlaces: 1
  priority: 20
```

**Example**: 1.67 days → 1.5 days

#### No Rounding

```yaml
RoundingRule:
  code: "ANNUAL_NO_ROUNDING"
  name: "Annual Leave - No Rounding"
  leaveTypeId: "ANNUAL_TYPE_ID"
  roundingMethod: NO_ROUNDING
  decimalPlaces: 2
  priority: 20
```

**Example**: 1.67 days → 1.67 days

---

## 🎯 Common Policy Scenarios

### Scenario 1: Standard Annual Leave Policy

**Requirements**:
- 20 days per year, allocated upfront
- Requires 6 months tenure
- Max 15 consecutive days
- 14 days advance notice
- Max 5 days carryover (use within 3 months)

**Configuration**:

```yaml
# Leave Type
LeaveType:
  code: "ANNUAL"
  name: "Annual Leave"
  leaveClassId: "PTO_CLASS_ID"
  isPaid: true
  requiresApproval: true
  allowsHalfDay: true
  unitOfMeasure: DAYS

# Eligibility
EligibilityRule:
  code: "ANNUAL_TENURE_6M"
  leaveTypeId: "ANNUAL_TYPE_ID"
  ruleType: TENURE
  minTenureMonths: 6
  priority: 20

# Accrual
AccrualRule:
  code: "ANNUAL_UPFRONT_20D"
  leaveTypeId: "ANNUAL_TYPE_ID"
  accrualMethod: UPFRONT
  accrualAmount: 20
  accrualPeriod: YEAR
  accrualStartDate: YEAR_START
  isProrated: true
  priority: 20

# Validation
ValidationRule:
  code: "ANNUAL_ADVANCE_14D"
  leaveTypeId: "ANNUAL_TYPE_ID"
  ruleType: ADVANCE_NOTICE
  advanceNoticeDays: 14
  priority: 20

ValidationRule:
  code: "ANNUAL_MAX_15D"
  leaveTypeId: "ANNUAL_TYPE_ID"
  ruleType: MAX_CONSECUTIVE_DAYS
  maxConsecutiveDays: 15
  priority: 20

# Carryover
CarryoverRule:
  code: "ANNUAL_LIMITED_5D"
  leaveTypeId: "ANNUAL_TYPE_ID"
  carryoverType: LIMITED
  maxCarryoverAmount: 5
  carryoverExpiryMonths: 3
  priority: 20
```

---

### Scenario 2: Sick Leave with Documentation

**Requirements**:
- 12 days per year, monthly accrual
- No tenure requirement
- Medical certificate required > 3 days
- No carryover (use it or lose it)
- No advance notice required

**Configuration**:

```yaml
# Leave Type
LeaveType:
  code: "SICK"
  name: "Sick Leave"
  leaveClassId: "PTO_CLASS_ID"
  isPaid: true
  requiresApproval: true
  requiresDocumentation: true
  allowsHalfDay: true
  unitOfMeasure: DAYS

# Accrual
AccrualRule:
  code: "SICK_MONTHLY_1D"
  leaveTypeId: "SICK_TYPE_ID"
  accrualMethod: MONTHLY
  accrualAmount: 1
  accrualPeriod: MONTH
  accrualStartDate: HIRE_DATE
  waitingPeriodMonths: 0
  priority: 20

# Validation
ValidationRule:
  code: "SICK_DOCUMENTATION_3D"
  leaveTypeId: "SICK_TYPE_ID"
  ruleType: DOCUMENTATION_REQUIRED
  documentationThresholdDays: 3
  errorMessage: "Medical certificate required for sick leave exceeding 3 days"
  priority: 20

# Carryover
CarryoverRule:
  code: "SICK_EXPIRE_ALL"
  leaveTypeId: "SICK_TYPE_ID"
  carryoverType: EXPIRE_ALL
  resetPeriod: YEAR
  priority: 20
```

---

### Scenario 3: Tenure-Based Annual Leave

**Requirements**:
- 0-5 years: 15 days
- 5-10 years: 20 days
- 10+ years: 25 days
- Allocated upfront, prorated for new joiners

**Configuration**:

```yaml
# Accrual Rule 1: 0-5 years
AccrualRule:
  code: "ANNUAL_0_5Y_15D"
  leaveTypeId: "ANNUAL_TYPE_ID"
  accrualMethod: UPFRONT
  accrualAmount: 15
  accrualPeriod: YEAR
  accrualStartDate: YEAR_START
  isProrated: true
  priority: 20
  # Eligibility: Tenure < 5 years (handled separately)

# Accrual Rule 2: 5-10 years
AccrualRule:
  code: "ANNUAL_5_10Y_20D"
  leaveTypeId: "ANNUAL_TYPE_ID"
  accrualMethod: UPFRONT
  accrualAmount: 20
  accrualPeriod: YEAR
  accrualStartDate: YEAR_START
  isProrated: true
  priority: 25  # Higher priority
  # Eligibility: Tenure >= 5 and < 10 years

# Accrual Rule 3: 10+ years
AccrualRule:
  code: "ANNUAL_10Y_25D"
  leaveTypeId: "ANNUAL_TYPE_ID"
  accrualMethod: UPFRONT
  accrualAmount: 25
  accrualPeriod: YEAR
  accrualStartDate: YEAR_START
  isProrated: true
  priority: 30  # Highest priority
  # Eligibility: Tenure >= 10 years
```

**System Behavior**: System selects highest priority rule that matches employee's tenure.

---

## ✅ Best Practices

### 1. Rule Organization

✅ **DO**:
- Use class-level rules for common policies
- Override at type level only when needed
- Use descriptive rule codes (e.g., `ANNUAL_TENURE_6M`)
- Document rule purpose in `description` field

❌ **DON'T**:
- Create duplicate rules at multiple levels
- Use generic codes (e.g., `RULE_001`)
- Bind all rules at type level (defeats purpose of classes)

### 2. Priority Management

✅ **DO**:
- Use standard priorities: 10 (class), 20 (type), 30 (override)
- Increment by 5 for multiple rules at same level
- Document priority rationale

❌ **DON'T**:
- Use random priority values
- Create priority conflicts (same priority, same level)

### 3. Eligibility Integration

✅ **DO**:
- Use `EligibilityProfile` for complex, reusable logic
- Reference profiles from Core module
- Document eligibility criteria clearly

❌ **DON'T**:
- Duplicate eligibility logic across leave types
- Use inline criteria for complex rules

### 4. Error Messages

✅ **DO**:
- Write clear, user-friendly error messages
- Include specific values (e.g., "14 days advance notice required")
- Provide actionable guidance

❌ **DON'T**:
- Use technical jargon
- Write vague messages (e.g., "Invalid request")

---

## ⚠️ Common Pitfalls

### Pitfall 1: Conflicting Rules

❌ **Wrong**:
```yaml
# Class rule: 6 months tenure
EligibilityRule:
  leaveClassId: "PTO_CLASS_ID"
  minTenureMonths: 6
  priority: 10

# Type rule: 3 months tenure
EligibilityRule:
  leaveTypeId: "ANNUAL_TYPE_ID"
  minTenureMonths: 3
  priority: 10  # WRONG: Same priority as class
```

✅ **Correct**:
```yaml
# Class rule: 6 months tenure
EligibilityRule:
  leaveClassId: "PTO_CLASS_ID"
  minTenureMonths: 6
  priority: 10

# Type rule: 3 months tenure
EligibilityRule:
  leaveTypeId: "ANNUAL_TYPE_ID"
  minTenureMonths: 3
  priority: 20  # CORRECT: Higher priority overrides class
```

**Why**: Type-level rules must have higher priority to override class-level rules.

---

### Pitfall 2: Missing Proration

❌ **Wrong**:
```yaml
AccrualRule:
  accrualMethod: UPFRONT
  accrualAmount: 20
  isProrated: false  # WRONG: New joiners get full 20 days
```

✅ **Correct**:
```yaml
AccrualRule:
  accrualMethod: UPFRONT
  accrualAmount: 20
  isProrated: true  # CORRECT: Prorated for mid-year joiners
```

**Why**: Without proration, employee joining in December gets full 20 days for 1 month of work.

---

### Pitfall 3: Carryover Without Expiry

❌ **Wrong**:
```yaml
CarryoverRule:
  carryoverType: LIMITED
  maxCarryoverAmount: 5
  # WRONG: No expiry, carried days accumulate forever
```

✅ **Correct**:
```yaml
CarryoverRule:
  carryoverType: LIMITED
  maxCarryoverAmount: 5
  carryoverExpiryMonths: 3  # CORRECT: Carried days expire after 3 months
```

**Why**: Without expiry, carried days accumulate year after year, defeating the purpose of limited carryover.

---

## 🎓 Quick Reference

### Rule Binding Checklist

- [ ] Identify common policies → Bind to **LeaveClass**
- [ ] Identify type-specific policies → Bind to **LeaveType**
- [ ] Set correct priorities (10, 20, 30)
- [ ] Test rule resolution with sample employees
- [ ] Document rule purpose and rationale

### Policy Configuration Checklist

- [ ] Define leave class and types
- [ ] Configure eligibility (use EligibilityProfile if complex)
- [ ] Set up accrual rules
- [ ] Define validation rules (advance notice, limits, blackouts)
- [ ] Configure carryover rules
- [ ] Set up proration for mid-year joiners
- [ ] Define rounding rules
- [ ] Test with sample scenarios
- [ ] Document policy in employee handbook

---

## 📚 Related Guides

- [Concept Overview](./01-concept-overview.md) - Module overview
- [Conceptual Guide](./02-conceptual-guide.md) - How the system works
- [Leave Balance Ledger Guide](./04-leave-balance-ledger-guide.md) - Balance tracking
- [Eligibility Engine Guide](../../CO/01-concept/11-eligibility-engine-guide.md) - Centralized eligibility
- [Absence Ontology](../00-ontology/absence-ontology.yaml) - Data model

---

**Document Version**: 1.0  
**Created**: 2025-12-12  
**Last Review**: 2025-12-12  
**Author**: xTalent Documentation Team
