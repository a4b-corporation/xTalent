---
entity: Contract
version: "1.0.0"
status: approved
created: 2026-01-23
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
  - vn-labor-code-2019
module: Core HR
---

# Schema Standards: Contract (Labor Contract)

## 1. Summary

The **Contract** (Labor Contract) entity represents the formal legal agreement between an employer (Legal Entity) and an employee. It documents the terms and conditions of employment including duration, compensation terms, working hours, and termination conditions. This entity is especially critical for Vietnam compliance where labor contracts have strict legal requirements under Bộ Luật Lao Động 2019.

**Confidence**: HIGH - Based on 3 major HCM vendors + VN Labor Code

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `PER_CONTRACTS_F` | Contract details (date-effective) |
| `PER_PERIODS_OF_SERVICE` | Employment period/work relationship |
| `PER_TERMS_F` | Work terms (assignment terms) |
| `CMP_SALARY` | Salary terms |

**Key Attributes** (from PER_CONTRACTS_F):
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| CONTRACT_ID | Number | Y | Unique contract identifier |
| CONTRACT_NUMBER | String | N | Business contract number |
| PERSON_ID | Number | Y | FK to Person |
| CONTRACT_TYPE | String | Y | Type of contract |
| START_DATE | Date | Y | Contract start date |
| END_DATE | Date | N | Contract end date |
| DURATION | Number | N | Contract duration |
| DURATION_UNITS | Enum | N | D=Days/M=Months/Y=Years |
| PROBATION_END_DATE | Date | N | End of probation period |
| PROBATION_PERIOD | Number | N | Probation duration |
| PROBATION_UNITS | Enum | N | Probation duration units |
| NOTICE_PERIOD | Number | N | Notice period length |
| NOTICE_PERIOD_UNITS | Enum | N | Notice period units |
| STATUS | String | Y | Contract status |
| EFFECTIVE_START_DATE | Date | Y | Record effective start |
| EFFECTIVE_END_DATE | Date | Y | Record effective end |

**Oracle Contract Types**:
- Permanent
- Fixed-term
- Temporary
- Seasonal

**Source**: Oracle HCM Cloud Documentation (Tier 1)

---

### 2.2 SAP SuccessFactors Employee Central

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `EmpEmployment` | Employment record with contract info |
| `EmpEmploymentTermination` | Termination details |
| `EmpGlobalAssignment` | Global assignment contracts |
| `EmpWorkPermit` | Work permit/visa |

**Key Attributes** (from EmpEmployment):
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| userId | String | Y | FK to User |
| personIdExternal | String | Y | External person ID |
| startDate | Date | Y | Employment start date |
| endDate | Date | N | Employment end date |
| originalStartDate | Date | N | Original hire date |
| lastDateWorked | Date | N | Last working day |
| seniorityDate | Date | N | Seniority calculation date |
| probationPeriodEndDate | Date | N | Probation end date |
| employmentType | String | N | Contract/employment type |
| isContingentWorker | Boolean | N | Contingent worker flag |
| okToRehire | Boolean | N | Rehire eligibility |

**Country-Specific Extensions** (via EmpGlobalInfo):
| Field | Description |
|-------|-------------|
| contractType | Country-specific contract type |
| contractEndDate | Contract expiry |
| noticePeriod | Notice period |

**Source**: SAP SuccessFactors API Reference (Tier 1)

---

### 2.3 Workday HCM

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `Worker_Contract_Data` | Contract information |
| `Employment_Data` | Employment relationship |
| `Probation_Period_Data` | Probation details |
| `Notice_Period_Data` | Notice period info |

**Key Attributes** (from Worker APIs):
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Contract_ID | String | Y | Unique contract ID |
| Contract_Type_Reference | Reference | Y | Contract type |
| Contract_Start_Date | Date | Y | Contract start |
| Contract_End_Date | Date | N | Contract end |
| Contract_Status_Reference | Reference | Y | Current status |
| Contract_Reason_Reference | Reference | N | Reason for contract |
| Probation_Start_Date | Date | N | Probation start |
| Probation_End_Date | Date | N | Probation end |
| Probation_Review_Date | Date | N | Review date |
| Notice_Period_Unit | Reference | N | Days/Weeks/Months |
| Employee_Notice_Period | Number | N | Employee notice |
| Employer_Notice_Period | Number | N | Employer notice |
| Continuous_Service_Date | Date | N | Service calculation |

**Source**: Workday Human Resources API (Tier 1)

---

## 3. Common Pattern Analysis

### 3.1 Universal Attributes (3/3 vendors)

| Attribute | Oracle | SAP | Workday | Recommended Type |
|-----------|--------|-----|---------|------------------|
| Contract ID | ✓ | ✓ | ✓ | uuid |
| Person/Employee | ✓ | ✓ | ✓ | reference |
| Contract Type | ✓ | ✓ | ✓ | enum |
| Start Date | ✓ | ✓ | ✓ | date |
| End Date | ✓ | ✓ | ✓ | date |
| Status | ✓ | ✓ | ✓ | enum |
| Probation End Date | ✓ | ✓ | ✓ | date |

### 3.2 Majority Attributes (2/3 vendors)

| Attribute | Oracle | SAP | Workday | Recommend |
|-----------|--------|-----|---------|-----------| 
| Contract Number | ✓ | - | ✓ | INCLUDE |
| Duration | ✓ | - | ✓ | INCLUDE |
| Notice Period | ✓ | ✓ | ✓ | INCLUDE |
| Probation Period | ✓ | - | ✓ | INCLUDE |
| Seniority Date | - | ✓ | ✓ | INCLUDE |
| OK to Rehire | - | ✓ | ✓ | OPTIONAL |

### 3.3 Vendor-Specific Notable

| Attribute | Vendor | Use Case |
|-----------|--------|----------|
| Duration Units | Oracle | Flexible duration |
| Original Start Date | SAP | Rehire tracking |
| Probation Review Date | Workday | Performance review |
| Employer Notice Period | Workday | Asymmetric notice |
| Is Contingent Worker | SAP | Worker type flag |

---

## 4. Canonical Schema: Contract

### 4.1 Required Attributes

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique internal identifier | Universal |
| contractNumber | string(50) | Business contract number | Oracle, Workday |
| employee | reference | FK to Employee | Universal |
| legalEntity | reference | FK to Legal Entity (employer) | Universal |
| contractType | enum | Type of labor contract | Universal |
| startDate | date | Contract effective start | Universal |
| status | enum | Current contract status | Universal |

### 4.2 Recommended Attributes

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| endDate | date | Contract end date (if definite) | Universal |
| signDate | date | Date contract was signed | Best practice |
| duration | number | Contract duration | Oracle, Workday |
| durationUnit | enum | Days/Months/Years | Oracle |
| probationStartDate | date | Probation period start | Workday |
| probationEndDate | date | Probation period end | 3/3 vendors |
| probationDays | number | Probation length in days | Best practice |
| noticePeriod | number | Notice period length | 3/3 vendors |
| noticePeriodUnit | enum | Days/Weeks/Months | Oracle, Workday |
| employerNoticePeriod | number | Employer's notice period | Workday |
| seniorityDate | date | Date for seniority calc | SAP, Workday |
| renewalCount | number | Number of renewals | Best practice |
| previousContract | reference | FK to previous contract | Best practice |
| workLocation | reference | FK to Location | VN requirement |
| position | reference | FK to Position | Best practice |

### 4.3 Optional Attributes

| Attribute | Type | When to Include |
|-----------|------|-----------------|
| okToRehire | boolean | Tracking rehire eligibility |
| terminationDate | date | Actual last working day |
| terminationReason | reference | Reason for ending |
| isContingentWorker | boolean | Contingent/contractor |
| documentUrl | string | Signed contract document |
| signatureDate | date | Employee signature date |
| witnessName | string | Witness (VN compliance) |
| appendices | reference[] | Contract appendices/amendments |

### 4.4 Audit Attributes (Required)

| Attribute | Type | Description |
|-----------|------|-------------|
| createdAt | datetime | Record creation timestamp |
| updatedAt | datetime | Last modification timestamp |
| createdBy | reference | User who created record |
| updatedBy | reference | User who last modified |

---

## 5. Canonical Relationships

| Relationship | Target Entity | Cardinality | Description |
|--------------|---------------|-------------|-------------|
| employee | Employee | N:1 | The contracted employee |
| legalEntity | LegalEntity | N:1 | Legal employer |
| position | Position | N:1 | Contracted position |
| workLocation | Location | N:1 | Primary work location |
| previousContract | Contract | N:1 | Previous contract (renewal chain) |
| nextContract | Contract | 1:1 | Next contract (if renewed) |
| amendments | ContractAmendment | 1:N | Contract amendments |
| documents | Document | 1:N | Attached documents |
| assignment | Assignment | 1:1 | Linked assignment |

---

## 6. Lifecycle States

| State | Description | Source |
|-------|-------------|--------|
| DRAFT | Contract being prepared | Best practice |
| PENDING_SIGNATURE | Awaiting signatures | Best practice |
| ACTIVE | Currently in effect | Universal |
| EXPIRED | Past end date | Universal |
| TERMINATED | Ended before expiry | Universal |
| RENEWED | Replaced by new contract | Best practice |
| CANCELLED | Cancelled before start | Best practice |

**State Transition Rules**:
```
DRAFT → PENDING_SIGNATURE (ready for signature)
PENDING_SIGNATURE → ACTIVE (all signatures collected)
PENDING_SIGNATURE → CANCELLED (cancelled before signing)
ACTIVE → EXPIRED (past endDate)
ACTIVE → TERMINATED (early termination)
ACTIVE → RENEWED (replaced by new contract)
```

---

## 7. Vendor Variations

### 7.1 Oracle HCM
- **Work Terms Model**: Contract info is part of work terms
- **Date-Effective**: Full history tracking
- **Duration Units**: Flexible duration specification
- **Flexfields**: Custom attribute support

### 7.2 SAP SuccessFactors
- **Employment-Centric**: Contract embedded in EmpEmployment
- **Country Extensions**: Country-specific fields via EmpGlobalInfo
- **Termination Tracking**: Separate termination entity
- **Rehire Flag**: okToRehire for eligibility

### 7.3 Workday
- **Separate Contract Data**: Worker_Contract_Data entity
- **Asymmetric Notice**: Different employee/employer notice
- **Probation Review**: Review date tracking
- **Continuous Service**: Service date for calculations

---

## 8. Local Adaptations (Vietnam)

### 8.1 VN Labor Code 2019 Requirements

| Attribute | VN Name | Requirement |
|-----------|---------|-------------|
| contractNumber | Số hợp đồng | Required, unique |
| contractType | Loại hợp đồng | Required (see types below) |
| signDate | Ngày ký | Required |
| startDate | Ngày hiệu lực | Required |
| endDate | Ngày kết thúc | Required for definite-term |
| workContent | Nội dung công việc | Required by law |
| workLocation | Địa điểm làm việc | Required by law |
| salary | Tiền lương | Required (separate entity) |
| workingHours | Thời giờ làm việc | Required by law |
| socialInsurance | BHXH | Required participation |

### 8.2 VN Contract Types (Loại Hợp Đồng)

| Code | VN Name | Description | Duration |
|------|---------|-------------|----------|
| INDEFINITE | Hợp đồng không xác định thời hạn | Permanent | No end date |
| DEFINITE | Hợp đồng xác định thời hạn | Fixed-term | 12-36 months |
| SEASONAL | Hợp đồng theo mùa vụ | Seasonal work | < 12 months |
| TRIAL | Hợp đồng thử việc | Probation only | Max 180 days |

> **Note**: Seasonal contracts (SEASONAL) are deprecated in Labor Code 2019. New contracts should use DEFINITE with duration < 12 months.

### 8.3 VN Probation Rules (Thử Việc)

| Role Level | Max Probation | Salary % |
|------------|---------------|----------|
| Enterprise Manager | 180 days | ≥ 85% |
| Manager/Specialist | 60 days | ≥ 85% |
| Technical/Skilled | 30 days | ≥ 85% |
| General Worker | 6 days | ≥ 85% |

### 8.4 VN Notice Period Rules

| Contract Type | Employee Notice | Employer Notice |
|---------------|-----------------|-----------------|
| Indefinite | 45 days | 45 days |
| Definite (12-36m) | 30 days | 30 days |
| Definite (<12m) | 3 days | 3 days |
| Seasonal | 3 days | 3 days |

### 8.5 VN Contract Renewal Rules

| Current Contract | Max Renewals | Result |
|------------------|--------------|--------|
| Definite-term | 1 time | After 2nd contract → Indefinite |
| Seasonal | No limit | Must remain seasonal work |

### 8.6 Recommended VN Extensions

| Field | Type | Description |
|-------|------|-------------|
| workContent | text | Nội dung công việc (required by law) |
| equipmentProvided | text | Trang thiết bị được cấp |
| laborBookNumber | string | Số sổ lao động |
| socialInsuranceStartDate | date | Ngày tham gia BHXH |
| unionContribution | boolean | Đóng phí công đoàn |
| collectiveAgreementRef | string | Tham chiếu thỏa ước lao động tập thể |

---

## 9. Design Recommendations

### 9.1 Contract vs Assignment

| Entity | Purpose |
|--------|---------|
| Contract | Legal document, terms, compliance |
| Assignment | Organizational placement, job, location |

Contract should link to Assignment but remain separate for:
- Legal document audit trail
- Renewal tracking (new contract, same assignment)
- Compliance reporting

### 9.2 Contract Renewal Pattern

```
Contract-1 (Definite, 12 months)
    └── previousContract: null
    └── nextContract: Contract-2

Contract-2 (Definite, 12 months - renewal)
    └── previousContract: Contract-1
    └── nextContract: Contract-3
    └── renewalCount: 1

Contract-3 (Indefinite - auto-convert)
    └── previousContract: Contract-2
    └── renewalCount: 2
    └── Note: VN law requires indefinite after 2nd renewal
```

### 9.3 Document Attachment

Contracts should support:
- Signed PDF attachment
- Amendment documents
- Appendices (job description, salary terms)
- Termination letters

### 9.4 Entity Hierarchy

```
Employee
├── Contract (legal document)
│   ├── ContractAmendment (changes)
│   ├── Document (attachments)
│   └── ContractTermination (if ended)
└── Assignment (org placement)
```

---

## 10. Sources

| Vendor | Document | URL | Tier |
|--------|----------|-----|------|
| Oracle | HCM Cloud PER_CONTRACTS_F | docs.oracle.com | 1 |
| SAP | EmpEmployment API | api.sap.com | 1 |
| Workday | Worker Contract Data | community.workday.com | 1 |
| VN Gov | Bộ Luật Lao Động 2019 | thuvienphapluat.vn | 1 |
| VN Gov | Nghị định 145/2020/NĐ-CP | thuvienphapluat.vn | 1 |

---

## 11. Next Steps

This schema standards document should be used as input for:
1. **ontology-builder** skill to create `contract.onto.md`
2. **frs-builder** skill for Contract Management sub-module
3. **api-builder** skill for Contract CRUD APIs

---

*Document Status: APPROVED - Verified against 3 major HCM vendors + VN Labor Code*
