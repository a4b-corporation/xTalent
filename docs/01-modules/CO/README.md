# Core HR (CO) Module

**Version**: 1.0.0  
**Status**: In Development (Batch 1A)  
**Owner**: HR Platform Team

---

## 📋 Overview

The Core HR module is the foundation of xTalent HCM, providing essential entities and workflows for:

- **Person Management**: Worker personal data, profiles, skills, and competencies
- **Employment Management**: Employment relationships, contracts, and assignments
- **Organization Structure**: Legal entities, business units, and organizational hierarchy
- **Job & Position Management**: Job catalog, position definitions, and career paths
- **Master Data**: Common reference data (skills, competencies, geographic data, code lists)
- **Facility Management**: Work locations, places, and facilities
- **Eligibility Management**: Cross-module eligibility profiles and rules

This module follows the **ERD-First Workflow** approach, building ontology from database design (`1.core.v4.dbml`) with AI enrichment.

---

## 📁 Documentation Structure

```
CO/
├── manifest.yaml                    # Module metadata and dependencies
├── README.md                        # This file
│
├── 00-ontology/                     # LAYER 0: Ontology (WHAT exists)
│   ├── domain/
│   │   ├── entity-index.yaml       # Entity registry by classification
│   │   ├── 01-person/              # Person sub-module (10 entities)
│   │   ├── 02-employment/          # Employment sub-module (7 entities)
│   │   ├── 03-org-structure/       # Org structure sub-module (10 entities)
│   │   ├── 04-job-position/        # Job-Position sub-module (13 entities)
│   │   ├── 05-master-data/         # Master data sub-module (15 entities)
│   │   ├── 06-facility/            # Facility sub-module (3 entities)
│   │   └── 07-eligibility/         # Eligibility sub-module (3 entities)
│   ├── workflows/                   # Workflow definitions
│   ├── actions/                     # Action definitions
│   └── glossary/                    # Domain vocabulary
│
├── 01-concept/                      # LAYER 1: Concept (HOW it works)
│   ├── 01-person/                  # Business guides for Person
│   ├── 02-employment/              # Business guides for Employment
│   └── ...
│
├── 02-spec/                         # LAYER 2: Specification (EXACT requirements)
│   ├── 05-BDD/                     # BDD scenarios (Gherkin)
│   └── ...
│
├── 03-design/                       # LAYER 3: Design (TECHNICAL)
│   └── 1.core.v4.dbml              # Database schema (source of truth)
│
└── 04-implementation/               # LAYER 4: Implementation
```

---

## 🎯 Sub-Modules

| Code | Name | Status | Entities | AGGREGATE_ROOT | Description |
|------|------|--------|----------|----------------|-------------|
| **01-PERSON** | Person Management | 🚧 In Progress | 10 | Worker | Worker personal data and profiles |
| **02-EMPLOYMENT** | Employment Management | 📋 Planned | 7 | Employee | Employment relationships and contracts |
| **03-ORG-STRUCTURE** | Organization Structure | 📋 Planned | 10 | LegalEntity, BusinessUnit | Legal entities and business units |
| **04-JOB-POSITION** | Job & Position | 📋 Planned | 13 | Job, Position, TaxonomyTree, JobTree, CareerPath | Job catalog and positions |
| **05-MASTER-DATA** | Master Data | 📋 Planned | 15 | TalentMarket, Opportunity | Reference data and talent marketplace |
| **06-FACILITY** | Facility Management | 📋 Planned | 3 | - | Work locations and places |
| **07-ELIGIBILITY** | Eligibility Management | 📋 Planned | 3 | EligibilityProfile | Cross-module eligibility |

**Total**: 68 entities, 12 AGGREGATE_ROOT

---

## 🔑 Key Entities (AGGREGATE_ROOT)

### Phase 1: Foundation
1. **Worker** - Person/worker master data (🚧 In Progress)

### Phase 2: Organization
2. **Employee** - Employment relationship
3. **LegalEntity** - Legal entity (company)
4. **BusinessUnit** - Business unit/department

### Phase 3: Job & Position
5. **Job** - Job definition
6. **Position** - Position in org structure
7. **TaxonomyTree** - Job taxonomy tree
8. **JobTree** - Job tree structure
9. **CareerPath** - Career path definition

### Phase 4: Advanced Features
10. **TalentMarket** - Talent market configuration
11. **Opportunity** - Internal opportunity
12. **EligibilityProfile** - Eligibility profile

---

## 🚀 Implementation Progress

### Current: Batch 1A (Infrastructure + Worker)

**Status**: In Progress  
**Target**: ~15 files

- [x] Infrastructure setup
  - [x] `manifest.yaml`
  - [x] `entity-index.yaml`
  - [x] Directory structure
  - [x] README files
- [x] Worker AGGREGATE_ROOT
  - [x] `worker.entity.yaml`
  - [x] `create-worker.workflow.yaml`
  - [ ] `update-worker-profile.workflow.yaml`
  - [ ] `create-worker.action.yaml`
  - [ ] `update-worker.action.yaml`
  - [ ] `delete-worker.action.yaml`
  - [ ] `person.glossary.yaml`
  - [ ] `worker-guide.md` (Concept)
  - [ ] `worker.feature` (BDD)

### Next: Batch 1B (Worker Child Entities)
- 9 ENTITY files (contact, address, document, etc.)

### Next: Batch 1C (Master Data)
- 13 REFERENCE_DATA files

---

## 🔗 Integration Points

This module provides foundational data for:

- **TA (Time & Absence)**: Worker and org data for leave management
- **TR (Total Rewards)**: Worker and position data for compensation
- **PR (Payroll)**: Worker and assignment data for payroll processing
- **RC (Recruiting)**: Worker data for candidate management

---

## 📚 Key Concepts

### Table vs Entity vs Domain Object

Following ERD-First Workflow standards:

- **Tables** (80+ in DBML): All database structures
- **Entities** (68): Tables with business identity (have meaningful primary keys)
- **Domain Objects** (12): AGGREGATE_ROOT entities with independent lifecycle

**Not all tables become entities**:
- Junction tables (only FKs) → modeled as N:N relationships
- History/audit tables → modeled via `history:` section
- Technical tables (migrations) → ignored

### Entity Classifications

- **AGGREGATE_ROOT**: Core domain objects with lifecycle (require full artifact set)
- **ENTITY**: Child entities belonging to aggregates (simpler artifact set)
- **REFERENCE_DATA**: Lookup/configuration data (minimal artifact set)
- **VALUE_OBJECT**: Embedded values (no separate entity files)

---

## 📖 Documentation Standards

This module follows **xTalent Ontology Standards v3.1**:

- **ERD-First Workflow**: Build ontology from DBML with AI enrichment
- **Dual Format Strategy**: YAML for machine, Markdown for human
- **Artifact Requirements**: Different by classification (see entity-index.yaml)
- **Quality Standards**: Comprehensive validation, security, GDPR compliance

See: `../../00-global/note/ontology-standards/`

---

## 🔐 Security & Compliance

- **Data Classification**: PII_SENSITIVE for Worker and related entities
- **GDPR Compliance**: Right to be forgotten, data anonymization
- **Encryption**: Required for all PII fields
- **Audit**: Full audit trail for all changes
- **Access Control**: Role-based access (HR_ADMIN, HR_MANAGER, SELF)

---

## 📞 Contact

**Module Owner**: HR Platform Team  
**Email**: hr-platform@company.com  
**Last Updated**: 2025-12-25

---

## 🔗 Related Documents

- [Implementation Plan](../../.gemini/antigravity/brain/5fee8886-1181-42c2-ad70-1a3240c69708/implementation_plan.md)
- [Ontology Standards](../../00-global/note/ontology-standards/)
- [ERD-First Workflow](../../00-global/note/ontology-standards/00-getting-started/ERD-FIRST-WORKFLOW.md)
- [Database Design](./03-design/1.core.v4.dbml)
