# Framework Architecture

**Version**: 3.0  
**Audience**: Architects, Tech Leads, Senior Developers

---

## 🎯 Design Goals

1. **Palantir-like Power** — Semantic layer enabling complex queries and operations
2. **AI-Native** — Optimized for LLM consumption and generation
3. **Developer-Friendly** — YAML/JSON, not RDF/OWL
4. **Full SDLC Coverage** — Requirements → Design → Code → Tests
5. **Zero Vendor Lock-in** — Git-based, tool-agnostic

---

## 🏗️ Layer Architecture

### Layer 0: Ontology (Foundation)

**Purpose**: Define WHAT exists in the domain

**Contents**:
- Entity definitions (`*.entity.yaml`)
- Workflow definitions (`*.workflow.yaml`)
- Action definitions (`*.action.yaml`)
- Glossary (`*.glossary.yaml`)

**Characteristics**:
- Pure domain model, no implementation details
- Machine-readable YAML with JSON-LD compatible URIs
- One file per entity (150-250 lines)
- Serves as single source of truth

> ⚠️ **Critical**: Not all database tables become entities!
> - **Tables** = All database structures
> - **Entities** = Tables with business identity (meaningful PK)
> - **Domain Objects** = Core entities with business lifecycle (AGGREGATE_ROOT)
> 
> See [ERD-FIRST-WORKFLOW.md](../00-getting-started/ERD-FIRST-WORKFLOW.md) for classification details.

**Analogy**: The "noun vocabulary" of your domain

```
Palantir Equivalent:
├── Object Types     → *.aggregate.yaml, *.entity.yaml, *.ref.yaml
├── Link Types       → relationships section
├── Actions          → *.action.yaml
├── Functions        → derived_attributes section
└── Interfaces       → mixins
```

---

### Layer 1: Concept (Understanding)

**Purpose**: Explain HOW things work together

**Contents**:
- Business context guides (`*-guide.md`)
- Process explanations
- Entity interaction diagrams
- Domain expert knowledge

**Characteristics**:
- Human-readable Markdown
- Heavy use of Mermaid diagrams
- Explains "why" not just "what"
- Links back to Ontology via `$ref`

**Analogy**: The "grammar" connecting nouns into meaningful sentences

---

### Layer 2: Specification (Requirements)

**Purpose**: Define EXACT requirements for implementation

**Contents**:
- Functional requirements (`*.fr.yaml`)
- Business rules (`*.br.yaml`)
- BDD scenarios (`*.feature`)
- API specifications (`openapi.yaml`)
- Data specifications

**Characteristics**:
- Testable, measurable
- Full traceability to Ontology
- Gherkin scenarios auto-generated from Actions
- Error codes and messages

**Analogy**: The "contract" between business and development

---

### Layer 3: Design (Technical)

**Purpose**: Technical implementation design

**Contents**:
- Database schema (`*.dbml`)
- API endpoints
- Sequence diagrams
- Component diagrams

**Characteristics**:
- Generated from Ontology where possible
- Technology-specific
- Performance considerations

---

### Layer 4: Implementation (Code)

**Purpose**: Actual running code

**Contents**:
- Source code
- Unit tests
- Integration tests
- Deployment configurations

**Characteristics**:
- References back to Specification for traceability
- Tests linked to BDD scenarios

---

## 🔄 Information Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        AUTHORING FLOW                            │
│                                                                  │
│   Business        AI Agent         Developer        QA           │
│      │               │                 │            │            │
│      ▼               ▼                 ▼            ▼            │
│  ┌───────┐      ┌─────────┐      ┌─────────┐  ┌─────────┐       │
│  │Glossary│ ──► │ Entity  │ ──► │ Design  │  │  BDD    │       │
│  │  .yaml │     │  .yaml  │     │  .dbml  │  │.feature │       │
│  └───────┘      └─────────┘      └─────────┘  └─────────┘       │
│      │               │                 │            │            │
│      └───────────────┴─────────────────┴────────────┘            │
│                              │                                   │
│                              ▼                                   │
│                    ┌─────────────────┐                          │
│                    │  Traceability   │                          │
│                    │     Matrix      │                          │
│                    └─────────────────┘                          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       CONSUMPTION FLOW                           │
│                                                                  │
│                    ┌─────────────────┐                          │
│                    │  Entity.yaml    │                          │
│                    └────────┬────────┘                          │
│                             │                                    │
│         ┌───────────────────┼───────────────────┐               │
│         ▼                   ▼                   ▼               │
│   ┌───────────┐      ┌───────────┐      ┌───────────┐          │
│   │  Database │      │    API    │      │   Tests   │          │
│   │   Schema  │      │   Spec    │      │  (BDD)    │          │
│   └───────────┘      └───────────┘      └───────────┘          │
│         │                   │                   │               │
│         ▼                   ▼                   ▼               │
│   ┌───────────┐      ┌───────────┐      ┌───────────┐          │
│   │    DDL    │      │   Code    │      │  Cucumber │          │
│   │           │      │   Gen     │      │   Steps   │          │
│   └───────────┘      └───────────┘      └───────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎭 Role-Based Views

### Business Analyst View

```
Glossary → Concept Guides → Functional Requirements → Business Rules
   │              │                    │                    │
   │              │                    │                    │
   ▼              ▼                    ▼                    ▼
 Terms        Processes            Features              Logic
```

**Tools**: Markdown editors, Mermaid preview, Glossary lookup

### Developer View

```
Entity.yaml → Design → Implementation
     │           │            │
     │           │            │
     ▼           ▼            ▼
  Structure   Schema        Code
```

**Tools**: IDE with YAML support, database tools, code generators

### QA View

```
Entity + Actions → BDD Scenarios → Test Execution
        │                │               │
        │                │               │
        ▼                ▼               ▼
    Test Data       Gherkin          Results
```

**Tools**: Cucumber, test management, coverage tools

### AI Agent View

```
$schema → Parse → Understand → Generate
    │        │          │           │
    │        │          │           │
    ▼        ▼          ▼           ▼
 Validate  Index     Reason      Output
```

**Tools**: YAML parser, semantic search, code generation

---

## 🔗 Cross-Layer References

### URI System

Every artifact has a unique identifier:

```
xtalent:{module}:{submodule}:{entity}:{version}

Examples:
xtalent:core-hr:workforce:employee:v1
xtalent:core-hr:workforce:employee:hire-date:v1
xtalent:payroll:processing:pay-run:WF-001
xtalent:payroll:processing:calculate-gross:BR-001
```

### Reference Format

```yaml
# In entity file
relationships:
  department:
    $ref: "xtalent:core-hr:org-structure:department"
    cardinality: N:1

# In business rule
applies_to:
  entity: 
    $ref: "xtalent:core-hr:workforce:employee"
  attribute: status

# In BDD scenario
@trace(xtalent:core-hr:workforce:employee:BR-001)
Scenario: Employee status validation
```

---

## 🧩 Module Boundaries

### What Defines a Module?

A module is a **Bounded Context** in DDD terms:

1. **Cohesive domain concept** — All entities relate to same business area
2. **Independent glossary** — Terms may have different meanings in other modules
3. **Clear interfaces** — Well-defined integration points
4. **Team ownership** — One team can own entire module

### Module Dependencies

```yaml
# In module's README or manifest
module: PAYROLL
version: "2.0"
dependencies:
  - module: CORE-HR
    version: ">=1.5"
    entities:
      - Employee
      - Assignment
      - Position
  - module: TIME-ATTENDANCE
    version: ">=1.0"
    entities:
      - Timecard
```

### Anti-Corruption Layer

When importing from external modules:

```yaml
# Define mapping in integration layer
integrations:
  core-hr:
    source: "xtalent:core-hr:workforce:employee"
    local_alias: Worker
    mapping:
      employee_code: worker_id
      full_name: name
      hire_date: start_date
```

---

## 📊 Comparison: Palantir vs xTalent

| Aspect | Palantir Ontology | xTalent Ontology |
|--------|------------------|------------------|
| Storage | Proprietary platform | Git repository |
| Format | Platform-specific | YAML/JSON (open) |
| Query | Palantir query tools | OQL (custom) + Gremlin |
| SDK | Java/Python/TypeScript | Any language |
| AI Support | Limited | Native (AI-first design) |
| Licensing | Enterprise license | Open/internal |
| Learning Curve | High (platform) | Low (familiar formats) |
| Actions | Platform UI | Code generation |
| Functions | Palantir Functions | Derived attributes |

---

## 🔄 ERD/DBML Reverse Engineering

### DBML → Palantir Components Mapping

For teams starting from database design (ERD-first approach):

| DBML Element | Palantir Concept | Entity YAML Section |
|--------------|------------------|--------------------|
| `Table` | Object Type | `entity:` |
| `Column` | Property | `attributes:` |
| `[pk]` marker | Primary Key | `primary_key: true` |
| `[ref: >]` | Link Type (N:1) | `relationships:` |
| `[ref: <]` | Link Type (1:N) | `relationships:` (inverse) |
| `CHECK` constraint | Validation Rule | `validation_rules:` |
| Enum column | Property enum | `type: enum` with `values:` |
| Computed column | Function | `derived_attributes:` |
| Indexes | Performance hints | `indexes:` |

### Components AI Must Add (Not in DBML)

| Palantir Concept | YAML Section | AI Enrichment Role |
|------------------|--------------|--------------------|
| Business Definition | `definition:` | Infer from domain context |
| Purpose | `purpose:` | Derive business value |
| Classification | `classification:` | Detect from patterns |
| Lifecycle States | `lifecycle:` | From status columns |
| Actions | (workflow/action files) | From status transitions |
| Aliases | (glossary) | Industry standard terms |

### ERD-First Workflow

```
┌─────────┐    ┌─────────────┐    ┌─────────────┐    ┌──────────────┐
│  DBML   │ →  │ AI Enriches │ →  │   Domain    │ →  │   Generate   │
│  Input  │    │ + Semantic  │    │   Entity    │    │  Downstream  │
│         │    │   Layer     │    │   (.yaml)   │    │  Artifacts   │
└─────────┘    └─────────────┘    └─────────────┘    └──────────────┘
```

**Full Guide**: [ERD-FIRST-WORKFLOW.md](../00-getting-started/ERD-FIRST-WORKFLOW.md)

---

## 🎯 Design Decisions

### Why YAML over RDF/OWL?

1. **Developer familiarity** — Most developers know YAML
2. **AI readability** — LLMs parse YAML better than RDF
3. **Tooling** — Rich ecosystem of YAML tools
4. **Simplicity** — 80% of OWL power with 20% complexity

### Why One File Per Entity?

1. **Context window** — 150-250 lines fits in LLM context
2. **Git diffs** — Clear change tracking
3. **Parallel work** — No merge conflicts on same file
4. **Focused review** — Review one entity at a time

### Why Separate Actions from Workflows?

1. **Reusability** — Same action in multiple workflows
2. **Atomicity** — Actions are atomic, workflows compose
3. **Testing** — Actions testable independently
4. **Palantir parity** — Matches Palantir model

---

## 🔄 Evolution Strategy

### Path A: Domain-First (Traditional)

```
1. Define glossary term → 2. Create entity.yaml → 3. Create concept guide → 4. Define BRs → 5. Generate BDD
```

### Path B: ERD-First (Reverse Engineering)

```
1. Create DBML → 2. AI enriches to entity.yaml → 3. Extract glossary → 4. Generate concept guide
```

**When to use ERD-First**:
- Existing database designs available
- PO thinks in data structures
- Migration from legacy systems

**Full Guide**: [ERD-FIRST-WORKFLOW.md](../00-getting-started/ERD-FIRST-WORKFLOW.md)

### Adding New Attributes

```
1. Update entity.yaml → 2. Update BR if needed → 3. Update BDD → 4. Implement
```

### Deprecating Entity

```yaml
entity: OldEntity
deprecated: true
deprecated_since: "2024-01-01"
replaced_by:
  $ref: "xtalent:module:new-entity"
migration_guide: "./migrations/old-to-new.md"
```

---

## 📚 Further Reading

- [ERD-FIRST-WORKFLOW.md](../00-getting-started/ERD-FIRST-WORKFLOW.md) — DBML to Entity workflow
- [ENTITY-SCHEMA.md](../03-schemas/ENTITY-SCHEMA.md) — Entity definition format
- [WORKFLOW-SCHEMA.md](../03-schemas/WORKFLOW-SCHEMA.md) — Workflow & Action format
- [QUERY-LANGUAGE.md](../03-schemas/QUERY-LANGUAGE.md) — OQL specification
- [AI-AGENT-GUIDE.md](../05-guides/AI-AGENT-GUIDE.md) — AI agent instructions
- [FORMAT-GUIDELINES.md](../00-getting-started/FORMAT-GUIDELINES.md) — YAML vs Markdown
