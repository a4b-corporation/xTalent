# Glossary - Finance Integration Bounded Context

> **Bounded Context**: Finance Integration (BC-005)
> **Module**: Payroll (PR)
> **Phase**: Domain Architecture (Step 3)
> **Date**: 2026-03-31

---

## Ubiquitous Language

This glossary defines the terms used within the Finance Integration bounded context. All team members should use these terms consistently when discussing GL mappings and banking templates.

---

## Entities

### GLMappingPolicy

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **GLMappingPolicy** | Policy defining how a pay element's cost is allocated to General Ledger accounts. | Not PayElement (which is mapped). Not GLMapping (individual mapping). |
| **policyCode** | Unique identifier for the policy. Human-readable like "GL_SALARY_BASIC". | Must be unique per tenant. |
| **policyName** | Human-readable name like "GL Mapping - Basic Salary". | For display. |
| **payElementId** | Reference to PayElement from Payroll Configuration BC. | The element being mapped. |
| **description** | Optional description of policy purpose. | Free text. |
| **isActive** | Flag indicating policy is available for use. | False after deletion. |
| **createdAt** | Timestamp when policy was created. | For audit. |
| **createdBy** | User who created the policy. | For audit. |

**Lifecycle States**:
- **Active**: isActive = true, used for GL posting
- **Inactive**: isActive = false, historical reference only

---

### GLMapping

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **GLMapping** | Individual mapping entry within a GLMappingPolicy defining GL account and allocation. | Not GLMappingPolicy (container). Not GL account (finance system). |
| **mappingId** | Unique identifier for the mapping. | System-generated UUID. |
| **glAccountCode** | General Ledger account code (e.g., "6221" for salary expense). | Must match finance system accounts. |
| **glAccountName** | GL account name for reference (e.g., "Salaries Expense"). | For display. |
| **costCenter** | Cost center code for allocation (e.g., "CC001"). | Optional. For department-level allocation. |
| **debitCredit** | Posting direction: DEBIT or CREDIT. | Earnings -> DEBIT expense. Deductions -> CREDIT liability. |
| **percentage** | Allocation percentage (0-100). | For split mappings. Must sum to 100%. |
| **description** | Optional description of mapping purpose. | Free text. |
| **effectiveStartDate** | Date when mapping becomes effective. | For version control. |
| **effectiveEndDate** | Date when mapping ends. Nullable for ongoing. | Set when mapping is replaced. |

**GL Posting Logic**:
| Element Classification | Debit Account | Credit Account |
|------------------------|---------------|----------------|
| EARNING | Expense Account | Cash/Bank |
| DEDUCTION | Cash/Bank | Liability/Expense |
| TAX | Tax Expense | Tax Liability |
| EMPLOYER_CONTRIBUTION | Employer Expense | Liability |

---

### BankTemplate

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **BankTemplate** | Template defining bank payment file format and field mappings. | Not PayElement. Not actual payment file. |
| **templateCode** | Unique identifier for the template. Human-readable like "VCB_TRANSFER". | Must be unique per tenant. |
| **templateName** | Human-readable name like "Vietcombank Transfer Template". | For display. |
| **bankCode** | Bank identifier (e.g., "VCB" for Vietcombank). | For file header. |
| **bankName** | Bank name for reference. | For display. |
| **fileFormat** | Output file format: CSV, FIXED, XML, JSON. | Determines field structure. |
| **delimiter** | Delimiter for CSV format (comma, semicolon, tab). | Only for CSV. |
| **encoding** | File encoding (UTF-8, ASCII). | For Vietnamese characters. |
| **headerRows** | Number of header rows in file. | Usually 1. |
| **footerRows** | Number of footer/summary rows. | Optional. |
| **isActive** | Flag indicating template is available for use. | False after deletion. |
| **createdAt** | Timestamp when template was created. | For audit. |
| **createdBy** | User who created the template. | For audit. |

---

### FieldMapping

| Attribute | Definition | Khac voi (Disambiguation) |
|-----------|------------|---------------------------|
| **FieldMapping** | Mapping from payroll data field to bank file field position. | Not GLMapping. Not the actual data. |
| **mappingId** | Unique identifier for the field mapping. | System-generated UUID. |
| **sourceField** | Payroll data field name (e.g., "employeeBankAccount", "paymentAmount"). | From payroll result. |
| **targetField** | Bank file field name (e.g., "AccountNo", "Amount"). | Bank file column. |
| **position** | Position/column number in output file. | 1-based index. |
| **format** | Format specification (e.g., "NUMBER", "STRING", "DATE:YYYY-MM-DD"). | For data formatting. |
| **length** | Field length for FIXED format. | Only for FIXED format. |
| **padding** | Padding character for FIXED format. | Left or right padding. |
| **defaultValue** | Default value if source is null. | Optional fallback. |
| **isRequired** | Flag indicating field is required in output. | Validation. |

---

## Value Objects

### FileFormat

| Value | Definition | Use Case |
|-------|------------|----------|
| **CSV** | Comma-separated values | Common format, flexible |
| **FIXED** | Fixed-width columns | Legacy systems |
| **XML** | XML structure | Modern systems |
| **JSON** | JSON structure | API-based transfers |

### DebitCredit

| Value | Definition |
|-------|------------|
| **DEBIT** | Increases expense account |
| **CREDIT** | Increases liability account |

---

## Events

### GLMapping Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **GLMappingCreated** | A GL mapping policy was created. | Policy with mappings. |
| **GLMappingUpdated** | GL mapping policy was modified. | Mapping changes. |
| **GLMappingDeleted** | GL mapping policy was soft-deleted. | Preserves history. |
| **GLMappingExported** | GL mappings were exported for finance system. | Integration event. |

### BankTemplate Events

| Event | Definition | Khac voi |
|-------|------------|----------|
| **BankTemplateCreated** | A bank template was created. | Template creation. |
| **BankTemplateUpdated** | Bank template was modified. | Field mapping changes. |
| **BankTemplateDeleted** | Bank template was soft-deleted. | Preserves history. |
| **BankTemplatePreviewed** | Bank template preview was generated. | Preview request. |
| **BankTemplateExported** | Bank template export was requested. | Integration event. |

---

## Commands

| Command | Actor | Description |
|---------|-------|-------------|
| **CreateGLMappingPolicy** | Finance Controller | Create GL mapping policy for element |
| **UpdateGLMappingPolicy** | Finance Controller | Update mapping policy |
| **DeleteGLMappingPolicy** | Finance Controller | Soft delete policy |
| **CreateGLMapping** | Finance Controller | Add mapping entry to policy |
| **UpdateGLMapping** | Finance Controller | Modify individual mapping |
| **DeleteGLMapping** | Finance Controller | Remove mapping entry |
| **ExportGLMappings** | Finance Controller | Export mappings for finance system |
| **CreateBankTemplate** | Payroll Admin | Create bank file template |
| **UpdateBankTemplate** | Payroll Admin | Update template attributes |
| **DeleteBankTemplate** | Payroll Admin | Soft delete template |
| **ConfigureFieldMapping** | Payroll Admin | Add field mapping to template |
| **PreviewBankTemplate** | Payroll Admin | Preview output file |
| **ExportBankTemplate** | Payroll Admin | Export template configuration |

---

## GL Mapping Examples

### Basic Salary - Single GL Account

```
GLMappingPolicy {
  policyCode: "GL_SALARY_BASIC",
  policyName: "GL Mapping - Basic Salary",
  payElementId: "SALARY_BASIC",
  isActive: true
}

GLMappings:
[
  {
    glAccountCode: "6221",
    glAccountName: "Salaries Expense",
    costCenter: null,
    debitCredit: DEBIT,
    percentage: 100,
    description: "Basic salary expense"
  }
]
```

### Bonus - Cost Center Split

```
GLMappingPolicy {
  policyCode: "GL_BONUS",
  policyName: "GL Mapping - Performance Bonus",
  payElementId: "BONUS_PERFORMANCE",
  isActive: true
}

GLMappings:
[
  {
    glAccountCode: "6223",
    glAccountName: "Bonus Expense",
    costCenter: "CC_HQ",
    debitCredit: DEBIT,
    percentage: 70,
    description: "HQ allocation"
  },
  {
    glAccountCode: "6223",
    glAccountName: "Bonus Expense",
    costCenter: "CC_BRANCH",
    debitCredit: DEBIT,
    percentage: 30,
    description: "Branch allocation"
  }
]

Validation: 70 + 30 = 100% -> PASS
```

### BHXH Employer - Liability Mapping

```
GLMappingPolicy {
  policyCode: "GL_BHXH_ER",
  policyName: "GL Mapping - BHXH Employer",
  payElementId: "BHXH_ER",
  isActive: true
}

GLMappings:
[
  {
    glAccountCode: "3321",
    glAccountName: "Social Insurance Liability",
    costCenter: null,
    debitCredit: CREDIT,
    percentage: 100,
    description: "Employer BHXH liability"
  }
]
```

---

## Bank Template Examples

### Vietcombank CSV Transfer

```
BankTemplate {
  templateCode: "VCB_TRANSFER",
  templateName: "Vietcombank Transfer Template",
  bankCode: "VCB",
  bankName: "Vietcombank",
  fileFormat: CSV,
  delimiter: "COMMA",
  encoding: "UTF-8",
  headerRows: 1,
  footerRows: 0,
  isActive: true
}

FieldMappings:
[
  { position: 1, sourceField: "employeeBankAccount", targetField: "AccountNo", format: "STRING" },
  { position: 2, sourceField: "paymentAmount", targetField: "Amount", format: "NUMBER" },
  { position: 3, sourceField: "employeeName", targetField: "BeneficiaryName", format: "STRING" },
  { position: 4, sourceField: "paymentReference", targetField: "Reference", format: "STRING" }
]
```

### Fixed-Width Format Example

```
BankTemplate {
  templateCode: "BANK_FIXED",
  templateName: "Legacy Bank Fixed Format",
  bankCode: "OTHER",
  fileFormat: FIXED,
  isActive: true
}

FieldMappings:
[
  { position: 1, sourceField: "employeeBankAccount", targetField: "AccountNo",
    format: "STRING", length: 20, padding: "LEFT_ZERO" },
  { position: 2, sourceField: "paymentAmount", targetField: "Amount",
    format: "NUMBER", length: 15, padding: "RIGHT_SPACE" },
  { position: 3, sourceField: "employeeName", targetField: "BeneficiaryName",
    format: "STRING", length: 50, padding: "RIGHT_SPACE" }
]
```

---

## Integration Points

### Inbound Integrations

| Source | Data | Purpose |
|--------|------|---------|
| Payroll Configuration | PayElement | Element to map |

### Outbound Integrations

| Target | Data | Purpose |
|--------|------|---------|
| Finance System | GLMappings export | GL posting input |
| Banking System | BankTemplate config | Payment file generation |

---

## Export Format

### GL Mapping Export (CSV)

```csv
ElementCode,GLAccountCode,AccountName,CostCenter,DebitCredit,Percentage
SALARY_BASIC,6221,Salaries Expense,,DEBIT,100
BONUS_PERFORMANCE,6223,Bonus Expense,CC_HQ,DEBIT,70
BONUS_PERFORMANCE,6223,Bonus Expense,CC_BRANCH,DEBIT,30
BHXH_ER,3321,Social Insurance Liability,,CREDIT,100
```

### Bank File Preview (CSV)

```csv
AccountNo,Amount,BeneficiaryName,Reference
1234567890,15000000,Nguyen Van A,Pay_Jan_2026
0987654321,12000000,Le Thi B,Pay_Jan_2026
```

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Domain Architect Agent