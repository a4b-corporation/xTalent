# Skills & Competencies API Catalog

> **Module**: Core HR - Skills & Competencies Management  
> **Version**: 1.0.0  
> **Status**: Draft  
> **Last Updated**: 2026-01-29  
> **Reference**: Oracle HCM Talent, Workday Skills Cloud, SAP SuccessFactors patterns

---

## Overview

This document catalogs all necessary APIs for **Skills & Competencies** master data and taxonomy. These entities serve as foundation for Talent Management modules.

### Skill vs Competency

| Aspect | Skill | Competency |
|--------|-------|------------|
| **Nature** | Technical ability | Behavioral trait |
| **Question** | "What can you do?" | "How do you do it?" |
| **Measurement** | Objective (tests, certs) | Subjective (360, ratings) |
| **Examples** | Java, Python, Excel | Leadership, Communication |

### Domain Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  SKILLS (Technical/Functional Abilities)                           │
│  ┌──────────────────┐         ┌──────────────┐                     │
│  │  SkillCategory   │◄────────│    Skill     │                     │
│  │  (Taxonomy)      │         │ (Master Data)│                     │
│  └──────────────────┘         └──────────────┘                     │
│           │                          │                              │
│           │                          ├── JobProfileSkill (Required) │
│           │                          └── WorkerSkill (Possessed)    │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  COMPETENCIES (Behavioral Traits)                                  │
│  ┌──────────────────┐         ┌──────────────┐                     │
│  │CompetencyCategory│◄────────│  Competency  │                     │
│  │  (Taxonomy)      │         │ (Master Data)│                     │
│  └──────────────────┘         └──────────────┘                     │
│           │                          │                              │
│           │                          └── WorkerCompetency (Assessed)│
└─────────────────────────────────────────────────────────────────────┘
```

### Entities Covered

| Entity | Description | File |
|--------|-------------|------|
| **Skill** | Technical/functional ability master data | skill.onto.md |
| **SkillCategory** | Hierarchical taxonomy for skills | skill-category.onto.md |
| **Competency** | Behavioral trait master data | competency.onto.md |
| **CompetencyCategory** | Hierarchical taxonomy for competencies | competency-category.onto.md |

---

## 1. Skill APIs

> **Entity**: `Skill`  
> **Domain**: Master Data  
> **Base Path**: `/api/v1/skills`

### 1.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/skills` | Create skill | Admin |
| `GET` | `/skills/{id}` | Get by ID | Read |
| `GET` | `/skills` | List (paginated) | Read |
| `PATCH` | `/skills/{id}` | Update | Admin |
| `DELETE` | `/skills/{id}` | Soft delete | Admin |

### 1.2 Business Actions - Lifecycle

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/skills/{id}/actions/activate` | Activate skill | Admin |
| `POST` | `/skills/{id}/actions/deactivate` | Deactivate | Admin |
| `POST` | `/skills/{id}/actions/deprecate` | Deprecate (replaced) | Skill obsolete |
| `POST` | `/skills/{id}/actions/reactivate` | Reactivate | Admin |

### 1.3 Business Actions - Management

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/skills/{id}/actions/merge` | Merge duplicate skills | Cleanup |
| `POST` | `/skills/{id}/actions/updateKeywords` | Update AI matching keywords | AI tuning |
| `POST` | `/skills/{id}/actions/linkExternal` | Link to external ID (O*NET, LinkedIn) | Integration |
| `POST` | `/skills/{id}/actions/createVersion` | Create SCD Type-2 version | Major change |

### 1.4 Batch Operations

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/skills/actions/import` | Bulk import skills | Initial setup |
| `POST` | `/skills/actions/export` | Export skills catalog | Integration |
| `POST` | `/skills/batch` | Batch create/update | Admin |

### 1.5 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/skills/query/by-category/{catId}` | Get by category | `includeChildren` |
| `GET` | `/skills/query/by-type/{type}` | Get by skill type | `type` |
| `GET` | `/skills/query/active` | Get active skills only | - |
| `GET` | `/skills/query/trending` | Get trending/in-demand skills | `limit` |
| `GET` | `/skills/search` | Full-text search | `q`, `type`, `categoryId` |
| `GET` | `/skills/{id}/related` | Get related skills | `limit` |
| `GET` | `/skills/{id}/jobs` | Get jobs requiring this skill | - |
| `GET` | `/skills/{id}/workers` | Get workers with this skill | `minProficiency` |
| `GET` | `/skills/{id}/gap-summary` | Get gap analysis summary | - |

### 1.6 Skill Types

| Type | Description | Examples |
|------|-------------|----------|
| `TECHNICAL` | Programming, systems | Java, Python, React |
| `FUNCTIONAL` | Domain knowledge | Financial Analysis, HR Law |
| `SOFT` | Interpersonal | Presentation, Negotiation |
| `LANGUAGE` | Natural languages | English, Japanese, Vietnamese |
| `CERTIFICATION` | Certified skills | AWS Certified, PMP |
| `TOOL` | Software tools | Excel, Figma, JIRA |

---

## 2. SkillCategory APIs

> **Entity**: `SkillCategory`  
> **Domain**: Taxonomy  
> **Base Path**: `/api/v1/skill-categories`

### 2.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/skill-categories` | Create category | Admin |
| `GET` | `/skill-categories/{id}` | Get by ID | Read |
| `GET` | `/skill-categories` | List (paginated) | Read |
| `PATCH` | `/skill-categories/{id}` | Update | Admin |
| `DELETE` | `/skill-categories/{id}` | Soft delete | Admin |

### 2.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/skill-categories/{id}/actions/activate` | Activate category | Admin |
| `POST` | `/skill-categories/{id}/actions/deactivate` | Deactivate | Admin |
| `POST` | `/skill-categories/{id}/actions/moveToParent` | Reparent category | Reorganization |
| `POST` | `/skill-categories/{id}/actions/merge` | Merge into another | Cleanup |
| `POST` | `/skill-categories/{id}/actions/reorder` | Update sort order | Admin |

### 2.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/skill-categories/{id}/children` | Get child categories | `recursive` |
| `GET` | `/skill-categories/{id}/ancestors` | Get path to root | - |
| `GET` | `/skill-categories/{id}/descendants` | Get all descendants | `maxDepth` |
| `GET` | `/skill-categories/{id}/skills` | Get skills in category | `includeChildren` |
| `GET` | `/skill-categories/tree` | Get full hierarchy tree | `depth` |
| `GET` | `/skill-categories/query/roots` | Get root categories | - |
| `GET` | `/skill-categories/search` | Search by name | `q` |

### 2.4 Example Hierarchy

```
Technical
├── Programming Languages
│   ├── Backend (Java, Python, Go)
│   └── Frontend (JavaScript, TypeScript, React)
├── Cloud & DevOps
│   ├── Cloud Platforms (AWS, Azure, GCP)
│   └── Containerization (Docker, Kubernetes)
└── Database
    ├── SQL (PostgreSQL, MySQL)
    └── NoSQL (MongoDB, Redis)

Soft Skills
├── Communication
├── Leadership
└── Problem Solving
```

---

## 3. Competency APIs

> **Entity**: `Competency`  
> **Domain**: Master Data  
> **Base Path**: `/api/v1/competencies`

### 3.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/competencies` | Create competency | Admin |
| `GET` | `/competencies/{id}` | Get by ID | Read |
| `GET` | `/competencies` | List (paginated) | Read |
| `PATCH` | `/competencies/{id}` | Update | Admin |
| `DELETE` | `/competencies/{id}` | Soft delete | Admin |

### 3.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/competencies/{id}/actions/activate` | Activate competency | Admin |
| `POST` | `/competencies/{id}/actions/deactivate` | Deactivate | Admin |
| `POST` | `/competencies/{id}/actions/deprecate` | Deprecate | Obsolete |
| `POST` | `/competencies/{id}/actions/updateIndicators` | Update behavioral indicators | Admin |
| `POST` | `/competencies/{id}/actions/setAsCore` | Mark as core competency | HR |
| `POST` | `/competencies/{id}/actions/removeFromCore` | Remove from core | HR |

### 3.3 Batch Operations

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/competencies/actions/import` | Bulk import competencies | Setup |
| `POST` | `/competencies/actions/export` | Export competency library | Integration |
| `POST` | `/competencies/batch` | Batch create/update | Admin |

### 3.4 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/competencies/query/by-category/{catId}` | Get by category | `includeChildren` |
| `GET` | `/competencies/query/by-type/{type}` | Get by type | - |
| `GET` | `/competencies/query/by-framework/{code}` | Get by framework | - |
| `GET` | `/competencies/query/core` | Get core competencies | - |
| `GET` | `/competencies/search` | Search by name | `q`, `type` |
| `GET` | `/competencies/{id}/workers` | Get workers assessed | `minRating` |
| `GET` | `/competencies/{id}/behavioral-indicators` | Get behavioral indicators | - |

### 3.5 Competency Types

| Type | Description | Examples |
|------|-------------|----------|
| `CORE` | Company-wide values | Integrity, Innovation |
| `LEADERSHIP` | Management behaviors | Coaching, Strategic Thinking |
| `FUNCTIONAL` | Role-specific behaviors | Client Focus, Technical Depth |
| `TECHNICAL_BEHAVIORAL` | Mixed technical + soft | Solution Thinking |

---

## 4. CompetencyCategory APIs

> **Entity**: `CompetencyCategory`  
> **Domain**: Taxonomy  
> **Base Path**: `/api/v1/competency-categories`

### 4.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/competency-categories` | Create category | Admin |
| `GET` | `/competency-categories/{id}` | Get by ID | Read |
| `GET` | `/competency-categories` | List (paginated) | Read |
| `PATCH` | `/competency-categories/{id}` | Update | Admin |
| `DELETE` | `/competency-categories/{id}` | Soft delete | Admin |

### 4.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/competency-categories/{id}/actions/activate` | Activate | Admin |
| `POST` | `/competency-categories/{id}/actions/deactivate` | Deactivate | Admin |
| `POST` | `/competency-categories/{id}/actions/moveToParent` | Reparent | Reorganization |
| `POST` | `/competency-categories/{id}/actions/setFramework` | Assign to framework | Admin |
| `POST` | `/competency-categories/{id}/actions/reorder` | Update sort order | Admin |

### 4.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/competency-categories/{id}/children` | Get child categories | `recursive` |
| `GET` | `/competency-categories/{id}/ancestors` | Get path to root | - |
| `GET` | `/competency-categories/{id}/descendants` | Get all descendants | `maxDepth` |
| `GET` | `/competency-categories/{id}/competencies` | Get competencies | `includeChildren` |
| `GET` | `/competency-categories/tree` | Get full hierarchy | `frameworkCode` |
| `GET` | `/competency-categories/query/by-framework/{code}` | Get by framework | - |
| `GET` | `/competency-categories/query/roots` | Get root categories | - |
| `GET` | `/competency-categories/search` | Search by name | `q` |

### 4.4 Competency Frameworks

| Framework | Description | Categories |
|-----------|-------------|------------|
| `COMPANY_CORE` | Company-wide values | Core Values, Execution |
| `LEADERSHIP_PIPELINE` | Leadership development | People Management, Strategic Thinking |
| `SALES_EXCELLENCE` | Sales-specific | Customer Focus, Negotiation |
| `TECHNICAL_EXCELLENCE` | Technical roles | Technical Depth, Innovation |

---

## Summary

### API Count by Entity

| Entity | CRUD | Actions | Query | Total |
|--------|------|---------|-------|-------|
| Skill | 5 | 11 | 9 | **25** |
| SkillCategory | 5 | 5 | 7 | **17** |
| Competency | 5 | 9 | 7 | **21** |
| CompetencyCategory | 5 | 5 | 8 | **18** |
| **Total** | **20** | **30** | **31** | **81** |

### Priority Matrix

| Priority | APIs | Description |
|----------|------|-------------|
| **P0** | 20 | CRUD - MVP |
| **P1** | 12 | Core Lifecycle (activate, deactivate) |
| **P2** | 8 | Taxonomy Operations (move, merge) |
| **P3** | 10 | Import/Export, Batch |
| **P4** | 31 | Query & Navigation |

### Key Use Cases

| Use Case | APIs Involved |
|----------|---------------|
| **Setup Skills Catalog** | POST /skill-categories (tree) → POST /skills (bulk) |
| **Define Competency Framework** | POST /competency-categories → POST /competencies |
| **Find Skill Gap** | GET /skills/{id}/gap-summary |
| **Search Workers by Skill** | GET /skills/{id}/workers |
| **Find Related Skills** | GET /skills/{id}/related |

---

## Appendix: Integration Points

### External Skill Sources

| Source | Description | Field Mapping |
|--------|-------------|---------------|
| **O*NET** | US job database | `externalId`, `externalSource: "ONET"` |
| **LinkedIn Skills** | LinkedIn skill taxonomy | `externalId`, `externalSource: "LINKEDIN"` |
| **ESCO** | European skills taxonomy | `externalId`, `externalSource: "ESCO"` |

### AI Matching Keywords

```json
{
  "skill": "Java",
  "keywords": ["java8", "java11", "spring", "spring boot", "jvm", "backend java", "java developer"]
}
```

### Multi-Module Usage

```
Skill / Competency referenced by:
├── Core HR → JobProfile requirements
├── Core HR → Worker possessions
├── Talent → Gap analysis
├── Training → Learning recommendations
├── Recruiting → Candidate matching
└── Succession → Readiness assessment
```

---

*Document Status: DRAFT*  
*References: [[Skill]], [[SkillCategory]], [[Competency]], [[CompetencyCategory]]*
