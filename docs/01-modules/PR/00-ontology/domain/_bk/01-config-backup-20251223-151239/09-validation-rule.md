# ValidationRule

**Module**: Payroll (PR)
**Submodule**: CONFIG
**Version**: 2.0
**Last Updated**: 2025-12-23

---

## Entity: ValidationRule {#validation-rule}

**Classification**: CORE_ENTITY  

**Definition**: Defines data validation rules for payroll processing to ensure data quality and compliance

**Purpose**: Provides configurable validation logic that can be applied to payroll data before processing

**Key Characteristics**:
- Can target specific tables and fields
- Contains rule expression for validation logic
- SCD Type 2 for historical tracking
- Returns custom error messages for violations
- Can be activated/deactivated independently

---

### Attributes

| Attribute | Type | Required | Constraints | Description |
|-----------|------|----------|-------------|-------------|
| `id` | UUID | ✅ | PK | Primary identifier |
| `rule_code` | varchar(50) | ✅ | UNIQUE, NOT NULL | Unique validation rule code |
| `rule_name` | varchar(255) | ✅ | NOT NULL | Rule display name |
| `target_table` | varchar(50) | ✅ | NOT NULL | Target table for validation |
| `field_name` | varchar(50) | ✅ | NOT NULL | Target field name |
| `rule_expression` | text | ✅ | NOT NULL | Validation logic expression |
| `error_message` | varchar(255) | ✅ | NOT NULL | Error message when rule violated |
| `effective_start_date` | date | ✅ | NOT NULL | Rule effective start |
| `effective_end_date` | date | ❌ | NULL | Rule expiration |
| `is_current_flag` | boolean | ✅ | Default: true | Current version flag |
| `is_active` | boolean | ✅ | Default: true | Whether rule is active |
| `metadata` | jsonb | ❌ | NULL | Additional flexible data |
| `created_at` | timestamp | ✅ | Auto-generated | Creation timestamp |
| `updated_at` | timestamp | ❌ | Auto-updated | Last modification timestamp |

---

### Business Rules

| Rule ID | Rule Name | Description | Validation Trigger |
|---------|-----------|-------------|----------------------|
| BR-PR-VAL-001 | Unique Rule Code | Validation rule code must be unique | On Create/Update |
| BR-PR-VAL-002 | Valid Expression | rule_expression must be valid and parseable | On Create/Update |
| BR-PR-VAL-003 | Valid Target | target_table and field_name must exist in schema | On Create/Update |

---

### Examples

#### Example 1: Salary Range Validation

```yaml
ValidationRule:
  rule_code: "VAL_SALARY_RANGE"
  rule_name: "Salary Must Be Positive"
  target_table: "pay_run.input_value"
  field_name: "input_value"
  rule_expression: "input_value > 0 AND input_value < 1000000000"
  error_message: "Salary must be positive and less than 1 billion"
  effective_start_date: "2025-01-01"
  is_current_flag: true
  is_active: true
```

#### Example 2: Date Range Validation

```yaml
ValidationRule:
  rule_code: "VAL_PERIOD_DATES"
  rule_name: "Period End After Start"
  target_table: "pay_run.batch"
  field_name: "period_end"
  rule_expression: "period_end > period_start"
  error_message: "Period end date must be after period start date"
  effective_start_date: "2025-01-01"
  is_current_flag: true
  is_active: true
```

---

### Best Practices

✅ **DO**:
- Write clear, specific error messages
- Test validation rules before activating
- Document rule purpose in metadata

❌ **DON'T**:
- Don't create overly complex expressions
- Don't duplicate built-in database constraints
- Don't activate rules without testing

---

### Related Workflows

- [WF-PR-CONFIG-004](../workflows/config-workflows.md#wf-pr-config-004) - Formula & Rule Configuration
- [WF-PR-PROC-005](../workflows/processing-workflows.md#wf-pr-proc-005) - Payroll Validation & Review

---


---

## References

- **Sub-module Index**: [README.md](./README.md)
- **Glossary**: [../../glossary-config.md](../../glossary-config.md)
- **Database Schema**: [../../../03-design/5.Payroll.V3.dbml](../../../03-design/5.Payroll.V3.dbml)