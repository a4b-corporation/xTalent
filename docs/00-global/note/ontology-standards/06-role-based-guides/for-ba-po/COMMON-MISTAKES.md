# BA/PO Guide: Common Mistakes

**Version**: 1.0  
**Last Updated**: 2025-12-25  
**Audience**: Business Analysts, Product Owners  
**Purpose**: Learn from common errors to define ontology correctly

---

## 🎯 Why This Matters

These mistakes cause:
- Rework during implementation
- Data model inconsistencies
- Confusion in API design
- Testing gaps
- Maintenance headaches

Learn to spot and avoid them early.

---

## 🚫 Top 10 Mistakes

### 1. Modeling Workflows as Entities

**❌ Wrong**:
```yaml
entity: PayrollProcess
classification: AGGREGATE_ROOT
attributes:
  step_1_collect_time: boolean
  step_2_calculate: boolean
  step_3_approve: boolean
```

**✅ Correct**:
```yaml
# payroll-run.workflow.yaml
workflow: PayrollRun
steps:
  - collect_time_data
  - calculate_pay
  - generate_results
  - await_approval
```

**How to spot**: If it has "steps" or "process" in the name, it's probably a workflow.

---

### 2. Confusing Transactions with Entities

**❌ Wrong**: Treating `PayResult` as an entity with lifecycle

```yaml
entity: PayResult
lifecycle:
  states: [DRAFT, APPROVED, PAID]  # Wrong! PayResult is immutable
```

**✅ Correct**: PayResult is a transaction (fact record)

```sql
-- Transaction: immutable record of what happened
CREATE TABLE pay_result (
    id UUID PRIMARY KEY,
    employee_id UUID NOT NULL,
    amount DECIMAL NOT NULL,
    calculated_at TIMESTAMP NOT NULL
    -- No updated_at! Transactions are immutable
);
```

**How to spot**: If it records "what already happened" and shouldn't change, it's a transaction.

---

### 3. Over-Engineering with Too Many Entities

**❌ Wrong**: Creating separate entities for every attribute group

```
Employee
├── EmployeePersonalInfo
├── EmployeeContactInfo  
├── EmployeeAddress
├── EmployeeEmergencyContact
└── EmployeePreferences
```

**✅ Correct**: Use VALUE_OBJECTs embedded in the aggregate

```yaml
entity: Employee
classification: AGGREGATE_ROOT

attributes:
  personal_info:
    type: object  # Embedded VALUE_OBJECT
    properties:
      birth_date: date
      nationality: string
      
  contact_info:
    type: object  # Embedded VALUE_OBJECT
    properties:
      email: string
      phone: string
```

**How to spot**: If it can't exist independently, it's probably a VALUE_OBJECT.

---

### 4. Circular Relationships

**❌ Wrong**:
```
Employee ──manages──> Team
Team ──contains──> Employee
Employee ──reports_to──> Employee
Manager ──is_a──> Employee    # Inheritance misuse
```

**✅ Correct**: Clear hierarchy without circles

```yaml
# Employee references manager (another employee)
entity: Employee
relationships:
  manager:
    target: Employee
    cardinality: N:1
    required: false  # Top-level has no manager
    
  direct_reports:
    target: Employee
    cardinality: 1:N
    inverse: manager
```

**How to spot**: Draw the relationship diagram - circles are red flags.

---

### 5. Missing Business Identity

**❌ Wrong**: Only technical ID

```yaml
entity: Employee
attributes:
  id:
    type: uuid
    primary_key: true
  name: string
  # No business identifier!
```

**✅ Correct**: Business-meaningful identifier

```yaml
entity: Employee
attributes:
  id:
    type: uuid
    primary_key: true
    
  employee_code:
    type: string
    required: true
    unique: true
    pattern: "^EMP[0-9]{6}$"
    description: "Human-readable employee identifier"
```

**How to spot**: Can business users identify this entity without showing the UUID?

---

### 6. Vague or Technical Definitions

**❌ Wrong**:
```yaml
entity: Assignment
definition: "Links employee to position"  # Too technical
```

**✅ Correct**:
```yaml
entity: Assignment
definition: "A formal placement of an employee in a specific position, 
             representing their job responsibilities and reporting structure 
             within the organization."
purpose: "Tracks who does what job, enables workforce planning, 
          and supports compensation calculations."
```

**How to spot**: Would a new business user understand this without asking?

---

### 7. Ignoring Time Dimensions

**❌ Wrong**: No effective dates

```yaml
entity: Salary
attributes:
  employee_id: uuid
  amount: decimal
  # When does this salary apply?
```

**✅ Correct**: Time-aware design

```yaml
entity: Salary
attributes:
  employee_id: uuid
  amount: decimal
  effective_date: date
  end_date: date  # nullable = current
  
constraints:
  - "No overlapping salary periods for same employee"
```

**How to spot**: Ask "When does this apply?" and "What was it before?"

---

### 8. Duplicating Concepts Across Modules

**❌ Wrong**: Each module defines its own "Employee"

```
Core HR: Employee { id, name, hire_date }
Payroll: PayrollEmployee { id, name, pay_grade }
TA: TimeEmployee { id, name, shift_pattern }
```

**✅ Correct**: Single source of truth with module-specific extensions

```yaml
# Core HR owns Employee
entity: Employee
attributes:
  id: uuid
  name: string
  hire_date: date

# Payroll references Core HR Employee
entity: PayrollAssignment
relationships:
  employee:
    $ref: "xtalent:core-hr:workforce:employee"
```

**How to spot**: Search for similar entity names across modules.

---

### 9. Missing Lifecycle States

**❌ Wrong**: No lifecycle defined

```yaml
entity: Contract
attributes:
  status: string  # Free text, no constraints
```

**✅ Correct**: Explicit lifecycle

```yaml
entity: Contract
lifecycle:
  states:
    - DRAFT
    - PENDING_APPROVAL
    - ACTIVE
    - EXPIRED
    - TERMINATED
  initial: DRAFT
  transitions:
    - from: DRAFT
      to: PENDING_APPROVAL
      action: submit_for_approval
      requires_role: HR_ADMIN
```

**How to spot**: Can the entity be in different states? Then define them explicitly.

---

### 10. Mixing Configuration with Business Data

**❌ Wrong**: Config in entity

```yaml
entity: PayElement
attributes:
  code: string
  name: string
  # These are system config, not business data
  retry_count: integer
  timeout_seconds: integer
  batch_size: integer
```

**✅ Correct**: Separate concerns

```yaml
# Business entity
entity: PayElement
attributes:
  code: string
  name: string
  element_type: enum
  calculation_rule: string

# System config (separate, not ontology)
# In configuration layer, not domain model
```

**How to spot**: Would business users ever need to know or change this value?

---

## ✅ Self-Check Questions

Before finalizing any entity:

1. **Is this a thing or an action?**
   - Thing → Entity ✅
   - Action → Workflow ❌

2. **Does it have independent identity?**
   - Yes → AGGREGATE_ROOT or ENTITY
   - No → VALUE_OBJECT

3. **Is it immutable after creation?**
   - Yes → Transaction record
   - No → Entity with lifecycle

4. **Who owns this concept?**
   - Clear owner → Good
   - Multiple owners → Need to clarify

5. **Can it change over time?**
   - Yes → Need effective dates
   - No → May be reference data

---

## 🔗 Related Documents

- [HOW-TO-DEFINE-ONTOLOGY.md](./HOW-TO-DEFINE-ONTOLOGY.md) — Step-by-step guide
- [WHAT-IS-NOT-ONTOLOGY.md](../../00-getting-started/WHAT-IS-NOT-ONTOLOGY.md) — Classification rules
- [FOUR-MODEL-COMPARISON.md](../../01-core-principles/FOUR-MODEL-COMPARISON.md) — Model types comparison
