# Ontology Builder Pipeline - Master Plan

**Version**: 1.0  
**Purpose**: Fully automated AI pipeline to build Domain Ontology from raw inputs  
**Approach**: Skill-based AI Agent with multi-phase execution

---

## 1. Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ONTOLOGY BUILDER PIPELINE                                │
│                                                                             │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│  │  PHASE 1 │───▶│  PHASE 2 │───▶│  PHASE 3 │───▶│  PHASE 4 │              │
│  │  Ingest  │    │  Analyze │    │ Synthestic│    │ Generate │              │
│  │          │    │  as SME  │    │    DRD   │    │ Ontology │              │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘              │
│       ▲                                               │                     │
│       │              Human Review Points              ▼                     │
│       │         (optional, on-demand only)      ┌──────────┐              │
│       └─────────────────────────────────────────│  OUTPUT  │              │
│                                                 │ Ontology │              │
│                                                 └──────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Input Structure

### 2.1 Required Input Folder

```
[PROJECT]/
├── _input/                              # ← AI reads from here
│   ├── project-context.md               # REQUIRED: Project background
│   ├── domain-hints.md                  # OPTIONAL: Domain-specific hints
│   │
│   ├── requirements/                    # Raw requirements (any format)
│   │   ├── user-stories.md
│   │   ├── feature-list.md
│   │   └── requirements-*.md
│   │
│   ├── interviews/                      # Interview transcripts
│   │   ├── interview-*.md
│   │   └── meeting-notes-*.md
│   │
│   ├── existing-docs/                   # Existing documentation
│   │   ├── *.md
│   │   ├── *.pdf
│   │   └── *.docx
│   │
│   └── references/                      # Reference materials
│       ├── competitor-analysis.md
│       ├── industry-standards.md
│       └── screenshots/
│
├── _output/                             # ← AI writes to here
│   ├── 00-drd/                          # Generated DRD
│   ├── 01-ontology/                     # Generated Ontology
│   └── _logs/                           # Processing logs
│
└── _pipeline/                           # Pipeline configuration
    ├── PIPELINE-MASTER-PLAN.md          # This file
    └── skills/                          # AI Skills
        ├── phase-1-ingest/
        ├── phase-2-analyze/
        ├── phase-3-synthesize/
        └── phase-4-generate/
```

### 2.2 project-context.md (Required)

```markdown
# Project Context

## Basic Information
- **Project Name**: [Name]
- **Module**: [Module being documented]
- **Domain**: [HR | Finance | Sales | Operations | Custom]
- **Company**: [Company name]
- **Region**: [Country - for regulatory context]

## Current State
- **Existing System**: [None | System name | Manual process]
- **Pain Points**: [List main issues]

## Target State
- **Goals**: [List main goals]
- **Timeline**: [Expected timeline]

## Stakeholders
| Role | Name | Responsibility |
|------|------|----------------|
| Product Owner | [Name] | [Responsibility] |
| SME | [Name] | [Responsibility] |

## Constraints
- **Technical**: [Any technical constraints]
- **Business**: [Any business constraints]
- **Regulatory**: [Applicable regulations]

## Output Preferences
- **Language**: [English | Vietnamese | Both]
- **Detail Level**: [Standard | Detailed | Minimal]
```

---

## 3. Phase Definitions

### Phase 1: INGEST
- **Skill**: `phase-1-ingest`
- **Input**: All files in `_input/`
- **Output**: `_output/_logs/ingestion-report.md`
- **Purpose**: Read and catalog all input materials

### Phase 2: ANALYZE
- **Skill**: `phase-2-analyze`
- **Input**: Ingestion report + raw files
- **Output**: `_output/_logs/analysis-report.md`
- **Purpose**: Extract entities, workflows, rules as SME

### Phase 3: SYNTHESIZE
- **Skill**: `phase-3-synthesize`
- **Input**: Analysis report
- **Output**: `_output/00-drd/DRD-[module].md`
- **Purpose**: Generate complete DRD document

### Phase 4: GENERATE
- **Skill**: `phase-4-generate`
- **Input**: DRD document
- **Output**: `_output/01-ontology/`
- **Purpose**: Generate Ontology from DRD

---

## 4. Execution Flow

### 4.1 Single Command Execution

```bash
# AI Agent receives this instruction:
"Execute Ontology Builder Pipeline for [PROJECT] folder"
```

### 4.2 AI Agent Behavior

```
1. Read PIPELINE-MASTER-PLAN.md (this file)
2. Validate _input/ folder structure
3. For each phase:
   a. Load phase skill
   b. Execute skill instructions
   c. Generate phase output
   d. Log progress
4. Present final output to user
```

### 4.3 Decision Points

| Situation | AI Behavior |
|-----------|-------------|
| Missing required input | Ask user for clarification |
| Ambiguous requirement | Make assumption + document it |
| Missing domain knowledge | Use market knowledge as SME |
| Conflicting information | Flag + use most recent source |
| Complex business rule | Break down + confirm understanding |

---

## 5. Quality Gates

### After Phase 2 (Analysis)
- [ ] All input files processed
- [ ] Entities extracted with confidence scores
- [ ] Workflows identified
- [ ] Gaps documented

### After Phase 3 (DRD)
- [ ] DRD follows template structure
- [ ] All sections complete
- [ ] Assumptions documented
- [ ] Open questions listed

### After Phase 4 (Ontology)
- [ ] Entity files generated
- [ ] Workflow catalog generated
- [ ] Cross-references valid
- [ ] No TODO placeholders

---

## 6. SME Knowledge Sources

When acting as SME, AI should reference:

### HR Domain
- Workday, SAP SuccessFactors, Oracle HCM patterns
- SHRM standards
- Local labor laws (based on region in context)

### Finance Domain
- SAP, Oracle Financials patterns
- GAAP/IFRS standards
- Local tax regulations

### General Patterns
- Domain-Driven Design principles
- Enterprise Integration Patterns
- Industry-standard workflows

---

## 7. Output Quality Standards

### Entity Definition Quality
- Clear description (2-3 sentences)
- All attributes with types and constraints
- Relationships with cardinality
- Business rules attached
- Examples provided

### Workflow Quality
- Clear trigger and actors
- Complete main flow
- Alternate flows documented
- Related entities linked
- Mermaid diagram included

---

## 8. Error Handling

| Error | Recovery |
|-------|----------|
| No input files | Stop + request input |
| Unreadable file format | Skip + log warning |
| Insufficient context | Ask clarifying question |
| Circular reference | Flag + suggest resolution |

---

## 9. Versioning

Each pipeline run creates versioned output:
- DRD: `DRD-[module]-v[N].md`
- Ontology files include version in header
- Logs include timestamp

---

## Next: Load Phase Skills

After reading this plan, proceed to load and execute:
1. `skills/phase-1-ingest/SKILL.md`
2. `skills/phase-2-analyze/SKILL.md`
3. `skills/phase-3-synthesize/SKILL.md`
4. `skills/phase-4-generate/SKILL.md`
