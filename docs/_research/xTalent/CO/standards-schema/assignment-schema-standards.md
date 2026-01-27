---
entity: Assignment
version: "1.0.0"
status: approved
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Assignment (Job Information)

## 1. Summary

The **Assignment** entity (often called **Job Information** in SAP) is the central core of an employee's record. It links a **Person** to a **Job**, **Position**, **Department**, and **Legal Entity**. It is strictly **date-effective**, meaning every change (promotion, transfer, raise) creates a new historical record with a start and end date.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: `PER_ALL_ASSIGNMENTS_M`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| ASSIGNMENT_ID | Number | Y | Unique ID |
| PERSON_ID | Number | Y | Employee |
| JOB_ID | Number | N | Job |
| POSITION_ID | Number | N | Position |
| ORGANIZATION_ID | Number | Y | Department |
| ASSIGNMENT_STATUS_TYPE_ID | Number | Y | Active/Suspended |
| ASSIGNMENT_TYPE | Enum | Y | Employee/Contingent |
| EFFECTIVE_START_DATE | Date | Y | Valid from |
| EFFECTIVE_END_DATE | Date | Y | Valid to |
| ACTION_CODE | String | N | Reason (Hire, Transfer) |

### 2.2 SAP SuccessFactors

**Entity**: `EmpJob`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | String | Y | Employee ID |
| startDate | Date | Y | Effective Date |
| endDate | Date | Y | End Date |
| event | Picklist | Y | Event (Hiro, Promo) |
| jobCode | Reference | Y | Job Classification |
| position | Reference | N | Position |
| department | Reference | N | Department |
| division | Reference | N | Division |
| employeeClass | Picklist | N | Class |
| employmentType | Picklist | N | Regular/Fixed |
| managerId | String | N | Direct Manager |

### 2.3 Workday

**Entity**: `Staffing Event` / `Worker Position`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Position | Reference | Y | Occupied Position |
| Job Profile | Reference | Y | Job Profile |
| Supervisory Org | Reference | Y | Reporting Line |
| Worker | Reference | Y | Employee |
| Effective Date | Date | Y | Date of change |
| Worker Type | Enum | Y | Employee/Contingent |
| Time Type | Enum | Y | Full/Part Time |

---

## 3. Canonical Schema: Assignment

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| person | reference | FK to Person | Universal |
| status | enum | Active/Terminated/Leave | Universal |
| effectiveStartDate | date | Record start | Universal |
| effectiveEndDate | date | Record end (4712/9999) | Universal |
| isPrimary | boolean | Primary job flag | Oracle |
| company | reference | FK to Legal Entity | 3/3 vendors |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| job | reference | FK to Job/Profile | 3/3 vendors |
| position | reference | FK to Position | 3/3 vendors |
| department | reference | FK to Department | 3/3 vendors |
| location | reference | FK to Location | 3/3 vendors |
| manager | reference | FK to Manager (Assignment) | 3/3 vendors |
| contract | reference | FK to Active Contract | Best practice |
| employeeClass | enum | White/Blue collar, Exec | SAP |
| employmentType | enum | Regular/Intern/Contractor | SAP, Workday |
| fte | decimal | Full Time Equivalent (0.0-1.0)| Best practice |
| eventReason | string | Why this change happened | SAP, Oracle |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| costCenter | reference | If different from Dept |
| workSchedule | reference | Working pattern link |
| probationEndDate | date | Probation tracking |
| noticePeriod | string | Notice term |

---

## 4. Lifecycle & Events

Assignment changes are driven by **Events** (Action Codes):
- **HIRE**: New assignment created.
- **TERMINATION**: Assignment status changes to Inactive.
- **PROMOTION**: Job/Grade change.
- **TRANSFER**: Department/Location change.
- **DATA_CHANGE**: Minor update (e.g. office number).

---

## 5. Relationships

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| person | Person | N:1 | Employee |
| position | Position | N:1 | "Chair" |
| job | Job | N:1 | Role definition |
| department | Department | N:1 | Org Unit |
| manager | Assignment | N:1 | Reporting Line |

---

*Document Status: APPROVED*
