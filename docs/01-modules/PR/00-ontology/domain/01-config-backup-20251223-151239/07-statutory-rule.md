# StatutoryRule

**Module**: Payroll (PR)
**Submodule**: CONFIG
**Version**: 2.0
**Last Updated**: 2025-12-23

---

## Entity: StatutoryRule {#statutory-rule}

**Classification**: CORE_ENTITY  

**Definition**: Defines country/market-specific statutory compliance rules for payroll calculations (tax, social insurance, etc.)

**Purpose**: Encapsulates statutory compliance logic that varies by country and changes over time

**Key Characteristics**:
- Market-specific rules (linked to TalentMarket)
- Contains calculation formulas for statutory requirements
- SCD Type 2 for historical tracking of rule changes
- Valid from/to dates for rule applicability
- Can be referenced by PayElements for automatic compliance

---

### Attributes

| Attribute | Type | Required | Constraints | Description |
|-----------|------|----------|-------------|-------------|
| `id` | UUID | ✅ | PK | Primary identifier |
| `code` | varchar(50) | ✅ | UNIQUE, NOT NULL | Unique rule code (e.g., VN_PIT_2025, VN_SI_2025) |
| `name` | varchar(255) | ✅ | NOT NULL | Rule display name |
| `market_id` | UUID | ✅ | FK → Core.TalentMarket | Applicable market |
| `description` | text | ❌ | NULL | Detailed rule description |
| `formula_json` | jsonb | ❌ | NULL | Calculation formula |
| `valid_from` | date | ✅ | NOT NULL | Rule effective start date |
| `valid_to` | date | ❌ | NULL | Rule expiration date |
| `is_active` | boolean | ✅ | Default: true | Whether rule is active |
| `metadata` | jsonb | ❌ | NULL | Additional flexible data |
| `created_at` | timestamp | ✅ | Auto-generated | Creation timestamp |
| `updated_at` | timestamp | ❌ | Auto-updated | Last modification timestamp |

**Attribute Details**:

#### `formula_json`

**Type**: jsonb  
**Purpose**: Stores statutory calculation logic (tax brackets, insurance rates, etc.)

**Structure**:
```yaml
formula_json:
  rule_type: "PROGRESSIVE_TAX" | "FLAT_RATE" | "TIERED"
  brackets:
    - min_amount: 0
      max_amount: 5000000
      rate: 0.05
      deduction: 0
    - min_amount: 5000001
      max_amount: 10000000
      rate: 0.10
      deduction: 250000
  parameters:
    personal_deduction: 11000000
    dependent_deduction: 4400000
```

**Example - Vietnam PIT 2025**:
```json
{
  "rule_type": "PROGRESSIVE_TAX",
  "brackets": [
    {"min_amount": 0, "max_amount": 5000000, "rate": 0.05, "deduction": 0},
    {"min_amount": 5000001, "max_amount": 10000000, "rate": 0.10, "deduction": 250000},
    {"min_amount": 10000001, "max_amount": 18000000, "rate": 0.15, "deduction": 750000},
    {"min_amount": 18000001, "max_amount": 32000000, "rate": 0.20, "deduction": 1650000},
    {"min_amount": 32000001, "max_amount": 52000000, "rate": 0.25, "deduction": 3250000},
    {"min_amount": 52000001, "max_amount": 80000000, "rate": 0.30, "deduction": 5850000},
    {"min_amount": 80000001, "max_amount": null, "rate": 0.35, "deduction": 9850000}
  ],
  "parameters": {
    "personal_deduction": 11000000,
    "dependent_deduction": 4400000,
    "insurance_deductible": true
  }
}
```

---

### Relationships

| Relationship | Target | Cardinality | Foreign Key | Description |
|--------------|--------|-------------|-------------|-------------|
| `market` | Core.TalentMarket | N:1 | `market_id` | Applicable market |
| `elements` | [PayElement](#pay-element) | 1:N | (inverse) | Elements using this rule |

---

### Business Rules

| Rule ID | Rule Name | Description | Validation Trigger |
|---------|-----------|-------------|----------------------|
| BR-PR-STAT-001 | Unique Rule per Market-Period | Only one active rule per market + code + valid period | On Create/Update |
| BR-PR-STAT-002 | Valid Date Range | valid_to must be after valid_from | On Create/Update |
| BR-PR-STAT-003 | Valid Formula | formula_json must be valid and parseable | On Create/Update |

---

### Examples

#### Example 1: Vietnam Personal Income Tax 2025

```yaml
StatutoryRule:
  code: "VN_PIT_2025"
  name: "Vietnam Personal Income Tax 2025"
  market_id: "vietnam-market-uuid"
  description: "Progressive tax brackets for Vietnam PIT effective 2025"
  formula_json:
    rule_type: "PROGRESSIVE_TAX"
    brackets:
      - min_amount: 0
        max_amount: 5000000
        rate: 0.05
      - min_amount: 5000001
        max_amount: 10000000
        rate: 0.10
        deduction: 250000
    parameters:
      personal_deduction: 11000000
      dependent_deduction: 4400000
  valid_from: "2025-01-01"
  valid_to: null
  is_active: true
  effective_start_date: "2025-01-01"
  is_current_flag: true
```

#### Example 2: Vietnam Social Insurance 2025

```yaml
StatutoryRule:
  code: "VN_SI_2025"
  name: "Vietnam Social Insurance 2025"
  market_id: "vietnam-market-uuid"
  description: "Social insurance contribution rates and caps"
  formula_json:
    rule_type: "FLAT_RATE"
    employee_rate: 0.08
    employer_rate: 0.175
    salary_cap: 29800000
    minimum_salary: 4680000
  valid_from: "2025-01-01"
  valid_to: null
  is_active: true
  effective_start_date: "2025-01-01"
  is_current_flag: true
```

---

### Best Practices

✅ **DO**:
- Update rules annually based on statutory changes
- Use clear rule codes with year (VN_PIT_2025)
- Document all parameters in description
- Test rules with sample calculations before activating

❌ **DON'T**:
- Don't delete historical rules (use SCD2 versioning)
- Don't mix rules from different markets
- Don't hardcode values that change annually
- Don't activate rules before valid_from date

---

### Related Entities

**Parent/Upstream**:
- Core.TalentMarket - Applicable market

**Children/Downstream**:
- [PayElement](#pay-element) - Elements using this rule

---

### Related Workflows

- [WF-PR-CONFIG-004](../workflows/config-workflows.md#wf-pr-config-004) - Formula & Rule Configuration
- [WF-PR-PROC-001](../workflows/processing-workflows.md#wf-pr-proc-001) - Standard Payroll Run

---

### Migration Notes

**Version History**:
- **v2.0 (2025-07-01)**: Added `market_id` for market-specific rules
- **v2.0 (2025-07-01)**: Implemented SCD Type 2 for historical tracking
- **v1.0 (2024-01-01)**: Initial statutory rule definition

---

---

## References

- **Sub-module Index**: [README.md](./README.md)
- **Glossary**: [../../glossary-config.md](../../glossary-config.md)
- **Database Schema**: [../../../03-design/5.Payroll.V3.dbml](../../../03-design/5.Payroll.V3.dbml)