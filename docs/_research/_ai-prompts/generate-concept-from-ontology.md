# Generate Concept Documents from Ontology

## Purpose
This prompt helps AI generate comprehensive concept documentation from ontology definitions.

## Context
You are an AI assistant helping to create concept-level documentation for an HCM system. You will be given an ontology file (YAML) that defines domain entities, and you need to generate concept documents that explain these entities in business terms.

---

## Prompt Template

```
You are a business analyst creating concept documentation for the xTalent HCM system.

I will provide you with an ontology file that defines domain entities, their attributes, relationships, and rules.

Your task is to generate the following concept documents:

1. **Concept Overview** (01-concept-overview.md)
   - Explain what this module/feature is
   - Describe the business problem it solves
   - Outline the high-level solution
   - Define scope (what's included and what's not)
   - List key concepts
   - Explain business value
   - Identify integration points

2. **Conceptual Guide** (02-conceptual-guide.md)
   - Explain how the system works at a high level
   - Describe key workflows and processes
   - Explain domain behaviors
   - Show how entities interact
   - Provide examples and scenarios

3. **Entity Concept Guides** (one file per entity in 03-concept-entity-guides/)
   - Explain the purpose of each entity
   - Describe its lifecycle
   - Explain business rules and why they exist
   - Show relationships with other entities
   - Provide real-world examples

Guidelines:
- Write for a business audience (PO, BA, non-technical stakeholders)
- Use clear, simple language - no technical jargon
- Focus on WHAT and WHY, not HOW (implementation)
- Use examples to illustrate concepts
- Explain the business rationale behind rules
- Show how concepts relate to real-world scenarios

Here is the ontology file:

[PASTE ONTOLOGY YAML HERE]

Please generate the concept documents following the templates in /_templates/.
```

---

## Example Usage

### Input
```yaml
# leave-management-ontology.yaml
entities:
  LeaveType:
    description: "Type of leave available to employees"
    attributes:
      - code: string
      - name: string
      - isPaid: boolean
      - maxDaysPerYear: integer
    rules:
      - "maxDaysPerYear must be > 0 if set"
```

### Expected Output

**01-concept-overview.md**:
```markdown
# Leave Management - Concept Overview

## What is this module?
The Leave Management module enables employees to request time off,
managers to approve requests, and HR to track leave balances...

[etc.]
```

**03-concept-entity-guides/leave-type.md**:
```markdown
# LeaveType - Entity Concept

## Purpose
LeaveType defines the different categories of leave available to 
employees, such as Annual Leave, Sick Leave, or Unpaid Leave.

## Why do we need this?
Different types of leave have different rules:
- Annual leave is typically paid and limited per year
- Sick leave may not require advance approval
- Unpaid leave doesn't affect leave balance

[etc.]
```

---

## Variations

### For a Single Entity
```
Generate a concept guide for the {EntityName} entity based on this ontology:

[PASTE ENTITY DEFINITION]

Explain:
1. What is this entity?
2. Why does it exist?
3. How does it work in the business context?
4. What are the key business rules and why?
5. How does it relate to other entities?
6. Provide 2-3 real-world examples
```

### For Workflows
```
Based on this ontology, explain the workflow for {ProcessName}:

[PASTE RELEVANT ENTITIES]

Describe:
1. Who are the actors?
2. What triggers the workflow?
3. What are the steps?
4. What are the decision points?
5. What are the outcomes?
6. What are common variations?
```

---

## Tips for Better Results

### DO ✅
- Provide complete ontology with all entities, relationships, and rules
- Specify the target audience (PO, BA, developers, etc.)
- Ask for specific sections if you don't need everything
- Request examples and scenarios
- Ask for diagrams (Mermaid) if helpful

### DON'T ❌
- Expect AI to invent business rules not in the ontology
- Ask for implementation details (that's for spec layer)
- Provide incomplete ontology and expect complete docs
- Mix concept and specification concerns

---

## Follow-up Prompts

After initial generation, you can refine:

```
"The concept overview is too technical. Rewrite it for a non-technical 
business audience."

"Add more real-world examples to the LeaveType entity guide."

"Expand the workflow explanation with a Mermaid sequence diagram."

"The business value section is too generic. Make it specific to 
leave management with concrete metrics."
```

---

## Quality Checklist

Generated concept docs should:
- [ ] Be understandable by non-technical stakeholders
- [ ] Explain WHY, not just WHAT
- [ ] Include concrete examples
- [ ] Show business value clearly
- [ ] Avoid implementation details
- [ ] Use consistent terminology from glossary
- [ ] Reference related documents
- [ ] Include diagrams where helpful

---

## Related Prompts
- [Generate API from Ontology](./generate-api-from-ontology.md)
- [Generate UI from Spec](./generate-ui-from-spec.md)
- [Generate Tests from Scenarios](./generate-tests-from-scenarios.md)
