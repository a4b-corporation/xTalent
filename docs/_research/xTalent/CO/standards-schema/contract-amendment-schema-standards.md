---
entity: ContractAmendment
version: "1.0.0"
status: approved
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Contract Amendment (History)

## 1. Summary

The **Contract Amendment** entity tracks changes to an active employment contract, often appearing as "Appendix" or "Addendum" (Phụ lục hợp đồng). It records *what* changed, *when* it is effective, and the *reason*. In systems like Oracle/SAP, this is often handled via effective-dated Contract records, while Workday manages it via processes.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Mechanism**: Effective-dated updates to `Employment Contract`.
**Entity**: `Contract Extension History` (Sub-component).

| Attribute | Data |
|-----------|------|
| Extension Number | Incremental ID |
| Change Date | Effective Date |
| Description | Reason for change |
| New End Date | For extensions |

### 2.2 SAP SuccessFactors

**Mechanism**: History of `Contract` object (Effective Dating).

| Attribute | Data |
|-----------|------|
| startDate | Effective Date of change |
| contractType | If type changes |
| endDate | Use for extension |
| attachment | Amendment scan |

### 2.3 Workday

**Mechanism**: `Maintain Contract` business process event.

| Attribute | Data |
|-----------|------|
| Event Date | Effective Date |
| Reason | Amendment context |
| Document | Generated amendment doc |

---

## 3. Canonical Schema: ContractAmendment

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| contract | reference | FK to Parent Contract | Universal |
| amendmentNumber| string(20) | Addendum No. (PL-01) | Best practice |
| effectiveDate | date | When change applies | Universal |
| changeType | enum | EXTENSION/SALARY/ROLE | Universal |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| signatureDate | date | Date signed | Best practice |
| reason | text | Reason for amendment | Universal |
| changedFields | json | Snapshot of changes | Best practice |
| document | reference | FK to Document (Signed) | Universal |
| status | enum | DRAFT/SIGNED/ACTIVE | Universal |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| newEndDate | date | If extension |
| newSalary | decimal | If salary change |

---

## 4. Local Adaptations (Vietnam)

- **Phụ lục Hợp đồng (Contract Appendix)**: Very common in VN. Used for salary adjustments (Phụ lục điều chỉnh lương) or contract extensions (Gia hạn hợp đồng).
- **Rule**: An appendix cannot change the *duration* of the contract in a way that exceeds the statutory limit for Fixed Term contracts (except for 1-time extension).

---

*Document Status: APPROVED*
