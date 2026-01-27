---
entity: BankAccount
version: "1.0.0"
status: approved
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Bank Account (Payment Information)

## 1. Summary

The **Bank Account** entity stores employee banking details for payroll purposes (direct deposit/EFT). It typically includes account numbers, bank codes, branch details, and payment distribution rules (e.g., split payments). Vietnam has specific banking system codes (CITAD, Napas).

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: `IBY_EXT_BANK_ACCOUNTS` (Bank Accounts)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| BANK_ACCOUNT_ID | Number | Y | Unique identifier |
| BANK_ACCOUNT_NAME | String | Y | Account holder name |
| BANK_ACCOUNT_NUMBER | String | Y | Account number |
| IBAN | String | N | IBAN |
| CURRENCY_CODE | String | Y | Currency |
| BANK_ID | Number | Y | FK to Bank |
| BANK_BRANCH_ID | Number | Y | FK to Branch |
| ACCOUNT_TYPE | Enum | N | Checking/Savings |
| COUNTRY_CODE | String | Y | Bank country |

### 2.2 SAP SuccessFactors

**Entity**: `PaymentInformationV3` + `PaymentInformationDetailV3`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| effectiveStartDate | Date | Y | Effective date |
| worker | String | Y | Employee |
| bankCountry | String | Y | Country |
| bank | String | Y | Bank code/ID |
| accountNumber | String | Y | Account number |
| accountOwner | String | N | Owner name |
| routingNumber | String | N | Routing/Branch code |
| iban | String | N | IBAN |
| currency | String | Y | Currency |
| paymentMethod | Enum | Y | Bank Transfer/Check |
| percent | Decimal | N | Split percentage |
| amount | Decimal | N | Split amount |

### 2.3 Workday

**Entity**: `Payment_Correction_Bank_Data` / `Payment_Election`

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Bank_Name | String | Y | Name of bank |
| Bank_Code | String | Y | Bank ID/Code |
| Branch_Name | String | N | Branch name |
| Account_Number | String | Y | Account number |
| Account_Type | Enum | Y | Checking/Savings |
| Currency | Reference | Y | Currency |
| SWIFT_Bank_Identification_Code | String | N | SWIFT/BIC |

---

## 3. Canonical Schema: BankAccount

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| employee | reference | FK to Employee | Universal |
| accountHolderName | string(200) | Name on account | Universal |
| accountNumber | string(50) | Bank account number | Universal |
| bank | reference | FK to Bank (Master) | Universal |
| currency | reference | Default currency | Universal |
| status | enum | Active/Inactive | Universal |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| branch | reference | FK to Bank Branch | Oracle, SAP |
| bankCode | string(20) | CITAD/Swift Code | Workday |
| iban | string(34) | IBAN (International) | 3/3 vendors |
| swiftCode | string(11) | SWIFT/BIC | Workday |
| isPrimary | boolean | Primary account | Best practice |
| accountType | enum | Checking/Savings | Oracle, Workday |
| effectiveDate | date | Valid from | SAP |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| branchName | string | If branch ref missing |
| paymentMethod | enum | Transfer/Cash/Check |
| distributionPercent| decimal | For split payments |
| distributionAmount | decimal | For split payments |

---

## 4. Local Adaptations (Vietnam)

### Vietnam Banking System
- **Bank Code**: 8-digit CITAD code or shorter Interbank code (e.g., VCB, TCB).
- **Account Number**: Variable length (10-14 digits usually).
- **Account Name**: Must match the Employee Name (Language: Vietnamese without accents usually required by some core banking systems, but modern ones accept Unicode). **Recommendation**: Store uppercase, no accents (e.g., NGUYEN VAN A) for compatibility.
- **Branch**: Specific branch selection is critical for older interbank transfers (CITAD), though Napas 24/7 uses BIN + Account Number. **Recommendation**: Keep Branch optional but recommended.
- **IBAN**: Not widely used for domestic VN transfers.

### Canonical VN Fields
| Field | Type | Description |
|-------|------|-------------|
| bankNameVN | string | Tên ngân hàng (VN) |
| bankCodeCitad | string | Mã CITAD |
| branchNameVN | string | Tên chi nhánh |

---

*Document Status: APPROVED*
