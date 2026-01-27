---
entity: WorkerRelationship
domain: person
version: "1.0.0"
status: approved
owner: Core HR Team
tags: [worker, relationship, dependent, family, emergency-contact, beneficiary]

# NOTE: WorkerRelationship stores family members, dependents, emergency contacts, and beneficiaries.
# Used for:
#   - Tax: Dependent registration (PIT deduction)
#   - Benefits: Health insurance, life insurance beneficiaries
#   - Emergency: Emergency contact information
#   - Visa: Visa sponsorship for family relocation

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  - name: workerId
    type: string
    required: true
    description: FK → Worker.id. The worker (main subject) of this relationship.
  
  - name: relatedWorkerId
    type: string
    required: false
    description: FK → Worker.id. If the related person is also a Worker in the system.
  
  # === RELATED PERSON INFO ===
  - name: fullName
    type: string
    required: false
    description: Full name of related person (if not linked to Worker record)
    constraints:
      maxLength: 255
  
  - name: dateOfBirth
    type: date
    required: false
    description: Date of birth of related person
  
  - name: gender
    type: enum
    required: false
    description: Gender of related person
    values: [MALE, FEMALE, OTHER, UNDISCLOSED]
  
  - name: nationalId
    type: string
    required: false
    description: National ID/CCCD of related person (for tax registration)
    constraints:
      maxLength: 50
  
  - name: taxCode
    type: string
    required: false
    description: Personal tax code (MST cá nhân)
    constraints:
      maxLength: 20
  
  # === RELATIONSHIP TYPE ===
  - name: relationCode
    type: enum
    required: true
    description: Type of relationship to the worker
    values: [SPOUSE, CHILD, PARENT, SIBLING, GRANDPARENT, GRANDCHILD, IN_LAW, OTHER_FAMILY, GUARDIAN, DOMESTIC_PARTNER, OTHER]
    # SPOUSE = Vợ/Chồng
    # CHILD = Con
    # PARENT = Bố/Mẹ
    # SIBLING = Anh/Chị/Em
    # GRANDPARENT = Ông/Bà
    # GRANDCHILD = Cháu
    # IN_LAW = Bố/Mẹ/Anh/Chị vợ/chồng
    # GUARDIAN = Người giám hộ
    # DOMESTIC_PARTNER = Người chung sống
    # OTHER = Khác
  
  - name: relationDescription
    type: string
    required: false
    description: Detailed description (e.g., "Father-in-law", "Adopted child")
    constraints:
      maxLength: 100
  
  # === FLAGS ===
  - name: isEmergencyContact
    type: boolean
    required: true
    default: false
    description: Is this person an emergency contact?
  
  - name: emergencyContactPriority
    type: integer
    required: false
    description: Priority order for emergency contacts (1 = primary)
    constraints:
      min: 1
      max: 10
  
  - name: isDependentFlag
    type: boolean
    required: true
    default: false
    description: Is this person a financial dependent (for tax/benefits)?
  
  - name: isBeneficiaryFlag
    type: boolean
    required: true
    default: false
    description: Is this person a beneficiary (insurance, estate)?
  
  - name: beneficiaryPercentage
    type: decimal
    required: false
    description: Percentage of benefit allocation for this beneficiary
    constraints:
      min: 0
      max: 100
  
  - name: isVisaSponsorFlag
    type: boolean
    required: false
    default: false
    description: Is this person being sponsored for visa/relocation?
  
  # === CONTACT INFO (Inline) ===
  - name: phoneNumber
    type: string
    required: false
    description: Primary phone number
    constraints:
      maxLength: 20
  
  - name: email
    type: string
    required: false
    description: Email address
    constraints:
      maxLength: 255
  
  - name: addressLine
    type: string
    required: false
    description: Address (brief)
    constraints:
      maxLength: 500
  
  # === SCD TYPE-2 ===
  - name: effectiveStartDate
    type: date
    required: true
    description: When this relationship becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: When this relationship ends (null = current)
  
  - name: isCurrent
    type: boolean
    required: true
    default: true
    description: Is this the current version?
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional data (marriage date, adoption date, notes, etc.)
  
  # === AUDIT ===
  - name: createdAt
    type: datetime
    required: true
    description: Record creation timestamp
  
  - name: updatedAt
    type: datetime
    required: false
    description: Last modification timestamp

relationships:
  - name: belongsToWorker
    target: Worker
    cardinality: many-to-one
    required: true
    inverse: hasRelationships
    description: The worker whose relationship this is.
  
  - name: relatedWorker
    target: Worker
    cardinality: many-to-one
    required: false
    description: The related worker (if they are also in the system).
  
  - name: hasContacts
    target: WorkerRelationshipContact
    cardinality: one-to-many
    required: false
    inverse: belongsToRelationship
    description: Additional contact methods for this related person.
  
  - name: hasDependentRegistrations
    target: DependentRegistration
    cardinality: one-to-many
    required: false
    inverse: forRelationship
    description: Tax dependent registrations linked to this relationship.

lifecycle:
  states: [ACTIVE, INACTIVE, DECEASED]
  initial: ACTIVE
  terminal: [DECEASED]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: Relationship no longer relevant (e.g., divorce)
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
    - from: ACTIVE
      to: DECEASED
      trigger: recordDeceased
      guard: Related person has passed away

policies:
  - name: UniqueRelationshipPerWorker
    type: validation
    rule: No duplicate relationship per worker
    expression: "UNIQUE(workerId, relationCode, fullName, dateOfBirth)"
    severity: WARNING
  
  - name: EmergencyContactRequiresPhone
    type: validation
    rule: Emergency contacts should have phone number
    expression: "isEmergencyContact = false OR phoneNumber IS NOT NULL"
    severity: WARNING
  
  - name: DependentRequiresDOB
    type: validation
    rule: Dependents need date of birth for tax purposes
    expression: "isDependentFlag = false OR dateOfBirth IS NOT NULL"
    severity: WARNING
  
  - name: BeneficiaryPercentageTotal
    type: business
    rule: Total beneficiary percentages should not exceed 100%
    severity: WARNING
  
  - name: SpouseUnique
    type: business
    rule: Worker should have only one current spouse
    expression: "relationCode != 'SPOUSE' OR COUNT(workerId WHERE relationCode = 'SPOUSE' AND isCurrent = true) <= 1"
    severity: WARNING
---

# Entity: WorkerRelationship

## 1. Overview

**WorkerRelationship** stores information about a worker's family members, emergency contacts, dependents, and beneficiaries. This entity supports multiple use cases across HR operations.

```mermaid
mindmap
  root((WorkerRelationship))
    Relationship Types
      SPOUSE
      CHILD
      PARENT
      SIBLING
      OTHER
    Flags
      isEmergencyContact
      isDependentFlag
      isBeneficiaryFlag
      isVisaSponsorFlag
    Person Info
      fullName
      dateOfBirth
      nationalId
      taxCode
    Contact
      phoneNumber
      email
      addressLine
    Use Cases
      Tax Dependent
      Emergency Contact
      Insurance Beneficiary
      Visa Sponsorship
```

### Use Cases

| Use Case | Flags | Purpose |
|----------|-------|---------|
| **Emergency Contact** | isEmergencyContact = true | Who to call in emergencies |
| **Tax Dependent** | isDependentFlag = true | PIT deduction registration |
| **Insurance Beneficiary** | isBeneficiaryFlag = true | Life insurance, estate |
| **Visa Sponsorship** | isVisaSponsorFlag = true | Expat family relocation |

### Relationship Types (Vietnamese)

| Code | English | Vietnamese |
|------|---------|------------|
| SPOUSE | Spouse | Vợ/Chồng |
| CHILD | Child | Con |
| PARENT | Parent | Bố/Mẹ |
| SIBLING | Sibling | Anh/Chị/Em |
| GRANDPARENT | Grandparent | Ông/Bà |
| GRANDCHILD | Grandchild | Cháu |
| IN_LAW | In-law | Bố/Mẹ/Anh/Chị vợ/chồng |
| GUARDIAN | Guardian | Người giám hộ |
| DOMESTIC_PARTNER | Domestic Partner | Người chung sống |

---

## 2. Attributes

### Identity

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier (UUID) |
| workerId | string | ✓ | FK → [[Worker]] |
| relatedWorkerId | string | | FK → [[Worker]] (if also employee) |

### Person Info

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| fullName | string | | Full name |
| dateOfBirth | date | | DOB |
| gender | enum | | MALE, FEMALE, OTHER |
| nationalId | string | | CCCD/CMND |
| taxCode | string | | MST cá nhân |

### Relationship

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| relationCode | enum | ✓ | SPOUSE, CHILD, PARENT, etc. |
| relationDescription | string | | Detailed description |

### Flags

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isEmergencyContact | boolean | ✓ | Emergency contact? |
| emergencyContactPriority | integer | | 1 = primary |
| isDependentFlag | boolean | ✓ | Tax dependent? |
| isBeneficiaryFlag | boolean | ✓ | Insurance beneficiary? |
| beneficiaryPercentage | decimal | | % allocation |
| isVisaSponsorFlag | boolean | | Visa sponsorship? |

---

## 3. Relationships

```mermaid
erDiagram
    Worker ||--o{ WorkerRelationship : hasRelationships
    Worker ||--o{ WorkerRelationship : "is related to"
    WorkerRelationship ||--o{ WorkerRelationshipContact : hasContacts
    WorkerRelationship ||--o{ DependentRegistration : hasDependentRegistrations
    
    WorkerRelationship {
        string id PK
        string workerId FK
        string relatedWorkerId FK
        string fullName
        date dateOfBirth
        enum relationCode
        boolean isEmergencyContact
        boolean isDependentFlag
        boolean isBeneficiaryFlag
    }
```

---

## 4. Use Cases

### Emergency Contact - Spouse

```yaml
WorkerRelationship:
  workerId: "worker-001"
  fullName: "Nguyễn Thị B"
  dateOfBirth: "1992-05-15"
  gender: "FEMALE"
  relationCode: "SPOUSE"
  isEmergencyContact: true
  emergencyContactPriority: 1
  isDependentFlag: false
  isBeneficiaryFlag: true
  beneficiaryPercentage: 50
  phoneNumber: "+84-909-123-456"
  email: "nguyenthib@email.com"
  effectiveStartDate: "2018-01-15"
  isCurrent: true
  metadata:
    marriageDate: "2018-01-15"
```

### Tax Dependent - Child

```yaml
WorkerRelationship:
  workerId: "worker-001"
  fullName: "Nguyễn Văn C"
  dateOfBirth: "2020-03-10"
  gender: "MALE"
  relationCode: "CHILD"
  isEmergencyContact: false
  isDependentFlag: true
  isBeneficiaryFlag: true
  beneficiaryPercentage: 25
  nationalId: null  # child, not yet issued
  effectiveStartDate: "2020-03-10"
  isCurrent: true
  metadata:
    birthCertificateNumber: "XXXX-YYYY"
```

### Parent - Tax Dependent

```yaml
WorkerRelationship:
  workerId: "worker-001"
  fullName: "Nguyễn Văn A Sr."
  dateOfBirth: "1955-08-20"
  gender: "MALE"
  nationalId: "024055012345"
  taxCode: "8012345678"
  relationCode: "PARENT"
  relationDescription: "Father"
  isEmergencyContact: false
  isDependentFlag: true  # Registered for PIT deduction
  isBeneficiaryFlag: false
  effectiveStartDate: "2024-01-01"
  isCurrent: true
  metadata:
    incomeStatus: "No income"
    residingWith: true
```

---

## 5. Tax Dependent Registration Flow

```mermaid
flowchart LR
    A[Worker adds Relationship] --> B{isDependentFlag?}
    B -->|Yes| C[Create DependentRegistration]
    C --> D[Submit to Tax Authority]
    D --> E{Approved?}
    E -->|Yes| F[PIT Deduction Applied]
    E -->|No| G[Rejected - Fix & Resubmit]
    B -->|No| H[No Tax Impact]
```

---

*Document Status: APPROVED*  
*References: [[Worker]], [[DependentRegistration]], [[WorkerRelationshipContact]]*
