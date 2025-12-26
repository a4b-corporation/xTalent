# xTalent Ontology Standards

**Version**: 4.1  
**Last Updated**: 2025-12-26  
**Status**: Official Standard  
**Inspired By**: Palantir Ontology, Domain-Driven Design, LinkML, JSON-LD

---

## 🎯 Purpose

This standards suite defines a **comprehensive ontology-driven development framework** that enables:

1. **AI Agent Collaboration** — Machine-readable schemas optimized for LLM context windows
2. **Human Understanding** — Clear documentation for developers, BAs, QA teams
3. **Seamless SDLC Integration** — From requirements to deployment with full traceability
4. **Semantic Interoperability** — Query patterns and linked data support
5. **ERD-First Workflow** — Reverse engineering from DBML to full domain entities

---

## 📁 Directory Structure

```
ontology-standards/
├── README.md                    # This file - Overview & Navigation
│
├── _ai-context/                 # 🤖 AI AGENT QUICK REFERENCE
│   ├── ENTITY-FORMAT.md         # Entity file format & rules
│   └── LAYER-TEMPLATES.md       # Templates for all doc types
│
├── 00-getting-started/          # ONBOARDING
│   ├── QUICK-START.md           # 5-minute onboarding
│   ├── WHAT-IS-NOT-ONTOLOGY.md  # ⭐ What is NOT ontology (critical)
│   ├── WHO-SHOULD-READ-WHAT.md  # Role-based navigation guide
│   ├── ERD-FIRST-WORKFLOW.md    # DBML → Entity reverse engineering
│   └── FORMAT-GUIDELINES.md     # YAML vs Markdown guidance
│
├── 01-core-principles/          # CORE CONCEPTS ⭐
│   ├── FOUR-MODEL-COMPARISON.md # Ontology vs Concept vs Workflow vs Transaction
│   └── ONTOLOGY-GUARDRAILS.md   # ⭐ What ontology MUST/MUST NOT contain

├── 02-architecture/             # FRAMEWORK
│   ├── ARCHITECTURE.md          # 4-layer architecture & Palantir mapping
│   └── DIRECTORY-STRUCTURE.md   # File organization standards
│
├── 03-schemas/                  # YAML SCHEMAS
│   ├── ENTITY-SCHEMA.md         # Entity definition schema
│   ├── WORKFLOW-SCHEMA.md       # Workflow & Action schemas
│   ├── GLOSSARY-SCHEMA.md       # Glossary term schema
│   ├── BUSINESS-RULES.md        # Business rules schema
│   └── QUERY-LANGUAGE.md        # OQL specification
│
├── 04-templates/                # DOCUMENT TEMPLATES
│   ├── CONCEPT-LAYER-TEMPLATES.md
│   └── SPEC-LAYER-TEMPLATES.md
│
├── 05-guides/                   # PROCESS GUIDES
│   ├── AI-AGENT-GUIDE.md        # Instructions for AI agents
│   ├── BDD-INTEGRATION.md       # Gherkin/BDD generation
│   └── TRACEABILITY.md          # Cross-layer traceability
│
├── 06-role-based-guides/        # ROLE-SPECIFIC GUIDES ⭐ NEW
│   ├── for-ba-po/
│   │   ├── HOW-TO-DEFINE-ONTOLOGY.md
│   │   └── COMMON-MISTAKES.md
│   ├── for-dev/
│   │   ├── WHAT-YOU-NEED-TO-FOLLOW.md
│   │   └── HOW-ONTOLOGY-BECOMES-API.md
│   └── for-architect/
│       ├── ONTOLOGY-GOVERNANCE.md
│       └── CROSS-MODULE-CONSISTENCY.md
│
├── examples/                    # REFERENCE EXAMPLES
│   └── employee.aggregate.yaml  # Complete AGGREGATE_ROOT example
│
└── 99-governance/               # GOVERNANCE ⭐ NEW
    ├── CHANGE-PROCESS.md        # Change management process
    ├── REVIEW-CHECKLIST.md      # Review criteria
    └── ARCHITECT-APPROVAL.md    # Approval requirements
```

---

## 🛤️ Two Starting Paths

### Path A: Domain-First (Traditional)

```
Glossary → Entity YAML → Concept Guide → BRs → BDD → Code
```

**Best for**: New projects, greenfield development

### Path B: ERD-First (Reverse Engineering)

```
DBML/ERD → AI Enrichment → Entity YAML → Generate Downstream
```

**Best for**: Existing systems, POs who think in data structures

👉 **See**: [ERD-FIRST-WORKFLOW.md](./00-getting-started/ERD-FIRST-WORKFLOW.md)

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     ONTOLOGY LAYER (Foundation)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   Entities   │  │  Workflows   │  │   Actions    │           │
│  │  (*.entity)  │  │ (*.workflow) │  │  (*.action)  │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│                           │                                      │
│  ┌────────────────────────┴────────────────────────┐            │
│  │              Glossary (*.glossary)               │            │
│  └──────────────────────────────────────────────────┘            │
├─────────────────────────────────────────────────────────────────┤
│                      CONCEPT LAYER (Understanding)               │
│  ┌──────────────────────────────────────────────────┐           │
│  │    Business Context Guides (*.concept.md)        │           │
│  └──────────────────────────────────────────────────┘           │
├─────────────────────────────────────────────────────────────────┤
│                   SPECIFICATION LAYER (Requirements)             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │  Functional  │  │   Business   │  │     BDD      │           │
│  │ Requirements │  │    Rules     │  │  Scenarios   │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
├─────────────────────────────────────────────────────────────────┤
│                      DESIGN LAYER (Technical)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   Database   │  │     API      │  │   Diagrams   │           │
│  │    (*.dbml)  │  │  (openapi)   │  │  (*.mermaid) │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
├─────────────────────────────────────────────────────────────────┤
│                   IMPLEMENTATION LAYER (Code)                    │
│  ┌──────────────────────────────────────────────────┐           │
│  │     Generated Code, Tests, Deployments           │           │
│  └──────────────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔑 Palantir Components Mapping

| Palantir Ontology | xTalent Equivalent | Description |
|-------------------|-------------------|-------------|
| Object Types | `*.aggregate.yaml`, `*.entity.yaml`, `*.ref.yaml` | Entity definitions with attributes, constraints |
| Link Types | `relationships` section | Entity relationships with cardinality |
| Actions | `*.action.yaml` | Atomic operations with preconditions/effects |
| Functions | `derived_attributes` | Computed properties and business logic |
| Interfaces | `mixins` | Shared property sets across entities |

### DBML → Palantir Mapping (for ERD-First)

| DBML Element | Palantir Concept | Entity YAML Section |
|--------------|------------------|---------------------|
| `Table` | Object Type | `entity:` |
| `Column` | Property | `attributes:` |
| `[ref: >]` | Link Type | `relationships:` |
| Status column | Lifecycle | `lifecycle:` |
| CHECK constraint | Validation | `validation_rules:` |

---

## 📖 Reading Order

👉 **Full role-based guide**: [WHO-SHOULD-READ-WHAT.md](./00-getting-started/WHO-SHOULD-READ-WHAT.md)

### Essential Reading for Everyone ⭐
1. [QUICK-START.md](./00-getting-started/QUICK-START.md)
2. [WHAT-IS-NOT-ONTOLOGY.md](./00-getting-started/WHAT-IS-NOT-ONTOLOGY.md) ← **CRITICAL**
3. [FOUR-MODEL-COMPARISON.md](./01-core-principles/FOUR-MODEL-COMPARISON.md) ← **BACKBONE**

### For PO/BA
1. [WHAT-IS-NOT-ONTOLOGY.md](./00-getting-started/WHAT-IS-NOT-ONTOLOGY.md)
2. [FOUR-MODEL-COMPARISON.md](./01-core-principles/FOUR-MODEL-COMPARISON.md)
3. [ERD-FIRST-WORKFLOW.md](./00-getting-started/ERD-FIRST-WORKFLOW.md)
4. [GLOSSARY-SCHEMA.md](./03-schemas/GLOSSARY-SCHEMA.md)

### For Developers
1. [FOUR-MODEL-COMPARISON.md](./01-core-principles/FOUR-MODEL-COMPARISON.md)
2. [ENTITY-SCHEMA.md](./03-schemas/ENTITY-SCHEMA.md)
3. [WORKFLOW-SCHEMA.md](./03-schemas/WORKFLOW-SCHEMA.md)
4. [DIRECTORY-STRUCTURE.md](./02-architecture/DIRECTORY-STRUCTURE.md)

### For AI Agents
1. [AI-AGENT-GUIDE.md](./05-guides/AI-AGENT-GUIDE.md) ← **START HERE**
2. [WHAT-IS-NOT-ONTOLOGY.md](./00-getting-started/WHAT-IS-NOT-ONTOLOGY.md)
3. [ENTITY-SCHEMA.md](./03-schemas/ENTITY-SCHEMA.md)
4. [WORKFLOW-SCHEMA.md](./03-schemas/WORKFLOW-SCHEMA.md)

### For Architects
1. [ARCHITECTURE.md](./02-architecture/ARCHITECTURE.md)
2. [WHAT-IS-NOT-ONTOLOGY.md](./00-getting-started/WHAT-IS-NOT-ONTOLOGY.md)
3. [FOUR-MODEL-COMPARISON.md](./01-core-principles/FOUR-MODEL-COMPARISON.md)
4. [TRACEABILITY.md](./05-guides/TRACEABILITY.md)

### For QA Teams
1. [BDD-INTEGRATION.md](./05-guides/BDD-INTEGRATION.md)
2. [BUSINESS-RULES.md](./03-schemas/BUSINESS-RULES.md)
3. [TRACEABILITY.md](./05-guides/TRACEABILITY.md)

---

## 🤖 AI Agent Optimization

This framework is specifically designed for AI agent consumption:

### Context Window Optimization
- **One Entity = One File** (150-250 lines target)
- **YAML-first** format for easy parsing
- **Explicit cross-references** using URIs

### ERD-First AI Enrichment
```
DBML Input → AI adds: definition, purpose, lifecycle, validation → Complete Entity YAML
```

### Machine-Readable Metadata
```yaml
$schema: "https://xtalent.io/schemas/entity/v3"
$id: "xtalent:core-hr:employee"
ai_instructions:
  priority: HIGH
  code_generation: true
```

---

## 🔗 References

### Foundational Standards
- [Palantir Ontology Documentation](https://www.palantir.com/docs/foundry/ontology/overview)
- [Domain-Driven Design (Eric Evans)](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [LinkML - Linked Data Modeling Language](https://linkml.io/)

### Testing & BDD
- [Cucumber/Gherkin](https://cucumber.io/docs/gherkin/)
- [BDD Best Practices](https://cucumber.io/docs/bdd/)

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.1 | 2025-12-26 | Added `_ai-context/` folder with minimal AI-optimized reference docs |
| 4.0 | 2025-12-26 | **Major refactor**: Markdown + YAML Frontmatter format (`*.onto.md`), 5 core sections (attributes, relationships, lifecycle, actions, policies), Data vs Context separation |
| 3.4 | 2025-12-25 | Enterprise refinements: ONTOLOGY-GUARDRAILS.md, warnings in WORKFLOW-SCHEMA, semantic terms in BUSINESS-RULES |
| 3.3 | 2025-12-25 | Added 06-role-based-guides and 99-governance |
| 3.2 | 2025-12-25 | Added enterprise-grade docs: WHAT-IS-NOT-ONTOLOGY, FOUR-MODEL-COMPARISON, WHO-SHOULD-READ-WHAT, new 01-core-principles folder |
| 3.1 | 2025-12-24 | Reorganized folder structure, added ERD-first workflow, format guidelines |
| 3.0 | 2024-12-24 | Complete rewrite with AI-first approach, OQL, BDD integration |
| 2.4 | 2024-12-23 | Modular file structure |
| 2.0 | 2024-12-01 | Initial layered architecture |
