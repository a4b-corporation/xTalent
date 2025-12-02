# xTalent Documentation Structure

> Created: 2025-11-28

## 📊 Structure Overview

```
docs/
│
├── 📘 README.md                          # Main documentation guide
├── 📝 note.md                            # Design notes and guidelines
│
├── 🌍 00-global/                         # Global/Shared Resources
│   ├── ontology/
│   │   ├── core-domain.yaml             # Core entities (Person, Worker, etc.)
│   │   ├── time-absence-core.yaml       # Time & Absence shared entities
│   │   └── total-rewards-core.yaml      # Total Rewards shared entities
│   ├── glossary/
│   │   └── domain-glossary.md           # Complete terminology dictionary
│   ├── speckit/
│   │   └── spec-structure.md            # SpecKit framework guide
│   └── standards/
│       ├── naming-conventions.md        # Naming standards
│       ├── http-api-standard.md         # (to be created)
│       └── ui-ux-guidelines.md          # (to be created)
│
├── 📦 01-modules/                        # Module-Specific Documentation
│   │
│   ├── CO/ (Core HR)                    # Worker, Org, Position Management
│   │   ├── README.md
│   │   ├── 00-ontology/
│   │   ├── 01-concept/
│   │   │   └── 03-concept-entity-guides/
│   │   ├── 02-spec/
│   │   │   └── 03-scenarios/
│   │   ├── 03-design/
│   │   ├── 04-api/
│   │   ├── 05-ui/
│   │   │   ├── 02-screens/
│   │   │   └── 03-mockups/
│   │   ├── 06-tests/
│   │   │   └── 03-playwright-specs/
│   │   └── 07-impl-notes/
│   │
│   ├── TA/ (Time & Absence)             # Leave, Attendance, Scheduling
│   │   ├── README.md
│   │   ├── 00-ontology/
│   │   ├── 01-concept/
│   │   │   └── 03-concept-entity-guides/
│   │   ├── 02-spec/
│   │   │   └── 03-scenarios/
│   │   ├── 03-design/
│   │   ├── 04-api/
│   │   ├── 05-ui/
│   │   │   ├── 02-screens/
│   │   │   └── 03-mockups/
│   │   ├── 06-tests/
│   │   │   └── 03-playwright-specs/
│   │   └── 07-impl-notes/
│   │
│   ├── TR/ (Total Rewards)              # Compensation, Benefits, Grades
│   │   ├── README.md
│   │   ├── 00-ontology/
│   │   ├── 01-concept/
│   │   │   └── 03-concept-entity-guides/
│   │   ├── 02-spec/
│   │   │   └── 03-scenarios/
│   │   ├── 03-design/
│   │   ├── 04-api/
│   │   ├── 05-ui/
│   │   │   ├── 02-screens/
│   │   │   └── 03-mockups/
│   │   ├── 06-tests/
│   │   │   └── 03-playwright-specs/
│   │   └── 07-impl-notes/
│   │
│   └── PR/ (Payroll)                    # Payroll Processing
│       ├── README.md
│       ├── 00-ontology/
│       ├── 01-concept/
│       │   └── 03-concept-entity-guides/
│       ├── 02-spec/
│       │   └── 03-scenarios/
│       ├── 03-design/
│       ├── 04-api/
│       ├── 05-ui/
│       │   ├── 02-screens/
│       │   └── 03-mockups/
│       ├── 06-tests/
│       │   └── 03-playwright-specs/
│       └── 07-impl-notes/
│
├── 📋 _templates/                        # Document Templates
│   ├── ontology-template.yaml
│   ├── concept-overview-template.md
│   ├── conceptual-guide-template.md     # (to be created)
│   ├── behaviour-spec-template.md       # (to be created)
│   ├── api-spec-template.yaml           # (to be created)
│   ├── ui-spec-template.md              # (to be created)
│   └── test-scenario-template.md        # (to be created)
│
└── 🤖 _ai-prompts/                       # AI Agent Prompts
    ├── generate-concept-from-ontology.md
    ├── generate-api-from-ontology.md    # (to be created)
    ├── generate-ui-from-spec.md         # (to be created)
    └── generate-tests-from-scenarios.md # (to be created)
```

## 📈 Statistics

### Created
- **Directories**: 68 folders
- **Files**: 14 documentation files
- **Modules**: 4 (CO, TA, TR, PR)
- **Layers per Module**: 8 (00-ontology through 07-impl-notes)

### File Breakdown
- **Global Ontology**: 3 YAML files (core, time-absence, total-rewards)
- **Global Docs**: 3 MD files (glossary, speckit, naming-conventions)
- **Module READMEs**: 4 MD files
- **Templates**: 2 files (ontology, concept-overview)
- **AI Prompts**: 1 file (generate-concept)
- **Main README**: 1 file

## 🎯 Module Summary

### CO (Core HR)
**Purpose**: Foundation module for worker, organization, and position management
**Key Entities**: Person, Worker, LegalEntity, OrgUnit, Job, Position, Assignment

### TA (Time & Absence)
**Purpose**: Comprehensive time and absence management
**Key Entities**: TimeType, TimeBalance, TimeEvent, TimeMovement, LeaveRequest, AttendanceRecord

### TR (Total Rewards)
**Purpose**: Compensation and benefits administration
**Key Entities**: CompensationPlan, CompensationComponent, Grade, BenefitPlan, EquityGrant

### PR (Payroll)
**Purpose**: Payroll processing and management
**Key Entities**: PayrollPeriod, PayrollRun, PayrollElement, PayrollResult, TaxRule

## 📝 Documentation Layers (per Module)

| Layer | Folder | Purpose | Output |
|-------|--------|---------|--------|
| **0** | `00-ontology/` | Domain entities, rules | YAML, MD, diagrams |
| **1** | `01-concept/` | What & Why (non-technical) | MD files |
| **2** | `02-spec/` | Detailed specifications | MD files, scenarios |
| **3** | `03-design/` | System & data design | DBML, MD |
| **4** | `04-api/` | API specifications | OpenAPI YAML |
| **5** | `05-ui/` | UI specs & mockups | MD, HTML |
| **6** | `06-tests/` | Test scenarios | MD, Playwright specs |
| **7** | `07-impl-notes/` | Technical decisions | MD (ADR) |

## 🚀 Next Steps

### Immediate Tasks
1. ✅ Create directory structure
2. ✅ Create global ontology files
3. ✅ Create global documentation (glossary, speckit, naming)
4. ✅ Create module READMEs
5. ✅ Create initial templates
6. ✅ Create AI prompt examples

### To Be Created
1. ⏳ Additional templates (behaviour-spec, api-spec, ui-spec, test-scenario)
2. ⏳ Additional AI prompts (api generation, ui generation, test generation)
3. ⏳ Additional standards (http-api-standard, ui-ux-guidelines)
4. ⏳ Module-specific ontology files
5. ⏳ Module-specific concept documents
6. ⏳ Module-specific specifications

### Recommended Workflow
1. **Start with one module** (suggest TA - Time & Absence)
2. **Create ontology** for that module
3. **Generate concepts** using AI from ontology
4. **Write specifications** for key features
5. **Design data model** and API
6. **Create UI specs** and mockups
7. **Use as template** for other modules

## 📖 Quick Reference

### For New Features
```
1. Define in {module}/00-ontology/
2. Write {module}/01-concept/
3. Specify in {module}/02-spec/
4. Design in {module}/03-design/
5. API in {module}/04-api/
6. UI in {module}/05-ui/
7. Tests in {module}/06-tests/
```

### For AI Generation
```
1. Read ontology → Generate concepts
2. Read ontology + spec → Generate API
3. Read API + UI spec → Generate UI code
4. Read scenarios → Generate tests
```

### For Finding Information
- **Terms**: `00-global/glossary/`
- **Entities**: `00-global/ontology/` or `{module}/00-ontology/`
- **How it works**: `{module}/01-concept/`
- **Detailed specs**: `{module}/02-spec/`
- **APIs**: `{module}/04-api/`
- **UI**: `{module}/05-ui/`

## 🎨 Design Principles

1. **Module-First**: Organize by module, not by document type
2. **Layered**: Clear separation between ontology → concept → spec → design
3. **AI-Ready**: Structured for AI-assisted development
4. **Template-Driven**: Consistent structure using templates
5. **Self-Documenting**: Each folder has clear purpose

## 📞 Support

- **Questions**: See main README.md
- **Templates**: Check _templates/
- **AI Help**: Check _ai-prompts/
- **Standards**: See 00-global/standards/

---

**Created**: 2025-11-28  
**Structure Version**: 1.0  
**Total Folders**: 68  
**Total Files**: 14
