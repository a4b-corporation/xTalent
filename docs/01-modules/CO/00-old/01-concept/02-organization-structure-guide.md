# Organization Structure Guide

**Version**: 2.0  
**Last Updated**: 2025-12-02  
**Audience**: Business Users, HR Administrators, Managers  
**Reading Time**: 40-50 minutes

---

## 📋 Overview

This guide explains how organizational structures are modeled in xTalent Core Module, with a focus on the revolutionary **Operational vs Supervisory Organization** concept that solves real-world organizational complexity.

### What You'll Learn
- The difference between operational and supervisory organizations
- Why traditional single-hierarchy models fail
- How to model complex organizational structures
- Real-world scenarios and best practices

### Prerequisites
- Basic understanding of organizational hierarchies
- Familiarity with reporting relationships
- Understanding of business units and departments

---

## 🎯 The Problem with Traditional Org Charts

### Traditional Approach (Single Hierarchy)

Most organizations use a single org chart that tries to represent:
- **How work is organized** (teams, departments, divisions)
- **Who reports to whom** (reporting relationships)
- **Budget ownership** (cost centers)
- **Security permissions** (data access)

**The Problem**: These are DIFFERENT concerns that don't always align!

### Real-World Example: Global Tech Company

```
Traditional Org Chart (Trying to do everything):

Engineering Division
  ├─ Backend Team (Vietnam)
  │   Manager: Alice
  │   Members: 10 engineers
  │
  ├─ Frontend Team (Vietnam)
  │   Manager: Bob
  │   Members: 8 engineers
  │
  ├─ Mobile Team (Singapore)
  │   Manager: Carol
  │   Members: 6 engineers
  │
  └─ DevOps Team (Singapore)
      Manager: David
      Members: 5 engineers
```

**Problems**:

❌ **Problem 1**: Alice manages both Backend AND Frontend teams  
→ Can't show this in single hierarchy

❌ **Problem 2**: VP Engineering APAC oversees Vietnam + Singapore  
→ Geographic management doesn't match team structure

❌ **Problem 3**: Project Alpha needs engineers from all teams  
→ Project reporting doesn't fit in functional hierarchy

❌ **Problem 4**: Approval workflows follow management chain, not team structure  
→ Leave approvals go to geographic manager, not team lead

---

## ✨ The xTalent Solution: Dual Structure

### Separate Operational and Supervisory Organizations

```
┌─────────────────────────────────────────────────────┐
│ OPERATIONAL STRUCTURE                               │
│ "How is work organized?"                            │
│                                                      │
│ Engineering Division                                │
│   ├─ Backend Team                                   │
│   ├─ Frontend Team                                  │
│   ├─ Mobile Team                                    │
│   └─ DevOps Team                                    │
│                                                      │
│ Purpose: Team organization, project assignment      │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ SUPERVISORY STRUCTURE                               │
│ "Who reports to whom for approvals/reviews?"        │
│                                                      │
│ VP Engineering (Supervisory Org)                    │
│   ├─ Engineering Manager APAC (Supervisory Org)     │
│   │   ├─ Backend Team members                       │
│   │   └─ Frontend Team members                      │
│   └─ Engineering Manager Singapore (Supervisory Org)│
│       ├─ Mobile Team members                        │
│       └─ DevOps Team members                        │
│                                                      │
│ Purpose: Reporting, approvals, performance reviews  │
└─────────────────────────────────────────────────────┘
```

**Key Insight**: Same people, two different organizational views!

---

## 📊 Understanding Operational Structure

### What is Operational Structure?

**Definition**: How work is organized into teams, departments, and divisions.

**Purpose**:
- ✅ Organize work by function, product, or project
- ✅ Define team membership
- ✅ Allocate resources
- ✅ Track project assignments

**Characteristics**:
- More **stable** (changes infrequently)
- Reflects **work organization**
- Used for **team collaboration**
- Visible in **org charts**

### Operational Unit Types

| Type | Level | Description | Example |
|------|-------|-------------|---------|
| **DIVISION** | 1 | Top-level business division | Engineering, Sales, Operations |
| **DEPARTMENT** | 2 | Department within division | Backend Engineering, Enterprise Sales |
| **TEAM** | 3 | Work team | API Team, Mobile Team |
| **PROJECT** | 3 | Temporary project team | Project Alpha Team |
| **COST_CENTER** | Varies | Cost accounting unit | CC-ENG-1000 |

### Example: Engineering Division

```yaml
# Operational Structure
Units:
  - code: ENG
    name: "Engineering Division"
    type: DIVISION
    level: 1
    
  - code: ENG-BACKEND
    name: "Backend Engineering Department"
    type: DEPARTMENT
    parent: ENG
    level: 2
    
  - code: ENG-BACKEND-API
    name: "API Team"
    type: TEAM
    parent: ENG-BACKEND
    level: 3
    members: 10
    
  - code: ENG-BACKEND-DATA
    name: "Data Team"
    type: TEAM
    parent: ENG-BACKEND
    level: 3
    members: 8
```

### When to Use Operational Structure

✅ **Use for**:
- Team organization charts
- Project resource allocation
- Work assignment
- Collaboration tools (Slack channels, etc.)
- Product/feature ownership

❌ **Don't use for**:
- Approval workflows
- Performance reviews
- Data access control
- Compensation decisions

---

## 📊 Understanding Supervisory Structure

### What is Supervisory Structure?

**Definition**: Who reports to whom for approvals, performance reviews, and career development.

**Purpose**:
- ✅ Define reporting relationships
- ✅ Approval workflows (leave, expenses, hiring)
- ✅ Performance management
- ✅ Career development
- ✅ Data access control

**Characteristics**:
- More **dynamic** (changes more frequently)
- Reflects **management hierarchy**
- Used for **approvals and reviews**
- May differ from operational structure

### Supervisory Organization Type

```yaml
UnitType:
  code: SUPERVISORY
  name: "Supervisory Organization"
  is_supervisory: true
  level_order: null  # Can exist at any level
  
  metadata:
    purpose: "Reporting and approval hierarchy"
    affects_security: true
    affects_approvals: true
    approval_authority_levels:
      EXPENSE_APPROVAL: 10000
      LEAVE_APPROVAL: true
      HIRE_APPROVAL: true
```

### Example: Engineering Supervisory Structure

```yaml
# Supervisory Structure (parallel to operational)
Units:
  - code: SUP-VP-ENG
    name: "VP Engineering Supervisory Org"
    type: SUPERVISORY
    is_supervisory: true
    manager: VP-Engineering
    
  - code: SUP-MGR-APAC
    name: "Engineering Manager APAC"
    type: SUPERVISORY
    parent: SUP-VP-ENG
    is_supervisory: true
    manager: MGR-APAC
    members:
      - Backend Team (Vietnam)
      - Frontend Team (Vietnam)
    
  - code: SUP-MGR-SG
    name: "Engineering Manager Singapore"
    type: SUPERVISORY
    parent: SUP-VP-ENG
    is_supervisory: true
    manager: MGR-SG
    members:
      - Mobile Team (Singapore)
      - DevOps Team (Singapore)
```

### When to Use Supervisory Structure

✅ **Use for**:
- Approval workflows
- Performance reviews
- Compensation decisions
- Career development
- Data access permissions
- Manager-employee relationships

❌ **Don't use for**:
- Day-to-day work organization
- Project assignments
- Team collaboration

---

## 🔄 How They Work Together

### Dual Membership

**Key Concept**: An employee belongs to BOTH structures simultaneously.

```yaml
Employee: John (Backend Engineer)
  
  # Operational Assignment
  Operational:
    business_unit: Backend Team (ENG-BACKEND-API)
    purpose: "Day-to-day work, team collaboration"
    
  # Supervisory Assignment
  Supervisory:
    supervisory_org: Engineering Manager APAC (SUP-MGR-APAC)
    manager: Alice (MGR-APAC)
    purpose: "Approvals, performance reviews"
```

### Real-World Scenario

**Scenario**: John is a Backend Engineer in Vietnam

#### Operational Structure (Work Organization)
```
John's Operational Unit: Backend Team
  ├─ Team Lead: Bob (technical lead)
  ├─ Team Members: 10 engineers
  ├─ Daily Standups: With Backend Team
  ├─ Sprint Planning: With Backend Team
  └─ Code Reviews: Within Backend Team
```

#### Supervisory Structure (Reporting)
```
John's Supervisory Org: Engineering Manager APAC
  ├─ Manager: Alice (people manager)
  ├─ Peers: Backend + Frontend engineers (Vietnam)
  ├─ Performance Review: By Alice
  ├─ Leave Approval: By Alice
  └─ Compensation: Decided by Alice
```

### Approval Flow Example

**John requests annual leave**:

```yaml
Leave Request:
  employee: John
  dates: 2024-12-20 to 2024-12-27
  
Approval Chain (follows SUPERVISORY structure):
  Step 1: Direct Manager (Alice - Engineering Manager APAC)
    → Approves/Rejects
  
  Step 2: Skip Level (VP Engineering)
    → Final approval for long leave
  
# NOT based on operational team structure!
# Bob (team lead) is NOT in approval chain
```

### Data Access Example

**Alice (Engineering Manager APAC) can access**:

```yaml
Data Access (based on SUPERVISORY structure):
  Can view:
    - All Backend Team members (Vietnam)
    - All Frontend Team members (Vietnam)
    - Performance data, compensation, personal info
    
  Cannot view:
    - Mobile Team members (different supervisory org)
    - DevOps Team members (different supervisory org)
```

---

## 🏗️ Implementation Patterns

### Pattern 1: Parallel Structures (Recommended)

**When to use**: Large organizations with complex reporting

```yaml
# Operational Structure
Operational:
  Engineering Division
    ├─ Backend Team (Vietnam)
    ├─ Frontend Team (Vietnam)
    ├─ Mobile Team (Singapore)
    └─ DevOps Team (Singapore)

# Supervisory Structure (completely separate)
Supervisory:
  VP Engineering
    ├─ Engineering Manager APAC
    │   ├─ Backend Team members
    │   └─ Frontend Team members
    └─ Engineering Manager Singapore
        ├─ Mobile Team members
        └─ DevOps Team members
```

**Benefits**:
- ✅ Clear separation of concerns
- ✅ Easy to understand
- ✅ Flexible reorganization
- ✅ Supports matrix organizations

**Implementation**:
```yaml
# Operational units
Unit:
  code: ENG-BACKEND
  type: DEPARTMENT
  is_supervisory: false

# Supervisory units
Unit:
  code: SUP-MGR-APAC
  type: SUPERVISORY
  is_supervisory: true

# Employee assignment
Assignment:
  business_unit_id: ENG-BACKEND  # Operational
  supervisory_org_id: SUP-MGR-APAC  # Supervisory (custom field)
```

---

### Pattern 2: Hybrid Approach

**When to use**: Medium organizations, simpler structure

```yaml
# Some units are BOTH operational AND supervisory
Unit:
  code: ENG
  name: "Engineering Division"
  type: DIVISION
  is_operational: true
  is_supervisory: true
  manager: VP-Engineering
  
  # Acts as both:
  # - Operational: Organizes engineering work
  # - Supervisory: VP Engineering's supervisory org
```

**Benefits**:
- ✅ Simpler to maintain
- ✅ Less duplication
- ✅ Works for traditional hierarchies

**Drawbacks**:
- ⚠️ Less flexible
- ⚠️ Harder to support matrix organizations

---

### Pattern 3: Geographic Matrix

**When to use**: Global organizations with geographic management

```yaml
# Operational: By Function
Operational:
  Engineering
    ├─ Backend Engineering
    ├─ Frontend Engineering
    └─ Mobile Engineering

# Supervisory: By Geography
Supervisory:
  Global Engineering
    ├─ APAC Engineering
    │   ├─ Vietnam Engineering Manager
    │   └─ Singapore Engineering Manager
    ├─ EMEA Engineering
    └─ Americas Engineering
```

**Example**:
```yaml
Employee: John (Backend Engineer, Vietnam)
  Operational: Backend Engineering (functional)
  Supervisory: Vietnam Engineering Manager (geographic)
  
  # Functional expertise: Backend team
  # Management/approvals: Vietnam manager
```

---

### Pattern 4: Product Matrix

**When to use**: Product-focused organizations

```yaml
# Operational: By Product
Operational:
  Product A Team
  Product B Team
  Product C Team

# Supervisory: By Function
Supervisory:
  Engineering Managers
    ├─ Backend Engineering Manager
    ├─ Frontend Engineering Manager
    └─ Mobile Engineering Manager
```

**Example**:
```yaml
Employee: Jane (Backend Engineer on Product A)
  Operational: Product A Team (product focus)
  Supervisory: Backend Engineering Manager (functional)
  
  # Day-to-day: Product A team
  # Career development: Backend engineering path
```

---

## 📈 Real-World Examples

### Example 1: Traditional Company (Simple)

**Company**: Local software company, 50 employees

**Structure**: Operational = Supervisory (same hierarchy)

```yaml
Company
  ├─ Engineering (Manager: Alice)
  │   ├─ Backend Team (Lead: Bob)
  │   └─ Frontend Team (Lead: Carol)
  └─ Sales (Manager: David)
      ├─ Enterprise Sales (Lead: Eve)
      └─ SMB Sales (Lead: Frank)

# Same structure for both operational and supervisory
# Simple, traditional hierarchy
```

**Implementation**:
```yaml
# Single hierarchy serves both purposes
Unit:
  code: ENG
  type: DIVISION
  manager: Alice
  # Used for both work organization AND reporting
```

---

### Example 2: Global Tech Company (Complex)

**Company**: Global tech company, 500+ employees, 3 regions

**Structure**: Separate operational and supervisory

#### Operational Structure (By Function)
```yaml
Engineering
  ├─ Backend Engineering
  │   ├─ API Team
  │   ├─ Database Team
  │   └─ Integration Team
  ├─ Frontend Engineering
  │   ├─ Web Team
  │   └─ Mobile Team
  └─ Platform Engineering
      ├─ DevOps Team
      └─ Infrastructure Team
```

#### Supervisory Structure (By Geography)
```yaml
Global Engineering Leadership
  ├─ APAC Engineering
  │   ├─ Vietnam Engineering Manager
  │   │   ├─ Backend engineers (Vietnam)
  │   │   ├─ Frontend engineers (Vietnam)
  │   │   └─ Platform engineers (Vietnam)
  │   └─ Singapore Engineering Manager
  │       └─ All engineers (Singapore)
  ├─ EMEA Engineering
  └─ Americas Engineering
```

**Why This Works**:
- ✅ Engineers collaborate by function (Backend, Frontend, etc.)
- ✅ Managers oversee by geography (easier for local HR, compliance)
- ✅ Approval workflows follow geographic managers
- ✅ Career paths follow functional expertise

---

### Example 3: Matrix Organization (Project-Based)

**Company**: Consulting firm, project-based work

**Structure**: Functional + Project matrix

#### Operational Structure (Projects)
```yaml
Active Projects
  ├─ Project Alpha
  │   ├─ 3 Backend Engineers
  │   ├─ 2 Frontend Engineers
  │   └─ 1 Designer
  ├─ Project Beta
  │   ├─ 2 Backend Engineers
  │   └─ 2 Mobile Engineers
  └─ Project Gamma
      └─ 4 Full-stack Engineers
```

#### Supervisory Structure (Functional)
```yaml
Engineering Leadership
  ├─ Backend Engineering Manager
  │   └─ All backend engineers (across all projects)
  ├─ Frontend Engineering Manager
  │   └─ All frontend engineers
  └─ Mobile Engineering Manager
      └─ All mobile engineers
```

**Employee Example**:
```yaml
Employee: John (Backend Engineer)
  Operational:
    - Project Alpha (60% time)
    - Project Beta (40% time)
  
  Supervisory:
    - Backend Engineering Manager
    
  # Day-to-day: Works on projects
  # Career/reviews: Backend engineering manager
```

---

## 🔄 Common Scenarios

### Scenario 1: New Hire

**Question**: Where does a new hire go?

**Answer**: Assign to BOTH structures

```yaml
New Hire: Sarah (Backend Engineer)

# Step 1: Assign to operational unit
Assignment:
  business_unit_id: ENG-BACKEND-API  # Operational team
  
# Step 2: Assign to supervisory org
Assignment:
  supervisory_org_id: SUP-MGR-APAC  # Reporting manager
  manager_id: ALICE
```

---

### Scenario 2: Reorganization

**Scenario**: Merge Backend and Frontend teams into Platform team

**Operational Change** (Major):
```yaml
# Before
Units:
  - ENG-BACKEND (10 people)
  - ENG-FRONTEND (8 people)

# After
Units:
  - ENG-PLATFORM (18 people)  # Merged!
  
# Update all assignments
Assignments:
  - Update business_unit_id to ENG-PLATFORM
```

**Supervisory Change** (None):
```yaml
# Supervisory structure unchanged!
Supervisory:
  - SUP-MGR-APAC (still manages same people)
  
# No need to update reporting relationships
# Approvals continue to work
```

**Benefits**:
- ✅ Reorganization doesn't break approval workflows
- ✅ Manager relationships preserved
- ✅ Performance review cycles unaffected

---

### Scenario 3: Manager Change

**Scenario**: Alice leaves, Bob becomes new manager

**Operational Change** (None):
```yaml
# Teams stay the same
Units:
  - ENG-BACKEND (unchanged)
  - ENG-FRONTEND (unchanged)
```

**Supervisory Change** (Update manager):
```yaml
# Before
Unit:
  code: SUP-MGR-APAC
  manager_id: ALICE

# After
Unit:
  code: SUP-MGR-APAC
  manager_id: BOB  # New manager
  effective_start: 2024-07-01
  
# All reporting relationships automatically updated
# Approval workflows now go to Bob
```

**Benefits**:
- ✅ Single point of change
- ✅ All approvals automatically rerouted
- ✅ Historical data preserved (SCD Type 2)

---

### Scenario 4: Project Assignment

**Scenario**: Engineer temporarily assigned to project

**Operational Change** (Add project assignment):
```yaml
Employee: John

# Primary assignment (unchanged)
Assignment:
  business_unit_id: ENG-BACKEND
  fte: 0.6  # 60% time
  is_primary: true

# Project assignment (new)
Assignment:
  business_unit_id: PROJ-ALPHA
  fte: 0.4  # 40% time
  is_primary: false
  dotted_line_supervisor_id: PROJ-LEAD-ALPHA
```

**Supervisory Change** (None):
```yaml
# Supervisory org unchanged
Supervisory:
  - SUP-MGR-APAC (still John's manager)
  
# Alice still approves leave, does performance review
# Project lead provides input but doesn't approve
```

---

## ✅ Best Practices

### 1. Organizational Design

✅ **DO**:
- Use operational structure for work organization
- Use supervisory structure for reporting/approvals
- Keep operational structure stable
- Allow supervisory structure to be more dynamic
- Document which structure is used for what purpose

❌ **DON'T**:
- Mix operational and supervisory in same hierarchy
- Use operational structure for approvals
- Change operational structure frequently
- Create supervisory orgs without clear purpose

---

### 2. Naming Conventions

✅ **DO**:
```yaml
# Operational units
ENG-BACKEND
ENG-FRONTEND
SALES-ENTERPRISE

# Supervisory units
SUP-VP-ENG
SUP-MGR-APAC
SUP-DIR-SALES
```

❌ **DON'T**:
```yaml
# Confusing names
TEAM-1
ORG-A
UNIT-123
```

---

### 3. Manager Assignment

✅ **DO**:
```yaml
# Operational unit: Team lead (technical)
Unit:
  code: ENG-BACKEND
  type: TEAM
  team_lead_id: BOB  # Technical lead

# Supervisory unit: People manager
Unit:
  code: SUP-MGR-APAC
  type: SUPERVISORY
  manager_id: ALICE  # People manager
```

❌ **DON'T**:
```yaml
# Same person as both technical and people manager
# (unless organization is small/simple)
```

---

### 4. Communication

✅ **DO**:
- Explain to employees which structure is which
- Show both structures in org charts
- Train managers on their supervisory responsibilities
- Document approval workflows clearly

❌ **DON'T**:
- Assume employees understand dual structure
- Show only one structure
- Mix up approval chains

---

## ⚠️ Common Pitfalls

### Pitfall 1: Using Operational Structure for Approvals

❌ **Wrong**:
```yaml
Leave Request:
  employee: John
  approver: Bob (Team Lead)  # WRONG!
  
# Bob is technical lead, not people manager
# Approval should go to Alice (supervisory manager)
```

✅ **Correct**:
```yaml
Leave Request:
  employee: John
  approver: Alice (Supervisory Manager)  # CORRECT!
  
# Alice is John's people manager in supervisory org
```

---

### Pitfall 2: Frequent Operational Reorganization

❌ **Wrong**:
```yaml
# Month 1
Unit: ENG-BACKEND

# Month 2
Unit: ENG-PLATFORM  # Renamed!

# Month 3
Unit: ENG-SERVICES  # Renamed again!

# Too much churn, confusing for employees
```

✅ **Correct**:
```yaml
# Keep operational structure stable
# Use projects or tags for temporary groupings
Unit: ENG-BACKEND (stable)
  Tags:
    - PROJECT: ALPHA
    - INITIATIVE: PLATFORM_MIGRATION
```

---

### Pitfall 3: Not Updating Supervisory Org on Manager Change

❌ **Wrong**:
```yaml
# Alice leaves, Bob becomes manager
# But supervisory org not updated!

Unit:
  code: SUP-MGR-APAC
  manager_id: ALICE  # STALE!
  
# Approvals still going to Alice (who left)
```

✅ **Correct**:
```yaml
# Update supervisory org immediately
Unit:
  code: SUP-MGR-APAC
  manager_id: BOB
  effective_start: 2024-07-01
  
# All approvals automatically rerouted to Bob
```

---

### Pitfall 4: Creating Too Many Supervisory Orgs

❌ **Wrong**:
```yaml
# One supervisory org per team (too granular)
SUP-BACKEND-API-TEAM
SUP-BACKEND-DATA-TEAM
SUP-FRONTEND-WEB-TEAM
SUP-FRONTEND-MOBILE-TEAM
# ... 50 supervisory orgs!
```

✅ **Correct**:
```yaml
# Supervisory orgs at manager level
SUP-MGR-APAC (covers multiple teams)
SUP-MGR-SG (covers multiple teams)
SUP-VP-ENG (covers all engineering)
```

---

## 📊 Decision Matrix

### When to Use Which Structure?

| Use Case | Use Operational | Use Supervisory |
|----------|----------------|-----------------|
| Team collaboration | ✅ | ❌ |
| Project assignment | ✅ | ❌ |
| Daily standups | ✅ | ❌ |
| Code reviews | ✅ | ❌ |
| Leave approval | ❌ | ✅ |
| Performance review | ❌ | ✅ |
| Compensation decision | ❌ | ✅ |
| Career development | ❌ | ✅ |
| Data access control | ❌ | ✅ |
| Expense approval | ❌ | ✅ |

---

## 🎓 Quick Reference

### Checklist: Setting Up Dual Structure

**Operational Structure**:
- [ ] Define divisions, departments, teams
- [ ] Set up team leads (technical)
- [ ] Assign employees to operational units
- [ ] Use for work organization

**Supervisory Structure**:
- [ ] Define supervisory organizations
- [ ] Assign people managers
- [ ] Link employees to supervisory orgs
- [ ] Configure approval workflows
- [ ] Set up data access permissions

**Communication**:
- [ ] Explain dual structure to employees
- [ ] Train managers on responsibilities
- [ ] Document approval workflows
- [ ] Update org charts to show both structures

---

## 📚 Related Guides

- [Employment Lifecycle Guide](./01-employment-lifecycle-guide.md) - Understanding assignments
- [Matrix Organizations Guide](./07-matrix-organizations-guide.md) - Solid/dotted line reporting
- [Job & Position Management Guide](./03-job-position-guide.md) - Position-based staffing

---

## 🔗 References

### Industry Best Practices
- **Workday HCM**: Supervisory Organization concept
- **SAP SuccessFactors**: Matrix organization support
- **Oracle HCM**: Organization structures

### Further Reading
- [glossary-business-unit.md](../00-ontology/glossary-business-unit.md) - Technical details
- [glossary-org-relation.md](../00-ontology/glossary-org-relation.md) - Relationship modeling

---

**Document Version**: 1.0  
**Created**: 2025-12-02  
**Last Review**: 2025-12-02
