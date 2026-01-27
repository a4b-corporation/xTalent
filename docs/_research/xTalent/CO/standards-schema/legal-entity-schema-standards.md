---
entity: LegalEntity
version: "1.0.0"
status: approved
created: 2026-01-23
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Legal Entity

## 1. Summary

The **Legal Entity** represents a legally recognized organization with rights and responsibilities under commercial law, established through registration with appropriate governmental authorities. It serves as the employer entity for payroll, tax reporting, and regulatory compliance purposes. This entity is fundamental for multi-company HCM implementations.

**Confidence**: HIGH - Based on 3 major HCM vendors (Oracle, SAP, Workday)

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `XLE_ENTITY_PROFILES` | Core legal entity profile |
| `HR_LEGAL_ENTITIES` | HCM legal entity view |
| `HR_ORG_UNIT_CLASSIFICATIONS_F` | Organization classifications |
| `XLE_REGISTRATION_ORGS` | Registration information |
| `XLE_JURISDICTIONS_VL` | Jurisdiction details |

**Key Attributes** (from Legal Entity Configurator):
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| LEGAL_ENTITY_ID | Number | Y | Unique identifier |
| NAME | String | Y | Legal entity name |
| LEGAL_ENTITY_IDENTIFIER | String | Y | Registration number |
| COUNTRY_CODE | String | Y | Country of registration |
| LEGAL_FORM | String | N | Type of legal entity (Corp, LLC) |
| INCORPORATION_DATE | Date | N | Date of incorporation |
| ACTIVITY_CODE | String | N | Industry classification |
| PLACE_OF_REGISTRATION | String | N | Registration authority |
| EFFECTIVE_START_DATE | Date | Y | When record becomes effective |
| EFFECTIVE_END_DATE | Date | Y | When record expires |

**Oracle Legal Entity Classifications**:
- **Legal Employer**: Directly employs workers (HR)
- **Payroll Statutory Unit (PSU)**: Handles payroll taxes
- **Tax Reporting Unit (TRU)**: Groups for tax reporting

**Source**: Oracle HCM Cloud Implementation Guide (Tier 1)

---

### 2.2 SAP SuccessFactors Employee Central

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `FOCompany` | Foundation Object for company |
| `FOLegalEntityLocal` | Country-specific legal entity |
| `FOCorporateAddressDeflt` | Corporate address |
| `PicklistValue` | Legal form picklist |

**Key Attributes** (from FOCompany):
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| externalCode | String | Y | Unique company code |
| name | String | Y | Company name |
| name_defaultValue | String | Y | Default language name |
| country | String | Y | Country code |
| defaultCurrency | String | N | Default currency |
| status | Enum | Y | Active/Inactive |
| startDate | Date | Y | Effective start date |
| endDate | Date | N | Effective end date |
| mdfSystemRecordStatus | Enum | Y | Record status |

**Additional Local Fields** (FOLegalEntityLocal):
| Attribute | Type | Description |
|-----------|------|-------------|
| taxId | String | Tax identification number |
| registrationNumber | String | Business registration number |
| legalForm | Picklist | Legal entity type |

**Source**: SAP SuccessFactors Employee Central API Reference (Tier 1)

---

### 2.3 Workday HCM

**Entity Structure**:
| Entity | Description |
|--------|-------------|
| `Company` | Core legal entity organization |
| `Company_Reference_ID` | External identifiers |
| `Organization_Data` | Parent organization data |
| `Tax_ID_Data` | Tax identification |
| `Address_Data` | Address information |

**Key Attributes** (from Company API):
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Company_ID | String | Y | Unique company identifier |
| Company_Reference_ID | String | Y | External reference ID |
| Company_Name | String | Y | Legal name |
| Organization_Subtype | Reference | Y | Company type reference |
| Country_Reference | Reference | Y | Country of incorporation |
| Currency_Reference | Reference | N | Default currency |
| Availability_Date | Date | Y | When organization becomes available |
| Include_Company_in_Name | Boolean | N | Include in display name |
| Inactive | Boolean | Y | Active/Inactive status |

**Tax & Registration**:
| Attribute | Type | Description |
|-----------|------|-------------|
| Tax_ID | String | Primary tax ID |
| Federal_Tax_ID | String | Federal tax identifier |
| State_Tax_ID | String | State/Province tax ID |
| Registration_Number | String | Business registration |

**Source**: Workday Human Resources API v44.2 (Tier 1)

---

## 3. Common Pattern Analysis

### 3.1 Universal Attributes (3/3 vendors)

| Attribute | Oracle | SAP | Workday | Recommended Type |
|-----------|--------|-----|---------|------------------|
| ID | ✓ | ✓ | ✓ | uuid |
| Code | ✓ | ✓ | ✓ | string |
| Name | ✓ | ✓ | ✓ | string |
| Country | ✓ | ✓ | ✓ | reference |
| Status | ✓ | ✓ | ✓ | enum |
| Effective Date | ✓ | ✓ | ✓ | date |
| Registration Number | ✓ | ✓ | ✓ | string |
| Tax ID | ✓ | ✓ | ✓ | string |

### 3.2 Majority Attributes (2/3 vendors)

| Attribute | Oracle | SAP | Workday | Recommend |
|-----------|--------|-----|---------|-----------| 
| Legal Form/Type | ✓ | ✓ | ✓ | INCLUDE |
| Default Currency | - | ✓ | ✓ | INCLUDE |
| Incorporation Date | ✓ | - | ✓ | INCLUDE |
| End Date | ✓ | ✓ | - | INCLUDE |
| Industry Code | ✓ | - | ✓ | OPTIONAL |

### 3.3 Vendor-Specific Notable

| Attribute | Vendor | Use Case |
|-----------|--------|----------|
| PSU Classification | Oracle | Payroll statutory unit |
| TRU Classification | Oracle | Tax reporting groups |
| Legislative Data Group | Oracle | Country-specific payroll |
| Federal/State Tax ID | Workday | US multi-state compliance |
| FOLegalEntityLocal | SAP | Country-specific fields |

### 3.4 Design Pattern: Legal Entity vs Organization

All vendors distinguish:
| Concept | Legal Entity | Organization |
|---------|--------------|--------------|
| Purpose | Legal/Tax reporting | Management hierarchy |
| Registration | Government registered | Internal structure |
| Employees | Legal employer | Reporting structure |
| Examples | Company Ltd, Corp | Department, Division |

---

## 4. Canonical Schema: Legal Entity

### 4.1 Required Attributes

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique internal identifier | Universal |
| code | string(50) | Business code (unique) | Universal |
| name | string(200) | Legal registered name | Universal |
| country | reference | Country of registration | Universal |
| status | enum | Entity status | Universal |
| effectiveDate | date | When entity becomes active | Universal |

### 4.2 Recommended Attributes

| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| shortName | string(50) | Short/display name | Best practice |
| legalForm | enum | Legal structure type | 3/3 vendors |
| registrationNumber | string(50) | Business registration ID | 3/3 vendors |
| taxId | string(50) | Primary tax identifier | 3/3 vendors |
| incorporationDate | date | Date of incorporation | Oracle, Workday |
| endDate | date | When entity becomes inactive | Oracle, SAP |
| defaultCurrency | reference | Default operating currency | SAP, Workday |
| registrationAuthority | string(200) | Registering government body | Oracle |
| industryCode | string(20) | Industry/activity classification | Oracle, Workday |

### 4.3 Optional Attributes

| Attribute | Type | When to Include |
|-----------|------|-----------------|
| federalTaxId | string(50) | US or federal/state tax systems |
| stateTaxIds | complex | Multi-state tax compliance |
| socialInsuranceNumber | string(50) | Social insurance registration |
| vatNumber | string(50) | VAT/GST registered entities |
| isPayrollStatutoryUnit | boolean | Payroll tax responsibility |
| isLegalEmployer | boolean | Directly employs workers |
| legislativeDataGroupId | reference | Country-specific payroll config |
| parentLegalEntity | reference | Legal entity hierarchy |

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
| country | Country | N:1 | Country of registration |
| defaultCurrency | Currency | N:1 | Default currency |
| parent | LegalEntity | N:1 | Parent legal entity (if hierarchy) |
| children | LegalEntity | 1:N | Child legal entities |
| addresses | Address | 1:N | Legal/business addresses |
| registrations | LegalRegistration | 1:N | Registration documents |
| taxIdentifiers | TaxIdentifier | 1:N | Tax ID records |
| bankAccounts | BankAccount | 1:N | Company bank accounts |
| employees | Employee | 1:N | Employees of this legal entity |
| organizations | Organization | 1:N | Business units under this entity |

---

## 6. Lifecycle States

| State | Description | Source |
|-------|-------------|--------|
| ACTIVE | Currently operating legal entity | Universal |
| INACTIVE | Temporarily not operating | Universal |
| PENDING | Awaiting registration completion | Best practice |
| DISSOLVED | Legally dissolved/closed | Best practice |
| MERGED | Merged into another entity | Best practice |

**State Transition Rules**:
```
PENDING → ACTIVE (registration completed)
ACTIVE → INACTIVE (temporary suspension)
INACTIVE → ACTIVE (reactivation)
ACTIVE → DISSOLVED (dissolution process)
ACTIVE → MERGED (merger/acquisition)
```

---

## 7. Vendor Variations

### 7.1 Oracle HCM
- **Legal Entity Configurator (XLE)**: Dedicated UI for legal entity setup
- **Multiple Classifications**: Same entity can be Legal Employer + PSU + TRU
- **Legislative Data Group**: Required for payroll, links to PSU
- **Date-Effective**: Full history tracking on all attributes

### 7.2 SAP SuccessFactors
- **Foundation Objects**: Legal Entity is part of FO framework
- **FOLegalEntityLocal**: Country-specific extensions per legislation
- **Picklist-driven**: Uses picklists for legal form, status
- **MDF-based**: Metadata Framework for customization

### 7.3 Workday
- **Company Organization Type**: Legal Entity is an organization subtype
- **Tax ID Separation**: Separate fields for federal/state taxes
- **Reference Model**: Uses WID for all cross-references
- **Reorganization Support**: Built-in org change management

---

## 8. Local Adaptations (Vietnam)

### 8.1 Required by VN Enterprise Law

| Attribute | VN Requirement | Notes |
|-----------|----------------|-------|
| registrationNumber | Mã số doanh nghiệp | 10-digit enterprise code |
| taxId | Mã số thuế | Same as registration for most |
| legalForm | Loại hình doanh nghiệp | LLC, JSC, Private, etc. |
| incorporationDate | Ngày thành lập | Required for all entities |

### 8.2 VN-Specific Legal Forms

| Code | VN Name | English |
|------|---------|---------|
| LLC | Công ty TNHH | Limited Liability Company |
| JSC | Công ty Cổ phần | Joint Stock Company |
| PRIVATE | Doanh nghiệp tư nhân | Private Enterprise |
| PARTNERSHIP | Công ty hợp danh | Partnership |
| BRANCH | Chi nhánh | Branch Office |
| REP_OFFICE | Văn phòng đại diện | Representative Office |

### 8.3 VN Tax Registration Requirements

| Field | VN Name | Description |
|-------|---------|-------------|
| taxId | Mã số thuế | Tax code (usually = registration number) |
| socialInsuranceNumber | Mã đơn vị BHXH | Social Insurance unit code |
| laborRegistration | Đăng ký sử dụng lao động | Labor registration number |

### 8.4 Recommended VN Extensions

| Field | Type | Description |
|-------|------|-------------|
| socialInsuranceCode | string | Mã BHXH doanh nghiệp |
| laborDepartmentCode | string | Mã Sở LĐTBXH |
| taxDepartmentCode | string | Mã Cục thuế quản lý |

---

## 9. Design Recommendations

### 9.1 Legal Entity Classifications

Consider implementing classification flags (Oracle pattern):
```
isLegalEmployer: boolean    // Can employ workers
isPayrollStatutory: boolean // Responsible for payroll taxes
isTaxReporting: boolean     // Tax reporting unit
```

### 9.2 Separate from Organization

Legal Entity should:
- Focus on LEGAL/TAX aspects only
- NOT contain management hierarchy
- Link to Organizations via relationship

Organization (separate entity) should:
- Handle management/reporting structure
- Support hierarchies (Department, Division, BU)
- Link to Legal Entity for payroll/tax purposes

### 9.3 Entity Hierarchy

```
LegalEntity (legal/tax)
├── Organization (management structure)
│   ├── BusinessUnit
│   ├── Division
│   └── Department
└── PayrollStatutoryUnit (if separate)
    └── TaxReportingUnit
```

---

## 10. Sources

| Vendor | Document | URL | Tier |
|--------|----------|-----|------|
| Oracle | HCM Cloud Legal Entity Guide | docs.oracle.com/en/cloud/saas/ | 1 |
| Oracle | Legal Entity Configurator | fusion docs apps2fusion.com | 1 |
| SAP | Employee Central Foundation Objects | api.sap.com/api/FOCompany | 1 |
| Workday | Company API Reference | community.workday.com | 1 |
| VN Gov | Enterprise Law 2020 | thuvienphapluat.vn | 1 |

---

## 11. Next Steps

This schema standards document should be used as input for:
1. **ontology-builder** skill to create `legal-entity.onto.md`
2. **frs-builder** skill for Legal Entity Management sub-module
3. **api-builder** skill for Legal Entity CRUD APIs

---

*Document Status: APPROVED - Verified against 3 major HCM vendors*
