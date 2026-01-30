---
entity: Contact
domain: person
version: "2.0.0"
status: draft
owner: Core HR Team
tags: [contact, phone, email, communication, pii]

# =============================================================================
# DESIGN PRINCIPLE: Contact stores communication methods for a Worker
# 
# - PHONE: Phone numbers (mobile, home, work)
# - EMAIL: Email addresses (personal, work)
# 
# NOTE: Emergency contact is NOT a contact type.
# Emergency contact is a FLAG on WorkerRelationship.
# Contact info for emergency person is fetched from their Worker.Contact records.
# =============================================================================

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  # === OWNER REFERENCE ===
  - name: workerId
    type: string
    required: true
    description: FK → Worker.id. The worker who owns this contact.
  
  # === CONTACT TYPE ===
  - name: contactTypeCode
    type: enum
    required: true
    description: |
      Type of contact method. References common.contact_type.code.
      Only communication methods - NOT relationship types.
    values: [PHONE, EMAIL]
  
  - name: isPrimary
    type: boolean
    required: true
    default: false
    description: Is this the primary contact of this type for the worker?
  
  # === PHONE ATTRIBUTES (when contactTypeCode = PHONE) ===
  - name: phoneTypeCode
    type: enum
    required: false
    description: Type of phone number (required if contactTypeCode = PHONE)
    values: [MOBILE, HOME, WORK, FAX, OTHER]
  
  - name: phoneNumber
    type: string
    required: false
    description: Complete phone number (required if contactTypeCode = PHONE)
    constraints:
      maxLength: 30
    pii: true
  
  - name: countryCode
    type: string
    required: false
    description: Country dialing code (e.g., +84 for VN)
    constraints:
      maxLength: 5
  
  - name: areaCode
    type: string
    required: false
    description: Area code (for landlines)
    constraints:
      maxLength: 10
  
  - name: extension
    type: string
    required: false
    description: Phone extension
    constraints:
      maxLength: 10
  
  - name: deviceTypeCode
    type: enum
    required: false
    description: Device type for phone
    values: [MOBILE, LANDLINE]
  
  # === EMAIL ATTRIBUTES (when contactTypeCode = EMAIL) ===
  - name: emailTypeCode
    type: enum
    required: false
    description: Type of email (required if contactTypeCode = EMAIL)
    values: [PERSONAL, WORK, OTHER]
  
  - name: emailAddress
    type: string
    required: false
    description: Email address (required if contactTypeCode = EMAIL)
    constraints:
      maxLength: 254
      pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    pii: true
  
  # === VERIFICATION ===
  - name: isVerified
    type: boolean
    required: true
    default: false
    description: Has this contact been verified?
  
  - name: verifiedAt
    type: datetime
    required: false
    description: When contact was verified
  
  # === VISIBILITY ===
  - name: isPublic
    type: boolean
    required: true
    default: false
    description: Is this contact publicly visible (company directory)?
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data
  
  # === SCD TYPE-2 ===
  - name: effectiveStartDate
    type: date
    required: true
    description: When this contact becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: When this contact ends (null = current)
  
  - name: isCurrentFlag
    type: boolean
    required: true
    default: true
    description: Is this the current/active version?
  
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
    inverse: hasContacts
    description: |
      The worker who owns this contact.
      INVERSE: Worker.hasContacts lists all contact records.

lifecycle:
  states: [ACTIVE, INACTIVE]
  initial: ACTIVE
  terminal: [INACTIVE]
  transitions:
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: Contact no longer valid

policies:
  # === PRIMARY UNIQUENESS ===
  - name: OnePrimaryPerType
    type: validation
    rule: Worker can have at most ONE primary contact per type
    expression: "COUNT(Contact WHERE workerId = X AND contactTypeCode = Y AND isPrimary = true AND isCurrentFlag = true) <= 1"
    severity: ERROR
  
  # === PHONE VALIDATION ===
  - name: PhoneAttributesRequired
    type: validation
    rule: If contactTypeCode = PHONE, phoneTypeCode and phoneNumber are required
    expression: "contactTypeCode != 'PHONE' OR (phoneTypeCode IS NOT NULL AND phoneNumber IS NOT NULL)"
    severity: ERROR
  
  # === EMAIL VALIDATION ===
  - name: EmailAttributesRequired
    type: validation
    rule: If contactTypeCode = EMAIL, emailTypeCode and emailAddress are required
    expression: "contactTypeCode != 'EMAIL' OR (emailTypeCode IS NOT NULL AND emailAddress IS NOT NULL)"
    severity: ERROR
  
  - name: EmailFormatValidation
    type: validation
    rule: Email address must be valid format
    expression: "emailAddress IS NULL OR REGEXP_MATCH(emailAddress, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$')"
    severity: ERROR
  
  # === VN PHONE FORMAT ===
  - name: VNMobileFormat
    type: business
    rule: VN mobile should be 10 digits starting with 09x, 03x, 07x, 08x
    expression: "countryCode != '+84' OR deviceTypeCode != 'MOBILE' OR REGEXP_MATCH(phoneNumber, '^(09|03|07|08)[0-9]{8}$')"
    severity: WARNING
  
  # === EMPLOYEE REQUIREMENTS ===
  - name: EmployeeShouldHavePrimaryMobile
    type: business
    rule: Every active employee should have at least one primary mobile phone
    expression: "Employee should have Contact with contactTypeCode = PHONE and phoneTypeCode = MOBILE and isPrimary = true"
    severity: WARNING
  
  - name: EmployeeShouldHaveWorkEmail
    type: business
    rule: Active employee should have work email
    expression: "Employee should have Contact with contactTypeCode = EMAIL and emailTypeCode = WORK"
    severity: WARNING
---

# Entity: Contact

## 1. Overview

**Contact** entity stores communication methods for a Worker. It supports two contact types: **PHONE** and **EMAIL**.

**Design Principle**:
```
Contact = Communication method for a Worker

Contact Types:
- PHONE: Phone numbers (mobile, home, work, fax)
- EMAIL: Email addresses (personal, work)

NOT a contact type (handled elsewhere):
- EMERGENCY_CONTACT → This is a FLAG on WorkerRelationship
  Emergency info is fetched from related Worker's Contact records
```

```mermaid
mindmap
  root((Contact))
    Identity
      id
      workerId
    Contact Type
      contactTypeCode
        PHONE
        EMAIL
      isPrimary
    Phone Attributes
      phoneTypeCode
        MOBILE
        HOME
        WORK
        FAX
        OTHER
      phoneNumber «PII»
      countryCode
      areaCode
      extension
      deviceTypeCode
    Email Attributes
      emailTypeCode
        PERSONAL
        WORK
        OTHER
      emailAddress «PII»
    Verification
      isVerified
      verifiedAt
    Visibility
      isPublic
    SCD Type-2
      effectiveStartDate
      effectiveEndDate
      isCurrentFlag
    Lifecycle
      ACTIVE
      INACTIVE
```

**Key Design Decision**:
> Emergency Contact is NOT a contact type.
> Emergency contact is a FLAG (`isEmergency`) on `WorkerRelationship`.
> When you need emergency contact phone → Find relationship → Get related Worker → Get their Contact.

---

## 2. Attributes

### 2.1 Identity

| Attribute | Type | Required | Description | DB Column |
|-----------|------|----------|-------------|-----------|
| id | UUID | ✓ | Unique identifier | person.contact.id |
| workerId | UUID | ✓ | Owner worker | person.contact.worker_id |

### 2.2 Contact Type

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| contactTypeCode | enum | ✓ | PHONE or EMAIL |
| isPrimary | boolean | ✓ | Is primary for this type? |

### 2.3 Phone Attributes (when contactTypeCode = PHONE)

| Attribute | Type | Required | Description | PII |
|-----------|------|----------|-------------|-----|
| phoneTypeCode | enum | ✓* | MOBILE, HOME, WORK, FAX, OTHER | |
| phoneNumber | string | ✓* | Complete phone number | ✓ |
| countryCode | string | | Country code (+84) | |
| areaCode | string | | Area code | |
| extension | string | | Extension | |
| deviceTypeCode | enum | | MOBILE, LANDLINE | |

*Required if contactTypeCode = PHONE

**VN Phone Formats**:

| Type | Format | Example |
|------|--------|---------|
| Mobile | 10 digits: 09x, 03x, 07x, 08x | 0901234567 |
| Landline | Area code + number | 028-1234-5678 (HCM) |
| Country code | +84 | +84901234567 |

### 2.4 Email Attributes (when contactTypeCode = EMAIL)

| Attribute | Type | Required | Description | PII |
|-----------|------|----------|-------------|-----|
| emailTypeCode | enum | ✓* | PERSONAL, WORK, OTHER | |
| emailAddress | string | ✓* | Email address | ✓ |

*Required if contactTypeCode = EMAIL

### 2.5 Verification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isVerified | boolean | ✓ | Has been verified? |
| verifiedAt | datetime | | Verification timestamp |

### 2.6 Visibility

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isPublic | boolean | ✓ | Visible in company directory? |

### 2.7 SCD Type-2

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| effectiveStartDate | date | ✓ | When contact becomes effective |
| effectiveEndDate | date | | When contact ends |
| isCurrentFlag | boolean | ✓ | Is current version? |

---

## 3. Relationships

```mermaid
erDiagram
    Worker ||--o{ Contact : hasContacts
    
    Contact {
        uuid id PK
        uuid workerId FK
        enum contactTypeCode
        enum phoneTypeCode
        string phoneNumber
        enum emailTypeCode
        string emailAddress
        boolean isPrimary
        boolean isVerified
    }
    
    Worker {
        uuid id PK
        string firstName
        string lastName
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Worker]] | belongsToWorker | N:1 | Contact owner |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create Contact
    
    ACTIVE --> INACTIVE: deactivate (no longer valid)
    
    INACTIVE --> [*]
    
    note right of ACTIVE
        Currently valid contact
        Used for communication
    end note
```

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **ACTIVE** | Currently valid | Can deactivate |
| **INACTIVE** | No longer valid | Read-only, historical |

---

## 5. Use Cases

### Use Case 1: Worker Mobile Phone

```yaml
Contact:
  id: "contact-001"
  workerId: "worker-001"
  contactTypeCode: "PHONE"
  isPrimary: true
  phoneTypeCode: "MOBILE"
  phoneNumber: "0901234567"
  countryCode: "+84"
  deviceTypeCode: "MOBILE"
  isVerified: true
  isPublic: false
  effectiveStartDate: "2024-01-01"
  isCurrentFlag: true
```

### Use Case 2: Work Email

```yaml
Contact:
  id: "contact-002"
  workerId: "worker-001"
  contactTypeCode: "EMAIL"
  isPrimary: true
  emailTypeCode: "WORK"
  emailAddress: "nguyen.van.a@company.com"
  isVerified: true
  isPublic: true  # Visible in directory
  effectiveStartDate: "2024-01-01"
  isCurrentFlag: true
```

### Use Case 3: Home Landline

```yaml
Contact:
  id: "contact-003"
  workerId: "worker-001"
  contactTypeCode: "PHONE"
  isPrimary: false
  phoneTypeCode: "HOME"
  phoneNumber: "028-1234-5678"
  countryCode: "+84"
  areaCode: "028"
  deviceTypeCode: "LANDLINE"
  isVerified: false
  isPublic: false
  effectiveStartDate: "2024-01-01"
  isCurrentFlag: true
```

---

## 6. Emergency Contact Pattern

**Important**: Emergency contact is NOT a contact type. See [[WorkerRelationship.onto.md]].

### How to Get Emergency Contact Phone

```sql
-- Get emergency contact phone for Worker A
SELECT 
    w_related.first_name || ' ' || w_related.last_name AS emergency_contact_name,
    wr.relation_code,
    c.phone_number AS emergency_phone,
    wr.emergency_priority
FROM person.worker_relationship wr
JOIN person.worker w_related ON w_related.id = wr.related_worker_id
LEFT JOIN person.contact c ON c.worker_id = w_related.id 
    AND c.contact_type_code = 'PHONE'
    AND c.phone_type_code = 'MOBILE'
    AND c.is_primary = true
    AND c.is_current_flag = true
WHERE wr.worker_id = :worker_a_id
  AND wr.is_emergency = true
  AND wr.is_current_flag = true
ORDER BY wr.emergency_priority;
```

---

## 7. Business Rules Reference

| Rule | Description |
|------|-------------|
| **OnePrimaryPerType** | Max 1 primary contact per type |
| **PhoneAttributesRequired** | Phone type and number required for PHONE |
| **EmailAttributesRequired** | Email type and address required for EMAIL |
| **EmailFormatValidation** | Valid email format |
| **VNMobileFormat** | VN mobile: 09x, 03x, 07x, 08x (10 digits) |
| **EmployeeShouldHavePrimaryMobile** | Employee should have mobile |
| **EmployeeShouldHaveWorkEmail** | Employee should have work email |

### Related Documents

- [[Worker.onto.md]] - Person information
- [[WorkerRelationship.onto.md]] - Emergency contact flag

---

*Document Status: DRAFT v2.0.0*  
*Refactored: Removed EMERGENCY_CONTACT type. Emergency is flag on WorkerRelationship.*  
*References: DBML 1.Core.V4 lines 582-594*
