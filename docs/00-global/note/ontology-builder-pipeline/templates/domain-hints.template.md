# Domain Hints

> **Instructions**: This file helps AI understand domain-specific terminology and rules.
> Fill in relevant sections. Delete sections that don't apply.
> Delete all instruction text (in blockquotes) before running pipeline.

## Industry-Specific Terminology

> Define terms that have specific meaning in your context

| Term | Meaning in This Context | Common Confusion |
|------|-------------------------|------------------|
| [Term 1] | [Your definition] | [What it might be confused with] |
| [Term 2] | [Your definition] | [Common confusion] |
| [Term 3] | [Your definition] | |

### Acronyms

| Acronym | Full Form | Usage |
|---------|-----------|-------|
| [ACR1] | [Full form] | [When/how used] |
| [ACR2] | [Full form] | [When/how used] |

## Local Regulations

> Region-specific rules that must be followed

### [Country/Region] Requirements

**Labor/Employment**:
- [Regulation 1 with brief explanation]
- [Regulation 2]

**Tax/Financial**:
- [Regulation 1]
- [Regulation 2]

**Data Privacy**:
- [Regulation 1]
- [Regulation 2]

### Industry-Specific Regulations

- [Industry regulation 1]
- [Industry regulation 2]

## Company-Specific Rules

> Rules unique to your organization

### Policies

| Policy Area | Rule | Notes |
|-------------|------|-------|
| [Area 1] | [Rule] | [Notes] |
| [Area 2] | [Rule] | [Notes] |

### Organizational Structure

> Relevant org structure information

- [Hierarchy info, e.g., "Approval goes to direct manager, then skip-level for amounts > $1000"]
- [Department structure if relevant]
- [Special roles or positions]

### Existing Conventions

> Naming, coding, or process conventions already in use

- **ID Format**: [e.g., "EMP-XXXX for employees"]
- **Date Format**: [e.g., "DD/MM/YYYY"]
- **Status Values**: [e.g., "Always use ACTIVE/INACTIVE, not ENABLED/DISABLED"]

## Reference Systems

> Systems that AI should consider as reference patterns

### Primary Reference

**System**: [e.g., "Workday", "SAP SuccessFactors"]
**Why**: [Why this is a good reference]
**Key Patterns to Follow**:
- [Pattern 1]
- [Pattern 2]

### Secondary References

| System | What to Reference | What to Avoid |
|--------|-------------------|---------------|
| [System 1] | [Good patterns] | [Patterns to avoid] |
| [System 2] | [Good patterns] | [Patterns to avoid] |

### Key Differences from Reference

> Important ways your system differs from standard patterns

- [Difference 1 and why]
- [Difference 2 and why]

## Known Complexities

> Warn AI about areas that are more complex than they appear

### Complex Area 1: [Name]

**What seems simple**: [Surface description]
**What's actually complex**: [Hidden complexity]
**Key considerations**:
- [Consideration 1]
- [Consideration 2]

### Complex Area 2: [Name]

[Same structure]

## Data Quality Notes

> Information about existing data if migrating

### Data Sources

| Source | Quality | Notes |
|--------|---------|-------|
| [Source 1] | [Good/Medium/Poor] | [What to be aware of] |
| [Source 2] | [Quality] | [Notes] |

### Known Data Issues

- [Issue 1]
- [Issue 2]

## User Expectations

> What users expect based on current experience

### End Users

- [Expectation 1, e.g., "Mobile access required"]
- [Expectation 2, e.g., "Vietnamese language support"]

### Managers

- [Expectation 1]
- [Expectation 2]

### Administrators

- [Expectation 1]
- [Expectation 2]

## Integration Landscape

> Existing systems that must be considered

```
┌─────────────────────────────────────────────────────────────────┐
│                     System Landscape                             │
│                                                                 │
│  [System A] ◄──────► [THIS MODULE] ◄──────► [System B]          │
│       │                    │                     │              │
│       ▼                    ▼                     ▼              │
│  [System C]           [System D]            [System E]          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

| System | Integration Type | Data Flow | Priority |
|--------|------------------|-----------|----------|
| [System A] | [API/File/DB] | [Direction] | [Must/Should/Could] |
| [System B] | [Type] | [Direction] | [Priority] |

## Anti-Patterns to Avoid

> Things that should NOT be done

- ❌ [Anti-pattern 1 and why]
- ❌ [Anti-pattern 2 and why]
- ❌ [Anti-pattern 3 and why]

## Success Stories to Reference

> Good implementations from the past

### [Previous Project Name]

**What worked well**: [Description]
**Pattern to reuse**: [What can be applied here]

---

**Last Updated**: [Date]
**Contributed By**: [Names of SMEs who provided input]
