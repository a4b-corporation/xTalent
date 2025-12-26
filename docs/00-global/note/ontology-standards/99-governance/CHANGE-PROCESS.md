# Ontology Change Process

**Version**: 1.0  
**Last Updated**: 2025-12-25  
**Owner**: Architecture Team  
**Audience**: All contributors

---

## 🎯 Purpose

This document defines the **official process for making changes** to the ontology. Following this process ensures:

1. **Quality** — Changes are reviewed before merge
2. **Consistency** — All entities follow the same standards
3. **Traceability** — Changes are documented and auditable
4. **Coordination** — Cross-module impacts are identified

---

## 📋 Change Categories

### Category A: Minor Changes (Fast Track)

**What qualifies**:
- Typo fixes in documentation
- Adding clarifying comments
- Updating examples
- Non-breaking attribute additions (optional fields)

**Process**: Direct PR → Single reviewer → Merge

**SLA**: 1 business day

---

### Category B: Standard Changes

**What qualifies**:
- New entities within existing domain
- New attributes (required fields)
- New relationships
- Workflow modifications
- Business rule changes

**Process**: 
1. Create RFC (Request for Change)
2. Domain review
3. Architecture review
4. PR with tests
5. Merge

**SLA**: 3-5 business days

---

### Category C: Major Changes (Requires ARB)

**What qualifies**:
- New domains/submodules
- Cross-module changes
- Breaking changes to existing entities
- Changes affecting multiple teams
- Changes to core entities (Employee, Contract, etc.)

**Process**:
1. Create RFC with impact analysis
2. ARB (Architecture Review Board) review
3. All affected team sign-off
4. Migration plan (if breaking)
5. PR with comprehensive tests
6. Staged rollout

**SLA**: 1-2 weeks

---

## 📝 RFC Template

```markdown
# RFC: [Title]

## Summary
Brief description of the change.

## Motivation
Why is this change needed?

## Proposal
Detailed description of the change.

## Affected Entities
- Entity 1: [nature of change]
- Entity 2: [nature of change]

## Cross-Module Impact
- Module A: [impact]
- Module B: [impact]

## Breaking Changes
- [ ] None
- [ ] Yes: [describe and provide migration path]

## Alternatives Considered
1. Alternative A: [why rejected]
2. Alternative B: [why rejected]

## Testing Plan
How will this be validated?

## Rollback Plan
How to revert if issues arise?
```

---

## 🔄 Change Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                      CHANGE WORKFLOW                             │
│                                                                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐   │
│  │  Propose │───▶│  Review  │───▶│ Approve  │───▶│  Merge   │   │
│  │   RFC    │    │   RFC    │    │  by ARB  │    │   PR     │   │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘   │
│       │               │               │               │          │
│       │               │               │               │          │
│       ▼               ▼               ▼               ▼          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐   │
│  │ Category │    │ Domain   │    │ Category │    │ Deploy   │   │
│  │ Triage   │    │ Expert   │    │ C Only   │    │ & Test   │   │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 👥 Roles & Responsibilities

| Role | Responsibility |
|------|----------------|
| **Contributor** | Propose changes, create RFC, implement PR |
| **Domain Expert** | Review domain accuracy, validate business logic |
| **Architect** | Review consistency, cross-module impact |
| **ARB** | Approve major changes, resolve conflicts |
| **Platform Team** | Enforce standards, maintain tooling |

---

## ✅ Review Checklist

Before approving any ontology change:

### For All Changes
- [ ] Follows [ENTITY-SCHEMA.md](../03-schemas/ENTITY-SCHEMA.md) format
- [ ] Has proper `$id` URI
- [ ] Has `definition` and `purpose` filled
- [ ] Naming follows conventions
- [ ] No duplicate concepts

### For New Entities
- [ ] Classification is correct (AGGREGATE_ROOT, ENTITY, etc.)
- [ ] Relationships are bidirectional where needed
- [ ] Lifecycle states are defined (if applicable)
- [ ] Linked to glossary terms

### For Relationship Changes
- [ ] Cardinality is correct
- [ ] Inverse relationships defined
- [ ] No circular dependencies

### For Breaking Changes
- [ ] Migration guide exists
- [ ] Deprecation notice added
- [ ] Affected teams notified
- [ ] Rollback plan documented

---

## 🚨 Emergency Changes

For production-critical fixes:

1. Create PR with `[EMERGENCY]` prefix
2. Get one Architect approval
3. Merge with monitoring
4. Create follow-up RFC for proper review

**Note**: Emergency changes must be reviewed within 48 hours post-merge.

---

## 📊 Metrics

We track:
- Time from RFC to merge
- Number of rollbacks
- Cross-module conflicts
- Review turnaround time

---

## 🔗 Related Documents

- [REVIEW-CHECKLIST.md](./REVIEW-CHECKLIST.md) — Detailed review criteria
- [ARCHITECT-APPROVAL.md](./ARCHITECT-APPROVAL.md) — When architect approval is needed
- [ENTITY-SCHEMA.md](../03-schemas/ENTITY-SCHEMA.md) — Entity format reference
