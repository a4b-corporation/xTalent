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
├── VERIFICATION-GATEWAY-SYSTEM.md   # Verification system documentation
├── README.md                        # This file
│
├── skills/                          # AI Skills
│   ├── phase-1-ingest/
│   │   └── SKILL.md                 # Ingest + Gate 1 verification
│   ├── phase-2-analyze/
│   │   └── SKILL.md                 # SME analysis + Gate 2 verification
│   ├── phase-3-synthesize/
│   │   └── SKILL.md                 # DRD generation + Gate 3 verification
│   ├── phase-4-generate/
│   │   └── SKILL.md                 # Ontology generation + Gate 4 verification
│   └── verifier-agent/
│       └── SKILL.md                 # Independent verification agent
│
└── templates/                       # Input templates
    ├── project-context.template.md
    ├── domain-hints.template.md
    ├── user-stories.template.md
    └── interview.template.md
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

### Phase 4: Generate Ontology + Concept

**Input**: DRD  
**Output**: `_output/00-ontology/` + `_output/01-concept/`  
**Purpose**: Generate final Ontology and Concept Guide artifacts

Output structure:
```
00-ontology/                         # Domain Foundation
├── README.md
├── domain/
│   ├── [submodule]-entities.md      # Entity definitions (SINGLE SOURCE)
│   └── shared-entities.md
└── workflows/
    └── [submodule]-workflows.md     # Workflow CATALOG only

01-concept/                          # Behavioral Documentation  
├── README.md
└── [submodule]/
    ├── overview.md
    └── [workflow]-guide.md          # Workflow DETAIL here
```

---

## 🧠 Dynamic SME Expertise

The AI Agent dynamically activates domain expertise based on `project-context.md`:

### How It Works

1. **Domain Identification**: AI reads project context to identify domain, industry, region
2. **SME Activation**: AI "becomes" a senior expert in that domain
3. **Knowledge Application**: AI applies industry patterns, standards, regulations
4. **Gap Filling**: AI uses domain expertise + web search to fill knowledge gaps

### Supported Domains (Any)

The pipeline is **domain-agnostic**. AI can act as SME for:

| Domain | Example Reference Systems | Example Standards |
|--------|---------------------------|-------------------|
| HR/HCM | Workday, SAP SF, Oracle HCM | SHRM, ISO 30414 |
| Finance | SAP S/4HANA, Oracle, NetSuite | GAAP, IFRS, VAS |
| Sales/CRM | Salesforce, HubSpot, SAP CRM | MEDDIC, BANT |
| Operations | SAP MM, Oracle SCM | Six Sigma, APICS |
| Healthcare | Epic, Cerner | HIPAA, HL7 |
| *Any other* | *AI will research* | *AI will identify* |

### Web Search Integration

AI uses web search when needed to:
- Verify current regulations
- Research unfamiliar domains
- Find latest best practices
- Understand regional requirements

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

## 🔍 Verification System

The pipeline includes built-in verification gates and supports independent AI verification.

### Self-Verification (Built-in)

Each phase generates a verification manifest:

| Gate | After Phase | Checks |
|------|-------------|--------|
| Gate 1 | Ingest | File coverage, summaries present |
| Gate 2 | Analyze | Source traceability, confidence levels |
| Gate 3 | Synthesize | Completeness, no placeholders |
| Gate 4 | Generate | Links valid, end-to-end trace |

### Independent Verification (Optional)

Use a separate AI Agent to cross-validate:

```
Agent 2 (Verifier):
"Verify ontology pipeline outputs in [project] folder.
 Load skills/verifier-agent/SKILL.md and run full verification."
```

The Verifier Agent will:
- Cross-reference outputs against inputs
- Identify unsupported claims
- Flag potential hallucinations
- Generate verification report

### Verification Outputs

```
_output/_logs/
├── gate-1-manifest.yaml      # Post-ingest verification
├── gate-2-manifest.yaml      # Post-analysis verification
├── gate-3-manifest.yaml      # Post-DRD verification
├── gate-4-manifest.yaml      # Final verification
├── traceability-matrix.yaml  # End-to-end trace
└── verification-report.md    # Independent verifier report
```

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
