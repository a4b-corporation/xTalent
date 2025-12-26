# Who Should Read What

**Version**: 1.0  
**Last Updated**: 2025-12-25  
**Purpose**: Role-based navigation guide for ontology standards documentation

---

## 🎯 Purpose

Not everyone needs to read everything. This guide helps you find **exactly what you need** based on your role.

> **⚠️ Critical Understanding**: *Ontology is mandatory reading for understanding business meaning, not for execution. Workflow schemas handle execution.*

---

## 📋 Role × Document Matrix

### Quick Reference Table

| Document | BA/PO | Developer | Architect | QA | AI Agent |
|----------|:-----:|:---------:|:---------:|:--:|:--------:|
| **00-getting-started/** | | | | | |
| QUICK-START.md | ✅ | ✅ | ✅ | ✅ | ✅ |
| WHAT-IS-NOT-ONTOLOGY.md | ✅✅ | ✅ | ✅✅ | ✅ | ✅✅ |
| ERD-FIRST-WORKFLOW.md | ✅✅ | ✅ | ✅ | ⚪ | ✅✅ |
| FORMAT-GUIDELINES.md | ✅ | ✅ | ✅ | ⚪ | ✅ |
| WHO-SHOULD-READ-WHAT.md | ✅ | ✅ | ✅ | ✅ | ⚪ |
| **01-core-principles/** | | | | | |
| FOUR-MODEL-COMPARISON.md | ✅✅ | ✅✅ | ✅✅ | ✅ | ✅✅ |
| **02-architecture/** | | | | | |
| ARCHITECTURE.md | ⚪ | ✅ | ✅✅ | ⚪ | ✅ |
| DIRECTORY-STRUCTURE.md | ✅ | ✅✅ | ✅✅ | ⚪ | ✅✅ |
| **03-schemas/** | | | | | |
| ENTITY-SCHEMA.md | ✅ | ✅✅ | ✅✅ | ⚪ | ✅✅ |
| WORKFLOW-SCHEMA.md | ✅ | ✅✅ | ✅ | ⚪ | ✅✅ |
| GLOSSARY-SCHEMA.md | ✅✅ | ⚪ | ✅ | ⚪ | ✅ |
| BUSINESS-RULES.md | ✅✅ | ✅ | ✅ | ✅✅ | ✅ |
| QUERY-LANGUAGE.md | ⚪ | ✅✅ | ✅ | ⚪ | ✅ |
| **04-templates/** | | | | | |
| CONCEPT-LAYER-TEMPLATES.md | ✅✅ | ⚪ | ✅ | ⚪ | ✅ |
| SPEC-LAYER-TEMPLATES.md | ✅ | ✅ | ✅ | ✅✅ | ✅ |
| **05-guides/** | | | | | |
| AI-AGENT-GUIDE.md | ⚪ | ✅ | ✅ | ⚪ | ✅✅ |
| BDD-INTEGRATION.md | ⚪ | ✅ | ⚪ | ✅✅ | ✅ |
| TRACEABILITY.md | ✅ | ✅ | ✅✅ | ✅✅ | ✅ |

**Legend**:
- ✅✅ = Must read (Critical for your role)
- ✅ = Should read (Helpful for your role)
- ⚪ = Optional (Reference when needed)

---

## 👤 Reading Paths by Role

### 🔵 Business Analyst / Product Owner

**Your goal**: Define business requirements correctly, avoid modeling mistakes

**Reading order**:
```
1. QUICK-START.md           → Get oriented
2. WHAT-IS-NOT-ONTOLOGY.md  → ⭐ Avoid 99% of mistakes
3. FOUR-MODEL-COMPARISON.md → ⭐ Understand the framework
4. ERD-FIRST-WORKFLOW.md    → Learn the practical workflow
5. GLOSSARY-SCHEMA.md       → Define terms correctly
6. BUSINESS-RULES.md        → Document rules properly
7. CONCEPT-LAYER-TEMPLATES.md → Templates for your docs
```

**Key documents for you**:
| Document | Why You Need It |
|----------|-----------------|
| WHAT-IS-NOT-ONTOLOGY.md | Prevents you from putting workflows into entities |
| FOUR-MODEL-COMPARISON.md | Helps you categorize requirements correctly |
| ERD-FIRST-WORKFLOW.md | Shows how to work with existing database designs |
| GLOSSARY-SCHEMA.md | Ensures consistent terminology |
| BUSINESS-RULES.md | Proper format for business rules |

---

### 🟢 Developer

**Your goal**: Implement correctly, follow standards, generate code

**Reading order**:
```
1. QUICK-START.md           → Get oriented
2. FOUR-MODEL-COMPARISON.md → ⭐ Know what you're building
3. ENTITY-SCHEMA.md         → ⭐ Understand entity structure
4. WORKFLOW-SCHEMA.md       → ⭐ Understand workflow structure
5. DIRECTORY-STRUCTURE.md   → Know where files go
6. QUERY-LANGUAGE.md        → How to query ontology
7. TRACEABILITY.md          → Link code to requirements
```

**Key documents for you**:
| Document | Why You Need It |
|----------|-----------------|
| ENTITY-SCHEMA.md | Complete reference for entity YAML |
| WORKFLOW-SCHEMA.md | How to define workflows |
| QUERY-LANGUAGE.md | Query patterns for ontology |
| DIRECTORY-STRUCTURE.md | Where to put your files |

---

### 🟣 Architect

**Your goal**: Ensure consistency, govern standards, review designs

**Reading order**:
```
1. ARCHITECTURE.md          → ⭐ Understand the framework design
2. WHAT-IS-NOT-ONTOLOGY.md  → ⭐ Enforce correct boundaries
3. FOUR-MODEL-COMPARISON.md → ⭐ Review designs against this
4. ENTITY-SCHEMA.md         → Know the entity format
5. DIRECTORY-STRUCTURE.md   → ⭐ Enforce file organization
6. TRACEABILITY.md          → ⭐ Ensure cross-layer links
```

**Key documents for you**:
| Document | Why You Need It |
|----------|-----------------|
| ARCHITECTURE.md | Deep understanding of framework |
| WHAT-IS-NOT-ONTOLOGY.md | Enforce boundaries in reviews |
| FOUR-MODEL-COMPARISON.md | Reference for design decisions |
| TRACEABILITY.md | Ensure traceability in reviews |

---

### 🟡 QA Engineer

**Your goal**: Write tests, validate requirements, ensure coverage

**Reading order**:
```
1. QUICK-START.md           → Get oriented
2. BDD-INTEGRATION.md       → ⭐ How to write BDD scenarios
3. BUSINESS-RULES.md        → ⭐ Understand rule format
4. TRACEABILITY.md          → ⭐ Link tests to requirements
5. SPEC-LAYER-TEMPLATES.md  → Templates for test specs
6. FOUR-MODEL-COMPARISON.md → Know what you're testing
```

**Key documents for you**:
| Document | Why You Need It |
|----------|-----------------|
| BDD-INTEGRATION.md | How to create Gherkin scenarios |
| BUSINESS-RULES.md | Understand what rules to test |
| TRACEABILITY.md | Link tests to requirements |

---

### 🤖 AI Agent

**Your goal**: Parse ontology, generate code, maintain consistency

**Reading order**:
```
1. AI-AGENT-GUIDE.md        → ⭐ Start here
2. WHAT-IS-NOT-ONTOLOGY.md  → ⭐ Understand boundaries
3. FOUR-MODEL-COMPARISON.md → ⭐ Know the 4 types
4. ENTITY-SCHEMA.md         → ⭐ Parse entity YAML
5. WORKFLOW-SCHEMA.md       → ⭐ Parse workflow YAML
6. DIRECTORY-STRUCTURE.md   → ⭐ Know file locations
7. ERD-FIRST-WORKFLOW.md    → Understand the conversion process
```

**Key documents for you**:
| Document | Why You Need It |
|----------|-----------------|
| AI-AGENT-GUIDE.md | Specific instructions for AI agents |
| ENTITY-SCHEMA.md | Complete schema for parsing |
| WORKFLOW-SCHEMA.md | Complete workflow schema |
| WHAT-IS-NOT-ONTOLOGY.md | Avoid classification errors |
| DIRECTORY-STRUCTURE.md | Know where to find/create files |

---

## 🎯 Use Case Quick Links

### "I need to..."

| Use Case | Go To |
|----------|-------|
| Understand what ontology IS | [QUICK-START.md](./QUICK-START.md) |
| Understand what ontology is NOT | [WHAT-IS-NOT-ONTOLOGY.md](./WHAT-IS-NOT-ONTOLOGY.md) |
| Compare 4 model types | [FOUR-MODEL-COMPARISON.md](../01-core-principles/FOUR-MODEL-COMPARISON.md) |
| Create entity from ERD | [ERD-FIRST-WORKFLOW.md](./ERD-FIRST-WORKFLOW.md) |
| Write an entity YAML | [ENTITY-SCHEMA.md](../03-schemas/ENTITY-SCHEMA.md) |
| Write a workflow YAML | [WORKFLOW-SCHEMA.md](../03-schemas/WORKFLOW-SCHEMA.md) |
| Write BDD scenarios | [BDD-INTEGRATION.md](../05-guides/BDD-INTEGRATION.md) |
| Define business rules | [BUSINESS-RULES.md](../03-schemas/BUSINESS-RULES.md) |
| Know where files go | [DIRECTORY-STRUCTURE.md](../02-architecture/DIRECTORY-STRUCTURE.md) |
| Trace requirements to code | [TRACEABILITY.md](../05-guides/TRACEABILITY.md) |
| Use AI to generate | [AI-AGENT-GUIDE.md](../05-guides/AI-AGENT-GUIDE.md) |

---

## 📊 Document Complexity Levels

| Level | Documents | Time to Read |
|-------|-----------|--------------|
| 🟢 Beginner | QUICK-START.md, WHO-SHOULD-READ-WHAT.md | 5-10 min each |
| 🟡 Intermediate | WHAT-IS-NOT-ONTOLOGY.md, FOUR-MODEL-COMPARISON.md, FORMAT-GUIDELINES.md | 10-15 min each |
| 🔴 Advanced | ENTITY-SCHEMA.md, WORKFLOW-SCHEMA.md, ARCHITECTURE.md | 20-30 min each |
| ⚫ Reference | QUERY-LANGUAGE.md, TRACEABILITY.md | As needed |

---

## 🔄 Document Dependencies

```
                    ┌─────────────────────┐
                    │    QUICK-START      │
                    │   (Entry Point)     │
                    └──────────┬──────────┘
                               │
           ┌───────────────────┼───────────────────┐
           │                   │                   │
           ▼                   ▼                   ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ WHAT-IS-NOT-    │  │ FOUR-MODEL-     │  │ ARCHITECTURE    │
│ ONTOLOGY        │  │ COMPARISON      │  │                 │
└────────┬────────┘  └────────┬────────┘  └────────┬────────┘
         │                    │                    │
         │      ┌─────────────┴─────────────┐      │
         │      │                           │      │
         ▼      ▼                           ▼      ▼
┌─────────────────┐                   ┌─────────────────┐
│  ENTITY-SCHEMA  │                   │   WORKFLOW-     │
│                 │                   │   SCHEMA        │
└────────┬────────┘                   └────────┬────────┘
         │                                     │
         └──────────────┬──────────────────────┘
                        │
                        ▼
              ┌─────────────────┐
              │  BDD / TESTING  │
              │  TRACEABILITY   │
              └─────────────────┘
```

---

## 💡 Tips

1. **Start with QUICK-START.md** — Everyone should read this first
2. **Focus on your role** — You don't need to read everything
3. **Use this document as index** — Come back when you need something specific
4. **WHAT-IS-NOT-ONTOLOGY + FOUR-MODEL-COMPARISON** — These two are essential for everyone
5. **Bookmark frequently used documents** — ENTITY-SCHEMA for devs, BUSINESS-RULES for BAs

---

## 🔗 Related Documents

- [QUICK-START.md](./QUICK-START.md) — 5-minute onboarding
- [README.md](../README.md) — Complete documentation index
