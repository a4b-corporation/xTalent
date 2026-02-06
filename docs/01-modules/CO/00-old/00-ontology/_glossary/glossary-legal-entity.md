# Legal Entity Glossary

## Overview

This glossary defines the legal entity structure entities used in the xTalent HCM system. Legal entities represent the corporate structure including companies, branches, subsidiaries, and their associated legal information.

---

## Entities

### EntityType

**Definition:** Classification of legal entity types defining the hierarchical structure of corporate organizations.

**Purpose:**
- Categorize legal entities by type (company, branch, subsidiary, etc.)
- Define allowed hierarchical relationships
- Support corporate structure modeling

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Entity type code |
| `name` | string(100) | No | Entity type name |
| `level_order` | integer | No | Hierarchical level indicator |
| `metadata` | jsonb | No | Allowed parent types, constraints |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Common Entity Types:**

| Code | Name | Level | Description |
|------|------|-------|-------------|
| `HOLDING` | Holding Company | 1 | Top-level holding company |
| `COMPANY` | Company | 2 | Operating company |
| `SUBSIDIARY` | Subsidiary | 3 | Subsidiary company |
| `BRANCH` | Branch | 4 | Branch office |
| `REPRESENTATIVE` | Representative Office | 4 | Representative office |

**Metadata Structure:**
```json
{
  "allowed_parent_types": ["HOLDING", "COMPANY"],
  "requires_license": true,
  "can_employ_workers": true,
  "tax_entity": true,
  "constraints": {
    "max_depth": 5,
    "requires_parent": true
  }
}
```

**Business Rules:**
- Entity type code must be unique
- Level order determines hierarchy depth
- SCD Type 2 for historical tracking

---

### Entity

**Definition:** Legal entity (company, branch, subsidiary) representing a legally registered organization that can employ workers and conduct business.

**Purpose:**
- Define corporate structure and hierarchy
- Track legal entity information
- Support multi-entity operations
- Enable entity-level reporting and compliance

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `code` | string(50) | Yes | Unique legal entity code |
| `name_vi` | string(150) | No | Vietnamese name |
| `name_en` | string(150) | No | English name |
| `type_id` | UUID | Yes | Entity type reference |
| `country_code` | string(2) | Yes | Country of legal registration (ISO-3166 alpha-2) |
| `parent_id` | UUID | No | Parent legal entity |
| `path` | string(255) | No | Hierarchical path (e.g., /parent/child) |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Relationships:**
- **Belongs to** `EntityType` (entity type)
- **Belongs to** `Entity` (parent entity)
- **Has many** `Entity` (child entities)
- **Has one** `EntityProfile` (extended profile)
- **Has many** `EntityRepresentative` (legal representatives)
- **Has many** `EntityLicense` (business licenses)
- **Has many** `EntityBankAccount` (bank accounts)
- **Has many** `Unit` (business units)

**Business Rules:**
- Entity code must be unique across all legal entities
- Country code represents legal jurisdiction (country of incorporation)
- Country code may differ from physical office address country
- Path must reflect actual hierarchy
- SCD Type 2 for tracking changes over time
- Parent entity must be of allowed type per EntityType metadata

**Examples:**

```yaml
# Holding Company
id: entity_vng_holding
code: VNG_HOLDING
name_vi: Tập đoàn VNG
name_en: VNG Corporation
type_id: type_holding
country_code: VN
parent_id: null
path: /VNG_HOLDING

# Operating Company
id: entity_vng_corp
code: VNG_CORP
name_vi: Công ty Cổ phần VNG
name_en: VNG Corporation JSC
type_id: type_company
country_code: VN
parent_id: entity_vng_holding
path: /VNG_HOLDING/VNG_CORP

# Branch
id: entity_vng_hn
code: VNG_HN_BRANCH
name_vi: Chi nhánh Hà Nội
name_en: Hanoi Branch
type_id: type_branch
country_code: VN
parent_id: entity_vng_corp
path: /VNG_HOLDING/VNG_CORP/VNG_HN_BRANCH
```

---

### EntityProfile

**Definition:** Extended profile information for legal entities including addresses, contacts, tax information, and branding.

**Purpose:**
- Store detailed legal entity information
- Maintain contact and address data
- Track tax and insurance identifiers
- Support branding and corporate identity

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `legal_entity_id` | UUID | Yes | Primary key and FK to Entity |
| `logo_url` | string(255) | No | Company logo URL |
| `legal_name_local` | string(255) | No | Full legal name (local language) |
| `legal_name_en` | string(255) | No | Full legal name (English) |
| `group_name` | string(255) | No | Corporate group name |
| `address1_country_code` | string(2) | No | Primary address country |
| `address1_admin_area_id` | UUID | No | Primary address admin area |
| `address1_street` | string(255) | No | Primary address street |
| `address1_postal_code` | string(20) | No | Primary address postal code |
| `address2_country_code` | string(2) | No | Secondary address country |
| `address2_admin_area_id` | UUID | No | Secondary address admin area |
| `address2_street` | string(255) | No | Secondary address street |
| `address2_postal_code` | string(20) | No | Secondary address postal code |
| `phone` | string(50) | No | Primary phone number |
| `fax` | string(50) | No | Fax number |
| `email` | string(100) | No | Primary email |
| `email_suffix` | string(100) | No | Corporate email domain (e.g., @company.com) |
| `website` | string(255) | No | Company website |
| `tagline` | string(255) | No | Company tagline/slogan |
| `is_head_office` | boolean | No | Head office indicator (default: false) |
| `is_member` | boolean | No | Member of corporate group (default: true) |
| `ceo_worker_id` | UUID | No | CEO worker reference |
| `tax_id` | string(50) | No | Tax identification number |
| `insurance_type_code` | string(50) | No | Insurance type code |
| `description` | text | No | Entity description |
| `metadata` | jsonb | No | Additional attributes |
| `active` | boolean | No | Active status (default: true) |

**Metadata Structure:**
```json
{
  "registration_number": "0100109106",
  "registration_date": "2004-04-08",
  "registration_authority": "Department of Planning and Investment of Hanoi",
  "charter_capital": 1000000000000,
  "charter_capital_currency": "VND",
  "business_sectors": ["Technology", "Entertainment", "E-commerce"],
  "employee_count_range": "1000-5000",
  "fiscal_year_end": "12-31",
  "stock_exchange": "HOSE",
  "stock_symbol": "VNZ"
}
```

**Relationships:**
- **Belongs to** `Entity` (one-to-one)
- **References** `Worker` (CEO)

**Business Rules:**
- One profile per legal entity
- At least one address should be provided
- Tax ID required for tax entities
- Email suffix should match corporate domain
- Address country may differ from Entity.country_code (legal jurisdiction)

**Example:**

```yaml
legal_entity_id: entity_vng_corp
logo_url: https://cdn.vng.com/logo.png
legal_name_local: Công ty Cổ phần VNG
legal_name_en: VNG Corporation Joint Stock Company
group_name: VNG Corporation
address1_country_code: VN
address1_admin_area_id: admin_vn_hanoi
address1_street: 182 Le Dai Hanh, Hai Ba Trung
address1_postal_code: "100000"
phone: "+84 24 7300 8855"
email: contact@vng.com.vn
email_suffix: "@vng.com.vn"
website: https://www.vng.com.vn
is_head_office: true
ceo_worker_id: worker_ceo_001
tax_id: "0100109106"
metadata:
  registration_number: "0100109106"
  registration_date: "2004-04-08"
  charter_capital: 1000000000000
```

---

### EntityRepresentative

**Definition:** Legal representatives and authorized signatories of legal entities.

**Purpose:**
- Track legal representatives
- Manage authorized signatories
- Support document signing authority
- Maintain compliance with corporate governance

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `legal_entity_id` | UUID | Yes | Legal entity reference |
| `rep_type_code` | string(50) | No | Representative type (LEGAL_REP, AUTH_REP, CEO) |
| `worker_id` | UUID | Yes | Worker reference |
| `document_id` | UUID | No | Authorization document |
| `metadata` | jsonb | No | Decision number, notes |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**Representative Types:**

| Code | Description | Authority Level |
|------|-------------|-----------------|
| `LEGAL_REP` | Legal Representative | Full legal authority |
| `AUTH_REP` | Authorized Representative | Limited authority per document |
| `CEO` | Chief Executive Officer | Executive authority |
| `CHAIRMAN` | Chairman of Board | Board authority |
| `DIRECTOR` | Director | Departmental authority |

**Metadata Structure:**
```json
{
  "decision_number": "123/QĐ-VNG",
  "decision_date": "2025-01-15",
  "appointment_authority": "Board of Directors",
  "signing_authority": ["contracts", "bank_documents", "legal_filings"],
  "delegation_scope": "Full authority",
  "notes": "Appointed as legal representative"
}
```

**Relationships:**
- **Belongs to** `Entity`
- **References** `Worker` (representative)
- **References** `Document` (authorization document)

**Business Rules:**
- Combination of entity, rep type, and effective start date must be unique
- Worker must be active employee of the entity
- SCD Type 2 for historical tracking
- Authorization document required for AUTH_REP type

**Example:**

```yaml
id: rep_001
legal_entity_id: entity_vng_corp
rep_type_code: LEGAL_REP
worker_id: worker_ceo_001
document_id: doc_appointment_001
metadata:
  decision_number: "01/2025/QĐ-HĐQT"
  decision_date: "2025-01-01"
  appointment_authority: "Board of Directors"
effective_start_date: "2025-01-01"
is_current_flag: true
```

---

### EntityLicense

**Definition:** Business licenses and registrations for legal entities.

**Purpose:**
- Track business licenses and permits
- Maintain compliance documentation
- Support regulatory reporting
- Manage license renewals

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `legal_entity_id` | UUID | Yes | Legal entity reference |
| `license_number` | string(100) | No | License/registration number |
| `issue_date` | date | No | Issue date |
| `issued_by` | string(255) | No | Issuing authority |
| `metadata` | jsonb | No | Attachments, notes, expiry date |
| `effective_start_date` | date | Yes | Effective start date |
| `effective_end_date` | date | No | Effective end date |
| `is_current_flag` | boolean | Yes | Current record indicator |

**License Types (in metadata):**

| Type | Description |
|------|-------------|
| `BUSINESS_REGISTRATION` | Business registration certificate |
| `TAX_REGISTRATION` | Tax registration certificate |
| `OPERATING_LICENSE` | Operating license |
| `INDUSTRY_PERMIT` | Industry-specific permit |
| `IMPORT_EXPORT` | Import/export license |

**Metadata Structure:**
```json
{
  "license_type": "BUSINESS_REGISTRATION",
  "license_name": "Business Registration Certificate",
  "expiry_date": "2030-12-31",
  "renewal_required": false,
  "attachment_url": "https://storage.vng.com/licenses/brc_001.pdf",
  "status": "ACTIVE",
  "notes": "Main business registration"
}
```

**Relationships:**
- **Belongs to** `Entity`

**Business Rules:**
- Combination of entity, license number, and effective start date must be unique
- SCD Type 2 for historical tracking
- Expiry date should be tracked in metadata
- Renewal alerts should be configured

**Example:**

```yaml
id: license_001
legal_entity_id: entity_vng_corp
license_number: "0100109106"
issue_date: "2004-04-08"
issued_by: "Department of Planning and Investment of Hanoi"
metadata:
  license_type: "BUSINESS_REGISTRATION"
  license_name: "Business Registration Certificate"
  expiry_date: null
  attachment_url: "https://storage.vng.com/licenses/brc_vng.pdf"
effective_start_date: "2004-04-08"
is_current_flag: true
```

---

### EntityBankAccount

**Definition:** Bank accounts owned by legal entities for financial transactions.

**Purpose:**
- Manage corporate bank accounts
- Support payroll and payment processing
- Track account details for financial operations
- Enable multi-currency banking

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `legal_entity_id` | UUID | Yes | Legal entity reference |
| `bank_name` | string(255) | No | Bank name |
| `account_number` | string(100) | No | Account number |
| `account_holder` | string(255) | No | Account holder name |
| `currency_code` | string(3) | No | Account currency (ISO 4217) |
| `is_primary` | boolean | No | Primary account indicator (default: false) |
| `metadata` | jsonb | No | Additional account details |

**Metadata Structure:**
```json
{
  "bank_code": "BIDVVNVX",
  "branch_name": "Hanoi Branch",
  "branch_code": "001",
  "swift_code": "BIDVVNVX",
  "iban": null,
  "account_type": "CORPORATE_CHECKING",
  "purpose": "PAYROLL",
  "status": "ACTIVE",
  "opened_date": "2004-05-01",
  "notes": "Primary payroll account"
}
```

**Account Purposes:**

| Purpose | Description |
|---------|-------------|
| `PAYROLL` | Employee payroll disbursement |
| `OPERATING` | General operating expenses |
| `RECEIVABLES` | Customer payments |
| `PAYABLES` | Vendor payments |
| `TAX` | Tax payments |
| `SAVINGS` | Savings/investment account |

**Relationships:**
- **Belongs to** `Entity`

**Business Rules:**
- Combination of entity and account number must be unique
- Only one primary account per entity per currency
- Currency code must be valid ISO 4217 code
- Account holder should match legal entity name

**Example:**

```yaml
id: bank_001
legal_entity_id: entity_vng_corp
bank_name: "BIDV - Bank for Investment and Development of Vietnam"
account_number: "12345678901"
account_holder: "CONG TY CO PHAN VNG"
currency_code: "VND"
is_primary: true
metadata:
  bank_code: "BIDVVNVX"
  branch_name: "Hanoi Branch"
  swift_code: "BIDVVNVX"
  account_type: "CORPORATE_CHECKING"
  purpose: "PAYROLL"
  status: "ACTIVE"
```

---

## Relationships

```mermaid
erDiagram
    EntityType ||--o{ Entity : "classifies"
    Entity ||--o{ Entity : "parent-child"
    Entity ||--o| EntityProfile : "has"
    Entity ||--o{ EntityRepresentative : "has"
    Entity ||--o{ EntityLicense : "has"
    Entity ||--o{ EntityBankAccount : "has"
    Worker ||--o{ EntityRepresentative : "is"
    
    EntityType {
        uuid id PK
        string code UK
        string name
        integer level_order
        jsonb metadata
    }
    
    Entity {
        uuid id PK
        string code UK
        string name_vi
        string name_en
        uuid type_id FK
        uuid parent_id FK
        string path
    }
    
    EntityProfile {
        uuid legal_entity_id PK_FK
        string legal_name_local
        string tax_id
        string email_suffix
        uuid ceo_worker_id FK
    }
    
    EntityRepresentative {
        uuid id PK
        uuid legal_entity_id FK
        string rep_type_code
        uuid worker_id FK
    }
    
    EntityLicense {
        uuid id PK
        uuid legal_entity_id FK
        string license_number
        date issue_date
    }
    
    EntityBankAccount {
        uuid id PK
        uuid legal_entity_id FK
        string account_number
        string currency_code
        boolean is_primary
    }
```

---

## Use Cases

### Corporate Structure Management
- Define holding company and subsidiaries
- Track branch offices and representative offices
- Manage corporate hierarchy changes
- Support M&A activities

### Legal Compliance
- Maintain business licenses and permits
- Track legal representatives
- Manage corporate governance
- Support regulatory reporting

### Financial Operations
- Manage corporate bank accounts
- Process payroll payments
- Handle vendor payments
- Track multi-currency accounts

### Employee Management
- Assign employees to legal entities
- Track employment contracts by entity
- Support multi-entity employment
- Enable entity-level reporting

---

## Best Practices

1. **Entity Code Naming:**
   - Use consistent naming convention
   - Include entity type prefix
   - Keep codes short but meaningful

2. **Hierarchy Management:**
   - Maintain accurate parent-child relationships
   - Update paths when hierarchy changes
   - Validate hierarchy depth

3. **Profile Completeness:**
   - Ensure all required fields are populated
   - Keep contact information current
   - Update tax IDs promptly

4. **License Tracking:**
   - Set up renewal reminders
   - Maintain digital copies
   - Track expiry dates

5. **Bank Account Security:**
   - Limit access to account details
   - Encrypt sensitive data
   - Audit account changes

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2025-12-01 | Enhanced metadata structures, added examples |
| 1.0 | 2025-11-01 | Initial legal entity ontology |
