# Person Sub-Module - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-01  
**Sub-Module**: Worker (People) Master Data

---

## 📋 Overview

The Person sub-module manages core person (worker) data including biographical information, contacts, addresses, qualifications, skills, and competencies. This is the **foundation** of all HR data.

**New in v2.0**: Person Type classification determines system behavior and available features.

### Entities (10)
1. **Worker** 🔄 (Enhanced with Person Types)
2. **Contact**
3. **Address**
4. **Document**
5. **BankAccount**
6. **WorkerRelationship** (Personal relationships, not work relationships)
7. **WorkerQualification**
8. **WorkerSkill** 🔄 (Enhanced with Gap Analysis)
9. **WorkerCompetency**
10. **WorkerInterest**

---

## 🔑 Key Entities

### Worker 🔄 ENHANCED

**Definition**: The core person entity representing any individual in the system with an immutable identity throughout their lifetime.

**Purpose**:
- Central identity for all individuals
- Biographical and demographic data
- Person type classification
- Entry point for all HR processes

**Key Attributes**:
- `id` - **Immutable worker ID** (never changes, even if person leaves and returns)
- `person_type_code` ✨ - System categorization
  - `EMPLOYEE` - Regular employee (full HR features)
  - `CONTRACTOR` - Independent contractor (limited features)
  - `CONTINGENT` - Temporary/agency worker
  - `NON_WORKER` - Participates but not employed (e.g., board members, advisors)
  - `PENDING` - Pending hire/onboarding
  - `FORMER` - Former employee (historical data retained)
- `first_name`, `middle_name`, `last_name` - Legal names
- `preferred_name` - Nickname or preferred name
- `date_of_birth` - For age calculation, benefits eligibility
- `gender_code` - From CodeList
- `nationality_code` - ISO-3166 country code
- `marital_status_code` - Single, Married, Divorced, etc.
- `data_classification` ✨ - Security metadata (JSONB)

**Data Classification Example**:
```json
{
  "sensitivity_level": "CONFIDENTIAL",
  "encryption_required": true,
  "pii_fields": ["date_of_birth", "nationality_code", "marital_status_code"],
  "access_scope": "SELF_AND_HR",
  "retention_years": 7,
  "gdpr_subject": true
}
```

**Person Type Behaviors**:

| Person Type | HR Records | Assignments | Absence | Payroll | Talent |
|-------------|------------|-------------|---------|---------|--------|
| EMPLOYEE | ✅ Full | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| CONTRACTOR | ⚠️ Limited | ✅ Yes | ❌ No | ⚠️ Invoicing | ❌ No |
| CONTINGENT | ⚠️ Limited | ✅ Yes | ⚠️ Limited | ⚠️ Agency | ❌ No |
| NON_WORKER | ❌ No | ❌ No | ❌ No | ❌ No | ❌ No |
| PENDING | ⚠️ Partial | ❌ No | ❌ No | ❌ No | ❌ No |
| FORMER | 🔒 Read-only | ❌ No | ❌ No | ❌ No | ❌ No |

**Business Rules**:
- ✅ Worker ID is **immutable** for lifetime (same ID if rehired)
- ✅ Person type determines available features and workflows
- ✅ NON_WORKER type cannot have assignments, absences, talent records
- ✅ FORMER type retains historical data but locked from changes
- ✅ One worker can have multiple work relationships (see Employment module)
- ✅ Personal data centralized here, employment data separate
- ⚠️ PII fields must be encrypted at rest per data_classification

**Example**:
```yaml
Worker:
  id: WORKER-001
  person_type: EMPLOYEE
  first_name: "Nguyễn Văn"
  last_name: "An"
  preferred_name: "Andy"
  date_of_birth: 1990-05-15
  nationality: "VN"
  data_classification:
    sensitivity_level: "CONFIDENTIAL"
    pii_fields: ["date_of_birth", "nationality"]
```

---

### Contact

**Definition**: Contact information for workers including phone numbers, emails, instant messaging, and social media accounts.

**Purpose**:
- Multiple contact methods per worker
- Primary contact designation
- Contact type validation

**Key Attributes**:
- `worker_id` - Person owning this contact
- `contact_type_code` - Type from ContactType master
  - `MOBILE_PERSONAL`
  - `MOBILE_WORK`
  - `EMAIL_PERSONAL`
  - `EMAIL_WORK`
  - `LINKEDIN`
  - `SKYPE`
  - `WHATSAPP`
- `contact_value` - Actual contact info
- `is_primary` - Primary contact of this type
- SCD Type 2 fields (effective_start_date, etc.)

**Business Rules**:
- ✅ Only one primary contact per type per worker
- ✅ Contact value must match validation regex from ContactType
- ✅ Work email typically follows company domain pattern

**Example**:
```yaml
Worker: Nguyễn Văn An
Contacts:
  - type: EMAIL_WORK
    value: "an.nguyen@company.com"
    is_primary: true
  - type: MOBILE_PERSONAL
    value: "+84-901-234-567"
    is_primary: true
  - type: LINKEDIN
    value: "linkedin.com/in/annguyen"
    is_primary: false
```

---

### Address

**Definition**: Physical addresses for workers (home, permanent, temporary).

**Purpose**:
- Track residential addresses
- Support tax jurisdiction calculation
- Emergency contact purposes
- Payroll address for tax forms

**Key Attributes**:
- `worker_id` - Person
- `address_type_code`:
  - `HOME` - Current residence
  - `PERMANENT` - Permanent address (e.g., hometown)
  - `TEMPORARY` - Temporary residence
  - `MAILING` - Mailing address
- `admin_area_id` - Links to AdminArea (ward/commune level)
- `street_line` - Street address
- `postal_code` - Zip/postal code
- `is_primary` - Primary address of this type
- SCD Type 2 tracking

**Address Hierarchy** (via admin_area_id):
```
Country (Vietnam)
  → Province/City (Hồ Chí Minh)
    → District (Quận 1)
      → Ward (Phường Bến Nghé) ← admin_area_id points here
```

**Business Rules**:
- ✅ One primary address per type
- ✅ Must link to lowest admin area level (ward/commune)
- ✅ Postal code must match admin area's country format

**Example**:
```yaml
Address:
  type: HOME
  admin_area_id: WARD-HCM-Q1-BENNGHE
  street_line: "123 Nguyễn Huệ"
  postal_code: "700000"
  is_primary: true
```

---

### Document

**Definition**: Documents related to workers (ID cards, passports, degrees, certificates).

**Purpose**:
- Store document metadata and file references
- Track expiration dates
- Compliance (right to work verification)

**Key Attributes**:
- `worker_id` - Document owner
- `document_type_code`:
  - `NATIONAL_ID` - National ID card
  - `PASSPORT` - Passport
  - `DRIVERS_LICENSE` - Driver's license
  - `DEGREE` - Academic degree
  - `CERTIFICATE` - Professional certificate
  - `WORK_PERMIT` - Work permit (foreigners)
  - `VISA` - Visa document
- `document_number` - Document ID number
- `issuing_authority` - Who issued (e.g., "Ministry of Public Security")
- `issue_date` / `expiry_date` - Validity period
- `file_url` - Link to scanned document
- SCD Type 2

**Business Rules**:
- ✅ Expiry date alerts for work permits, visas
- ✅ National ID and Passport should be unique per worker
- ⚠️ Documents with personal data require encryption

**Example**:
```yaml
Documents:
  - type: NATIONAL_ID
    number: "001090012345"
    issue_date: 2020-01-15
    expiry_date: 2030-01-15
    issuing_authority: "Public Security Ministry"
    
  - type: WORK_PERMIT
    number: "WP-2024-001"
    issue_date: 2024-01-01
    expiry_date: 2026-12-31
    issuing_authority: "Department of Labor"
```

---

### BankAccount

**Definition**: Bank account information for workers (salary payments, reimbursements).

**Purpose**:
- Salary direct deposit
- Expense reimbursements
- Multiple accounts support (primary + savings)

**Key Attributes**:
- `worker_id` - Account owner
- `account_type_code`:
  - `SALARY` - Primary salary account
  - `SAVINGS` - Secondary/savings account
  - `EXPENSE_REIMBURSEMENT` - For expense claims
- `bank_code` - Bank identifier
- `branch_code` - Branch identifier
- `account_number` - Account number
- `account_holder_name` - Name on account
- `is_primary` - Primary salary account
- `currency_code` - VND, USD, etc.
- SCD Type 2

**Business Rules**:
- ✅ Only one primary salary account at a time
- ✅ Account holder name should match worker's legal name
- ✅ Currency must match payroll currency
- ⚠️ Account numbers encrypted in database

**Example**:
```yaml
BankAccounts:
  - type: SALARY
    bank: "Vietcombank"
    branch: "HCM District 1"
    account_number: "0011000123456"
    currency: VND
    is_primary: true
    
  - type: SAVINGS
    bank: "Techcombank"
    account_number: "19036000123456"
    currency: USD
    is_primary: false
```

---

### WorkerRelationship

**Definition**: Personal relationships between workers (family, dependents, emergency contacts).

⚠️ **Not to be confused with** `WorkRelationship` in Employment module (which is work relationships).

**Purpose**:
- Track family members for benefits
- Tax dependents
- Emergency contacts
- Insurance beneficiaries

**Key Attributes**:
- `worker_id` - Primary worker
- `related_worker_id` - Related person (if also a worker)
- `relationship_type_id` - From RelationshipType master
  - Family: FATHER, MOTHER, SPOUSE, CHILD, SIBLING
  - Financial: DEPENDENT
  - Emergency: EMERGENCY_CONTACT
- `related_person_name` - Name (if not a worker)
- `dependency_flag` - Financial dependent for tax
- `is_emergency_contact` - Emergency contact flag
- SCD Type 2

**Business Rules**:
- ✅ Inverse relationships auto-created (FATHER ↔ SON)
- ✅ Dependents affect tax calculation
- ✅ Emergency contacts must have valid phone number

**Example**:
```yaml
Worker: Nguyễn Văn An
Relationships:
  - related_person: "Trần Thị Bích" (wife)
    relationship: SPOUSE
    dependency: true
    emergency_contact: true
    
  - related_person: "Nguyễn An Khang" (son)
    relationship: CHILD
    dependency: true
    date_of_birth: 2015-05-01
```

---

### WorkerQualification

**Definition**: Educational qualifications and professional certifications.

**Purpose**:
- Track degrees, diplomas, certificates
- Verify credentials
- Career development planning

**Key Attributes**:
- `worker_id` - Person
- `qualification_type_code`:
  - Education: `BACHELOR`, `MASTER`, `PHD`, `DIPLOMA`
  - Professional: `CPA`, `PMP`, `CISSP`, `AWS_CERTIFIED`
- `institution_name` - University or certifying body
- `field_of_study` - Major or specialization
- `graduation_date` or `issue_date`
- `expiry_date` - For time-limited certifications
- `grade_gpa` - Academic grade
- `verification_status` - VERIFIED, PENDING, NOT_VERIFIED
- SCD Type 2

**Business Rules**:
- ✅ Professional certifications require renewal tracking
- ✅ Degrees typically don't expire, certifications do
- ✅ Verification required for compliance

**Example**:
```yaml
Qualifications:
  - type: BACHELOR
    institution: "University of Technology"
    field_of_study: "Computer Science"
    graduation_date: 2012-06-30
    gpa: 3.65
    verification_status: VERIFIED
    
  - type: PMP
    institution: "PMI"
    issue_date: 2023-01-15
    expiry_date: 2026-01-15
    verification_status: VERIFIED
```

---

### WorkerSkill 🔄 ENHANCED

**Definition**: Skills possessed by workers with proficiency levels and gap analysis.

**Purpose**:
- Track current skills and proficiency
- Identify skill gaps (NEW in v2.0)
- Development planning
- Job matching

**Key Attributes**:
- `worker_id` - Person
- `skill_id` - Links to SkillMaster
- `proficiency_level` - Current level (1-5 or per scale)
- `target_proficiency_level` ✨ - Desired level (NEW)
- `proficiency_gap` ✨ - Computed: target - current (NEW)
- `estimated_gap_months` ✨ - Time to close gap (NEW)
- `years_experience` - Years using this skill
- `last_used_date` - When last used
- `source_code`:
  - `SELF` - Self-assessment
  - `MANAGER` - Manager assessment
  - `CERT` - Certificate-based
  - `ASSESS` - Formal assessment
- `verified_flag` - Verified by manager/HR
- `verified_date` ✨ - When verified (NEW)
- `verified_by_worker_id` ✨ - Who verified (NEW)
- SCD Type 2

**Proficiency Scales** (example):
```
1 = Beginner (awareness)
2 = Novice (basic tasks with guidance)
3 = Intermediate (independent work)
4 = Advanced (complex problems, mentor others)
5 = Expert (thought leader, innovator)
```

**Skill Gap Analysis** ✨ NEW:
```yaml
Skill: Python Programming
  current_proficiency: 3 (Intermediate)
  target_proficiency: 5 (Expert)
  proficiency_gap: 2
  estimated_gap_months: 18
  development_plan:
    - Advanced Python course (3 months)
    - Lead 2 Python projects (9 months)
    - Mentor junior developers (6 months)
```

**Business Rules**:
- ✅ Only verified skills count for job matching
- ✅ Manager verification overrides self-assessment
- ✅ Certification automatically verified
- ✅ Gap > 0 triggers development plan suggestion
- ⚠️ Skills older than 3 years may need re-verification

**Example**:
```yaml
WorkerSkills:
  - skill: "Python"
    current_proficiency: 4
    target_proficiency: 5
    gap: 1
    gap_months: 12
    years_experience: 5.5
    source: MANAGER
    verified: true
    
  - skill: "Machine Learning"
    current_proficiency: 2
    target_proficiency: 4
    gap: 2
    gap_months: 18
    source: SELF
    verified: false
```

---

### WorkerCompetency

**Definition**: Behavioral competency assessments (soft skills).

**Purpose**:
- Performance reviews
- Leadership development
- Succession planning

**Key Attributes**:
- `worker_id` - Person
- `competency_id` - Links to CompetencyMaster
- `rating_value` - Numeric score
- `rating_scale_code` - Scale used (e.g., 1-5, 1-10)
- `assessed_date` - When assessed
- `assessed_by_worker_id` - Assessor
- `source_code`:
  - `SELF` - Self-assessment
  - `MGR` - Manager assessment
  - `360` - 360-degree feedback
  - `SURVEY` - Employee survey
- SCD Type 2

**Common Competencies**:
- Leadership
- Communication
- Teamwork
- Problem Solving
- Innovation
- Customer Focus
- Adaptability

**Example**:
```yaml
Competencies:
  - competency: "Leadership"
    rating: 4.5
    scale: "1-5"
    assessed_date: 2024-06-30
    source: "360"
    assessor: Manager
    
  - competency: "Communication"
    rating: 4.0
    scale: "1-5"
    source: "MGR"
```

---

### WorkerInterest

**Definition**: Worker's career interests and preferences.

**Purpose**:
- Career path planning
- Internal mobility
- Talent marketplace matching
- Engagement tracking

**Key Attributes**:
- `worker_id` - Person
- `interest_type_code`:
  - `JOB_FAMILY` - Interested in job family (e.g., Engineering, Sales)
  - `JOB_ROLE` - Specific role (e.g., Product Manager)
  - `LOCATION` - Geographic preference
  - `PROJECT_TYPE` - Project preferences
  - `LEARNING_TOPIC` - Learning interests
- `interest_target_id` - Links to relevant master (Job, Location, etc.)
- `interest_level` - 1-5 (5 = very interested)
- `willing_to_relocate` - Boolean
- `available_from_date` - When available for change
- SCD Type 2

**Business Rules**:
- ✅ Interests used for internal job recommendations
- ✅ Multiple interests allowed
- ✅ Interests linked to talent marketplace opportunities

**Example**:
```yaml
Interests:
  - type: JOB_ROLE
    target: "Product Manager"
    level: 5
    available_from: 2025-01-01
    
  - type: LOCATION
    target: "Singapore Office"
    level: 4
    willing_to_relocate: true
    
  - type: LEARNING_TOPIC
    target: "AI/Machine Learning"
    level: 5
```

---

## 🔄 Data Flow Examples

### New Hire Onboarding
```
1. Create Worker (person_type = PENDING)
   ↓
2. Collect personal info (contacts, addresses)
   ↓
3. Upload documents (ID, degree certificates)
   ↓
4. Setup bank account for salary
   ↓
5. Record qualifications and skills
   ↓
6. Update person_type to EMPLOYEE (on hire date)
   ↓
7. Create WorkRelationship and Employee (see Employment module)
```

### Skill Development Cycle
```
1. Manager assesses worker skills
   ↓
2. Set target proficiency levels (skill gap identified)
   ↓
3. Calculate gap and estimate timeline
   ↓
4. Create development plan
   ↓
5. Worker completes training/projects
   ↓
6. Re-assess skills (proficiency increased)
   ↓
7. Gap reduced or closed
```

---

## 💡 Best Practices

### Data Privacy & Security
- ✅ Always populate `data_classification` for PII
- ✅ Encrypt: national_id, bank_account_number, date_of_birth
- ✅ Access control: SELF_AND_HR for most personal data
- ✅ GDPR right to be forgotten: Mark as FORMER, retain minimum data

### Skill Management
- ✅ Regular skill assessments (annually)
- ✅ Manager verification for critical skills
- ✅ Link skills to training programs
- ✅ Use gap analysis for performance reviews

### Document Management
- ✅ Set up expiry alerts (work permits, certifications)
- ✅ Scan and upload all critical documents
- ✅ Regular document verification audits

---

## ⚠️ Important Notes

### Person Type Migration (v2.0)
```sql
-- Set person type for existing workers
UPDATE person.worker
SET person_type_code = CASE
  WHEN EXISTS (SELECT 1 FROM employment.employee WHERE worker_id = worker.id)
    THEN 'EMPLOYEE'
  WHEN worker_category_code = 'CONTRACTOR'
    THEN 'CONTRACTOR'
  ELSE 'CONTINGENT'
END;
```

### Skill Gap Analysis (v2.0)
- New fields optional for backward compatibility
- Populate target levels during performance reviews
- Use for development planning and succession

---

## 🔗 Related Glossaries

- **Employment** - Work relationships, employees, assignments
- **Common** - SkillMaster, CompetencyMaster, ContactType
- **JobPosition** - Job profiles with required skills

---

**Document Version**: 2.0  
**Last Review**: 2025-12-01
