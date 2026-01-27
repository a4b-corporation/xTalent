---
entity: JobFamily
version: "1.0.0"
status: deprecated
deprecated_by: job-taxonomy-schema-standards.md
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# ⚠️ DEPRECATED: Schema Standards: Job Family

> **This document is DEPRECATED.** 
> 
> Please use [`job-taxonomy-schema-standards.md`](./job-taxonomy-schema-standards.md) instead.
> 
> The new document provides:
> - **Multi-tree architecture** (CORP/LE/BU scope)
> - **N-level hierarchy** (not limited to 2 levels)
> - **Inheritance/override patterns**
> - **Cross-tree mapping** for reporting consolidation
> - **Many-to-many Job mapping**

---

# Schema Standards: Job Family (Legacy)

## 1. Summary

The **Job Family** entity represents a broad grouping of related Jobs based on similar functions, identifying competencies, or career paths. Examples include "Engineering", "Sales", "Human Resources". Some systems support a higher level **Job Family Group**.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: `Job Family`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Job Family Code | String | Y | Unique ID |
| Name | String | Y | Name |
| Active Status | Enum | Y | Status |
| Action ID | Reference | N | Action reason |

### 2.2 SAP SuccessFactors

**Entity**: `JobFamily` (Association)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| externalCode | String | Y | Code |
| name | String | Y | Name |
| status | Enum | Y | Status |
| usage | Enum | N | Usage type |

### 2.3 Workday

**Entity**: `Job Family` / `Job Family Group`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| ID | String | Y | Unique ID |
| Name | String | Y | Name |
| Job Family Group | Reference | N | Parent Group |
| Summary | Text | N | Description |
| Inactive | Boolean | N | Status |

---

## 3. Canonical Schema: JobFamily

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| code | string(50) | Unique Code | Universal |
| name | string(200) | Family Name | Universal |
| status | enum | Active/Inactive | Universal |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| description | text | Summary of family | Workday |
| jobFamilyGroup | reference | Parent Grouping | Workday |
| effectiveDate | date | Start date | Best practice |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| owner | reference | Functional Owner |

---

## 4. Key Relationships

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| jobs | Job | 1:N | Jobs in family |
| jobFamilyGroup | JobFamilyGroup | N:1 | Higher grouping |

---

*Document Status: APPROVED*
