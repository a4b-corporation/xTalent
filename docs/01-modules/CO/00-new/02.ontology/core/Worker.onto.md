---
entity: Worker
domain: core-hr
version: "1.0.0"
status: approved
owner: HR Domain Team
tags: [person, identity, biographical, core]

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: workerNumber
    type: string
    required: false
    unique: true
    description: Human-readable worker identifier (e.g., W001234)
  
  - name: status
    type: enum
    required: true
    description: Current status of the worker record
    values: [ACTIVE, INACTIVE, DECEASED, MERGED]
  
  - name: dateOfBirth
    type: date
    required: true
    description: Date of birth (Ngày sinh). REQUIRED for age-based validations (minimum working age, retirement eligibility).
  
  # === BIOLOGICAL & HEALTH (Demographics) ===
  - name: gender
    type: enum
    required: false
    description: Biological sex or gender identity (Giới tính). Fixed enum as biological categories rarely change.
    values: [MALE, FEMALE, OTHER, UNDISCLOSED]
    metadata:
      pii: true
      sensitivity: medium
  
  - name: bloodType
    type: enum
    required: false
    description: Blood type for emergency/healthcare (Nhóm máu). Critical for workplace safety.
    values: [A_POSITIVE, A_NEGATIVE, B_POSITIVE, B_NEGATIVE, O_POSITIVE, O_NEGATIVE, AB_POSITIVE, AB_NEGATIVE, UNKNOWN]
    metadata:
      pii: true
      sensitivity: high
  
  - name: height
    type: number
    required: false
    description: Height in centimeters. Used for uniform sizing and health assessments.
    constraints:
      min: 100
      max: 250
    metadata:
      pii: true
      sensitivity: low
  
  - name: weight
    type: number
    required: false
    description: Weight in kilograms. Used for uniform sizing and health assessments.
    constraints:
      min: 30
      max: 300
    metadata:
      pii: true
      sensitivity: low
  
  - name: smokingStatus
    type: enum
    required: false
    description: Smoking habit status. Used for health insurance premium calculations.
    values: [NON_SMOKER, SMOKER, FORMER_SMOKER, PREFER_NOT_TO_SAY]
    metadata:
      pii: true
      sensitivity: medium
  
  - name: disabilityStatus
    type: enum
    required: false
    description: Registered disability status for tax deductions and hiring quotas (Người khuyết tật).
    values: [NONE, REGISTERED, PREFER_NOT_TO_SAY]
    metadata:
      pii: true
      sensitivity: high
  
  # === WORK CAPACITY ASSESSMENT (VN Decree 88/2015) ===
  - name: workCapacityLossPercentage
    type: number
    required: false
    description: Percentage of work capacity loss (Tỷ lệ % mất khả năng lao động). Per VN Decree 88/2015.
    constraints:
      min: 0
      max: 100
    metadata:
      pii: true
      sensitivity: high
  
  - name: workCapacityAssessmentDate
    type: date
    required: false
    description: Date of last official work capacity assessment (Ngày giám định khả năng lao động gần nhất).
  
  - name: workCapacityStatus
    type: enum
    required: false
    description: Work capacity status derived from workCapacityLossPercentage. >= 81% = UNABLE_TO_WORK, 61-80% = RESTRICTED, <= 60% = FULL_CAPACITY.
    values: [FULL_CAPACITY, RESTRICTED, UNABLE_TO_WORK]
    metadata:
      calculated: true
      formula: "workCapacityLossPercentage >= 81 ? UNABLE_TO_WORK : workCapacityLossPercentage >= 61 ? RESTRICTED : FULL_CAPACITY"
  
  # === RETIREMENT TRACKING (VN Labor Code 2019) ===
  - name: retirementEligibilityDate
    type: date
    required: false
    description: "Date when worker becomes eligible for retirement. Auto-calculated from dateOfBirth + gender (Male: 60, Female: 55)."
    metadata:
      calculated: true
      formula: "dateOfBirth + (gender = MALE ? 60 years : 55 years)"
  
  - name: retirementStatus
    type: enum
    required: false
    description: Current retirement status. Auto-updated when current date passes retirementEligibilityDate.
    values: [NOT_ELIGIBLE, ELIGIBLE, RETIRED, WORKING_BEYOND_RETIREMENT]
    default: NOT_ELIGIBLE
  
  - name: retirementExtensionEndDate
    type: date
    required: false
    description: If working beyond retirement age (WORKING_BEYOND_RETIREMENT), when does the extension end?
  
  # === CULTURAL & SOCIAL (CodeList References) ===
  - name: maritalStatus
    type: string
    required: false
    description: Legal marital status (Tình trạng hôn nhân). Maps to CODELIST_MARITAL_STATUS for dynamic values.
    constraints:
      reference: CODELIST_MARITAL_STATUS
    metadata:
      pii: true
      sensitivity: medium
      codeListValues: [SINGLE, MARRIED, DIVORCED, WIDOWED, SEPARATED, DOMESTIC_PARTNERSHIP]
  
  - name: maritalStatusDate
    type: date
    required: false
    description: Date when marital status last changed. Required for tax and benefits calculations.
  
  - name: religion
    type: string
    required: false
    description: Religious affiliation (Tôn giáo). Maps to CODELIST_RELIGION. SENSITIVE DATA - voluntary disclosure only.
    constraints:
      reference: CODELIST_RELIGION
    metadata:
      pii: true
      sensitivity: high
      codeListValues: [BUDDHIST, CATHOLIC, PROTESTANT, ISLAM, HINDU, NONE, OTHER, PREFER_NOT_TO_SAY]
  
  - name: ethnicity
    type: string
    required: false
    description: Ethnic group (Dân tộc). Maps to CODELIST_ETHNICITY. VN has 54 official ethnic groups. SENSITIVE DATA.
    constraints:
      reference: CODELIST_ETHNICITY
    metadata:
      pii: true
      sensitivity: high
      codeListValues: [KINH, TAY, THAI, MUONG, KHMER, HMONG, DAO, NGA, HANI, OTHER]
  
  - name: nativeLanguage
    type: string
    required: false
    description: Mother tongue / native language (Tiếng mẹ đẻ). Different from foreign language skills.
    constraints:
      reference: CODELIST_LANGUAGE
    metadata:
      codeListValues: [VIETNAMESE, ENGLISH, CHINESE, FRENCH, KHMER, HMONG, OTHER]
  
  # === CIVIL & ORIGIN (Citizenship & Birth) ===
  - name: primaryNationality
    type: string
    required: false
    description: Primary citizenship/nationality (Quốc tịch chính). Maps to CODELIST_COUNTRY (ISO 3166).
    constraints:
      reference: CODELIST_COUNTRY
      pattern: "^[A-Z]{2}$"
    metadata:
      pii: true
      sensitivity: medium
  
  - name: dualCitizenship
    type: string
    required: false
    description: Secondary citizenship if applicable (Quốc tịch thứ 2). Critical for expats and global mobility.
    constraints:
      reference: CODELIST_COUNTRY
      pattern: "^[A-Z]{2}$"
    metadata:
      pii: true
      sensitivity: medium
  
  - name: countryOfBirth
    type: string
    required: false
    description: Country where person was born (Quốc gia nơi sinh). May differ from nationality.
    constraints:
      reference: CODELIST_COUNTRY
      pattern: "^[A-Z]{2}$"
  
  - name: regionOfBirth
    type: string
    required: false
    description: Birth region/province (Tỉnh/Thành phố sinh). Maps to CODELIST_PROVINCE for VN.
    constraints:
      reference: CODELIST_PROVINCE
  
  - name: cityOfBirth
    type: string
    required: false
    description: Birth city/town (Nơi sinh). Free text or reference to CODELIST_CITY.
  
  - name: militaryStatus
    type: enum
    required: false
    description: Military service status (Tình trạng nghĩa vụ quân sự). Required in VN, Korea, etc.
    values: [NOT_APPLICABLE, COMPLETED, EXEMPTED, DEFERRED, IN_SERVICE, PREFER_NOT_TO_SAY]
    metadata:
      pii: true
      sensitivity: medium
  
  - name: dateOfDeath
    type: date
    required: false
    description: Date of death if applicable. Triggers DECEASED lifecycle state.
  
  - name: correspondenceLanguage
    type: string
    required: false
    description: Preferred communication language (Ngôn ngữ giao tiếp ưa thích). Maps to CODELIST_LANGUAGE.
    constraints:
      reference: CODELIST_LANGUAGE
  
  - name: hometownProvince
    type: string
    required: false
    description: Ancestral hometown province (Quê quán - VN specific)
  
  # === IDENTITY & DISPLAY (Performance Optimization) ===
  - name: preferredName
    type: string
    required: false
    description: Name preferred for informal addressing (e.g., "Tony" instead of "Anthony"). Denormalized for UI performance.
  
  - name: legalName
    type: json
    required: true
    description: Legal name structure (first, middle, last). Primary name used in official documents.
    schema:
      firstName: string (required)
      middleName: string (optional)
      lastName: string (required)
      nameType: enum (LEGAL, PREFERRED, LOCAL_SCRIPT, ALIAS)
    metadata:
      example: '{"firstName": "Nguy\u1ec5n", "middleName": "V\u0103n", "lastName": "An", "nameType": "LEGAL"}'
  
  - name: localName
    type: json
    required: false
    description: Local script name (e.g., Chinese characters, Khmer script). Optional for cultural representation.
    schema:
      firstName: string
      middleName: string
      lastName: string
      script: string (HAN, KHMER, THAI, etc.)
    metadata:
      example: '{"firstName": "\u962e", "middleName": "\u6587", "lastName": "\u5b89", "script": "HAN"}'
  
  - name: nameHistory
    type: array
    required: false
    description: Historical record of name changes (marriage, legal name change). Array of name change events for audit trail.
    schema:
      - effectiveDate: date (when name change became effective)
        changeReason: enum (MARRIAGE, LEGAL_CHANGE, CORRECTION, ADOPTION, OTHER)
        previousName: json (firstName, middleName, lastName)
        newName: json (firstName, middleName, lastName)
        documentReference: string (reference to supporting document ID)
        changedBy: string (user who recorded the change)
    metadata:
      example: '[{"effectiveDate": "2023-05-15", "changeReason": "MARRIAGE", "previousName": {"firstName": "Nguyễn", "middleName": "Thị", "lastName": "Lan"}, "newName": {"firstName": "Trần", "middleName": "Thị", "lastName": "Lan"}, "documentReference": "DOC-2023-001", "changedBy": "HR-ADMIN-01"}]'
  
  - name: photoUrl
    type: string
    required: false
    description: URL to current primary avatar image. Denormalized for list view performance without joining Photo table.
  
  - name: salutation
    type: enum
    required: false
    description: Formal title for professional communication (Ông, Bà, Tiến sĩ, Giáo sư)
    values: [MR, MS, MRS, DR, PROF, OTHER]
  
  - name: preferredPronouns
    type: enum
    required: false
    description: Preferred pronouns for DEI compliance and inclusive communication
    values: [HE_HIM, SHE_HER, THEY_THEM, OTHER, PREFER_NOT_TO_SAY]
  
  - name: universalId
    type: string
    required: false
    unique: true
    description: External identity system ID (Azure AD, Okta, Google Workspace) for SSO integration
  
  # === LEGAL & COMPLIANCE (Vietnam Decree 13 & Global) ===
  - name: privacyConsentStatus
    type: enum
    required: true
    description: Status of consent for personal data processing (Nghị định 13/2023)
    values: [PENDING, GRANTED, PARTIAL, DENIED, REVOKED]
  
  - name: privacyConsentDate
    type: datetime
    required: false
    description: Timestamp when consent was last granted or modified. Required for audit compliance.
  
  - name: taxResidenceCountry
    type: string
    required: false
    description: Country of tax residence (may differ from nationality). Critical for global payroll and tax reporting.
  
  - name: backgroundCheckStatus
    type: enum
    required: false
    description: Background verification status for risk management and compliance
    values: [NOT_REQUIRED, PENDING, IN_PROGRESS, CLEARED, FAILED, EXPIRED]
  
  - name: backgroundCheckDate
    type: date
    required: false
    description: Date of most recent background check. Some industries require annual re-verification.
  
  # === HEALTH & SAFETY (Manufacturing & Wellness) ===
  - name: biometricHash
    type: string
    required: false
    description: Hashed biometric identifier (fingerprint/face) for time attendance. Must be encrypted at rest.
  
  - name: uniformInfo
    type: json
    required: false
    description: Uniform sizes for automated provisioning. Structured JSON for manufacturing/logistics systems.
    schema:
      shirt: string (S, M, L, XL, XXL, XXXL)
      shoes: number (35-45 for VN sizing)
      hat: string (S, M, L)
      type: string (MALE, FEMALE, UNISEX)
    metadata:
      example: '{"shirt": "L", "shoes": 42, "hat": "M", "type": "MALE"}'
  
  - name: dietaryPreference
    type: enum
    required: false
    description: Dietary restrictions for catering and welfare programs
    values: [NONE, VEGETARIAN, VEGAN, HALAL, KOSHER, GLUTEN_FREE, LACTOSE_FREE, OTHER]
  
  # === TALENT SUMMARY (Denormalized for Analytics) ===
  - name: highestEducationLevel
    type: enum
    required: false
    description: Highest qualification attained. Denormalized from Qualification for fast filtering.
    values: [PRIMARY, SECONDARY, HIGH_SCHOOL, VOCATIONAL, ASSOCIATE, BACHELOR, MASTER, DOCTORATE, POST_DOCTORATE]
  
  - name: totalYearsOfExperience
    type: number
    required: false
    description: Total years of professional experience (self-declared + verified). Updated periodically.
    constraints:
      min: 0
      max: 60
  
  - name: lastActivityDate
    type: datetime
    required: false
    description: Last system interaction timestamp (login, profile update). Used for engagement analytics.
  
  # === PERSONALIZATION (Remote Work & UX) ===
  - name: timeZone
    type: string
    required: false
    description: Preferred working time zone (IANA format - Asia/Ho_Chi_Minh). Critical for remote/global teams.
  
  - name: locale
    type: string
    required: false
    description: Preferred locale for UI formatting (vi-VN, en-US). Controls date/number/currency display.
  
  - name: createdAt
    type: datetime
    required: true
    description: Record creation timestamp
  
  - name: updatedAt
    type: datetime
    required: true
    description: Last modification timestamp
  
  - name: createdBy
    type: string
    required: true
    description: User who created the record
  
  - name: updatedBy
    type: string
    required: true
    description: User who last modified the record

relationships:
  - name: hasNationalIds
    target: NationalId
    cardinality: one-to-many
    required: false
    inverse: belongsToWorker
    description: "National/Government ID documents (CCCD, CMND, Passport). INVERSE: NationalId.belongsToWorker must reference this Worker."
  
  - name: hasAddresses
    target: Address
    cardinality: one-to-many
    required: false
    inverse: belongsToWorker
    description: Address records (permanent, current, mailing)
  
  - name: hasContacts
    target: Contact
    cardinality: one-to-many
    required: false
    inverse: belongsToOwner
    description: "All contact information (phone, email, emergency contacts) for this worker. Contact uses polymorphic pattern with ownerType=WORKER and contactTypeCode (PHONE, EMAIL, EMERGENCY_CONTACT)."
  
  - name: hasCitizenships
    target: Citizenship
    cardinality: one-to-many
    required: false
    inverse: belongsToWorker
    description: Citizenship/Passport records
  
  - name: hasDisabilities
    target: Disability
    cardinality: one-to-many
    required: false
    inverse: belongsToWorker
    description: Disability records for accessibility
  
  - name: hasEmploymentRecords
    target: Employment
    cardinality: one-to-many
    required: false
    inverse: belongsToWorker
    description: "Employment relationship records. INVERSE: Employment.belongsToWorker must reference this Worker."
  
  - name: hasApplications
    target: Application
    cardinality: one-to-many
    required: false
    inverse: belongsToWorker
    description: "Job application records. INVERSE: Application.belongsToWorker must reference this Worker."
  
  - name: hasQualifications
    target: WorkerQualification
    cardinality: one-to-many
    required: false
    inverse: belongsToWorker
    description: "Education, certifications, licenses held by this worker."
  
  - name: hasRelationships
    target: WorkerRelationship
    cardinality: one-to-many
    required: false
    inverse: belongsToWorker
    description: "Family members, dependents, emergency contacts, beneficiaries."
  
  - name: hasSkills
    target: WorkerSkill
    cardinality: one-to-many
    required: false
    inverse: belongsToWorker
    description: "Skills possessed by this worker."
  
  - name: hasCompetencyAssessments
    target: WorkerCompetency
    cardinality: one-to-many
    required: false
    inverse: belongsToWorker
    description: "Competency assessments for this worker."

lifecycle:
  states: [ACTIVE, INACTIVE, DECEASED, MERGED]
  initial: ACTIVE
  terminal: [DECEASED, MERGED]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: No active employment
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
    - from: ACTIVE
      to: DECEASED
      trigger: recordDeath
    - from: INACTIVE
      to: DECEASED
      trigger: recordDeath
    - from: ACTIVE
      to: MERGED
      trigger: mergeDuplicate
      guard: Duplicate detected
    - from: INACTIVE
      to: MERGED
      trigger: mergeDuplicate
      guard: Duplicate detected

policies:
  # === AGE-BASED VALIDATION (VN Labor Code 2019) ===
  - name: DateOfBirthRequired
    type: validation
    rule: dateOfBirth is REQUIRED for all workers (needed for age-based validations)
    expression: "dateOfBirth IS NOT NULL"
  
  - name: MinimumWorkingAge
    type: validation
    rule: Worker must be at least 15 years old at time of hire (VN Labor Code Article 145)
    expression: "YEAR(CURRENT_DATE) - YEAR(dateOfBirth) >= 15"
  
  # === RETIREMENT TRACKING ===
  - name: RetirementEligibilityCalculation
    type: business
    rule: Auto-calculate retirementEligibilityDate when dateOfBirth or gender changes
    trigger: ON_UPDATE(dateOfBirth, gender)
  
  - name: RetirementStatusUpdate
    type: business
    rule: Auto-update retirementStatus when current date passes retirementEligibilityDate
    trigger: DAILY_BATCH
  
  - name: WorkingBeyondRetirementApproval
    type: business
    rule: Workers with retirementStatus=WORKING_BEYOND_RETIREMENT must have valid health certificate and employer approval
  
  # === WORK CAPACITY VALIDATION (VN Decree 88/2015) ===
  - name: WorkCapacityStatusCalculation
    type: business
    rule: Auto-calculate workCapacityStatus from workCapacityLossPercentage
    trigger: ON_UPDATE(workCapacityLossPercentage)
  
  - name: UnableToWorkRestriction
    type: validation
    rule: Workers with workCapacityStatus=UNABLE_TO_WORK cannot have ACTIVE employment
    expression: "workCapacityStatus = UNABLE_TO_WORK IMPLIES NOT EXISTS(Employment WHERE status = ACTIVE)"
  
  - name: WorkCapacityReassessment
    type: business
    rule: Work capacity must be reassessed every 5 years (VN Decree 88/2015)
    trigger: workCapacityAssessmentDate + 5 years
  
  - name: DisabilityStatusSync
    type: business
    rule: When workCapacityLossPercentage >= 61%, disabilityStatus should be REGISTERED
    trigger: ON_UPDATE(workCapacityLossPercentage)
  
  # === DATA PROTECTION & PRIVACY ===
  - name: PersonalDataProtection
    type: access
    rule: Personal data access requires explicit consent and role-based permissions
  
  - name: DataRetention
    type: retention
    rule: Worker records retained for 10 years after last employment termination (VN Labor Law)
  
  - name: SensitiveDataHandling
    type: access
    rule: Religion, ethnicity, disability, and LGBT fields are voluntary and require special protection
  
  - name: UniqueIdentifier
    type: validation
    rule: Worker ID must be globally unique across the system
    expression: "UNIQUE(id)"
  
  - name: DateOfBirthValidation
    type: validation
    rule: Date of birth must be in the past and person must be at least 15 years old (VN minimum working age)
    expression: "dateOfBirth < TODAY() AND AGE(dateOfBirth) >= 15"
  
  - name: MaritalStatusConsistency
    type: validation
    rule: If maritalStatus changes, maritalStatusDate must be updated
  
  - name: DeceasedImmutability
    type: business
    rule: Once status is DECEASED, no biographical data can be modified except by authorized personnel
  
  - name: MergedRedirection
    type: business
    rule: MERGED workers must have a reference to the target worker record
  
  # === ADDED: Privacy Consent Policies (Decree 13/2023) ===
  - name: PrivacyConsentRequired
    type: validation
    rule: privacyConsentStatus must be GRANTED before processing sensitive personal data
    expression: "privacyConsentStatus IN [GRANTED, PARTIAL]"
  
  - name: PrivacyConsentAudit
    type: business
    rule: Any change to privacyConsentStatus must update privacyConsentDate and log the change
  
  - name: PrivacyConsentRevocation
    type: business
    rule: When privacyConsentStatus changes to REVOKED, system must anonymize or delete non-essential personal data within 30 days
  
  # === ADDED: Biometric Security ===
  - name: BiometricEncryption
    type: access
    rule: biometricHash must be encrypted at rest using AES-256 and only accessible by authorized time attendance systems
  
  # === ADDED: Denormalization Consistency ===
  - name: PreferredNameSync
    type: business
    rule: When WorkerName with type=PREFERRED is updated, preferredName must be synchronized
  
  - name: PhotoUrlSync
    type: business
    rule: When primary Photo is updated, photoUrl must be synchronized
  
  - name: EducationLevelSync
    type: business
    rule: When new Qualification is added with higher level, highestEducationLevel must be updated
  
  # === ADDED: Personalization Defaults ===
  - name: LocaleInheritance
    type: business
    rule: If locale is not set, inherit from correspondenceLanguage or system default (vi-VN)
---

# Entity: Worker

## 1. Overview

The **Worker** entity represents an individual's fundamental identity and biographical data, independent of any employment relationship. It serves as the foundational layer upon which Employment, Application, and Contact entities are built. This separation follows the industry-standard pattern of decoupling personal identity from organizational relationships.

```mermaid
mindmap
  root((Worker))
    Identity
      id
      workerNumber
      universalId
      status
    Name & Display
      legalName (JSON)
      localName (JSON)
      preferredName
      photoUrl
      salutation
      preferredPronouns
    Biographical & Demographics
      dateOfBirth
      gender
      maritalStatus
      height
      weight
      smokingStatus
    Citizenship & Origin
      primaryNationality
      dualCitizenship
      countryOfBirth
      regionOfBirth
      militaryStatus
    Cultural & Social
      ethnicity
      religion
      nativeLanguage
    Contact Info
      hasAddresses
      hasContacts
    Legal & Compliance
      privacyConsentStatus
      taxResidenceCountry
      backgroundCheckStatus
      hasNationalIds
      hasCitizenships
    Health & Safety
      bloodType
      disabilityStatus
      biometricHash
      uniformInfo (JSON)
      dietaryPreference
    Talent Summary
      highestEducationLevel
      totalYearsOfExperience
      lastActivityDate
    Personalization
      timeZone
      locale
      correspondenceLanguage
    Relationships
      hasEmploymentRecords
      hasApplications
      hasContacts
    Lifecycle
      ACTIVE
      INACTIVE
      DECEASED
      MERGED
```

**Key Characteristics**:
- **Person-centric**: Contains only biographical/identity information
- **Reusable**: Same Worker can be an Employee, Applicant, or Contact
- **Date-independent**: Core identity attributes are not date-effective
- **Privacy-aware**: Sensitive fields (religion, ethnicity) are optional and protected

**Design Pattern**: Worker is separated from WorkerName to handle:
- Multiple name types (LEGAL, PREFERRED, LOCAL_SCRIPT)
- Date-effective name changes (marriage, legal changes)
- Cultural variations (Vietnamese vs Western naming conventions)

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique internal identifier (UUID) |
| workerNumber | string | | Human-readable worker ID (e.g., W001234) |
| status | enum | ✓ | Record status: ACTIVE, INACTIVE, DECEASED, MERGED |

### 2.2 Biographical Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| dateOfBirth | date | | Date of birth (Ngày sinh) |
| gender | enum | | MALE, FEMALE, OTHER, UNDISCLOSED |
| maritalStatus | enum | | SINGLE, MARRIED, DIVORCED, WIDOWED, SEPARATED |
| maritalStatusDate | date | | When marital status last changed |
| primaryNationality | string | | Primary citizenship (Country reference) |
| additionalNationalities | array | | Secondary citizenships |
| countryOfBirth | string | | Birth country (Country reference) |
| regionOfBirth | string | | Birth region/province |
| cityOfBirth | string | | Birth city/town |
| dateOfDeath | date | | Date of death if applicable |
| correspondenceLanguage | string | | Preferred communication language |

### 2.3 Health & Diversity Attributes (Optional)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| bloodType | enum | | A+, A-, B+, B-, O+, O-, AB+, AB- |
| religion | string | | Religious affiliation (voluntary) |
| ethnicity | string | | Ethnic group (VN: 54 official groups) |
| disabilityStatus | enum | | NONE, DISCLOSED, PREFER_NOT_TO_SAY |
| veteranStatus | enum | | Military veteran status |
| usesTobacco | boolean | | Tobacco use indicator |

### 2.4 Vietnam-Specific Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| hometownProvince | string | | Ancestral hometown (Quê quán) |

### 2.5 Identity & Display Attributes (Performance Optimization)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| preferredName | string | | Informal name for UI ("Tony" vs "Anthony") |
| photoUrl | string | | Avatar URL (denormalized for performance) |
| salutation | enum | | MR, MS, MRS, DR, PROF, OTHER |
| preferredPronouns | enum | | HE_HIM, SHE_HER, THEY_THEM, OTHER |
| universalId | string | | External SSO ID (Azure AD, Okta) |

### 2.6 Legal & Compliance Attributes (Decree 13 & Global)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| privacyConsentStatus | enum | ✓ | PENDING, GRANTED, PARTIAL, DENIED, REVOKED |
| privacyConsentDate | datetime | | When consent was granted/modified |
| taxResidenceCountry | string | | Tax residence (may differ from nationality) |
| backgroundCheckStatus | enum | | NOT_REQUIRED, PENDING, CLEARED, FAILED, EXPIRED |
| backgroundCheckDate | date | | Most recent background check date |

### 2.7 Health & Safety Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| biometricHash | string | | Hashed biometric for time attendance |
| uniformInfo | object | | Sizes: {shirt, shoes, hat, type} |
| dietaryPreference | enum | | VEGETARIAN, VEGAN, HALAL, KOSHER, etc. |

### 2.8 Talent Summary Attributes (Denormalized)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| highestEducationLevel | enum | | PRIMARY to POST_DOCTORATE |
| totalYearsOfExperience | number | | Total professional experience (years) |
| lastActivityDate | datetime | | Last system interaction |

### 2.9 Personalization Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| timeZone | string | | IANA time zone (Asia/Ho_Chi_Minh) |
| locale | string | | UI locale (vi-VN, en-US) |

### 2.10 Audit Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| createdAt | datetime | ✓ | Record creation timestamp |
| updatedAt | datetime | ✓ | Last modification timestamp |
| createdBy | string | ✓ | User who created record |
| updatedBy | string | ✓ | User who last modified |

---

## 3. Relationships

```mermaid
erDiagram
    Worker ||--o{ NationalId : hasNationalIds
    Worker ||--o{ Address : hasAddresses
    Worker ||--o{ Contact : hasContacts
    Worker ||--o{ Citizenship : hasCitizenships
    Worker ||--o{ Disability : hasDisabilities
    Worker ||--o{ Employment : hasEmploymentRecords
    Worker ||--o{ Application : hasApplications
    
    Worker {
        string id PK
        string workerNumber UK
        enum status
        date dateOfBirth
        enum gender
        json legalName
        json localName
        string preferredName
    }
    
    Contact {
        string id PK
        enum ownerType
        string ownerId FK
        enum contactTypeCode
        string phoneNumber
        string emailAddress
        string emergencyContactName
    }
    
    Employment {
        string id PK
        string workerId FK
        date hireDate
        enum status
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[NationalId]] | hasNationalIds | 1:N | Government IDs (CCCD, CMND, Passport) |
| [[Address]] | hasAddresses | 1:N | Address records (permanent, current) |
| [[Contact]] | hasContacts | 1:N | All contact info (phone, email, emergency) via polymorphic pattern |
| [[Citizenship]] | hasCitizenships | 1:N | Citizenship/Passport records |
| [[Disability]] | hasDisabilities | 1:N | Disability records |
| [[Employment]] | hasEmploymentRecords | 1:N | Employment relationships |
| [[Application]] | hasApplications | 1:N | Job application records |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create Worker
    
    ACTIVE --> INACTIVE: Deactivate
    INACTIVE --> ACTIVE: Reactivate
    
    ACTIVE --> DECEASED: Record Death
    INACTIVE --> DECEASED: Record Death
    
    ACTIVE --> MERGED: Merge Duplicate
    INACTIVE --> MERGED: Merge Duplicate
    
    DECEASED --> [*]
    MERGED --> [*]
    
    note right of ACTIVE
        Normal operational state
        Can have active employment
    end note
    
    note right of INACTIVE
        Temporarily inactive
        No active employment
    end note
    
    note right of DECEASED
        Person has passed away
        Terminal state
    end note
    
    note right of MERGED
        Duplicate merged into another
        Terminal state
    end note
```

### State Descriptions

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **ACTIVE** | Valid, active worker record | All operations allowed |
| **INACTIVE** | Temporarily inactive, no active employment | Limited updates, can reactivate |
| **DECEASED** | Person has passed away | Read-only except by authorized personnel |
| **MERGED** | Duplicate record merged into another | Read-only, redirects to target worker |

### Transition Rules

| From | To | Trigger | Guard Condition |
|------|-----|---------|-----------------|
| ACTIVE | INACTIVE | deactivate | No active employment |
| INACTIVE | ACTIVE | reactivate | - |
| ACTIVE | DECEASED | recordDeath | - |
| INACTIVE | DECEASED | recordDeath | - |
| ACTIVE | MERGED | mergeDuplicate | Duplicate detected |
| INACTIVE | MERGED | mergeDuplicate | Duplicate detected |

---

## 5. Business Rules Reference

### Data Protection & Privacy
- **PersonalDataProtection**: Personal data access requires explicit consent and role-based permissions (GDPR/VN Personal Data Protection Law)
- **SensitiveDataHandling**: Religion, ethnicity, disability fields are voluntary and require special protection
- **DataRetention**: Worker records retained for 10 years after last employment termination (VN Labor Law Article 33)
- **PrivacyConsentRequired**: `privacyConsentStatus` must be GRANTED before processing sensitive personal data (Nghị định 13/2023)
- **PrivacyConsentAudit**: Any change to `privacyConsentStatus` must update `privacyConsentDate` and create audit log
- **PrivacyConsentRevocation**: When consent is REVOKED, system must anonymize/delete non-essential data within 30 days

### Security & Access Control
- **BiometricEncryption**: `biometricHash` must be encrypted at rest (AES-256) and only accessible by authorized time attendance systems
- **UniversalIdUniqueness**: `universalId` must be globally unique across all identity systems (Azure AD, Okta, Google Workspace)

### Validation Rules
- **UniqueIdentifier**: Worker ID must be globally unique across the system
- **DateOfBirthValidation**: Date of birth must be in the past and person must be at least 15 years old (VN minimum working age per Labor Code 2019)
- **MaritalStatusConsistency**: If maritalStatus changes, maritalStatusDate must be updated
- **ExperienceValidation**: `totalYearsOfExperience` must be between 0 and 60 years

### Business Constraints
- **DeceasedImmutability**: Once status is DECEASED, no biographical data can be modified except by authorized personnel
- **MergedRedirection**: MERGED workers must have a reference to the target worker record

### Denormalization Consistency (Performance Optimization)
- **PreferredNameSync**: When WorkerName with type=PREFERRED is updated, `preferredName` must be synchronized
- **PhotoUrlSync**: When primary Photo is updated, `photoUrl` must be synchronized
- **EducationLevelSync**: When new Qualification is added with higher level, `highestEducationLevel` must be updated

### Personalization & UX
- **LocaleInheritance**: If `locale` is not set, inherit from `correspondenceLanguage` or system default (vi-VN)
- **TimeZoneDefault**: For VN-based workers, default `timeZone` to Asia/Ho_Chi_Minh if not specified

### Vietnam-Specific Rules
- **National ID Format**: CCCD must be 12 digits, CMND (old format) must be 9 digits
- **Ethnicity Classification**: Must use official 54 ethnic groups classification from Vietnamese government
- **Permanent Address**: Required for labor contract registration (Hộ khẩu thường trú)
- **Privacy Consent Mandatory**: All workers must have `privacyConsentStatus` set (cannot be NULL) per Decree 13/2023

### Related Business Rules Documents
- See `worker-management.brs.md` for complete business rules catalog
- See `personal-data-protection.brs.md` for data privacy rules (Decree 13/2023 compliance)
- See `vn-labor-compliance.brs.md` for Vietnam-specific requirements
- See `biometric-security.brs.md` for biometric data handling policies
- See `denormalization-sync.brs.md` for cache consistency rules

---

*Document Status: APPROVED - Enhanced with SCAMPER analysis (Identity, Compliance, Health, Talent, Personalization)*
