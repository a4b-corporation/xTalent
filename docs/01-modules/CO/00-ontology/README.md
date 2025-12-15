# Core (CO) Module - Ontology

**Version**: 2.0  
**Last Updated**: 2025-12-15  
**Purpose**: Entity definitions and data model for the Core module

---

## 📚 Documents

### Core Ontology Files

| Document | Description | Entities | Status |
|----------|-------------|----------|--------|
| [core-ontology.yaml](./core-ontology.yaml) | Complete Core ontology | 50+ entities across 11 sub-modules | ✅ Complete |

### Glossary Documents

| Document | Description | Language | Status |
|----------|-------------|----------|--------|
| [glossary-index.md](./glossary-index.md) | Master index of all glossaries | EN | ✅ Complete |
| [glossary-common.md](./glossary-common.md) | Common master data entities | EN | ✅ Complete |
| [glossary-common-vi.md](./glossary-common-vi.md) | Common master data entities | VI | ✅ Complete |
| [glossary-geographic.md](./glossary-geographic.md) | Geographic entities | EN | ✅ Complete |
| [glossary-geographic-vi.md](./glossary-geographic-vi.md) | Geographic entities | VI | ✅ Complete |
| [glossary-legal-entity.md](./glossary-legal-entity.md) | Legal entity structures | EN | ✅ Complete |
| [glossary-legal-entity-vi.md](./glossary-legal-entity-vi.md) | Legal entity structures | VI | ✅ Complete |
| [glossary-business-unit.md](./glossary-business-unit.md) | Business unit structures | EN | ✅ Complete |
| [glossary-business-unit-vi.md](./glossary-business-unit-vi.md) | Business unit structures | VI | ✅ Complete |
| [glossary-org-relation.md](./glossary-org-relation.md) | Dynamic org relationships | EN | ✅ Complete |
| [glossary-org-relation-vi.md](./glossary-org-relation-vi.md) | Dynamic org relationships | VI | ✅ Complete |
| [glossary-person.md](./glossary-person.md) | Worker/person entities | EN | ✅ Complete |
| [glossary-person-vi.md](./glossary-person-vi.md) | Worker/person entities | VI | ✅ Complete |
| [glossary-employment.md](./glossary-employment.md) | Employment relationships | EN | ✅ Complete |
| [glossary-employment-vi.md](./glossary-employment-vi.md) | Employment relationships | VI | ✅ Complete |
| [glossary-job-position.md](./glossary-job-position.md) | Job & position structures | EN | ✅ Complete |
| [glossary-job-position-vi.md](./glossary-job-position-vi.md) | Job & position structures | VI | ✅ Complete |
| [glossary-career.md](./glossary-career.md) | Career paths & progression | EN | ✅ Complete |
| [glossary-facility.md](./glossary-facility.md) | Facilities & locations | EN | ✅ Complete |
| [glossary-facility-vi.md](./glossary-facility-vi.md) | Facilities & locations | VI | ✅ Complete |
| [glossary-talent-market.md](./glossary-talent-market.md) | Internal talent marketplace | EN | ✅ Complete |
| [glossary-eligibility.md](./glossary-eligibility.md) | Eligibility rules | EN | ✅ Complete |

### Enhancement & Review Documents

| Document | Description | Status |
|----------|-------------|--------|
| [CORE-ONTOLOGY-REVIEW.md](./CORE-ONTOLOGY-REVIEW.md) | Best practices comparison with Workday/SAP/Oracle | ✅ Complete |
| [ONTOLOGY-V2-ENHANCEMENT-SUMMARY.md](./ONTOLOGY-V2-ENHANCEMENT-SUMMARY.md) | v2.0 enhancement summary | ✅ Complete |
| [JOBPOSITION-IMPLEMENTATION-SUMMARY.md](./JOBPOSITION-IMPLEMENTATION-SUMMARY.md) | Job & Position implementation details | ✅ Complete |
| [MISSING-ENTITIES-ANALYSIS.md](./MISSING-ENTITIES-ANALYSIS.md) | Gap analysis and missing entities | ✅ Complete |
| [GLOSSARY-PROGRESS.md](./GLOSSARY-PROGRESS.md) | Glossary completion tracking | ✅ Complete |

---

## 🎯 Quick Start

**For Developers**: Start with [core-ontology.yaml](./core-ontology.yaml) - complete entity definitions with attributes, relationships, and business rules

**For Business Analysts**: Read [glossary-index.md](./glossary-index.md) for term definitions, then explore specific glossaries by domain

**For Architects**: Review [CORE-ONTOLOGY-REVIEW.md](./CORE-ONTOLOGY-REVIEW.md) for best practices comparison and [ONTOLOGY-V2-ENHANCEMENT-SUMMARY.md](./ONTOLOGY-V2-ENHANCEMENT-SUMMARY.md) for v2.0 enhancements

---

## 📖 Entity Categories

### 1. Common (Master Data)
- **Reference Data**: CodeList, Currency, TimeZone, Industry
- **Contact Types**: ContactType, RelationshipType
- **Skills**: SkillMaster, CompetencyMaster
- **Markets**: TalentMarket

### 2. Geographic
- **Location Hierarchy**: Country, AdminArea (Province/District/Ward)

### 3. Legal Entity
- **Corporate Structure**: Entity, EntityType, EntityProfile
- **Compliance**: EntityRepresentative, EntityLicense, EntityBankAccount

### 4. Business Unit
- **Operational Structure**: Unit, UnitType, UnitTag
- **Supervisory Organizations**: Separate approval/reporting hierarchy

### 5. Organization Relations
- **Dynamic Relationships**: RelationSchema, RelationType, RelationEdge
- **Matrix Organizations**: Support for dotted-line reporting

### 6. Person (Worker)
- **Identity**: Worker (with Person Types: EMPLOYEE, CONTRACTOR, CONTINGENT)
- **Contact Info**: Contact, Address
- **Documents**: Document, BankAccount
- **Relationships**: WorkerRelationship (family, dependents)
- **Qualifications**: WorkerQualification, WorkerSkill, WorkerCompetency
- **Interests**: WorkerInterest

### 7. Employment
- **4-Level Hierarchy**:
  1. **WorkRelationship** (NEW in v2.0) - Overall relationship
  2. **Employee** - Employment contract details
  3. **Contract** - Legal contract terms
  4. **Assignment** - Actual job assignment
- **Global Assignments**: GlobalAssignment (expatriate support)
- **Identifiers**: EmployeeIdentifier

### 8. Job & Position
- **Multi-Tree Architecture**: TaxonomyTree, JobTree
- **Job Classification**: JobTaxonomy, Job, JobProfile
- **Job Grading**: JobLevel, JobGrade
- **Position Management**: Position (with staffing models: POSITION_BASED vs JOB_BASED)

### 9. Career
- **Career Paths**: CareerPath, CareerStep
- **Progression**: JobProgression

### 10. Facility
- **Locations**: Place, Location, WorkLocation

### 11. Talent Market
- **Internal Mobility**: Opportunity, OpportunitySkill, OpportunityApplication

---

## 🌟 Key Features (v2.0)

### Enterprise Best Practices
- ✅ **Work Relationship Concept** - Separation from employment contract (Workday/Oracle pattern)
- ✅ **Person Types** - EMPLOYEE, CONTRACTOR, CONTINGENT, NON_WORKER, PENDING, FORMER
- ✅ **Supervisory Organization** - Separate approval/reporting hierarchy
- ✅ **Staffing Model Flexibility** - POSITION_BASED vs JOB_BASED assignments
- ✅ **Matrix Reporting** - Explicit solid vs dotted line
- ✅ **Skill Gap Analysis** - Target proficiency tracking
- ✅ **Data Classification** - GDPR/CCPA compliance metadata

### Advanced Patterns
- ✅ **SCD Type 2** - Historical tracking with effective dates
- ✅ **Multi-Tree Architecture** - Corporate and BU-specific job catalogs
- ✅ **Dynamic Relationships** - Flexible organization modeling
- ✅ **Global Assignment Support** - Shadow payroll, COLA, housing allowances

---

## 🔗 Related Documentation

- [Core Concept Guides](../01-concept/) - Conceptual documentation and guides
- [Core Specification](../02-spec/) - Detailed requirements and business rules
- [Core Design](../03-design/) - Database schema (DBML) and API design

---

**Maintained by**: xTalent Documentation Team
