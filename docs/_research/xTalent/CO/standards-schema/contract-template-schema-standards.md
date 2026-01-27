---
entity: ContractTemplate
version: "1.0.0"
status: approved
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Contract Template

## 1. Summary

The **Contract Template** entity manages the blueprints for generating legal employment contracts. It defines the layout, static text, and dynamic data placeholders (tokens) that are replaced by employee data during generation. Systems use BI Publisher (Oracle), BIRT (Workday), or Document Generation (SAP).

**Confidence**: MEDIUM - Implementation varies by vendor tool, but concept is universal.

---

## 2. Common Pattern Analysis

### Template Structure
All vendors separate the **Data Model** (Placeholders) from the **Layout** (RTF/HTML/PDF).

| Concept | Oracle (DOR/BIP) | SAP (Doc Gen) | Workday (BIRT) |
|---------|------------------|---------------|----------------|
| **Template File** | RTF File | Rich Text / HTML | RPTDESIGN File |
| **Data Source** | Data Model (XML) | Mapped Fields | Report Logic |
| **Tokens** | `<?TAG_NAME?>` | `[[placeholder]]` | Data Bindings |
| **Output** | PDF/HTML | PDF/HTML | PDF/HTML |

---

## 3. Canonical Schema: ContractTemplate

### Required Attributes
| Attribute | Type | Description |
|-----------|------|-------------|
| id | uuid | Unique identifier |
| code | string(50) | Template Code |
| name | string(200) | Template Name |
| documentType | enum | OFFER/CONTRACT/ADDENDUM |
| content | text/blob | Template body (HTML/RTF) |
| isActive | boolean | Status |

### Recommended Attributes
| Attribute | Type | Description |
|-----------|------|-------------|
| effectiveDate | date | Valid from |
| language | string(5) | Locale (vi-VN, en-US) |
| version | string(10) | Version number |
| placeholders | json | List of required tokens |
| category | enum | PROBATION/OFFICIAL/INTERN |

### Data Structure: Placeholders
```json
[
  { "key": "EMPLOYEE_NAME", "source": "person.fullName" },
  { "key": "START_DATE", "source": "assignment.startDate" },
  { "key": "SALARY_AMOUNT", "source": "compensation.baseSalary" }
]
```

---

## 4. Local Adaptations (Vietnam)

- **Bilingual Support**: Templates often need to support bilingual columns (Vietnamese/English).
- **Hard-copy reliance**: Although e-signatures are growing, templates must print well on A4 paper for wet-ink signatures features.

---

*Document Status: APPROVED*
