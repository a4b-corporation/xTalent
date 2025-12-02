# Core Module (CO) - Specification Approach Analysis

**Version**: 2.0  
**Last Updated**: 2025-12-02  
**Status**: Planning Phase

---

## 🔍 GitHub Spec-Kit vs Our Current Approach

### GitHub Spec-Kit Methodology

Based on the [GitHub Spec-Kit](https://github.com/github/spec-kit), the **Spec-Driven Development** process is:

```yaml
Spec-Kit Process:
  1. Constitution (Project Principles)
     - Governing principles
     - Development guidelines
     - Quality standards
     
  2. Functional Specification (spec.md)
     - User stories
     - Functional requirements
     - What to build (NOT how)
     - Tech-stack agnostic
     
  3. Clarification (spec.md updates)
     - Structured Q&A
     - Refine requirements
     - Validate acceptance criteria
     
  4. Technical Plan (plan.md)
     - Tech stack decisions
     - Architecture choices
     - Implementation approach
     - Research notes
     
  5. Task Breakdown (tasks.md)
     - Actionable tasks
     - Implementation steps
     
  6. Implementation
     - Execute tasks
     - Build the feature
```

### Our Current Approach

```yaml
Our Current Approach:
  0. Ontology (core-ontology.yaml)
     - Data model foundation
     - Entity definitions
     
  1. Concept Guides (01-concept/*.md)
     - Business requirements
     - Conceptual understanding
     - User-facing guides
     
  2. Specifications (02-spec/*.md) - PLANNED
     - Functional requirements
     - API specs
     - Data specs
     - Business rules
     - Use cases
     
  3. Design (03-design/*.dbml)
     - Database schema
     - Technical design
     
  4. Implementation
     - Code
```

---

## 📊 Comparison Analysis

### Similarities ✅

| Aspect | Spec-Kit | Our Approach | Match? |
|--------|----------|--------------|--------|
| **Functional Spec** | spec.md (user stories, requirements) | Functional Requirements | ✅ Yes |
| **Tech-agnostic first** | Yes (spec before plan) | Yes (concept before spec) | ✅ Yes |
| **Technical Plan** | plan.md (tech stack, architecture) | Design docs | ✅ Yes |
| **Task Breakdown** | tasks.md | Implementation plan | ✅ Yes |
| **Iterative refinement** | Clarification step | Review cycles | ✅ Yes |

### Differences ⚠️

| Aspect | Spec-Kit | Our Approach | Issue? |
|--------|----------|--------------|--------|
| **Granularity** | Per-feature specs | Module-wide specs | ⚠️ Too broad |
| **Structure** | .specify/specs/NNN-feature-name/ | 02-spec/*.md | ⚠️ Different |
| **Constitution** | Project principles first | Not explicit | ⚠️ Missing |
| **Data Model** | In plan.md (after spec) | In ontology (before spec) | ⚠️ Order |
| **API Spec** | In contracts/ (after plan) | Planned early | ⚠️ Order |
| **Scope** | Per feature/story | Entire module | ⚠️ Too big |

---

## 🎯 Key Insights

### 1. **Spec-Kit is Feature-Driven, We are Module-Driven**

**Spec-Kit**:
```
.specify/
  specs/
    001-create-taskify/
      spec.md          # Functional spec for THIS feature
      plan.md          # Technical plan for THIS feature
      tasks.md         # Tasks for THIS feature
      data-model.md    # Data model for THIS feature
      contracts/
        api-spec.json  # API for THIS feature
```

**Our Approach**:
```
02-spec/
  01-functional-requirements.md  # ALL features in module
  02-api-specification.md        # ALL APIs in module
  03-data-specification.md       # ALL data in module
  04-business-rules.md           # ALL rules in module
```

**Problem**: Our approach is too broad! We should break down by **feature/epic**, not by **document type**.

---

### 2. **Spec-Kit Separates "What" from "How"**

**Spec-Kit Order**:
```
1. spec.md (WHAT to build - functional requirements)
   ↓
2. Clarify (refine WHAT)
   ↓
3. plan.md (HOW to build - tech stack, architecture)
   ↓
4. data-model.md, api-spec.json (technical details)
```

**Our Current Order**:
```
1. Ontology (data model FIRST - too technical too early)
   ↓
2. Concept (business understanding)
   ↓
3. Spec (functional + technical mixed)
```

**Problem**: We defined data model (ontology) BEFORE functional requirements!

---

### 3. **Constitution (Project Principles) is Missing**

Spec-Kit starts with **constitution.md** - governing principles:
- Code quality standards
- Testing requirements
- Performance requirements
- Security standards
- Development guidelines

**We don't have this!** We should create it.

---

## ✅ Recommended Approach (Aligned with Spec-Kit)

### New Structure

```
xTalent/
  .specify/
    memory/
      constitution.md           # Project principles
      
    specs/
      # Feature 1: Worker Management
      001-worker-management/
        spec.md                 # Functional spec
        plan.md                 # Technical plan
        tasks.md                # Task breakdown
        data-model.md           # Data model for this feature
        contracts/
          api-spec.yaml         # API spec for this feature
      
      # Feature 2: Employment Lifecycle
      002-employment-lifecycle/
        spec.md
        plan.md
        tasks.md
        data-model.md
        contracts/
          api-spec.yaml
      
      # Feature 3: Organization Structure
      003-organization-structure/
        spec.md
        plan.md
        tasks.md
        data-model.md
        contracts/
          api-spec.yaml
      
      # ... more features
    
    templates/
      spec-template.md
      plan-template.md
      tasks-template.md
```

---

## 🔄 Revised Process

### Phase 0: Foundation (DONE ✅)

```yaml
Status: COMPLETE

Deliverables:
  - core-ontology.yaml (data model foundation)
  - Glossaries (entity definitions)
  - Concept guides (business understanding)

Purpose:
  - Understand the domain
  - Define entities and relationships
  - Business education
```

### Phase 1: Constitution (NEW - HIGH PRIORITY)

```yaml
Status: TODO

Deliverable:
  - .specify/memory/constitution.md

Content:
  - Project principles
  - Code quality standards
  - Testing requirements (unit, integration, e2e)
  - Performance requirements
  - Security standards (GDPR, PDPA, Vietnam Decree 13)
  - Development guidelines
  - API design principles
  - Database design principles
  - Documentation standards

Purpose:
  - Guide all subsequent development
  - Ensure consistency
  - Set quality bar
```

### Phase 2: Feature Specifications (Per Feature)

```yaml
Status: TODO

For Each Feature:
  
  Step 1: Functional Spec (spec.md)
    - User stories
    - Functional requirements
    - Acceptance criteria
    - Tech-agnostic
    - Focus on WHAT, not HOW
    
  Step 2: Clarification
    - Structured Q&A
    - Refine requirements
    - Validate completeness
    
  Step 3: Technical Plan (plan.md)
    - Tech stack choices
    - Architecture decisions
    - Implementation approach
    - Research notes
    
  Step 4: Data Model (data-model.md)
    - Tables for THIS feature
    - Relationships
    - Constraints
    
  Step 5: API Spec (contracts/api-spec.yaml)
    - Endpoints for THIS feature
    - Request/response formats
    - OpenAPI spec
    
  Step 6: Task Breakdown (tasks.md)
    - Actionable tasks
    - Implementation steps
    - Dependencies
```

---

## 📋 Feature List (Epic Breakdown)

### Core Module Features (Prioritized)

```yaml
Phase 1: Core Employment (High Priority)
  
  001-worker-management:
    - Create worker
    - Update worker
    - Data classification
    - Consent management
    
  002-work-relationship:
    - Create work relationship
    - Employee vs Contractor
    - Status management
    - Termination
    
  003-employee-management:
    - Create employee record
    - Employee number generation
    - Probation tracking
    - Rehire handling
    
  004-assignment-management:
    - Create assignment
    - Position-based staffing
    - Job-based staffing
    - Manager assignment
    - Transfer/promotion
    
  005-basic-reporting:
    - Headcount reports
    - Employee list
    - Org chart

Phase 2: Organization & Jobs (Medium Priority)
  
  006-business-unit:
    - Create business unit
    - Unit hierarchy
    - Operational vs Supervisory
    
  007-job-taxonomy:
    - Job families
    - Job hierarchy
    - Multi-tree support
    
  008-job-profile:
    - Job requirements
    - Skills & competencies
    - Proficiency levels
    
  009-position-management:
    - Create position
    - Vacancy tracking
    - Position hierarchy
    
  010-reporting-lines:
    - Solid line reporting
    - Dotted line reporting
    - Matrix organizations

Phase 3: Skills & Advanced (Lower Priority)
  
  011-skill-catalog:
    - Skill master
    - Proficiency scales
    - Certifications
    
  012-skill-assessment:
    - Worker skills
    - Skill gap analysis
    - Development plans
    
  013-career-paths:
    - Career progression
    - Job progression rules
    
  014-data-privacy:
    - DSAR workflows
    - Consent management
    - Audit reports
```

---

## 🎯 Immediate Next Steps

### Option A: Follow Spec-Kit Exactly (RECOMMENDED)

```yaml
1. Create Constitution
   File: .specify/memory/constitution.md
   Content: Project principles, standards, guidelines
   
2. Pick First Feature (001-worker-management)
   
3. Write Functional Spec
   File: .specify/specs/001-worker-management/spec.md
   Content: User stories, requirements (WHAT, not HOW)
   
4. Clarify & Refine
   Iterate on spec.md
   
5. Write Technical Plan
   File: .specify/specs/001-worker-management/plan.md
   Content: Tech stack, architecture (HOW)
   
6. Define Data Model
   File: .specify/specs/001-worker-management/data-model.md
   Content: Tables, relationships for THIS feature
   
7. Define API Spec
   File: .specify/specs/001-worker-management/contracts/api-spec.yaml
   Content: Endpoints for THIS feature
   
8. Break Down Tasks
   File: .specify/specs/001-worker-management/tasks.md
   Content: Implementation tasks
   
9. Implement
   Execute tasks
```

### Option B: Hybrid Approach

```yaml
Keep our current structure but reorganize:

1. Create Constitution
   File: 00-foundation/constitution.md
   
2. Reorganize Specs by Feature
   02-spec/
     001-worker-management/
       functional-spec.md
       technical-plan.md
       data-model.md
       api-spec.yaml
       tasks.md
     002-employment-lifecycle/
       ...
     
3. Reference Ontology
   Ontology serves as "master data model"
   Feature data-models are subsets
```

---

## 💡 Recommendations

### 1. **Adopt Spec-Kit Structure** ✅

**Why**:
- Industry-proven methodology
- AI-agent friendly
- Feature-focused (easier to manage)
- Clear separation of concerns (WHAT vs HOW)
- Better for incremental development

**How**:
- Create `.specify/` directory
- Organize by feature, not by document type
- Follow spec → plan → tasks flow

### 2. **Reuse Our Concept Guides** ✅

**Our concept guides are VALUABLE**:
- They provide business context
- They educate stakeholders
- They are more detailed than typical specs

**How to use them**:
- Reference from functional specs
- Use as "extended documentation"
- Keep in `01-concept/` for education
- Link from feature specs

### 3. **Treat Ontology as "Master Reference"** ✅

**Our ontology is GOOD**:
- Comprehensive data model
- Well-defined entities
- Clear relationships

**How to use it**:
- Keep as master reference
- Feature data-models are subsets
- Reference from feature specs
- Don't duplicate, just reference

### 4. **Start with Constitution** ✅

**Create project principles FIRST**:
- Quality standards
- Testing requirements
- Security requirements (GDPR, PDPA, Vietnam)
- API design principles
- Database design principles

---

## 📊 Comparison: Old vs New Approach

### Old Approach (Module-Wide)

```
Pros:
  ✅ Comprehensive view of entire module
  ✅ Good for understanding big picture
  
Cons:
  ❌ Too broad to implement
  ❌ Hard to break down into tasks
  ❌ Mixes WHAT and HOW
  ❌ Not AI-agent friendly
```

### New Approach (Feature-Driven, Spec-Kit Style)

```
Pros:
  ✅ Feature-focused (manageable scope)
  ✅ Clear WHAT → HOW separation
  ✅ Easy to break down into tasks
  ✅ AI-agent friendly
  ✅ Incremental development
  ✅ Industry-proven methodology
  
Cons:
  ⚠️ Need to manage feature dependencies
  ⚠️ Need to ensure consistency across features
```

---

## ✅ Final Recommendation

### Adopt Spec-Kit Methodology with Our Enhancements

```yaml
Structure:
  .specify/
    memory/
      constitution.md           # NEW: Project principles
      
    specs/
      001-worker-management/    # NEW: Per-feature specs
        spec.md                 # Functional spec (WHAT)
        plan.md                 # Technical plan (HOW)
        data-model.md           # Data model (subset of ontology)
        contracts/
          api-spec.yaml         # API spec
        tasks.md                # Task breakdown
      
      002-employment-lifecycle/
        ...
  
  00-ontology/                  # KEEP: Master data model
    core-ontology.yaml
    glossaries/
  
  01-concept/                   # KEEP: Business guides
    01-employment-lifecycle-guide.md
    02-organization-structure-guide.md
    ...
  
  03-design/                    # KEEP: Technical design
    dbml/
  
  04-implementation/            # Future: Code
```

### Benefits:
1. ✅ **Spec-Kit compliant** - Can use AI agents
2. ✅ **Reuses our work** - Concept guides, ontology
3. ✅ **Feature-focused** - Manageable scope
4. ✅ **Clear process** - WHAT → HOW → Tasks
5. ✅ **Industry-proven** - GitHub methodology

---

**Document Version**: 1.0  
**Created**: 2025-12-02  
**Status**: Analysis Complete - Ready for Decision
