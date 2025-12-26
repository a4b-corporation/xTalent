# Format Guidelines

**Version**: 1.0  
**Audience**: Everyone  
**Purpose**: Clarify when to use YAML vs Markdown

---

## 🎯 The Dual Format Strategy

xTalent Ontology Standards use **both YAML and Markdown** for different purposes:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DUAL FORMAT STRATEGY                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   YAML (Machine-First)              Markdown (Human-First)                  │
│   ════════════════════              ══════════════════════                  │
│                                                                              │
│   ┌─────────────────┐               ┌─────────────────┐                     │
│   │ Entity.yaml     │               │ Guide.md        │                     │
│   │ Workflow.yaml   │               │ Overview.md     │                     │
│   │ Glossary.yaml   │               │ README.md       │                     │
│   │ BR.yaml         │               │ Templates.md    │                     │
│   └─────────────────┘               └─────────────────┘                     │
│                                                                              │
│   Purpose:                          Purpose:                                 │
│   • AI processing                   • Human reading                         │
│   • Schema validation               • GitHub rendering                      │
│   • Code generation                 • Navigation                            │
│   • Search/filter                   • Diagrams (Mermaid)                    │
│   • Single source of truth          • Explanations                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Format Decision Matrix

| Content Type | Format | Reason | Location |
|--------------|--------|--------|----------|
| Entity definitions | **YAML** | Schema validation, code gen | `00-ontology/domain/` |
| Workflow definitions | **YAML** | State machine parsing | `00-ontology/workflows/` |
| Action definitions | **YAML** | API generation | `00-ontology/actions/` |
| Glossary | **YAML** | Term search, AI lookup | `00-ontology/glossary/` |
| Business rules | **YAML** | Rule engine parsing | `02-spec/04-BR/` |
| Concept guides | **Markdown** | Human understanding | `01-concept/` |
| Module overviews | **Markdown** | Navigation, context | `README.md` files |
| Process guides | **Markdown** | Step-by-step with diagrams | `01-concept/` |
| Standards docs | **Markdown** | Documentation | This folder |

---

## 📝 YAML: When & Why

### Use YAML For

1. **Structured data that needs parsing**
   ```yaml
   entity: Employee
   attributes:
     name:
       type: string
       required: true
   ```

2. **Content AI agents will process**
   - Entity definitions for code generation
   - Glossary terms for semantic search
   - Business rules for validation

3. **Data with schema validation needs**
   - Enforceable structure
   - Type checking
   - Required field validation

4. **Cross-referencing using `$ref`**
   ```yaml
   relationships:
     department:
       target_ref: "xtalent:core-hr:org-structure:department"
   ```

### YAML Best Practices

```yaml
# Good: Clear structure, consistent formatting
entity: Employee
classification: AGGREGATE_ROOT

attributes:
  id:
    type: uuid
    required: true
    primary_key: true
    description: "Unique identifier"
    
  name:
    type: string
    required: true
    max_length: 200
    description: "Employee full name"

# Bad: Inconsistent, missing structure
entity: Employee
id: uuid
name: string  # Where's the metadata?
```

---

## 📄 Markdown: When & Why

### Use Markdown For

1. **Human-readable explanations**
   ```markdown
   ## What is an Employee?
   
   An Employee represents a person who works for the organization...
   ```

2. **Navigation and overviews**
   - README files
   - Index pages
   - Quick start guides

3. **Diagrams and visuals**
   ```markdown
   ```mermaid
   stateDiagram-v2
       [*] --> DRAFT
       DRAFT --> ACTIVE
   ```

4. **Step-by-step processes**
   - Workflow guides
   - How-to documentation
   - Onboarding materials

### Markdown Best Practices

```markdown
# Good: Clear structure, scannable

## Overview
Brief explanation of the topic.

## Key Concepts
| Term | Definition |
|------|------------|
| X    | What X is  |

## Step-by-Step
1. First step
2. Second step

## Related
- [Link 1](./path/to/doc.md)
- [Link 2](./path/to/other.md)
```

---

## 🔄 YAML ↔ Markdown Generation

### Auto-Generate Markdown from YAML

For GitHub readability, you can generate Markdown views from YAML:

```
Source (YAML)                    Generated (Markdown)
═════════════                    ═══════════════════

employee.entity.yaml      →      employee.entity.md
  ↓ AI/Script                      ↓
  Parses YAML                      Renders as readable doc
  Extracts key info                Adds navigation
  Formats for humans               Links to related
```

### Generation Template

```markdown
# {{ entity.name }}

**Classification**: {{ entity.classification }}  
**Module**: {{ entity.module }}

## Definition
{{ entity.definition }}

## Attributes
| Name | Type | Required | Description |
|------|------|----------|-------------|
{% for attr in entity.attributes %}
| {{ attr.name }} | {{ attr.type }} | {{ attr.required }} | {{ attr.description }} |
{% endfor %}

## Relationships
{% for rel in entity.relationships %}
- **{{ rel.name }}** → {{ rel.target }} ({{ rel.cardinality }})
{% endfor %}
```

---

## 📁 Layer-Specific Guidelines

### Layer 0: Ontology → YAML

All ontology layer files should be YAML:
- `*.aggregate.yaml`, `*.entity.yaml`, `*.ref.yaml` — Entity definitions (by classification)
- `.workflow.yaml` — Workflow definitions
- `.action.yaml` — Action definitions
- `.glossary.yaml` — Glossary terms

### Layer 1: Concept → Markdown

All concept layer files should be Markdown:
- `-guide.md` — Concept guides
- `overview.md` — Overviews
- `README.md` — Navigation

### Layer 2: Specification → Mixed

| Content | Format |
|---------|--------|
| Functional requirements | Markdown |
| Business rules | YAML |
| BDD scenarios | Gherkin (`.feature`) |
| API specs | YAML (OpenAPI) |
| Data specs | YAML |

---

## 🤖 AI Agent Considerations

### Why YAML for AI Processing

1. **Structured parsing** — AI can reliably extract fields
2. **Schema adherence** — Validates against known structure
3. **Cross-file references** — `$id` and `$ref` enable linking
4. **Consistent format** — Reduces parsing errors

### AI Reading Priority

```
1. Load glossary/*.glossary.yaml     → Understand terms
2. Load domain/*.entity.yaml         → Understand structure
3. Load workflows/*.workflow.yaml    → Understand processes
4. Read 01-concept/*.md              → Understand context
```

---

## 📚 Summary

| Question | Answer |
|----------|--------|
| Entity definition format? | **YAML** (parseable, validatable) |
| Glossary format? | **YAML** (searchable by AI) |
| Concept guide format? | **Markdown** (readable by humans) |
| README format? | **Markdown** (GitHub renders it) |
| Business rules format? | **YAML** (processable) |
| When in doubt? | **YAML** for data, **Markdown** for explanation |

---

## 📚 Related Documents

- [ENTITY-SCHEMA.md](../03-schemas/ENTITY-SCHEMA.md) — YAML entity schema
- [CONCEPT-LAYER-TEMPLATES.md](../04-templates/CONCEPT-LAYER-TEMPLATES.md) — Markdown templates
- [QUICK-START.md](./QUICK-START.md) — Getting started guide
