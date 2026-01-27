---
entity: Position
version: "1.0.0"
status: approved
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Position

## 1. Summary

The **Position** entity represents a specific instance of a Job in the organization. It is the "chair" that an employee sits in. A Position belongs to a specific Department, reports to a specific Manager (or Parent Position), and inherits attributes from a Job Profile. Position Management enables tracking of headcounts (filled/vacant) independent of the employees.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: `Position`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Position Code | String | Y | Unique ID |
| Name | String | Y | Name |
| Job | Reference | Y | Link to Job |
| Department | Reference | Y | Link to Dept |
| Location | Reference | Y | Link to Location |
| FTE | Decimal | N | Full-Time Equivalent |
| Headcount | Integer | N | Allowed headcount |
| Hiring Status | Enum | Y | Approved/Frozen |
| Type | Enum | Y | Single/Shared/Pooled |

### 2.2 SAP SuccessFactors

**Entity**: `Position` (MDF Object)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| code | String | Y | Unique code |
| externalName | String | Y | Title |
| effectiveStartDate | Date | Y | Effective date |
| jobCode | Reference | Y | Link to Job Classification |
| department | Reference | Y | Department |
| parentPosition | Reference | N | Reporting line |
| targetFTE | Decimal | N | Target FTE |
| vacany | Boolean | N | To be hired? |
| multipleIncumbents | Boolean | N | Shared position? |

### 2.3 Workday

**Entity**: `Position`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Position ID | String | Y | Unique ID |
| Job Profile | Reference | Y | Link to Job Profile |
| Supervisory Org | Reference | Y | Who it reports to |
| Location | Reference | Y | Location |
| Worker Type | Reference | Y | Employee/Contingent |
| Time Type | Reference | Y | Full/Part Time |
| Availability Date | Date | Y | When open |
| Hiring Freeze | Boolean | N | Frozen status |

---

## 3. Canonical Schema: Position

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| code | string(50) | Position Code | Universal |
| title | string(200) | Position Title | Universal |
| job | reference | FK to Job/Profile | Universal |
| department | reference | FK to Department | Universal |
| status | enum | Active/Inactive/Frozen | Universal |
| effectiveDate | date | Start date | SAP, Oracle |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| location | reference | FK to Location | 3/3 vendors |
| parentPosition | reference | Reporting Line | SAP |
| costCenter | reference | Financial Charge | Best practice |
| fte | decimal | Full-Time Equivalent | Oracle, SAP |
| headcount | integer | Planned headcount | Oracle |
| isShared | boolean | Multiple incumbents? | Oracle, SAP |
| isVacant | boolean | Open for hire? | SAP |
| businessUnit | reference | FK to Business Unit | SAP |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| criticalSkill | boolean | Critical role flag |
| successionPlan | boolean | Succession tracking |
| validGrades | reference[] | Override Job's grades |
| probationPeriod | integer | Specific probation |

---

## 4. Key Relationships

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| job | Job | N:1 | "Is a" relationship |
| incumbents | Employee | 1:N | Who holds position |
| parentPosition | Position | N:1 | Hierarchy |
| department | Department | N:1 | Org Unit |
| successors | Employee | 1:N | Succession plan |

---

## 5. Design Pattern: Position vs Job

*   **Inheritance**: Position inherits default attributes (Title, Grade, Level) from Job.
*   **Override**: Specific Positions can override inherited values (e.g., a "Senior Dev" Position might require a specific certificate not in the generic Job).
*   **Hierarchy**: The Org Chart is built on **Positions** (Parent-Child), not Jobs.

---

*Document Status: APPROVED*
