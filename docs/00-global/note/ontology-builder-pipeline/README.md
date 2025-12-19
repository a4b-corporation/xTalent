# Ontology Builder Pipeline

**Version**: 1.0  
**Purpose**: Fully automated AI pipeline to build Domain Ontology from raw inputs  
**Approach**: Skill-based AI Agent with multi-phase execution

---

## 🎯 Overview

This pipeline enables an AI Agent to automatically generate Domain Ontology documentation from raw inputs (user stories, interviews, existing documents) by acting as a domain Subject Matter Expert (SME).

```
┌─────────────────────────────────────────────────────────────────┐
│                         INPUT                                    │
│  • User Stories    • Interviews    • Existing Docs              │
│  • Project Context • Domain Hints  • References                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AI AGENT PIPELINE                             │
│                                                                 │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐     │
│  │ Phase 1  │──▶│ Phase 2  │──▶│ Phase 3  │──▶│ Phase 4  │     │
│  │ Ingest   │   │ Analyze  │   │Synthesize│   │ Generate │     │
│  │          │   │ (as SME) │   │   DRD    │   │ Ontology │     │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘     │
│                                                                 │
│  Skills: phase-1-ingest → phase-2-analyze → phase-3-synthesize  │
│          → phase-4-generate                                     │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                         OUTPUT                                   │
│  • Domain Requirement Document (DRD)                            │
│  • Entity Definitions (Markdown)                                │
│  • Workflow Catalog (Markdown)                                  │
│  • Concept Guides (Markdown)                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
ontology-builder-pipeline/
│
├── PIPELINE-MASTER-PLAN.md          # Master plan (AI reads this first)
├── README.md                        # This file
│
├── skills/                          # AI Skills for each phase
│   ├── phase-1-ingest/
│   │   └── SKILL.md                 # Ingest and catalog inputs
│   ├── phase-2-analyze/
│   │   └── SKILL.md                 # SME analysis
│   ├── phase-3-synthesize/
│   │   └── SKILL.md                 # DRD generation
│   └── phase-4-generate/
│       └── SKILL.md                 # Ontology generation
│
└── templates/                       # Input templates
    ├── project-context.template.md  # Required context
    ├── domain-hints.template.md     # Optional domain hints
    ├── user-stories.template.md     # User story format
    └── interview.template.md        # Interview format
```

---

## 🚀 Quick Start

### Step 1: Prepare Input Folder

Create a project folder with inputs:

```
my-project/
├── _input/
│   ├── project-context.md           # REQUIRED - Copy from templates/
│   ├── domain-hints.md              # OPTIONAL - Copy from templates/
│   ├── requirements/
│   │   └── user-stories.md          # Your user stories
│   ├── interviews/
│   │   └── interview-*.md           # Your interviews
│   └── existing-docs/
│       └── *.md                     # Any existing docs
│
├── _output/                         # AI will write here
└── _pipeline/                       # Copy pipeline files here
    ├── PIPELINE-MASTER-PLAN.md
    └── skills/
```

### Step 2: Fill Required Templates

At minimum, fill out `project-context.md`:

```markdown
# Project Context

## Basic Information
| Field | Value |
|-------|-------|
| **Project Name** | My HCM System |
| **Module** | Leave Management |
| **Module Code** | LV |
| **Domain** | HR |
| **Region** | Vietnam |
...
```

### Step 3: Run Pipeline

Give AI Agent this instruction:

```
Execute Ontology Builder Pipeline for [my-project] folder.

Read _pipeline/PIPELINE-MASTER-PLAN.md first, then execute all phases.
```

### Step 4: Review Output

After pipeline completes, review:
- `_output/00-drd/DRD-[module].md` - Domain Requirements Document
- `_output/01-ontology/` - Generated Ontology files
- `_output/_logs/` - Processing logs

---

## 📋 Input Requirements

### Required

| Input | Purpose |
|-------|---------|
| `project-context.md` | Project background, scope, constraints |

### Recommended

| Input | Purpose |
|-------|---------|
| User stories | Primary source for entities/workflows |
| Interviews | Domain expert knowledge |
| `domain-hints.md` | Terminology, local rules |

### Optional

| Input | Purpose |
|-------|---------|
| Existing documents | Legacy system docs, policies |
| Reference materials | Industry standards, competitor analysis |
| Screenshots | Visual reference for existing systems |

---

## 🔄 Phase Details

### Phase 1: Ingest

**Input**: `_input/` folder  
**Output**: `_output/_logs/ingestion-report.md`  
**Purpose**: Catalog and summarize all input materials

### Phase 2: Analyze (as SME)

**Input**: Ingestion report + raw files  
**Output**: `_output/_logs/analysis-report.md`  
**Purpose**: Extract entities, workflows, rules with SME expertise

Key behaviors:
- Fill knowledge gaps using market knowledge
- Make documented assumptions
- Flag areas needing human review

### Phase 3: Synthesize DRD

**Input**: Analysis report  
**Output**: `_output/00-drd/DRD-[module].md`  
**Purpose**: Generate complete Domain Requirement Document

### Phase 4: Generate Ontology

**Input**: DRD  
**Output**: `_output/01-ontology/`  
**Purpose**: Generate final Ontology artifacts

Output structure:
```
01-ontology/
├── README.md
├── domain/
│   ├── [submodule]-entities.md
│   └── shared-entities.md
├── workflows/
│   └── [submodule]-workflows.md
└── concept-guides/
    └── [workflow]-guide.md
```

---

## 🧠 SME Knowledge Sources

When acting as SME, AI references:

### HR/HCM Domain
- Workday, SAP SuccessFactors, Oracle HCM patterns
- SHRM standards
- Local labor laws (Vietnam, Singapore, etc.)

### Finance Domain
- SAP FI/CO, Oracle Financials patterns
- GAAP/IFRS standards
- Local tax regulations

### General Patterns
- Domain-Driven Design principles
- Enterprise Integration Patterns
- Industry-standard workflows

---

## ✅ Quality Standards

### Confidence Levels

| Level | Meaning |
|-------|---------|
| HIGH | From explicit input sources |
| MEDIUM | Inferred from context |
| LOW | Partial evidence |
| ASSUMED | Market knowledge, needs validation |

### Output Quality

- All entities have descriptions and attributes
- All workflows have step-by-step flows
- Business rules linked to entities/workflows
- Examples provided for each entity
- Assumptions explicitly documented

---

## 🔧 Customization

### Adding Domain-Specific Knowledge

Add to `_input/domain-hints.md`:
- Industry terminology
- Local regulations
- Company-specific rules
- Reference system patterns

### Adjusting Output Detail

In `project-context.md`, set:
```markdown
## Output Preferences
| Preference | Value |
|------------|-------|
| **Detail Level** | Detailed |  # or Standard, Minimal
```

---

## 📊 Expected Timeline

| Phase | Duration | Output |
|-------|----------|--------|
| Input Preparation | 1-2 hours | Filled templates |
| Phase 1-4 (AI) | 15-30 mins | Complete ontology |
| Human Review | 1-2 hours | Validated output |
| **Total** | **~3-4 hours** | **vs 2-3 weeks manual** |

---

## 🤝 Human-in-the-Loop

Although pipeline is automated, human review is recommended at:

1. **After Phase 2**: Review assumptions
2. **After Phase 3**: Validate DRD
3. **After Phase 4**: Final ontology review

The AI will flag items needing review with:
- `[ASSUMED]` markers
- Open Questions section
- Low confidence items

---

## 📝 License

[Your license]

---

## 🔗 Related Documentation

- [PIPELINE-MASTER-PLAN.md](./PIPELINE-MASTER-PLAN.md) - Detailed pipeline specification
- [Ontology-Concept-Spec Methodology](../ONTOLOGY-CONCEPT-SPEC-METHODOLOGY.md) - Underlying methodology
- [Module Documentation Standards](../MODULE-DOCUMENTATION-STANDARDS.md) - Output standards
