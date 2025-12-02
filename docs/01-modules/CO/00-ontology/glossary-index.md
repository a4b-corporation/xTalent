# Core Module (CO) - Glossary Index

**Version**: 2.0  
**Last Updated**: 2025-12-01  
**Module**: Core Organization & People Management

---

## 📚 Overview

This glossary provides comprehensive definitions for all entities, terms, and concepts in the Core module. The glossary is organized into sub-modules for easy navigation.

**Total Sub-Modules**: 11  
**Total Entities**: 50+

---

## 📖 Sub-Module Glossaries

### 1. **Common** - Master Data & Reference Tables
**File**: [`glossary-common.md`](./glossary-common.md)  
**Entities**: 10  
- CodeList, Currency, TimeZone, Industry
- ContactType, RelationshipGroup, RelationshipType
- TalentMarket, SkillMaster, CompetencyMaster

**Purpose**: Foundation master data used across all modules

---

### 2. **Geographic** - Geographic Master Data
**File**: [`glossary-geographic.md`](./glossary-geographic.md)  
**Entities**: 2  
- Country, AdminArea

**Purpose**: Geographic hierarchy (country → province → district → ward)

---

### 3. **LegalEntity** - Legal Entity (Company) Structure
**File**: [`glossary-legal-entity.md`](./glossary-legal-entity.md)  
**Entities**: 6  
- EntityType, Entity, EntityProfile
- EntityRepresentative, EntityLicense, EntityBankAccount

**Purpose**: Legal company structure, shareholding, compliance

---

### 4. **BusinessUnit** - Operational Organization Units
**File**: [`glossary-business-unit.md`](./glossary-business-unit.md)  
**Entities**: 3  
- UnitType, Unit, UnitTag

**Purpose**: Operational org structure (division, department, team, supervisory)

---

### 5. **OrganizationRelation** - Dynamic Relationships
**File**: [`glossary-org-relation.md`](./glossary-org-relation.md)  
**Entities**: 3  
- RelationSchema, RelationType, RelationEdge

**Purpose**: Matrix organizations, reporting lines, dynamic relationships

---

### 6. **Person** - Worker (People) Master Data ⭐
**File**: [`glossary-person.md`](./glossary-person.md)  
**Entities**: 10  
- Worker, Contact, Address, Document, BankAccount
- WorkerRelationship, WorkerQualification
- WorkerSkill, WorkerCompetency, WorkerInterest

**Purpose**: Core person data, qualifications, skills, competencies

---

### 7. **Employment** - Employment Relationships & Assignments ⭐⭐
**File**: [`glossary-employment.md`](./glossary-employment.md)  
**Entities**: 6  
- **WorkRelationship** (NEW in v2.0)
- Employee, Contract, Assignment
- EmployeeIdentifier, GlobalAssignment

**Purpose**: Work relationships, employment contracts, job assignments (4-level hierarchy)

---

### 8. **JobPosition** - Job & Position Structures
**File**: [`glossary-job-position.md`](./glossary-job-position.md)  
**Entities**: 8  
- TaxonomyTree, JobTaxonomy, JobTree
- Job, JobProfile, JobLevel, JobGrade, Position

**Purpose**: Job classification, position management, multi-tree taxonomy

---

### 9. **Career** - Career Paths & Progression
**File**: [`glossary-career.md`](./glossary-career.md)  
**Entities**: 3  
- CareerPath, CareerStep, JobProgression

**Purpose**: Career development, progression paths

---

### 10. **Facility** - Physical Locations & Facilities
**File**: [`glossary-facility.md`](./glossary-facility.md)  
**Entities**: 3  
- Place, Location, WorkLocation

**Purpose**: Physical workplace locations

---

### 11. **TalentMarket** - Internal Talent Marketplace
**File**: [`glossary-talent-market.md`](./glossary-talent-market.md)  
**Entities**: 3  
- Opportunity, OpportunitySkill, OpportunityApplication

**Purpose**: Internal job marketplace, gig economy

---

## 🔑 Key Concepts (Cross-Cutting)

### Person-Worker-Employee-Assignment Hierarchy (v2.0)

```
┌─────────────────────────────────────────────────────────┐
│ WORKER                                                  │
│ • Immutable person identity                             │
│ • Person Type: EMPLOYEE, CONTRACTOR, CONTINGENT, etc.  │
│ • Core biographical data                                │
└─────────────────┬───────────────────────────────────────┘
                  │ 1 Worker → Many Work Relationships
                  ↓
┌─────────────────────────────────────────────────────────┐
│ WORK RELATIONSHIP (NEW in v2.0)                         │
│ • Overall relationship with organization                │
│ • Type: EMPLOYEE, CONTRACTOR, CONTINGENT, VOLUNTEER     │
│ • Can have multiple concurrent relationships            │
└─────────────────┬───────────────────────────────────────┘
                  │ 1 Relationship → 0..1 Employee Record
                  ↓
┌─────────────────────────────────────────────────────────┐
│ EMPLOYEE                                                │
│ • Employment contract details                           │
│ • Only for EMPLOYEE-type work relationships             │
│ • Employee code, hire date, probation                   │
└─────────────────┬───────────────────────────────────────┘
                  │ 1 Employee → Many Assignments
                  ↓
┌─────────────────────────────────────────────────────────┐
│ ASSIGNMENT                                              │
│ • Actual job assignment in business unit                │
│ • Staffing Model: POSITION_BASED or JOB_BASED          │
│ • Reporting lines (solid + dotted)                      │
└─────────────────────────────────────────────────────────┘
```

### Legal Entity vs Business Unit

| Aspect | Legal Entity | Business Unit |
|--------|--------------|---------------|
| **Purpose** | Legal/compliance structure | Operational structure |
| **Examples** | ABC Ltd., DEF Branch | Sales Dept, Engineering Team |
| **Hierarchy** | Corporate group | Division → Department → Team |
| **Code Prefix** | `LE-` | `BU-` |
| **Tax/Legal** | Yes (tax ID, licenses) | No |
| **Employment** | Employer of record | Work location |

### Staffing Models (NEW in v2.0)

#### Position-Based Staffing
- **Use Case**: Corporate roles, strict headcount control
- **Characteristics**:
  - Pre-defined budgeted positions
  - One position = one person (typically)
  - FTE tracking per position
  - Vacancy management
- **Example**: "Finance Manager" position in Finance Dept

#### Job-Based Staffing
- **Use Case**: Hourly workers, contractors, flexible capacity
- **Characteristics**:
  - No pre-defined positions
  - Multiple people → same job
  - Flexible headcount
  - Dynamic capacity
- **Example**: "Warehouse Worker" job (10 people, no specific positions)

### Matrix Organization (v2.0 Enhancement)

```
Solid Line Reporting (Primary)
  → Affects approval chains
  → Performance reviews
  → Direct authority

Dotted Line Reporting (Secondary)
  → Functional guidance
  → Matrix relationships
  → Informational only

Supervisory Organization
  → Security/approval hierarchy
  → Can differ from operational structure
  → Used for access control
```

---

## 🎯 Version 2.0 Highlights

### New Concepts
- ✨ **Work Relationship** - Separation from employment contract
- ✨ **Person Types** - EMPLOYEE, CONTRACTOR, CONTINGENT, NON_WORKER, PENDING, FORMER
- ✨ **Supervisory Organization** - Separate approval hierarchy
- ✨ **Staffing Model Flexibility** - POSITION_BASED vs JOB_BASED
- ✨ **Matrix Reporting** - Explicit solid vs dotted line
- ✨ **Skill Gap Analysis** - Target proficiency tracking
- ✨ **Data Classification** - GDPR/CCPA compliance metadata

### Enhanced Concepts
- 🔄 Employee now child of WorkRelationship
- 🔄 Assignment supports both staffing models
- 🔄 RelationType with explicit reporting types
- 🔄 WorkerSkill with gap analysis fields

---

## 📖 How to Use This Glossary

### For Business Users
1. Start with **Employment** glossary for core hiring/assignment concepts
2. Read **Person** glossary for worker data
3. Review **JobPosition** for job structures

### For System Architects
1. Study **Common** for master data patterns
2. Understand **OrganizationRelation** for flexibility
3. Review **Employment** for 4-level hierarchy

### For Implementers
1. Read all glossaries sequentially
2. Focus on business rules in each entity
3. Note relationships and dependencies

---

## 🔗 Related Documentation

- **Ontology**: [`core-ontology.yaml`](./core-ontology.yaml) - Technical data model
- **Review**: [`CORE-ONTOLOGY-REVIEW.md`](./CORE-ONTOLOGY-REVIEW.md) - Best practices comparison
- **Enhancement Summary**: [`ONTOLOGY-V2-ENHANCEMENT-SUMMARY.md`](./ONTOLOGY-V2-ENHANCEMENT-SUMMARY.md)
- **Database Design**: [`../03-design/1.Core.V3.dbml`](../03-design/1.Core.V3.dbml)

---

## 📝 Glossary Conventions

### Term Types
- **Entity**: Database table/object (e.g., Worker, Employee)
- **Attribute**: Field within entity (e.g., hire_date, FTE)
- **Relationship**: Link between entities (e.g., Worker → Employee)
- **Concept**: Business idea (e.g., Staffing Model, Matrix Organization)
- **Pattern**: Design approach (e.g., SCD Type 2, Multi-tree)

### Notation
- `code_style` - Technical terms, field names, enums
- **Bold** - Important concepts
- *Italic* - Emphasis or clarification
- → - "leads to" or "results in"
- ⚠️ - Important warning or note
- ✨ - New in version 2.0
- 🔄 - Enhanced in version 2.0

---

**Document Version**: 2.0  
**Maintained By**: xTalent Documentation Team  
**Last Review**: 2025-12-01
