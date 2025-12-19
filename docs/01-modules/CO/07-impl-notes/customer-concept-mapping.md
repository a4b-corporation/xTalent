# Customer Concept Mapping to xTalent Ontology

**Date**: 2025-12-19  
**Customer**: [Customer Name]  
**Purpose**: Map customer's employment and contract terminology to xTalent Core Module ontology

---

## 📋 Customer's Current Concepts

The customer has the following classification structure:

### 1. Employee Type
- Permanent
- Contractor
- Intern
- Freelance

### 2. Contract Group Type
- Hợp đồng lao động (Employment Contract)
- Hợp đồng thử việc (Probation Contract)
- Hợp đồng dịch vụ (Service Contract)

### 3. Contract Type
- Hợp đồng lao động 1 năm (1-year Employment Contract)
- Hợp đồng lao động 3 năm (3-year Employment Contract)
- Hợp đồng lao động không xác định (Indefinite Employment Contract)
- Hợp đồng dịch vụ 6 tháng (6-month Service Contract)

### 4. Appendix Type
- Phụ lục - Signing Bonus
- Phụ lục - Staff Movement

---

## 🎯 Mapping to xTalent Ontology

### Mapping Overview

```
Customer Concept          →  xTalent Entity.Attribute
─────────────────────────────────────────────────────────
Employee Type             →  WorkRelationship.relationship_type_code
Contract Group Type       →  Contract.contract_type_code (high-level)
Contract Type             →  ContractTemplate.code + Contract instance
Appendix Type             →  Contract.parent_relationship_type
```

---

## 1️⃣ Employee Type → WorkRelationship.relationship_type_code

### Mapping Table

| Customer's "Employee Type" | xTalent Mapping | Has Employee Record? |
|---------------------------|-----------------|---------------------|
| **Permanent** | `WorkRelationship.relationship_type_code = EMPLOYEE`<br>`Employee.employee_class_code = REGULAR` | ✅ YES |
| **Contractor** | `WorkRelationship.relationship_type_code = CONTRACTOR` | ❌ NO |
| **Intern** | `WorkRelationship.relationship_type_code = INTERN` | ⚠️ OPTIONAL (if paid) |
| **Freelance** | `WorkRelationship.relationship_type_code = CONTRACTOR`<br>(same as Contractor) | ❌ NO |

### Implementation Details

#### Permanent Employee
```yaml
Worker:
  id: WORKER-001
  person_type: EMPLOYEE

WorkRelationship:
  relationship_type_code: EMPLOYEE  # Maps from "Permanent"
  legal_entity_code: CUSTOMER-VN
  status_code: ACTIVE

Employee:
  work_relationship_id: WR-001
  employee_class_code: REGULAR  # Permanent = Regular employee
  employee_code: "EMP-2024-001"
  hire_date: 2024-01-15
```

#### Contractor
```yaml
Worker:
  id: WORKER-002
  person_type: CONTRACTOR

WorkRelationship:
  relationship_type_code: CONTRACTOR  # Maps from "Contractor"
  legal_entity_code: CUSTOMER-VN
  status_code: ACTIVE

# NO Employee record for contractors
```

#### Intern
```yaml
Worker:
  id: WORKER-003
  person_type: INTERN

WorkRelationship:
  relationship_type_code: INTERN  # Maps from "Intern"
  legal_entity_code: CUSTOMER-VN
  status_code: ACTIVE

# Employee record ONLY if paid intern
Employee:  # Optional
  work_relationship_id: WR-003
  employee_class_code: TRAINEE
  employee_code: "INTERN-2024-001"
```

#### Freelance
```yaml
# Same as Contractor - no difference in xTalent
Worker:
  id: WORKER-004
  person_type: CONTRACTOR

WorkRelationship:
  relationship_type_code: CONTRACTOR  # Freelance = Contractor
  legal_entity_code: CUSTOMER-VN
  status_code: ACTIVE
```

**Note**: If customer wants to distinguish Freelance from Contractor, use `metadata` field:
```yaml
WorkRelationship:
  relationship_type_code: CONTRACTOR
  metadata:
    customer_employee_type: "FREELANCE"  # Custom field
```

---

## 2️⃣ Contract Group Type → Contract.contract_type_code

### Mapping Table

| Customer's "Contract Group Type" | xTalent Mapping |
|----------------------------------|-----------------|
| **Hợp đồng lao động** (Employment Contract) | `Contract.contract_type_code = PERMANENT` or `FIXED_TERM` |
| **Hợp đồng thử việc** (Probation Contract) | `Contract.contract_type_code = PROBATION` |
| **Hợp đồng dịch vụ** (Service Contract) | `Contract.contract_type_code = SERVICE_AGREEMENT` ✨ |

**Note**: `SERVICE_AGREEMENT` is a new code value we should add to support service contracts.

### Implementation Details

#### Hợp đồng lao động (Employment Contract)
```yaml
# For Permanent employees
Contract:
  employee_id: EMP-001
  contract_type_code: PERMANENT  # If indefinite term
  # OR
  contract_type_code: FIXED_TERM  # If 1-year or 3-year
  start_date: 2024-01-15
  end_date: null  # For PERMANENT
  # OR
  end_date: 2025-01-15  # For FIXED_TERM
```

#### Hợp đồng thử việc (Probation Contract)
```yaml
Contract:
  employee_id: EMP-001
  contract_type_code: PROBATION
  start_date: 2024-01-15
  end_date: 2024-04-15  # Typically 2-3 months
  probation_end_date: 2024-04-15
```

#### Hợp đồng dịch vụ (Service Contract)
```yaml
# For Contractors/Freelancers
Contract:
  work_relationship_id: WR-002  # Links to WorkRelationship, not Employee
  contract_type_code: SERVICE_AGREEMENT  # NEW code value
  start_date: 2024-02-01
  end_date: 2024-08-01  # 6 months
  supplier_id: null  # Direct contractor (not through agency)
```

---

## 3️⃣ Contract Type → ContractTemplate + Contract

### Strategy

Customer's "Contract Type" combines:
1. **Contract Group** (employment vs service)
2. **Duration** (1 year, 3 years, indefinite, 6 months)

**xTalent Approach**: Use **ContractTemplate** to define standard contract types.

### Mapping Table

| Customer's "Contract Type" | xTalent ContractTemplate | Contract Instance |
|---------------------------|-------------------------|-------------------|
| **Hợp đồng lao động 1 năm** | Template: `VN_EMP_FIXED_1Y` | `contract_type_code = FIXED_TERM`<br>`duration = 12 MONTH` |
| **Hợp đồng lao động 3 năm** | Template: `VN_EMP_FIXED_3Y` | `contract_type_code = FIXED_TERM`<br>`duration = 36 MONTH` |
| **Hợp đồng lao động không xác định** | Template: `VN_EMP_PERMANENT` | `contract_type_code = PERMANENT`<br>`end_date = null` |
| **Hợp đồng dịch vụ 6 tháng** | Template: `VN_SERVICE_6M` | `contract_type_code = SERVICE_AGREEMENT`<br>`duration = 6 MONTH` |

### Implementation: ContractTemplate Setup

#### Template 1: 1-Year Employment Contract
```yaml
ContractTemplate:
  code: "VN_EMP_FIXED_1Y"
  name: "Vietnam - Employment Contract 1 Year"
  name_local: "Hợp đồng lao động 1 năm"
  contract_type_code: FIXED_TERM
  country_code: VN
  
  # Duration Configuration
  default_duration_value: 12
  default_duration_unit: MONTH
  min_duration_value: 12
  min_duration_unit: MONTH
  max_duration_value: 12
  max_duration_unit: MONTH
  
  # Probation Configuration
  probation_required: true
  probation_duration_value: 60
  probation_duration_unit: DAY
  
  # Renewal Configuration
  allows_renewal: true
  max_renewals: 2  # Vietnam labor law
  renewal_notice_days: 30
  
  # Termination
  default_notice_period_days: 30
  
  # Legal Compliance
  legal_requirements:
    max_consecutive_fixed_terms: 2
    labor_code_reference: "VN_LC_2019_Article_22"
```

#### Template 2: 3-Year Employment Contract
```yaml
ContractTemplate:
  code: "VN_EMP_FIXED_3Y"
  name: "Vietnam - Employment Contract 3 Years"
  name_local: "Hợp đồng lao động 3 năm"
  contract_type_code: FIXED_TERM
  country_code: VN
  
  default_duration_value: 36
  default_duration_unit: MONTH
  max_duration_value: 36
  max_duration_unit: MONTH  # VN max for fixed-term
  
  probation_required: true
  probation_duration_value: 60
  probation_duration_unit: DAY
  
  allows_renewal: true
  max_renewals: 1  # Only 1 renewal allowed for 3-year
  
  default_notice_period_days: 45  # Longer notice for 3-year
```

#### Template 3: Indefinite Employment Contract
```yaml
ContractTemplate:
  code: "VN_EMP_PERMANENT"
  name: "Vietnam - Permanent Employment Contract"
  name_local: "Hợp đồng lao động không xác định"
  contract_type_code: PERMANENT
  country_code: VN
  
  # No duration for permanent
  default_duration_value: null
  default_duration_unit: null
  max_duration_value: null
  
  probation_required: true
  probation_duration_value: 60
  probation_duration_unit: DAY
  
  allows_renewal: false  # Permanent doesn't need renewal
  
  default_notice_period_days: 30
```

#### Template 4: 6-Month Service Contract
```yaml
ContractTemplate:
  code: "VN_SERVICE_6M"
  name: "Vietnam - Service Contract 6 Months"
  name_local: "Hợp đồng dịch vụ 6 tháng"
  contract_type_code: SERVICE_AGREEMENT
  country_code: VN
  
  default_duration_value: 6
  default_duration_unit: MONTH
  max_duration_value: 12
  max_duration_unit: MONTH
  
  probation_required: false  # No probation for service contracts
  
  allows_renewal: true
  max_renewals: null  # Unlimited renewals for service contracts
  
  default_notice_period_days: 15  # Shorter notice for contractors
```

### Implementation: Contract Instance

When creating a contract, select the appropriate template:

```yaml
# Example: Creating a 1-year employment contract
Contract:
  employee_id: EMP-001
  template_id: TEMPLATE-VN-EMP-FIXED-1Y  # Reference to template
  contract_type_code: FIXED_TERM  # Inherited from template
  contract_number: "HĐLĐ-2024-001"
  
  # Duration inherited from template
  duration_value: 12  # From template
  duration_unit: MONTH
  
  start_date: 2024-01-15
  end_date: 2025-01-15  # Auto-calculated: start + 12 months
  
  # Probation inherited from template
  probation_end_date: 2024-03-15  # start + 60 days
  
  # Notice period inherited from template
  notice_period_days: 30
  
  # Salary (specific to this contract)
  base_salary: 50000000
  salary_currency_code: VND
  salary_frequency_code: MONTHLY
```

---

## 4️⃣ Appendix Type → Contract Fields

### Mapping Table

| Customer's "Appendix Type" | parent_relationship_type | amendment_type_code |
|---------------------------|-------------------------|---------------------|
| **Phụ lục - Signing Bonus** | `ADDENDUM` | `SIGNING_BONUS` |
| **Phụ lục - Staff Movement** | `AMENDMENT` | `STAFF_MOVEMENT` |

### Understanding AMENDMENT vs ADDENDUM

#### AMENDMENT (Sửa đổi)
- **Modifies** existing contract terms
- Changes salary, position, working hours, etc.
- **Supersedes** original terms
- Examples: Salary change, position change, working hours change

#### ADDENDUM (Phụ lục bổ sung)
- **Adds** new terms
- Does NOT change existing terms
- **Supplements** original contract
- Examples: Signing bonus, additional benefits

### Understanding Appendix Types

#### Phụ lục - Signing Bonus (Addendum)
**Nature**: Adds new terms (bonus) without changing existing contract terms.

```yaml
# Original Contract
Contract#1:
  id: CONTRACT-001
  employee_id: EMP-001
  contract_type_code: FIXED_TERM
  start_date: 2024-01-15
  end_date: 2025-01-15
  base_salary: 50000000
  parent_contract_id: null

# Appendix: Signing Bonus
Contract#2:
  id: CONTRACT-002
  employee_id: EMP-001
  contract_type_code: null  # Not applicable for appendix
  parent_contract_id: CONTRACT-001
  parent_relationship_type: ADDENDUM  # Adding new terms
  amendment_type_code: SIGNING_BONUS  # ✨ NEW field!
  
  start_date: 2024-01-15  # Effective from hire date
  
  # Original terms unchanged
  base_salary: null  # Not changing salary
  
  # New terms added in metadata
  metadata:
    bonus_amount: 10000000
    payment_date: "2024-01-15"
    signing_bonus_conditions: "Payable after 3 months employment"
```

#### Phụ lục - Staff Movement (Amendment)
**Nature**: Modifies existing terms (position, department, salary) due to transfer/promotion.

```yaml
# Original Contract
Contract#1:
  id: CONTRACT-001
  employee_id: EMP-001
  contract_type_code: PERMANENT
  start_date: 2024-01-15
  base_salary: 50000000
  metadata:
    position: "Junior Developer"
    department: "Engineering Team A"

# Appendix: Staff Movement (Promotion)
Contract#2:
  id: CONTRACT-002
  employee_id: EMP-001
  contract_type_code: null  # Not applicable for appendix
  parent_contract_id: CONTRACT-001
  parent_relationship_type: AMENDMENT  # Modifying existing terms
  amendment_type_code: STAFF_MOVEMENT  # ✨ NEW field!
  
  start_date: 2024-07-01  # Effective date of promotion
  
  # Modified terms in metadata
  metadata:
    movement_type: "PROMOTION"
    old_position: "Junior Developer"
    new_position: "Senior Developer"
    old_department: "Engineering Team A"
    new_department: "Engineering Team B"
    old_salary: 50000000
    new_salary: 70000000
    movement_reason: "Performance-based promotion"
```

### Appendix Workflow

```
Original Contract (CONTRACT-001)
  │
  ├─ Addendum: Signing Bonus (CONTRACT-002)
  │   └─ Adds bonus terms, doesn't change original
  │
  └─ Amendment: Staff Movement (CONTRACT-003)
      └─ Changes position/salary, supersedes some original terms
```

---

## 📊 Complete Example: Employee Lifecycle

### Scenario: Permanent Employee with Probation, Signing Bonus, and Promotion

```yaml
# Step 1: Create Worker
Worker:
  id: WORKER-001
  full_name: "Nguyễn Văn An"
  person_type: EMPLOYEE

# Step 2: Create WorkRelationship
WorkRelationship:
  id: WR-001
  worker_id: WORKER-001
  relationship_type_code: EMPLOYEE  # Customer: "Permanent"
  legal_entity_code: CUSTOMER-VN
  start_date: 2024-01-15

# Step 3: Create Employee
Employee:
  id: EMP-001
  work_relationship_id: WR-001
  employee_code: "EMP-2024-001"
  employee_class_code: PROBATION  # Initially on probation
  hire_date: 2024-01-15
  probation_end_date: 2024-03-15

# Step 4: Create Probation Contract
Contract#1:
  id: CONTRACT-001
  employee_id: EMP-001
  template_id: TEMPLATE-VN-PROBATION
  contract_type_code: PROBATION  # Customer: "Hợp đồng thử việc"
  contract_number: "HĐTV-2024-001"
  start_date: 2024-01-15
  end_date: 2024-03-15
  base_salary: 45000000
  parent_contract_id: null

# Step 5: Addendum - Signing Bonus
Contract#2:
  id: CONTRACT-002
  employee_id: EMP-001
  parent_contract_id: CONTRACT-001
  parent_relationship_type: ADDENDUM  # Customer: "Phụ lục - Signing Bonus"
  contract_number: "HĐTV-2024-001-PL01"
  start_date: 2024-01-15
  metadata:
    appendix_type: "SIGNING_BONUS"
    signing_bonus_amount: 5000000

# Step 6: Permanent Contract (after probation)
Contract#3:
  id: CONTRACT-003
  employee_id: EMP-001
  template_id: TEMPLATE-VN-EMP-PERMANENT
  contract_type_code: PERMANENT  # Customer: "Hợp đồng lao động không xác định"
  contract_number: "HĐLĐ-2024-001"
  parent_contract_id: CONTRACT-001
  parent_relationship_type: SUPERSESSION  # Replaces probation contract
  start_date: 2024-03-16
  end_date: null  # Indefinite
  base_salary: 50000000

# Update Employee
Employee:
  employee_class_code: REGULAR  # Changed from PROBATION

# Step 7: Amendment - Staff Movement (Promotion after 6 months)
Contract#4:
  id: CONTRACT-004
  employee_id: EMP-001
  parent_contract_id: CONTRACT-003
  parent_relationship_type: AMENDMENT  # Customer: "Phụ lục - Staff Movement"
  contract_number: "HĐLĐ-2024-001-PL01"
  start_date: 2024-09-01  # Promotion effective date
  base_salary: 70000000  # Increased
  metadata:
    appendix_type: "STAFF_MOVEMENT"
    movement_type: "PROMOTION"
    old_position: "Junior Developer"
    new_position: "Senior Developer"
```

---

## 🔧 Implementation Checklist

### 1. CodeList Setup

Add new code values to support customer concepts:

```yaml
# Add to CodeList
CodeList:
  # For SERVICE_AGREEMENT contract type
  - group_code: "CONTRACT_TYPE"
    code: "SERVICE_AGREEMENT"
    display_en: "Service Agreement"
    display_local: "Hợp đồng dịch vụ"
    sort_order: 50
  
  # For Appendix Types (in metadata)
  - group_code: "APPENDIX_TYPE"
    code: "SIGNING_BONUS"
    display_en: "Signing Bonus Appendix"
    display_local: "Phụ lục - Signing Bonus"
    sort_order: 10
  
  - group_code: "APPENDIX_TYPE"
    code: "STAFF_MOVEMENT"
    display_en: "Staff Movement Appendix"
    display_local: "Phụ lục - Staff Movement"
    sort_order: 20
```

### 2. ContractTemplate Creation

Create 4 standard templates:
- ✅ VN_EMP_FIXED_1Y (1-year employment)
- ✅ VN_EMP_FIXED_3Y (3-year employment)
- ✅ VN_EMP_PERMANENT (indefinite employment)
- ✅ VN_SERVICE_6M (6-month service contract)

### 3. UI/UX Considerations

#### Contract Creation Form
```
Select Contract Type:
  ○ Hợp đồng lao động 1 năm        → Template: VN_EMP_FIXED_1Y
  ○ Hợp đồng lao động 3 năm        → Template: VN_EMP_FIXED_3Y
  ○ Hợp đồng lao động không xác định → Template: VN_EMP_PERMANENT
  ○ Hợp đồng dịch vụ 6 tháng       → Template: VN_SERVICE_6M
```

#### Appendix Creation Form
```
Select Appendix Type:
  ○ Phụ lục - Signing Bonus    → parent_relationship_type: ADDENDUM
  ○ Phụ lục - Staff Movement   → parent_relationship_type: AMENDMENT
```

### 4. Reporting Considerations

Customer may want reports using their terminology:

```sql
-- Map xTalent to Customer terminology
SELECT 
  CASE wr.relationship_type_code
    WHEN 'EMPLOYEE' THEN 
      CASE e.employee_class_code
        WHEN 'REGULAR' THEN 'Permanent'
        ELSE 'Permanent'
      END
    WHEN 'CONTRACTOR' THEN 'Contractor/Freelance'
    WHEN 'INTERN' THEN 'Intern'
  END as customer_employee_type,
  
  CASE c.contract_type_code
    WHEN 'PROBATION' THEN 'Hợp đồng thử việc'
    WHEN 'FIXED_TERM' THEN 
      CASE c.duration_value
        WHEN 12 THEN 'Hợp đồng lao động 1 năm'
        WHEN 36 THEN 'Hợp đồng lao động 3 năm'
      END
    WHEN 'PERMANENT' THEN 'Hợp đồng lao động không xác định'
    WHEN 'SERVICE_AGREEMENT' THEN 'Hợp đồng dịch vụ 6 tháng'
  END as customer_contract_type
  
FROM worker w
JOIN work_relationship wr ON w.id = wr.worker_id
LEFT JOIN employee e ON wr.id = e.work_relationship_id
LEFT JOIN contract c ON e.id = c.employee_id
```

---

## ⚠️ Important Notes

### 1. Employee Type vs Employee Class

**Customer Confusion**: "Permanent" might mean:
- **Relationship Type**: Employee (vs Contractor)
- **Employment Class**: Regular (vs Probation)
- **Contract Type**: Permanent (vs Fixed-term)

**Clarification Needed**: 
- "Permanent" in customer's "Employee Type" → `relationship_type_code = EMPLOYEE` + `employee_class_code = REGULAR`
- "Permanent" in contract → `contract_type_code = PERMANENT`

### 2. Freelance vs Contractor

**Customer Distinction**: Customer may distinguish Freelance from Contractor.

**xTalent Approach**: Both are `CONTRACTOR` relationship type. Use `metadata` to track customer's distinction:
```yaml
WorkRelationship:
  relationship_type_code: CONTRACTOR
  metadata:
    customer_classification: "FREELANCE"  # or "CONTRACTOR"
```

### 3. Contract Group Type

**Customer's "Contract Group Type"** is essentially a **high-level categorization** of contracts.

**xTalent Approach**: Use `contract_type_code` directly. If customer needs grouping for reporting, create a view:
```sql
CREATE VIEW contract_groups AS
SELECT 
  CASE contract_type_code
    WHEN 'PERMANENT' THEN 'Hợp đồng lao động'
    WHEN 'FIXED_TERM' THEN 'Hợp đồng lao động'
    WHEN 'PROBATION' THEN 'Hợp đồng thử việc'
    WHEN 'SERVICE_AGREEMENT' THEN 'Hợp đồng dịch vụ'
  END as contract_group
FROM contract;
```

---

## ✅ Final Mapping Summary

| Customer Concept | xTalent Implementation | Notes |
|------------------|----------------------|-------|
| **Employee Type: Permanent** | `WorkRelationship.relationship_type_code = EMPLOYEE`<br>`Employee.employee_class_code = REGULAR` | Creates Employee record |
| **Employee Type: Contractor** | `WorkRelationship.relationship_type_code = CONTRACTOR` | No Employee record |
| **Employee Type: Intern** | `WorkRelationship.relationship_type_code = INTERN` | Optional Employee record |
| **Employee Type: Freelance** | `WorkRelationship.relationship_type_code = CONTRACTOR`<br>`WorkRelationship.metadata.customer_classification = "FREELANCE"` | Same as Contractor |
| **Contract Group: Hợp đồng lao động** | `Contract.contract_type_code = PERMANENT` or `FIXED_TERM` | Employment contract |
| **Contract Group: Hợp đồng thử việc** | `Contract.contract_type_code = PROBATION` | Probation contract |
| **Contract Group: Hợp đồng dịch vụ** | `Contract.contract_type_code = SERVICE_AGREEMENT` | Service contract |
| **Contract Type: 1 năm** | `Contract.template_id → ContractTemplate(code="VN_EMP_FIXED_1Y")`<br>`Contract.contract_type_code = FIXED_TERM`<br>`Contract.duration_value = 12, duration_unit = MONTH` | Template provides defaults |
| **Contract Type: 3 năm** | `Contract.template_id → ContractTemplate(code="VN_EMP_FIXED_3Y")`<br>`Contract.contract_type_code = FIXED_TERM`<br>`Contract.duration_value = 36, duration_unit = MONTH` | Template provides defaults |
| **Contract Type: không xác định** | `Contract.template_id → ContractTemplate(code="VN_EMP_PERMANENT")`<br>`Contract.contract_type_code = PERMANENT` | Template provides defaults |
| **Contract Type: dịch vụ 6 tháng** | `Contract.template_id → ContractTemplate(code="VN_SERVICE_6M")`<br>`Contract.contract_type_code = SERVICE_AGREEMENT`<br>`Contract.duration_value = 6, duration_unit = MONTH` | Template provides defaults |
| **Appendix: Signing Bonus** | `Contract.parent_contract_id = [main contract]`<br>`Contract.parent_relationship_type = ADDENDUM`<br>`Contract.amendment_type_code = SIGNING_BONUS` | Adds bonus terms |
| **Appendix: Staff Movement** | `Contract.parent_contract_id = [main contract]`<br>`Contract.parent_relationship_type = AMENDMENT`<br>`Contract.amendment_type_code = STAFF_MOVEMENT` | Modifies position/salary |

---

## 📝 Implementation Steps

### Step 1: Create ContractTemplates

```sql
INSERT INTO contract_template (code, name, contract_type_code, default_duration_value, default_duration_unit) VALUES
('VN_EMP_FIXED_1Y', 'Hợp đồng lao động 1 năm', 'FIXED_TERM', 12, 'MONTH'),
('VN_EMP_FIXED_3Y', 'Hợp đồng lao động 3 năm', 'FIXED_TERM', 36, 'MONTH'),
('VN_EMP_PERMANENT', 'Hợp đồng không xác định', 'PERMANENT', NULL, NULL),
('VN_SERVICE_6M', 'Hợp đồng dịch vụ 6 tháng', 'SERVICE_AGREEMENT', 6, 'MONTH');
```

### Step 2: Add CodeList Values

```sql
-- Amendment types
INSERT INTO code_list (group_code, code, display_local, display_en) VALUES
('AMENDMENT_TYPE', 'SIGNING_BONUS', 'Phụ lục - Signing Bonus', 'Signing Bonus Appendix'),
('AMENDMENT_TYPE', 'STAFF_MOVEMENT', 'Phụ lục - Staff Movement', 'Staff Movement Appendix'),
('AMENDMENT_TYPE', 'SALARY_CHANGE', 'Phụ lục - Thay đổi lương', 'Salary Change'),
('AMENDMENT_TYPE', 'POSITION_CHANGE', 'Phụ lục - Thay đổi vị trí', 'Position Change'),
('AMENDMENT_TYPE', 'BENEFITS_CHANGE', 'Phụ lục - Thay đổi phúc lợi', 'Benefits Change'),
('AMENDMENT_TYPE', 'WORKING_HOURS_CHANGE', 'Phụ lục - Thay đổi giờ làm', 'Working Hours Change'),
('AMENDMENT_TYPE', 'OTHER', 'Phụ lục - Khác', 'Other Amendment');

-- Parent relationship types
INSERT INTO code_list (group_code, code, display_local, display_en) VALUES
('PARENT_RELATIONSHIP_TYPE', 'AMENDMENT', 'Sửa đổi', 'Amendment'),
('PARENT_RELATIONSHIP_TYPE', 'ADDENDUM', 'Phụ lục bổ sung', 'Addendum'),
('PARENT_RELATIONSHIP_TYPE', 'RENEWAL', 'Gia hạn', 'Renewal'),
('PARENT_RELATIONSHIP_TYPE', 'SUPERSESSION', 'Thay thế', 'Supersession');
```

### Step 3: UI Implementation

```javascript
// Contract creation - select template
function createContract(employeeId, templateCode) {
  const template = getContractTemplate(templateCode);
  
  const contract = {
    employee_id: employeeId,
    template_id: template.id,
    contract_type_code: template.contract_type_code,
    duration_value: template.default_duration_value,
    duration_unit: template.default_duration_unit,
    // ... other fields from template
  };
  
  return contract;
}

// Amendment creation
function createAmendment(parentContractId, amendmentType) {
  const amendment = {
    parent_contract_id: parentContractId,
    parent_relationship_type: amendmentType === 'SIGNING_BONUS' ? 'ADDENDUM' : 'AMENDMENT',
    amendment_type_code: amendmentType,
    template_id: null,  // Amendments don't use templates
    // ... other fields
  };
  
  return amendment;
}
```

---

## 🎯 Key Design Decisions

### 1. Contract Type Hierarchy

**Customer has 2 levels**:
- Contract Group Type (high-level): Hợp đồng lao động, Hợp đồng thử việc, Hợp đồng dịch vụ
- Contract Type (specific): 1 năm, 3 năm, không xác định

**xTalent solution**:
- **Contract Group Type** → `Contract.contract_type_code` (PERMANENT, FIXED_TERM, PROBATION, SERVICE_AGREEMENT)
- **Contract Type** → `ContractTemplate.code` (VN_EMP_FIXED_1Y, VN_EMP_FIXED_3Y, etc.)
- Each contract instance links to template via `Contract.template_id`

**Benefits**:
- ✅ Template provides defaults (duration, probation period, notice period)
- ✅ Ensures consistency across contracts of same type
- ✅ Easy to update defaults globally
- ✅ Contract instances can override template values if needed

### 2. Amendment Categorization

**Customer has**:
- Phụ lục - Signing Bonus
- Phụ lục - Staff Movement

**xTalent solution**:
- `Contract.parent_relationship_type` = AMENDMENT or ADDENDUM
- `Contract.amendment_type_code` = SIGNING_BONUS, STAFF_MOVEMENT, etc.
- Amendment details stored in `Contract.metadata`

**Benefits**:
- ✅ Clear categorization with dedicated fields
- ✅ Easy to query by amendment type
- ✅ Distinguishes between AMENDMENT (modifies) vs ADDENDUM (adds)
- ✅ Aligns with industry standards (Workday, SAP, Oracle)

---

**Document Version**: 3.0  
**Updated**: 2025-12-19  
**Implementation Approach**: 
- Contract hierarchy: Use `template_id` to link to `ContractTemplate`
- Amendment categorization: Use `parent_relationship_type` + `amendment_type_code` fields
- Customer terminology: Store in `metadata` for reporting/UI

**Next Steps**: 
1. ✅ Create ContractTemplates for 4 contract types
2. ✅ Add CodeList values for AMENDMENT_TYPE and PARENT_RELATIONSHIP_TYPE
3. Update UI to use templates and amendment fields
4. Migrate existing data (if any)
