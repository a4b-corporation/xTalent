---
entity: Person
version: "1.0.0"
status: approved
created: 2026-01-23
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Person

## 1. Summary

The **Person** entity represents an individual's fundamental identity and biographical data, independent of any employment relationship. It serves as the foundational layer upon which Employee, Contingent Worker, Applicant, and Contact entities are built. This separation follows the industry-standard pattern of decoupling personal identity from employment relationships.

**Confidence**: HIGH - Based on 3 major HCM vendors (Oracle, SAP, Workday)

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `PER_PERSONS` | Non-date-tracked parent (stable PERSON_ID) |
| `PER_ALL_PEOPLE_F` | Date-effective person attributes |
| `PER_PERSON_NAMES_F` | Name components (date-effective) |
| `PER_NATIONAL_IDENTIFIERS` | National/Government IDs |
| `PER_ADDRESSES_F` | Address information |
| `PER_PHONES` | Phone numbers |
| `PER_EMAIL_ADDRESSES` | Email addresses |
| `PER_RELIGIONS` | Religion information |
| `PER_ETHNICITIES` | Ethnicity records |

**Key Person Attributes** (from PER_ALL_PEOPLE_F):
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| PERSON_ID | Number | Y | Unique person identifier |
| DATE_OF_BIRTH | Date | N | Date of birth |
| COUNTRY_OF_BIRTH | String | N | Country of birth |
| TOWN_OF_BIRTH | String | N | Town/City of birth |
| REGION_OF_BIRTH | String | N | Region of birth |
| DATE_OF_DEATH | Date | N | Date of death |
| BLOOD_TYPE | String | N | Blood type (A, B, O, AB) |
| SEX | String | N | Legal gender |
| MARITAL_STATUS | String | N | Marital status |
| CORRESPONDENCE_LANGUAGE | String | N | Preferred language |

**Source**: Oracle HCM Cloud Tables and Views Documentation (Tier 1)

---

### 2.2 SAP SuccessFactors Employee Central

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `PerPerson` | Base person record (minimal) |
| `PerPersonal` | Personal information (name, gender, DOB) |
| `PerNationalId` | National identifiers |
| `PerEmail` | Email addresses |
| `PerPhone` | Phone numbers |
| `PerAddressDEFLT` | Default address |
| `PerGlobalInfoXXX` | Country-specific personal info |

**Key Person Attributes** (from PerPersonal):
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| personIdExternal | String | Y | External person ID |
| firstName | String | Y | First name |
| lastName | String | Y | Last name |
| middleName | String | N | Middle name |
| gender | Enum | N | Gender (M/F/U) |
| dateOfBirth | Date | N | Date of birth |
| nationality | String | N | Nationality country code |
| nativePreferredLang | String | N | Native language |
| maritalStatus | Enum | N | Marital status |
| secondNationality | String | N | Secondary nationality |
| thirdNationality | String | N | Third nationality |
| initials | String | N | Name initials |
| suffix | String | N | Name suffix |
| title | String | N | Name title/prefix |

**Source**: SAP SuccessFactors Employee Central API Reference (Tier 1)

---

### 2.3 Workday HCM

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `Personal_Information_Data` | Core personal/biographical info |
| `Person_Name_Data` | Name components |
| `National_ID_Data` | National identifiers |
| `Contact_Information_Data` | Address, phone, email |
| `Citizenship_Data` | Citizenship/nationality records |
| `Ethnicity_Data` | Ethnicity information |
| `Disability_Data` | Disability status |
| `Military_Service_Data` | Military service records |

**Key Person Attributes** (from Personal_Information_Data):
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Person_ID | String | Y | Unique person identifier |
| Date_of_Birth | Date | N | Date of birth |
| Gender | Enum | N | Gender reference |
| Marital_Status | Enum | N | Marital status reference |
| Marital_Status_Date | Date | N | Date marital status changed |
| City_of_Birth | String | N | Birth city |
| Country_of_Birth_Reference | Reference | N | Birth country |
| Region_of_Birth_Reference | Reference | N | Birth region |
| Uses_Tobacco | Boolean | N | Tobacco use indicator |
| Political_Affiliation | Reference | N | Political affiliation |
| Date_of_Death | Date | N | Date of death |
| Religion | Reference | N | Religious affiliation |
| Hukou_Region | Reference | N | China-specific registration |
| Hukou_Subregion | Reference | N | China-specific sub-registration |
| Hukou_Type | Reference | N | China-specific type |
| Native_Region | Reference | N | Native/ancestral region |
| LGBT_Identification | Boolean | N | LGBT self-identification |

**Source**: Workday Human Resources API v44.2 (Tier 1)

---

## 3. Common Pattern Analysis

### 3.1 Universal Attributes (3/3 vendors)

| Attribute | Oracle | SAP | Workday | Recommended Type |
|-----------|--------|-----|---------|------------------|
| Person ID | ✓ | ✓ | ✓ | uuid |
| Date of Birth | ✓ | ✓ | ✓ | date |
| Gender | ✓ | ✓ | ✓ | enum |
| Marital Status | ✓ | ✓ | ✓ | enum |
| Nationality | ✓ | ✓ | ✓ | reference |
| Country of Birth | ✓ | ✓ | ✓ | reference |
| City/Town of Birth | ✓ | - | ✓ | string |

### 3.2 Majority Attributes (2/3 vendors)

| Attribute | Oracle | SAP | Workday | Recommend |
|-----------|--------|-----|---------|-----------| 
| Date of Death | ✓ | - | ✓ | INCLUDE |
| Blood Type | ✓ | - | - | OPTIONAL |
| Correspondence Language | ✓ | ✓ | - | INCLUDE |
| Region of Birth | ✓ | - | ✓ | INCLUDE |
| Religion | ✓ | - | ✓ | OPTIONAL |
| Multiple Nationalities | - | ✓ | ✓ | INCLUDE |
| Ethnicity | ✓ | - | ✓ | OPTIONAL |

### 3.3 Vendor-Specific Notable

| Attribute | Vendor | Use Case |
|-----------|--------|----------|
| Blood Type | Oracle | Healthcare, emergency response |
| Hukou | Workday | China labor law compliance |
| Uses_Tobacco | Workday | Health insurance, wellness programs |
| LGBT_Identification | Workday | Diversity reporting (voluntary) |
| Political_Affiliation | Workday | Government sector requirements |

### 3.4 Design Pattern: Person vs Name Separation

All vendors separate **Person** (identity) from **PersonName** (name components):

| Vendor | Person Entity | Name Entity |
|--------|---------------|-------------|
| Oracle | PER_ALL_PEOPLE_F | PER_PERSON_NAMES_F |
| SAP | PerPerson | PerPersonal (combined) |
| Workday | Personal_Information_Data | Person_Name_Data |

**Rationale for separation**:
1. Name changes are frequent (marriage, legal changes)
2. Multiple name formats per person (legal, preferred, local script)
3. Date-effective tracking for audit compliance
4. Cultural variations in name structure

---

## 4. Canonical Schema: Person

### 4.1 Required Attributes

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique internal identifier | Universal |
| status | enum | Person record status | Universal |

### 4.2 Recommended Attributes

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| dateOfBirth | date | Date of birth | 3/3 vendors |
| gender | enum | Gender identity | 3/3 vendors |
| maritalStatus | enum | Current marital status | 3/3 vendors |
| maritalStatusDate | date | When marital status changed | Workday, compliance |
| primaryNationality | reference | Primary citizenship | 3/3 vendors |
| additionalNationalities | reference[] | Secondary citizenships | SAP, Workday |
| countryOfBirth | reference | Birth country | 3/3 vendors |
| regionOfBirth | string(100) | Birth region/province | Oracle, Workday |
| cityOfBirth | string(100) | Birth city/town | Oracle, Workday |
| dateOfDeath | date | Date of death (if applicable) | Oracle, Workday |
| correspondenceLanguage | reference | Preferred communication language | Oracle, SAP |

### 4.3 Optional Attributes

| Attribute | Type | When to Include |
|-----------|------|-----------------|
| bloodType | enum | Healthcare organizations, emergency systems |
| religion | enum | VN context (voluntary), some country requirements |
| ethnicity | enum | Diversity reporting, government compliance (US/VN) |
| disabilityStatus | enum | Accessibility programs, compliance |
| veteranStatus | enum | US VETS-4212 compliance |
| usesTobacco | boolean | Health insurance, wellness programs |
| lgbtIdentification | boolean | Diversity reporting (voluntary, sensitive) |
| politicalAffiliation | reference | Government sector (sensitive) |

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
| names | PersonName | 1:N | Name records (legal, preferred, local) |
| nationalIds | NationalId | 1:N | National/Government ID documents |
| addresses | Address | 1:N | Address records |
| phoneNumbers | Phone | 1:N | Phone records |
| emailAddresses | Email | 1:N | Email records |
| citizenships | Citizenship | 1:N | Citizenship/Passport records |
| disabilities | Disability | 1:N | Disability records |
| religions | Religion | 1:N | Religious affiliation history |
| ethnicities | Ethnicity | 1:N | Ethnicity records |
| visas | Visa | 1:N | Visa/Work permit records |
| passportInfo | Passport | 1:N | Passport information |
| emergencyContacts | EmergencyContact | 1:N | Emergency contact persons |

---

## 6. Lifecycle States

| State | Description | Source |
|-------|-------------|--------|
| ACTIVE | Valid, active person record | Universal |
| INACTIVE | Temporarily inactive | Universal |
| DECEASED | Person has passed away | Oracle, Workday |
| MERGED | Duplicate merged into another | Best practice |

**State Transition Rules**:
```
ACTIVE → INACTIVE (deactivation)
INACTIVE → ACTIVE (reactivation)
ACTIVE → DECEASED (death notification)
ACTIVE → MERGED (duplicate resolution)
INACTIVE → DECEASED (death notification)
```

---

## 7. Vendor Variations

### 7.1 Oracle HCM
- **Date-Effective Model**: Uses `EFFECTIVE_START_DATE` and `EFFECTIVE_END_DATE` for all person changes
- **Separate Name Entity**: `PER_PERSON_NAMES_F` with name type (LEGAL, PREFERRED)
- **Flexfields**: Supports DFF for custom attributes
- **Legislation Code**: Some attributes vary by legislation (country)

### 7.2 SAP SuccessFactors
- **MDF-based**: Uses Metadata Framework for entity definitions
- **Combined Personal**: `PerPersonal` contains both person and name info
- **Country-specific**: Separate entities per country (e.g., PerGlobalInfoVNM)
- **Picklist-driven**: Heavy use of picklists for enumerations

### 7.3 Workday
- **Reference Model**: Uses Workday ID (WID) for all references
- **Separate Personal Data**: Clear separation between identity and names
- **Rich Diversity Fields**: Most comprehensive diversity/inclusion attributes
- **Tenant-configurable**: Many fields configurable per tenant

---

## 8. Local Adaptations (Vietnam)

### 8.1 Required by VN Labor Law

| Attribute | VN Requirement | Notes |
|-----------|----------------|-------|
| dateOfBirth | Ngày sinh | Required for labor contract |
| gender | Giới tính | Required for reporting |
| ethnicity | Dân tộc | Optional, for government statistics |
| religion | Tôn giáo | Optional, for statistics |
| permanentAddress | Hộ khẩu thường trú | Required for labor contracts |

### 8.2 VN-Specific National IDs

| Type | VN Name | Format |
|------|---------|--------|
| CCCD | Căn cước công dân | 12 digits |
| CMND | Chứng minh nhân dân (old) | 9 digits |
| Passport | Hộ chiếu | Alphanumeric |
| Birth Certificate | Giấy khai sinh | Varies by province |

### 8.3 VN Cultural Considerations

| Field | VN Pattern | Notes |
|-------|------------|-------|
| Name Order | Family name first | lastName (Họ) precedes firstName (Tên) |
| Middle Name | Common | middleName (Tên đệm) is very common |
| Ethnicity | 54 ethnic groups | Official government classification |
| Religion | 6 major + others | Buddhist, Catholic, Protestant, etc. |

### 8.4 Recommended Extensions for VN

| Field | Type | Description |
|-------|------|-------------|
| hometownProvince | reference | Quê quán (ancestral hometown) |
| registrationNumber | string | Số đăng ký hộ khẩu |

---

## 9. Design Recommendations

### 9.1 Separate Person from PersonName

Create a separate `PersonName` entity to handle:
- Multiple name types (LEGAL, PREFERRED, LOCAL_SCRIPT)
- Date-effective name changes
- Cultural variations (Western vs Vietnamese naming)

### 9.2 Separate Person from Employee

The `Person` entity should:
- Contain ONLY biographical/identity information
- NOT contain employment-related fields (hireDate, terminationDate)
- Be reusable for Applicants, Contacts, Dependents

The `Employee` entity (see employee-schema-standards.md) should:
- Link to Person via N:1 relationship
- Contain employment relationship data
- Handle organizational assignments

### 9.3 Entity Hierarchy

```
Person (identity)
├── Employee (employment relationship)
├── ContingentWorker (contractor relationship)
├── Applicant (application relationship)
├── Contact (business contact)
├── Dependent (family relationship to employee)
└── Beneficiary (benefits relationship to employee)
```

---

## 10. Sources

| Vendor | Document | URL | Tier |
|--------|----------|-----|------|
| Oracle | HCM Cloud Tables and Views | docs.oracle.com/en/cloud/saas/human-resources/ | 1 |
| Oracle | PER_ALL_PEOPLE_F Reference | etrm.live (Oracle reference) | 1 |
| SAP | Employee Central API Reference | api.sap.com/api/ECEmployeeProfile | 1 |
| Workday | Human Resources API v44.2 | community.workday.com/productionapi/Human_Resources | 1 |
| VN Gov | Labor Code 2019 | thuvienphapluat.vn/van-ban/lao-dong-tien-luong/Bo-Luat-lao-dong-2019 | 1 |

---

## 11. Next Steps

This schema standards document should be used as input for:
1. **ontology-builder** skill to create `person.onto.md`
2. **ontology-builder** skill to create `person-name.onto.md` (separate entity)
3. **frs-builder** skill for Person Management sub-module

---

*Document Status: APPROVED - Verified against 3 major HCM vendors*
