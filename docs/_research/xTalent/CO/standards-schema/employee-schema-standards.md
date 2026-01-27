---
entity: Employee
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

# Schema Standards: Employee

## 1. Summary

The Employee entity represents an individual who has an employment relationship with the organization. It is the central entity in Core HR, linking personal information, employment details, compensation, benefits, and organizational assignments.

**Confidence**: HIGH - Based on 3 major HCM vendors (Oracle, SAP, Workday)

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `PER_ALL_PEOPLE_F` | Base person record (date-effective) |
| `PER_PERIODS_OF_SERVICE` | Employment period/relationship |
| `PER_ALL_ASSIGNMENTS_F` | Job assignments (date-effective) |
| `PER_PERSON_NAMES_F` | Name components |
| `PER_NATIONAL_IDENTIFIERS` | National/Government IDs |
| `PER_ADDRESSES_F` | Address information |
| `PER_PHONES` | Phone numbers |
| `PER_EMAIL_ADDRESSES` | Email addresses |

**Key Attributes** (from REST API):
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| PersonId | Number | Y | Unique person identifier |
| PersonNumber | String | Y | Employee number |
| DateOfBirth | Date | N | Date of birth |
| CountryOfBirth | String | N | Country of birth |
| TownOfBirth | String | N | Town/City of birth |
| DateOfDeath | Date | N | Date of death |
| BloodType | String | N | Blood type |
| Correspondence Language | String | N | Preferred communication language |

**Source**: Oracle HCM Cloud REST API Documentation (Tier 1)

---

### 2.2 SAP SuccessFactors Employee Central

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `PerPerson` | Base person record |
| `PerPersonal` | Personal information (name, gender, etc.) |
| `EmpEmployment` | Employment relationship |
| `EmpJob` | Job information |
| `PerNationalId` | National identifiers |
| `PerEmail` | Email addresses |
| `PerPhone` | Phone numbers |
| `PerAddressDEFLT` | Default address |
| `PerEmergencyContacts` | Emergency contacts |

**Key Attributes**:
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| personIdExternal | String | Y | External person ID |
| userId | String | Y | User ID for login |
| firstName | String | Y | First name |
| lastName | String | Y | Last name |
| middleName | String | N | Middle name |
| gender | Enum | N | Gender (M/F/U) |
| dateOfBirth | Date | N | Date of birth |
| nationality | String | N | Nationality country code |
| maritalStatus | Enum | N | Marital status |
| initials | String | N | Name initials |

**Source**: SAP SuccessFactors API Reference (Tier 1)

---

### 2.3 Workday HCM

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `Worker` | Base worker entity (Employee or Contingent) |
| `Personal_Information_Data` | Personal/biographical info |
| `Person_Name_Data` | Name components |
| `Employment_Data` | Employment relationship |
| `Position_Data` | Position assignment |
| `National_ID_Data` | National identifiers |
| `Contact_Information_Data` | Address, phone, email |
| `Worker_Status_Data` | Employment status |

**Key Attributes** (from Get_Workers API):
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Worker_ID | String | Y | Unique worker identifier |
| Employee_ID | String | Y | Employee number |
| User_ID | String | N | System user ID |
| Legal_Name | Complex | Y | Legal name components |
| Preferred_Name | Complex | N | Preferred/display name |
| Date_of_Birth | Date | N | Date of birth |
| Gender | Enum | N | Gender reference |
| Marital_Status | Enum | N | Marital status reference |
| Nationality | Enum | N | Nationality/citizenship |
| Ethnicity | Enum | N | Ethnicity (US compliance) |
| Disability_Status | Complex | N | Disability information |

**Source**: Workday Human Resources API v44.2 (Tier 1)

---

## 3. Common Pattern Analysis

### 3.1 Universal Attributes (3/3 vendors)

| Attribute | Oracle | SAP | Workday | Recommended Type |
|-----------|--------|-----|---------|------------------|
| Person/Worker ID | ✓ | ✓ | ✓ | uuid |
| Employee Number | ✓ | ✓ | ✓ | string |
| First Name | ✓ | ✓ | ✓ | string |
| Last Name | ✓ | ✓ | ✓ | string |
| Date of Birth | ✓ | ✓ | ✓ | date |
| Gender | ✓ | ✓ | ✓ | enum |
| Nationality | ✓ | ✓ | ✓ | reference |
| Marital Status | ✓ | ✓ | ✓ | enum |
| Email Address | ✓ | ✓ | ✓ | string |
| Phone Number | ✓ | ✓ | ✓ | string |
| Address | ✓ | ✓ | ✓ | complex |
| National ID | ✓ | ✓ | ✓ | string |
| Hire Date | ✓ | ✓ | ✓ | date |
| Termination Date | ✓ | ✓ | ✓ | date |

### 3.2 Majority Attributes (2/3 vendors)

| Attribute | Oracle | SAP | Workday | Recommend |
|-----------|--------|-----|---------|-----------|
| Middle Name | ✓ | ✓ | ✓ | INCLUDE |
| Preferred Name | ✓ | - | ✓ | INCLUDE |
| Name Prefix (Title) | ✓ | ✓ | ✓ | INCLUDE |
| Name Suffix | ✓ | ✓ | ✓ | INCLUDE |
| Country of Birth | ✓ | ✓ | - | INCLUDE |
| Blood Type | ✓ | - | - | EXCLUDE |
| Religion | - | ✓ | - | OPTIONAL (VN context) |
| Ethnicity | - | - | ✓ | OPTIONAL (compliance) |
| Disability Status | ✓ | ✓ | ✓ | INCLUDE |

### 3.3 Vendor-Specific Notable

| Attribute | Vendor | Use Case |
|-----------|--------|----------|
| Blood Type | Oracle | Healthcare, emergency |
| Religion | SAP | Some country requirements |
| Military Service | SAP | Regulatory compliance |
| Veteran Status | Workday | US compliance (VETS-4212) |

### 3.4 Naming Variations

| Concept | Oracle | SAP | Workday | Canonical |
|---------|--------|-----|---------|-----------|
| Base Entity | Person | PerPerson | Worker | Employee |
| Employee ID | PersonNumber | personIdExternal | Employee_ID | employeeNumber |
| User Account | UserId | userId | User_ID | userId |
| Legal Name | DisplayName | lastName + firstName | Legal_Name | legalName |
| Gender Values | M/F | M/F/U | Male/Female | MALE/FEMALE/OTHER |

---

## 4. Canonical Schema: Employee

### 4.1 Required Attributes

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique internal identifier | Universal |
| employeeNumber | string | Business identifier (display) | Universal |
| firstName | string(100) | First/given name | Universal |
| lastName | string(100) | Last/family name | Universal |
| status | enum | Employment status | Universal |
| workerType | enum | EMPLOYEE, CONTINGENT, INTERN | Gap Analysis |
| employmentType | enum | FULL_TIME, PART_TIME, SEASONAL | Gap Analysis |
| hireDate | date | Original hire date | Universal |

### 4.2 Recommended Attributes

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| middleName | string(100) | Middle name | 3/3 vendors |
| preferredName | string(100) | Display/preferred name | Oracle, Workday |
| namePrefix | string(20) | Title (Mr., Ms., Dr.) | 3/3 vendors |
| nameSuffix | string(20) | Suffix (Jr., III, PhD) | 3/3 vendors |
| dateOfBirth | date | Date of birth | 3/3 vendors |
| gender | enum | Gender identity | 3/3 vendors |
| nationality | reference | Citizenship country | 3/3 vendors |
| maritalStatus | enum | Marital status | 3/3 vendors |
| countryOfBirth | reference | Birth country | Oracle, SAP |
| placeOfBirth | string(200) | Birth city/town | Oracle, SAP |
| userId | string(100) | System login ID | 3/3 vendors |
| originalHireDate | date | First ever hire date (re-hire tracking) | Gap Analysis |
| laborContractType | enum | INDEFINITE, DEFINITE_12M, DEFINITE_36M, SEASONAL | VN Labor Law |
| probationEndDate | date | End of probation period | VN Labor Law |
| terminationDate | date | Employment end date | Universal |
| terminationReason | reference | Reason for termination | Universal |
| personalDataConsent | boolean | GDPR/privacy consent flag | Privacy Compliance |
| consentDate | date | Date consent was given | Privacy Compliance |

### 4.3 Optional Attributes

| Attribute | Type | When to Include |
|-----------|------|-----------------|
| religion | enum | VN Labor Law compliance (optional disclosure) |
| ethnicity | enum | Diversity reporting / US compliance |
| disabilityStatus | enum | Accessibility / Compliance |
| veteranStatus | enum | US VETS compliance |
| bloodType | enum | Healthcare organizations |
| militaryService | complex | Government/Defense sectors |
| photoUrl | string | Employee directory systems |

### 4.4 Audit Attributes (Required)

| Attribute | Type | Description |
|-----------|------|-------------|
| createdAt | datetime | Record creation timestamp |
| updatedAt | datetime | Last modification timestamp |
| createdBy | reference | User who created record |
| updatedBy | reference | User who last modified |
| effectiveDate | date | When record becomes effective |
| endDate | date | When record expires (date-effective) |

---

## 5. Canonical Relationships

| Relationship | Target Entity | Cardinality | Description |
|--------------|---------------|-------------|-------------|
| primaryPosition | Position | N:1 | Current primary position assignment |
| positions | Position | N:M | All position assignments (history) |
| organization | Organization | N:1 | Business unit assignment |
| job | Job | N:1 | Job profile/role |
| manager | Employee | N:1 | Direct reporting manager |
| directReports | Employee | 1:N | Employees reporting to this person |
| legalEntity | LegalEntity | N:1 | Employing legal entity |
| workLocation | Location | N:1 | Primary work location |
| addresses | Address | 1:N | Address records |
| phoneNumbers | Phone | 1:N | Phone records |
| emailAddresses | Email | 1:N | Email records |
| nationalIds | NationalId | 1:N | National/Government IDs |
| emergencyContacts | EmergencyContact | 1:N | Emergency contact persons |
| dependents | Dependent | 1:N | Family dependents |
| bankAccounts | BankAccount | 1:N | Payment bank accounts |
| documents | Document | 1:N | Attached documents |

---

## 6. Lifecycle States

| State | Description | Source |
|-------|-------------|--------|
| PENDING | Pre-hire, awaiting onboarding | Universal |
| ACTIVE | Currently employed, working | Universal |
| ON_LEAVE | On approved leave of absence | Universal |
| SUSPENDED | Temporarily suspended | Universal |
| TERMINATED | Employment ended | Universal |
| RETIRED | Left organization via retirement | Universal |
| DECEASED | Employee has passed away | Oracle, SAP |

**State Transition Rules**:
```
PENDING → ACTIVE (on hireDate)
ACTIVE → ON_LEAVE (leave request approved)
ON_LEAVE → ACTIVE (leave ended)
ACTIVE → SUSPENDED (suspension action)
SUSPENDED → ACTIVE (reinstatement)
ACTIVE → TERMINATED (termination processed)
ACTIVE → RETIRED (retirement processed)
ACTIVE → DECEASED (death notification)
```

---

## 7. Vendor Variations

### 7.1 Oracle HCM
- **Date-Effective Model**: Uses `EFFECTIVE_START_DATE` and `EFFECTIVE_END_DATE` for historical tracking
- **Person vs Worker**: Separates Person (identity) from Worker (employment)
- **Multi-assignment**: Supports multiple concurrent assignments
- **Flexfields**: Extensive custom field support via DFF

### 7.2 SAP SuccessFactors
- **MDF-based**: Uses Metadata Framework for entity definitions
- **Picklist-driven**: Heavy use of picklists for reference values
- **Country-specific entities**: Separate entities per country (e.g., PerAddressDEFLT, PerAddressUSA)
- **Foundation Objects**: Links to foundation tables for org structure

### 7.3 Workday
- **Object-Reference Model**: Uses WID (Workday ID) extensively
- **Business Processes**: Tight integration with BP for all changes
- **Position-centric**: Position is central, not job
- **Tenant-configurable**: Many fields configurable per tenant

---

## 8. Local Adaptations (Vietnam)

### 8.1 Required by VN Labor Law
| Attribute | VN Requirement | Notes |
|-----------|----------------|-------|
| nationalIdNumber | Căn cước công dân (CCCD) | 12-digit format |
| socialInsuranceNumber | Mã số BHXH | Social insurance ID |
| taxCode | Mã số thuế cá nhân | Personal tax code |
| dateOfBirth | Ngày sinh | Required for labor compliance |
| gender | Giới tính | Required for reporting |
| ethnicity | Dân tộc | Optional, for statistics |
| religion | Tôn giáo | Optional, for statistics |
| permanentAddress | Hộ khẩu thường trú | Required for labor contracts |
| temporaryAddress | Địa chỉ tạm trú | If different from permanent |
| education | Trình độ học vấn | For labor statistics |

### 8.2 VN-Specific Enums
- **nationalIdType**: CCCD, CMND (old), Passport, Birth_Certificate
- **educationLevel**: PRIMARY, SECONDARY, HIGH_SCHOOL, VOCATIONAL, COLLEGE, BACHELOR, MASTER, DOCTORATE
- **laborContractType**: INDEFINITE, DEFINITE, SEASONAL, TRIAL

### 8.3 Recommended Extensions
| Field | Type | Description |
|-------|------|-------------|
| laborBookNumber | string | Sổ lao động ID |
| healthInsuranceNumber | string | Mã số BHYT |
| unionMember | boolean | Đoàn viên công đoàn |

> [!NOTE]
> `partyMember` field was considered but **removed** - too sensitive for commercial HCM software.

---

## 9. Sources

| Vendor | Document | URL | Tier |
|--------|----------|-----|------|
| Oracle | HCM Cloud REST API | docs.oracle.com/en/cloud/saas/human-resources/ | 1 |
| SAP | Employee Central API Reference | api.sap.com/api/ECEmployeeProfile | 1 |
| Workday | Human Resources API v44.2 | community.workday.com/productionapi/Human_Resources | 1 |
| VN Gov | Labor Code 2019 | thuvienphapluat.vn/van-ban/lao-dong-tien-luong/Bo-Luat-lao-dong-2019 | 1 |

---

## 10. Next Steps

This schema standards document should be used as input for:
1. **ontology-builder** skill to create `employee.onto.md`
2. **frs-builder** skill for Employee Management sub-module
3. **api-builder** skill for Employee CRUD APIs

---

## 11. Brainstorm & Verification Analysis

### 11.1 SCAMPER Refinements Applied

| Action | Change | Reason |
|--------|--------|--------|
| Substitute | - | No substitutions needed |
| Combine | Identity documents → NationalId entity | Better normalization |
| Adapt | Added configurable fields support | From Workday pattern |
| Modify | Gender enum → MALE/FEMALE/OTHER/PREFER_NOT_TO_SAY | Modern inclusivity |
| Put to Use | Added privacy consent fields | Analytics use case |
| Eliminate | Removed `partyMember` | Too sensitive |
| Rearrange | Grouped by: Identity, Personal, Employment, Contact, Compliance | Better organization |

### 11.2 Gap Analysis Additions

| Field | Reason | Priority |
|-------|--------|----------|
| workerType | Support contractors/interns | HIGH |
| employmentType | FT/PT distinction | HIGH |
| originalHireDate | Re-hire tracking | MEDIUM |
| laborContractType | VN Labor Law compliance | HIGH |
| probationEndDate | VN Labor Law compliance | HIGH |
| personalDataConsent | Privacy compliance | MEDIUM |

### 11.3 Verification Checklist

- [x] Completeness: All CRUD ops, audit fields, identifiers, status, relationships
- [x] Consistency: camelCase naming, consistent types, appropriate cardinality
- [x] Practicality: VN requirements, common use cases, extensible
- [x] Quality: 3x Tier 1 sources, justifications documented

---

**Document Status**: ✅ APPROVED

**Verdict**: Ready for use as input to `ontology-builder` skill.
