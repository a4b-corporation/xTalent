# Staffing Models Guide

**Version**: 2.0  
**Last Updated**: 2025-12-02  
**Audience**: HR Leaders, Finance, Business Managers  
**Reading Time**: 40-50 minutes

---

## 📋 Overview

This guide provides a deep dive into the two fundamental staffing models in xTalent Core Module: **Position-Based** and **Job-Based** staffing. Understanding these models is critical for headcount management, budgeting, and organizational flexibility.

### What You'll Learn
- The fundamental difference between position-based and job-based staffing
- When to use each model
- How each model affects budgeting and headcount control
- Implementation strategies and best practices
- Real-world scenarios and decision frameworks

### Prerequisites
- Understanding of jobs and positions
- Basic knowledge of budgeting and headcount planning
- Familiarity with organizational structures

---

## 🎯 The Fundamental Question

### What Are You Managing?

```
The Core Question:
Do you manage POSITIONS (pre-approved slots)
or JOBS (flexible assignments)?

This decision affects:
  ✓ Budget approval process
  ✓ Headcount control
  ✓ Hiring speed
  ✓ Organizational flexibility
  ✓ Reporting and analytics
```

---

## 📊 Position-Based Staffing

### What Is It?

**Definition**: Employees are assigned to specific, pre-approved budgeted positions that exist independently of the people who fill them.

**Core Concept**: **Position = Headcount Slot**

```
Position-Based Model:

Step 1: Create Position (Budget Approval)
  ┌─────────────────────────────────┐
  │ Position: POS-ENG-001           │
  │ Job: Senior Backend Engineer    │
  │ Department: Engineering         │
  │ Budget: Approved for 2024       │
  │ Status: VACANT                  │
  └─────────────────────────────────┘
  
Step 2: Hire to Position
  ┌─────────────────────────────────┐
  │ Position: POS-ENG-001           │
  │ Incumbent: John Doe             │
  │ Status: FILLED                  │
  └─────────────────────────────────┘
  
Step 3: Employee Leaves
  ┌─────────────────────────────────┐
  │ Position: POS-ENG-001           │
  │ Incumbent: None                 │
  │ Status: VACANT (can refill)     │
  └─────────────────────────────────┘
```

### Key Characteristics

| Aspect | Details |
|--------|---------|
| **Headcount Control** | Strict - positions are pre-approved |
| **Budget Approval** | Required for each position |
| **Hiring Process** | Fill existing vacant position |
| **Vacancy Tracking** | Easy - positions can be vacant |
| **Organizational Chart** | Shows positions (boxes), not people |
| **Flexibility** | Lower - need approval to create position |
| **Reporting Hierarchy** | Positions form hierarchy |
| **Typical Users** | Government, large corporations, regulated industries |

### Complete Example

```yaml
# Step 1: Budget Planning (Annual)
Budget Request 2024:
  Department: Engineering
  Positions Requested:
    - 5 Senior Backend Engineers (Grade 7)
    - 3 Mid Backend Engineers (Grade 6)
    - 2 Junior Backend Engineers (Grade 5)
  Total Budget: 2,500,000,000 VND

# Step 2: Budget Approved
Approved Positions:
  - POS-ENG-BACKEND-001 (Senior, Grade 7)
  - POS-ENG-BACKEND-002 (Senior, Grade 7)
  - POS-ENG-BACKEND-003 (Senior, Grade 7)
  - POS-ENG-BACKEND-004 (Mid, Grade 6)
  - POS-ENG-BACKEND-005 (Mid, Grade 6)
  - POS-ENG-BACKEND-006 (Junior, Grade 5)
  
  All positions: VACANT, ready to hire

# Step 3: Hire to Positions
Position: POS-ENG-BACKEND-001
  job_id: JOB-BACKEND-SENIOR
  business_unit_id: BU-ENGINEERING
  reports_to_position_id: POS-ENG-MGR-001
  location_id: LOC-HCM-OFFICE
  fte: 1.0
  status: ACTIVE
  is_budgeted: true
  budget_year: 2024
  current_incumbents: 0  # Vacant
  max_incumbents: 1

# Step 4: Fill Position
Assignment:
  employee_id: EMP-001
  staffing_model: POSITION_BASED
  position_id: POS-ENG-BACKEND-001
  job_id: JOB-BACKEND-SENIOR  # Derived from position
  effective_start_date: 2024-01-15

Position: POS-ENG-BACKEND-001
  current_incumbents: 1  # Filled

# Step 5: Employee Leaves
Assignment:
  effective_end_date: 2024-12-31
  is_current: false

Position: POS-ENG-BACKEND-001
  current_incumbents: 0  # Vacant again
  status: ACTIVE  # Can be refilled
```

### Position Lifecycle

```
┌──────────────────────────────────────────────────┐
│ POSITION LIFECYCLE                               │
└──────────────────────────────────────────────────┘

1. CREATED (Budget Approval)
   Position: POS-001
   Status: ACTIVE
   Incumbents: 0
   ↓

2. POSTED (Job Opening)
   Recruiting for position
   ↓

3. FILLED (Hire)
   Incumbents: 1
   ↓

4. VACANT (Resignation)
   Incumbents: 0
   Can refill immediately
   ↓

5. FROZEN (Hiring Freeze)
   Status: FROZEN
   Cannot hire
   ↓

6. ELIMINATED (Reorganization)
   Status: ELIMINATED
   Historical record only
```

---

## 📊 Job-Based Staffing

### What Is It?

**Definition**: Employees are assigned directly to jobs without pre-defined positions. Headcount is managed through job assignments.

**Core Concept**: **Job = Role, No Position Needed**

```
Job-Based Model:

Step 1: Define Job (One-time)
  ┌─────────────────────────────────┐
  │ Job: Senior Backend Engineer    │
  │ Level: Senior (L3)              │
  │ Grade: Grade 7                  │
  │ Profile: [requirements]         │
  └─────────────────────────────────┘
  
Step 2: Hire Directly to Job
  ┌─────────────────────────────────┐
  │ Employee: John Doe              │
  │ Job: Senior Backend Engineer    │
  │ Department: Engineering         │
  │ No position needed!             │
  └─────────────────────────────────┘
  
Step 3: Hire Another Person (Same Job)
  ┌─────────────────────────────────┐
  │ Employee: Jane Smith            │
  │ Job: Senior Backend Engineer    │
  │ Department: Engineering         │
  │ Multiple people, same job OK!   │
  └─────────────────────────────────┘
```

### Key Characteristics

| Aspect | Details |
|--------|---------|
| **Headcount Control** | Flexible - no pre-defined slots |
| **Budget Approval** | Approve headcount budget, not positions |
| **Hiring Process** | Hire to job directly |
| **Vacancy Tracking** | Harder - no concept of "vacant position" |
| **Organizational Chart** | Shows people and their jobs |
| **Flexibility** | Higher - easy to scale up/down |
| **Reporting Hierarchy** | People report to people |
| **Typical Users** | Startups, consulting firms, agile organizations |

### Complete Example

```yaml
# Step 1: Budget Planning (Annual)
Budget Request 2024:
  Department: Engineering
  Headcount Budget:
    - Senior Engineers: 5 people × 130M VND = 650M VND
    - Mid Engineers: 3 people × 90M VND = 270M VND
    - Junior Engineers: 2 people × 65M VND = 130M VND
  Total Budget: 1,050M VND
  Total Headcount: 10 people

# Step 2: Budget Approved
Approved:
  Headcount: 10 people
  Budget: 1,050M VND
  # No specific positions created!

# Step 3: Hire to Jobs (As Needed)
Assignment 1:
  employee_id: EMP-001
  staffing_model: JOB_BASED
  position_id: null  # No position!
  job_id: JOB-BACKEND-SENIOR
  business_unit_id: BU-ENGINEERING
  supervisor_assignment_id: ASG-MGR-001
  effective_start_date: 2024-01-15

Assignment 2:
  employee_id: EMP-002
  staffing_model: JOB_BASED
  position_id: null
  job_id: JOB-BACKEND-SENIOR  # Same job as EMP-001
  business_unit_id: BU-ENGINEERING
  supervisor_assignment_id: ASG-MGR-001
  effective_start_date: 2024-02-01

# Multiple people, same job, no positions needed!

# Step 4: Track Headcount
Current Headcount (Engineering):
  Senior Engineers: 5 (budget: 5) ✓
  Mid Engineers: 3 (budget: 3) ✓
  Junior Engineers: 2 (budget: 2) ✓
  Total: 10 (budget: 10) ✓
```

---

## 🔄 Side-by-Side Comparison

### Hiring Process

#### Position-Based
```yaml
Hiring Process:
  1. Position exists (pre-approved)
     Position: POS-ENG-001 (VACANT)
     
  2. Post job opening
     "We have an open position for Senior Engineer"
     
  3. Interview candidates
     
  4. Make offer
     
  5. Hire to position
     Assignment:
       position_id: POS-ENG-001
       
  6. Position filled
     Position: POS-ENG-001 (FILLED)

Timeline: Faster (position already approved)
Approval: Not needed (position pre-approved)
```

#### Job-Based
```yaml
Hiring Process:
  1. Identify need
     "We need another Senior Engineer"
     
  2. Check headcount budget
     Current: 5 Senior Engineers
     Budget: 8 Senior Engineers
     Available: 3 slots ✓
     
  3. Get hiring approval
     Manager approves hiring
     
  4. Post job opening
     
  5. Interview candidates
     
  6. Make offer
     
  7. Hire to job
     Assignment:
       job_id: JOB-BACKEND-SENIOR
       position_id: null

Timeline: May be slower (need approval)
Approval: Needed per hire
```

---

### Resignation Handling

#### Position-Based
```yaml
Employee Resigns:
  1. Employee: John (POS-ENG-001) resigns
     
  2. End assignment
     Assignment: effective_end_date = 2024-12-31
     
  3. Position becomes vacant
     Position: POS-ENG-001
       current_incumbents: 0
       status: ACTIVE (can refill)
       
  4. Backfill immediately
     Position already approved
     Post job opening
     Hire to same position
     
  5. No budget approval needed
     Position already in budget

Backfill: EASY (position exists)
Approval: NOT NEEDED
```

#### Job-Based
```yaml
Employee Resigns:
  1. Employee: John resigns
     
  2. End assignment
     Assignment: effective_end_date = 2024-12-31
     
  3. Headcount decreases
     Senior Engineers: 5 → 4
     
  4. Decide to backfill
     Need manager approval
     Check budget
     
  5. Get approval
     Manager: "Yes, backfill"
     
  6. Hire new person
     Post job opening
     Hire to job

Backfill: REQUIRES DECISION
Approval: NEEDED
```

---

### Reorganization

#### Position-Based
```yaml
Reorganization:
  Merge Backend + Frontend → Platform Team
  
  Steps:
    1. Eliminate old positions
       POS-BACKEND-001: ELIMINATED
       POS-BACKEND-002: ELIMINATED
       POS-FRONTEND-001: ELIMINATED
       POS-FRONTEND-002: ELIMINATED
       
    2. Create new positions
       POS-PLATFORM-001: CREATED
       POS-PLATFORM-002: CREATED
       POS-PLATFORM-003: CREATED
       POS-PLATFORM-004: CREATED
       
    3. Transfer employees
       End old assignments
       Create new assignments to new positions
       
    4. Update org chart
       New position hierarchy

Complexity: HIGH
Time: WEEKS
Effort: SIGNIFICANT
```

#### Job-Based
```yaml
Reorganization:
  Merge Backend + Frontend → Platform Team
  
  Steps:
    1. Update assignments
       Change business_unit_id to BU-PLATFORM
       
    2. Update org chart
       New team structure

Complexity: LOW
Time: DAYS
Effort: MINIMAL
```

---

### Headcount Reporting

#### Position-Based
```yaml
Headcount Report:
  Total Positions: 100
    Active: 85
    Vacant: 10
    Frozen: 5
    
  Filled Positions: 85
  Vacancy Rate: 10/100 = 10%
  
  By Department:
    Engineering:
      Total Positions: 30
      Filled: 25
      Vacant: 3
      Frozen: 2
      
  By Level:
    Senior: 20 positions (18 filled)
    Mid: 40 positions (38 filled)
    Junior: 40 positions (29 filled)

Reporting: EASY (positions are countable)
Vacancy Tracking: BUILT-IN
```

#### Job-Based
```yaml
Headcount Report:
  Total Employees: 85
  
  By Department:
    Engineering: 25 people
    Sales: 30 people
    Operations: 30 people
    
  By Job:
    Senior Backend Engineer: 5 people
    Mid Backend Engineer: 10 people
    Junior Backend Engineer: 10 people
    
  Budget vs Actual:
    Budget: 100 people
    Actual: 85 people
    Under budget: 15 people

Reporting: REQUIRES CALCULATION
Vacancy Tracking: MANUAL (budget - actual)
```

---

## 🎯 When to Use Each Model

### Use Position-Based When:

✅ **Strict Headcount Control Required**
```yaml
Example: Government Agency
  - Every position requires legislative approval
  - Cannot hire without approved position
  - Position-based is MANDATORY
```

✅ **Formal Budget Approval Process**
```yaml
Example: Large Corporation
  - Annual budget cycle
  - Each position approved by CFO
  - Position = budget line item
```

✅ **Clear Organizational Hierarchy Needed**
```yaml
Example: Traditional Enterprise
  - Org chart shows positions (boxes)
  - Reporting relationships through positions
  - Position hierarchy = authority structure
```

✅ **Vacancy Tracking Important**
```yaml
Example: Recruitment-Heavy Organization
  - Need to track open positions
  - Recruitment metrics by position
  - Time-to-fill per position
```

✅ **Succession Planning**
```yaml
Example: Executive Positions
  - Each position has succession plan
  - Identify backups for key positions
  - Position-based planning
```

---

### Use Job-Based When:

✅ **Flexibility and Speed Needed**
```yaml
Example: Startup
  - Rapid growth (10 → 100 people in 1 year)
  - Can't wait for position approval
  - Hire to jobs directly
```

✅ **Project-Based Staffing**
```yaml
Example: Consulting Firm
  - Staff projects as needed
  - No fixed positions
  - Flexible team composition
```

✅ **Agile Organization**
```yaml
Example: Tech Company
  - Frequent reorganizations
  - Teams form and dissolve
  - Position-based too rigid
```

✅ **Contractor-Heavy Workforce**
```yaml
Example: Professional Services
  - 50% contractors
  - Contractors don't need positions
  - Job-based more appropriate
```

✅ **Simple Organizational Structure**
```yaml
Example: Small Company (<50 people)
  - Position management overhead not worth it
  - Job-based simpler
```

---

## 🔄 Hybrid Approach (Recommended)

### Best of Both Worlds

**Strategy**: Use position-based for some roles, job-based for others.

```yaml
Hybrid Staffing Model:

Position-Based:
  - Executives and senior management
  - Key strategic positions
  - Roles requiring board approval
  - Succession planning positions
  
  Example:
    - CEO (position)
    - CFO (position)
    - VP Engineering (position)
    - Director of Sales (position)

Job-Based:
  - Individual contributors
  - Contractors and consultants
  - Temporary roles
  - Flexible team members
  
  Example:
    - Software Engineers (job)
    - Sales Representatives (job)
    - Contractors (job)
    - Interns (job)
```

### Implementation Strategy

```yaml
# Tier 1: Executive (Position-Based)
Positions:
  - POS-CEO
  - POS-CFO
  - POS-CTO
  - POS-VP-ENG
  - POS-VP-SALES

Characteristics:
  - Strict control
  - Board approval required
  - Succession planning
  - High visibility

# Tier 2: Management (Position-Based)
Positions:
  - POS-DIR-ENG
  - POS-MGR-BACKEND
  - POS-MGR-FRONTEND
  - POS-MGR-SALES-ENTERPRISE

Characteristics:
  - Budget approval required
  - Reporting hierarchy
  - Headcount control

# Tier 3: Individual Contributors (Job-Based)
Jobs:
  - JOB-BACKEND-SENIOR
  - JOB-BACKEND-MID
  - JOB-BACKEND-JUNIOR
  - JOB-SALES-REP

Characteristics:
  - Flexible headcount
  - Manager approval
  - Easy to scale

# Tier 4: Contractors (Job-Based)
Jobs:
  - JOB-CONTRACTOR-BACKEND
  - JOB-CONSULTANT
  - JOB-INTERN

Characteristics:
  - No positions
  - Temporary
  - Flexible
```

### Benefits of Hybrid

✅ **Control Where Needed**
- Executive and management positions controlled
- IC roles flexible

✅ **Flexibility Where Needed**
- Easy to scale IC teams
- Quick hiring for projects

✅ **Clear Hierarchy**
- Management positions form hierarchy
- IC roles flexible within teams

✅ **Optimized Processes**
- Position approval for key roles
- Streamlined hiring for IC roles

---

## 📈 Real-World Scenarios

### Scenario 1: Startup Growth (Job-Based → Hybrid)

**Phase 1: Early Stage (0-20 people) - Job-Based**
```yaml
Headcount: 15 people
Model: 100% Job-Based

Rationale:
  - Moving fast
  - No time for position approval
  - Frequent reorganizations
  - Simple structure

Implementation:
  All employees:
    staffing_model: JOB_BASED
    position_id: null
```

**Phase 2: Growth Stage (20-100 people) - Hybrid**
```yaml
Headcount: 75 people
Model: Hybrid (20% Position, 80% Job)

Rationale:
  - Need some structure
  - Investors want control
  - Still growing fast

Implementation:
  Executives (5): Position-Based
  Managers (10): Position-Based
  ICs (60): Job-Based
```

**Phase 3: Mature (100+ people) - Mostly Position-Based**
```yaml
Headcount: 250 people
Model: Hybrid (60% Position, 40% Job)

Rationale:
  - IPO preparation
  - Need strict controls
  - Board oversight

Implementation:
  Executives (10): Position-Based
  Managers (40): Position-Based
  Senior ICs (50): Position-Based
  ICs (100): Job-Based
  Contractors (50): Job-Based
```

---

### Scenario 2: Consulting Firm (Job-Based)

**Organization**: Professional Services Firm

```yaml
Staffing Model: 100% Job-Based

Rationale:
  - Project-based work
  - Flexible team composition
  - No fixed positions
  - Clients drive staffing

Implementation:
  Partners: Job-Based
    job: PARTNER
    staffing_model: JOB_BASED
    
  Consultants: Job-Based
    job: SENIOR_CONSULTANT
    staffing_model: JOB_BASED
    
  Analysts: Job-Based
    job: ANALYST
    staffing_model: JOB_BASED

Project Staffing:
  Project Alpha:
    - 1 Partner
    - 2 Senior Consultants
    - 3 Analysts
    
  Project Beta:
    - 1 Partner
    - 3 Senior Consultants
    - 2 Analysts
    
  # People move between projects
  # No fixed positions
```

---

### Scenario 3: Government Agency (Position-Based)

**Organization**: Government Department

```yaml
Staffing Model: 100% Position-Based

Rationale:
  - Legal requirement
  - Legislative approval
  - Civil service rules
  - Strict hierarchy

Implementation:
  Every role is a position:
    - POS-DIRECTOR-001
    - POS-DEPUTY-DIR-001
    - POS-MANAGER-001
    - POS-OFFICER-001
    - POS-CLERK-001

Position Creation:
  1. Budget request to legislature
  2. Legislative approval
  3. Position created
  4. Recruitment authorized
  5. Hire to position

Position Elimination:
  1. Proposal to legislature
  2. Legislative approval
  3. Position eliminated
  
  # Cannot hire without approved position
  # Cannot eliminate position without approval
```

---

### Scenario 4: Tech Company (Hybrid)

**Organization**: Mid-size Tech Company (500 people)

```yaml
Staffing Model: Hybrid

Position-Based (30%):
  Executives (10 positions):
    - C-suite
    - VPs
    
  Directors (20 positions):
    - Engineering Directors
    - Sales Directors
    - Product Directors
    
  Key Managers (120 positions):
    - Engineering Managers
    - Product Managers
    - Sales Managers

Job-Based (70%):
  Engineers (250 people):
    - Senior Engineers
    - Mid Engineers
    - Junior Engineers
    
  Sales Reps (50 people):
    - Enterprise Sales
    - SMB Sales
    
  Contractors (50 people):
    - Temporary staff
    - Consultants

Rationale:
  Position-Based:
    - Control management headcount
    - Clear reporting hierarchy
    - Succession planning
    
  Job-Based:
    - Flexibility for IC hiring
    - Easy to scale teams
    - Quick hiring process
```

---

## ✅ Best Practices

### 1. Choosing the Right Model

✅ **DO**:
```yaml
Assess your needs:
  - Organization size
  - Growth rate
  - Industry regulations
  - Budget process
  - Flexibility requirements
  
Choose based on:
  - Control vs flexibility tradeoff
  - Administrative capacity
  - Organizational culture
```

❌ **DON'T**:
```yaml
# Copy what others do
# "Google uses job-based, so we should too"
# Your context may be different!

# Choose based on trend
# "Position-based is old-fashioned"
# It may be right for your organization
```

---

### 2. Implementing Position-Based

✅ **DO**:
```yaml
Position Management:
  - Clear position naming convention
  - Formal approval process
  - Regular position reviews
  - Vacancy tracking system
  - Position hierarchy maintenance

Budget Process:
  - Annual position budgeting
  - Mid-year adjustments
  - Position freeze protocols
  - Elimination process
```

❌ **DON'T**:
```yaml
# Create too many positions
# One position per person = overhead

# Never eliminate positions
# Accumulate obsolete positions

# Ignore vacant positions
# Track and manage vacancies
```

---

### 3. Implementing Job-Based

✅ **DO**:
```yaml
Headcount Management:
  - Clear headcount budgets
  - Regular headcount reviews
  - Approval workflows
  - Budget vs actual tracking

Job Management:
  - Well-defined jobs
  - Clear job levels
  - Consistent job titles
  - Job catalog maintenance
```

❌ **DON'T**:
```yaml
# Lose control of headcount
# "We have budget, hire anyone"

# Create too many jobs
# One job per person = chaos

# Ignore budget
# Headcount creep
```

---

### 4. Hybrid Implementation

✅ **DO**:
```yaml
Clear Criteria:
  Position-Based:
    - Executives (all)
    - Managers (all)
    - Key strategic roles
    
  Job-Based:
    - Individual contributors
    - Contractors
    - Temporary roles

Communication:
  - Explain why different models
  - Document criteria
  - Train HR and managers
```

❌ **DON'T**:
```yaml
# Inconsistent application
# Same role, different models in different teams

# No clear criteria
# Ad-hoc decisions

# Confuse employees
# Unclear which model applies
```

---

## ⚠️ Common Pitfalls

### Pitfall 1: Position-Based Rigidity

❌ **Problem**:
```yaml
Scenario:
  - Need to hire urgently
  - No vacant position
  - Must create new position
  - Position approval takes 3 months
  - Candidate accepts other offer
  
Result: Lost candidate due to slow process
```

✅ **Solution**:
```yaml
Hybrid Approach:
  - Use job-based for urgent hires
  - Convert to position later if needed
  
Or:
  - Maintain buffer positions
  - "Flex positions" for urgent needs
```

---

### Pitfall 2: Job-Based Headcount Creep

❌ **Problem**:
```yaml
Scenario:
  - No position approval needed
  - Managers hire freely
  - Headcount grows uncontrolled
  - Budget overrun
  
Result: 120 people hired, budget for 100
```

✅ **Solution**:
```yaml
Controls:
  - Strict headcount budgets
  - Manager approval required
  - Regular headcount reviews
  - Finance oversight
```

---

### Pitfall 3: Mixing Models Inconsistently

❌ **Problem**:
```yaml
Scenario:
  - Team A: Position-based
  - Team B: Job-based (same roles)
  - Different processes
  - Confusion
  
Result: Inconsistent treatment, employee complaints
```

✅ **Solution**:
```yaml
Clear Criteria:
  - Document which roles use which model
  - Consistent application
  - Clear communication
```

---

## 📊 Decision Framework

### Decision Tree

```
Choose Staffing Model:

1. Is strict headcount control required by law/regulation?
   YES → Position-Based (mandatory)
   NO → Continue to 2

2. Is your organization growing rapidly (>50% per year)?
   YES → Job-Based (flexibility needed)
   NO → Continue to 3

3. Do you have formal budget approval for each hire?
   YES → Position-Based (aligns with process)
   NO → Continue to 4

4. Is your workforce mostly contractors/temporary?
   YES → Job-Based (no positions for contractors)
   NO → Continue to 5

5. Do you reorganize frequently (quarterly)?
   YES → Job-Based (easier reorganization)
   NO → Continue to 6

6. Do you need succession planning for key roles?
   YES → Hybrid (positions for key roles)
   NO → Continue to 7

7. Is your organization small (<50 people)?
   YES → Job-Based (simpler)
   NO → Hybrid (best of both)
```

---

## 🎓 Quick Reference

### Comparison Table

| Aspect | Position-Based | Job-Based | Hybrid |
|--------|----------------|-----------|--------|
| **Control** | High | Medium | High for key roles |
| **Flexibility** | Low | High | Medium |
| **Approval Speed** | Slow | Fast | Mixed |
| **Vacancy Tracking** | Easy | Hard | Easy for positions |
| **Reorganization** | Hard | Easy | Medium |
| **Best For** | Large orgs, govt | Startups, consulting | Most organizations |
| **Complexity** | High | Low | Medium |

### Checklist: Choosing Your Model

**Position-Based Indicators**:
- [ ] Strict headcount control required
- [ ] Formal budget approval process
- [ ] Succession planning important
- [ ] Clear organizational hierarchy needed
- [ ] Vacancy tracking critical
- [ ] Government or regulated industry

**Job-Based Indicators**:
- [ ] Rapid growth expected
- [ ] Frequent reorganizations
- [ ] Project-based work
- [ ] Contractor-heavy workforce
- [ ] Need hiring flexibility
- [ ] Small organization

**Hybrid Indicators**:
- [ ] Mix of stable and flexible roles
- [ ] Want control for key positions
- [ ] Want flexibility for IC roles
- [ ] Medium to large organization
- [ ] Balanced growth and control

---

## 📚 Related Guides

- [Job & Position Management Guide](./03-job-position-guide.md) - Jobs and positions explained
- [Employment Lifecycle Guide](./01-employment-lifecycle-guide.md) - Assignment details
- [Organization Structure Guide](./02-organization-structure-guide.md) - Organizational context

---

**Document Version**: 1.0  
**Created**: 2025-12-02  
**Last Review**: 2025-12-02
