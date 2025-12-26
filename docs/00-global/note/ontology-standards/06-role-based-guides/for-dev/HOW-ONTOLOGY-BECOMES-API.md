# Developer Guide: How Ontology Becomes API

**Version**: 1.0  
**Last Updated**: 2025-12-25  
**Audience**: Developers  
**Purpose**: Understand the transformation from ontology to API

---

## 🎯 The Transformation Pipeline

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Ontology   │ -> │  Database   │ -> │    API      │ -> │   Code      │
│   (YAML)    │    │   (DBML)    │    │ (OpenAPI)   │    │ (Generated) │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

---

## 📊 Ontology → Database Mapping

### Entity Classification → Table Type

| Classification | Table Pattern |
|---------------|---------------|
| AGGREGATE_ROOT | Main table with audit fields |
| ENTITY | Child table with FK to aggregate |
| VALUE_OBJECT | Embedded (JSON) or separate table |
| REF_DATA | Lookup table with code/name |

### Attribute Type → Column Type

| Ontology Type | PostgreSQL | MySQL | Notes |
|---------------|------------|-------|-------|
| `uuid` | `UUID` | `CHAR(36)` | Primary keys |
| `string` | `VARCHAR(n)` | `VARCHAR(n)` | Use `pattern` for length hint |
| `integer` | `INTEGER` | `INT` | |
| `decimal` | `NUMERIC(p,s)` | `DECIMAL(p,s)` | |
| `boolean` | `BOOLEAN` | `TINYINT(1)` | |
| `date` | `DATE` | `DATE` | |
| `datetime` | `TIMESTAMP` | `DATETIME` | |
| `enum` | `VARCHAR` + CHECK | `ENUM` | |
| `array` | `JSONB` | `JSON` | |
| `object` | `JSONB` | `JSON` | For VALUE_OBJECT |

### Example Transformation

**Ontology Input**:
```yaml
entity: Employee
classification: AGGREGATE_ROOT

attributes:
  id:
    type: uuid
    primary_key: true
  employee_code:
    type: string
    required: true
    unique: true
    pattern: "^EMP[0-9]{6}$"
  full_name:
    type: string
    required: true
  status:
    type: enum
    values: [DRAFT, ACTIVE, TERMINATED]
    default: DRAFT
    
relationships:
  department:
    target: Department
    cardinality: N:1
    required: true
```

**DBML Output**:
```sql
Table employee {
  id uuid [pk]
  employee_code varchar(10) [not null, unique]
  full_name varchar(255) [not null]
  status varchar(20) [not null, default: 'DRAFT']
  department_id uuid [not null, ref: > department.id]
  
  // Audit fields (auto-added for AGGREGATE_ROOT)
  created_at timestamp [not null, default: `now()`]
  updated_at timestamp [not null]
  created_by uuid [not null]
  updated_by uuid [not null]
  
  Indexes {
    employee_code [unique]
    department_id
  }
}
```

---

## 🔌 Ontology → API Mapping

### Classification → Endpoint Pattern

| Classification | REST Endpoints |
|---------------|----------------|
| AGGREGATE_ROOT | Full CRUD: `GET/POST/PUT/DELETE /employees` |
| ENTITY | Nested: `GET /employees/:id/assignments` |
| VALUE_OBJECT | Embedded in parent response |
| REF_DATA | Read-only: `GET /reference/countries` |

### Lifecycle → State Transitions API

**From Lifecycle**:
```yaml
lifecycle:
  transitions:
    - from: DRAFT
      to: ACTIVE
      action: activate
```

**To API**:
```yaml
# OpenAPI
paths:
  /employees/{id}/activate:
    post:
      summary: "Activate employee"
      description: "Transitions employee from DRAFT to ACTIVE"
      responses:
        200:
          description: "Employee activated"
        400:
          description: "Invalid state transition"
```

### Relationships → API Response

**From Relationship**:
```yaml
relationships:
  department:
    target: Department
    cardinality: N:1
  assignments:
    target: Assignment
    cardinality: 1:N
```

**To API Response**:
```json
{
  "id": "...",
  "employee_code": "EMP000123",
  "department": {
    "id": "...",
    "name": "Engineering"
  },
  "_links": {
    "assignments": "/employees/123/assignments"
  }
}
```

---

## 🧪 Ontology → Tests Mapping

### Validation Rules → Test Cases

**From Ontology**:
```yaml
attributes:
  employee_code:
    pattern: "^EMP[0-9]{6}$"
    unique: true
```

**To Test Cases**:
```gherkin
Scenario: Valid employee code format
  Given I create an employee with code "EMP000123"
  Then the employee is created successfully

Scenario: Invalid employee code format
  Given I create an employee with code "INVALID"
  Then I receive validation error "employee_code does not match pattern"

Scenario: Duplicate employee code
  Given an employee with code "EMP000123" exists
  When I create another employee with code "EMP000123"
  Then I receive validation error "employee_code must be unique"
```

### Lifecycle → State Transition Tests

**From Lifecycle**:
```yaml
lifecycle:
  transitions:
    - from: DRAFT
      to: ACTIVE
      action: activate
```

**To Test Cases**:
```gherkin
Scenario: Successful activation
  Given an employee in DRAFT status
  When I activate the employee
  Then the employee status is ACTIVE

Scenario: Invalid activation from TERMINATED
  Given an employee in TERMINATED status
  When I try to activate the employee
  Then I receive error "Cannot activate from TERMINATED status"
```

---

## 💻 Code Generation Patterns

### Repository Pattern
```python
# Generated from Employee aggregate
class EmployeeRepository:
    def find_by_id(self, id: UUID) -> Employee | None: ...
    def find_by_employee_code(self, code: str) -> Employee | None: ...  # From unique constraint
    def find_by_department(self, dept_id: UUID) -> List[Employee]: ...  # From relationship
    def save(self, employee: Employee) -> Employee: ...
```

### Domain Model
```python
# Generated from Employee attributes + lifecycle
@dataclass
class Employee:
    id: UUID
    employee_code: str
    full_name: str
    status: EmployeeStatus
    department: Department
    
    def activate(self) -> None:
        """Transition from DRAFT to ACTIVE"""
        if self.status != EmployeeStatus.DRAFT:
            raise InvalidStateTransition("Can only activate from DRAFT")
        self.status = EmployeeStatus.ACTIVE
```

### Validation
```python
# Generated from attribute constraints
def validate_employee_code(value: str) -> bool:
    pattern = re.compile(r"^EMP[0-9]{6}$")
    return bool(pattern.match(value))
```

---

## 📋 Generation Checklist

Before generating code:

- [ ] All required metadata present
- [ ] All attribute types are valid
- [ ] All relationships have valid targets
- [ ] Lifecycle is complete (no orphan states)
- [ ] Validation patterns are valid regex

After generation:

- [ ] Database migrations run successfully
- [ ] API endpoints match specification
- [ ] All generated tests pass
- [ ] No orphan code (unused classes/functions)

---

## 🔗 Related Documents

- [ENTITY-SCHEMA.md](../../03-schemas/ENTITY-SCHEMA.md) — Complete schema reference
- [WHAT-YOU-NEED-TO-FOLLOW.md](./WHAT-YOU-NEED-TO-FOLLOW.md) — Developer standards
- [AI-AGENT-GUIDE.md](../../05-guides/AI-AGENT-GUIDE.md) — AI code generation
