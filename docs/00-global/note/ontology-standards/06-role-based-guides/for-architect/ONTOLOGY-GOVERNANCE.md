# Architect Guide: Ontology Governance

**Version**: 1.0  
**Last Updated**: 2025-12-25  
**Audience**: Solution Architects, Domain Architects, Technical Leads  
**Purpose**: Guide for governing ontology across the organization

---

## 🎯 Architect's Role in Ontology

As an architect, you are the **guardian of consistency and quality**. Your responsibilities:

1. **Define** standards and patterns
2. **Review** changes for cross-cutting concerns
3. **Govern** the evolution of the domain model
4. **Resolve** conflicts between modules and teams

---

## 🏛️ Governance Pillars

### 1. Consistency

Ensure all entities follow the same patterns:

| Aspect | Standard Reference |
|--------|-------------------|
| Naming | [ENTITY-SCHEMA.md](../../03-schemas/ENTITY-SCHEMA.md) |
| File structure | [DIRECTORY-STRUCTURE.md](../../02-architecture/DIRECTORY-STRUCTURE.md) |
| Classification | [WHAT-IS-NOT-ONTOLOGY.md](../../00-getting-started/WHAT-IS-NOT-ONTOLOGY.md) |
| Model types | [FOUR-MODEL-COMPARISON.md](../../01-core-principles/FOUR-MODEL-COMPARISON.md) |

### 2. Coherence

Ensure entities work together logically:
- No duplicate concepts across modules
- Relationships are bidirectional where needed
- Cross-module dependencies are explicit

### 3. Completeness

Ensure entities are fully specified:
- All required metadata present
- Lifecycle defined for stateful entities
- Business rules linked
- BDD scenarios exist

---

## 📋 Review Responsibilities

### What You Review

| Change Type | Review Focus |
|-------------|--------------|
| New AGGREGATE_ROOT | Business justification, naming, classification |
| Cross-module relationship | Dependency management, data flow |
| Lifecycle changes | State machine completeness, transition rules |
| Breaking changes | Migration path, affected systems |

### Review Questions to Ask

**For New Entities**:
1. "Is this truly an ontology entity or something else?"
   - → Use [WHAT-IS-NOT-ONTOLOGY.md](../../00-getting-started/WHAT-IS-NOT-ONTOLOGY.md) checklist
   
2. "Does a similar concept already exist?"
   - → Check existing modules for duplicates
   
3. "Who owns this entity?"
   - → Clear ownership prevents conflicts

**For Relationships**:
1. "Is this the right direction?"
   - → N:1 vs 1:N matters for data loading patterns
   
2. "What happens on cascade?"
   - → Delete, update behavior must be specified
   
3. "Does this create circular dependencies?"
   - → Draw the dependency graph

**For Lifecycle Changes**:
1. "Are all states reachable?"
   - → No orphan states
   
2. "Are there dead-ends?"
   - → Only terminal states should have no exit
   
3. "Who can trigger each transition?"
   - → RBAC should be defined

---

## 🗺️ Cross-Module Governance

### Module Boundaries

```
┌─────────────────────────────────────────────────────────────────┐
│                      CORE HR (Foundation)                        │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐             │
│  │ Person  │  │Employee │  │Position │  │ Org     │             │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘             │
│       ▲            ▲            ▲            ▲                   │
└───────┼────────────┼────────────┼────────────┼───────────────────┘
        │            │            │            │
   ┌────┴────┐  ┌────┴────┐  ┌────┴────┐  ┌────┴────┐
   │   TA    │  │ Payroll │  │   TR    │  │ Others  │
   │ Module  │  │ Module  │  │ Module  │  │         │
   └─────────┘  └─────────┘  └─────────┘  └─────────┘
   
   Legend:
   ← Reference (can read)
   ← No direct write to other module's aggregates
```

### Rules for Cross-Module References

1. **Reference by ID, not by embedding**
   ```yaml
   # ✅ Correct
   relationships:
     employee:
       $ref: "xtalent:core-hr:workforce:employee"
       
   # ❌ Wrong - don't duplicate
   attributes:
     employee_name: string  # Duplicates Core HR data
   ```

2. **Declare dependencies explicitly**
   ```yaml
   # In module manifest
   module: PAYROLL
   dependencies:
     - module: CORE-HR
       version: ">=2.0"
       entities:
         - Employee
         - Assignment
   ```

3. **Use events for cross-module updates**
   - Module A changes → publishes event
   - Module B subscribes → updates own data

---

## 🔄 Evolution Patterns

### Pattern 1: Backward Compatible Addition

**Safe**: Add optional attribute with default
```yaml
# Version 1
attributes:
  name: string

# Version 2 (backward compatible)
attributes:
  name: string
  nickname:
    type: string
    required: false
    default: null
```

### Pattern 2: Deprecation First

**Required**: Deprecate before removing
```yaml
# Phase 1: Add deprecation
attributes:
  old_field:
    type: string
    deprecated: true
    deprecated_since: "2025-01-01"
    replaced_by: new_field
  new_field:
    type: string

# Phase 2 (after migration period): Remove
attributes:
  new_field:
    type: string
```

### Pattern 3: Breaking Change with Migration

**Required**: Provide migration path
```yaml
# Document migration
migration:
  from_version: "2.x"
  to_version: "3.0"
  breaking_changes:
    - attribute: status
      old_type: string
      new_type: enum
      migration_script: "migrate_status_to_enum.sql"
```

---

## 🔍 Audit Points

### Weekly Review
- [ ] New entities added this week follow standards
- [ ] Cross-module relationships are documented
- [ ] No duplicate concepts introduced

### Monthly Review
- [ ] Module dependency graph is up to date
- [ ] Deprecated items are on track for removal
- [ ] Documentation is current

### Quarterly Review
- [ ] Standards are still relevant
- [ ] Pain points are addressed
- [ ] New patterns are documented

---

## 🚨 Escalation Triggers

Escalate to ARB when:

1. **Conflicting ownership claims**
   - Two teams want to own same concept
   
2. **Circular dependencies detected**
   - Module A → B → C → A
   
3. **Breaking change to core entity**
   - Changes to Employee, Contract, Position, etc.
   
4. **New module proposed**
   - Major addition to the domain
   
5. **Standard change requested**
   - Modification to ontology standards themselves

---

## 📊 Governance Metrics

Track and report:

| Metric | Target | Frequency |
|--------|--------|-----------|
| Standards compliance | >95% | Monthly |
| Cross-module conflicts | 0 | Weekly |
| Review turnaround | <3 days | Continuous |
| Breaking changes | Minimize | Quarterly |
| Orphan entities | 0 | Monthly |

---

## 🔗 Related Documents

- [CHANGE-PROCESS.md](../../99-governance/CHANGE-PROCESS.md) — Change management
- [REVIEW-CHECKLIST.md](../../99-governance/REVIEW-CHECKLIST.md) — Review criteria
- [ARCHITECT-APPROVAL.md](../../99-governance/ARCHITECT-APPROVAL.md) — Approval requirements
- [VERSIONING-STRATEGY.md](./VERSIONING-STRATEGY.md) — Version management
