# Directory Structure Specification

**Version**: 3.0  
**Audience**: Everyone

---

## 🎯 Purpose

Defines the standard directory layout for xTalent modules using ontology-driven development.

---

## 📁 Complete Directory Structure

```
[MODULE-CODE]/
│
├── README.md                           # Module overview
├── manifest.yaml                       # Module metadata & dependencies
│
├── 00-ontology/                        # LAYER 0: Ontology (WHAT exists)
│   ├── README.md                       # Ontology navigation hub
│   │
│   ├── domain/                         # Entity definitions
│   │   ├── 01-[submodule]/             # Submodule 1
│   │   │   ├── README.md               # Entity index
│   │   │   ├── [entity].aggregate.yaml # AGGREGATE_ROOT (one per file)
│   │   │   ├── [entity].entity.yaml    # ENTITY (one per file)
│   │   │   ├── [entity].ref.yaml       # REFERENCE_DATA (one per file)
│   │   │   ├── employee.aggregate.yaml # Example: AGGREGATE_ROOT
│   │   │   ├── assignment.entity.yaml  # Example: ENTITY
│   │   │   ├── currency.ref.yaml       # Example: REFERENCE_DATA
│   │   │   └── ...
│   │   │
│   │   ├── 02-[submodule]/             # Submodule 2
│   │   │   └── ...
│   │   │
│   │   └── 99-shared/                  # Cross-submodule entities
│   │       └── ...
│   │
│   ├── workflows/                      # Workflow definitions
│   │   ├── 01-[submodule]/
│   │   │   ├── README.md               # Workflow catalog
│   │   │   └── [workflow].workflow.yaml
│   │   └── ...
│   │
│   ├── actions/                        # Action definitions
│   │   ├── 01-[submodule]/
│   │   │   └── [action].action.yaml
│   │   └── ...
│   │
│   ├── glossary/                       # Domain vocabulary
│   │   ├── glossary-index.yaml         # Master index
│   │   └── [submodule].glossary.yaml   # Per-submodule glossary
│   │
│   ├── queries/                        # Reusable OQL queries
│   │   └── templates.oql.yaml
│   │
│   └── mixins/                         # Shared property sets
│       └── common-mixins.yaml
│
├── 01-concept/                         # LAYER 1: Concept (HOW it works)
│   ├── README.md                       # Concept index
│   ├── 01-overview.md                  # Module overview
│   │
│   ├── 02-[submodule]/
│   │   ├── overview.md                 # Submodule overview
│   │   ├── [workflow]-guide.md         # Workflow detail guides
│   │   └── ...
│   │
│   └── 99-shared/
│       └── [topic]-guide.md
│
├── 02-spec/                            # LAYER 2: Specification (EXACT requirements)
│   ├── README.md                       # Spec index
│   │
│   ├── 01-FR/                          # Functional Requirements
│   │   ├── README.md
│   │   └── FR-[NN]-[submodule].md
│   │
│   ├── 02-API/                         # API Specifications
│   │   ├── README.md
│   │   └── openapi.yaml
│   │
│   ├── 03-DATA/                        # Data Specifications
│   │   ├── README.md
│   │   └── data-validation.yaml
│   │
│   ├── 04-BR/                          # Business Rules
│   │   ├── README.md                   # BR index
│   │   └── BR-[NN]-[submodule].br.yaml
│   │
│   ├── 05-BDD/                         # BDD Scenarios (Gherkin)
│   │   ├── 01-[submodule]/
│   │   │   └── [entity].feature
│   │   └── ...
│   │
│   ├── 06-SECURITY/                    # Security Requirements
│   │   └── security-spec.md
│   │
│   └── FEATURE-LIST.yaml               # Feature breakdown
│
├── 03-design/                          # LAYER 3: Design (TECHNICAL)
│   ├── README.md
│   ├── [module].dbml                   # Database schema
│   ├── erd.mermaid                     # ER diagram
│   │
│   └── diagrams/
│       ├── architecture.mermaid
│       ├── sequence/
│       └── component/
│
├── 04-implementation/                  # LAYER 4: Implementation
│   ├── README.md
│   │
│   ├── backend/
│   │   ├── src/
│   │   └── tests/
│   │
│   ├── frontend/
│   │   ├── src/
│   │   └── tests/
│   │
│   └── migrations/
│       └── ...
│
└── 05-api/                             # API Documentation
    ├── README.md
    └── openapi/
        └── [module]-api.yaml
```

---

## 🏷️ Naming Conventions

### Directories

| Type | Pattern | Example |
|------|---------|---------|
| Submodule | `[NN]-[name]` | `01-workforce`, `02-org-structure` |
| Shared | `99-shared` | `99-shared` |

### Files

#### Entity Files (by Classification)

| Classification | Extension | Example | Description |
|---------------|-----------|---------|-------------|
| **AGGREGATE_ROOT** | `*.aggregate.yaml` | `worker.aggregate.yaml` | Core domain objects with independent lifecycle |
| **ENTITY** | `*.entity.yaml` | `contact.entity.yaml` | Child entities belonging to an aggregate |
| **REFERENCE_DATA** | `*.ref.yaml` | `currency.ref.yaml` | Lookup/configuration data |

> **Rationale**: File extension indicates classification for quick identification and easy filtering.

#### Other Ontology Files

| Type | Pattern | Example |
|------|---------|--------|
| Workflow | `[workflow-name].workflow.yaml` | `hire-employee.workflow.yaml` |
| Action | `[action-name].action.yaml` | `terminate-employee.action.yaml` |
| Glossary | `[submodule].glossary.yaml` | `workforce.glossary.yaml` |
| Business Rule | `BR-[NN]-[submodule].br.yaml` | `BR-01-workforce.br.yaml` |
| Feature | `[entity].feature` | `employee.feature` |
| Concept Guide | `[topic]-guide.md` | `onboarding-guide.md` |

### Naming Rules

1. **Use kebab-case** for file names: `employee-assignment.entity.yaml`
2. **Use singular nouns** for entities: `employee` not `employees`
3. **Use action verbs** for actions: `terminate-employee` not `employee-termination`
4. **Prefix with sequence** for ordering: `01-`, `02-`
5. **Match extension to classification**: AGGREGATE_ROOT → `.aggregate.yaml`, ENTITY → `.entity.yaml`, REFERENCE_DATA → `.ref.yaml`

---

## 📄 Required Files by Layer

### Layer 0: Ontology

| File | Required | Owner |
|------|----------|-------|
| `00-ontology/README.md` | ✅ | Architect |
| `domain/*/README.md` | ✅ | Architect |
| `domain/*/*.aggregate.yaml` | ✅ | Architect/BA |
| `domain/*/*.entity.yaml` | ✅ | Architect/BA |
| `domain/*/*.ref.yaml` | ✅ | Architect/BA |
| `workflows/*/README.md` | ✅ | BA |
| `glossary/*.glossary.yaml` | ✅ | BA/Domain Expert |

### Layer 1: Concept

| File | Required | Owner |
|------|----------|-------|
| `01-concept/README.md` | ✅ | BA |
| `01-concept/01-overview.md` | ✅ | BA |
| `[submodule]/overview.md` | ✅ | BA |
| `[submodule]/*-guide.md` | Per workflow | BA |

### Layer 2: Specification

| File | Required | Owner |
|------|----------|-------|
| `02-spec/README.md` | ✅ | BA |
| `01-FR/*.md` | ✅ | BA |
| `04-BR/*.br.yaml` | ✅ | BA |
| `05-BDD/*.feature` | ✅ | QA |

### Layer 3: Design

| File | Required | Owner |
|------|----------|-------|
| `03-design/README.md` | ✅ | Architect |
| `[module].dbml` | ✅ | Architect |

---

## 📦 Module Manifest

Every module should have a `manifest.yaml`:

```yaml
# manifest.yaml
$schema: "https://xtalent.io/schemas/manifest/v3"

module:
  code: CORE-HR
  name: "Core Human Resources"
  version: "2.0.0"
  description: "Core HR module for workforce management"
  
owner:
  team: "HR Platform Team"
  contact: "hr-platform@company.com"

# Dependencies on other modules
dependencies:
  - module: ORG-STRUCTURE
    version: ">=1.5.0"
    required: true
    
  - module: AUTH
    version: ">=2.0.0"
    required: true

# What this module provides to others
exports:
  entities:
    - employee
    - assignment
    - position
  actions:
    - get-employee
    - create-assignment
  events:
    - EmployeeCreated
    - EmployeeTerminated

# Submodules
submodules:
  - code: workforce
    name: "Workforce Management"
    entities: 5
    workflows: 3
    
  - code: org-structure
    name: "Organization Structure"
    entities: 4
    workflows: 2

# Statistics
statistics:
  total_entities: 15
  total_workflows: 8
  total_actions: 25
  total_business_rules: 45
  
# Status
status:
  phase: PRODUCTION
  last_updated: "2024-12-24"
```

---

## � Entity Registry (Index by Classification)

Every module should maintain an `entity-index.yaml` to catalog entities by classification:

**File**: `00-ontology/domain/entity-index.yaml`

```yaml
# entity-index.yaml
$schema: "https://xtalent.io/schemas/entity-index/v1"

module: CORE-HR
version: "2.0.0"
last_updated: "2025-12-25"

# ═══════════════════════════════════════════════════════════════════
# AGGREGATE_ROOT - Core Domain Objects (require full artifact set)
# ═══════════════════════════════════════════════════════════════════
aggregate_roots:
  - entity: Employee
    file: 01-workforce/employee.entity.yaml
    workflows:
      - hire-employee.workflow.yaml
      - terminate-employee.workflow.yaml
    actions:
      - activate-employee.action.yaml
      - deactivate-employee.action.yaml
    concept_guide: ../../01-concept/02-workforce/employee-guide.md
    bdd_feature: ../../02-spec/05-BDD/01-workforce/employee.feature
    
  - entity: Position
    file: 02-org-structure/position.entity.yaml
    workflows:
      - create-position.workflow.yaml
    actions:
      - fill-position.action.yaml
    concept_guide: ../../01-concept/03-org-structure/position-guide.md
    bdd_feature: ../../02-spec/05-BDD/02-org-structure/position.feature

# ═══════════════════════════════════════════════════════════════════
# ENTITY - Child entities (belong to aggregates)
# ═══════════════════════════════════════════════════════════════════
entities:
  - entity: Assignment
    file: 01-workforce/assignment.entity.yaml
    parent_aggregate: Employee
    
  - entity: EmployeeContact
    file: 01-workforce/employee-contact.entity.yaml
    parent_aggregate: Employee
    
  - entity: PositionHistory
    file: 02-org-structure/position-history.entity.yaml
    parent_aggregate: Position

# ═══════════════════════════════════════════════════════════════════
# REFERENCE_DATA - Lookup/configuration data
# ═══════════════════════════════════════════════════════════════════
reference_data:
  - entity: Country
    file: 99-shared/country.ref.yaml
    
  - entity: Currency
    file: 99-shared/currency.ref.yaml
    
  - entity: EmploymentType
    file: 01-workforce/employment-type.ref.yaml

# ═══════════════════════════════════════════════════════════════════
# VALUE_OBJECT - Embedded value types (optional entity files)
# ═══════════════════════════════════════════════════════════════════
value_objects:
  - name: Money
    embedded_in: [Compensation, PayElement]
    
  - name: DateRange
    embedded_in: [Assignment, Contract]

# ═══════════════════════════════════════════════════════════════════
# TRANSACTION_DATA - Immutable event records
# ═══════════════════════════════════════════════════════════════════
transaction_data:
  - entity: EmployeeAuditLog
    file: 01-workforce/employee-audit-log.entity.yaml
    
  - entity: StatusChangeEvent
    file: 99-shared/status-change-event.entity.yaml

# ═══════════════════════════════════════════════════════════════════
# SUMMARY STATISTICS
# ═══════════════════════════════════════════════════════════════════
statistics:
  aggregate_roots: 2      # Core domain objects
  entities: 3             # Child entities
  reference_data: 3       # Lookup tables
  value_objects: 2        # Embedded values
  transaction_data: 2     # Event records
  total: 12
```

### Benefits of Entity Registry

1. **Clear Classification**: See at a glance which entities are core domain vs supporting
2. **Artifact Tracking**: Know which artifacts exist for each AGGREGATE_ROOT
3. **Parent-Child Mapping**: Understand aggregate boundaries
4. **AI Navigation**: AI agents can load registry to understand module structure

---

## �🔀 File Size Guidelines

| File Type | Target Lines | Max Lines |
|-----------|-------------|-----------|
| Entity YAML | 150-250 | 350 |
| Workflow YAML | 200-300 | 500 |
| Action YAML | 100-200 | 300 |
| Glossary YAML | 200-400 | 600 |
| Concept Guide | 100-300 | 500 |
| Feature File | 100-300 | 500 |
| BR File | 300-500 | 700 |

If a file exceeds max lines, split it:
- Entities: Keep as is (they should be focused)
- Workflows: Split into sub-workflows
- BRs: Split by category: `BR-01.01-workforce-validation.br.yaml`

---

## 📚 Related Documents

- [01-ARCHITECTURE.md](./01-ARCHITECTURE.md) — Framework overview
- [02-ENTITY-SCHEMA.md](./02-ENTITY-SCHEMA.md) — Entity definitions
- [07-AI-AGENT-GUIDE.md](./07-AI-AGENT-GUIDE.md) — AI processing guide
