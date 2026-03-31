# Glossary - Payroll Configuration Bounded Context

> **Bounded Context**: Payroll Configuration (BC-001)
> **Module**: Payroll (PR)
> **Phase**: Domain Architecture (Step 3)
> **Date**: 2026-03-31

---

## Ubiquitous Language

This glossary defines the terms used within the Payroll Configuration bounded context. All team members (developers, business analysts, stakeholders) should use these terms consistently.

---

## Entities

### PayElement

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **PayElement** | Fundamental payroll component representing an earning, deduction, or tax that contributes to employee pay calculation. | Not a PayProfile (which bundles elements). Not a PayFormula (which defines calculation logic). |
| **elementCode** | Unique identifier for the pay element within a legal entity. Human-readable code like "SALARY_BASIC". | Not elementId (internal database key). Must be unique per legal entity. |
| **elementName** | Human-readable name for the pay element like "Basic Salary". | Can change over time; elementCode is stable. |
| **classification** | Category determining gross/net impact: EARNING, DEDUCTION, TAX, EMPLOYER_CONTRIBUTION. | Not statutoryType (which is BHXH, BHYT, BHTN, PIT). |
| **calculationType** | How the element value is determined: FIXED, FORMULA, RATE_BASED, HOURS_BASED. | Not the formula expression itself. |
| **statutoryFlag** | Indicates if element represents statutory contribution (BHXH, BHYT, BHTN, PIT). | Not the same as statutoryType in StatutoryRule. True for government-mandated elements. |
| **taxableFlag** | Indicates if element is subject to PIT calculation. | Different from statutoryFlag. Many earnings are taxable but not statutory. |
| **formulaId** | Reference to PayFormula for FORMULA calculation type. | Nullable for FIXED or RATE_BASED elements. |
| **rate** | Fixed rate percentage for RATE_BASED calculation (e.g., 0.08 for 8%). | Different from StatutoryRule.rate. Used for formula-based elements. |
| **amount** | Fixed amount for FIXED calculation type. | Used when calculationType = FIXED. |
| **isActive** | Flag indicating element is available for assignment to profiles. | False after soft delete. Soft delete sets isActive = false. |
| **effectiveStartDate** | Date when this version becomes effective (SCD-2). | Part of version management. First version starts on creation date. |
| **effectiveEndDate** | Date when this version ends (SCD-2). Null for current version. | Set when new version is created. |
| **isCurrentFlag** | Indicates this is the current active version. | Only one version can have isCurrentFlag = true. |

**Lifecycle States**:
- **Active**: isActive = true, isCurrentFlag = true, can be assigned to profiles
- **Inactive**: isActive = false, soft-deleted, preserved for audit
- **Historical**: isCurrentFlag = false, previous version preserved

**Business Rules**:
- BR-PE-001: elementCode must be unique per legal entity
- BR-PE-002: classification determines gross/net impact direction
- BR-PE-003: Elements never physically deleted (soft delete only)
- BR-PE-004: Cannot delete if assigned to active pay profile
- BR-PE-005: New version effective date must follow previous version end date

---

### PayProfile

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **PayProfile** | Configuration bundle containing pay elements and statutory rules for a specific employee group within a legal entity. | Not PayElement (individual component). Not PayGroup (which assigns employees). |
| **profileCode** | Unique identifier for the pay profile within a legal entity. | Must be unique per legalEntityId. |
| **profileName** | Human-readable name like "Staff Profile" or "Executive Profile". | Can change; profileCode is stable. |
| **legalEntityId** | Reference to LegalEntity from Core HR (CO) module. | Not owned by this module. Reference only. |
| **payFrequencyId** | Reference to PayFrequency (WEEKLY, BI_WEEKLY, SEMI_MONTHLY, MONTHLY). | Reference data, not owned by this module. |
| **description** | Optional description of the profile purpose. | Free text for documentation. |
| **isActive** | Flag indicating profile is available for pay group assignment. | False after soft delete. |
| **effectiveStartDate** | Date when this version becomes effective (SCD-2). | Part of version management. |
| **effectiveEndDate** | Date when this version ends (SCD-2). Null for current version. | Set when new version is created. |
| **isCurrentFlag** | Indicates this is the current active version. | Only one version can have isCurrentFlag = true. |

**Lifecycle States**:
- **Active**: isActive = true, can be assigned to PayGroups
- **Inactive**: isActive = false, preserved for audit
- **Historical**: isCurrentFlag = false, previous version

**Business Rules**:
- BR-PP-001: profileCode unique per legal entity
- BR-PP-002: Element priority 1-99 determines calculation sequence
- BR-PP-003: Same element cannot be assigned twice to profile
- BR-PP-004: Only active elements can be assigned
- BR-PP-005: Assignment requires effective start date

---

### PayElementAssignment

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **PayElementAssignment** | Assignment of a PayElement to a PayProfile with optional overrides. | Not PayElement itself. Not PayGroupAssignment (employee to group). |
| **payElementId** | Reference to the PayElement being assigned. | Must reference active element. |
| **priority** | Calculation sequence order (1-99). Lower numbers calculated first. | Important for elements depending on other elements. |
| **formulaOverride** | Optional formula expression overriding element's default formula. | Nullable; if null, uses element's formula. |
| **rateOverride** | Optional rate overriding element's default rate. | Nullable; if null, uses element's rate. |
| **amountOverride** | Optional fixed amount overriding element's default amount. | Nullable; if null, uses element's amount. |
| **effectiveStartDate** | Date when assignment becomes effective. | Required field. |
| **effectiveEndDate** | Date when assignment ends. Nullable means ongoing. | Set when element is removed from profile. |

---

### StatutoryRuleAssignment

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **StatutoryRuleAssignment** | Assignment of a StatutoryRule to a PayProfile. | Not StatutoryRule itself. Different BC (Statutory Compliance). |
| **statutoryRuleId** | Reference to the StatutoryRule being assigned. | Must reference active rule. |
| **effectiveStartDate** | Date when assignment becomes effective. | Required field. |
| **effectiveEndDate** | Date when assignment ends. Nullable means ongoing. | Set when rule is removed from profile. |

---

### PayFormula

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **PayFormula** | Calculation formula defining how a pay element value is computed. | Not PayElement (which uses formula). Not formulaOverride (profile-specific override). |
| **formulaId** | Unique identifier for the formula. | System-generated UUID. |
| **formulaName** | Human-readable name like "BHXH Employee Calculation". | For documentation and selection. |
| **expression** | Formula expression like "{SALARY_BASIC} * 0.08". | Must pass syntax validation. |
| **description** | Optional description of formula purpose. | Free text for documentation. |
| **isActive** | Flag indicating formula is available for use. | False after soft delete. |

**Formula Language Elements**:

| Element | Syntax | Example |
|---------|--------|---------|
| Element Reference | `{ELEMENT_CODE}` | `{SALARY_BASIC}` |
| Arithmetic | `+`, `-`, `*`, `/` | `{base} * 0.08` |
| Power | `^` | `{base} ^ 2` |
| Comparison | `==`, `!=`, `<`, `>` | `{hours} > 8` |
| Conditional | `IF(cond, true, false)` | `IF({hours}>8, {hours}*1.5, {hours})` |
| Min/Max | `MIN(a, b)`, `MAX(a, b)` | `MIN({base}, 36000000)` |
| Round | `ROUND(val, decimals)` | `ROUND({result}, 0)` |
| Lookup | `LOOKUP(table, key)` | `LOOKUP(TAX_TABLE, {income})` |
| Progressive | `PROGRESSIVE(brackets, val)` | `PROGRESSIVE(PIT_BRACKETS, {taxable})` |

**Business Rules**:
- BR-FM-001: Valid syntax required
- BR-FM-002: Referenced elements must exist and be active
- BR-FM-003: No circular reference allowed
- BR-FM-004: Division by zero must be handled

---

## Classification Impact

| Classification | Gross Pay Impact | Net Pay Impact | Example |
|----------------|------------------|----------------|---------|
| EARNING | Increases | Increases | Basic Salary, Bonus |
| DEDUCTION | Decreases | Decreases | Union Fee, Advance |
| TAX | No impact | Decreases | PIT, Other Tax |
| EMPLOYER_CONTRIBUTION | No impact | No impact (employer cost) | BHXH Employer, BHYT Employer |

---

## Events

### PayElement Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **PayElementCreated** | A new pay element was created with version 1. | First creation, not update. |
| **PayElementUpdated** | An existing pay element was modified, creating new version. | Creates PayElementVersionCreated. |
| **PayElementDeleted** | A pay element was soft-deleted (isActive = false). | Not physical deletion. |
| **PayElementVersionCreated** | A new version of pay element was created via update. | Part of SCD-2 versioning. |

### PayProfile Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **PayProfileCreated** | A new pay profile was created with version 1. | First creation. |
| **PayProfileUpdated** | An existing pay profile was modified. | May trigger version. |
| **PayProfileDeleted** | A pay profile was soft-deleted. | Preserves assignments. |
| **PayProfileVersionCreated** | A new version of pay profile was created. | SCD-2 versioning. |

### Assignment Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **PayElementAssigned** | A pay element was assigned to a profile. | Creates PayElementAssignment. |
| **PayElementUnassigned** | A pay element was removed from a profile. | Sets effectiveEndDate. |
| **StatutoryRuleAssigned** | A statutory rule was assigned to a profile. | Creates StatutoryRuleAssignment. |

### Formula Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **FormulaCreated** | A new formula was created. | First creation. |
| **FormulaUpdated** | An existing formula was modified. | Re-validation required. |
| **FormulaValidated** | Formula validation completed successfully. | Syntax + references valid. |
| **FormulaValidationFailed** | Formula validation failed. | Error message provided. |

---

## Commands

| Command | Actor | Description |
|---------|-------|-------------|
| **CreatePayElement** | Payroll Admin | Create new pay element with SCD-2 version 1 |
| **UpdatePayElement** | Payroll Admin | Update element, creating new version |
| **DeletePayElement** | Payroll Admin | Soft delete (check in-use first) |
| **QueryPayElement** | Payroll Admin | Get current version by code |
| **QueryPayElementVersions** | Payroll Admin | List all versions |
| **ComparePayElementVersions** | Payroll Admin | Compare two versions |
| **CreatePayProfile** | Payroll Admin | Create profile with version 1 |
| **UpdatePayProfile** | Payroll Admin | Update profile |
| **DeletePayProfile** | Payroll Admin | Soft delete profile |
| **AssignPayElement** | Payroll Admin | Add element to profile |
| **UnassignPayElement** | Payroll Admin | Remove element from profile |
| **OverrideElementFormula** | Payroll Admin | Set formulaOverride on assignment |
| **CreateFormula** | Payroll Admin | Create calculation formula |
| **ValidateFormula** | Payroll Admin | Validate formula syntax and references |
| **PreviewFormula** | Payroll Admin | Preview result with sample values |

---

## Integration Points

### Inbound Integrations

| Source | Data | Purpose |
|--------|------|---------|
| Core HR (CO) | LegalEntity | Profile scope reference |
| Total Rewards (TR) | Compensation | Salary element mapping |
| Time & Absence (TA) | TimeEvent | Hours-based elements |

### Outbound Integrations

| Target | Data | Purpose |
|--------|------|---------|
| Calculation Engine | ConfigurationSnapshot | Payroll calculation input |
| Statutory Compliance | StatutoryRuleAssignment | Rule reference |

---

## Value Objects

### ElementClassification

| Value | Definition |
|-------|------------|
| EARNING | Component that increases employee pay |
| DEDUCTION | Component that decreases employee pay |
| TAX | Tax component decreasing net pay only |
| EMPLOYER_CONTRIBUTION | Employer cost, no employee impact |

### CalculationType

| Value | Definition |
|-------|------------|
| FIXED | Fixed amount defined on element |
| FORMULA | Calculated via formula expression |
| RATE_BASED | Percentage of base (e.g., 8% of salary) |
| HOURS_BASED | Hours multiplied by rate |

---

## Example Scenarios

### Creating Basic Salary Element

```
PayElement {
  elementCode: "SALARY_BASIC",
  elementName: "Basic Salary",
  classification: EARNING,
  calculationType: FIXED,
  statutoryFlag: false,
  taxableFlag: true,
  amount: null, // From TR compensation
  isActive: true,
  effectiveStartDate: "2026-01-01",
  effectiveEndDate: null,
  isCurrentFlag: true
}
```

### Creating BHXH Employee Element

```
PayElement {
  elementCode: "BHXH_EE",
  elementName: "Social Insurance Employee",
  classification: DEDUCTION,
  calculationType: FORMULA,
  statutoryFlag: true,
  taxableFlag: false,
  formulaId: "formula-bhxh-ee",
  isActive: true
}

PayFormula {
  formulaId: "formula-bhxh-ee",
  expression: "MIN({SALARY_BASIC}, 36000000) * 0.08"
}
```

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent