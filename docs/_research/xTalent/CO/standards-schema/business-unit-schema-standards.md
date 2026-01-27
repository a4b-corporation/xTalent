---
entity: BusinessUnit
version: "1.0.0"
status: approved
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Business Unit

## 1. Summary

The **Business Unit (BU)** is a high-level organizational entity used to partition data and manage business functions. It typically represents a distinct operational segment (e.g., "Consumer Electronics", "Southeast Asia Region") with its own Profit & Loss (P&L) responsibility. In hierarchy terms, it usually sits below the Legal Entity and above Divisions/Departments.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: `Business Unit` (Organization Structure)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| BUSINESS_UNIT_ID | Number | Y | Unique identifier |
| BU_NAME | String | Y | Business unit name |
| SHORT_CODE | String | N | Code |
| MANAGER_ID | Number | N | Head of BU |
| LOCATION_ID | Number | N | Main location |
| LEGAL_ENTITY_ID | Number | N | Default Legal Entity |
| STATUS | Enum | Y | Active/Inactive |
| SET_ID | Number | Y | Reference data set (SetID) |

**Concept**: Used to partition reference data (Jobs, Grades) and transaction data.

### 2.2 SAP SuccessFactors

**Entity**: `BusinessUnit` (Foundation Object)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| externalCode | String | Y | Unique code |
| name | String | Y | Name |
| headOfUnit | String | N | Head of unit (User) |
| effectiveStartDate | Date | Y | Start date |
| legalEntity | Reference | N | Related Legal Entity |
| status | Enum | Y | Status |

**Hierarchy**: Legal Entity -> Business Unit -> Division -> Department

### 2.3 Workday

**Entity**: `Business_Unit` (Organization Type)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Organization_Reference_ID | String | Y | Unique ID |
| Name | String | Y | Name |
| Code | String | N | Code |
| Manager | Reference | N | Manager |
| Subtype | Reference | N | BU Subtype |
| Superior_Organization | Reference | N | Parent org |

**Concept**: Workday uses "Supervisory Organizations" for the reporting hierarchy. "Business Unit" is often a custom organization type or coordinate.

---

## 3. Canonical Schema: BusinessUnit

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| code | string(50) | Business code (unique) | Universal |
| name | string(200) | Name of Business Unit | Universal |
| status | enum | Active/Inactive | Universal |
| effectiveDate | date | Effective start date | SAP, Oracle |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| shortName | string(100) | Abbreviated name | Oracle |
| manager | reference | FK to Employee (Head) | 3/3 vendors |
| legalEntity | reference | Default Legal Entity | Oracle, SAP |
| location | reference | FK to Location | Oracle |
| description | text | Description of function | Best practice |
| costCenter | reference | Default Cost Center | Best practice |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| parentBusinessUnit | reference | Nested BUs |
| currency | reference | Functional currency |
| logo | string | BU Logo URL |

---

## 4. Organizational Hierarchy Context

While schema implementation varies, the standard canonical hierarchy is:

```
Enterprise / Group
└── Legal Entity (Company)
    └── Business Unit (P&L / Segment)
        └── Division (Optional Subdivision)
            └── Department (Functional Team)
```

### Distinction
*   **Legal Entity**: Complies with laws, pays taxes (e.g., "Google Vietnam Co., Ltd.").
*   **Business Unit**: Analyzes profit/operation (e.g., "Cloud Services APAC").
*   **Department**: Groups people by function (e.g., "Solution Engineering").

---

## 5. Relationships

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| manager | Employee | N:1 | Head of Business Unit |
| legalEntity | LegalEntity | N:1 | Primary Legal Entity |
| departments | Department | 1:N | Departments in BU |
| divisions | Division | 1:N | Divisions in BU |
| locations | Location | 1:N | Locations |

---

*Document Status: APPROVED*
