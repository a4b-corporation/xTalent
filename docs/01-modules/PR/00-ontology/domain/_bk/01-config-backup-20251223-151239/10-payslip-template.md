# PayslipTemplate

**Module**: Payroll (PR)
**Submodule**: CONFIG
**Version**: 2.0
**Last Updated**: 2025-12-23

---

## Entity: PayslipTemplate {#payslip-template}

**Classification**: CORE_ENTITY  

**Definition**: Defines payslip template layouts and formatting for employee payslip generation

**Purpose**: Provides customizable payslip templates that can be localized and branded per organization

**Key Characteristics**:
- Contains template layout in JSON format
- Supports localization with locale_code
- Can mark as default template
- SCD Type 2 for historical tracking
- Supports multiple output formats (PDF, HTML, etc.)

---

### Attributes

| Attribute | Type | Required | Constraints | Description |
|-----------|------|----------|-------------|-------------|
| `id` | UUID | ✅ | PK | Primary identifier |
| `code` | varchar(50) | ✅ | UNIQUE, NOT NULL | Unique template code |
| `name` | varchar(255) | ✅ | NOT NULL | Template display name |
| `locale_code` | varchar(10) | ❌ | NULL | Locale for localization (en-US, vi-VN) |
| `template_json` | jsonb | ❌ | NULL | Template layout and formatting |
| `description` | text | ❌ | NULL | Template description |
| `is_default` | boolean | ✅ | Default: false | Whether this is default template |
| `is_active` | boolean | ✅ | Default: true | Whether template is active |
| `effective_start_date` | date | ✅ | NOT NULL | Template effective start |
| `effective_end_date` | date | ❌ | NULL | Template expiration |
| `is_current_flag` | boolean | ✅ | Default: true | Current version flag |
| `metadata` | jsonb | ❌ | NULL | Additional flexible data |
| `created_at` | timestamp | ✅ | Auto-generated | Creation timestamp |
| `updated_at` | timestamp | ❌ | Auto-updated | Last modification timestamp |

**Attribute Details**:

#### `template_json`

**Type**: jsonb  
**Purpose**: Defines payslip layout, sections, and formatting

**Structure**:
```yaml
template_json:
  format: "PDF" | "HTML"
  layout:
    header:
      company_logo: true
      company_name: true
      payslip_title: "PAYSLIP"
    sections:
      - section_name: "Employee Information"
        fields:
          - field: "employee_name"
            label: "Employee Name"
          - field: "employee_id"
            label: "Employee ID"
      - section_name: "Earnings"
        fields:
          - field: "element_results"
            filter: "classification = 'EARNING'"
      - section_name: "Deductions"
        fields:
          - field: "element_results"
            filter: "classification = 'DEDUCTION'"
    footer:
      signature_line: true
      generated_date: true
```

---

### Examples

#### Example 1: Vietnam Standard Payslip

```yaml
PayslipTemplate:
  code: "VN_STANDARD_2025"
  name: "Vietnam Standard Payslip 2025"
  locale_code: "vi-VN"
  template_json:
    format: "PDF"
    layout:
      header:
        company_logo: true
        company_name: true
        payslip_title: "PHIẾU LƯƠNG"
      sections:
        - section_name: "Thông tin nhân viên"
          fields:
            - field: "employee_name"
              label: "Họ và tên"
            - field: "employee_id"
              label: "Mã nhân viên"
        - section_name: "Thu nhập"
          fields:
            - field: "element_results"
              filter: "classification = 'EARNING'"
        - section_name: "Khấu trừ"
          fields:
            - field: "element_results"
              filter: "classification = 'DEDUCTION'"
  is_default: true
  is_active: true
  effective_start_date: "2025-01-01"
  is_current_flag: true
```

---

### Best Practices

✅ **DO**:
- Localize templates for each market
- Test template rendering before activating
- Include all required legal information

❌ **DON'T**:
- Don't hardcode values in templates
- Don't create too many similar templates
- Don't change default template mid-period

---

### Related Workflows

- [WF-PR-CONFIG-005](../workflows/config-workflows.md#wf-pr-config-005) - Payslip Template Design
- [WF-PR-PROC-006](../workflows/processing-workflows.md#wf-pr-proc-006) - Payroll Finalization (generates payslips)

---


---

## References

- **Sub-module Index**: [README.md](./README.md)
- **Glossary**: [../../glossary-config.md](../../glossary-config.md)
- **Database Schema**: [../../../03-design/5.Payroll.V3.dbml](../../../03-design/5.Payroll.V3.dbml)