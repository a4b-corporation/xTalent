# Specification Quick Start Guide

**Time Required**: 1 hour  
**Prerequisites**: Completed concept layer  
**Output**: Complete specification layer documentation

---

## What You'll Create

By the end of this guide, you'll have:
- ✅ `01-functional-requirements.md` - All FRs
- ✅ `04-business-rules.md` - All BRs
- ✅ `03-scenarios/[workflow].md` - First use case
- ✅ `FEATURE-LIST.yaml` - Feature breakdown

---

## Step-by-Step Process

### Step 1: Prepare Your Workspace (5 minutes)

#### 1.1 Create Directory Structure
```bash
cd docs/01-modules/[YOUR-MODULE]/
mkdir -p 02-spec/03-scenarios
cd 02-spec
```

#### 1.2 Download Templates
```bash
# Copy templates
cp ../../../00-global/templates/spec/*.md .
cp ../../../00-global/templates/spec/*.yaml .
```

#### 1.3 Review Concept Layer
- Open `../01-concept/02-conceptual-guide.md`
- Have workflows ready for reference

---

### Step 2: Write Functional Requirements (20 minutes)

#### 2.1 Use AI to Generate FRs

**Prompt**:
```
Based on the following entities and workflows:

ENTITIES:
[PASTE from ontology]

WORKFLOWS:
[PASTE from workflows.yaml]

Generate Functional Requirements in this format:

For each entity, create:
1. FR-[MODULE]-NNN: Create [Entity]
2. FR-[MODULE]-NNN: Read [Entity]
3. FR-[MODULE]-NNN: Update [Entity]
4. FR-[MODULE]-NNN: Delete [Entity]
5. FR-[MODULE]-NNN: List [Entity]

For each workflow, create:
6. FR-[MODULE]-NNN: [Workflow Action]

Each FR must include:
- Priority (HIGH/MEDIUM/LOW)
- User Story (As a... I want... So that...)
- Acceptance Criteria (Given/When/Then)
- Related Business Rules
- API Endpoint
```

#### 2.2 Edit `01-functional-requirements.md`

```markdown
# [Module Name] - Functional Requirements

**Version**: 1.0  
**Last Updated**: [DATE]  
**Module**: [Module Name]

---

## Overview

[Module description and scope]

---

## Feature Areas

### 1. [Entity] Management

#### FR-[MODULE]-001: Create [Entity]

**Priority**: HIGH

**User Story**:
```
As a [role]
I want to create a new [entity]
So that [business value]
```

**Description**:
[Detailed requirement description]

**Acceptance Criteria**:
- Given [context]
- When [action]
- Then [expected result]
- And [additional result]

**Business Rules**:
- BR-[MODULE]-001: [Rule reference]
- BR-[MODULE]-002: [Rule reference]

**Related Entities**:
- [Entity1]
- [Entity2]

**API Endpoint**:
- `POST /api/v1/[entities]`

---

#### FR-[MODULE]-002: [Next Requirement]

[Same structure]

---

[Repeat for all entities and workflows]

---

## Requirements Summary

| ID | Title | Priority | Status |
|----|-------|----------|--------|
| FR-[MODULE]-001 | Create [Entity] | HIGH | ✅ Defined |
| FR-[MODULE]-002 | Read [Entity] | HIGH | ✅ Defined |

---

**Total Requirements**: [Number]  
**High Priority**: [Number]  
**Medium Priority**: [Number]
```

---

### Step 3: Write Business Rules (15 minutes)

#### 3.1 Extract Rules from Concepts

Review your concept guides and extract all business rules mentioned.

#### 3.2 Use AI to Format Rules

**Prompt**:
```
Based on the following concept documentation:

[PASTE from conceptual-guide.md]

Extract all business rules and format as:

BR-[MODULE]-NNN: [Rule Title]
- Category: VALIDATION | CALCULATION | AUTHORIZATION | CONSTRAINT
- Description: [Clear description]
- Condition: IF [condition] THEN [action]
- Error Code: ERR_[MODULE]_NNN
- Error Message: "[User-friendly message]"
- Examples: Valid and Invalid cases
```

#### 3.3 Edit `04-business-rules.md`

```markdown
# [Module Name] - Business Rules

**Version**: 1.0  
**Last Updated**: [DATE]

---

## Overview

[Description of business rules in this module]

---

## Business Rules Catalog

### Category: Validation

#### BR-[MODULE]-001: [Rule Title]

**Priority**: HIGH

**Description**:
[Detailed rule description]

**Conditions**:
```
IF [condition 1]
AND [condition 2]
THEN [action]
```

**Rules**:
1. [Rule detail 1]
2. [Rule detail 2]

**Exceptions**:
- [Exception 1]
- [Exception 2]

**Error Messages**:
- `ERR_[MODULE]_001`: "[Error message]"

**Examples**:

```yaml
Example 1: Valid Case
  Input:
    [field]: [value]
  
  Validation:
    BR-[MODULE]-001: PASS
  
  Output:
    [result]

Example 2: Invalid Case
  Input:
    [field]: [invalid value]
  
  Validation:
    BR-[MODULE]-001: FAIL
  
  Error:
    code: ERR_[MODULE]_001
    message: "[Error message]"
```

**Related Requirements**:
- FR-[MODULE]-001
- FR-[MODULE]-002

**Related Entities**:
- [Entity1]
- [Entity2]

---

[Repeat for all business rules]

---

## Business Rules Summary

| ID | Title | Category | Priority |
|----|-------|----------|----------|
| BR-[MODULE]-001 | [Title] | Validation | HIGH |

---

**Total Rules**: [Number]
```

---

### Step 4: Write First Use Case (15 minutes)

#### 4.1 Choose a Core Workflow

Pick the most important workflow from your conceptual guide.

#### 4.2 Create `03-scenarios/[workflow-name].md`

```markdown
# Use Case: [Workflow Name]

**ID**: UC-[MODULE]-001  
**Priority**: HIGH  
**Complexity**: MEDIUM  
**Related Workflow**: WF-[MODULE]-001

---

## Metadata

- **Module**: [Module Name]
- **Sub-module**: [Sub-module]
- **Version**: 1.0
- **Last Updated**: [DATE]

---

## Actors

- **Primary**: [Actor]
- **Secondary**: [Actor]
- **System**: Automated processing

---

## Preconditions

- [Condition 1]
- [Condition 2]
- [Condition 3]

---

## Triggers

**Type**: USER_ACTION  
**Description**: [What initiates this use case]

---

## Main Success Scenario

### Step 1: [Step Name]
**Actor**: [Actor]  
**Action**: [What actor does]  
**System**: [What system does]  
**Business Rules**: BR-[MODULE]-001, BR-[MODULE]-002

### Step 2: [Step Name]
**Actor**: [Actor]  
**Action**: [What actor does]  
**System**: [What system does]  
**Validation**:
- Check [condition]
- Verify [condition]

### Step 3: [Step Name]
**Actor**: [Actor]  
**Action**: [What actor does]  
**System**: [What system does]  
**Result**: [What happens]

[Continue for all steps]

---

## Alternative Flows

### AF1: [Alternative Flow Name]

**At Step**: [N]  
**Condition**: [When this flow applies]  
**Flow**:
1. [Alternative step 1]
2. [Alternative step 2]
3. Return to main flow at Step [N]

---

## Exception Flows

### EF1: [Exception Name]

**Condition**: [Error condition]  
**Handling**:
1. System logs error
2. System displays: "[Error message]"
3. Actor can [recovery action]

---

## Postconditions

### Success
- [Outcome 1]
- [Outcome 2]
- [Outcome 3]

### Failure
- No data changed
- Error logged
- User informed

---

## API Sequence

```
1. POST /api/v1/[resource]
   Request: { [data] }
   Response: 201 Created

2. PUT /api/v1/[resource]/{id}
   Request: { [data] }
   Response: 200 OK

3. GET /api/v1/[notifications]
   Response: 200 OK
```

---

## Business Rules Applied

- BR-[MODULE]-001: [Rule description]
- BR-[MODULE]-002: [Rule description]
- BR-[MODULE]-003: [Rule description]

---

## Test Scenarios

- TS-001: Happy path with valid data
- TS-002: [Error condition] validation
- TS-003: [Alternative flow] handling
- TS-004: Boundary testing

---

## Related Documents

- [Conceptual Guide](../../01-concept/02-conceptual-guide.md)
- [Functional Requirements](../01-functional-requirements.md)
- [Business Rules](../04-business-rules.md)
```

---

### Step 5: Create Feature List (5 minutes)

#### 5.1 Edit `FEATURE-LIST.yaml`

```yaml
# [Module Name] - Feature List
# Version: 1.0
# Last Updated: [DATE]

module:
  code: [MODULE-CODE]
  name: "[Module Name]"

features:
  # Feature 1
  - id: "001"
    name: "[entity]-management"
    title: "[Entity] Management"
    priority: HIGH
    epic: "[Epic Name]"
    
    sources:
      concept_guides:
        - "01-concept/02-conceptual-guide.md"
      
      functional_requirements:
        - "FR-[MODULE]-001 to FR-[MODULE]-005"
      
      business_rules:
        - "BR-[MODULE]-001 to BR-[MODULE]-003"
      
      entities:
        - "[Entity1]"
        - "[Entity2]"
      
      apis:
        - "POST /api/v1/[entities]"
        - "GET /api/v1/[entities]/{id}"
        - "PUT /api/v1/[entities]/{id}"
        - "DELETE /api/v1/[entities]/{id}"
    
    spec_kit_outputs:
      - "spec.md"
      - "data-model.md"
      - "contracts/api-spec.yaml"
    
    status: "PLANNED"
    estimated_effort: "[Story points]"
  
  # Feature 2
  - id: "002"
    name: "[workflow]-process"
    title: "[Workflow] Process"
    priority: HIGH
    epic: "[Epic Name]"
    
    sources:
      concept_guides:
        - "01-concept/02-conceptual-guide.md"
      
      functional_requirements:
        - "FR-[MODULE]-006 to FR-[MODULE]-010"
      
      business_rules:
        - "BR-[MODULE]-004 to BR-[MODULE]-008"
      
      workflows:
        - "WF-[MODULE]-001"
      
      use_cases:
        - "UC-[MODULE]-001"
    
    status: "PLANNED"
    estimated_effort: "[Story points]"

# Feature Summary
summary:
  total_features: 2
  by_priority:
    HIGH: 2
    MEDIUM: 0
    LOW: 0
  by_status:
    PLANNED: 2
    IN_PROGRESS: 0
    COMPLETED: 0
```

---

### Step 6: Validate (5 minutes)

#### 6.1 Run Validation Checklist

**Spec Validation**:
- [ ] All FRs have acceptance criteria
- [ ] All BRs have examples
- [ ] At least 1 use case created
- [ ] Feature list created
- [ ] All FRs trace to entities/workflows
- [ ] All BRs trace to concepts

**Quality Check**:
- [ ] Each FR is testable
- [ ] Each BR has error message
- [ ] Use case has all flows (main, alt, exception)
- [ ] API endpoints documented

---

## Checklist: You're Done When...

- [ ] `01-functional-requirements.md` created
- [ ] `04-business-rules.md` created
- [ ] `03-scenarios/[workflow].md` created (first use case)
- [ ] `FEATURE-LIST.yaml` created
- [ ] All requirements traceable to concepts
- [ ] Technical review completed (optional)

---

## Common Issues & Solutions

### Issue 1: Too Many FRs
**Symptom**: 100+ requirements  
**Solution**: Group related FRs, focus on core features first

### Issue 2: Vague Acceptance Criteria
**Symptom**: "System should work correctly"  
**Solution**: Use Given/When/Then format with specific values

### Issue 3: Missing Error Cases
**Symptom**: Only happy path documented  
**Solution**: Add alternative and exception flows

---

## Next Steps

✅ **Specification Complete**

Now you can:
- Create remaining use cases (1 per core workflow)
- Create API specification (`02-api-specification.md`)
- Create data specification (`03-data-specification.md`)
- Create integration guide (`INTEGRATION-GUIDE.md`)

Or proceed to implementation handoff!

---

## Example: Leave Management

See complete example at: `docs/00-global/examples/leave-management/03-spec/`

---

**Questions?** Review the full [Spec Methodology](./ONTOLOGY-CONCEPT-SPEC-METHODOLOGY.md#6-layer-3-specification)
