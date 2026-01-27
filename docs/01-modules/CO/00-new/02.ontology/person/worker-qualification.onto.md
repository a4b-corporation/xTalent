---
entity: WorkerQualification
domain: person
version: "1.0.0"
status: approved
owner: Core HR Team
tags: [worker, qualification, education, certification, credential]

# NOTE: WorkerQualification stores educational degrees, certifications, and credentials.
# This is DIFFERENT from WorkerSkill:
#   - WorkerSkill = Abilities (what you can do)
#   - WorkerQualification = Credentials (what you have earned/achieved)
#
# Types: Education (degrees), Certifications, Licenses, Languages, Awards

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
    description: FK → Worker.id. The worker who holds this qualification.
  
  # === QUALIFICATION TYPE ===
  - name: qualTypeCode
    type: enum
    required: true
    description: Type of qualification
    values: [EDUCATION, CERTIFICATION, LICENSE, LANGUAGE, AWARD, TRAINING, OTHER]
    # EDUCATION = Academic degrees (Bachelor, Master, PhD)
    # CERTIFICATION = Professional certifications (AWS, PMP, CPA)
    # LICENSE = Professional licenses (Medical, Legal, Engineering)
    # LANGUAGE = Language proficiency (IELTS, TOEFL, JLPT)
    # AWARD = Awards and honors
    # TRAINING = Training programs completed
    # OTHER = Other qualifications
  
  # === DETAILS ===
  - name: name
    type: string
    required: true
    description: Name of qualification (e.g., "Bachelor of Computer Science", "AWS Solutions Architect")
    constraints:
      maxLength: 255
  
  - name: institution
    type: string
    required: false
    description: Issuing institution/organization (e.g., "MIT", "Amazon Web Services")
    constraints:
      maxLength: 255
  
  - name: fieldOfStudy
    type: string
    required: false
    description: Major/field of study (for education)
    constraints:
      maxLength: 255
  
  # === DATES ===
  - name: startDate
    type: date
    required: false
    description: Start date (enrollment/program start)
  
  - name: endDate
    type: date
    required: false
    description: End date (graduation/completion)
  
  - name: issueDate
    type: date
    required: false
    description: Date qualification was issued/awarded
  
  - name: expiryDate
    type: date
    required: false
    description: Expiration date (for certifications/licenses)
  
  # === GRADE/LEVEL ===
  - name: levelOrScore
    type: string
    required: false
    description: Level achieved or score (e.g., "3.8 GPA", "IELTS 7.5", "Associate Level")
    constraints:
      maxLength: 50
  
  - name: gradeCode
    type: string
    required: false
    description: Standardized grade code (e.g., EXCELLENT, GOOD, PASS)
    constraints:
      maxLength: 50
  
  # === VERIFICATION ===
  - name: credentialId
    type: string
    required: false
    description: External credential ID (certificate number, badge ID)
    constraints:
      maxLength: 100
  
  - name: credentialUrl
    type: string
    required: false
    description: URL to verify credential (e.g., Credly badge, LinkedIn cert)
    constraints:
      maxLength: 500
  
  - name: isVerified
    type: boolean
    required: true
    default: false
    description: Has this qualification been verified by HR?
  
  - name: verifiedBy
    type: string
    required: false
    description: FK → Worker.id (who verified)
  
  - name: verifiedDate
    type: date
    required: false
    description: When verification was done
  
  # === DOCUMENT ===
  - name: documentId
    type: string
    required: false
    description: FK → Document.id (attached certificate/diploma scan)
  
  # === SCD TYPE-2 ===
  - name: effectiveStartDate
    type: date
    required: true
    description: When this qualification record becomes effective
  
  - name: effectiveEndDate
    type: date
    required: false
    description: When this qualification record ends (null = current)
  
  - name: isCurrent
    type: boolean
    required: true
    default: true
    description: Is this the current version?
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional data (honors, specialization, GPA breakdown, etc.)
  
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
    inverse: hasQualifications
    description: The worker who holds this qualification.
  
  - name: attachedDocument
    target: Document
    cardinality: many-to-one
    required: false
    description: Attached certificate/diploma document.
  
  - name: verifiedByWorker
    target: Worker
    cardinality: many-to-one
    required: false
    description: HR personnel who verified this qualification.

lifecycle:
  states: [PENDING, VERIFIED, EXPIRED, INVALID]
  initial: PENDING
  terminal: [INVALID]
  transitions:
    - from: PENDING
      to: VERIFIED
      trigger: verify
      guard: Verification completed by HR
    - from: VERIFIED
      to: EXPIRED
      trigger: expire
      guard: expiryDate has passed
    - from: EXPIRED
      to: VERIFIED
      trigger: renew
      guard: Renewed/extended certification
    - from: [PENDING, VERIFIED, EXPIRED]
      to: INVALID
      trigger: invalidate
      guard: Fraudulent or revoked qualification

policies:
  - name: UniqueWorkerQualification
    type: validation
    rule: No duplicate qualification per worker
    expression: "UNIQUE(workerId, qualTypeCode, name, institution, issueDate)"
    severity: WARNING
  
  - name: ExpiryDateAfterIssue
    type: validation
    rule: Expiry date must be after issue date
    expression: "expiryDate IS NULL OR issueDate IS NULL OR expiryDate > issueDate"
  
  - name: CertificationRequiresExpiry
    type: business
    rule: Certifications should have expiry date for tracking
    expression: "qualTypeCode NOT IN ('CERTIFICATION', 'LICENSE') OR expiryDate IS NOT NULL"
    severity: WARNING
---

# Entity: WorkerQualification

## 1. Overview

**WorkerQualification** stores educational credentials, professional certifications, licenses, language proficiencies, and other formal qualifications earned by a worker.

**Key Distinction**:
```
WorkerSkill = What you CAN DO (abilities, proficiency)
WorkerQualification = What you HAVE EARNED (degrees, certs, licenses)
```

```mermaid
mindmap
  root((WorkerQualification))
    Types
      EDUCATION
      CERTIFICATION
      LICENSE
      LANGUAGE
      AWARD
      TRAINING
    Details
      name
      institution
      fieldOfStudy
    Dates
      startDate
      endDate
      issueDate
      expiryDate
    Verification
      isVerified
      verifiedBy
      credentialUrl
    Attachments
      documentId
```

### Qualification Types

| Type | Description | Example |
|------|-------------|---------|
| **EDUCATION** | Academic degrees | Bachelor of CS, MBA |
| **CERTIFICATION** | Professional certs | AWS SA, PMP, CPA |
| **LICENSE** | Professional licenses | CPA License, Medical License |
| **LANGUAGE** | Language proficiency | IELTS 7.5, JLPT N1 |
| **AWARD** | Awards and honors | Employee of the Year |
| **TRAINING** | Training programs | Leadership Development Program |

---

## 2. Attributes

### Identity & Type

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique identifier (UUID) |
| workerId | string | ✓ | FK → [[Worker]] |
| qualTypeCode | enum | ✓ | EDUCATION, CERTIFICATION, etc. |

### Details

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| name | string | ✓ | Qualification name |
| institution | string | | Issuing organization |
| fieldOfStudy | string | | Major/field (education) |
| levelOrScore | string | | Grade/score/level |

### Dates

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| startDate | date | | Program start |
| endDate | date | | Completion date |
| issueDate | date | | Award/issue date |
| expiryDate | date | | Expiration (certs) |

### Verification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| credentialId | string | | External cert number |
| credentialUrl | string | | Verification URL |
| isVerified | boolean | ✓ | Verified by HR? |

---

## 3. Relationships

```mermaid
erDiagram
    Worker ||--o{ WorkerQualification : hasQualifications
    Document ||--o{ WorkerQualification : attachedTo
    
    WorkerQualification {
        string id PK
        string workerId FK
        enum qualTypeCode
        string name
        string institution
        date issueDate
        date expiryDate
        boolean isVerified
    }
    
    Worker {
        string id PK
        string fullName
    }
```

---

## 4. Use Cases

### Education - Bachelor Degree

```yaml
WorkerQualification:
  workerId: "worker-001"
  qualTypeCode: "EDUCATION"
  name: "Bachelor of Computer Science"
  institution: "VNU - University of Science"
  fieldOfStudy: "Computer Science"
  startDate: "2015-09-01"
  endDate: "2019-06-15"
  issueDate: "2019-07-01"
  levelOrScore: "3.6 GPA"
  gradeCode: "EXCELLENT"
  isVerified: true
  verifiedBy: "hr-admin-001"
  verifiedDate: "2020-01-15"
  metadata:
    honors: "Cum Laude"
    thesis: "Machine Learning in NLP"
```

### Certification - AWS

```yaml
WorkerQualification:
  workerId: "worker-001"
  qualTypeCode: "CERTIFICATION"
  name: "AWS Solutions Architect - Professional"
  institution: "Amazon Web Services"
  issueDate: "2024-03-15"
  expiryDate: "2027-03-15"
  credentialId: "AWS-SAP-12345"
  credentialUrl: "https://www.credly.com/badges/xxx"
  isVerified: true
  verifiedBy: "system"
  metadata:
    examScore: 850
    validationNumber: "XXXXXXXXXX"
```

### Language - IELTS

```yaml
WorkerQualification:
  workerId: "worker-001"
  qualTypeCode: "LANGUAGE"
  name: "IELTS Academic"
  institution: "British Council"
  issueDate: "2023-06-20"
  expiryDate: "2025-06-20"
  levelOrScore: "7.5"
  metadata:
    listening: 8.0
    reading: 7.5
    writing: 7.0
    speaking: 7.5
```

---

*Document Status: APPROVED*  
*References: [[Worker]], [[Document]], [[WorkerSkill]]*
