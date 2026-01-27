---
entity: CostCenter
version: "1.0.0"
status: approved
created: 2026-01-26
sources:
  - oracle-hcm
  - sap-successfactors
  - workday
module: Core HR
---

# Schema Standards: Cost Center

## 1. Summary

The **Cost Center** entity represents a unit within an organization to which costs are allocated. It is the primary integration point between HR (Headcount) and Finance (General Ledger). In many systems, it is strictly a financial object, but HR systems mirror it to assign employees and track payroll costs.

**Confidence**: HIGH - Based on 3 major HCM vendors

---

## 2. Vendor Comparison Matrix

### 2.1 Oracle HCM Cloud

**Entity**: GL Cost Center (Segment in Chart of Accounts)
**Representation in HCM**: `Organization` with classification or Department attribute.

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| COST_ALLOCATION_KEYFLEX_ID | Number | Y | CCID/KFF ID |
| SEGMENT1...N | String | Y | GL Segments |
| ENABLED_FLAG | String | Y | Active status |
| START_DATE_ACTIVE | Date | Y | Start date |
| END_DATE_ACTIVE | Date | N | End date |

**Concept**: Deeply integrated with Financials. HCM Departments map to GL Cost Centers.

### 2.2 SAP SuccessFactors

**Entity**: `FOCostCenter` (Foundation Object)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| externalCode | String | Y | GL Code |
| name | String | Y | Name |
| description | String | N | Description |
| status | Enum | Y | Status |
| startDate | Date | Y | Effective date |
| legalEntity | Reference | N | Company Code |
| glStatementCode | String | N | GL mapping |
| costCenterManager | String | N | Manager (User) |

### 2.3 Workday

**Entity**: `Cost_Center` (Organization Type)

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| Organization_Reference_ID | String | Y | Unique ID |
| Cost_Center_Code | String | Y | GL Code |
| Name | String | Y | Name |
| Manager | Reference | N | Manager |
| Company | Reference | Y | Legal Entity |
| Location | Reference | N | Default Location |
| Include_In_Hierarchy | Boolean | Y | Hierarchy flag |

---

## 3. Canonical Schema: CostCenter

### Required Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| id | uuid | Unique identifier | Universal |
| code | string(50) | GL Cost Center Code | Universal |
| name | string(200) | Cost Center Name | Universal |
| status | enum | Active/Inactive | Universal |
| legalEntity | reference | FK to Legal Entity | 3/3 vendors |
| effectiveDate | date | Start date | SAP, Oracle |

### Recommended Attributes
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| description | text | Description of costs | SAP |
| manager | reference | FK to Employee (Approver) | SAP, Workday |
| parentCostCenter | reference | Hierarchy parent | Workday |
| currency | reference | Functional currency | Best practice |
| profitCenter | reference | Related Profit Center | ERP integration |
| glAccount | string(50) | Default GL Account | ERP integration |

### Optional Attributes
| Attribute | Type | When to Include |
|-----------|------|-----------------|
| department | reference | 1:1 Department mapping |
| businessUnit | reference | Higher level grouping |
| budget | decimal | Budget limit (HR view) |
| spendingLimit | decimal | Approval limit |

---

## 4. Integration Context

Cost Center is typically **Mastered in Finance/ERP** and **Slave in HCM**.

*   **Flow**: ERP (Create CC) → iPaaS/Integration → HCM (Create FOCostCenter).
*   **Usage**:
    *   **Hiring**: Select Cost Center for new hire.
    *   **Payroll**: Split payroll costs across multiple Cost Centers.
    *   **Expenses**: Charge expense reports to Cost Center.

---

## 5. Relationships

| Relationship | Target | Cardinality | Description |
|--------------|--------|-------------|-------------|
| legalEntity | LegalEntity | N:1 | Owning Company |
| manager | Employee | N:1 | Budget Holder |
| parent | CostCenter | N:1 | Hierarchy |
| employees | Employee | 1:N | Headcount in CC |
| glAccount | GLAccount | N:1 | Finance mapping |

---

*Document Status: APPROVED*
