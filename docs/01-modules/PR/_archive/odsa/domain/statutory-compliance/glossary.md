# Glossary - Statutory Compliance Bounded Context

> **Bounded Context**: Statutory Compliance (BC-002)
> **Module**: Payroll (PR)
> **Phase**: Domain Architecture (Step 3)
> **Date**: 2026-03-31

---

## Ubiquitous Language

This glossary defines the terms used within the Statutory Compliance bounded context. All team members should use these terms consistently when discussing Vietnam statutory payroll rules.

---

## Entities

### StatutoryRule

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **StatutoryRule** | Government-mandated payroll rule for social insurance, health insurance, unemployment insurance, or personal income tax. | Not PayElement (which is a payroll component). Not PayProfile (which bundles rules). |
| **ruleCode** | Unique identifier for the statutory rule. Human-readable like "BHXH_EE", "PIT_VN". | Must be unique across all statutory rules. |
| **ruleName** | Human-readable name like "Social Insurance Employee Contribution". | Can change; ruleCode is stable. |
| **statutoryType** | Type of statutory rule: BHXH, BHYT, BHTN, PIT. | Not PayElement classification. Specific to statutory rules. |
| **partyType** | Who pays the contribution: EMPLOYEE, EMPLOYER. | BHXH has both employee (8%) and employer (17.5%) rules. |
| **rateType** | How rate is applied: FIXED_RATE, PROGRESSIVE, LOOKUP_BASED. | PIT uses PROGRESSIVE; others use FIXED_RATE. |
| **rate** | Fixed percentage rate (e.g., 0.08 for 8%). | For FIXED_RATE only. PIT does not use this. |
| **ceilingAmount** | Maximum wage base for contribution calculation (36,000,000 VND for social insurance). | Required for BHXH, BHYT, BHTN. Not used for PIT. |
| **floorAmount** | Minimum wage base for contribution (optional). | Rarely used in Vietnam. |
| **personalExemption** | Personal deduction amount for PIT (11,000,000 VND/month). | Only for PIT statutoryType. |
| **dependentExemption** | Deduction per dependent for PIT (4,400,000 VND/person/month). | Only for PIT statutoryType. |
| **isActive** | Flag indicating rule is available for assignment. | False after soft delete. |
| **effectiveStartDate** | Date when this version becomes effective (SCD-2). | Part of version management. |
| **effectiveEndDate** | Date when this version ends (SCD-2). Null for current version. | Set when government updates rates. |
| **isCurrentFlag** | Indicates this is the current active version. | Only one version can be current. |
| **versionReason** | Reason for creating new version. | Required field, e.g., "Government rate change July 2026". |

**Lifecycle States**:
- **Active**: isActive = true, isCurrentFlag = true, can be assigned to profiles
- **Inactive**: isActive = false, preserved for audit
- **Historical**: isCurrentFlag = false, previous version

**Business Rules**:
- BR-SR-001: Rate must be between 0 and 1 (percentage)
- BR-SR-002: Ceiling required for BHXH, BHYT, BHTN
- BR-SR-003: PIT brackets must cover full income range
- BR-SR-004: Version effective dates cannot overlap
- BR-SR-005: Government rates should match regulations (warning if different)

---

### TaxBracket

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **TaxBracket** | Progressive tax bracket defining income range and applicable tax rate. | Only for PIT statutoryType. Not for BHXH/BHYT/BHTN. |
| **bracketNumber** | Sequential bracket number (1-7 for Vietnam PIT). | Ordered from lowest to highest income. |
| **minAmount** | Minimum taxable income for this bracket. | Bracket 1 starts at 0. |
| **maxAmount** | Maximum taxable income for this bracket. | Null for highest bracket (no upper limit). |
| **rate** | Tax rate for this bracket (0.05 to 0.35). | Applied to income within bracket range. |
| **taxAmount** | Cumulative tax from previous brackets (pre-calculated for efficiency). | Optional optimization field. |

**Vietnam PIT Brackets (2026)**:
| Bracket | Min Amount (VND) | Max Amount (VND) | Rate | Cumulative Tax |
|---------|------------------|------------------|------|----------------|
| 1 | 0 | 5,000,000 | 5% | 0 |
| 2 | 5,000,001 | 10,000,000 | 10% | 250,000 |
| 3 | 10,000,001 | 18,000,000 | 15% | 750,000 |
| 4 | 18,000,001 | 32,000,000 | 20% | 1,950,000 |
| 5 | 32,000,001 | 52,000,000 | 25% | 4,750,000 |
| 6 | 52,000,001 | 80,000,000 | 30% | 9,750,000 |
| 7 | 80,000,001+ | - | 35% | 18,150,000 |

---

## Value Objects

### StatutoryType

| Value | Definition | Vietnam Rates |
|-------|------------|---------------|
| **BHXH** | Social Insurance (Bao Hiem Xa Hoi) | Employee 8%, Employer 17.5% |
| **BHYT** | Health Insurance (Bao Hiem Y Te) | Employee 1.5%, Employer 3% |
| **BHTN** | Unemployment Insurance (Bao Hiem That Nghiep) | Employee 1%, Employer 1% |
| **PIT** | Personal Income Tax (Thue TNCN) | Progressive 5%-35% |

### PartyType

| Value | Definition |
|-------|------------|
| **EMPLOYEE** | Employee contribution (deducted from salary) |
| **EMPLOYER** | Employer contribution (employer cost) |

### RateType

| Value | Definition | Used For |
|-------|------------|----------|
| **FIXED_RATE** | Single percentage rate applied to wage base | BHXH, BHYT, BHTN |
| **PROGRESSIVE** | Multiple brackets with different rates | PIT |
| **LOOKUP_BASED** | Rate determined by lookup table | Custom scenarios |

---

## Events

### StatutoryRule Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **StatutoryRuleCreated** | A new statutory rule was created with version 1. | First creation. |
| **StatutoryRuleUpdated** | An existing statutory rule was modified, creating new version. | Government rate change. |
| **StatutoryRuleDeleted** | A statutory rule was soft-deleted. | Preserves history. |
| **StatutoryRuleVersionCreated** | A new version was created via update. | SCD-2 versioning. |

### PIT Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **PITBracketConfigured** | Progressive PIT brackets were configured. | Updates TaxBracket collection. |
| **PITExemptionSet** | Personal and dependent exemptions were set. | Updates statutory rule. |

---

## Commands

| Command | Actor | Description |
|---------|-------|-------------|
| **CreateStatutoryRule** | Payroll Admin, Compliance Officer | Create new statutory rule |
| **UpdateStatutoryRule** | Payroll Admin, Compliance Officer | Update rule (rate, ceiling) |
| **DeleteStatutoryRule** | Payroll Admin | Soft delete rule |
| **ConfigurePITBrackets** | Payroll Admin | Set progressive tax brackets |
| **SetPITExemptions** | Payroll Admin | Set personal/dependent exemptions |
| **QueryStatutoryRuleVersions** | Payroll Admin | List all versions |
| **QueryStatutoryRuleByDate** | Payroll Admin | Get version effective on date |

---

## Vietnam Statutory Reference

### Social Insurance (BHXH)

| Party | Rate | Ceiling | Effective From |
|-------|------|---------|----------------|
| Employee | 8% | 36,000,000 VND | 2026-01-01 |
| Employer | 17.5% | 36,000,000 VND | 2026-01-01 |

**Notes**:
- Total employer contribution: 17.5% (includes retirement, disability, survivor benefits)
- Employee contribution: 8% (retirement fund only)
- Ceiling applies to wage base, not contribution amount

### Health Insurance (BHYT)

| Party | Rate | Ceiling | Effective From |
|-------|------|---------|----------------|
| Employee | 1.5% | 36,000,000 VND | 2026-01-01 |
| Employer | 3% | 36,000,000 VND | 2026-01-01 |

### Unemployment Insurance (BHTN)

| Party | Rate | Ceiling | Effective From |
|-------|------|---------|----------------|
| Employee | 1% | 36,000,000 VND | 2026-01-01 |
| Employer | 1% | 36,000,000 VND | 2026-01-01 |

### Personal Income Tax (PIT)

**Progressive Brackets**:
| Monthly Income (VND) | Tax Rate |
|----------------------|----------|
| 0 - 5,000,000 | 5% |
| 5,000,001 - 10,000,000 | 10% |
| 10,000,001 - 18,000,000 | 15% |
| 18,000,001 - 32,000,000 | 20% |
| 32,000,001 - 52,000,000 | 25% |
| 52,000,001 - 80,000,000 | 30% |
| 80,000,001+ | 35% |

**Exemptions**:
| Type | Amount |
|------|--------|
| Personal Exemption | 11,000,000 VND/month |
| Dependent Exemption | 4,400,000 VND/person/month |

---

## Calculation Examples

### BHXH Employee Contribution

```
Employee Salary: 50,000,000 VND/month

Step 1: Apply ceiling
  wageBase = MIN(salary, ceilingAmount)
  wageBase = MIN(50,000,000, 36,000,000) = 36,000,000 VND

Step 2: Calculate contribution
  contribution = wageBase * rate
  contribution = 36,000,000 * 0.08 = 2,880,000 VND

Result: Employee BHXH deduction = 2,880,000 VND
```

### PIT Progressive Calculation

```
Monthly taxable income: 45,000,000 VND
Personal exemption: 11,000,000 VND
Dependents: 2 (exemption = 8,800,000 VND)

Step 1: Calculate taxable base
  taxableBase = grossIncome - personalExemption - dependentExemption
  taxableBase = 45,000,000 - 11,000,000 - 8,800,000 = 25,200,000 VND

Step 2: Apply progressive brackets
  Bracket 1: 5,000,000 * 5% = 250,000
  Bracket 2: 5,000,000 * 10% = 500,000
  Bracket 3: 8,000,000 * 15% = 1,200,000
  Bracket 4: 7,200,000 * 20% = 1,440,000

Step 3: Sum tax from all brackets
  totalPIT = 250,000 + 500,000 + 1,200,000 + 1,440,000 = 3,390,000 VND

Result: Monthly PIT = 3,390,000 VND
```

---

## Integration Points

### Outbound Integrations

| Target | Data | Purpose |
|--------|------|---------|
| Payroll Configuration | StatutoryRuleAssignment | Profile rule reference |
| Calculation Engine | StatutoryRuleSnapshot | Payroll calculation |

---

## Version Management

### Version Query by Date

```
Query statutory rule "BHXH_EE" for date "2026-05-15"

Rules:
  Version 1: effective 2026-01-01 to 2026-06-30, rate 8%
  Version 2: effective 2026-07-01 to null, rate 8.5%

Result: Version 1 (rate = 8%)
```

### Version Change Workflow

```
Government announces rate change effective July 1, 2026

Steps:
1. Compliance Officer initiates UpdateStatutoryRule
2. New version created with:
   - effectiveStartDate: 2026-07-01
   - rate: 0.085
   - versionReason: "Government rate increase Decree 2026"
3. Previous version updated:
   - effectiveEndDate: 2026-06-30
   - isCurrentFlag: false
4. Audit entry created
```

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent