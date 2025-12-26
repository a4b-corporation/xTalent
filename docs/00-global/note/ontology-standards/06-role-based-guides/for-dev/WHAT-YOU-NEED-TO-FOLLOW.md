# Developer Guide: What You Need to Follow

**Version**: 1.0  
**Last Updated**: 2025-12-25  
**Audience**: Developers  
**Time to Read**: 10 minutes

---

## 🎯 Your Role

As a developer, you **implement** the ontology defined by BA/PO. Your responsibilities:

1. **Translate** business definitions into technical schemas
2. **Enforce** constraints and validations
3. **Generate** code from ontology definitions
4. **Maintain** consistency between models and implementation

---

## 📋 Essential Standards to Follow

### 1. File Naming Convention

```
[entity-name].[type].yaml

Types:
- .aggregate.yaml  → AGGREGATE_ROOT
- .entity.yaml     → ENTITY
- .vo.yaml         → VALUE_OBJECT  
- .ref.yaml        → REF_DATA
- .workflow.yaml   → Workflow
- .action.yaml     → Action
- .glossary.yaml   → Glossary terms
```

**Examples**:
```
employee.aggregate.yaml
assignment.entity.yaml
address.vo.yaml
country-code.ref.yaml
hire-employee.workflow.yaml
```

---

### 2. Entity YAML Structure

Every entity must have:

```yaml
# Required header
$schema: "https://xtalent.io/schemas/entity/v3"
$id: "xtalent:module:domain:entity-name"

# Required metadata
entity: EntityName
classification: AGGREGATE_ROOT  # or ENTITY, VALUE_OBJECT, REF_DATA
definition: "Clear business definition"
purpose: "Why this exists"

# Required sections (content varies)
attributes:
  # At least one attribute

relationships:
  # If any relationships exist

lifecycle:
  # For AGGREGATE_ROOT with states

# Optional but recommended
ai_instructions:
  priority: HIGH | MEDIUM | LOW
  code_generation: true | false
```

---

### 3. Attribute Definition Rules

```yaml
attributes:
  # Good example
  employee_code:
    type: string
    required: true
    unique: true
    pattern: "^EMP[0-9]{6}$"
    description: "Human-readable employee identifier"
    example: "EMP000123"
    
  # Type must be one of:
  # string, integer, decimal, boolean, date, datetime, uuid, enum, array, object
  
  status:
    type: enum
    required: true
    values:
      - DRAFT
      - ACTIVE
      - INACTIVE
    default: DRAFT
```

**Required for every attribute**:
- `type`
- `required` (explicit true/false)

**Required for business-critical attributes**:
- `description`
- `example`

---

### 4. Relationship Definition Rules

```yaml
relationships:
  # N:1 relationship (many employees to one department)
  department:
    target: Department
    cardinality: N:1
    required: true
    description: "The department this employee belongs to"
    
  # 1:N relationship (one employee, many assignments)
  assignments:
    target: Assignment
    cardinality: 1:N
    inverse: employee  # The attribute name on the other side
    cascade: DELETE    # What happens when parent is deleted
```

**Cardinality options**: `1:1`, `1:N`, `N:1`, `N:M`

---

### 5. Lifecycle Definition Rules

```yaml
lifecycle:
  states:
    - DRAFT
    - ACTIVE
    - SUSPENDED
    - TERMINATED
    
  initial: DRAFT
  
  terminal:
    - TERMINATED
    
  transitions:
    - from: DRAFT
      to: ACTIVE
      action: activate
      requires_role: HR_ADMIN
      conditions:
        - "all required fields are filled"
        
    - from: ACTIVE
      to: SUSPENDED
      action: suspend
      requires_role: HR_MANAGER
```

---

### 6. Cross-Reference Format

When referencing other entities or documents:

```yaml
# Reference to another entity
relationships:
  position:
    $ref: "xtalent:core-hr:org-structure:position"
    
# Reference to documentation
traceability:
  glossary_refs:
    - "xtalent:core-hr:glossary:employee"
  concept_guide: "../../01-concept/02-workforce/employee-guide.md"
  business_rules: "../../02-spec/04-BR/BR-01-workforce.md"
```

---

## ⚠️ Do NOT Do

### 1. Don't Add Implementation Details
```yaml
# ❌ Wrong
attributes:
  id:
    type: uuid
    database_column: "emp_id"  # No! Implementation detail
    index_type: "btree"        # No! Database concern
```

### 2. Don't Mix Concerns
```yaml
# ❌ Wrong - mixing business with technical
attributes:
  name: string
  api_rate_limit: integer     # No! Technical concern
  cache_ttl_seconds: integer  # No! Technical concern
```

### 3. Don't Skip Required Fields
```yaml
# ❌ Wrong - missing required metadata
entity: Employee
attributes:
  name: string
# Missing: $schema, $id, classification, definition, purpose
```

### 4. Don't Invent Classifications
```yaml
# ❌ Wrong
classification: MASTER_DATA  # Not a valid classification!

# ✅ Correct - use standard classifications
classification: AGGREGATE_ROOT  # or ENTITY, VALUE_OBJECT, REF_DATA
```

### 5. Don't Create Orphan Entities
```yaml
# ❌ Wrong - entity with no relationships
entity: RandomThing
# ... no relationships section
# How does this connect to anything?
```

---

## ✅ Code Generation Checklist

Before generating code from ontology:

- [ ] Entity has valid `$id`
- [ ] All attributes have types
- [ ] Required fields are marked
- [ ] Relationships have valid targets
- [ ] Lifecycle states are complete
- [ ] No orphan states in lifecycle
- [ ] Validation rules are testable

---

## 🔄 Sync Points with BA/PO

| Phase | You Receive | You Provide |
|-------|------------|-------------|
| Definition | Business definition, rules | Questions on edge cases |
| Schema | Reviewed schema | Technical feasibility feedback |
| Implementation | Approved schema | Working code + tests |
| Testing | BDD scenarios | Test results, issues found |

---

## 🔗 Related Documents

- [ENTITY-SCHEMA.md](../../03-schemas/ENTITY-SCHEMA.md) — Complete schema reference
- [WORKFLOW-SCHEMA.md](../../03-schemas/WORKFLOW-SCHEMA.md) — Workflow definitions
- [DIRECTORY-STRUCTURE.md](../../02-architecture/DIRECTORY-STRUCTURE.md) — File organization
- [HOW-ONTOLOGY-BECOMES-API.md](./HOW-ONTOLOGY-BECOMES-API.md) — API generation guide
