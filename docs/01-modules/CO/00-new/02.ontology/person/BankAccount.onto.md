---
entity: BankAccount
domain: common
version: "1.0.0"
status: approved
owner: Common Domain Team
tags: [bank-account, payment, payroll, vn-banking]

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
    description: Type of entity that owns this bank account
    values: [WORKER, EMPLOYEE, LEGAL_ENTITY]
  
  - name: ownerId
    type: string
    required: true
    description: Reference to owner entity (polymorphic - Worker, Employee, or LegalEntity)
  
  # === ACCOUNT HOLDER ===
  - name: accountHolderName
    type: string
    required: true
    description: Name on bank account (must match owner name for payroll). For VN, uppercase without accents recommended.
    constraints:
      maxLength: 200
    metadata:
      pii: true
      sensitivity: medium
  
  # === BANK ACCOUNT DETAILS ===
  - name: accountNumber
    type: string
    required: true
    description: Bank account number (10-14 digits for VN)
    constraints:
      maxLength: 50
    metadata:
      pii: true
      sensitivity: high
  
  - name: accountTypeCode
    type: enum
    required: false
    description: Type of bank account
    values: [CHECKING, SAVINGS, SALARY]
    default: CHECKING
  
  # === BANK REFERENCE ===
  - name: bankId
    type: string
    required: false
    description: Reference to Bank master data entity (if using master)
  
  - name: bankCode
    type: string
    required: false
    description: Bank code (CITAD 8-digit or short code like VCB, TCB for VN)
    constraints:
      maxLength: 20
  
  - name: bankName
    type: string
    required: false
    description: Bank name (if not using bank master)
    constraints:
      maxLength: 200
  
  # === BRANCH REFERENCE ===
  - name: branchId
    type: string
    required: false
    description: Reference to Bank Branch master data entity (if using master)
  
  - name: branchCode
    type: string
    required: false
    description: Branch code
    constraints:
      maxLength: 20
  
  - name: branchName
    type: string
    required: false
    description: Branch name (Tên chi nhánh)
    constraints:
      maxLength: 200
  
  # === INTERNATIONAL CODES ===
  - name: iban
    type: string
    required: false
    description: IBAN (International Bank Account Number) - not widely used for VN domestic
    constraints:
      maxLength: 34
  
  - name: swiftCode
    type: string
    required: false
    description: SWIFT/BIC code (for international transfers)
    constraints:
      maxLength: 11
  
  # === CURRENCY ===
  - name: currencyCode
    type: string
    required: true
    description: Account currency (ISO 4217 code). Default VND for VN.
    constraints:
      pattern: "^[A-Z]{3}$"
    default: VND
  
  # === PRIMARY FLAG ===
  - name: isPrimary
    type: boolean
    required: true
    default: false
    description: Is this the primary bank account for payroll?
  
  # === STATUS ===
  - name: statusCode
    type: enum
    required: true
    description: Bank account status. Aligned with xTalent naming convention.
    values: [ACTIVE, INACTIVE, PENDING_VERIFICATION, BLOCKED]
    default: PENDING_VERIFICATION
  
  # === PAYMENT DISTRIBUTION (for split payments) ===
  - name: distributionPercent
    type: decimal
    required: false
    description: Percentage of salary to distribute to this account (for split payments)
    constraints:
      min: 0.0
      max: 100.0
  
  - name: distributionAmount
    type: decimal
    required: false
    description: Fixed amount to distribute to this account (for split payments)
    constraints:
      min: 0.0
  
  # === VERIFICATION ===
  - name: isVerified
    type: boolean
    required: true
    default: false
    description: Has this bank account been verified (test transfer, etc.)?
  
  - name: verifiedAt
    type: datetime
    required: false
    description: When account was verified
  
  # === DATE EFFECTIVENESS ===
  - name: effectiveStartDate
    type: date
    required: false
    description: Date this bank account becomes effective for payroll
  
  - name: effectiveEndDate
    type: date
    required: false
    description: Date this bank account expires (null = current)
  
  # === METADATA ===
  - name: metadata
    type: json
    required: false
    description: Additional flexible data (payment method, notes, etc.)
  
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
  - name: denominatedInCurrency
    target: Currency
    cardinality: many-to-one
    required: true
    inverse: usedinBankAccounts
    description: Currency of the bank account. INVERSE - Currency.usedInBankAccounts must reference this BankAccount.
  
  - name: heldAtBank
    target: Bank
    cardinality: many-to-one
    required: false
    inverse: hasBankAccounts
    description: Bank where account is held (if using bank master). INVERSE - Bank.hasBankAccounts must reference this BankAccount.
  
  - name: heldAtBranch
    target: BankBranch
    cardinality: many-to-one
    required: false
    inverse: hasBankAccounts
    description: Bank branch where account is held (if using branch master). INVERSE - BankBranch.hasBankAccounts must reference this BankAccount.

lifecycle:
  states: [PENDING_VERIFICATION, ACTIVE, INACTIVE, BLOCKED]
  initial: PENDING_VERIFICATION
  terminal: [INACTIVE]
  transitions:
    - from: PENDING_VERIFICATION
      to: ACTIVE
      trigger: verify
      guard: Account verified (test transfer successful)
    - from: ACTIVE
      to: INACTIVE
      trigger: deactivate
      guard: Account no longer used (closed, changed bank)
    - from: ACTIVE
      to: BLOCKED
      trigger: block
      guard: Account blocked (fraud, error, etc.)
    - from: BLOCKED
      to: ACTIVE
      trigger: unblock
      guard: Block removed
    - from: PENDING_VERIFICATION
      to: INACTIVE
      trigger: cancel
      guard: Verification failed or cancelled

policies:
  - name: OnePrimaryBankAccountPerOwner
    type: validation
    rule: Owner can have at most ONE primary bank account
    expression: "COUNT(BankAccount WHERE ownerId = X AND ownerType = Y AND isPrimary = true) <= 1"
    severity: ERROR
  
  - name: AccountHolderNameMatch
    type: business
    rule: Account holder name should match owner name (for payroll compliance)
    severity: WARNING
  
  - name: EffectiveDateConsistency
    type: validation
    rule: effectiveStartDate must be before effectiveEndDate (if set)
    expression: "effectiveEndDate IS NULL OR effectiveStartDate < effectiveEndDate"
  
  - name: DistributionValidation
    type: validation
    rule: Cannot have both distributionPercent and distributionAmount set
    expression: "distributionPercent IS NULL OR distributionAmount IS NULL"
    severity: ERROR
  
  - name: TotalDistributionPercent
    type: business
    rule: Sum of distributionPercent across all accounts for owner should be <= 100%
    expression: "SUM(BankAccount.distributionPercent WHERE ownerId = X) <= 100"
    severity: WARNING
  
  - name: VNBankAccountFormat
    type: validation
    rule: For VN accounts, accountNumber should be 10-14 digits
    expression: "currencyCode != 'VND' OR (LENGTH(accountNumber) >= 10 AND LENGTH(accountNumber) <= 14)"
    severity: WARNING
  
  - name: VNAccountHolderNameFormat
    type: business
    rule: For VN accounts, accountHolderName should be uppercase without accents (for compatibility)
    severity: INFO
  
  - name: ActiveAccountRequirements
    type: business
    rule: ACTIVE account must be verified
    expression: "statusCode != ACTIVE OR isVerified = true"
    severity: WARNING
  
  - name: BlockedAccountRestrictions
    type: business
    rule: BLOCKED accounts cannot be used for payroll
    severity: ERROR
---

# Entity: BankAccount

## 1. Overview

The **BankAccount** entity stores banking details for payroll purposes (direct deposit/EFT). It is a **polymorphic entity** that can be owned by Worker, Employee, or LegalEntity. Vietnam has specific banking system codes (CITAD, Napas) and account name format requirements.

**Key Concept**:
```
BankAccount = Polymorphic (Worker/Employee/LegalEntity)
VN Banking: CITAD code + Account Number (10-14 digits)
Account Holder Name: Must match owner (uppercase, no accents for VN)
```

```mermaid
mindmap
  root((BankAccount))
    Identity
      id
    Owner (Polymorphic)
      ownerType
      ownerId
    Account Holder
      accountHolderName
    Account Details
      accountNumber
      accountTypeCode
    Bank Reference
      bankId
      bankCode
      bankName
    Branch Reference
      branchId
      branchCode
      branchName
    International
      iban
      swiftCode
    Currency
      currencyCode
    Primary Flag
      isPrimary
    Status
      statusCode
    Payment Distribution
      distributionPercent
      distributionAmount
    Verification
      isVerified
      verifiedAt
    Date Effectiveness
      effectiveStartDate
      effectiveEndDate
    Relationships
      denominatedInCurrency
      heldAtBank
      heldAtBranch
    Lifecycle
      PENDING_VERIFICATION
      ACTIVE
      INACTIVE
      BLOCKED
```

**Design Rationale**:
- **Polymorphic Owner**: Same entity for Worker, Employee, LegalEntity bank accounts
- **VN Banking Support**: CITAD codes, account name format (uppercase, no accents)
- **Payment Distribution**: Split payments (percent or fixed amount)
- **Verification**: Test transfer before activation

---

## 2. Attributes

### 2.1 Identity Attributes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | ✓ | Unique internal identifier (UUID) |

### 2.2 Owner Reference (Polymorphic)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| ownerType | enum | ✓ | WORKER, EMPLOYEE, LEGAL_ENTITY |
| ownerId | string | ✓ | Reference to owner entity |

### 2.3 Account Holder

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| accountHolderName | string | ✓ | Name on account (uppercase, no accents for VN) |

### 2.4 Account Details

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| accountNumber | string | ✓ | Account number (10-14 digits for VN) |
| accountTypeCode | enum | | CHECKING, SAVINGS, SALARY |

### 2.5 Bank Reference

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| bankId | string | | Bank master reference |
| bankCode | string | | CITAD/short code (VCB, TCB) |
| bankName | string | | Bank name |

### 2.6 Branch Reference

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| branchId | string | | Branch master reference |
| branchCode | string | | Branch code |
| branchName | string | | Branch name |

### 2.7 International Codes

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| iban | string | | IBAN (not common for VN domestic) |
| swiftCode | string | | SWIFT/BIC (international) |

### 2.8 Currency

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| currencyCode | string | ✓ | Currency (ISO 4217, default VND) |

### 2.9 Primary Flag

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isPrimary | boolean | ✓ | Primary account for payroll? |

### 2.10 Status

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| statusCode | enum | ✓ | PENDING_VERIFICATION, ACTIVE, INACTIVE, BLOCKED |

### 2.11 Payment Distribution

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| distributionPercent | decimal | | Percentage for split payments |
| distributionAmount | decimal | | Fixed amount for split payments |

### 2.12 Verification

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| isVerified | boolean | ✓ | Account verified? |
| verifiedAt | datetime | | Verification timestamp |

### 2.13 Date Effectiveness

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| effectiveStartDate | date | | Effective for payroll from |
| effectiveEndDate | date | | Effective until |

### 2.14 Audit Attributes

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
    Currency ||--o{ BankAccount : usedInBankAccounts
    Bank ||--o{ BankAccount : hasBankAccounts
    BankBranch ||--o{ BankAccount : hasBankAccounts
    Worker ||--o{ BankAccount : "hasBankAccounts (polymorphic)"
    Employee ||--o{ BankAccount : "hasBankAccounts (polymorphic)"
    LegalEntity ||--o{ BankAccount : "hasBankAccounts (polymorphic)"
    
    BankAccount {
        string id PK
        enum ownerType
        string ownerId FK
        string accountHolderName
        string accountNumber
        string bankCode
        string currencyCode FK
        boolean isPrimary
        enum statusCode
    }
```

### Related Entities

| Entity | Relationship | Cardinality | Description |
|--------|--------------|-------------|-------------|
| [[Currency]] | denominatedInCurrency | N:1 | Account currency |
| [[Bank]] | heldAtBank | N:1 | Bank (if using master) |
| [[BankBranch]] | heldAtBranch | N:1 | Branch (if using master) |

---

## 4. Lifecycle

```mermaid
stateDiagram-v2
    [*] --> PENDING_VERIFICATION: Create Bank Account
    
    PENDING_VERIFICATION --> ACTIVE: Verify (test transfer OK)
    PENDING_VERIFICATION --> INACTIVE: Cancel (verification failed)
    
    ACTIVE --> INACTIVE: Deactivate (closed, changed bank)
    ACTIVE --> BLOCKED: Block (fraud, error)
    
    BLOCKED --> ACTIVE: Unblock
    
    INACTIVE --> [*]
    
    note right of PENDING_VERIFICATION
        Awaiting verification
        Test transfer pending
        Cannot use for payroll yet
    end note
    
    note right of ACTIVE
        Verified and active
        Can use for payroll
        Normal operations
    end note
    
    note right of BLOCKED
        Temporarily blocked
        Fraud/error detected
        Cannot use for payroll
    end note
    
    note right of INACTIVE
        No longer used
        Terminal state
        Historical record
    end note
```

### State Descriptions

| State | Description | Allowed Operations |
|-------|-------------|-------------------|
| **PENDING_VERIFICATION** | Awaiting verification | Can verify, can cancel |
| **ACTIVE** | Verified and active | Can deactivate, can block, use for payroll |
| **BLOCKED** | Temporarily blocked | Can unblock |
| **INACTIVE** | No longer used | Read-only, historical |

### Transition Rules

| From | To | Trigger | Guard Condition |
|------|-----|---------|--------------------|
| PENDING_VERIFICATION | ACTIVE | verify | Test transfer successful |
| PENDING_VERIFICATION | INACTIVE | cancel | Verification failed/cancelled |
| ACTIVE | INACTIVE | deactivate | Account closed/changed |
| ACTIVE | BLOCKED | block | Fraud/error detected |
| BLOCKED | ACTIVE | unblock | Block removed |

---

## 5. Business Rules Reference

### Validation Rules
- **OnePrimaryBankAccountPerOwner**: At most ONE primary account per owner
- **EffectiveDateConsistency**: effectiveStartDate < effectiveEndDate (if set)
- **DistributionValidation**: Cannot have both percent and amount
- **VNBankAccountFormat**: VN accounts should be 10-14 digits (WARNING)

### Business Constraints
- **AccountHolderNameMatch**: Name should match owner (WARNING)
- **TotalDistributionPercent**: Sum of percent <= 100% (WARNING)
- **VNAccountHolderNameFormat**: Uppercase, no accents for VN (INFO)
- **ActiveAccountRequirements**: ACTIVE must be verified (WARNING)
- **BlockedAccountRestrictions**: BLOCKED cannot be used for payroll

### VN Banking System
- **Bank Code**: 8-digit CITAD or short code (VCB, TCB, ACB, etc.)
- **Account Number**: 10-14 digits typically
- **Account Name**: Uppercase, no accents (NGUYEN VAN A) for compatibility
- **Branch**: Optional but recommended for older CITAD transfers
- **Napas 24/7**: Uses BIN + Account Number (branch less critical)

### Payment Distribution (Split Payments)
- **Percent-Based**: distributionPercent (e.g., 70% to Account A, 30% to Account B)
- **Amount-Based**: distributionAmount (e.g., 5,000,000 VND to savings, rest to checking)
- **Validation**: Cannot mix percent and amount in same account
- **Total Check**: Sum of percents <= 100%

### Related Business Rules Documents
- See `[[bank-account-management.brs.md]]` for complete business rules catalog
- See `[[vn-banking-integration.brs.md]]` for VN banking system integration
- See `[[payroll-distribution.brs.md]]` for split payment rules

---

## 6. Use Cases

### Use Case 1: Employee Primary Bank Account (VN)

```yaml
BankAccount:
  id: "ba-001"
  ownerType: "EMPLOYEE"
  ownerId: "emp-001"
  accountHolderName: "NGUYEN VAN A"  # Uppercase, no accents
  accountNumber: "1234567890"  # 10 digits
  bankCode: "VCB"  # Vietcombank
  bankName: "Ngân hàng TMCP Ngoại thương Việt Nam"
  branchName: "Chi nhánh TP.HCM"
  currencyCode: "VND"
  isPrimary: true
  statusCode: "ACTIVE"
  isVerified: true
```

### Use Case 2: Split Payment (Savings + Checking)

```yaml
# Primary Account (70% to checking)
BankAccount_Checking:
  ownerType: "EMPLOYEE"
  accountNumber: "1111111111"
  bankCode: "VCB"
  isPrimary: true
  distributionPercent: 70.0
  statusCode: "ACTIVE"

# Secondary Account (30% to savings)
BankAccount_Savings:
  ownerType: "EMPLOYEE"
  accountNumber: "2222222222"
  bankCode: "TCB"
  isPrimary: false
  distributionPercent: 30.0
  accountTypeCode: "SAVINGS"
  statusCode: "ACTIVE"
```

### Use Case 3: Legal Entity Bank Account

```yaml
BankAccount:
  ownerType: "LEGAL_ENTITY"
  ownerId: "le-001"
  accountHolderName: "CONG TY CO PHAN VNG"
  accountNumber: "9999999999"
  bankCode: "VCB"
  branchName: "Chi nhánh Quận 1"
  currencyCode: "VND"
  isPrimary: true
  statusCode: "ACTIVE"
```

---

*Document Status: APPROVED - Based on Oracle HCM, SAP SuccessFactors, Workday patterns*  
*VN Banking: CITAD, Napas 24/7 compatibility*
