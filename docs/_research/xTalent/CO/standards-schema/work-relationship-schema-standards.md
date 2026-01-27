---
entity: WorkRelationship
version: "1.0.0"
status: approved
created: 2026-01-23
verified: 2026-01-23
confidence: HIGH
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: WorkRelationship

## 1. Summary

The WorkRelationship entity represents the legal and contractual engagement between a Person (Employee) and a Legal Employer. It is distinct from the Person entity and tracks the duration, type, and status of the employment or contingent work arrangement. A single person may have multiple work relationships (concurrently or sequentially).

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud
**Entity**: `PER_PERIODS_OF_SERVICE`
- **Concept**: "Period of Service" tracks the duration of employment with a Legal Employer.
- **Key Attributes**:
  - `PERIOD_OF_SERVICE_ID` (PK)
  - `PERSON_ID` (FK)
  - `LEGAL_ENTITY_ID` (FK)
  - `DATE_START` (Hire Date)
  - `ACTUAL_TERMINATION_DATE`
  - `WORKER_TYPE` (Employee, Contingent Worker, Pending Worker)
  - `PRIMARY_FLAG` (Primary relationship)

### 2.2 SAP SuccessFactors
**Entity**: `EmpEmployment`
- **Concept**: Links a User (Person) to the company, serving as the anchor for job information.
- **Key Attributes**:
  - `personIdExternal` (FK)
  - `userId` (FK)
  - `startDate`
  - `endDate`
  - `originalStartDate`
  - `isPrimary`
  - `assignmentIdExternal`

### 2.3 Workday HCM
**Entity**: `Worker` (Employment Data)
- **Concept**: Information about the worker's engagement, including hiring and termination dates.
- **Key Attributes**:
  - `Hire_Date`
  - `Original_Hire_Date`
  - `End_Employment_Date`
  - `Worker_Type` (Employee, Contingent Worker)
  - `Continuous_Service_Date`
  - `Probation_End_Date`

---

## 3. Common Pattern Analysis

### 3.1 Universal Attributes
| Attribute | Oracle | SAP | Workday | Type |
|-----------|--------|-----|---------|------|
| Start Date / Hire Date | ✓ | ✓ | ✓ | date |
| End Date / Termination Date | ✓ | ✓ | ✓ | date |
| Original Start Date | ✓ | ✓ | ✓ | date |
| Worker Type (Emp/Contingent) | ✓ | - | ✓ | enum |
| Primary Flag | ✓ | ✓ | Implicit | boolean |
| Legal Employer Link | ✓ | Implicit | Implicit | reference |

### 3.2 Canonical Terminology
| Concept | Oracle | SAP | Workday | Canonical |
|---------|--------|-----|---------|-----------|
| Start of Relationship | Date Start | Start Date | Hire Date | startDate |
| End of Relationship | Actual Termination Date | End Date | End Employment Date | terminationDate |
| Re-hire Tracking | Original Date of Hire | Original Start Date | Original Hire Date | originalHireDate |
| Worker Classification | Worker Type | Employee Class | Worker Type | workerType |

---

## 4. Canonical Schema: WorkRelationship

### 4.1 Required Attributes
| Attribute | Type | Description |
|-----------|------|-------------|
| id | uuid | Unique identifier |
| relationshipNumber | string | Human-readable ID (e.g., WR-001) |
| startDate | date | Date relationship began |
| status | enum | ACTIVE, TERMINATED, SUSPENDED, PENDING |
| workerType | enum | EMPLOYEE, CONTINGENT, INTERN |
| isPrimary | boolean | Is this the primary employment? |
| laborContractId | uuid | Current active labor contract ID |

### 4.2 Recommended Attributes
| Attribute | Type | Description |
|-----------|------|-------------|
| originalHireDate | date | First hire date (for re-hires) |
| terminationDate | date | Date relationship ended |
| terminationReason | reference | Reason for termination |
| lastWorkingDate | date | Last day of actual work |
| seniorityDate | date | Date for seniority calculation |
| probationEndDate | date | Expected end of probation |
| probationResult | enum | PASSED, FAILED, EXTENDED |
| notificationDate | date | Date termination was notified |
| projectedTerminationDate | date | Expected end (for fixed term) |
| suspensionStartDate | date | Start of suspension period |
| suspensionEndDate | date | End of suspension period |

### 4.3 Optional Attributes
| Attribute | Type | Use Case |
|-----------|------|----------|
| resignationDate | date | Date employee resigned |
| eligibleForRehire | boolean | Re-hire eligibility flag |
| regretTermination | boolean | Regret losing this employee? |
| noticePeriod | integer | Days of notice required |

---

## 5. Canonical Relationships

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| person | Person | N:1 | The individual |
| legalEmployer | LegalEntity | N:1 | The contracting company |
| primaryAssignment | Assignment | N:1 | Main job assignment |
| assignments | Assignment | 1:N | All assignments in this rel |
| laborContracts | LaborContract | 1:N | Contracts associated |

---

## 6. Local Adaptations (Vietnam)

### 6.1 VN Labor Law Requirements
- **Labor Contract Linkage**: Crucial for defining the relationship type (Indefinite vs Definite).
- **Probation Tracking**: Specific probation periods (6 days, 30 days, 60 days, 180 days) must be tracked strictly.
- **Severance**: Termination data must support severance allowance calculation (Trợ cấp thôi việc).

### 6.2 VN Specific Attributes
| Attribute | Type | Requirement |
|-----------|------|-------------|
| laborBookStatus | enum | Status of return of Labor Book (Sổ lao động) |
| socialInsuranceCloseDate | date | Date SHUI was closed (Chốt sổ BHXH) |
| terminationDecisionNumber | string | Số quyết định thôi việc |
| terminationDecisionDate | date | Ngày ký quyết định thôi việc |
| severanceAllowanceStatus | enum | PAID, NOT_PAID, NOT_ELIGIBLE |
| unemploymentInsuranceStatus | enum | RETURNED_TO_EMPLOYEE, HELD_BY_COMPANY |

---

## 7. Brainstorm & Verification Analysis

### 7.1 SCAMPER Refinements Applied
| Action | Change | Reason |
|--------|--------|--------|
| Combine | `probation` status + end date | Added `probationResult` for clear outcome tracking |
| Adapt | Added `suspension` dates | Critical for VN "Hoãn thực hiện HĐLĐ" |
| Modify | Clarified `LaborContract` cardinality | 1:N allows contract renewal without breaking relationship |
| Put to Use | `seniorityDate` | Defined use for severance/leave calculation |
| Eliminate | `regretTermination` | Moved to optional/subjective |

### 7.2 Gap Analysis (VN Context)
| Gap | Solution | Priority |
|-----|----------|----------|
| **Suspension** | Added `suspensionStartDate/EndDate` | HIGH |
| **Probation** | Added `probationResult` (Passed/Failed) | HIGH |
| **Severance** | Added `severanceAllowanceStatus` | MEDIUM |
| **Documents** | Added `terminationDecisionNumber` | HIGH |

### 7.3 Verification Checklist
- [x] **Completeness**: Covers Hire -> Probation -> Contract -> Suspension -> Termination
- [x] **Consistency**: Aligns with Employee (Person) schema pattern
- [x] **Practicality**: Matches VN usage of "Quyết định thôi việc" and "Sổ lao động"
- [x] **Quality**: Mapped from Oracle/SAP/Workday core structures

---

## 8. Next Steps
- Define `LaborContract` entity schema.
- Define `Assignment` entity schema.
