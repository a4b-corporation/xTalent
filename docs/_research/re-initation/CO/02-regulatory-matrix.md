# Regulatory & Constraint Matrix

> **Core HR (CO) Module** | Vietnam Labor Code 2019 Compliance
> Date: 2026-01-19

---

## Overview

This document maps Vietnam Labor Code 2019 requirements to xTalent Core HR system invariants. Priority indicates **compliance requirement level** (MUST = legal requirement, SHOULD = best practice).

---

## Employment Contract Types (Điều 20)

| Regulation | System Requirement | Priority | Entity | Compliance Risk |
|------------|-------------------|----------|--------|-----------------|
| Two contract types only: Indefinite, Definite-term | contractTypeCode ∈ {INDEFINITE, FIXED_TERM} | MUST | Contract | High - wrong types void contract |
| Definite-term max 36 months | endDate - startDate ≤ 36 months when type=FIXED_TERM | MUST | Contract | High - exceeds legal limit |
| Continue work 30 days after expiry → new contract required | System alert 30 days before endDate | SHOULD | Contract | Medium - compliance reminder |
| After 30 days without new contract → becomes INDEFINITE | Auto-convert on day 31 | MUST | Contract | High - legal presumption |
| Max 2 consecutive FIXED_TERM contracts | renewalCount ≤ 2 per WorkRelationship | MUST | Contract | High - 3rd must be INDEFINITE |

### System Invariants

```yaml
contract_type_validation:
  rule: "contractTypeCode IN ('INDEFINITE', 'FIXED_TERM')"
  error: "Invalid contract type per Labor Code 2019 Article 20"
  
fixed_term_duration:
  rule: "IF type='FIXED_TERM' THEN duration_months <= 36"
  error: "Fixed-term contract cannot exceed 36 months"
  
renewal_limit:
  rule: "IF consecutive_fixed_term_count >= 2 THEN next_must_be_indefinite"
  warning: "Third consecutive contract must be indefinite-term"
```

---

## Probation Period (Điều 24-27)

| Regulation | System Requirement | Priority | Entity | Compliance Risk |
|------------|-------------------|----------|--------|-----------------|
| Probation once per job | Unique(workerId, jobId, probation) | MUST | Contract | Medium - duplicate probation void |
| Max 180 days for enterprise managers | IF jobLevel='EXECUTIVE' THEN probationDays ≤ 180 | MUST | Contract | High - exceeds limit |
| Max 60 days for professional/technical | IF qualification='COLLEGE+' THEN probationDays ≤ 60 | MUST | Contract | High - exceeds limit |
| Max 30 days for skilled workers | IF qualification='INTERMEDIATE' THEN probationDays ≤ 30 | MUST | Contract | High - exceeds limit |
| Max 6 working days for other jobs | Default probationDays ≤ 6 | MUST | Contract | High - exceeds limit |
| Probation salary ≥ 85% of official | probationSalary >= 0.85 * officialSalary | MUST | Contract | Medium - below minimum |
| No probation for contracts < 1 month | IF duration < 1 month THEN probation = null | MUST | Contract | Medium - invalid probation |

### Probation Duration Matrix

| Job Level | Qualification | Max Probation Days |
|-----------|---------------|-------------------|
| Enterprise Manager | Per Enterprise Law | 180 |
| Professional/Technical | College degree+ | 60 |
| Skilled Worker | Intermediate cert | 30 |
| General Staff | Other | 6 |

### System Invariants

```yaml
probation_limit_executive:
  condition: "jobLevel IN ('C-LEVEL', 'DIRECTOR', 'EXECUTIVE')"
  rule: "probationDays <= 180"
  
probation_limit_professional:
  condition: "qualification IN ('COLLEGE', 'BACHELOR', 'MASTER', 'PHD')"
  rule: "probationDays <= 60"
  
probation_limit_skilled:
  condition: "qualification = 'INTERMEDIATE'"
  rule: "probationDays <= 30"
  
probation_limit_default:
  condition: "ELSE"
  rule: "probationDays <= 6"
  
probation_salary:
  rule: "probationSalary >= officialSalary * 0.85"
```

---

## Working Hours (Điều 105-107)

| Regulation | System Requirement | Priority | Entity | Compliance Risk |
|------------|-------------------|----------|--------|-----------------|
| Normal: max 8 hours/day | dailyHours ≤ 8 | MUST | Assignment | Medium - overtime triggers |
| Normal: max 48 hours/week | weeklyHours ≤ 48 | MUST | Assignment | Medium - overtime triggers |
| Reduced hours for heavy/hazardous work | IF hazardLevel='HIGH' THEN dailyHours ≤ 6 | MUST | Assignment | High - health and safety |
| Night work: 10pm - 6am | nightShift = true IF workHours overlap [22:00, 06:00] | SHOULD | Assignment | Medium - premium pay calculation |

---

## Termination (Điều 34-48)

| Regulation | System Requirement | Priority | Entity | Compliance Risk |
|------------|-------------------|----------|--------|-----------------|
| 24 termination grounds defined | terminationReasonCode ∈ validReasons | MUST | WorkRelationship | High - wrongful termination |
| Notice period by contract type | terminationNotice = f(contractType, tenure) | MUST | WorkRelationship | Medium - procedural compliance |
| Severance pay for certain grounds | IF eligible THEN severancePay calculated | MUST | WorkRelationship | High - financial compliance |

### Notice Period Matrix

| Contract Type | Condition | Notice Period |
|--------------|-----------|---------------|
| INDEFINITE | Normal termination | 45 days |
| INDEFINITE | Health reasons | 30 days |
| FIXED_TERM | Normal termination | 30 days |
| FIXED_TERM | Health reasons | 30 days |
| PROBATION | Either party | 3 days |

---

## Social Insurance (BHXH/BHYT/BHTN)

| Regulation | System Requirement | Priority | Entity | Compliance Risk |
|------------|-------------------|----------|--------|-----------------|
| Mandatory for EMPLOYEE type | IF workRelationType='EMPLOYEE' AND duration≥1month THEN siRequired=true | MUST | WorkRelationship | High - legal violation |
| SI registration within 30 days | siRegistrationDate ≤ hireDate + 30 | MUST | Employee | High - penalty applies |
| Contribution rates per law | Apply current rates table | MUST | Payroll (PR) | High - incorrect deductions |

### Worker Type SI Mapping

| WorkRelationship Type | BHXH Required | BHYT Required | BHTN Required |
|----------------------|---------------|---------------|---------------|
| EMPLOYEE | ✅ Yes | ✅ Yes | ✅ Yes |
| CONTINGENT | ❌ External | ❌ External | ❌ External |
| CONTRACTOR | ❌ Self | ❌ Self | ❌ Self |
| NON_WORKER | ❌ No | ❌ No | ❌ No |

---

## Data Retention (Điều 12 + Tax Law)

| Regulation | System Requirement | Priority | Entity | Compliance Risk |
|------------|-------------------|----------|--------|-----------------|
| Employment records 5 years after termination | retentionYears ≥ 5 for all employment data | MUST | All | Medium - audit failure |
| Payroll records 10 years | retentionYears ≥ 10 for payroll | MUST | Payroll | High - tax audit failure |
| Personal data per PDPA | consentRequired, dataMinimization | MUST | Worker | High - privacy violation |

---

## Industry Canon (De-facto Standards)

| Industry Standard | System Requirement | Priority | Compliance Risk |
|-------------------|-------------------|----------|-----------------|
| Effective-dated records (SCD-2) | All employment entities use effective_start_date/effective_end_date | SHOULD | Medium - audit trail |
| Maker-Checker for sensitive data | approvalWorkflow for salary, termination | SHOULD | Medium - fraud prevention |
| Immutable audit trail | All changes logged with timestamp, user | SHOULD | Medium - compliance evidence |
| Position-based access control | Assign permissions based on Position + BusinessUnit | SHOULD | Medium - data security |

---

## Constraint Catalog Summary

| Category | MUST (Legal) | SHOULD (Best Practice) | Total |
|----------|--------------|------------------------|-------|
| Contract Types | 5 | 1 | 6 |
| Probation | 6 | 0 | 6 |
| Working Hours | 3 | 1 | 4 |
| Termination | 3 | 0 | 3 |
| Social Insurance | 3 | 0 | 3 |
| Data Retention | 3 | 0 | 3 |
| Industry Canon | 0 | 4 | 4 |
| **Total** | **23** | **6** | **29** |
