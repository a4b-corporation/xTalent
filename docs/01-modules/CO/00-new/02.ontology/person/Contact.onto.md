---
entity: Contact
domain: common
version: "1.0.0"
status: approved
owner: Common Domain Team
tags: [contact, phone, email, emergency, communication]

attributes:
  # === IDENTITY ===
  - name: id
    type: string
    required: true
    unique: true
    description: Unique internal identifier (UUID format)
  
  # === OWNER REFERENCE (Polymorphic) ===
  - name: ownerType
    type: enum
    required: true
    description: Type of entity that owns this contact
    values: [WORKER, EMPLOYEE, LEGAL_ENTITY, BUSINESS_UNIT]
  
  - name: ownerId
    type: string
    required: true
    description: Reference to owner entity (polymorphic - Worker, Employee, LegalEntity, or BusinessUnit)
  
  # === CONTACT TYPE ===
  - name: contactTypeCode
    type: enum
    required: true
    description: Type of contact information
    values: [PHONE, EMAIL, EMERGENCY_CONTACT]
  
  - name: isPrimary
    type: boolean
    required: true
    default: false
    description: Is this the primary contact of this type for the owner?
  
  # === PHONE ATTRIBUTES (when contactTypeCode = PHONE) ===
  - name: phoneTypeCode
    type: enum
    required: false
    description: Type of phone number (required if contactTypeCode = PHONE)
    values: [HOME, MOBILE, WORK, FAX, OTHER]
  
  - name: phoneNumber
    type: string
    required: false
    description: Complete phone number (required if contactTypeCode = PHONE)
    constraints:
      maxLength: 30
    metadata:
      pii: true
      sensitivity: medium
  
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
    description: Device type
    values: [MOBILE, LANDLINE]
  
  # === EMAIL ATTRIBUTES (when contactTypeCode = EMAIL) ===
  - name: emailTypeCode
    type: enum
    required: false
    description: Type of email (required if contactTypeCode = EMAIL)
    values: [HOME, WORK, OTHER]
  
  - name: emailAddress
    type: string
    required: false
    description: Email address (required if contactTypeCode = EMAIL)
    constraints:
      maxLength: 254
      pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    metadata:
      pii: true
      sensitivity: medium
  
  # === EMERGENCY CONTACT ATTRIBUTES (when contactTypeCode = EMERGENCY_CONTACT) ===
  - name: emergencyContactName
    type: string
    required: false
    description: Emergency contact person name (required if contactTypeCode = EMERGENCY_CONTACT)
    constraints:
      maxLength: 200
    metadata:
      pii: true
      sensitivity: medium
  
  - name: relationshipCode
    type: enum
    required: false
    description: Relationship to owner (required if contactTypeCode = EMERGENCY_CONTACT)
    values: [SPOUSE, PARENT, CHILD, SIBLING, FRIEND, OTHER]
  
  - name: emergencyPrimaryPhone
    type: string
    required: false
    description: Primary phone for emergency contact (required if contactTypeCode = EMERGENCY_CONTACT)
    constraints:
      maxLength: 30
    metadata:
      pii: true
      sensitivity: high
  
  - name: emergencyAlternatePhone
    type: string
    required: false
    description: Alternate phone for emergency contact
    constraints:
      maxLength: 30
    metadata:
      pii: true
      sensitivity: high
  
  - name: emergencyAddress
    type: string
    required: false
    description: Address of emergency contact
    constraints:
      maxLength: 500
    metadata:
      pii: true
      sensitivity: medium
  
  - name: emergencyPriority
    type: integer
    required: false
    description: Contact priority (1 = first, 2 = second, etc.)
    constraints:
      min: 1
      max: 10
  
  - name: emergencyNotes
    type: string
    required: false
    description: Special instructions for emergency contact
    constraints:
      maxLength: 1000
  
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
    description: Is this contact publicly visible (directory, etc.)?
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data
  
  # === AUDIT ===
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
  - name: belongsToOwner
    target: "[Worker|Employee|LegalEntity|BusinessUnit]"
    cardinality: many-to-one
    required: true
    polymorphic: true
    description: "Polymorphic owner relationship. Resolved based on ownerType + ownerId. When ownerType=WORKER, inverse is Worker.hasContacts."
    inverses:
      WORKER: hasContacts
      EMPLOYEE: hasContacts
      LEGAL_ENTITY: hasContacts
      BUSINESS_UNIT: hasContacts

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
  - name: OnePrimaryContactPerTypePerOwner
    type: validation
    rule: Owner can have at most ONE primary contact of each type
    expression: "COUNT(Contact WHERE ownerId = X AND ownerType = Y AND contactTypeCode = Z AND isPrimary = true) <= 1"
    severity: WARNING
  
  - name: PhoneAttributesRequired
    type: validation
    rule: If contactTypeCode = PHONE, phoneTypeCode and phoneNumber are required
    expression: "contactTypeCode != PHONE OR (phoneTypeCode IS NOT NULL AND phoneNumber IS NOT NULL)"
    severity: ERROR
  
  - name: EmailAttributesRequired
    type: validation
    rule: If contactTypeCode = EMAIL, emailTypeCode and emailAddress are required
    expression: "contactTypeCode != EMAIL OR (emailTypeCode IS NOT NULL AND emailAddress IS NOT NULL)"
    severity: ERROR
  
  - name: EmergencyContactAttributesRequired
    type: validation
    rule: If contactTypeCode = EMERGENCY_CONTACT, emergencyContactName, relationshipCode, and emergencyPrimaryPhone are required
    expression: "contactTypeCode != EMERGENCY_CONTACT OR (emergencyContactName IS NOT NULL AND relationshipCode IS NOT NULL AND emergencyPrimaryPhone IS NOT NULL)"
    severity: ERROR
  
  - name: EmailFormatValidation
    type: validation
    rule: Email address must be valid format
    expression: "emailAddress IS NULL OR emailAddress MATCHES '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'"
    severity: ERROR
  
  - name: VNPhoneFormatValidation
    type: business
    rule: For VN phone numbers, mobile should be 10 digits (09x, 03x, 07x, 08x)
    severity: WARNING
  
  - name: WorkerEmergencyContactRequired
    type: business
    rule: Worker should have at least one emergency contact
    expression: "ownerType != WORKER OR EXISTS(Contact WHERE ownerId = X AND contactTypeCode = EMERGENCY_CONTACT)"
    severity: WARNING
---

# Entity: Contact

## 1. Overview

The **Contact** entity stores communication information including phone numbers, email addresses, and emergency contacts. It is a **polymorphic entity** with **type-specific attributes** - different attributes are used depending on contactTypeCode (PHONE, EMAIL, or EMERGENCY_CONTACT).

**Key Concept**:
```
Contact = Polymorphic owner + Type-specific attributes
- PHONE: phoneNumber, phoneTypeCode, deviceTypeCode
- EMAIL: emailAddress, emailTypeCode
- EMERGENCY_CONTACT: emergencyContactName, relationshipCode, emergencyPrimaryPhone
```

```mermaid
mindmap
  root((Contact))
    Identity
      id
    Owner (Polymorphic)
      ownerType
      ownerId
    Contact Type
      contactTypeCode
      isPrimary
    Phone Attributes
      phoneTypeCode
      phoneNumber
      countryCode
      areaCode
      extension
      deviceTypeCode
    Email Attributes
      emailTypeCode
      emailAddress
    Emergency Contact
      emergencyContactName
      relationshipCode
      emergencyPrimaryPhone
      emergencyAlternatePhone
      emergencyAddress
      emergencyPriority
      emergencyNotes
    Verification
      isVerified
      verifiedAt
    Visibility
      isPublic
    Lifecycle
      ACTIVE
      INACTIVE
```

**Design Rationale**:
- **Polymorphic Owner**: Same entity for Worker, Employee, LegalEntity, BusinessUnit contacts
- **Type-Specific Attributes**: Different attributes based on contactTypeCode
- **VN Phone Format**: Support for VN mobile (10 digits) and landline formats
- **Emergency Contact**: Full emergency contact info (name, relationship, phones, address)

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique internal identifier (UUID) |

### 2.2 Owner Reference (Polymorphic)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| ownerType | enum | ✓ | WORKER, EMPLOYEE, LEGAL_ENTITY, BUSINESS_UNIT |
| ownerId | string | ✓ | Reference to owner entity |

### 2.3 Contact Type

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| contactTypeCode | enum | ✓ | PHONE, EMAIL, EMERGENCY_CONTACT |
| isPrimary | boolean | ✓ | Primary contact flag |

### 2.4 Phone Attributes (when contactTypeCode = PHONE)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| phoneTypeCode | enum | ✓* | HOME, MOBILE, WORK, FAX, OTHER |
| phoneNumber | string | ✓* | Complete phone number |
| countryCode | string | | Country dialing code (+84) |
| areaCode | string | | Area code (landlines) |
| extension | string | | Phone extension |
| deviceTypeCode | enum | | MOBILE, LANDLINE |

*Required if contactTypeCode = PHONE

### 2.5 Email Attributes (when contactTypeCode = EMAIL)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| emailTypeCode | enum | ✓* | HOME, WORK, OTHER |
| emailAddress | string | ✓* | Email address |

*Required if contactTypeCode = EMAIL

### 2.6 Emergency Contact Attributes (when contactTypeCode = EMERGENCY_CONTACT)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| emergencyContactName | string | ✓* | Contact person name |
| relationshipCode | enum | ✓* | SPOUSE, PARENT, CHILD, SIBLING, FRIEND, OTHER |
| emergencyPrimaryPhone | string | ✓* | Primary phone |
| emergencyAlternatePhone | string | | Alternate phone |
| emergencyAddress | string | | Contact address |
| emergencyPriority | integer | | Priority (1, 2, 3...) |
| emergencyNotes | string | | Special instructions |

*Required if contactTypeCode = EMERGENCY_CONTACT

### 2.7 Verification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isVerified | boolean | ✓ | Contact verified? |
| verifiedAt | datetime | | Verification timestamp |

### 2.8 Visibility

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isPublic | boolean | ✓ | Publicly visible? |

### 2.9 Audit Attributes

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
    Worker ||--o{ Contact : "hasContacts (polymorphic)"
    Employee ||--o{ Contact : "hasContacts (polymorphic)"
    LegalEntity ||--o{ Contact : "hasContacts (polymorphic)"
    BusinessUnit ||--o{ Contact : "hasContacts (polymorphic)"
    
    Contact {
        string id PK
        enum ownerType
        string ownerId FK
        enum contactTypeCode
        string phoneNumber
        string emailAddress
        string emergencyContactName
        boolean isPrimary
    }
```

### Related Entities

No explicit relationships defined (polymorphic owner handled via ownerType + ownerId).

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> ACTIVE: Create Contact
    
    ACTIVE --> INACTIVE: Deactivate (no longer valid)
    
    INACTIVE --> [*]
    
    note right of ACTIVE
        Currently valid contact
        Can be used for communication
    end note
    
    note right of INACTIVE
        No longer valid
        Historical record
    end note
```

### State Descriptions

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **ACTIVE** | Currently valid contact | Can deactivate |
| **INACTIVE** | No longer valid | Read-only, historical |

### Transition Rules

| From | To | Trigger | Guard Condition |
|------|-----|---------|--------------------|
| ACTIVE | INACTIVE | deactivate | Contact no longer valid |

---

## 5. Business Rules Reference

### Validation Rules
- **OnePrimaryContactPerTypePerOwner**: At most ONE primary contact of each type per owner (WARNING)
- **PhoneAttributesRequired**: If PHONE, phoneTypeCode and phoneNumber required
- **EmailAttributesRequired**: If EMAIL, emailTypeCode and emailAddress required
- **EmergencyContactAttributesRequired**: If EMERGENCY_CONTACT, name/relationship/phone required
- **EmailFormatValidation**: Email must be valid format

### Business Constraints
- **VNPhoneFormatValidation**: VN mobile should be 10 digits (09x, 03x, 07x, 08x) (WARNING)
- **WorkerEmergencyContactRequired**: Worker should have emergency contact (WARNING)

### Contact Types

**Phone Types**:
| Code | Description | VN Example |
|------|-------------|------------|
| HOME | Home phone | 028-1234-5678 (landline) |
| MOBILE | Mobile/Cell | 0901234567 (10 digits) |
| WORK | Work phone | 028-9876-5432 |
| FAX | Fax number | 028-1111-2222 |
| OTHER | Other | - |

**Email Types**:
| Code | Description |
|------|-------------|
| HOME | Personal email |
| WORK | Work email |
| OTHER | Other |

**Relationship Types** (Emergency Contact):
| Code | VN Name |
|------|---------|
| SPOUSE | Vợ/Chồng |
| PARENT | Cha/Mẹ |
| CHILD | Con |
| SIBLING | Anh/Chị/Em |
| FRIEND | Bạn bè |
| OTHER | Khác |

### VN Phone Format
- **Country Code**: +84
- **Mobile**: 09x, 03x, 07x, 08x (10 digits total)
  - Example: 0901234567
- **Landline**: Area code + number
  - Example: 028-1234-5678 (TP.HCM)

### Related Business Rules Documents
- See `[[contact-management.brs.md]]` for complete business rules catalog
- See `[[vn-phone-validation.brs.md]]` for VN phone format validation
- See `[[emergency-contact-procedures.brs.md]]` for emergency contact procedures

---

## 6. Use Cases

### Use Case 1: Worker Mobile Phone (VN)

```yaml
Contact:
  id: "contact-001"
  ownerType: "WORKER"
  ownerId: "worker-001"
  contactTypeCode: "PHONE"
  isPrimary: true
  phoneTypeCode: "MOBILE"
  phoneNumber: "0901234567"
  countryCode: "+84"
  deviceTypeCode: "MOBILE"
  isVerified: true
```

### Use Case 2: Employee Work Email

```yaml
Contact:
  id: "contact-002"
  ownerType: "EMPLOYEE"
  ownerId: "emp-001"
  contactTypeCode: "EMAIL"
  isPrimary: true
  emailTypeCode: "WORK"
  emailAddress: "nguyen.van.a@company.com"
  isVerified: true
  isPublic: true  # Visible in company directory
```

### Use Case 3: Emergency Contact

```yaml
Contact:
  id: "contact-003"
  ownerType: "WORKER"
  ownerId: "worker-001"
  contactTypeCode: "EMERGENCY_CONTACT"
  isPrimary: true
  emergencyContactName: "Nguyễn Thị B"
  relationshipCode: "SPOUSE"
  emergencyPrimaryPhone: "0909876543"
  emergencyAlternatePhone: "028-1234-5678"
  emergencyAddress: "456 Lê Lợi, Quận 1, TP.HCM"
  emergencyPriority: 1
  emergencyNotes: "Gọi vào giờ hành chính"
```

### Use Case 4: Legal Entity Contact

```yaml
# Company Phone
Contact_Phone:
  ownerType: "LEGAL_ENTITY"
  ownerId: "le-001"
  contactTypeCode: "PHONE"
  phoneTypeCode: "WORK"
  phoneNumber: "028-1234-5678"
  isPrimary: true

# Company Email
Contact_Email:
  ownerType: "LEGAL_ENTITY"
  ownerId: "le-001"
  contactTypeCode: "EMAIL"
  emailTypeCode: "WORK"
  emailAddress: "info@company.com"
  isPrimary: true
  isPublic: true
```

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday patterns*  
*VN Phone Format: Mobile 10 digits (09x, 03x, 07x, 08x)*
