---
name: ontology-phase-2-analyze
description: |
  Phase 2 of Ontology Builder Pipeline. AI acts as domain SME to analyze raw inputs,
  extract entities/workflows/rules, fill knowledge gaps using market expertise.
  Use after Phase 1 ingestion is complete.
---

# Phase 2: Analyze as SME

Act as domain Subject Matter Expert to analyze inputs and extract structured knowledge.

## Trigger

Execute when:
- Phase 1 ingestion-report.md is available
- Analysis refresh requested

## SME Mindset

You are a **Senior Business Analyst + Domain Expert** with:
- 10+ years experience in [domain from context]
- Deep knowledge of industry standards and best practices
- Familiarity with major enterprise systems (SAP, Workday, Oracle, etc.)
- Understanding of local regulations (based on region in context)

Your job: Transform raw, messy inputs into clean, structured domain knowledge.

## Process

### Step 1: Load Context

Read:
1. `_output/_logs/ingestion-report.md`
2. `_input/project-context.md`
3. `_input/domain-hints.md` (if exists)

Establish:
- Domain type (HR, Finance, Sales, etc.)
- Regional context (for regulations)
- Existing system landscape
- Key constraints

### Step 2: Deep Read All Sources

For each file in ingestion report, perform deep analysis:

```yaml
analysis_per_file:
  file: [path]
  
  entities_extracted:
    - name: [EntityName]
      evidence: "[quote from source]"
      confidence: [HIGH|MEDIUM|LOW]
      attributes_mentioned: [list]
      
  workflows_extracted:
    - name: [WorkflowName]
      evidence: "[quote from source]"
      confidence: [HIGH|MEDIUM|LOW]
      actors_mentioned: [list]
      steps_mentioned: [list]
      
  rules_extracted:
    - description: [rule description]
      evidence: "[quote from source]"
      confidence: [HIGH|MEDIUM|LOW]
      applies_to: [entity or workflow]
      
  questions_raised:
    - question: [what's unclear]
      context: [why it matters]
```

### Step 3: Consolidate Findings

Merge extractions from all files:

#### 3.1 Entity Consolidation

For each potential entity:
1. Merge mentions from different sources
2. Resolve naming conflicts (use most common or clearest name)
3. Combine attributes from all sources
4. Assign confidence score

```yaml
consolidated_entity:
  name: [EntityName]
  aliases: [other names used in sources]
  sources: [list of files mentioning this]
  confidence: [HIGH|MEDIUM|LOW]
  classification: [CORE|VALUE_OBJECT|REFERENCE|TRANSACTION]
  description: [synthesized from sources]
  attributes:
    - name: [attr]
      type: [inferred type]
      source: [which file mentioned it]
  relationships:
    - target: [OtherEntity]
      type: [relationship type]
      evidence: [quote]
```

#### 3.2 Workflow Consolidation

For each potential workflow:
1. Merge related actions into coherent workflows
2. Identify actors and triggers
3. Map to related entities
4. Assign confidence score

#### 3.3 Business Rule Consolidation

For each rule:
1. Link to entity or workflow
2. Determine rule type (validation, constraint, calculation)
3. Assign ID and confidence

### Step 4: Gap Analysis

Identify what's missing based on domain expertise:

#### 4.1 Entity Gaps

As SME, I expect these entities in [domain] but don't see them:
- [Expected entity 1] - [why expected]
- [Expected entity 2] - [why expected]

#### 4.2 Workflow Gaps

Standard workflows I expect but aren't documented:
- [Expected workflow 1] - [why expected]
- [Expected workflow 2] - [why expected]

#### 4.3 Attribute Gaps

Common attributes missing from entities:
- [Entity] missing [attribute] - standard in [reference system]

#### 4.4 Rule Gaps

Standard business rules not mentioned:
- [Rule description] - common in [domain]

### Step 5: Fill Gaps with Market Knowledge

For each gap, apply SME knowledge:

```yaml
gap_resolution:
  gap: [what's missing]
  resolution: [how I'm filling it]
  source: "Market knowledge: [reference system/standard]"
  confidence: ASSUMED
  assumption: [explicit assumption being made]
  needs_validation: [true|false]
```

#### Market Knowledge Sources by Domain

**HR/HCM Domain:**
- Workday patterns: Leave management, Time tracking, Compensation
- SAP SuccessFactors: Employee lifecycle, Performance management
- Oracle HCM: Benefits administration, Payroll integration
- Standards: SHRM guidelines, ISO 30414

**Finance Domain:**
- SAP FI/CO: GL, AP, AR, Cost centers
- Oracle Financials: Procure-to-pay, Order-to-cash
- Standards: GAAP, IFRS, SOX compliance

**Sales/CRM Domain:**
- Salesforce: Lead-to-opportunity, Account management
- SAP CRM: Pipeline management, Quotation
- Standards: MEDDIC, BANT qualification

### Step 6: Resolve Conflicts

When sources conflict:

1. **Date conflict**: Use most recent source
2. **Stakeholder conflict**: Flag for human review
3. **Detail conflict**: Use most detailed version
4. **Terminology conflict**: Create alias mapping

### Step 7: Ask Clarifying Questions (If Needed)

If critical information is genuinely missing and cannot be assumed:

```markdown
## Questions for Stakeholder

Before proceeding, please clarify:

1. **[Question]**
   - Context: [why this matters]
   - My assumption if no answer: [what I'll assume]

2. **[Question]**
   - Context: [why this matters]
   - My assumption if no answer: [what I'll assume]
```

**Important**: Only ask questions that are:
- Critical for correctness
- Cannot be reasonably assumed
- Would significantly change the output

Prefer making documented assumptions over blocking progress.

### Step 8: Generate Analysis Report

Output: `_output/_logs/analysis-report.md`

```markdown
# Analysis Report

**Generated**: [timestamp]
**Analyst**: AI SME Agent
**Domain Expertise Applied**: [domain type]

## Executive Summary

- **Entities identified**: [N] ([confidence breakdown])
- **Workflows identified**: [N] ([confidence breakdown])
- **Business rules identified**: [N]
- **Gaps filled with market knowledge**: [N]
- **Assumptions made**: [N]

## Consolidated Entities

### [EntityName] [CONFIDENCE]

**Classification**: [type]
**Sources**: [list]
**Description**: [description]

**Attributes**:
| Attribute | Type | Required | Source |
|-----------|------|----------|--------|
| [attr] | [type] | [Y/N] | [source] |

**Relationships**:
| Target | Cardinality | Description |
|--------|-------------|-------------|
| [entity] | [card] | [desc] |

**Business Rules**:
- BR-XXX: [rule]

---

[Repeat for each entity]

## Consolidated Workflows

### [WorkflowName] [CONFIDENCE]

**Classification**: [CORE|SUPPORT|INTEGRATION]
**Trigger**: [trigger]
**Actors**: [list]
**Related Entities**: [list]

**High-Level Steps**:
1. [step]
2. [step]
3. [step]

**Business Rules Applied**: [list]

---

[Repeat for each workflow]

## Business Rules Catalog

| ID | Description | Applies To | Source | Confidence |
|----|-------------|------------|--------|------------|
| BR-001 | [desc] | [entity/workflow] | [source] | [conf] |

## Gap Analysis

### Gaps Filled with Market Knowledge

| Gap | Resolution | Source | Assumption |
|-----|------------|--------|------------|
| [gap] | [resolution] | [market ref] | [assumption] |

### Remaining Gaps (Need Human Input)

| Gap | Impact | Suggested Resolution |
|-----|--------|---------------------|
| [gap] | [impact] | [suggestion] |

## Assumptions Made

| # | Assumption | Rationale | Risk if Wrong |
|---|------------|-----------|---------------|
| 1 | [assumption] | [rationale] | [risk] |

## Questions for Stakeholder (Optional)

[Only if critical questions exist]

## Confidence Summary

| Category | HIGH | MEDIUM | LOW | ASSUMED |
|----------|------|--------|-----|---------|
| Entities | [N] | [N] | [N] | [N] |
| Workflows | [N] | [N] | [N] | [N] |
| Rules | [N] | [N] | [N] | [N] |

## Ready for Phase 3

Analysis complete. Proceed to DRD synthesis.
```

## Output

- `_output/_logs/analysis-report.md`
- Ready for Phase 3: Synthesize

## Key Behaviors

### DO:
- Make reasonable assumptions based on domain expertise
- Document every assumption explicitly
- Use market knowledge to fill gaps
- Prefer progress over perfection
- Be specific about confidence levels

### DON'T:
- Block on minor missing details
- Invent arbitrary numbers without flagging
- Ignore conflicting information
- Make assumptions without documenting them

## Next Phase

After completing analysis:
→ Load `phase-3-synthesize/SKILL.md`
→ Pass analysis-report.md as input
