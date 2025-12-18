# Ontology Quick Start Guide

**Time Required**: 1 hour  
**Prerequisites**: User requirements document, text editor, AI access  
**Output**: Complete ontology layer documentation

---

## What You'll Create

By the end of this guide, you'll have:
- ✅ `[module]-ontology.yaml` - Entity definitions
- ✅ `[module]-workflows.yaml` - Workflow catalog
- ✅ `glossary-[submodule].md` - Entity glossary
- ✅ `glossary-index.md` - Navigation index

---

## Step-by-Step Process

### Step 1: Prepare Your Workspace (5 minutes)

#### 1.1 Create Directory Structure
```bash
cd docs/01-modules/[YOUR-MODULE]/
mkdir -p 00-ontology
cd 00-ontology
```

#### 1.2 Download Templates
```bash
# Copy templates from global templates folder
cp ../../../00-global/templates/ontology/*.yaml .
cp ../../../00-global/templates/ontology/*.md .
```

#### 1.3 Gather Requirements
- Open your user requirements document
- Have it ready to copy/paste

---

### Step 2: Extract Entities (15 minutes)

#### 2.1 Use AI to Extract Nouns

**Prompt**:
```
Analyze the following user requirements and extract all ENTITIES (nouns):

[PASTE YOUR REQUIREMENTS HERE]

For each entity, provide:
1. Name (CamelCase)
2. Brief description
3. Classification (CORE_ENTITY, VALUE_OBJECT, REFERENCE_DATA, or TRANSACTION_DATA)
4. Key attributes (3-5 main ones)

Format as a simple list.
```

#### 2.2 Review and Classify

Use this decision tree:

```
Is it a discrete event with a natural date?
├── YES → TRANSACTION_DATA
└── NO → Does it have unique identity that persists?
          ├── YES → CORE_ENTITY
          └── NO → Is it a lookup/static value?
                    ├── YES → REFERENCE_DATA
                    └── NO → VALUE_OBJECT
```

#### 2.3 Start `[module]-ontology.yaml`

Open the template and add your first entity:

```yaml
# [Module Name] Ontology
# Version: 1.0
# Created: [DATE]

entities:
  YourFirstEntity:
    description: |
      Clear description of what this entity represents.
      Why it exists in the domain.
    
    classification: CORE_ENTITY
    
    attributes:
      id:
        type: uuid
        required: true
        unique: true
        description: "Primary key"
      
      name:
        type: string
        required: true
        maxLength: 100
        description: "Entity name"
        example: "Example Name"
      
      status:
        type: enum
        values: [ACTIVE, INACTIVE]
        default: ACTIVE
        description: "Current status"
    
    relationships:
      # Add relationships later
    
    lifecycle:
      states: [DRAFT, ACTIVE, INACTIVE]
      initial_state: DRAFT
```

**Repeat for 3-5 key entities**

---

### Step 3: Define Relationships (10 minutes)

#### 3.1 Identify Connections

Ask yourself:
- Which entities reference each other?
- What's the cardinality? (1:1, 1:N, N:M)

#### 3.2 Add Relationships

```yaml
entities:
  Employee:
    # ... attributes ...
    
    relationships:
      reportsTo:
        target: Employee
        cardinality: "N:1"
        description: "Direct manager"
      
      worksIn:
        target: Department
        cardinality: "N:1"
        description: "Primary department"
```

---

### Step 4: Extract Workflows (15 minutes)

#### 4.1 Use AI to Extract Actions

**Prompt**:
```
Analyze the following user requirements and extract all WORKFLOWS (actions/processes):

[PASTE YOUR REQUIREMENTS HERE]

For each workflow, provide:
1. Name (descriptive)
2. Classification (CORE, SUPPORT, or INTEGRATION)
3. Actors involved (USER, SYSTEM, EXTERNAL)
4. Trigger (what starts it)
5. High-level steps (3-5 main steps)

Format as a simple list.
```

#### 4.2 Create `[module]-workflows.yaml`

```yaml
# [Module Name] Workflows
# Version: 1.0
# Created: [DATE]

workflows:
  YourFirstWorkflow:
    id: WF-[MODULE]-001
    name: "Human-Readable Workflow Name"
    description: |
      What this workflow accomplishes and its business value.
    
    classification: CORE
    
    actors:
      - name: "Employee"
        type: USER
        role: "Initiates the workflow"
      
      - name: "Manager"
        type: USER
        role: "Approves or rejects"
      
      - name: "System"
        type: SYSTEM
        role: "Validates and processes"
    
    trigger:
      type: USER_ACTION
      description: "Employee clicks 'Submit Request'"
    
    steps:
      - order: 1
        name: "Create Request"
        actor: "Employee"
        action: "Fills out request form"
      
      - order: 2
        name: "Validate"
        actor: "System"
        action: "Checks business rules"
      
      - order: 3
        name: "Submit"
        actor: "Employee"
        action: "Submits for approval"
      
      - order: 4
        name: "Review"
        actor: "Manager"
        action: "Reviews request details"
      
      - order: 5
        name: "Decide"
        actor: "Manager"
        action: "Approves or rejects"
    
    outcomes:
      success: "Request approved and processed"
      failure: "Request rejected with reason"
    
    related_entities:
      - YourFirstEntity
      - YourSecondEntity
```

**Repeat for 2-3 core workflows**

---

### Step 5: Create Glossary (10 minutes)

#### 5.1 Create `glossary-[submodule].md`

```markdown
# [Sub-module Name] - Glossary

**Version**: 1.0  
**Last Updated**: [DATE]  
**Module**: [Module Name]  
**Sub-module**: [Sub-module Name]

---

## Overview

[Brief description of this sub-module and its purpose]

---

## Entities

### YourFirstEntity

**Definition**: [One-sentence definition]

**Purpose**: [Why this entity exists]

**Key Characteristics**:
- [Characteristic 1]
- [Characteristic 2]
- [Characteristic 3]

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `name` | String | Yes | Entity name |
| `status` | Enum | Yes | Current status (ACTIVE, INACTIVE) |

**Relationships**:

| Relationship | Target Entity | Cardinality | Description |
|--------------|---------------|-------------|-------------|
| `reportsTo` | Employee | N:1 | Direct manager |

**Business Rules**:

1. **BR-[MODULE]-001**: [Rule description]
2. **BR-[MODULE]-002**: [Rule description]

**Examples**:

```yaml
Example 1: Active Employee
  Employee:
    id: emp-001
    name: "John Doe"
    status: ACTIVE
    reportsTo: emp-manager-001
```

**Best Practices**:
- ✅ DO: [Best practice]
- ❌ DON'T: [Anti-pattern]

---

[Repeat for each entity]
```

#### 5.2 Create `glossary-index.md`

```markdown
# Glossary Index

**Module**: [Module Name]

---

## Sub-modules

### [Sub-module 1]
- [glossary-submodule1.md](./glossary-submodule1.md)
- Entities: [Entity1], [Entity2], [Entity3]

### [Sub-module 2]
- [glossary-submodule2.md](./glossary-submodule2.md)
- Entities: [Entity4], [Entity5]

---

## Quick Reference

| Entity | Sub-module | Classification |
|--------|------------|----------------|
| [Entity1] | [Sub-module 1] | CORE_ENTITY |
| [Entity2] | [Sub-module 1] | TRANSACTION_DATA |
```

---

### Step 6: Validate (5 minutes)

#### 6.1 Run Validation Checklist

**Ontology Validation**:
- [ ] All entities have ≥2 sentence description
- [ ] All entities classified (CORE_ENTITY, VALUE_OBJECT, etc.)
- [ ] All attributes have types and descriptions
- [ ] ≥80% attributes have example values
- [ ] All relationships have cardinality
- [ ] File is valid YAML (no syntax errors)

**Workflow Validation**:
- [ ] All workflows have actors identified
- [ ] All workflows have triggers
- [ ] All workflows have 3-5 steps minimum
- [ ] All workflows linked to related entities
- [ ] File is valid YAML (no syntax errors)

**Glossary Validation**:
- [ ] All entities from ontology documented
- [ ] Each entity has definition, purpose, characteristics
- [ ] Each entity has examples
- [ ] Glossary index created

#### 6.2 YAML Validation

```bash
# Install YAML validator if needed
npm install -g yaml-validator

# Validate files
yaml-validator [module]-ontology.yaml
yaml-validator [module]-workflows.yaml
```

---

### Step 7: SME Review (Optional but Recommended)

#### 7.1 Prepare Review Package

Create a review document:

```markdown
# Ontology Review Request

**Module**: [Module Name]  
**Reviewer**: [SME Name]  
**Review Date**: [DATE]

## Files to Review
- [module]-ontology.yaml
- [module]-workflows.yaml
- glossary-[submodule].md

## Review Focus
1. Are all key entities captured?
2. Are entity descriptions accurate?
3. Are workflows complete?
4. Are actors correctly identified?

## Questions
1. [Question about entity X]
2. [Question about workflow Y]
```

#### 7.2 Incorporate Feedback

- Update ontology based on SME feedback
- Add missing entities/workflows
- Clarify descriptions

---

## Checklist: You're Done When...

- [ ] `[module]-ontology.yaml` created with 3-5 entities
- [ ] `[module]-workflows.yaml` created with 2-3 workflows
- [ ] `glossary-[submodule].md` created for each sub-module
- [ ] `glossary-index.md` created
- [ ] All files validated (YAML syntax)
- [ ] SME review completed (optional)
- [ ] No unresolved ambiguities

---

## Common Issues & Solutions

### Issue 1: Too Many Entities
**Symptom**: Extracted 50+ entities  
**Solution**: Focus on core entities first (5-10), add others later

### Issue 2: Unclear Classification
**Symptom**: Can't decide if CORE_ENTITY or VALUE_OBJECT  
**Solution**: Ask "Does it have identity?" If yes → CORE_ENTITY

### Issue 3: Complex Relationships
**Symptom**: Many-to-many relationships everywhere  
**Solution**: Start simple (1:N), add complexity later

### Issue 4: Workflow vs Entity Confusion
**Symptom**: "Is 'Approval' an entity or workflow?"  
**Solution**: If it's an action → Workflow. If it's a thing → Entity

---

## Next Steps

✅ **Ontology Complete**

Now proceed to:
- [Concept Quick Start](./CONCEPT-QUICK-START.md) - Group entities into contexts
- Or return to [Methodology](./ONTOLOGY-CONCEPT-SPEC-METHODOLOGY.md)

---

## Example: Leave Management

See complete example at: `docs/00-global/examples/leave-management/01-ontology/`

---

**Questions?** Review the full [Ontology Methodology](./ONTOLOGY-CONCEPT-SPEC-METHODOLOGY.md#4-layer-1-ontology)
