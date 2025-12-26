# Architect Approval Requirements

**Version**: 1.0  
**Last Updated**: 2025-12-25  
**Purpose**: Define when architect approval is required for ontology changes

---

## 🎯 Overview

Not all changes require architect approval. This document clarifies:
- When to **self-approve** (team level)
- When to **escalate to architect**
- When to **bring to ARB** (Architecture Review Board)

---

## 🟢 No Architect Approval Needed

Team leads can approve these changes:

### Documentation Only
- Typo fixes
- Clarifying comments
- Adding examples
- Updating diagrams

### Minor Entity Changes
- Adding **optional** attributes (with defaults)
- Adding new enum values (non-breaking)
- Updating `definition` or `purpose` text
- Adding aliases to glossary

### Within-Domain Changes
- New VALUE_OBJECT within existing AGGREGATE_ROOT
- New actions within existing workflow
- Additional validation rules (making stricter)

---

## 🟡 Architect Approval Required

Single architect must approve:

### New Entities
- [ ] Any new AGGREGATE_ROOT
- [ ] Any new ENTITY with external relationships
- [ ] First entity in a new subdomain

### Structural Changes
- [ ] Adding **required** attributes (breaking change)
- [ ] Changing attribute types
- [ ] Modifying cardinality of relationships
- [ ] Adding/removing lifecycle states

### Cross-Boundary Changes
- [ ] Relationships spanning subdomains
- [ ] Changes affecting shared entities (Person, Organization, etc.)
- [ ] Modifications to REF_DATA used by multiple modules

### Business Logic Changes
- [ ] New business rules affecting calculations
- [ ] Modified validation that could reject existing data
- [ ] Changes to derived attributes

---

## 🔴 ARB (Architecture Review Board) Required

Full ARB review for:

### Major Structural Changes
- [ ] New modules or domains
- [ ] Fundamental changes to core entities (Employee, Contract, Position)
- [ ] Changes to shared infrastructure entities
- [ ] New cross-module integration patterns

### Breaking Changes
- [ ] Removing entities
- [ ] Removing attributes
- [ ] Changing entity classification (e.g., ENTITY to AGGREGATE_ROOT)
- [ ] Renaming entities or attributes

### High-Risk Changes
- [ ] Changes affecting more than 3 teams
- [ ] Changes to audit or compliance-related entities
- [ ] Changes that require data migration
- [ ] Changes with unclear backward compatibility

### Strategic Decisions
- [ ] Introducing new patterns or conventions
- [ ] Deprecating existing patterns
- [ ] Tool or process changes affecting all teams

---

## 📋 Decision Matrix

| Change Type | Who Approves | Turnaround |
|-------------|--------------|------------|
| Documentation fix | Team peer | Same day |
| Optional attribute | Team lead | 1 day |
| New VALUE_OBJECT | Team lead | 1-2 days |
| Required attribute | Architect | 2-3 days |
| New AGGREGATE_ROOT | Architect | 3-5 days |
| Cross-module relationship | Architect | 3-5 days |
| Breaking change | ARB | 1-2 weeks |
| New module | ARB | 2-4 weeks |

---

## 🏛️ ARB Composition

### Permanent Members
- Lead Architect (Chair)
- Domain Architect (Core HR)
- Domain Architect (Payroll/TR)
- Domain Architect (TA)
- Platform Lead

### Ad-Hoc Members
- Affected module leads (when their domain is impacted)
- Security lead (for PII/compliance changes)
- DBA (for significant schema changes)

### Quorum
- Minimum 3 permanent members for standard reviews
- Minimum 4 permanent members + all affected parties for breaking changes

---

## 📝 Architect Review Request Template

When requesting architect approval, provide:

```markdown
## Change Request Summary

**Entity/Module**: [name]
**Change Type**: [New Entity | Structural Change | Cross-Boundary | etc.]
**Urgency**: [Normal | High | Critical]

## Description
[Brief description of the change]

## Justification
[Why is this change needed?]

## Impact Analysis
- Affected entities: [list]
- Affected teams: [list]
- Breaking changes: [Yes/No - if yes, describe]

## Proposed Timeline
- PR ready: [date]
- Desired merge: [date]

## Supporting Documents
- RFC: [link if applicable]
- Design doc: [link if applicable]
- Related PRs: [links]
```

---

## 🔄 Escalation Path

```
┌─────────────────────────────────────────────────────────────────┐
│                     ESCALATION PATH                              │
│                                                                  │
│   Contributor                                                    │
│        │                                                         │
│        ▼                                                         │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Team Lead Review                      │   │
│   │   Can approve: Documentation, optional attrs, VALUE_OBJ │   │
│   └─────────────────────────────────────────────────────────┘   │
│        │ Cannot approve                                          │
│        ▼                                                         │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                   Architect Review                       │   │
│   │   Can approve: Required attrs, new entities, cross-ref  │   │
│   └─────────────────────────────────────────────────────────┘   │
│        │ Cannot approve                                          │
│        ▼                                                         │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                        ARB                               │   │
│   │   Approves: Breaking changes, new modules, strategic    │   │
│   └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## ⚡ Fast-Track Approval

For time-sensitive changes that would normally need ARB:

1. **Emergency Fast-Track**
   - Get 2 architect approvals (instead of full ARB)
   - Document justification
   - Schedule ARB ratification within 1 week

2. **Pre-Approved Patterns**
   - Some patterns are pre-approved (see catalog)
   - Just reference the pattern ID in PR
   - Example: `#PAT-001: Standard Audit Fields`

---

## 📊 Approval SLAs

| Approver | First Response | Decision |
|----------|---------------|----------|
| Team Lead | 4 hours | 1 day |
| Architect | 1 day | 3 days |
| ARB | 2 days | 5-10 days |

**Escalation**: If SLA is missed, escalate to next level.

---

## 🔗 Related Documents

- [CHANGE-PROCESS.md](./CHANGE-PROCESS.md) — Full change process
- [REVIEW-CHECKLIST.md](./REVIEW-CHECKLIST.md) — Review criteria
- [FOUR-MODEL-COMPARISON.md](../01-core-principles/FOUR-MODEL-COMPARISON.md) — Classification guidance
