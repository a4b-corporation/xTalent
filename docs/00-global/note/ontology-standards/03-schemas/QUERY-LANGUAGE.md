# Ontology Query Language (OQL) Specification

**Version**: 3.0  
**Audience**: AI Agents, Developers  
**Inspired By**: SPARQL, Gremlin, GraphQL

---

## 🎯 Purpose

OQL (Ontology Query Language) provides a simple, human-readable way to:

1. **Traverse** entity relationships
2. **Filter** entities by conditions
3. **Aggregate** data across the ontology
4. **Query** workflows and actions

OQL is designed to be:
- **Readable** by both humans and AI agents
- **Translatable** to SQL, Gremlin, or SPARQL
- **Embeddable** in documentation and code comments

---

## 📋 Basic Syntax

### Path Expressions

Navigate relationships using `->`:

```oql
# Basic path: Employee to Department
Employee -> Department

# Multi-step path
Employee -> Assignment -> Position -> Department

# With entity ID
Employee[id="550e8400-..."] -> Department
```

### Filtering

Filter entities using `[condition]`:

```oql
# Single condition
Employee[status="ACTIVE"]

# Multiple conditions (AND)
Employee[status="ACTIVE" AND hire_date >= "2020-01-01"]

# OR conditions
Employee[department.name="Engineering" OR department.name="Product"]

# Complex conditions
Employee[
  status="ACTIVE" 
  AND years_of_service >= 5 
  AND (is_manager=true OR has_direct_reports > 0)
]
```

### Selecting Attributes

Select specific attributes using `{attributes}`:

```oql
# Select specific fields
Employee[status="ACTIVE"] {id, code, full_name, hire_date}

# Select with relationship data
Employee[status="ACTIVE"] {
  id,
  full_name,
  department: Department {name, code}
}
```

---

## 📊 Query Types

### 1. Entity Query

Find entities matching criteria:

```oql
# Find all active employees
FIND Employee[status="ACTIVE"]

# Find with limit
FIND Employee[status="ACTIVE"] LIMIT 100

# Find with ordering
FIND Employee[status="ACTIVE"] 
ORDER BY hire_date DESC
LIMIT 10
```

### 2. Path Query

Traverse relationships:

```oql
# Find all employees in Engineering department
FIND Employee -> Department[name="Engineering"]

# Find all managers in a specific location
FIND Employee[is_manager=true] -> Department -> Location[city="Ho Chi Minh"]

# Reverse traversal (find who reports to a manager)
FIND Employee[manager_id="..."] <- Employee
```

### 3. Aggregation Query

Compute aggregates:

```oql
# Count employees by department
AGGREGATE Employee 
GROUP BY department.name 
COMPUTE COUNT(*) AS employee_count

# Average salary by department
AGGREGATE Employee[status="ACTIVE"]
GROUP BY department.name
COMPUTE AVG(salary) AS avg_salary, COUNT(*) AS count

# Multiple aggregations
AGGREGATE Employee
GROUP BY status, department.name
COMPUTE 
  COUNT(*) AS total,
  SUM(salary) AS total_salary,
  AVG(years_of_service) AS avg_tenure
```

### 4. Existence Query

Check if relationships exist:

```oql
# Check if employee has active assignments
EXISTS Employee[id="..."] -> Assignment[status="ACTIVE"]

# Check if employee is in a specific department
EXISTS Employee[id="..."] -> Department[name="Engineering"]
```

### 5. Workflow Query

Query workflow instances:

```oql
# Find all in-progress onboarding workflows
FIND Workflow[code="WF-001" AND status="IN_PROGRESS"]

# Find workflows waiting on a specific step
FIND Workflow[current_step="STEP-005"] {
  workflow_id,
  started_at,
  context.employee_name
}

# Find workflows past SLA
FIND Workflow[
  status="IN_PROGRESS" 
  AND started_at < NOW() - INTERVAL "10 days"
]
```

---

## 🔗 Relationship Traversal

### Forward Traversal

```oql
# Follow defined relationship
Employee -> Department

# Named relationship
Employee -[assignments]-> Assignment

# With filter on relationship
Employee -[assignments WHERE status="ACTIVE"]-> Assignment
```

### Reverse Traversal

```oql
# Reverse relationship (inverse)
Department <- Employee

# Find all employees in a department
Department[id="..."] <- Employee

# Reverse with filter
Department[name="Engineering"] <- Employee[status="ACTIVE"]
```

### Deep Traversal

```oql
# Multi-level traversal
Employee -> Assignment -> Position -> JobFamily -> JobCategory

# Variable depth (recursive)
Employee -[manager*1..5]-> Employee  # Up to 5 levels of management

# All ancestors
Employee -[manager*]-> Employee  # All managers up the chain
```

---

## 🧮 Operators

### Comparison Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Equals | `status="ACTIVE"` |
| `!=` | Not equals | `status!="TERMINATED"` |
| `>` | Greater than | `salary > 50000` |
| `>=` | Greater or equal | `hire_date >= "2020-01-01"` |
| `<` | Less than | `age < 65` |
| `<=` | Less or equal | `years_of_service <= 5` |
| `IN` | In list | `status IN ("ACTIVE", "INACTIVE")` |
| `NOT IN` | Not in list | `status NOT IN ("TERMINATED")` |
| `LIKE` | Pattern match | `name LIKE "John%"` |
| `BETWEEN` | Range | `salary BETWEEN 50000 AND 100000` |
| `IS NULL` | Null check | `manager_id IS NULL` |
| `IS NOT NULL` | Not null check | `termination_date IS NOT NULL` |

### Logical Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `AND` | Logical AND | `status="ACTIVE" AND is_manager=true` |
| `OR` | Logical OR | `dept="Eng" OR dept="Product"` |
| `NOT` | Logical NOT | `NOT status="TERMINATED"` |

### Aggregate Functions

| Function | Description | Example |
|----------|-------------|---------|
| `COUNT(*)` | Count rows | `COUNT(*)` |
| `COUNT(attr)` | Count non-null | `COUNT(manager_id)` |
| `SUM(attr)` | Sum values | `SUM(salary)` |
| `AVG(attr)` | Average | `AVG(salary)` |
| `MIN(attr)` | Minimum | `MIN(hire_date)` |
| `MAX(attr)` | Maximum | `MAX(salary)` |
| `COLLECT(attr)` | Collect into array | `COLLECT(skill)` |

---

## 📝 Common Query Patterns

### Pattern 1: Find Related Entities

```oql
# All employees in Engineering and their assignments
FIND Employee -> Department[name="Engineering"]
INCLUDE {
  employee: {id, full_name, status},
  assignments: Assignment[status="ACTIVE"] {position.title, start_date}
}
```

### Pattern 2: Hierarchical Query

```oql
# Find entire reporting chain for an employee
FIND Employee[id="..."] -[manager*]-> Employee {
  id, full_name, title, level: PATH_LENGTH()
}
ORDER BY level ASC
```

### Pattern 3: Cross-Module Query

```oql
# Find employees with their payroll data
FIND Employee[status="ACTIVE"]
JOIN Payroll:PayrollRecord[employee_id=Employee.id]
{
  employee: {id, full_name},
  payroll: {gross_pay, net_pay, pay_period}
}
```

### Pattern 4: Temporal Query

```oql
# Find employees as of a specific date (SCD2)
FIND Employee[
  effective_start_date <= "2023-06-15"
  AND (effective_end_date IS NULL OR effective_end_date > "2023-06-15")
]

# Changes in last 30 days
FIND Employee[updated_at >= NOW() - INTERVAL "30 days"]
ORDER BY updated_at DESC
```

### Pattern 5: Action Applicability

```oql
# Find employees eligible for termination action
FIND Employee 
WHERE CAN_EXECUTE(Action:TerminateEmployee)
{
  id, full_name, status
}
```

---

## 🔄 OQL to SQL Translation

OQL can be translated to SQL for execution:

### Example 1: Simple Query

**OQL:**
```oql
FIND Employee[status="ACTIVE" AND department.name="Engineering"]
```

**SQL:**
```sql
SELECT e.*
FROM employee e
JOIN department d ON e.department_id = d.id
WHERE e.status = 'ACTIVE' AND d.name = 'Engineering';
```

### Example 2: Path Query

**OQL:**
```oql
FIND Employee -> Assignment[status="ACTIVE"] -> Position {title}
```

**SQL:**
```sql
SELECT DISTINCT p.title
FROM employee e
JOIN assignment a ON a.employee_id = e.id
JOIN position p ON a.position_id = p.id
WHERE a.status = 'ACTIVE';
```

### Example 3: Aggregation

**OQL:**
```oql
AGGREGATE Employee[status="ACTIVE"]
GROUP BY department.name
COMPUTE COUNT(*) AS count, AVG(salary) AS avg_salary
```

**SQL:**
```sql
SELECT d.name, COUNT(*) AS count, AVG(e.salary) AS avg_salary
FROM employee e
JOIN department d ON e.department_id = d.id
WHERE e.status = 'ACTIVE'
GROUP BY d.name;
```

---

## 🔄 OQL to Gremlin Translation

For graph database execution:

**OQL:**
```oql
FIND Employee[status="ACTIVE"] -> Department[name="Engineering"]
```

**Gremlin:**
```groovy
g.V().hasLabel('Employee').has('status', 'ACTIVE')
  .out('belongs_to')
  .hasLabel('Department').has('name', 'Engineering')
```

---

## 🤖 AI Agent Usage

AI agents can use OQL to:

### 1. Answer Domain Questions

**Question**: "How many active employees are in each department?"

**OQL Generated**:
```oql
AGGREGATE Employee[status="ACTIVE"]
GROUP BY department.name
COMPUTE COUNT(*) AS employee_count
ORDER BY employee_count DESC
```

### 2. Validate Business Rules

**Rule**: "Employee must have active assignment"

**OQL Check**:
```oql
FIND Employee[status="ACTIVE"]
WHERE NOT EXISTS (Employee -> Assignment[status="ACTIVE"])
```

### 3. Explore Relationships

**Question**: "What entities does Employee relate to?"

**OQL**:
```oql
DESCRIBE RELATIONSHIPS FOR Employee
```

**Result**:
```yaml
relationships:
  - department: N:1 -> Department
  - manager: N:1 -> Employee
  - assignments: 1:N -> Assignment
  - direct_reports: 1:N -> Employee
```

---

## 📋 Query Templates

### Template Library

Define reusable query templates:

```yaml
# queries/templates.oql.yaml

templates:
  active_employees_in_department:
    description: "Find all active employees in a specific department"
    parameters:
      - name: department_name
        type: string
        required: true
    query: |
      FIND Employee[status="ACTIVE"] 
      -> Department[name=:department_name]
      {id, full_name, hire_date, position.title}
      ORDER BY hire_date DESC
      
  employee_tenure_report:
    description: "Report on employee tenure by department"
    parameters:
      - name: min_years
        type: integer
        default: 0
    query: |
      AGGREGATE Employee[
        status="ACTIVE" 
        AND years_of_service >= :min_years
      ]
      GROUP BY department.name
      COMPUTE 
        COUNT(*) AS count,
        AVG(years_of_service) AS avg_tenure,
        MIN(hire_date) AS oldest_hire,
        MAX(hire_date) AS newest_hire
      ORDER BY avg_tenure DESC
```

### Using Templates

```oql
# Use predefined template
EXECUTE TEMPLATE active_employees_in_department(
  department_name="Engineering"
)

# With custom limit
EXECUTE TEMPLATE employee_tenure_report(min_years=5)
LIMIT 10
```

---

## 📚 Related Documents

- [02-ENTITY-SCHEMA.md](./02-ENTITY-SCHEMA.md) — Entity definitions
- [03-WORKFLOW-SCHEMA.md](./03-WORKFLOW-SCHEMA.md) — Workflow definitions
- [07-AI-AGENT-GUIDE.md](./07-AI-AGENT-GUIDE.md) — AI agent usage guide
