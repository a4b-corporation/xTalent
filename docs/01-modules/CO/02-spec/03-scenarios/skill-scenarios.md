# Skill Management Scenarios - Core Module

**Version**: 2.0  
**Last Updated**: 2025-12-03  
**Module**: Core (CO)  
**Status**: Complete - Skill Assessment & Development Workflows

---

## 📋 Overview

This document defines detailed end-to-end scenarios for skill management in the Core Module. Each scenario provides step-by-step workflows for skill assessment, gap analysis, skill development, endorsements, and certifications.

### Scenario Categories

1. **Skill Catalog Scenarios** - Building and maintaining skill taxonomy
2. **Skill Assessment Scenarios** - Evaluating employee skills
3. **Skill Gap Analysis Scenarios** - Identifying development needs
4. **Skill Endorsement Scenarios** - Peer validation
5. **Certification Management Scenarios** - Tracking professional certifications

---

## 🎓 Scenario 1: Build Skill Catalog and Taxonomy

### Overview

**Scenario**: Create comprehensive skill catalog for technology organization

**Actors**:
- HR Administrator
- Learning & Development Manager
- Technical Leads

**Preconditions**:
- Job profiles exist
- Competency framework defined
- Skill categories identified

---

### Main Flow

#### Step 1: Create Skill Taxonomy

**Actor**: HR Administrator

**Action**: Create skill taxonomy structure

**Input Data**:
```json
{
  "code": "TECH-SKILLS",
  "name": "Technology Skills Taxonomy",
  "description": "Technical skills for engineering roles",
  "taxonomy_type": "SKILL"
}
```

**API Call**:
```http
POST /api/v1/skill-taxonomies
Authorization: Bearer {token}
Content-Type: application/json
```

**Expected Output**:
```json
{
  "id": "skill-tax-uuid-tech",
  "code": "TECH-SKILLS",
  "name": "Technology Skills Taxonomy",
  "created_at": "2025-01-01T09:00:00Z"
}
```

---

#### Step 2: Create Skill Categories

**Actor**: HR Administrator

**Action**: Create skill categories (Level 1)

**Input Data** (Programming Languages):
```json
{
  "taxonomy_id": "skill-tax-uuid-tech",
  "code": "PROG-LANG",
  "name": "Programming Languages",
  "description": "Programming and scripting languages",
  "category_type": "TECHNICAL",
  "sort_order": 1
}
```

**API Call**:
```http
POST /api/v1/skill-categories
```

**Create multiple categories**:
```json
[
  {"code": "PROG-LANG", "name": "Programming Languages"},
  {"code": "FRAMEWORKS", "name": "Frameworks & Libraries"},
  {"code": "DATABASES", "name": "Databases"},
  {"code": "CLOUD", "name": "Cloud Platforms"},
  {"code": "DEVOPS", "name": "DevOps & Tools"},
  {"code": "SOFT-SKILLS", "name": "Soft Skills"}
]
```

**Data Changes**:
- `skill_categories` table: INSERT 6 rows

---

#### Step 3: Create Skills

**Actor**: HR Administrator

**Action**: Create individual skills under categories

**Input Data** (Python):
```json
{
  "code": "PYTHON",
  "name": "Python Programming",
  "description": "Python programming language proficiency",
  "skill_category_id": "cat-uuid-prog-lang",
  "skill_type": "TECHNICAL",
  "is_active": true,
  "synonyms": ["Python", "Python3", "Python 3.x"]
}
```

**API Call**:
```http
POST /api/v1/skills
```

**Business Rules Applied**:
- BR-SKL-001: Skill Creation

**Expected Output**:
```json
{
  "id": "skill-uuid-python",
  "code": "PYTHON",
  "name": "Python Programming",
  "category": "Programming Languages",
  "created_at": "2025-01-01T09:10:00Z"
}
```

**Create comprehensive skill set**:
```json
{
  "programming_languages": [
    {"code": "PYTHON", "name": "Python Programming"},
    {"code": "JAVA", "name": "Java Programming"},
    {"code": "JAVASCRIPT", "name": "JavaScript"},
    {"code": "TYPESCRIPT", "name": "TypeScript"},
    {"code": "GO", "name": "Go Programming"}
  ],
  "frameworks": [
    {"code": "REACT", "name": "React.js"},
    {"code": "DJANGO", "name": "Django"},
    {"code": "SPRING", "name": "Spring Framework"}
  ],
  "databases": [
    {"code": "POSTGRESQL", "name": "PostgreSQL"},
    {"code": "MONGODB", "name": "MongoDB"},
    {"code": "REDIS", "name": "Redis"}
  ],
  "cloud": [
    {"code": "AWS", "name": "Amazon Web Services"},
    {"code": "GCP", "name": "Google Cloud Platform"},
    {"code": "AZURE", "name": "Microsoft Azure"}
  ],
  "soft_skills": [
    {"code": "LEADERSHIP", "name": "Technical Leadership"},
    {"code": "COMMUNICATION", "name": "Communication"},
    {"code": "PROBLEM-SOLVING", "name": "Problem Solving"}
  ]
}
```

**Data Changes**:
- `skills` table: INSERT 20+ rows

---

#### Step 4: Define Proficiency Levels

**Actor**: HR Administrator

**Action**: Define standard proficiency levels

**Input Data**:
```json
{
  "levels": [
    {
      "code": "BEGINNER",
      "name": "Beginner",
      "description": "Basic understanding, requires guidance",
      "rank": 1
    },
    {
      "code": "INTERMEDIATE",
      "name": "Intermediate",
      "description": "Can work independently on routine tasks",
      "rank": 2
    },
    {
      "code": "ADVANCED",
      "name": "Advanced",
      "description": "Expert level, can mentor others",
      "rank": 3
    },
    {
      "code": "EXPERT",
      "name": "Expert",
      "description": "Industry expert, thought leader",
      "rank": 4
    }
  ]
}
```

**API Call**:
```http
POST /api/v1/skill-proficiency-levels/bulk
```

**Business Rules Applied**:
- BR-SKL-020: Proficiency Levels

---

#### Step 5: Verify Skill Catalog

**Actor**: HR Administrator

**Action**: Get complete skill catalog

**API Call**:
```http
GET /api/v1/skills/catalog
```

**Expected Output**:
```json
{
  "catalog": {
    "total_skills": 25,
    "categories": [
      {
        "name": "Programming Languages",
        "skills_count": 5,
        "skills": [
          {
            "code": "PYTHON",
            "name": "Python Programming",
            "proficiency_levels": ["BEGINNER", "INTERMEDIATE", "ADVANCED", "EXPERT"]
          }
        ]
      },
      {
        "name": "Soft Skills",
        "skills_count": 3,
        "skills": [...]
      }
    ]
  }
}
```

---

### Postconditions

**System State**:
- ✅ Skill taxonomy created
- ✅ 6 skill categories created
- ✅ 25+ skills created
- ✅ 4 proficiency levels defined
- ✅ Skill catalog ready for assessment
- ✅ Skills linked to categories

**Data Summary**:
- Skill Taxonomies: +1
- Skill Categories: +6
- Skills: +25
- Proficiency Levels: +4
- Audit Logs: +36

---

## 📊 Scenario 2: Employee Skill Assessment (Manager-Led)

### Overview

**Scenario**: Manager assesses employee skills during performance review

**Actors**:
- Manager
- Employee
- HR Administrator

**Preconditions**:
- Employee has active assignment
- Skill catalog exists
- Job profile has required skills
- Performance review cycle active

---

### Main Flow

#### Step 1: View Employee Current Skills

**Actor**: Manager

**Action**: Review employee's current skill profile

**API Call**:
```http
GET /api/v1/employees/{employeeId}/skills
```

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "employee_number": "EMP-000456",
  "full_name": "Nguyễn Văn An",
  "job_title": "Senior Software Engineer",
  "current_skills": [
    {
      "skill_code": "PYTHON",
      "skill_name": "Python Programming",
      "proficiency_level": "INTERMEDIATE",
      "assessment_source": "SELF_ASSESSED",
      "assessment_date": "2024-12-01",
      "assessor": "Self"
    },
    {
      "skill_code": "JAVASCRIPT",
      "skill_name": "JavaScript",
      "proficiency_level": "ADVANCED",
      "assessment_source": "MANAGER_ASSESSED",
      "assessment_date": "2024-06-15",
      "assessor": "Trần Thị Bình"
    }
  ],
  "total_skills": 8
}
```

---

#### Step 2: Assess Employee Skills

**Actor**: Manager

**Action**: Assess or update employee skills

**Input Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "assessments": [
    {
      "skill_id": "skill-uuid-python",
      "proficiency_level": "ADVANCED",
      "assessment_source": "MANAGER_ASSESSED",
      "assessment_date": "2025-01-15",
      "comments": "Demonstrated advanced Python skills in recent projects. Led backend refactoring initiative.",
      "evidence": [
        "Led microservices migration project",
        "Mentored 2 junior engineers in Python best practices",
        "Contributed to internal Python framework"
      ]
    },
    {
      "skill_id": "skill-uuid-system-design",
      "proficiency_level": "ADVANCED",
      "assessment_source": "MANAGER_ASSESSED",
      "assessment_date": "2025-01-15",
      "comments": "Excellent system design skills. Designed scalable architecture for payment system."
    },
    {
      "skill_id": "skill-uuid-leadership",
      "proficiency_level": "INTERMEDIATE",
      "assessment_source": "MANAGER_ASSESSED",
      "assessment_date": "2025-01-15",
      "comments": "Growing leadership skills. Ready for team lead role."
    }
  ]
}
```

**API Call**:
```http
POST /api/v1/employees/{employeeId}/skills/assess
```

**Business Rules Applied**:
- BR-ASS-001: Skill Assignment

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "assessments_completed": 3,
  "skills_updated": 2,
  "skills_added": 1,
  "assessment_date": "2025-01-15",
  "assessed_by": "Trần Thị Bình"
}
```

**Data Changes**:
- `employee_skills` table: UPDATE 2 rows, INSERT 1 row
- `skill_assessment_history` table: INSERT 3 rows
- `audit_logs` table: INSERT 3 rows

---

#### Step 3: Add New Skills

**Actor**: Manager

**Action**: Add newly acquired skills

**Input Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "skill_id": "skill-uuid-kubernetes",
  "proficiency_level": "INTERMEDIATE",
  "assessment_source": "MANAGER_ASSESSED",
  "assessment_date": "2025-01-15",
  "acquisition_method": "ON_THE_JOB",
  "comments": "Learned Kubernetes through platform migration project"
}
```

**API Call**:
```http
POST /api/v1/employees/{employeeId}/skills
```

---

#### Step 4: View Updated Skill Profile

**Actor**: Manager

**Action**: Review complete skill profile

**API Call**:
```http
GET /api/v1/employees/{employeeId}/skills/summary
```

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "skill_summary": {
    "total_skills": 12,
    "by_proficiency": {
      "EXPERT": 0,
      "ADVANCED": 5,
      "INTERMEDIATE": 6,
      "BEGINNER": 1
    },
    "by_category": {
      "Programming Languages": 4,
      "Frameworks": 3,
      "Cloud Platforms": 2,
      "Soft Skills": 3
    },
    "recently_assessed": 3,
    "last_assessment_date": "2025-01-15"
  }
}
```

---

### Postconditions

**System State**:
- ✅ Employee skills assessed by manager
- ✅ 3 skills updated with new proficiency levels
- ✅ 1 new skill added
- ✅ Assessment history recorded
- ✅ Evidence documented
- ✅ Ready for gap analysis

**Data Summary**:
- Employee Skills: 2 updated, 1 inserted
- Assessment History: +3
- Audit Logs: +3

---

## 🎯 Scenario 3: Skill Gap Analysis and Development Planning

### Overview

**Scenario**: Identify skill gaps and create development plan

**Actors**:
- Employee
- Manager
- Learning & Development Team

**Preconditions**:
- Employee skills assessed
- Job profile has required skills
- Career path defined

---

### Main Flow

#### Step 1: Generate Skill Gap Analysis

**Actor**: Manager

**Action**: Compare employee skills to job requirements

**API Call**:
```http
GET /api/v1/employees/{employeeId}/skill-gaps
```

**Business Rules Applied**:
- BR-ASS-020: Skill Gap Analysis

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "employee_number": "EMP-000456",
  "current_job": {
    "code": "SWE-SR",
    "title": "Senior Software Engineer"
  },
  "skill_gap_analysis": {
    "required_skills_met": 8,
    "required_skills_total": 10,
    "proficiency_gaps": [
      {
        "skill_code": "PYTHON",
        "skill_name": "Python Programming",
        "required_level": "EXPERT",
        "current_level": "ADVANCED",
        "gap": 1,
        "gap_severity": "LOW",
        "priority": "MEDIUM"
      },
      {
        "skill_code": "SYSTEM-DESIGN",
        "skill_name": "System Design",
        "required_level": "EXPERT",
        "current_level": "ADVANCED",
        "gap": 1,
        "gap_severity": "LOW",
        "priority": "MEDIUM"
      }
    ],
    "missing_skills": [
      {
        "skill_code": "MICROSERVICES",
        "skill_name": "Microservices Architecture",
        "required_level": "ADVANCED",
        "current_level": null,
        "gap_severity": "MEDIUM",
        "priority": "HIGH"
      },
      {
        "skill_code": "DISTRIBUTED-SYSTEMS",
        "skill_name": "Distributed Systems",
        "required_level": "INTERMEDIATE",
        "current_level": null,
        "gap_severity": "MEDIUM",
        "priority": "HIGH"
      }
    ],
    "overall_readiness": 80
  }
}
```

---

#### Step 2: Create Development Plan

**Actor**: Manager

**Action**: Create skill development plan

**Input Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "development_plan": {
    "plan_name": "Senior to Lead Engineer Development Plan",
    "start_date": "2025-02-01",
    "target_completion_date": "2025-08-01",
    "objectives": [
      "Close skill gaps for current role",
      "Prepare for Lead Engineer promotion"
    ],
    "skill_development_items": [
      {
        "skill_id": "skill-uuid-microservices",
        "target_proficiency": "ADVANCED",
        "development_activities": [
          {
            "activity_type": "TRAINING",
            "activity_name": "Microservices Architecture Course",
            "provider": "Udemy",
            "duration_hours": 40,
            "target_date": "2025-03-31"
          },
          {
            "activity_type": "PROJECT",
            "activity_name": "Lead microservices migration project",
            "duration_hours": 160,
            "target_date": "2025-06-30"
          }
        ]
      },
      {
        "skill_id": "skill-uuid-distributed-systems",
        "target_proficiency": "INTERMEDIATE",
        "development_activities": [
          {
            "activity_type": "READING",
            "activity_name": "Designing Data-Intensive Applications",
            "target_date": "2025-04-30"
          },
          {
            "activity_type": "MENTORING",
            "activity_name": "Mentorship from Staff Engineer",
            "mentor_id": "emp-uuid-staff-engineer",
            "duration_hours": 20,
            "target_date": "2025-07-31"
          }
        ]
      },
      {
        "skill_id": "skill-uuid-leadership",
        "target_proficiency": "ADVANCED",
        "development_activities": [
          {
            "activity_type": "TRAINING",
            "activity_name": "Technical Leadership Program",
            "provider": "Internal L&D",
            "duration_hours": 24,
            "target_date": "2025-05-31"
          },
          {
            "activity_type": "PRACTICE",
            "activity_name": "Lead team of 3 engineers on new project",
            "target_date": "2025-08-01"
          }
        ]
      }
    ]
  }
}
```

**API Call**:
```http
POST /api/v1/employees/{employeeId}/development-plans
```

**Expected Output**:
```json
{
  "development_plan_id": "plan-uuid-001",
  "employee_id": "emp-uuid-001",
  "plan_name": "Senior to Lead Engineer Development Plan",
  "total_skills": 3,
  "total_activities": 7,
  "estimated_hours": 244,
  "start_date": "2025-02-01",
  "target_completion_date": "2025-08-01",
  "status": "ACTIVE",
  "created_at": "2025-01-15T14:00:00Z"
}
```

---

#### Step 3: Track Development Progress

**Actor**: Employee/Manager

**Action**: Update progress on development activities

**Input Data**:
```json
{
  "development_plan_id": "plan-uuid-001",
  "activity_updates": [
    {
      "activity_id": "activity-uuid-001",
      "status": "COMPLETED",
      "completion_date": "2025-03-25",
      "hours_spent": 42,
      "comments": "Completed Microservices course with certification"
    },
    {
      "activity_id": "activity-uuid-002",
      "status": "IN_PROGRESS",
      "progress_pct": 60,
      "hours_spent": 96,
      "comments": "Migration project 60% complete"
    }
  ]
}
```

**API Call**:
```http
PUT /api/v1/development-plans/{planId}/progress
```

---

#### Step 4: Reassess Skills

**Actor**: Manager

**Action**: Reassess skills after development activities

**Input Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "skill_id": "skill-uuid-microservices",
  "proficiency_level": "INTERMEDIATE",
  "assessment_source": "MANAGER_ASSESSED",
  "assessment_date": "2025-04-01",
  "comments": "Completed training and demonstrating skills in migration project"
}
```

**API Call**:
```http
PUT /api/v1/employees/{employeeId}/skills/{skillId}
```

---

### Postconditions

**System State**:
- ✅ Skill gaps identified (2 proficiency gaps, 2 missing skills)
- ✅ Development plan created
- ✅ 7 development activities defined
- ✅ Progress tracking active
- ✅ Skills reassessed after development
- ✅ Gap closure monitored

**Data Summary**:
- Development Plans: +1
- Development Activities: +7
- Skill Updates: +2
- Audit Logs: +10

---

## 👍 Scenario 4: Skill Endorsement and Peer Validation

### Overview

**Scenario**: Employees endorse colleague's skills

**Actors**:
- Employee (Endorser)
- Employee (Endorsed)
- Manager

**Preconditions**:
- Both employees active
- Skills exist in catalog
- Endorsement feature enabled

---

### Main Flow

#### Step 1: View Colleague's Skills

**Actor**: Employee (Endorser)

**Action**: View colleague's skill profile

**API Call**:
```http
GET /api/v1/employees/{employeeId}/skills/public
```

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "full_name": "Nguyễn Văn An",
  "job_title": "Senior Software Engineer",
  "public_skills": [
    {
      "skill_code": "PYTHON",
      "skill_name": "Python Programming",
      "proficiency_level": "ADVANCED",
      "endorsements_count": 3,
      "can_endorse": true
    },
    {
      "skill_code": "SYSTEM-DESIGN",
      "skill_name": "System Design",
      "proficiency_level": "ADVANCED",
      "endorsements_count": 2,
      "can_endorse": true
    }
  ]
}
```

---

#### Step 2: Endorse Skills

**Actor**: Employee (Endorser)

**Action**: Endorse colleague's skills

**Input Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "endorser_id": "emp-uuid-endorser",
  "endorsements": [
    {
      "skill_id": "skill-uuid-python",
      "endorsement_type": "WORKED_TOGETHER",
      "comments": "Worked together on payment system. Excellent Python skills and code quality.",
      "project_context": "Payment System Refactoring Q4 2024"
    },
    {
      "skill_id": "skill-uuid-system-design",
      "endorsement_type": "WORKED_TOGETHER",
      "comments": "Designed scalable architecture for high-traffic payment processing."
    }
  ]
}
```

**API Call**:
```http
POST /api/v1/employees/{employeeId}/skills/endorse
```

**Business Rules Applied**:
- BR-ASS-025: Skill Endorsement

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "endorsements_added": 2,
  "endorsed_by": "Lê Văn Cường",
  "endorsement_date": "2025-01-20T10:00:00Z"
}
```

**Data Changes**:
- `skill_endorsements` table: INSERT 2 rows
- `employee_skills` table: UPDATE 2 rows (increment endorsement_count)

---

#### Step 3: View Endorsements

**Actor**: Employee (Endorsed)

**Action**: View who endorsed skills

**API Call**:
```http
GET /api/v1/employees/me/skills/{skillId}/endorsements
```

**Expected Output**:
```json
{
  "skill_code": "PYTHON",
  "skill_name": "Python Programming",
  "total_endorsements": 4,
  "endorsements": [
    {
      "endorser": "Lê Văn Cường",
      "endorser_job_title": "Lead Software Engineer",
      "endorsement_type": "WORKED_TOGETHER",
      "endorsement_date": "2025-01-20",
      "comments": "Worked together on payment system. Excellent Python skills.",
      "project_context": "Payment System Refactoring Q4 2024"
    },
    {
      "endorser": "Phạm Thị Dung",
      "endorser_job_title": "Senior Software Engineer",
      "endorsement_type": "PEER_REVIEW",
      "endorsement_date": "2025-01-10",
      "comments": "Reviewed code. Clean, well-tested Python code."
    }
  ]
}
```

---

### Postconditions

**System State**:
- ✅ 2 skills endorsed
- ✅ Endorsement count updated
- ✅ Endorser and context recorded
- ✅ Social proof of skills established

**Data Summary**:
- Skill Endorsements: +2
- Employee Skills: 2 updated (endorsement counts)
- Audit Logs: +2

---

## 🎓 Scenario 5: Certification Management

### Overview

**Scenario**: Track professional certifications and licenses

**Actors**:
- Employee
- Manager
- HR Administrator

**Preconditions**:
- Employee active
- Certification catalog exists
- Skills linked to certifications

---

### Main Flow

#### Step 1: Add Certification

**Actor**: Employee

**Action**: Record professional certification

**Input Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "certification_name": "AWS Certified Solutions Architect - Professional",
  "issuing_organization": "Amazon Web Services",
  "certification_id": "AWS-SAP-123456",
  "issue_date": "2024-12-15",
  "expiry_date": "2027-12-15",
  "credential_url": "https://aws.amazon.com/verification/123456",
  "related_skills": [
    "skill-uuid-aws",
    "skill-uuid-cloud-architecture",
    "skill-uuid-system-design"
  ],
  "document_attachment": "cert-aws-sap.pdf"
}
```

**API Call**:
```http
POST /api/v1/employees/{employeeId}/certifications
```

**Business Rules Applied**:
- BR-ASS-026: Skill Certification

**Expected Output**:
```json
{
  "certification_id": "cert-uuid-001",
  "employee_id": "emp-uuid-001",
  "certification_name": "AWS Certified Solutions Architect - Professional",
  "status": "ACTIVE",
  "issue_date": "2024-12-15",
  "expiry_date": "2027-12-15",
  "days_until_expiry": 1077,
  "related_skills_updated": 3,
  "created_at": "2025-01-20T11:00:00Z"
}
```

**Data Changes**:
- `certifications` table: INSERT 1 row
- `employee_skills` table: UPDATE 3 rows (mark as CERTIFIED)
- `audit_logs` table: INSERT 1 row

---

#### Step 2: Update Skills Based on Certification

**Actor**: System (Automated)

**Action**: Automatically update skill proficiency

**Process**:
1. Identify skills related to certification
2. Update assessment source to CERTIFIED
3. Suggest proficiency level based on certification level
4. Notify employee and manager

**Data Changes**:
```json
{
  "employee_id": "emp-uuid-001",
  "skills_updated": [
    {
      "skill_code": "AWS",
      "old_proficiency": "INTERMEDIATE",
      "new_proficiency": "ADVANCED",
      "assessment_source": "CERTIFIED",
      "certification_id": "cert-uuid-001"
    },
    {
      "skill_code": "CLOUD-ARCHITECTURE",
      "old_proficiency": "INTERMEDIATE",
      "new_proficiency": "ADVANCED",
      "assessment_source": "CERTIFIED"
    }
  ]
}
```

---

#### Step 3: Certification Expiry Tracking

**Actor**: System (Automated)

**Action**: Monitor certification expiry and send notifications

**Notification Schedule**:
- 90 days before expiry: First reminder
- 30 days before expiry: Second reminder
- 7 days before expiry: Final reminder
- On expiry: Status updated to EXPIRED

**API Call** (Get expiring certifications):
```http
GET /api/v1/certifications/expiring?days=90
```

**Expected Output**:
```json
{
  "expiring_certifications": [
    {
      "employee_number": "EMP-000456",
      "employee_name": "Nguyễn Văn An",
      "certification_name": "AWS Certified Solutions Architect",
      "expiry_date": "2025-04-15",
      "days_until_expiry": 85,
      "renewal_required": true,
      "renewal_url": "https://aws.amazon.com/certification/recertify"
    }
  ]
}
```

---

#### Step 4: Renew Certification

**Actor**: Employee

**Action**: Update certification after renewal

**Input Data**:
```json
{
  "certification_id": "cert-uuid-001",
  "renewal_date": "2027-12-01",
  "new_expiry_date": "2030-12-01",
  "new_certification_id": "AWS-SAP-789012",
  "document_attachment": "cert-aws-sap-renewed.pdf"
}
```

**API Call**:
```http
POST /api/v1/certifications/{certId}/renew
```

**Expected Output**:
```json
{
  "certification_id": "cert-uuid-001",
  "status": "ACTIVE",
  "renewal_date": "2027-12-01",
  "new_expiry_date": "2030-12-01",
  "renewal_count": 1,
  "days_until_expiry": 2191
}
```

---

#### Step 5: Certification Portfolio

**Actor**: Employee

**Action**: View complete certification portfolio

**API Call**:
```http
GET /api/v1/employees/me/certifications
```

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "certification_summary": {
    "total_certifications": 5,
    "active": 4,
    "expired": 1,
    "expiring_soon": 1
  },
  "certifications": [
    {
      "certification_name": "AWS Certified Solutions Architect - Professional",
      "status": "ACTIVE",
      "issue_date": "2024-12-15",
      "expiry_date": "2027-12-15",
      "related_skills": ["AWS", "Cloud Architecture", "System Design"]
    },
    {
      "certification_name": "Certified Kubernetes Administrator",
      "status": "ACTIVE",
      "issue_date": "2024-06-01",
      "expiry_date": "2027-06-01"
    },
    {
      "certification_name": "Professional Scrum Master I",
      "status": "ACTIVE",
      "issue_date": "2023-03-15",
      "expiry_date": null
    }
  ]
}
```

---

### Postconditions

**System State**:
- ✅ Certification recorded
- ✅ Related skills updated to CERTIFIED
- ✅ Proficiency levels adjusted
- ✅ Expiry tracking active
- ✅ Renewal reminders scheduled
- ✅ Certification portfolio maintained

**Data Summary**:
- Certifications: +1
- Employee Skills: 3 updated
- Expiry Notifications: Scheduled
- Audit Logs: +4

---

## 📊 Scenario Summary

### Scenarios Covered

| Scenario | Complexity | Actors | Steps | Business Rules |
|----------|------------|--------|-------|----------------|
| **Build Skill Catalog** | Medium | 3 | 5 | 2 |
| **Skill Assessment (Manager-Led)** | Medium | 3 | 4 | 1 |
| **Skill Gap Analysis** | High | 3 | 4 | 1 |
| **Skill Endorsement** | Low | 2 | 3 | 1 |
| **Certification Management** | Medium | 3 | 5 | 1 |

### Key Operations Covered

**Skill Catalog**:
- ✅ Create skill taxonomy
- ✅ Define skill categories
- ✅ Create skills (25+ skills)
- ✅ Define proficiency levels
- ✅ Verify skill catalog

**Skill Assessment**:
- ✅ View current skills
- ✅ Manager assessment
- ✅ Self-assessment
- ✅ Add new skills
- ✅ Update proficiency levels
- ✅ Document evidence

**Gap Analysis**:
- ✅ Identify proficiency gaps
- ✅ Identify missing skills
- ✅ Calculate readiness score
- ✅ Create development plan
- ✅ Track progress
- ✅ Reassess after development

**Endorsements**:
- ✅ View colleague skills
- ✅ Endorse skills
- ✅ Add context and comments
- ✅ View endorsements received
- ✅ Social proof tracking

**Certifications**:
- ✅ Add certification
- ✅ Link to skills
- ✅ Auto-update skill proficiency
- ✅ Track expiry
- ✅ Renewal management
- ✅ Certification portfolio

---

## 🎯 Skill Development Journey

### Complete Employee Journey

```yaml
Step 1: Skill Assessment
  - Manager assesses current skills
  - Employee self-assesses
  - Skills recorded in system

Step 2: Gap Analysis
  - Compare to job requirements
  - Identify gaps (proficiency + missing)
  - Calculate readiness score

Step 3: Development Planning
  - Create development plan
  - Define activities (training, projects, mentoring)
  - Set target dates and proficiency levels

Step 4: Skill Development
  - Complete training courses
  - Work on projects
  - Receive mentoring
  - Track progress

Step 5: Reassessment
  - Manager reassesses skills
  - Update proficiency levels
  - Document improvements

Step 6: Validation
  - Peers endorse skills
  - Obtain certifications
  - Build skill portfolio

Step 7: Career Progression
  - Skills meet job requirements
  - Ready for promotion
  - Career path advancement
```

---

## 📈 Skill Analytics

### Key Metrics

**Individual Level**:
- Total skills count
- Skills by proficiency level
- Skills by category
- Endorsement count
- Certification count
- Skill gap score
- Development plan progress

**Team Level**:
- Team skill matrix
- Skill coverage by proficiency
- Critical skill gaps
- Skill demand vs supply
- Certification coverage

**Organization Level**:
- Skill inventory
- Skill trends over time
- High-demand skills
- Skill shortage areas
- Certification compliance

---

## 🔗 Related Documentation

- [Functional Requirements](../01-functional-requirements.md) - Skill FRs
- [Business Rules](../04-business-rules.md) - BR-SKL, BR-ASS rules
- [API Specification](../02-api-specification.md) - Skill APIs
- [Career Paths Guide](../../01-concept/08-career-paths-guide.md) - Concepts

---

**Document Version**: 2.0  
**Created**: 2025-12-03  
**Scenarios**: 5 detailed skill management workflows  
**Maintained By**: Product Team + L&D Team  
**Status**: Complete - Ready for Implementation
