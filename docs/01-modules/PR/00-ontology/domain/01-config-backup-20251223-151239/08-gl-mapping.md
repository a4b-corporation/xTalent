# GLMapping

**Module**: Payroll (PR)
**Submodule**: CONFIG
**Version**: 2.0
**Last Updated**: 2025-12-23

---

## Entity: GLMapping {#gl-mapping}

**Classification**: CORE_ENTITY  

**Definition**: Maps payroll elements to specific GL (General Ledger) accounts for accounting integration

**Purpose**: Provides flexible GL account mapping that can override element-level defaults based on organizational structure or time periods

**Key Characteristics**:
- Links PayElement to specific GL account codes
- SCD Type 2 for historical tracking of account changes
- Can have different mappings for different time periods
- Supports complex GL account structures with segments

---

### Attributes

| Attribute | Type | Required | Constraints | Description |
|-----------|------|----------|-------------|-------------|
| `id` | UUID | ✅ | PK | Primary identifier |
| `element_id` | UUID | ✅ | FK → [PayElement](#pay-element) | Payroll element |
| `gl_account_code` | varchar(105) | ✅ | NOT NULL | GL account code |
| `effective_start_date` | date | ✅ | NOT NULL | Mapping effective start |
| `effective_end_date` | date | ❌ | NULL | Mapping expiration |
| `is_current_flag` | boolean | ✅ | Default: true | Current version flag |
| `is_active` | boolean | ✅ | Default: true | Whether mapping is active |
| `created_at` | timestamp | ✅ | Auto-generated | Creation timestamp |
| `updated_at` | timestamp | ❌ | Auto-updated | Last modification timestamp |

---

### Relationships

| Relationship | Target | Cardinality | Foreign Key | Description |
|--------------|--------|-------------|-------------|-------------|
| `element` | [PayElement](#pay-element) | N:1 | `element_id` | Mapped payroll element |

---

### Business Rules

| Rule ID | Rule Name | Description | Validation Trigger |
|---------|-----------|-------------|----------------------|
| BR-PR-GL-001 | Valid GL Account | gl_account_code must match chart of accounts | On Create/Update |
| BR-PR-GL-002 | No Overlapping Periods | Cannot have overlapping effective periods for same element | On Create/Update |
| BR-PR-GL-003 | Active Element Required | Cannot map to inactive element | On Create |

---

### Examples

#### Example 1: Basic Salary GL Mapping

```yaml
GLMapping:
  element_id: "basic-sal-element-uuid"
  gl_account_code: "5100-PAYROLL-SALARY"
  effective_start_date: "2025-01-01"
  effective_end_date: null
  is_current_flag: true
  is_active: true
```

**Business Context**: Maps basic salary element to payroll salary GL account

#### Example 2: Department-Specific Mapping

```yaml
GLMapping:
  element_id: "basic-sal-element-uuid"
  gl_account_code: "5100-IT-SALARY"
  effective_start_date: "2025-01-01"
  effective_end_date: null
  is_current_flag: true
  is_active: true
```

**Business Context**: Different GL account for IT department salaries

---

### Best Practices

✅ **DO**:
- Validate GL account codes against chart of accounts
- Use SCD2 for account changes
- Document mapping rationale in metadata

❌ **DON'T**:
- Don't create overlapping mappings
- Don't delete mappings (inactivate instead)
- Don't change GL accounts mid-period

---

### Related Entities

**Parent/Upstream**:
- [PayElement](#pay-element) - Mapped element

**Integration Points**:
- Accounting/GL System - GL account validation

---

### Related Workflows

- [WF-PR-CONFIG-004](../workflows/config-workflows.md#wf-pr-config-004) - Formula & Rule Configuration
- [WF-PR-PROC-006](../workflows/processing-workflows.md#wf-pr-proc-006) - Payroll Finalization (generates GL entries)

---


---

## References

- **Sub-module Index**: [README.md](./README.md)
- **Glossary**: [../../glossary-config.md](../../glossary-config.md)
- **Database Schema**: [../../../03-design/5.Payroll.V3.dbml](../../../03-design/5.Payroll.V3.dbml)