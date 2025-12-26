# AI Agent Guide

**Version**: 3.0  
**Audience**: AI Agents (Claude, GPT, Gemini, Copilot)  
**Priority**: READ THIS FIRST

---

## 🤖 Your Role

You are an AI agent assisting with software development using the xTalent Ontology framework. Your tasks include:

1. **Understanding** domain models from ontology files
2. **Generating** code, tests, documentation
3. **Enriching** DBML/ERD to full domain entities
4. **Answering** questions about the domain
5. **Validating** compliance with business rules
6. **Suggesting** improvements to the ontology

---

## 📖 Reading Priority

When working with a module, read files in this order:

```
1. 00-ontology/glossary/*.glossary.yaml    ← Domain vocabulary
2. 00-ontology/domain/**/*.{aggregate,entity,ref}.yaml  ← Entity definitions (by classification)
3. 00-ontology/workflows/**/*.workflow.yaml ← Business processes
4. 00-ontology/actions/**/*.action.yaml    ← Atomic operations
5. 01-concept/**/*-guide.md                ← Business context
6. 02-spec/04-BR/**/*.br.yaml              ← Business rules
7. 02-spec/05-BDD/**/*.feature             ← Test scenarios
```

---

## 🔑 Key Concepts to Understand

### 1. Entity Classification

| Classification | Meaning | AI Action |
|---------------|---------|-----------|
| `AGGREGATE_ROOT` | Main entity, owns others | Generate full CRUD, lifecycle |
| `ENTITY` | Independent entity with ID | Generate standard CRUD |
| `VALUE_OBJECT` | Immutable, no ID | Generate as embedded type |
| `REFERENCE_DATA` | Lookup/config data | Generate as enum or seed data |
| `TRANSACTION_DATA` | Event records | Generate with timestamps, immutable |

### ⚠️ Critical: Tables vs Entities vs Domain Objects

**When processing DBML, NOT all tables become entities:**

| Skip These Tables | Pattern | Reason |
|-------------------|---------|--------|
| Junction tables | `employee_skill`, only FKs | Model as N:N relationship |
| History tables | `*_history`, `*_audit` | Model via `history:` section |
| Technical tables | `migrations`, `sequences` | Not part of domain |
| Views/Summaries | `v_*`, `*_summary` | Derived, not source of truth |

**Only AGGREGATE_ROOT is a true Domain Object:**
- Has its own lifecycle (status, transitions)
- Is the parent of other entities
- Can exist independently
- Examples: Employee, PayrollBatch, Order

**ENTITY vs AGGREGATE_ROOT:**
- ENTITY has meaningful PK but belongs to an aggregate
- ENTITY follows parent's lifecycle, not its own
- Examples: Assignment (belongs to Employee), OrderLine (belongs to Order)

### 2. Relationship Patterns

| Pattern | Generation Strategy |
|---------|---------------------|
| `1:1` | Embedded or separate table with FK |
| `1:N` | Child table with FK to parent |
| `N:1` | FK column on child |
| `N:N` | Junction table |

### 3. Lifecycle States

When an entity has `lifecycle` defined:
- Generate state machine implementation
- Generate transition validation
- Generate state-specific permissions

---

## 📝 File Parsing Instructions

### Parsing Entity Files

```yaml
# When you see this header:
$schema: "https://xtalent.io/schemas/entity/v3"
$id: "xtalent:core-hr:workforce:employee"

# Extract:
# - module: core-hr
# - submodule: workforce  
# - entity_name: employee
# - full_uri: xtalent:core-hr:workforce:employee
```

### Finding Related Entities

```yaml
# When you see relationship:
relationships:
  department:
    target: Department
    target_ref: "xtalent:core-hr:org-structure:department"
    cardinality: N:1

# The target file is at:
# 00-ontology/domain/*/department.entity.yaml
# Or search for $id containing "department"
```

### Understanding AI Instructions

```yaml
# When you see:
ai_instructions:
  priority: HIGH
  code_generation: true
  notes: |
    - Always validate status before operation
    - Consider timezone for dates

# This means:
# - This entity is important, understand it well
# - You should generate code for this entity
# - Pay attention to the specific notes
```

---

## 🛠️ Generation Tasks

### Task 1: Generate Database Schema

**Input**: `*.entity.yaml`  
**Output**: DBML or SQL DDL

**Rules**:
1. Map types according to type table in [02-ENTITY-SCHEMA.md](./02-ENTITY-SCHEMA.md)
2. Generate indexes from `indexes` section
3. Generate foreign keys from `relationships`
4. Add audit columns from `mixins` (Auditable, etc.)
5. Generate constraints from `validation_rules`

**Example Output**:
```dbml
Table employee {
  id uuid [pk]
  code varchar(50) [unique, not null]
  full_name varchar(200) [not null]
  status varchar(20) [not null, default: 'DRAFT']
  hire_date date [not null]
  department_id uuid [ref: > department.id]
  manager_id uuid [ref: > employee.id]
  created_at timestamp [default: `now()`]
  updated_at timestamp
  
  indexes {
    code [unique]
    (department_id, status)
    manager_id
  }
}
```

---

## 🔄 DBML → Entity Enrichment (Reverse Engineering)

When the user provides DBML and asks for entity generation, follow this process:

### Step 1: Analyze DBML Structure

```dbml
# Input from user
Table payroll_batch {
  id uuid [pk]
  calendar_id uuid [ref: > pay_calendar.id]
  period_start date [not null]
  period_end date [not null]
  status_code varchar(20) [note: 'INIT, CALC, REVIEW, CONFIRM, CLOSED']
  created_at timestamp [default: `now()`]
  created_by varchar(100) [not null]
}
```

### Step 2: Classify Entity

| Pattern Detected | Classification |
|------------------|----------------|
| Has PK + status column | `AGGREGATE_ROOT` |
| Has PK, is child (FK to parent) | `ENTITY` |
| No PK, embedded values | `VALUE_OBJECT` |
| Lookup/config table | `REFERENCE_DATA` |
| Time-stamped events | `TRANSACTION_DATA` |

### Step 3: Add Semantic Layer

AI must add these sections NOT present in DBML:

```yaml
# YOU ADD:
definition: |  # 2-3 sentences explaining business purpose
  A single execution run of payroll calculation for a specific 
  pay period. Contains all inputs, calculations, and outputs.

purpose: |  # Why this entity exists
  Orchestrates the entire payroll processing cycle from 
  initialization through calculation, review, and finalization.

ai_instructions:  # Guidance for future AI processing
  priority: HIGH
  notes: |
    - Central entity for payroll workflow
    - Status transitions must be validated
```

### Step 4: Expand Relationships

Convert DBML refs to full relationship definitions:

```yaml
# FROM: calendar_id uuid [ref: > pay_calendar.id]
# TO:
relationships:
  calendar:
    target: PayCalendar
    target_ref: "xtalent:payroll:config:pay-calendar"
    cardinality: N:1
    required: true
    foreign_key: calendar_id
    description: "Payroll calendar defining schedule and periods"
    on_delete: RESTRICT
```

### Step 5: Infer Lifecycle from Status

```yaml
# FROM: status_code [note: 'INIT, CALC, REVIEW, CONFIRM, CLOSED']
# TO:
lifecycle:
  state_attribute: status_code
  states:
    INIT:
      description: "Batch created, ready for calculation"
      initial: true
    CALC:
      description: "Calculation in progress"
    REVIEW:
      description: "Pending review and approval"
    CONFIRM:
      description: "Approved, ready for finalization"
    CLOSED:
      description: "Finalized and complete"
      terminal: true
  transitions:
    - name: start_calculation
      from: INIT
      to: CALC
    - name: complete_calculation
      from: CALC
      to: REVIEW
    # ... etc
```

### Step 6: Generate Validation Rules

```yaml
# Infer from constraints and business logic:
validation_rules:
  - rule: period_end_after_start
    expression: "period_end >= period_start"
    message: "Period end must be on or after period start"
    severity: ERROR
```

### Step 7: Add Derived Attributes

```yaml
# Identify computed values:
derived_attributes:
  is_finalized:
    type: boolean
    formula: "status_code = 'CLOSED'"
    description: "Whether batch is finalized"
```

### Step 8: Generate Examples

```yaml
# Create realistic examples:
examples:
  - name: "Regular Monthly Batch"
    description: "Standard monthly payroll"
    data:
      id: "batch-2025-01-uuid"
      calendar_id: "vn-calendar-uuid"
      period_start: "2025-01-01"
      period_end: "2025-01-31"
      status_code: "REVIEW"
```

### Complete Output Checklist

- [ ] `$schema` and `$id` present
- [ ] `classification` determined
- [ ] `definition` (2-3 sentences)
- [ ] `purpose` (business value)
- [ ] All columns → `attributes`
- [ ] All refs → `relationships` with full detail
- [ ] Status column → `lifecycle`
- [ ] Constraints → `validation_rules`
- [ ] Computed values → `derived_attributes`
- [ ] 2-3 `examples`
- [ ] `references` section

**Full Guide**: [ERD-FIRST-WORKFLOW.md](../00-getting-started/ERD-FIRST-WORKFLOW.md)

### Task 2: Generate API Endpoints

**Input**: `*.entity.yaml` + `*.action.yaml`  
**Output**: OpenAPI specification

**Rules**:
1. Standard CRUD for entities
2. Custom endpoints from `action.api` section
3. Include validation from `validation_rules`
4. Map errors from action `error_handling`

### Task 3: Generate BDD Scenarios

**Input**: `*.entity.yaml` + `*.action.yaml` + `*.br.yaml`  
**Output**: Cucumber `.feature` files

**Rules**:
1. Use `bdd_template` from action files
2. Cover all lifecycle transitions
3. Cover all business rules (BR)
4. Use `examples` section for test data

**Example Output**:
```gherkin
@entity(employee)
@trace(xtalent:core-hr:workforce:employee)
Feature: Employee Management

  @lifecycle
  Scenario: Create new employee
    Given I am an HR Specialist
    When I create an employee with:
      | field      | value           |
      | first_name | John            |
      | last_name  | Doe             |
      | hire_date  | 2024-01-15      |
    Then the employee should be created with status "DRAFT"
    And the employee code should match pattern "^EMP[0-9]{6}$"

  @rule(BR-001)
  @trace(xtalent:core-hr:workforce:BR-001)
  Scenario: Hire date cannot be in future
    Given I am creating a new employee
    When I set hire_date to tomorrow
    Then I should receive error "Hire date cannot be in the future"
    And the employee should not be created
```

### Task 4: Generate TypeScript/Python Types

**Input**: `*.entity.yaml`  
**Output**: Type definitions

**TypeScript Example**:
```typescript
// Generated from xtalent:core-hr:workforce:employee
export interface Employee {
  id: string;  // UUID
  code: string;
  fullName: string;
  status: EmployeeStatus;
  hireDate: Date;
  departmentId: string;
  managerId?: string;
  
  // Derived attributes
  readonly yearsOfService: number;
  readonly isEligibleForPromotion: boolean;
}

export enum EmployeeStatus {
  DRAFT = 'DRAFT',
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  TERMINATED = 'TERMINATED'
}

// Lifecycle transitions
export type EmployeeTransition = 
  | { action: 'activate'; from: 'DRAFT'; to: 'ACTIVE' }
  | { action: 'deactivate'; from: 'ACTIVE'; to: 'INACTIVE' }
  | { action: 'reactivate'; from: 'INACTIVE'; to: 'ACTIVE' }
  | { action: 'terminate'; from: 'ACTIVE' | 'INACTIVE'; to: 'TERMINATED' };
```

---

## 🔍 Query Execution

When asked questions about the domain, use OQL:

### Question → OQL Mapping

| Question Type | OQL Pattern |
|--------------|-------------|
| "What is X?" | Check `glossary/*.glossary.yaml` |
| "List all X" | `FIND Entity[...]` |
| "How many X" | `AGGREGATE Entity COMPUTE COUNT(*)` |
| "Who has X" | `FIND Entity -> RelatedEntity[condition]` |
| "Can X do Y" | `EXISTS Entity WHERE CAN_EXECUTE(Action)` |

### Example Q&A

**Q**: "How many active employees are in the Engineering department?"

**Process**:
1. Parse question: count, employees, active status, Engineering department
2. Generate OQL:
   ```oql
   AGGREGATE Employee[status="ACTIVE"] 
   -> Department[name="Engineering"]
   COMPUTE COUNT(*) AS count
   ```
3. If executing, translate to SQL
4. Return answer with context

---

## ✅ Validation Tasks

### Validate Entity Definition

Check for:
- Required fields: `$schema`, `$id`, `entity`, `attributes`
- Primary key exists
- All relationships have `target_ref`
- Validation rules use valid expressions
- Lifecycle transitions are valid
- Examples match schema

### Validate Business Rule Coverage

- Every `validation_rule` should have corresponding BR
- Every lifecycle transition should have BR
- Every `derived_attribute` formula should be documented

### Validate BDD Coverage

- Every action should have at least one scenario
- Every lifecycle transition should have scenario
- Every business rule should have scenario

---

## 🚫 What NOT to Do

1. **Don't invent attributes** not in the entity definition
2. **Don't assume relationships** not explicitly defined
3. **Don't skip validation rules** when generating code
4. **Don't ignore lifecycle** when implementing state changes
5. **Don't generate tests** without checking `examples` section
6. **Don't bypass security** constraints in generation

---

## 💬 Communication Patterns

### When You Need More Context

```
"I found the Employee entity but need more context about the hire process.
Should I read 01-concept/01-workforce/hiring-guide.md?"
```

### When Something Is Missing

```
"The Employee entity references Department, but I couldn't find 
department.entity.yaml. Is it in a different module or not yet created?"
```

### When You Find Inconsistencies

```
"I noticed BR-001 requires hire_date validation, but the Employee entity 
doesn't have this in validation_rules. Should I add it?"
```

### When Proposing Changes

```
"Based on the workflow requirements, I suggest adding a 'PENDING_APPROVAL' 
status to the Employee lifecycle. Here's the proposed change:

lifecycle:
  states:
    DRAFT: ...
    PENDING_APPROVAL:  # NEW
      description: "Awaiting HR approval"
    ACTIVE: ...
```

---

## 📊 Traceability

Always maintain traceability using `$id` URIs:

```typescript
/**
 * @entity xtalent:core-hr:workforce:employee
 * @generated-from 00-ontology/domain/01-workforce/employee.entity.yaml
 * @business-rules BR-001, BR-002, BR-003
 */
export class EmployeeService { ... }
```

```gherkin
# In generated tests
@trace(xtalent:core-hr:workforce:employee)
@trace(xtalent:core-hr:workforce:BR-001)
Scenario: Validate hire date
```

---

## 🔧 Context Loading Strategy

When working on a task, load context efficiently:

### For Entity-Focused Tasks

```
1. Load target entity.yaml (full)
2. Load related entities (attributes + relationships only)
3. Load relevant glossary entries
4. Load applicable business rules
```

### For Workflow Tasks

```
1. Load workflow.yaml (full)
2. Load all referenced action.yaml files
3. Load entities affected by workflow
4. Load concept guide for context
```

### For Test Generation

```
1. Load entity/action being tested
2. Load ALL business rules for that entity
3. Load examples section
4. Load any existing feature files for patterns
```

---

## 📚 Related Documents

- [ERD-FIRST-WORKFLOW.md](../00-getting-started/ERD-FIRST-WORKFLOW.md) — Reverse engineering guide
- [ENTITY-SCHEMA.md](../03-schemas/ENTITY-SCHEMA.md) — Entity schema reference
- [WORKFLOW-SCHEMA.md](../03-schemas/WORKFLOW-SCHEMA.md) — Workflow schema reference
- [QUERY-LANGUAGE.md](../03-schemas/QUERY-LANGUAGE.md) — OQL reference
- [BDD-INTEGRATION.md](./BDD-INTEGRATION.md) — Test generation guide
