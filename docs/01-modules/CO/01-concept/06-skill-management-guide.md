# Skill Management Guide

**Version**: 2.0  
**Last Updated**: 2025-12-02  
**Audience**: HR Administrators, Talent Development, Hiring Managers  
**Reading Time**: 40-50 minutes

---

## 📋 Overview

This guide explains how to manage skills and competencies in xTalent Core Module, with a focus on skill gap analysis for hiring, development, and career planning.

### What You'll Learn
- The difference between skills and competencies
- How to build a skill catalog
- Proficiency scales and assessment
- Skill gap analysis methodology
- Using skills for hiring and development
- Real-world scenarios and best practices

### Prerequisites
- Understanding of job profiles
- Basic knowledge of talent development
- Familiarity with performance management

---

## 🎯 Skills vs Competencies: The Core Distinction

### What Are Skills?

**Definition**: **Technical or functional abilities** that can be learned, measured, and improved.

**Characteristics**:
- ✅ **Teachable** - Can be learned through training
- ✅ **Measurable** - Can be assessed objectively
- ✅ **Job-specific** - Vary by role
- ✅ **Evolve** - New skills emerge with technology

**Examples**:
```yaml
Technical Skills:
  - Python programming
  - AWS cloud services
  - PostgreSQL database
  - Docker containerization
  - React.js framework

Functional Skills:
  - Project management
  - Financial analysis
  - Data analysis
  - Business writing
  - Presentation skills

Language Skills:
  - English (CEFR: B2)
  - Vietnamese (Native)
  - Mandarin (HSK 4)
```

---

### What Are Competencies?

**Definition**: **Behavioral attributes** that describe how work is performed.

**Characteristics**:
- ✅ **Behavioral** - Observable behaviors
- ✅ **Transferable** - Apply across roles
- ✅ **Harder to teach** - Develop over time
- ✅ **Stable** - Don't change rapidly

**Examples**:
```yaml
Leadership Competencies:
  - Leadership
  - Strategic thinking
  - Decision making
  - Influencing others

Interpersonal Competencies:
  - Communication
  - Teamwork
  - Collaboration
  - Conflict resolution

Cognitive Competencies:
  - Problem solving
  - Analytical thinking
  - Innovation
  - Learning agility

Personal Competencies:
  - Adaptability
  - Resilience
  - Self-motivation
  - Integrity
```

---

### Side-by-Side Comparison

| Aspect | Skills | Competencies |
|--------|--------|--------------|
| **Nature** | Technical/Functional | Behavioral |
| **Examples** | Python, Excel, AWS | Leadership, Communication |
| **Teachability** | Highly teachable | Harder to teach |
| **Measurement** | Objective (tests, certifications) | Subjective (observation, feedback) |
| **Change Rate** | Evolve rapidly | Relatively stable |
| **Scope** | Job-specific | Transferable across roles |
| **Development** | Training, practice | Experience, coaching, feedback |
| **Assessment** | Skills tests, certifications | 360 feedback, behavioral interviews |

---

## 📊 Building a Skill Catalog

### Skill Master Structure

```yaml
SkillMaster:
  id: SKILL-001
  code: PYTHON
  name: "Python Programming"
  
  # Categorization
  category: TECHNICAL
  sub_category: PROGRAMMING_LANGUAGE
  
  # Proficiency scale
  proficiency_scale_id: TECH_5_LEVEL
  
  # Metadata
  description: "Python programming language for backend development"
  
  related_certifications:
    - "PCEP - Certified Entry-Level Python Programmer"
    - "PCAP - Certified Associate Python Programmer"
    - "PCPP - Certified Professional Python Programmer"
  
  learning_resources:
    - url: "https://python.org/docs"
      type: "Official Documentation"
    - url: "https://realpython.com"
      type: "Tutorial Site"
  
  # Status
  is_active: true
  is_emerging: false  # New/trending skill
  is_declining: false  # Becoming obsolete
```

### Skill Categories

#### 1. Technical Skills

```yaml
Technical Skills:
  Programming Languages:
    - Python
    - Java
    - JavaScript
    - Go
    - Rust
    
  Frameworks:
    - React.js
    - Vue.js
    - Django
    - Spring Boot
    - FastAPI
    
  Databases:
    - PostgreSQL
    - MySQL
    - MongoDB
    - Redis
    - Elasticsearch
    
  Cloud Platforms:
    - AWS
    - Google Cloud
    - Azure
    - DigitalOcean
    
  DevOps Tools:
    - Docker
    - Kubernetes
    - Jenkins
    - GitLab CI/CD
    - Terraform
```

#### 2. Functional Skills

```yaml
Functional Skills:
  Project Management:
    - Agile/Scrum
    - Waterfall
    - Risk management
    - Stakeholder management
    
  Business Analysis:
    - Requirements gathering
    - Process mapping
    - Data analysis
    - Business case development
    
  Financial:
    - Financial modeling
    - Budgeting
    - Forecasting
    - Financial reporting
    
  Marketing:
    - Digital marketing
    - SEO/SEM
    - Content marketing
    - Social media marketing
```

#### 3. Language Skills

```yaml
Language Skills:
  English:
    proficiency_scale: CEFR
    levels: [A1, A2, B1, B2, C1, C2]
    
  Vietnamese:
    proficiency_scale: NATIVE_SCALE
    levels: [Native, Fluent, Advanced, Intermediate, Basic]
    
  Mandarin:
    proficiency_scale: HSK
    levels: [HSK1, HSK2, HSK3, HSK4, HSK5, HSK6]
```

---

## 📊 Proficiency Scales

### Technical Skills (5-Level Scale)

```yaml
Proficiency Scale: TECH_5_LEVEL

Level 1: Beginner
  description: "Basic understanding, needs guidance"
  indicators:
    - "Can perform simple tasks with supervision"
    - "Understands basic concepts"
    - "Requires frequent help"
  example: "Can write simple Python scripts with help"

Level 2: Basic
  description: "Can work independently on simple tasks"
  indicators:
    - "Handles routine tasks independently"
    - "Understands common patterns"
    - "Occasional help needed"
  example: "Can implement basic CRUD APIs in Python"

Level 3: Intermediate
  description: "Proficient, handles complex tasks"
  indicators:
    - "Works independently on complex tasks"
    - "Applies best practices"
    - "Can troubleshoot issues"
  example: "Can design microservices architecture in Python"

Level 4: Advanced
  description: "Expert, can mentor others"
  indicators:
    - "Deep expertise in the skill"
    - "Optimizes and improves systems"
    - "Mentors others"
    - "Solves complex problems"
  example: "Can optimize Python performance, lead design reviews"

Level 5: Expert
  description: "Authority, sets standards"
  indicators:
    - "Industry-recognized expert"
    - "Contributes to open source"
    - "Speaks at conferences"
    - "Sets organizational standards"
  example: "Python core contributor, conference speaker"
```

### Competency Scale (5-Level Scale)

```yaml
Proficiency Scale: COMPETENCY_5_LEVEL

Level 1: Developing
  description: "Shows basic awareness"
  indicators:
    - "Demonstrates basic understanding"
    - "Applies with guidance"
    - "Inconsistent application"

Level 2: Competent
  description: "Demonstrates competency consistently"
  indicators:
    - "Applies competency regularly"
    - "Consistent results"
    - "Meets expectations"

Level 3: Proficient
  description: "Applies competency effectively"
  indicators:
    - "Strong, consistent application"
    - "Exceeds expectations"
    - "Adapts to situations"

Level 4: Advanced
  description: "Role model, mentors others"
  indicators:
    - "Exceptional demonstration"
    - "Coaches others"
    - "Drives improvements"

Level 5: Expert
  description: "Thought leader, drives organizational change"
  indicators:
    - "Organizational impact"
    - "Develops others"
    - "Sets standards"
```

### Language Proficiency (CEFR)

```yaml
Common European Framework of Reference (CEFR):

A1 - Beginner:
  description: "Basic phrases, simple interactions"
  
A2 - Elementary:
  description: "Routine tasks, simple exchanges"
  
B1 - Intermediate:
  description: "Main points of clear input, familiar matters"
  
B2 - Upper Intermediate:
  description: "Complex text, fluent interaction"
  
C1 - Advanced:
  description: "Wide range of demanding texts, fluent expression"
  
C2 - Proficient:
  description: "Virtually everything, precise expression"
```

---

## 📊 Job Requirements: What Jobs Need

### Job Profile with Skills

```yaml
Job: Senior Backend Engineer
  code: JOB-BACKEND-SENIOR
  level: Senior (L3)
  grade: Grade 7

JobProfile:
  summary: "Design and build scalable backend systems"
  
  # Required Skills
  required_skills:
    # Mandatory Technical Skills
    - skill: Python
      required_proficiency: 4  # Advanced
      is_mandatory: true
      weight: 0.3  # 30% importance
      
    - skill: RESTful API Design
      required_proficiency: 4
      is_mandatory: true
      weight: 0.2
      
    - skill: PostgreSQL
      required_proficiency: 3  # Intermediate
      is_mandatory: true
      weight: 0.15
      
    - skill: AWS
      required_proficiency: 3
      is_mandatory: true
      weight: 0.15
      
    - skill: Docker
      required_proficiency: 3
      is_mandatory: true
      weight: 0.1
      
    # Nice-to-Have Skills
    - skill: Kubernetes
      required_proficiency: 3
      is_mandatory: false
      weight: 0.05
      
    - skill: Redis
      required_proficiency: 2  # Basic
      is_mandatory: false
      weight: 0.05
  
  # Required Competencies
  required_competencies:
    - competency: Leadership
      required_level: 4  # Advanced
      is_mandatory: true
      weight: 0.25
      
    - competency: Problem Solving
      required_level: 5  # Expert
      is_mandatory: true
      weight: 0.3
      
    - competency: Communication
      required_level: 4
      is_mandatory: true
      weight: 0.25
      
    - competency: Teamwork
      required_level: 4
      is_mandatory: true
      weight: 0.2
```

---

## 📊 Worker Skills: What People Have

### Worker Skill Profile

```yaml
Worker: John Doe
  id: WORKER-001
  
  # Technical Skills
  skills:
    - skill: Python
      proficiency_level: 5  # Expert
      years_experience: 8
      last_assessed: 2024-06-01
      assessment_method: "Technical interview + code review"
      certifications:
        - "PCPP - Certified Professional Python Programmer"
      
    - skill: RESTful API Design
      proficiency_level: 4  # Advanced
      years_experience: 6
      last_assessed: 2024-06-01
      
    - skill: PostgreSQL
      proficiency_level: 4  # Advanced
      years_experience: 5
      last_assessed: 2024-06-01
      certifications:
        - "PostgreSQL Certified Professional"
      
    - skill: AWS
      proficiency_level: 2  # Basic
      years_experience: 1
      last_assessed: 2024-06-01
      # GAP: Needs improvement!
      
    - skill: Docker
      proficiency_level: 4  # Advanced
      years_experience: 4
      last_assessed: 2024-06-01
      
    - skill: Kubernetes
      proficiency_level: 0  # None
      # MISSING: Needs to learn
      
    - skill: Go
      proficiency_level: 3  # Intermediate
      years_experience: 2
      # EXTRA: Not required but valuable
  
  # Competencies
  competencies:
    - competency: Leadership
      assessed_level: 4  # Advanced
      last_assessed: 2024-01-15
      assessment_method: "360 feedback"
      
    - competency: Problem Solving
      assessed_level: 5  # Expert
      last_assessed: 2024-01-15
      
    - competency: Communication
      assessed_level: 3  # Proficient
      last_assessed: 2024-01-15
      # GAP: Needs development
      
    - competency: Teamwork
      assessed_level: 4  # Advanced
      last_assessed: 2024-01-15
```

---

## 🔍 Skill Gap Analysis

### What is Skill Gap Analysis?

**Definition**: Comparing **what a job requires** vs **what a worker has** to identify gaps and strengths.

**Purpose**:
- ✅ Hiring decisions (candidate qualification)
- ✅ Training needs identification
- ✅ Career development planning
- ✅ Internal mobility (job matching)
- ✅ Succession planning

### Gap Analysis Formula

```yaml
For each skill:
  Gap = Required Proficiency - Current Proficiency
  
  If Gap > 0: SKILL GAP (needs development)
  If Gap = 0: MEETS REQUIREMENT
  If Gap < 0: EXCEEDS REQUIREMENT (strength)
```

### Complete Gap Analysis Example

```yaml
Job: Senior Backend Engineer
Worker: John Doe

# SKILL GAP ANALYSIS

Mandatory Skills:
  
  Python:
    Required: 4 (Advanced)
    Current: 5 (Expert)
    Gap: -1
    Status: ✅ EXCEEDS (Strength!)
    Action: None needed
    
  RESTful API Design:
    Required: 4 (Advanced)
    Current: 4 (Advanced)
    Gap: 0
    Status: ✅ MEETS
    Action: None needed
    
  PostgreSQL:
    Required: 3 (Intermediate)
    Current: 4 (Advanced)
    Gap: -1
    Status: ✅ EXCEEDS (Strength!)
    Action: None needed
    
  AWS:
    Required: 3 (Intermediate)
    Current: 2 (Basic)
    Gap: +1
    Status: ❌ GAP (Training needed!)
    Action: AWS training required
    Priority: HIGH (mandatory skill)
    
  Docker:
    Required: 3 (Intermediate)
    Current: 4 (Advanced)
    Gap: -1
    Status: ✅ EXCEEDS (Strength!)
    Action: None needed

Nice-to-Have Skills:
  
  Kubernetes:
    Required: 3 (Intermediate)
    Current: 0 (None)
    Gap: +3
    Status: ⚠️ MISSING
    Action: Kubernetes training recommended
    Priority: MEDIUM (nice-to-have)
    
  Redis:
    Required: 2 (Basic)
    Current: 0 (None)
    Gap: +2
    Status: ⚠️ MISSING
    Action: Redis training optional
    Priority: LOW (nice-to-have)

Extra Skills (Not Required):
  
  Go:
    Required: N/A
    Current: 3 (Intermediate)
    Status: ℹ️ BONUS
    Action: Valuable additional skill

# COMPETENCY GAP ANALYSIS

Mandatory Competencies:
  
  Leadership:
    Required: 4 (Advanced)
    Current: 4 (Advanced)
    Gap: 0
    Status: ✅ MEETS
    
  Problem Solving:
    Required: 5 (Expert)
    Current: 5 (Expert)
    Gap: 0
    Status: ✅ MEETS
    
  Communication:
    Required: 4 (Advanced)
    Current: 3 (Proficient)
    Gap: +1
    Status: ❌ GAP
    Action: Communication coaching needed
    Priority: HIGH
    
  Teamwork:
    Required: 4 (Advanced)
    Current: 4 (Advanced)
    Gap: 0
    Status: ✅ MEETS

# OVERALL ASSESSMENT

Qualification Score: 85/100
  Mandatory Skills: 4/5 met (80%)
  Nice-to-Have Skills: 0/2 met (0%)
  Competencies: 3/4 met (75%)

Decision: QUALIFIED WITH DEVELOPMENT NEEDS
  
Strengths:
  ✅ Python (Expert level)
  ✅ PostgreSQL (Exceeds requirement)
  ✅ Docker (Exceeds requirement)
  ✅ Problem Solving (Expert level)
  ℹ️ Go programming (Bonus skill)

Gaps (Must Address):
  ❌ AWS (Gap: +1) - HIGH PRIORITY
  ❌ Communication (Gap: +1) - HIGH PRIORITY

Development Opportunities:
  ⚠️ Kubernetes (Gap: +3) - MEDIUM PRIORITY
  ⚠️ Redis (Gap: +2) - LOW PRIORITY

Recommendation:
  ✅ HIRE with condition: Complete AWS training in first 3 months
  ✅ Assign communication coach
  ✅ Kubernetes training in first 6 months
```

---

## 🎯 Use Cases for Skill Gap Analysis

### Use Case 1: Hiring Decision

**Scenario**: Evaluating candidate for Senior Backend Engineer role

```yaml
Candidate: Jane Smith

Gap Analysis Result:
  Mandatory Skills: 5/5 met (100%)
  Nice-to-Have Skills: 2/2 met (100%)
  Competencies: 4/4 met (100%)
  
  Qualification Score: 100/100

Decision: STRONG HIRE
  - Meets all requirements
  - No gaps identified
  - Ready to start immediately
  - No training needed

Offer:
  Level: Senior (L3)
  Grade: Grade 7
  Salary: Top of range (160M VND)
```

---

### Use Case 2: Internal Promotion

**Scenario**: Mid-level engineer applying for senior role

```yaml
Employee: Mike Chen
Current Role: Mid Backend Engineer (L2)
Target Role: Senior Backend Engineer (L3)

Gap Analysis:
  Technical Skills:
    Python: ✅ MEETS (4/4)
    API Design: ✅ MEETS (4/4)
    PostgreSQL: ✅ MEETS (3/3)
    AWS: ❌ GAP (2/3) - needs +1
    Docker: ✅ MEETS (3/3)
    
  Competencies:
    Leadership: ❌ GAP (2/4) - needs +2
    Problem Solving: ✅ MEETS (5/5)
    Communication: ❌ GAP (3/4) - needs +1
    Teamwork: ✅ MEETS (4/4)

Decision: NOT READY YET
  
Development Plan (6 months):
  1. AWS Training
     - Complete AWS Solutions Architect course
     - Build 2 projects using AWS
     - Target: Reach Level 3 by Month 3
     
  2. Leadership Development
     - Lead 1 major project
     - Mentor 2 junior engineers
     - Complete leadership training
     - Target: Reach Level 4 by Month 6
     
  3. Communication Coaching
     - Executive communication workshop
     - Present at 3 team meetings
     - Target: Reach Level 4 by Month 4

Re-assess: After 6 months
```

---

### Use Case 3: Training Needs Analysis

**Scenario**: Identify training needs for engineering team

```yaml
Team: Backend Engineering (10 engineers)

Aggregate Gap Analysis:

AWS Skills:
  Required: Level 3 (all engineers)
  Current Average: Level 2.1
  Gap: +0.9
  
  Engineers with gap:
    - 7/10 engineers below Level 3
    
  Action: Team-wide AWS training
  Priority: HIGH
  Budget: 50M VND
  Timeline: Q1 2024

Kubernetes Skills:
  Required: Level 3 (all engineers)
  Current Average: Level 1.5
  Gap: +1.5
  
  Engineers with gap:
    - 9/10 engineers below Level 3
    
  Action: Kubernetes bootcamp
  Priority: HIGH
  Budget: 60M VND
  Timeline: Q2 2024

Leadership Competency:
  Required: Level 4 (senior engineers only, 4 people)
  Current Average: Level 2.5
  Gap: +1.5
  
  Action: Leadership development program
  Priority: MEDIUM
  Budget: 40M VND
  Timeline: Q3 2024

Total Training Budget: 150M VND
```

---

### Use Case 4: Succession Planning

**Scenario**: Identify successor for Engineering Manager role

```yaml
Target Role: Engineering Manager (M1)

Required Profile:
  Technical Skills:
    - System Design: Level 4
    - Architecture: Level 4
    - Any programming language: Level 4+
    
  Competencies:
    - Leadership: Level 5 (Expert)
    - Strategic Thinking: Level 4
    - People Management: Level 4
    - Communication: Level 5

Candidates Analysis:

Candidate 1: Sarah (Principal Engineer)
  Technical: ✅ Strong (all Level 4+)
  Leadership: ❌ Gap (Level 3, needs +2)
  Strategic Thinking: ✅ Meets (Level 4)
  People Management: ❌ Gap (Level 2, needs +2)
  Communication: ✅ Meets (Level 5)
  
  Readiness: 12-18 months
  Development: Leadership + People management

Candidate 2: Tom (Senior Engineer)
  Technical: ✅ Strong (all Level 4+)
  Leadership: ✅ Meets (Level 5)
  Strategic Thinking: ❌ Gap (Level 3, needs +1)
  People Management: ✅ Meets (Level 4)
  Communication: ✅ Meets (Level 5)
  
  Readiness: 6-12 months
  Development: Strategic thinking

Recommendation: Tom is the primary successor
  - Closer to ready (6-12 months)
  - Only 1 gap (strategic thinking)
  - Already demonstrates leadership
  
  Development Plan:
    - Involve in strategic planning
    - Shadow current manager
    - Lead cross-team initiatives
```

---

## ✅ Best Practices

### 1. Building Skill Catalog

✅ **DO**:
```yaml
Skill Catalog:
  - Start with core skills for key roles
  - Use industry-standard skill names
  - Define clear proficiency scales
  - Include certifications and resources
  - Review and update quarterly
  - Retire obsolete skills
  - Add emerging skills
```

❌ **DON'T**:
```yaml
# Too granular
Skill: "Python 3.9 on Ubuntu 20.04"
# Too generic
Skill: "Programming"

# Use standard names
✅ Python
✅ JavaScript
✅ AWS
❌ "Coding in snake language"
```

---

### 2. Assessing Skills

✅ **DO**:
```yaml
Assessment Methods:
  Technical Skills:
    - Technical interviews
    - Coding tests
    - Project reviews
    - Certifications
    - Peer reviews
    
  Competencies:
    - 360-degree feedback
    - Behavioral interviews
    - Performance reviews
    - Manager observations
    
  Frequency:
    - Annual formal assessment
    - Continuous informal feedback
    - Update after major projects
```

❌ **DON'T**:
```yaml
# Self-assessment only
Worker: "I'm Level 5 in everything!"
# No validation

# Never update
Last assessed: 2018
# Outdated!

# No documentation
Assessment method: "I think so"
# Not credible
```

---

### 3. Gap Analysis

✅ **DO**:
```yaml
Gap Analysis Process:
  1. Define job requirements clearly
  2. Assess worker skills objectively
  3. Calculate gaps systematically
  4. Prioritize gaps (mandatory vs nice-to-have)
  5. Create development plans
  6. Track progress
  7. Re-assess regularly
```

❌ **DON'T**:
```yaml
# Ignore gaps
Gap identified: AWS Level 2, need Level 3
Action: None
# Problem persists!

# Unrealistic expectations
Gap: +3 levels
Timeline: 1 month
# Impossible!
```

---

### 4. Development Planning

✅ **DO**:
```yaml
Development Plan:
  Skill: AWS
  Current: Level 2
  Target: Level 3
  Timeline: 3 months
  
  Actions:
    - Complete AWS Solutions Architect course (Month 1)
    - Build 2 projects using AWS (Month 2-3)
    - Get AWS certification (Month 3)
    - Pair with AWS expert (ongoing)
    
  Success Criteria:
    - Pass AWS certification exam
    - Deploy 2 production projects on AWS
    - Demonstrate Level 3 proficiency in assessment
    
  Support:
    - Training budget: 10M VND
    - Study time: 4 hours/week
    - Mentor: Senior Engineer John
```

❌ **DON'T**:
```yaml
# Vague plan
Development Plan:
  Skill: AWS
  Action: "Learn AWS"
  Timeline: "Soon"
  # Not actionable!
```

---

## ⚠️ Common Pitfalls

### Pitfall 1: Inflated Self-Assessment

❌ **Problem**:
```yaml
Worker Self-Assessment:
  Python: Level 5 (Expert)
  AWS: Level 4 (Advanced)
  Leadership: Level 5 (Expert)
  
Manager Assessment:
  Python: Level 3 (Intermediate)
  AWS: Level 2 (Basic)
  Leadership: Level 2 (Developing)
  
# Huge discrepancy!
```

✅ **Solution**:
```yaml
Validation Process:
  1. Self-assessment (worker)
  2. Manager assessment
  3. Peer feedback
  4. Objective tests/certifications
  5. Calibration meeting
  6. Final agreed rating
```

---

### Pitfall 2: Outdated Skill Data

❌ **Problem**:
```yaml
Worker Skills:
  Last assessed: 2019
  Current year: 2024
  # 5 years old!
  
  Skills may have:
    - Improved significantly
    - Degraded (not used)
    - Become obsolete
```

✅ **Solution**:
```yaml
Regular Updates:
  - Annual formal assessment
  - Update after major projects
  - Update after training
  - Update after certifications
  - Continuous feedback
```

---

### Pitfall 3: Ignoring Competencies

❌ **Problem**:
```yaml
Hiring Decision:
  Technical Skills: ✅ All met
  Competencies: ❌ Not assessed
  
  Result:
    - Hired technically strong candidate
    - Poor communication skills
    - Cannot work in team
    - Performance issues
```

✅ **Solution**:
```yaml
Balanced Assessment:
  Technical Skills: 50% weight
  Competencies: 50% weight
  
  Both must meet minimum requirements
```

---

### Pitfall 4: No Development Follow-up

❌ **Problem**:
```yaml
Development Plan Created:
  Date: 2024-01-01
  
Follow-up:
  None
  
Result:
  - Plan forgotten
  - No progress
  - Gap persists
```

✅ **Solution**:
```yaml
Development Tracking:
  - Monthly check-ins
  - Progress reviews
  - Adjust plan as needed
  - Celebrate milestones
  - Re-assess at end
```

---

## 📊 Skill Gap Analysis Metrics

### Individual Metrics

```yaml
Worker: John Doe

Skill Coverage:
  Mandatory Skills Met: 4/5 (80%)
  Nice-to-Have Skills Met: 0/2 (0%)
  Overall Skill Coverage: 57%

Competency Coverage:
  Mandatory Competencies Met: 3/4 (75%)

Qualification Score: 75/100

Development Progress:
  Skills in Development: 2
  Skills Improved (last 6 months): 3
  Certifications Earned: 1
```

### Team Metrics

```yaml
Team: Backend Engineering (10 engineers)

Team Skill Coverage:
  AWS: 30% (3/10 engineers at required level)
  Kubernetes: 10% (1/10 engineers at required level)
  Python: 90% (9/10 engineers at required level)

Average Qualification Score: 72/100

Training Investment:
  Budget: 150M VND
  Engineers in Training: 8/10
  Completion Rate: 75%

Skill Improvement:
  Engineers Improved: 7/10
  Average Improvement: +0.8 levels
```

---

## 🎓 Quick Reference

### Skill Gap Analysis Checklist

**For Hiring**:
- [ ] Define job requirements (skills + competencies)
- [ ] Assess candidate (interview + tests)
- [ ] Calculate gaps
- [ ] Evaluate mandatory vs nice-to-have
- [ ] Make hire/no-hire decision
- [ ] Create onboarding development plan

**For Development**:
- [ ] Assess current skills
- [ ] Identify target role
- [ ] Calculate gaps
- [ ] Prioritize gaps
- [ ] Create development plan
- [ ] Assign resources (budget, time, mentor)
- [ ] Track progress
- [ ] Re-assess

**For Team Planning**:
- [ ] Assess all team members
- [ ] Aggregate gaps
- [ ] Identify common gaps
- [ ] Plan team training
- [ ] Allocate budget
- [ ] Schedule training
- [ ] Track completion
- [ ] Measure improvement

---

## 📚 Related Guides

- [Job & Position Management Guide](./03-job-position-guide.md) - Job profiles and requirements
- [Employment Lifecycle Guide](./01-employment-lifecycle-guide.md) - Worker and employee data
- [Organization Structure Guide](./02-organization-structure-guide.md) - Organizational context

---

## 🔗 References

### Industry Standards
- **SFIA** (Skills Framework for the Information Age) - IT skills framework
- **O*NET** - Occupational skills database
- **CEFR** - Common European Framework of Reference for Languages
- **PMI** - Project Management competencies

### Further Reading
- [glossary-common.md](../00-ontology/glossary-common.md) - SkillMaster and CompetencyMaster
- [glossary-person.md](../00-ontology/glossary-person.md) - WorkerSkill and WorkerCompetency

---

**Document Version**: 1.0  
**Created**: 2025-12-02  
**Last Review**: 2025-12-02
