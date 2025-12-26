# PayFormula

**Module**: Payroll (PR)
**Submodule**: CONFIG
**Version**: 2.0
**Last Updated**: 2025-12-23

---

## Entity: PayFormula {#pay-formula}

**Classification**: CORE_ENTITY  

**Definition**: Defines reusable calculation formulas that can be referenced by multiple pay elements

**Purpose**: Provides centralized formula library for complex calculations, promoting reusability and maintainability

**Key Characteristics**:
- Contains formula script/logic
- Versioned for change tracking
- Can be activated/deactivated independently
- Referenced by PayElement for calculations

---

### Attributes

| Attribute | Type | Required | Constraints | Description |
|-----------|------|----------|-------------|-------------|
| `id` | UUID | ✅ | PK | Primary identifier |
| `code` | varchar(50) | ✅ | UNIQUE, NOT NULL | Unique formula code |
| `name` | varchar(255) | ✅ | NOT NULL | Formula display name |
| `script` | text | ✅ | NOT NULL | Formula calculation script |
| `description` | text | ❌ | NULL | Formula description and usage |
| `version_no` | int | ✅ | Default: 1 | Formula version number |
| `is_active` | boolean | ✅ | Default: true | Whether formula is active |
| `metadata` | jsonb | ❌ | NULL | Additional flexible data |
| `created_at` | timestamp | ✅ | Auto-generated | Creation timestamp |
| `updated_at` | timestamp | ❌ | Auto-updated | Last modification timestamp |

---

### Examples

#### Example 1: Overtime Calculation Formula

```yaml
PayFormula:
  code: "CALC_OT_1_5"
  name: "Overtime 1.5x Calculation"
  script: |
    // Calculate overtime at 1.5x rate
    const hourlyRate = getEmployeeBasicHourlyRate(employee_id);
    const otHours = getInputValue('OT_HOURS');
    return hourlyRate * 1.5 * otHours;
  description: "Calculates overtime pay at 1.5x hourly rate"
  version_no: 1
  is_active: true
```

#### Example 2: Prorated Salary Formula

```yaml
PayFormula:
  code: "CALC_PRORATED_SAL"
  name: "Prorated Salary Calculation"
  script: |
    // Calculate prorated salary based on working days
    const monthlySalary = getEmployeeBasicSalary(employee_id);
    const workingDays = getInputValue('WORKING_DAYS');
    const totalDays = getCalendarWorkingDays(period_start, period_end);
    return (monthlySalary / totalDays) * workingDays;
  description: "Calculates prorated salary for partial month"
  version_no: 1
  is_active: true
```

---

### Best Practices

✅ **DO**:
- Document formula logic clearly
- Test formulas with sample data
- Version formulas when making changes
- Use descriptive formula codes

❌ **DON'T**:
- Don't create overly complex formulas
- Don't duplicate existing formulas
- Don't change active formulas (create new version)

---

### Related Entities

**Children/Downstream**:
- [PayElement](#pay-element) - Elements using this formula

---

### Related Workflows

- [WF-PR-CONFIG-004](../workflows/config-workflows.md#wf-pr-config-004) - Formula & Rule Configuration

---


---

## References

- **Sub-module Index**: [README.md](./README.md)
- **Glossary**: [../../glossary-config.md](../../glossary-config.md)
- **Database Schema**: [../../../03-design/5.Payroll.V3.dbml](../../../03-design/5.Payroll.V3.dbml)