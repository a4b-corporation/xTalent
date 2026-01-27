---
entity: Job
version: "1.0.0"
status: approved
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Job (Job Profile)

## 1. Summary

The **Job** (or **Job Profile**) entity defines the generic "WHAT" of a role: the responsibilities, qualifications, and standard attributes shared by everyone with that title. It serves as a template for creating specific Positions. It is distinct from a Position, which is a specific instance of a Job in a Department.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: `Job`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Job Code | String | Y | Unique identifier |
| Name | String | Y | Job title |
| Job Family | Reference | N | Grouping |
| Benchmark | Boolean | N | Market survey benchmark |
| Management Level | Enum | N | Mgmt level |
| Valid Grade | Reference | N | Valid pay grades |
| Full/Part Time | Enum | N | Standard terms |
| Regular/Temp | Enum | N | Standard terms |

### 2.2 SAP SuccessFactors

**Entity**: `JobClassification` (Foundation Object)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| externalCode | String | Y | Job Code |
| name | String | Y | Job Title |
| employeeClass | Enum | N | Class |
| payGrade | Reference | N | Default Pay Grade |
| jobFunction | Reference | N | Functional Area |
| jobLevel | Reference | N | Career Level |
| standardWeeklyHours | Decimal | N | Std Hours |
| isFullTimeEmployee | Boolean | N | FT flag |

### 2.3 Workday

**Entity**: `Job Profile`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Job Profile ID | String | Y | Unique ID |
| Job Title | String | Y | Title |
| Job Family | Reference | N | Family grouping |
| Management Level | Reference | N | Mgmt level |
| Job Level | Reference | N | Career level |
| Pay Rate Type | Enum | N | Salary/Hourly |
| Job Description | Text | N | Rich text desc |
| Skills | Reference | N | Competencies |
| Qualifications | Reference | N | Education/Certs |

---

## 3. Canonical Schema: Job

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| code | string(50) | Unique Job Code | Universal |
| title | string(200) | Job Title | Universal |
| status | enum | Active/Inactive | Universal |
| effectiveDate | date | Start date | SAP, Oracle |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| jobFamily | reference | FK to Job Family | 3/3 vendors |
| jobLevel | reference | Career/Job Level | SAP, Workday |
| managementLevel | reference | Management Level | Oracle, Workday |
| jobDescription | text | Duties/Summary | Workday |
| payGrade | reference | Default Pay Grade | SAP |
| payRateType | enum | Salary/Hourly | Workday |
| standardHours | decimal | Std weekly hours | SAP |
| isBenchmark | boolean | Market pricing benchmark | Oracle |
| jobFunction | string | Functional Area | SAP |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| educationLevel | reference | Min education req |
| certifications | reference[] | Required certs |
| skills | reference[] | Required skills |
| flsaStatus | enum | Exempt/Non-exempt (US) |
| eeoCategory | enum | EEO Classification |

---

## 4. Key Relationships

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| jobFamily | JobFamily | N:1 | Grouping |
| positions | Position | 1:N | Instances of this job |
| validGrades | Grade | N:M | Valid pay grades |
| jobLevel | Level | N:1 | Career level |

---

## 5. Local Adaptations (Vietnam)

- **Official Titles**: May track official Vietnamese titles for labor contracts vs internal English titles.
- **Occupational Code**: Mapping to VN Occupational Classification (Danh mục nghề nghiệp).

---

*Document Status: APPROVED*
