---
entity: WorkerRelationship
domain: person
version: "2.0.0"
status: draft
owner: Core HR Team
tags: [worker, relationship, link, emergency-contact, dependent, beneficiary]

# =============================================================================
# DESIGN PRINCIPLE: WorkerRelationship is a PURE LINK between two Workers
# 
# - NO PII stored here - PII lives on Worker entity
# - NO Contact info here - Contact info lives on Contact entity
# - This is an ASSOCIATION/JUNCTION table with FLAGS
# 
# Pattern: Worker A ←→ WorkerRelationship ←→ Worker B
#          └── is_emergency = true means B is emergency contact for A
# =============================================================================

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  # === LINK ENDPOINTS ===
  - name: workerId
    type: string
    required: true
    description: |
      FK → Worker.id. The subject worker (employee whose relationship this is).
      Example: If "A's wife is B", then workerId = A.
  
  - name: relatedWorkerId
    type: string
    required: true
    description: |
      FK → Worker.id. The related worker (the other person in the relationship).
      Example: If "A's wife is B", then relatedWorkerId = B.
      NOTE: Every related person MUST be a Worker. If you have PII, create Worker first.
  
  # === RELATIONSHIP TYPE ===
  - name: relationCode
    type: enum
    required: true
    description: |
      Type of relationship. References common.relationship_type.code.
      Relationship is FROM workerId TO relatedWorkerId.
      Example: relationCode = SPOUSE means relatedWorkerId is spouse of workerId.
    values: [SPOUSE, FATHER, MOTHER, SON, DAUGHTER, BROTHER, SISTER, GRANDFATHER, GRANDMOTHER, GRANDSON, GRANDDAUGHTER, FATHER_IN_LAW, MOTHER_IN_LAW, SON_IN_LAW, DAUGHTER_IN_LAW, GUARDIAN, DOMESTIC_PARTNER, OTHER]
  
  - name: relationDescription
    type: string
    required: false
    description: |
      Additional description for clarity.
      Examples: "Adopted son", "Step-mother", "Uncle from father's side"
    constraints:
      maxLength: 255
  
  # === FLAGS ===
  - name: isEmergency
    type: boolean
    required: true
    default: false
    description: |
      Is relatedWorkerId an emergency contact for workerId?
      If true, in emergency situations, contact relatedWorkerId.
  
  - name: emergencyPriority
    type: integer
    required: false
    description: |
      Priority order for emergency contacts.
      1 = Primary contact, 2 = Secondary, etc.
      Only relevant if isEmergency = true.
    constraints:
      min: 1
      max: 10
  
  - name: isDependentFlag
    type: boolean
    required: true
    default: false
    description: |
      Is relatedWorkerId a financial dependent of workerId?
      Used for tax deduction registration (giảm trừ gia cảnh).
  
  - name: isBeneficiaryFlag
    type: boolean
    required: true
    default: false
    description: |
      Is relatedWorkerId a beneficiary of workerId?
      Used for insurance, estate, retirement benefits.
  
  - name: beneficiaryPercentage
    type: decimal
    required: false
    description: |
      Percentage of benefit allocation for this beneficiary.
      Only relevant if isBeneficiaryFlag = true.
    constraints:
      min: 0
      max: 100
  
  - name: isVisaSponsorFlag
    type: boolean
    required: false
    default: false
    description: |
      Is workerId sponsoring relatedWorkerId for visa/relocation?
      Used for expatriate family relocation tracking.
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: |
      Additional flexible data.
      Examples:
        - marriageDate (for SPOUSE)
        - adoptionDate (for adopted children)
        - notes
  
  # === SCD TYPE-2 (Slowly Changing Dimension) ===
  - name: effectiveStartDate
    type: date
    required: true
    description: When this relationship record becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: When this relationship record ends (null = current)
  
  - name: isCurrentFlag
    type: boolean
    required: true
    default: true
    description: Is this the current/active version of the relationship?
  
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
  - name: fromWorker
    target: Worker
    cardinality: many-to-one
    required: true
    inverse: hasRelationships
    description: |
      The subject worker whose relationship this is.
      INVERSE: Worker.hasRelationships lists all relationships where this worker is the subject.
  
  - name: toWorker
    target: Worker
    cardinality: many-to-one
    required: true
    inverse: isRelatedTo
    description: |
      The related worker (other person in the relationship).
      INVERSE: Worker.isRelatedTo lists all relationships where this worker is the related person.

lifecycle:
  states: [ACTIVE, INACTIVE, DECEASED]
  initial: ACTIVE
  terminal: [DECEASED]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: Relationship no longer relevant (e.g., divorce, legal separation)
    - from: INACTIVE
      to: ACTIVE
      trigger: reactivate
      guard: Relationship restored
    - from: ACTIVE
      to: DECEASED
      trigger: recordDeceased
      guard: Related person has passed away

policies:
  # === UNIQUENESS ===
  - name: UniqueRelationshipPair
    type: validation
    rule: No duplicate active relationship between same two workers with same relation type
    expression: "UNIQUE(workerId, relatedWorkerId, relationCode, isCurrentFlag = true)"
    severity: ERROR
  
  # === EMERGENCY CONTACT ===
  - name: EmergencyContactHasPriority
    type: validation
    rule: If isEmergency = true, emergencyPriority should be set
    expression: "isEmergency = false OR emergencyPriority IS NOT NULL"
    severity: WARNING
  
  - name: AtLeastOneEmergencyContact
    type: business
    rule: Every active employee should have at least one emergency contact
    expression: "Each Worker with Employee status should have at least one WorkerRelationship with isEmergency = true"
    severity: WARNING
  
  # === SPOUSE ===
  - name: SpouseUnique
    type: business
    rule: Worker should have at most one current SPOUSE relationship
    expression: "COUNT(WorkerRelationship WHERE workerId = X AND relationCode = 'SPOUSE' AND isCurrentFlag = true) <= 1"
    severity: WARNING
  
  # === BENEFICIARY ===
  - name: BeneficiaryPercentageTotal
    type: business
    rule: Total beneficiary percentages for a worker should not exceed 100%
    expression: "SUM(beneficiaryPercentage WHERE workerId = X AND isBeneficiaryFlag = true AND isCurrentFlag = true) <= 100"
    severity: WARNING
  
  - name: BeneficiaryRequiresPercentage
    type: validation
    rule: If isBeneficiaryFlag = true, beneficiaryPercentage should be set
    expression: "isBeneficiaryFlag = false OR beneficiaryPercentage IS NOT NULL"
    severity: WARNING
  
  # === DEPENDENT ===
  - name: DependentRequiresWorkerDOB
    type: business
    rule: Dependent registration requires related worker to have date of birth
    expression: "For tax dependent, related Worker must have dateOfBirth"
    severity: WARNING
  
  # === SELF REFERENCE ===
  - name: NoSelfRelationship
    type: validation
    rule: Worker cannot have relationship with themselves
    expression: "workerId != relatedWorkerId"
    severity: ERROR
---

# Entity: WorkerRelationship

## 1. Overview

**WorkerRelationship** is a **PURE LINK (association) entity** that connects two Workers. It does NOT store PII - all person information lives on the Worker entity.

**Design Principle**:
```
WorkerRelationship = LINK between two Workers + FLAGS

- workerId → Subject Worker (A)
- relatedWorkerId → Related Worker (B)
- relationCode → What B is to A (e.g., SPOUSE)
- Flags → What role B plays for A (emergency, dependent, beneficiary)

PII Location:
- Name, DOB, gender → Worker entity
- Phone, email → Contact entity (belongs to Worker)
- Address → Address entity (belongs to Worker)
```

```mermaid
mindmap
  root((WorkerRelationship))
    LINK Endpoints
      workerId → Worker A
      relatedWorkerId → Worker B
    Relationship Type
      relationCode
        SPOUSE
        FATHER
        MOTHER
        SON
        DAUGHTER
        SIBLING
        IN_LAW
        GUARDIAN
        OTHER
      relationDescription
    FLAGS
      isEmergency
      emergencyPriority
      isDependentFlag
      isBeneficiaryFlag
      beneficiaryPercentage
      isVisaSponsorFlag
    Metadata
      metadata «JSONB»
    SCD Type-2
      effectiveStartDate
      effectiveEndDate
      isCurrentFlag
    Lifecycle
      ACTIVE
      INACTIVE
      DECEASED
```

**Key Design Decision**:
> Every related person MUST be a Worker in the system.
> If you have PII (name, DOB, phone), first create a Worker, then create the relationship.
> Contact info is fetched from the related Worker's Contact records.

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|-----------|
| id | UUID | ✓ | Unique identifier | person.worker_relationship.id |

### 2.2 Link Endpoints

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|-----------|
| workerId | UUID | ✓ | Subject worker (A) | person.worker_relationship.worker_id |
| relatedWorkerId | UUID | ✓ | Related worker (B) | person.worker_relationship.related_worker_id |

### 2.3 Relationship Type

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| relationCode | enum | ✓ | Type of relationship (SPOUSE, FATHER, MOTHER, etc.) |
| relationDescription | string | | Additional description |

**Relation Codes (Vietnamese)**:

| Code | English | Vietnamese |
|------|---------|------------|
| SPOUSE | Spouse | Vợ/Chồng |
| FATHER | Father | Cha/Bố |
| MOTHER | Mother | Mẹ |
| SON | Son | Con trai |
| DAUGHTER | Daughter | Con gái |
| BROTHER | Brother | Anh/Em trai |
| SISTER | Sister | Chị/Em gái |
| GRANDFATHER | Grandfather | Ông |
| GRANDMOTHER | Grandmother | Bà |
| GRANDSON | Grandson | Cháu trai |
| GRANDDAUGHTER | Granddaughter | Cháu gái |
| FATHER_IN_LAW | Father-in-law | Bố chồng/vợ |
| MOTHER_IN_LAW | Mother-in-law | Mẹ chồng/vợ |
| GUARDIAN | Guardian | Người giám hộ |
| DOMESTIC_PARTNER | Domestic Partner | Người chung sống |
| OTHER | Other | Khác |

### 2.4 Flags

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| isEmergency | boolean | ✓ | false | Is B emergency contact for A? |
| emergencyPriority | integer | | | Priority (1 = primary) |
| isDependentFlag | boolean | ✓ | false | Is B financial dependent of A? |
| isBeneficiaryFlag | boolean | ✓ | false | Is B beneficiary of A? |
| beneficiaryPercentage | decimal | | | % of benefits |
| isVisaSponsorFlag | boolean | | false | Is A sponsoring B for visa? |

### 2.5 SCD Type-2

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| effectiveStartDate | date | ✓ | When relationship becomes effective |
| effectiveEndDate | date | | When relationship ends |
| isCurrentFlag | boolean | ✓ | Is current version? |

---

## 3. Relationships

```mermaid
erDiagram
    Worker ||--o{ WorkerRelationship : "hasRelationships (as subject)"
    Worker ||--o{ WorkerRelationship : "isRelatedTo (as related)"
    
    WorkerRelationship {
        uuid id PK
        uuid workerId FK
        uuid relatedWorkerId FK
        enum relationCode
        boolean isEmergency
        int emergencyPriority
        boolean isDependentFlag
        boolean isBeneficiaryFlag
        decimal beneficiaryPercentage
    }
    
    Worker {
        uuid id PK
        string firstName
        string lastName
        date dateOfBirth
    }
```

### How to Get Emergency Contact Info

```sql
-- Get emergency contacts for Worker A with their contact info
SELECT 
    rw.first_name || ' ' || rw.last_name AS contact_name,
    wr.relation_code,
    wr.emergency_priority,
    c.contact_value AS phone
FROM person.worker_relationship wr
JOIN person.worker rw ON rw.id = wr.related_worker_id
LEFT JOIN person.contact c ON c.worker_id = rw.id 
    AND c.contact_type_code = 'MOBILE' 
    AND c.is_primary = true
WHERE wr.worker_id = 'worker-a-id'
  AND wr.is_emergency = true
  AND wr.is_current_flag = true
ORDER BY wr.emergency_priority;
```

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create Relationship
    
    ACTIVE --> INACTIVE: deactivate (divorce, separation)
    INACTIVE --> ACTIVE: reactivate
    ACTIVE --> DECEASED: recordDeceased
    
    DECEASED --> [*]
```

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **ACTIVE** | Current, valid relationship | Used for emergency, dependent, beneficiary |
| **INACTIVE** | Relationship ended (e.g., divorce) | Historical, not used for active lookups |
| **DECEASED** | Related person has passed away | Update beneficiary allocations |

---

## 5. Use Cases

### Use Case 1: Spouse as Emergency Contact

```yaml
# Worker A: Nguyễn Văn A (employee)
# Worker B: Nguyễn Thị B (A's wife, also in system)

WorkerRelationship:
  id: "wr-001"
  workerId: "worker-a-id"
  relatedWorkerId: "worker-b-id"
  relationCode: "SPOUSE"
  isEmergency: true
  emergencyPriority: 1
  isDependentFlag: false  # Wife has own income
  isBeneficiaryFlag: true
  beneficiaryPercentage: 50
  metadata:
    marriageDate: "2018-01-15"
  effectiveStartDate: "2018-01-15"
  isCurrentFlag: true
```

### Use Case 2: Child as Tax Dependent

```yaml
# Worker A: Nguyễn Văn A (employee)
# Worker C: Nguyễn Văn C (A's child, created as Worker)

WorkerRelationship:
  id: "wr-002"
  workerId: "worker-a-id"
  relatedWorkerId: "worker-c-id"
  relationCode: "SON"
  isEmergency: false
  isDependentFlag: true  # Child is dependent for tax
  isBeneficiaryFlag: true
  beneficiaryPercentage: 25
  effectiveStartDate: "2020-03-10"
  isCurrentFlag: true
```

### Use Case 3: Parent as Emergency Contact

```yaml
# Worker A: Nguyễn Văn A (employee)
# Worker D: Nguyễn Văn D (A's father)

WorkerRelationship:
  id: "wr-003"
  workerId: "worker-a-id"
  relatedWorkerId: "worker-d-id"
  relationCode: "FATHER"
  isEmergency: true
  emergencyPriority: 2  # Secondary emergency contact
  isDependentFlag: true  # Father has no income
  isBeneficiaryFlag: false
  effectiveStartDate: "2024-01-01"
  isCurrentFlag: true
```

---

## 6. Data Flow

### Creating a Related Person

```mermaid
flowchart LR
    A[Collect PII] --> B[Create Worker for related person]
    B --> C[Create Contact records for Worker]
    C --> D[Create WorkerRelationship link]
    D --> E[Set flags: emergency, dependent, beneficiary]
```

### Fetching Emergency Contacts

```mermaid
flowchart LR
    A[Worker A needs emergency contacts] --> B[Query WorkerRelationship where workerId = A and isEmergency = true]
    B --> C[Get relatedWorkerId]
    C --> D[Fetch Worker B details]
    D --> E[Fetch Contact records for Worker B]
    E --> F[Return name + phone]
```

---

## 7. Business Rules Reference

| Rule | Description |
|------|-------------|
| **UniqueRelationshipPair** | No duplicate active relationships |
| **SpouseUnique** | Max 1 current spouse |
| **BeneficiaryPercentageTotal** | Sum ≤ 100% |
| **NoSelfRelationship** | Cannot relate to self |
| **AtLeastOneEmergencyContact** | Every employee should have emergency contact |

### Related Documents

- [[Worker.onto.md]] - Person information
- [[Contact.onto.md]] - Contact information
- [[DependentRegistration.flow.md]] - Tax dependent registration flow

---

*Document Status: DRAFT v2.0.0*  
*Refactored: Removed inline PII, converted to pure LINK pattern*  
*References: DBML 1.Core.V4 lines 640-656*
