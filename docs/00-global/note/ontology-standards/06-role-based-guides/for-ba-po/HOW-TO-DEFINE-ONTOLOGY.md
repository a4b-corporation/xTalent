# BA/PO Guide: How to Define Ontology

**Version**: 1.0  
**Last Updated**: 2025-12-25  
**Audience**: Business Analysts, Product Owners  
**Time to Read**: 15 minutes

---

## 🎯 Your Role in Ontology

As a BA/PO, you are the **bridge between business knowledge and technical implementation**. Your primary responsibilities:

1. **Identify** what business concepts need to be modeled
2. **Define** clear business definitions for each entity
3. **Validate** that technical models accurately represent business reality
4. **Maintain** the glossary and business rules

---

## 📋 The 5-Step Process

### Step 1: Identify Business Concepts

Start with questions:
- What are the key "things" in this business domain?
- What do business users talk about daily?
- What appears in reports and dashboards?

**Example from Core HR**:
```
Business conversations mention:
- "We hired 5 new employees last month"
- "John was promoted to Senior Developer"
- "The Sales department has 20 open positions"

Key concepts identified:
→ Employee
→ Position  
→ Department
→ Promotion (this is a PROCESS, not an entity!)
```

> ⚠️ **Important**: Not everything is an entity! See [WHAT-IS-NOT-ONTOLOGY.md](../../00-getting-started/WHAT-IS-NOT-ONTOLOGY.md)

---

### Step 2: Write Business Definitions

For each concept, write a **clear, jargon-free definition**.

**Good Definition**:
> "Employee: A person who has an active employment relationship with the organization, receiving compensation in exchange for services rendered."

**Bad Definition**:
> "Employee: A row in the employee table with employee_id as primary key."

**Definition Checklist**:
- [ ] Would a new hire understand this?
- [ ] Does it describe WHAT it is, not HOW it's stored?
- [ ] Does it distinguish this from similar concepts?
- [ ] Is it consistent with industry terminology?

---

### Step 3: Identify Relationships

Map how concepts connect:

```
Employee ──────────> Position
          "holds"
          
Position ──────────> Department
          "belongs to"
          
Employee ──────────> Contract
          "has"          (1:N - one employee, many contracts over time)
```

**Questions to ask**:
- Can an Employee exist without a Position?
- Can one Employee have multiple Contracts?
- What happens to Assignments when a Position is deleted?

---

### Step 4: Define Lifecycle States

For key entities, map their lifecycle:

```
Employee Lifecycle:
DRAFT → ACTIVE → SUSPENDED → TERMINATED
                    ↑
                    └── ACTIVE (can return from suspension)

Questions:
- What triggers each state change?
- Who can change states?
- What business rules apply at each state?
```

---

### Step 5: Document Business Rules

Capture the rules that govern the entity:

```yaml
# Example: Employee Business Rules

BR-EMP-001:
  description: "Employee code must be unique across the organization"
  applies_to: Employee.employee_code

BR-EMP-002:
  description: "Hire date cannot be in the future"
  applies_to: Employee.hire_date
  condition: "hire_date <= today()"

BR-EMP-003:
  description: "Active employee must have at least one active assignment"
  applies_to: Employee
  condition: "status = ACTIVE implies assignments.any(a => a.status = ACTIVE)"
```

---

## 🚫 Common Mistakes to Avoid

### Mistake 1: Modeling Processes as Entities
```
❌ WRONG: Creating "HiringProcess" as an entity
✅ RIGHT: Creating "Employee" entity + "Hire Employee" workflow
```

### Mistake 2: Confusing Transactions with Entities
```
❌ WRONG: "PayrollRun" as an entity (it's a transaction/event)
✅ RIGHT: "PayElement" (what CAN be paid) as entity
          "PayResult" as transaction record
```

### Mistake 3: Overly Technical Definitions
```
❌ WRONG: "Employee is the master record linked via FK to..."
✅ RIGHT: "Employee is a person employed by the organization..."
```

### Mistake 4: Missing the "Why"
```
❌ WRONG: "hire_date: The date of hiring"
✅ RIGHT: "hire_date: The official start date of employment, 
          used for seniority calculations and benefits eligibility"
```

---

## 📝 Templates You'll Use

### Entity Request Template
```markdown
## Entity Request: [Name]

### Business Need
[Why do we need to model this?]

### Definition
[Clear business definition]

### Key Attributes
- attribute_1: [definition]
- attribute_2: [definition]

### Relationships
- Relates to [Entity A]: [how]
- Relates to [Entity B]: [how]

### Lifecycle (if applicable)
[States and transitions]

### Business Rules
- [Rule 1]
- [Rule 2]

### Examples
- [Example instance 1]
- [Example instance 2]
```

---

## 🔄 Working with Developers

### What You Provide
- Clear business definitions
- Business rules in plain language
- Example data
- Edge cases and exceptions

### What Developers Provide
- Technical schema (YAML)
- Validation implementation
- API design

### Collaboration Points
1. **Definition Review**: You validate that technical model matches business intent
2. **Rule Implementation**: You verify business rules are correctly implemented
3. **Testing**: You provide acceptance criteria for BDD scenarios

---

## ✅ Your Checklist Before Handoff

Before handing off to developers:

- [ ] Definition is clear and reviewed by SME
- [ ] All key attributes are identified with business meaning
- [ ] Relationships are mapped with cardinality
- [ ] Lifecycle states are defined (if applicable)
- [ ] Major business rules are documented
- [ ] At least 3 example instances are provided
- [ ] Edge cases and exceptions are noted

---

## 🔗 Related Documents

- [WHAT-IS-NOT-ONTOLOGY.md](../../00-getting-started/WHAT-IS-NOT-ONTOLOGY.md) — What NOT to model as ontology
- [FOUR-MODEL-COMPARISON.md](../../01-core-principles/FOUR-MODEL-COMPARISON.md) — Understanding model types
- [GLOSSARY-SCHEMA.md](../../03-schemas/GLOSSARY-SCHEMA.md) — How to write glossary terms
- [BUSINESS-RULES.md](../../03-schemas/BUSINESS-RULES.md) — Business rules format
