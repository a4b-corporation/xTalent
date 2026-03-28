# Calculation Rules - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-04  
**Module**: Total Rewards (TR)  
**Sub-module**: Calculation Rules

---

## Overview

Calculation Rules manages the complex calculation logic for compensation, tax, and social insurance across multiple countries. This sub-module provides:

- **Rule Definitions**: Versioned calculation rules for tax, social insurance, overtime, proration
- **Rule Application**: Links rules to pay components and salary bases
- **Performance Optimization**: Tax calculation caching for faster payroll processing
- **Country Configuration**: Country-specific settings for working hours, holidays, tax systems
- **Holiday Management**: Holiday calendars for overtime and proration calculations

This sub-module is critical for **multi-country payroll compliance** and ensures accurate, auditable calculations.

---

## Entities

### 1. CalculationRuleDefinition

**Definition**: Versioned calculation rule storing actual calculation logic for tax, social insurance, overtime, and other compensation calculations.

**Purpose**: Centralizes all calculation logic in a structured, auditable format with full version history (SCD Type 2).

**Key Characteristics**:
- Supports multiple rule types (PROGRESSIVE tax, RATE_TABLE for SI, LOOKUP_TABLE for OT)
- Country-specific rules with jurisdiction support
- Version tracking for regulatory changes
- Stores calculation logic in structured JSON format
- Legal reference documentation for compliance

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Unique code (e.g., VN_PIT_2025, SG_CPF_2025) |
| `name` | string(200) | Yes | Rule name |
| `rule_category` | enum | Yes | TAX, SOCIAL_INSURANCE, PRORATION, OVERTIME, ROUNDING, FOREX, ANNUALIZATION, GROSS_TO_NET |
| `rule_type` | enum | Yes | FORMULA, LOOKUP_TABLE, CONDITIONAL, RATE_TABLE, PROGRESSIVE, TIERED |
| `country_code` | string(2) | No | ISO country code (NULL for global rules) |
| `jurisdiction` | string(50) | No | State/Province/City if applicable |
| `formula_json` | jsonb | Yes | Actual calculation logic/data (structure varies by rule_type) |
| `description` | text | No | Detailed description |
| `legal_reference` | text | No | Legal citation (e.g., "Labor Code Article 107") |
| `effective_start_date` | date | Yes | When rule becomes active |
| `effective_end_date` | date | No | When rule expires (NULL = still effective) |
| `version_number` | integer | No | Version tracking (default: 1) |
| `previous_version_id` | UUID | No | FK to previous version (SCD Type 2 chain) |
| `is_current_version` | boolean | No | True for current version only |

**Relationships**:

| Relationship | Target Entity | Cardinality | Description |
|--------------|---------------|-------------|-------------|
| `previousVersion` | CalculationRuleDefinition | N:1 | Previous version in SCD chain |
| `componentRules` | ComponentCalculationRule | 1:N | Components using this rule |
| `basisRules` | BasisCalculationRule | 1:N | Salary bases using this rule |
| `cache` | TaxCalculationCache | 1:N | Cached calculations |

**Business Rules**:
1. Only one current version per code (is_current_version = true)
2. Country-specific rules override global rules
3. formula_json structure must match rule_type
4. Legal reference required for tax and SI rules
5. Version chain must be unbroken

**Formula JSON Examples by Rule Type**:

```yaml
PROGRESSIVE (Tax Brackets):
  formula_json:
    brackets:
      - min: 0
        max: 5000000
        rate: 0.05
      - min: 5000001
        max: 10000000
        rate: 0.10
      - min: 10000001
        max: 18000000
        rate: 0.15
    personal_deduction: 11000000
    dependent_deduction: 4400000

RATE_TABLE (Social Insurance):
  formula_json:
    employee:
      si_rate: 0.08
      hi_rate: 0.015
      ui_rate: 0.01
    employer:
      si_rate: 0.14
      hi_rate: 0.03
      ui_rate: 0.01
    min_base: 2340000
    max_base: 46800000

LOOKUP_TABLE (Overtime Multipliers):
  formula_json:
    weekday_normal: 1.5
    weekday_night: 1.95
    weekend: 2.0
    holiday: 3.0
```

**Real-World Examples**:

```yaml
Example 1: Vietnam Personal Income Tax 2025
  CalculationRuleDefinition:
    code: "VN_PIT_2025"
    name: "Vietnam Personal Income Tax 2025"
    rule_category: TAX
    rule_type: PROGRESSIVE
    country_code: "VN"
    legal_reference: "Law on Personal Income Tax 2007, amended 2012"
    formula_json:
      brackets:
        - {min: 0, max: 5000000, rate: 0.05}
        - {min: 5000001, max: 10000000, rate: 0.10}
        - {min: 10000001, max: 18000000, rate: 0.15}
        - {min: 18000001, max: 32000000, rate: 0.20}
        - {min: 32000001, max: 52000000, rate: 0.25}
        - {min: 52000001, max: 80000000, rate: 0.30}
        - {min: 80000001, max: null, rate: 0.35}
      personal_deduction: 11000000
      dependent_deduction: 4400000

Example 2: Vietnam Social Insurance 2025
  CalculationRuleDefinition:
    code: "VN_SI_2025"
    name: "Vietnam Social Insurance 2025"
    rule_category: SOCIAL_INSURANCE
    rule_type: RATE_TABLE
    country_code: "VN"
    legal_reference: "Social Insurance Law 2014, amended 2024"
    formula_json:
      employee: {si_rate: 0.08, hi_rate: 0.015, ui_rate: 0.01}
      employer: {si_rate: 0.14, hi_rate: 0.03, ui_rate: 0.01}
      min_base: 2340000
      max_base: 46800000

Example 3: Vietnam Overtime Multipliers
  CalculationRuleDefinition:
    code: "VN_OT_MULT_2019"
    name: "Vietnam Overtime Multipliers"
    rule_category: OVERTIME
    rule_type: LOOKUP_TABLE
    country_code: "VN"
    legal_reference: "Labor Code 2019, Article 107"
    formula_json:
      weekday_normal: 1.5
      weekday_night: 1.95
      weekend: 2.0
      holiday: 3.0
```

**Best Practices**:
- ✅ DO: Create new version when regulations change (don't modify existing)
- ✅ DO: Document legal references for all tax/SI rules
- ✅ DO: Test formula_json thoroughly before activation
- ✅ DO: Use country_code for country-specific rules
- ❌ DON'T: Delete historical rule versions
- ❌ DON'T: Modify formula_json of active rules (create new version)
- ❌ DON'T: Mix different rule_types in same rule

**Related Entities**:
- ComponentCalculationRule - Links rules to pay components
- BasisCalculationRule - Links rules to salary bases
- TaxCalculationCache - Caches rule execution results

---

### 2. ComponentCalculationRule

**Definition**: Links pay components to specific calculation rules with execution order and parameter overrides.

**Purpose**: Defines which rules apply to each pay component and in what sequence.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `component_id` | UUID | Yes | FK to PayComponentDefinition |
| `rule_id` | UUID | Yes | FK to CalculationRuleDefinition |
| `rule_scope` | enum | Yes | COMPONENT_CALC, TAX, PRORATION, VALIDATION, SI_CALCULATION, ROUNDING |
| `execution_order` | integer | No | Sequence when multiple rules apply (default: 0) |
| `override_params` | jsonb | No | Component-specific parameter overrides |
| `effective_start_date` | date | Yes | When rule link becomes active |
| `effective_end_date` | date | No | When rule link expires |

**Business Rules**:
1. execution_order determines calculation sequence
2. override_params can customize rule behavior per component
3. Multiple rules can apply to same component (different scopes)

**Examples**:

```yaml
Example: Base Salary with Tax and SI Rules
  ComponentCalculationRule:
    - component_id: "BASE_SALARY_UUID"
      rule_id: "VN_SI_2025_UUID"
      rule_scope: SI_CALCULATION
      execution_order: 1
    
    - component_id: "BASE_SALARY_UUID"
      rule_id: "VN_PIT_2025_UUID"
      rule_scope: TAX
      execution_order: 2
    
    - component_id: "BASE_SALARY_UUID"
      rule_id: "VN_PRORATION_CALENDAR_UUID"
      rule_scope: PRORATION
      execution_order: 0
```

---

### 3. BasisCalculationRule

**Definition**: Links salary basis to calculation rules defining the gross-to-net calculation flow.

**Purpose**: Defines which rules apply to entire salary basis and their execution sequence.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `salary_basis_id` | UUID | Yes | FK to SalaryBasis |
| `rule_id` | UUID | Yes | FK to CalculationRuleDefinition |
| `rule_scope` | enum | Yes | PRORATION, TAX, ROUNDING, ANNUALIZATION, SI_CALCULATION, GROSS_TO_NET |
| `execution_order` | integer | No | Calculation sequence (1-6) |
| `override_params` | jsonb | No | Basis-specific parameter overrides |
| `effective_start_date` | date | Yes | When rule link becomes active |
| `effective_end_date` | date | No | When rule link expires |

**Execution Order Standard**:
1. Proration rules (calculate prorated amounts)
2. Component calculations (formulas, OT)
3. Gross salary sum
4. Social insurance deductions
5. Tax calculations (PIT)
6. Net salary calculation

**Business Rules**:
1. execution_order critical for multi-step calculations (gross→SI→tax→net)
2. override_params can customize rule behavior per basis

---

### 4. TaxCalculationCache

**Definition**: Pre-calculated tax/SI lookup table for performance optimization.

**Purpose**: Caches frequently-used calculations to speed up payroll processing and reduce computation load.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `rule_id` | UUID | Yes | FK to CalculationRuleDefinition |
| `input_amount` | decimal(18,4) | Yes | Taxable income or SI base |
| `output_tax` | decimal(18,4) | Yes | Calculated tax or SI amount |
| `output_details` | jsonb | No | Breakdown by bracket/tier |
| `params_hash` | string(64) | Yes | MD5 hash of input parameters (cache key) |
| `calculated_at` | timestamp | No | When cache was created |
| `expires_at` | timestamp | Yes | Cache expiration date |

**Business Rules**:
1. params_hash = MD5(rule_id + input_amount + deductions + dependents + ...)
2. Cache invalidated when rule version changes
3. expires_at for automatic cache cleanup
4. Used for read-heavy payroll calculations

**Examples**:

```yaml
Example: Cached Tax Calculation
  TaxCalculationCache:
    rule_id: "VN_PIT_2025_UUID"
    input_amount: 30000000  # 30M VND taxable income
    output_tax: 2350000     # Calculated tax
    output_details:
      brackets:
        - {bracket: 1, amount: 5000000, rate: 0.05, tax: 250000}
        - {bracket: 2, amount: 5000000, rate: 0.10, tax: 500000}
        - {bracket: 3, amount: 8000000, rate: 0.15, tax: 1200000}
        - {bracket: 4, amount: 12000000, rate: 0.20, tax: 400000}
      total_tax: 2350000
      effective_rate: 0.0783
    params_hash: "a3f5b8c9d2e1..."
    expires_at: "2025-12-31T23:59:59Z"
```

---

### 5. CountryConfiguration

**Definition**: Country-level configuration for compensation calculations including working hours, tax systems, and standards.

**Purpose**: Centralizes country-specific settings used across all compensation calculations.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `country_code` | string(2) | Yes | ISO 3166-1 alpha-2 (VN, US, SG) |
| `country_name` | string(100) | Yes | Country name |
| `currency_code` | string(3) | Yes | ISO 4217 (VND, USD, SGD) |
| `tax_system` | enum | Yes | PROGRESSIVE, FLAT, DUAL, TERRITORIAL, NONE |
| `si_system` | enum | Yes | MANDATORY, OPTIONAL, HYBRID, NONE |
| `standard_working_hours_per_day` | integer | No | Default: 8 |
| `standard_working_days_per_week` | integer | No | Default: 5 |
| `standard_working_days_per_month` | integer | No | Default: 22 (for proration) |
| `config_json` | jsonb | No | Country-specific configurations |
| `is_active` | boolean | No | Active status |

**Business Rules**:
1. Country code must be valid ISO 3166-1 alpha-2
2. Currency code must be valid ISO 4217
3. Standard working hours/days used for proration calculations
4. One configuration per country

**Examples**:

```yaml
Example 1: Vietnam Configuration
  CountryConfiguration:
    country_code: "VN"
    country_name: "Vietnam"
    currency_code: "VND"
    tax_system: PROGRESSIVE
    si_system: MANDATORY
    standard_working_hours_per_day: 8
    standard_working_days_per_month: 26
    config_json:
      fiscal_year_start: "01-01"
      minimum_wage: 4680000
      overtime_cap_hours_per_month: 200
      annual_leave_days: 12

Example 2: Singapore Configuration
  CountryConfiguration:
    country_code: "SG"
    country_name: "Singapore"
    currency_code: "SGD"
    tax_system: PROGRESSIVE
    si_system: MANDATORY
    standard_working_hours_per_day: 8
    standard_working_days_per_month: 22
```

---

### 6. HolidayCalendar

**Definition**: Holiday calendar per country/jurisdiction for overtime multiplier determination and proration calculations.

**Purpose**: Tracks public holidays to apply correct overtime rates and exclude from working day calculations.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `country_code` | string(2) | Yes | FK to CountryConfiguration |
| `jurisdiction` | string(50) | No | State/Province (NULL for national) |
| `year` | integer | Yes | Calendar year (2025, 2026, etc.) |
| `holiday_date` | date | Yes | Holiday date |
| `holiday_name` | string(200) | Yes | Holiday name |
| `holiday_type` | enum | Yes | NATIONAL, REGIONAL, BANK, OPTIONAL, RELIGIOUS |
| `is_paid` | boolean | No | Is this a paid holiday? (default: true) |
| `ot_multiplier` | decimal(4,2) | No | OT multiplier if work on this day (e.g., 3.0) |

**Business Rules**:
1. Used for OT multiplier determination
2. Used for proration calculations (exclude holidays from working days)
3. Regional holidays override national for specific jurisdictions
4. Must be maintained annually

**Examples**:

```yaml
Example: Vietnam Holidays 2025
  HolidayCalendar:
    - country_code: "VN"
      year: 2025
      holiday_date: "2025-01-01"
      holiday_name: "Tết Dương Lịch"
      holiday_type: NATIONAL
      is_paid: true
      ot_multiplier: 3.0
    
    - country_code: "VN"
      year: 2025
      holiday_date: "2025-01-28"
      holiday_name: "Tết Nguyên Đán (Mùng 1)"
      holiday_type: NATIONAL
      is_paid: true
      ot_multiplier: 3.0
    
    - country_code: "VN"
      year: 2025
      holiday_date: "2025-04-30"
      holiday_name: "Ngày Giải Phóng Miền Nam"
      holiday_type: NATIONAL
      is_paid: true
      ot_multiplier: 3.0
```

---

## Summary

The Calculation Rules sub-module provides **6 entities** that work together to manage:

1. **Rule Definition**: CalculationRuleDefinition (versioned calculation logic)
2. **Rule Application**: ComponentCalculationRule, BasisCalculationRule
3. **Performance**: TaxCalculationCache
4. **Configuration**: CountryConfiguration, HolidayCalendar

**Key Design Patterns**:
- ✅ SCD Type 2 for rule versioning (regulatory compliance)
- ✅ Structured JSON for flexible calculation logic
- ✅ Multi-country support with country-specific overrides
- ✅ Performance optimization through caching
- ✅ Legal reference documentation for audit trail

**Integration Points**:
- **Payroll Module**: Uses rules for gross-to-net calculation
- **Core Compensation**: Rules applied to components and salary bases
- **Time & Attendance**: Overtime multipliers from holiday calendar

---

**Document Status**: ✅ Complete  
**Coverage**: 6 of 6 entities documented  
**Last Updated**: 2025-12-04  
**Next Steps**: Create glossary-variable-pay.md
