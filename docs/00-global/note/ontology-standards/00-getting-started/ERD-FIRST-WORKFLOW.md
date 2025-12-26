# ERD/DBML-First Workflow

**Version**: 1.0  
**Audience**: Product Owners, Business Analysts, AI Agents  
**Prerequisites**: Familiarity with DBML syntax

---

## 🎯 Purpose

This guide documents the **reverse engineering workflow** for creating complete Domain Entities from existing ERD/DBML designs. This approach is ideal when:

- You already have database schema designs
- You're working from an existing system
- You think in data structures first

---

## 🔄 Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     ERD/DBML-FIRST WORKFLOW                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  STEP 1          STEP 2              STEP 3           STEP 4                │
│  ┌──────┐       ┌─────────┐        ┌─────────┐      ┌──────────┐           │
│  │ DBML │  →    │   AI    │   →    │ Domain  │  →   │ Generate │           │
│  │Input │       │Enriches │        │ Entity  │      │Downstream│           │
│  │      │       │+Semantic│        │ (.yaml) │      │Artifacts │           │
│  └──────┘       └─────────┘        └─────────┘      └──────────┘           │
│                                                                              │
│  PO Effort:      AI Effort:        Output:          Auto-generated:         │
│  - Table         - Definition      - Complete       - Glossary terms        │
│  - Columns       - Purpose         - Entity YAML    - Concept guide         │
│  - FKs           - Lifecycle       - Validated      - BDD scenarios         │
│  - Constraints   - Rules                            - API hints             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ⚠️ Critical Distinction: Table → Entity → Domain Object

> **Not all Tables become Entities. Not all Entities are Domain Objects.**

This is a fundamental concept when reverse engineering from ERD/DBML.

### The Three-Level Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DATABASE TABLES                                                             │
│  ══════════════                                                              │
│  Everything in your DBML file                                                │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  ENTITIES (Ontology)                                                   │  │
│  │  ════════════════════                                                  │  │
│  │  Tables with business identity (have meaningful PK)                    │  │
│  │                                                                        │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │  DOMAIN OBJECTS (Core)                                          │  │  │
│  │  │  ═══════════════════════                                        │  │  │
│  │  │  Entities that represent core business concepts                 │  │  │
│  │  │  → AGGREGATE_ROOT                                               │  │  │
│  │  │  → Key ENTITY with business lifecycle                          │  │  │
│  │  │                                                                 │  │  │
│  │  │  Examples: Employee, PayrollBatch, LeaveRequest                 │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                        │  │
│  │  Examples: Assignment, PayslipResult, TimeEntry                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  Examples: employee_skill (junction), audit_log, db_migration               │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Tables That Do NOT Become Entities

| Table Type | Pattern | What To Do Instead |
|------------|---------|-------------------|
| **Junction/Association Tables** | `employee_skill`, `position_competency` | Model as N:N relationship in parent entity |
| **History/Audit Tables** | `*_history`, `*_audit`, `*_log` | Model via `history:` section in parent entity |
| **Technical Tables** | `migrations`, `sequences`, `locks` | Do not model in ontology |
| **Denormalized Views** | `v_*`, `*_summary` | Do not model, these are derived |
| **Pure Linking Tables** | Only FKs, no business attributes | Model as relationship |

### Entity Classification Decision Tree

```
START: Analyze Table
         │
         ▼
    Has meaningful PK?
    (not just composite FK)
         │
    ┌────┴────┐
   NO        YES
    │         │
    ▼         ▼
 NOT AN    Is it a lookup/
 ENTITY    config table?
 (model as     │
 relationship) │
          ┌────┴────┐
         YES        NO
          │         │
          ▼         ▼
   REFERENCE_DATA  Has status/
                   lifecycle?
                      │
                 ┌────┴────┐
                YES        NO
                 │         │
                 ▼         ▼
           Is it parent   ENTITY
           of aggregation? (child)
                 │
            ┌────┴────┐
           YES        NO
            │         │
            ▼         ▼
     AGGREGATE_ROOT  Check if
     (Domain Object) time-stamped
                     event?
                        │
                   ┌────┴────┐
                  YES        NO
                   │         │
                   ▼         ▼
           TRANSACTION    ENTITY
              _DATA      (regular)
```

### Classification Summary

| Classification | Is Domain Object? | Create Entity File? | Has Own Lifecycle? | Examples |
|----------------|-------------------|--------------------|--------------------|----------|
| `AGGREGATE_ROOT` | ✅ **YES** | ✅ Yes | ✅ Yes | Employee, PayrollBatch, Order |
| `ENTITY` | 🔶 Partial | ✅ Yes | ❌ No (follows parent) | Assignment, OrderLine, Address |
| `VALUE_OBJECT` | ❌ No | 🔶 Optional | ❌ No | Money, DateRange, Coordinate |
| `REFERENCE_DATA` | ❌ No | ✅ Yes | ❌ No | Country, Currency, Status |
| `TRANSACTION_DATA` | ❌ No | ✅ Yes | ❌ No (immutable) | AuditLog, EventRecord |

### Artifact Requirements by Classification

**AGGREGATE_ROOT requires MORE artifacts than other classifications:**

| Artifact | AGGREGATE_ROOT | ENTITY | VALUE_OBJECT | REFERENCE_DATA |
|----------|:--------------:|:------:|:------------:|:--------------:|
| Entity file | ✅ `*.aggregate.yaml` | ✅ `*.entity.yaml` | 🔶 Optional | ✅ `*.ref.yaml` |
| `lifecycle:` section | ✅ **Required** | ❌ Skip | ❌ Skip | ❌ Skip |
| `*.workflow.yaml` | ✅ **Required** | ❌ Skip | ❌ Skip | ❌ Skip |
| `*.action.yaml` | ✅ **Required** | 🔶 Optional | ❌ Skip | ❌ Skip |
| Concept Guide (`*-guide.md`) | ✅ **Required** | 🔶 Optional | ❌ Skip | ❌ Skip |
| Glossary (main term) | ✅ **Required** | 🔶 As sub-entry | ❌ Skip | 🔶 Optional |
| BDD Scenarios | ✅ Full coverage | 🔶 Via parent | ❌ Skip | 🔶 Minimal |

**Directory structure example:**

```
Module/
├── 00-ontology/
│   ├── domain/
│   │   ├── employee.aggregate.yaml   # AGGREGATE_ROOT - Full
│   │   ├── assignment.entity.yaml    # ENTITY - Simpler
│   │   └── country.ref.yaml          # REFERENCE_DATA - Minimal
│   ├── workflows/
│   │   └── hire-employee.workflow.yaml  # Only for AGGREGATE_ROOT
│   ├── actions/
│   │   └── terminate-employee.action.yaml  # Only for AGGREGATE_ROOT
│   └── glossary/
│       └── workforce.glossary.yaml   # AGGREGATE_ROOT as main terms
├── 01-concept/
│   └── employee-guide.md             # Only for AGGREGATE_ROOT
└── 02-spec/05-BDD/
    └── employee.feature              # Focus on AGGREGATE_ROOT
```

### Examples of Non-Domain Tables

```dbml
// ❌ Junction Table - DO NOT create entity
Table employee_skill {
  employee_id uuid [ref: > employee.id, pk]
  skill_id uuid [ref: > skill.id, pk]
  proficiency_level int
}
// → Model as N:N relationship in Employee entity

// ❌ History Table - DO NOT create entity  
Table employee_history {
  id uuid [pk]
  employee_id uuid
  changed_at timestamp
  old_values jsonb
  new_values jsonb
}
// → Model via `history:` section in Employee entity

// ❌ Technical Table - DO NOT model
Table flyway_schema_history {
  installed_rank int [pk]
  version varchar
  script varchar
}
// → Ignore completely

// ✅ Domain Object - CREATE entity
Table employee {
  id uuid [pk]
  code varchar [unique]
  status varchar  // Has lifecycle
}
// → Create employee.entity.yaml with AGGREGATE_ROOT

// ✅ Child Entity - CREATE entity
Table assignment {
  id uuid [pk]
  employee_id uuid [ref: > employee.id]  // Belongs to aggregate
  position_id uuid [ref: > position.id]
  start_date date
}
// → Create assignment.entity.yaml with ENTITY classification
```

---

## Step 1: DBML Input (PO Provides)

### Minimum Required DBML

```dbml
// Minimal input from PO/BA
Table payroll_batch {
  id uuid [pk]
  calendar_id uuid [ref: > pay_calendar.id]
  period_start date [not null]
  period_end date [not null]
  batch_type varchar(20) [not null, note: 'REGULAR, SUPPLEMENTAL, RETRO']
  status_code varchar(20) [not null, note: 'INIT, CALC, REVIEW, CONFIRM, CLOSED']
  original_run_id uuid [ref: > payroll_batch.id]
  executed_at timestamp
  finalized_at timestamp
  created_at timestamp [default: `now()`]
  created_by varchar(100) [not null]
  
  indexes {
    calendar_id [name: 'idx_batch_calendar']
    status_code [name: 'idx_batch_status']
  }
}
```

### What PO Should Include

| Element | Required | Purpose |
|---------|----------|---------|
| Table name | ✅ | Entity name derivation |
| Columns with types | ✅ | Attribute definition |
| `[pk]` marker | ✅ | Primary key identification |
| `[ref: >]` foreign keys | ✅ | Relationship discovery |
| `[not null]` constraints | ✅ | Required field identification |
| `[note: '...']` comments | 🔶 Recommended | Enum values, business hints |
| Indexes | 🔶 Optional | Performance hints |

---

## Step 2: AI Enrichment Process

### 2.1 Classification Detection

AI analyzes DBML to determine entity classification:

| Pattern | Classification | Example |
|---------|---------------|---------|
| Has PK + status column + lifecycle | `AGGREGATE_ROOT` | PayrollBatch, Employee |
| Has PK + FKs, is child entity | `ENTITY` | Assignment, PayslipResult |
| No PK, only value columns | `VALUE_OBJECT` | Address, Money |
| Lookup/config table, rarely changes | `REFERENCE_DATA` | Country, Currency |
| Event/log table, time-stamped | `TRANSACTION_DATA` | AuditLog, EventLog |

### 2.2 Semantic Layer Addition

AI adds business meaning not present in DBML:

```yaml
# AI adds these sections based on domain knowledge:

entity: PayrollBatch
classification: AGGREGATE_ROOT  # Detected from status_code presence

definition: |
  A single execution run of payroll calculation for a specific 
  pay period. Contains all inputs, calculations, and outputs 
  for producing employee compensation.

purpose: |
  Orchestrates the entire payroll processing cycle from initialization
  through calculation, review, approval, and finalization. Serves as
  the parent container for all payroll results within a period.
```

### 2.3 Relationship Inference

AI converts DBML refs to full relationship definitions:

```dbml
# DBML Input
calendar_id uuid [ref: > pay_calendar.id]
original_run_id uuid [ref: > payroll_batch.id]
```

```yaml
# AI Output
relationships:
  calendar:
    target: PayCalendar
    target_ref: "xtalent:payroll:config:pay-calendar"
    cardinality: N:1
    required: true
    foreign_key: calendar_id
    description: "Payroll calendar defining schedule and periods"
    on_delete: RESTRICT
    
  original_run:
    target: PayrollBatch
    target_ref: "xtalent:payroll:processing:payroll-batch"
    cardinality: N:1
    required: false
    foreign_key: original_run_id
    description: "Original run for retro adjustments (self-reference)"
    on_delete: SET_NULL
```

### 2.4 Lifecycle State Machine

AI infers lifecycle from status columns:

```dbml
# DBML Input
status_code varchar(20) [note: 'INIT, CALC, REVIEW, CONFIRM, CLOSED']
```

```yaml
# AI Output
lifecycle:
  state_attribute: status_code
  
  states:
    INIT:
      description: "Batch created, employees selected, ready for calculation"
      initial: true
      
    CALC:
      description: "Calculation in progress"
      
    REVIEW:
      description: "Calculation complete, pending review and approval"
      
    CONFIRM:
      description: "Approved, ready for finalization"
      
    CLOSED:
      description: "Finalized, payslips generated, payments initiated"
      terminal: true
      
  transitions:
    - name: start_calculation
      from: INIT
      to: CALC
      action_ref: "xtalent:payroll:processing:start-calculation"
      requires:
        - "employees selected"
        - "time data available"
        
    - name: complete_calculation
      from: CALC
      to: REVIEW
      action_ref: "xtalent:payroll:processing:complete-calculation"
      
    - name: approve
      from: REVIEW
      to: CONFIRM
      action_ref: "xtalent:payroll:processing:approve-batch"
      requires:
        - "approver authorization"
        
    - name: finalize
      from: CONFIRM
      to: CLOSED
      action_ref: "xtalent:payroll:processing:finalize-batch"
```

### 2.5 Validation Rules Generation

AI generates rules from constraints and business logic:

```yaml
# AI Output
validation_rules:
  - rule: period_end_after_start
    expression: "period_end >= period_start"
    message: "Period end must be on or after period start"
    severity: ERROR
    error_code: "ERR_INVALID_PERIOD_RANGE"
    
  - rule: valid_batch_type
    expression: "batch_type IN ('REGULAR', 'SUPPLEMENTAL', 'RETRO')"
    message: "Batch type must be REGULAR, SUPPLEMENTAL, or RETRO"
    severity: ERROR
    error_code: "ERR_INVALID_BATCH_TYPE"
    
  - rule: retro_requires_original
    expression: "batch_type != 'RETRO' OR original_run_id IS NOT NULL"
    message: "Retro batch must reference the original run"
    severity: ERROR
    error_code: "ERR_RETRO_MISSING_ORIGINAL"
```

### 2.6 Derived Attributes Discovery

AI identifies computed properties:

```yaml
# AI Output
derived_attributes:
  employee_count:
    type: integer
    formula: "COUNT(payroll_employee WHERE batch_id = this.id)"
    description: "Number of employees processed in this batch"
    
  total_gross:
    type: decimal
    formula: "SUM(payroll_result.gross_amount WHERE batch_id = this.id)"
    description: "Total gross pay for all employees in batch"
    
  is_finalized:
    type: boolean
    formula: "status_code = 'CLOSED'"
    description: "Whether batch has been finalized"
```

---

## Step 3: Output Entity YAML

Complete entity following [ENTITY-SCHEMA](../03-schemas/ENTITY-SCHEMA.md):

```yaml
$schema: "https://xtalent.io/schemas/entity/v3"
$id: "xtalent:payroll:processing:payroll-batch"

module: PAYROLL
submodule: processing
version: "1.0"

entity: PayrollBatch
classification: AGGREGATE_ROOT

definition: |
  A single execution run of payroll calculation for a specific 
  pay period. Contains all inputs, calculations, and outputs 
  for producing employee compensation.

purpose: |
  Orchestrates the entire payroll processing cycle from initialization
  through calculation, review, approval, and finalization.

ai_instructions:
  priority: HIGH
  code_generation: true
  test_generation: true
  notes: |
    - Central entity for payroll processing workflow
    - Status transitions must be validated
    - Supports retro processing via self-reference

mixins:
  - Auditable

attributes:
  # ... (complete attribute list from DBML + AI enrichment)

relationships:
  # ... (complete relationship list)

lifecycle:
  # ... (complete state machine)

validation_rules:
  # ... (complete rules)

derived_attributes:
  # ... (computed properties)

examples:
  # ... (AI-generated examples)

references:
  glossary: "../glossary/processing.glossary.yaml#payroll-batch"
  concept_guide: "../../01-concept/02-processing/payroll-batch-guide.md"
```

---

## Step 4: Generate Downstream Artifacts

From the Entity YAML, AI can auto-generate:

### 4.1 Glossary Terms

```yaml
# Auto-extracted to glossary
payroll_batch:
  term: "Payroll Batch"
  type: ENTITY
  definition: "A single execution run of payroll calculation..."
  aliases: ["Payroll Run", "Pay Cycle"]
  entity_ref: "xtalent:payroll:processing:payroll-batch"
```

### 4.2 Concept Guide Outline

```markdown
# PayrollBatch - Business Guide

## What is a Payroll Batch?
[Generated from definition]

## Lifecycle Explained
[Generated from lifecycle section]

## How It Connects
[Generated from relationships]
```

### 4.3 BDD Scenario Templates

```gherkin
@entity(payroll-batch)
Feature: PayrollBatch Lifecycle

  Scenario: Create new payroll batch
    Given a valid pay calendar exists
    When I create a PayrollBatch with:
      | calendar_id  | {calendar_id} |
      | period_start | 2025-01-01    |
      | batch_type   | REGULAR       |
    Then the batch status should be "INIT"

  Scenario: Transition from INIT to CALC
    Given a PayrollBatch with status "INIT"
    And employees are selected for the batch
    When I start calculation
    Then the batch status should be "CALC"
```

---

## 🤖 AI Prompt Templates

### Prompt 1: Full Entity Generation

```
I have this DBML table definition. Please generate a complete 
entity YAML following xTalent Ontology Standards v3.

DBML:
[paste DBML here]

Requirements:
1. Determine classification (AGGREGATE_ROOT, ENTITY, etc.)
2. Add business definition and purpose
3. Convert all refs to full relationship definitions
4. Infer lifecycle from status column if present
5. Generate validation rules from constraints
6. Identify derived attributes
7. Create 2-3 examples
8. Follow ENTITY-SCHEMA.md format exactly
```

### Prompt 2: Batch Processing Multiple Tables

```
I have these related DBML tables. Please:
1. Generate entity YAML for each table
2. Ensure relationship consistency across entities
3. Identify the aggregate root
4. Map the domain boundary

Tables:
[paste multiple tables]
```

---

## ✅ Checklist: Complete Entity

Use this checklist to verify AI output:

- [ ] `$schema` and `$id` present
- [ ] `module` and `submodule` set correctly
- [ ] `classification` appropriate for entity type
- [ ] `definition` is 2-3 clear sentences
- [ ] `purpose` explains why entity exists
- [ ] All DBML columns mapped to `attributes`
- [ ] All FKs mapped to `relationships`
- [ ] Lifecycle present if status column exists
- [ ] `validation_rules` cover all constraints
- [ ] At least 2 `examples` included
- [ ] `references` section links to related docs

---

## 📚 Related Documents

- [ENTITY-SCHEMA.md](../03-schemas/ENTITY-SCHEMA.md) — Complete entity schema reference
- [AI-AGENT-GUIDE.md](../05-guides/AI-AGENT-GUIDE.md) — AI processing instructions
- [FORMAT-GUIDELINES.md](./FORMAT-GUIDELINES.md) — YAML vs Markdown guidance
