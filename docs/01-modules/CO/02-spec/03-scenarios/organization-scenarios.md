# Organization Scenarios - Core Module

**Version**: 2.0  
**Last Updated**: 2025-12-03  
**Module**: Core (CO)  
**Status**: Complete - Organizational Change Workflows

---

## 📋 Overview

This document defines detailed end-to-end scenarios for organizational structure changes in the Core Module. Each scenario provides step-by-step workflows for reorganizations, manager changes, business unit operations, and matrix organization management.

### Scenario Categories

1. **Business Unit Scenarios** - Creating and managing organizational units
2. **Reorganization Scenarios** - Structural changes
3. **Manager Change Scenarios** - Reporting relationship changes
4. **Matrix Organization Scenarios** - Dual reporting structures
5. **Hierarchy Management Scenarios** - Organizational hierarchy operations

---

## 🏢 Scenario 1: Create Business Unit Hierarchy

### Overview

**Scenario**: Create a new business unit hierarchy for a new department

**Actors**:
- HR Administrator
- Department Head
- Finance Team

**Preconditions**:
- Parent business unit exists
- Department head identified
- Budget approved
- Effective date confirmed

---

### Main Flow

#### Step 1: Create Parent Business Unit

**Actor**: HR Administrator

**Action**: Create top-level department

**Input Data**:
```json
{
  "code": "PRODUCT",
  "name": "Product Department",
  "unit_type": "OPERATIONAL",
  "parent_unit_id": "bu-uuid-company-root",
  "manager_id": "emp-uuid-vp-product",
  "location_id": "loc-uuid-hcm",
  "cost_center": "CC-PRODUCT",
  "effective_start_date": "2025-01-01",
  "description": "Product management and development"
}
```

**API Call**:
```http
POST /api/v1/business-units
Authorization: Bearer {token}
Content-Type: application/json
```

**Business Rules Applied**:
- BR-BU-001: Business Unit Creation
- BR-BU-002: Business Unit Hierarchy

**Expected Output**:
```json
{
  "id": "bu-uuid-product",
  "code": "PRODUCT",
  "name": "Product Department",
  "unit_type": "OPERATIONAL",
  "hierarchy_level": 2,
  "hierarchy_path": "/bu-uuid-company-root/bu-uuid-product/",
  "manager": {
    "employee_number": "EMP-000100",
    "full_name": "Nguyễn Văn A"
  },
  "created_at": "2024-12-01T10:00:00Z"
}
```

**Data Changes**:
- `business_units` table: INSERT 1 row
- `audit_logs` table: INSERT 1 row

---

#### Step 2: Create Sub-Units (Teams)

**Actor**: HR Administrator

**Action**: Create teams under department

**Input Data** (Team 1):
```json
{
  "code": "PRODUCT-MOBILE",
  "name": "Mobile Product Team",
  "unit_type": "OPERATIONAL",
  "parent_unit_id": "bu-uuid-product",
  "manager_id": "emp-uuid-mobile-lead",
  "location_id": "loc-uuid-hcm",
  "cost_center": "CC-PRODUCT-MOBILE",
  "effective_start_date": "2025-01-01"
}
```

**API Call**:
```http
POST /api/v1/business-units
```

**Expected Output**:
```json
{
  "id": "bu-uuid-product-mobile",
  "code": "PRODUCT-MOBILE",
  "name": "Mobile Product Team",
  "hierarchy_level": 3,
  "hierarchy_path": "/bu-uuid-company-root/bu-uuid-product/bu-uuid-product-mobile/",
  "parent_unit": "Product Department"
}
```

**Repeat for additional teams**:
- Product-Web Team
- Product-Platform Team
- Product-Analytics Team

**Data Changes**:
- `business_units` table: INSERT 4 rows (1 parent + 3 sub-units)

---

#### Step 3: Verify Hierarchy

**Actor**: HR Administrator

**Action**: Get complete hierarchy tree

**API Call**:
```http
GET /api/v1/business-units/hierarchy-tree?root_unit_id=bu-uuid-product
```

**Expected Output**:
```json
{
  "root": {
    "id": "bu-uuid-product",
    "code": "PRODUCT",
    "name": "Product Department",
    "manager": "Nguyễn Văn A",
    "headcount": 0,
    "children": [
      {
        "id": "bu-uuid-product-mobile",
        "code": "PRODUCT-MOBILE",
        "name": "Mobile Product Team",
        "manager": "Trần Thị B",
        "headcount": 0,
        "children": []
      },
      {
        "id": "bu-uuid-product-web",
        "code": "PRODUCT-WEB",
        "name": "Web Product Team",
        "manager": "Lê Văn C",
        "headcount": 0,
        "children": []
      }
    ]
  }
}
```

---

### Postconditions

**System State**:
- ✅ Parent business unit created (PRODUCT)
- ✅ 3 sub-units created (Mobile, Web, Platform)
- ✅ Hierarchy paths calculated
- ✅ Managers assigned
- ✅ Cost centers assigned
- ✅ Ready for employee assignments

**Data Summary**:
- Business Units: +4
- Hierarchy Levels: 2-3
- Audit Logs: +4

---

## 🔄 Scenario 2: Department Reorganization

### Overview

**Scenario**: Reorganize department by moving teams to different parent units

**Actors**:
- HR Administrator
- Department Heads
- Affected Employees
- Finance Team

**Preconditions**:
- Reorganization plan approved
- New structure defined
- Effective date confirmed
- Communication plan ready

---

### Main Flow

#### Step 1: Analyze Current Structure

**Actor**: HR Administrator

**Action**: Get current organization structure

**API Call**:
```http
GET /api/v1/business-units/bu-uuid-engineering/headcount
```

**Expected Output**:
```json
{
  "business_unit_id": "bu-uuid-engineering",
  "business_unit_name": "Engineering",
  "direct_headcount": 10,
  "total_headcount": 150,
  "sub_units": [
    {
      "code": "ENG-BACKEND",
      "name": "Backend Engineering",
      "headcount": 50
    },
    {
      "code": "ENG-FRONTEND",
      "name": "Frontend Engineering",
      "headcount": 40
    },
    {
      "code": "ENG-MOBILE",
      "name": "Mobile Engineering",
      "headcount": 30
    },
    {
      "code": "ENG-PLATFORM",
      "name": "Platform Engineering",
      "headcount": 20
    }
  ]
}
```

---

#### Step 2: Create New Parent Unit

**Actor**: HR Administrator

**Action**: Create new "Product Engineering" unit

**Input Data**:
```json
{
  "code": "PRODUCT-ENG",
  "name": "Product Engineering",
  "unit_type": "OPERATIONAL",
  "parent_unit_id": "bu-uuid-company-root",
  "manager_id": "emp-uuid-product-eng-vp",
  "effective_start_date": "2025-02-01"
}
```

**API Call**:
```http
POST /api/v1/business-units
```

---

#### Step 3: Move Teams to New Parent

**Actor**: HR Administrator

**Action**: Move Frontend and Mobile teams to Product Engineering

**Input Data** (Move Frontend):
```json
{
  "business_unit_id": "bu-uuid-eng-frontend",
  "new_parent_unit_id": "bu-uuid-product-eng",
  "effective_date": "2025-02-01",
  "reason": "Reorganization - Product Engineering formation"
}
```

**API Call**:
```http
POST /api/v1/business-units/reorganize
```

**Business Rules Applied**:
- BR-BU-002: Business Unit Hierarchy
- Hierarchy paths recalculated
- Employee assignments remain unchanged
- Manager assignments remain unchanged

**Expected Output**:
```json
{
  "reorganization_id": "reorg-uuid-001",
  "business_unit_id": "bu-uuid-eng-frontend",
  "old_parent": "Engineering",
  "new_parent": "Product Engineering",
  "old_hierarchy_path": "/root/engineering/frontend/",
  "new_hierarchy_path": "/root/product-eng/frontend/",
  "affected_employees": 40,
  "effective_date": "2025-02-01",
  "status": "COMPLETED"
}
```

**Repeat for Mobile team**

---

#### Step 4: Update Reporting Lines

**Actor**: HR Administrator

**Action**: Update manager for moved teams (if needed)

**Input Data**:
```json
{
  "business_unit_id": "bu-uuid-eng-frontend",
  "new_manager_id": "emp-uuid-frontend-new-manager",
  "effective_date": "2025-02-01"
}
```

**API Call**:
```http
PUT /api/v1/business-units/{buId}/manager
```

---

#### Step 5: Bulk Update Employee Assignments

**Actor**: System (Automated)

**Action**: Update business_unit_id for all affected assignments

**Process**:
1. Get all active assignments in moved units
2. Update business_unit_id to reflect new hierarchy
3. Maintain assignment history (SCD Type 2)
4. Update reporting chains

**Data Changes**:
- `assignments` table: UPDATE 70 rows (40 Frontend + 30 Mobile)
- `business_units` table: UPDATE 2 rows (new parent_unit_id)
- `audit_logs` table: INSERT 72 rows

---

#### Step 6: Verify New Structure

**Actor**: HR Administrator

**Action**: Verify reorganization completed

**API Call**:
```http
GET /api/v1/business-units/hierarchy-tree
```

**Expected Output**:
```json
{
  "root": {
    "name": "Company",
    "children": [
      {
        "name": "Engineering",
        "headcount": 70,
        "children": [
          {"name": "Backend Engineering", "headcount": 50},
          {"name": "Platform Engineering", "headcount": 20}
        ]
      },
      {
        "name": "Product Engineering",
        "headcount": 70,
        "children": [
          {"name": "Frontend Engineering", "headcount": 40},
          {"name": "Mobile Engineering", "headcount": 30}
        ]
      }
    ]
  }
}
```

---

#### Step 7: Communication

**Actor**: HR Administrator

**Action**: Send reorganization notifications

**Notifications Sent**:

1. **To All Affected Employees** (70 people):
   - Subject: "Organization Update: New Product Engineering Division"
   - Content: New structure, new reporting lines, effective date

2. **To All Managers**:
   - Subject: "Reorganization Complete"
   - Content: New org chart, updated headcount

3. **To Finance**:
   - Subject: "Cost Center Updates"
   - Content: New hierarchy, cost center mappings

---

### Postconditions

**System State**:
- ✅ New "Product Engineering" unit created
- ✅ 2 teams moved (Frontend, Mobile)
- ✅ Hierarchy paths recalculated
- ✅ 70 employee assignments updated
- ✅ Reporting chains updated
- ✅ Historical data preserved
- ✅ Notifications sent

**Data Summary**:
- Business Units: +1 created, 2 moved
- Assignments: 70 updated
- Audit Logs: +72
- Notifications: +73

---

### Alternative Flows

#### A1: Merge Business Units

**Condition**: Consolidating two units into one

**Flow**:
1. Create new merged unit (or designate one as target)
2. Move all employees from source units to target
3. Deactivate source units
4. Update hierarchy

**API Call**:
```http
POST /api/v1/business-units/merge
```

---

#### A2: Split Business Unit

**Condition**: Dividing one unit into multiple

**Flow**:
1. Create new child units
2. Distribute employees across new units
3. Update parent unit headcount
4. Recalculate hierarchy

**API Call**:
```http
POST /api/v1/business-units/split
```

---

## 👔 Scenario 3: Manager Change (Solid Line)

### Overview

**Scenario**: Change an employee's direct manager

**Actors**:
- HR Administrator
- Old Manager
- New Manager
- Employee

**Preconditions**:
- New manager identified
- Change approved
- Effective date confirmed

---

### Main Flow

#### Step 1: Get Current Manager

**Actor**: HR Administrator

**Action**: View current reporting relationship

**API Call**:
```http
GET /api/v1/employees/{employeeId}/reporting-chain
```

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "employee_number": "EMP-000456",
  "full_name": "Nguyễn Văn An",
  "reporting_chain": [
    {
      "level": 1,
      "employee_id": "emp-uuid-manager-old",
      "employee_number": "EMP-000100",
      "full_name": "Trần Thị Bình",
      "job_title": "Engineering Manager",
      "relationship_type": "SOLID_LINE"
    },
    {
      "level": 2,
      "employee_id": "emp-uuid-director",
      "full_name": "Lê Văn Cường",
      "job_title": "Director of Engineering"
    }
  ]
}
```

---

#### Step 2: Change Solid Line Manager

**Actor**: HR Administrator

**Action**: Assign new solid line manager

**Input Data**:
```json
{
  "assignment_id": "asg-uuid-001",
  "new_manager_id": "emp-uuid-manager-new",
  "effective_date": "2025-03-01",
  "reason": "Team restructure"
}
```

**API Call**:
```http
POST /api/v1/assignments/{asgId}/solid-line-manager
```

**Business Rules Applied**:
- BR-MTX-001: Solid Line Manager
- BR-ASG-004: Manager Assignment Validation
- BR-MTX-010: Circular Reporting Detection

**Expected Output**:
```json
{
  "assignment_id": "asg-uuid-001",
  "old_manager_id": "emp-uuid-manager-old",
  "new_manager_id": "emp-uuid-manager-new",
  "manager_type": "SOLID_LINE",
  "effective_date": "2025-03-01",
  "change_reason": "Team restructure",
  "created_at": "2025-02-15T10:00:00Z"
}
```

**Data Changes**:
- `assignments` table: UPDATE 1 row (SCD Type 2 - new version)
- `manager_history` table: INSERT 1 row
- `audit_logs` table: INSERT 1 row

---

#### Step 3: Verify Reporting Chain

**Actor**: HR Administrator

**Action**: Verify new reporting chain

**API Call**:
```http
GET /api/v1/employees/{employeeId}/reporting-chain
```

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "reporting_chain": [
    {
      "level": 1,
      "employee_id": "emp-uuid-manager-new",
      "employee_number": "EMP-000200",
      "full_name": "Phạm Thị Dung",
      "job_title": "Senior Engineering Manager",
      "relationship_type": "SOLID_LINE"
    },
    {
      "level": 2,
      "employee_id": "emp-uuid-vp",
      "full_name": "Hoàng Văn Em",
      "job_title": "VP Engineering"
    }
  ]
}
```

---

#### Step 4: Update Direct Reports

**Actor**: System (Automated)

**Action**: Update manager's direct reports lists

**Old Manager**:
- Remove employee from direct reports list
- Update headcount (-1)

**New Manager**:
- Add employee to direct reports list
- Update headcount (+1)

---

#### Step 5: Notifications

**Notifications Sent**:

1. **To Employee**:
   - Subject: "Manager Change Notification"
   - Content: New manager details, effective date, introduction

2. **To Old Manager**:
   - Subject: "Team Update: Nguyễn Văn An"
   - Content: Employee moving to new manager, knowledge transfer

3. **To New Manager**:
   - Subject: "New Team Member: Nguyễn Văn An"
   - Content: Employee background, current projects, start date

---

### Postconditions

**System State**:
- ✅ Solid line manager changed
- ✅ Reporting chain updated
- ✅ Direct reports lists updated
- ✅ Manager history recorded
- ✅ Notifications sent

**Data Summary**:
- Assignments: 1 updated (new version)
- Manager History: +1
- Audit Logs: +1
- Notifications: +3

---

## 🔀 Scenario 4: Matrix Organization Setup (Dual Reporting)

### Overview

**Scenario**: Set up dual reporting for employee in matrix organization

**Actors**:
- HR Administrator
- Solid Line Manager (Functional)
- Dotted Line Manager (Project)
- Employee

**Preconditions**:
- Employee has active assignment
- Both managers identified
- Time allocation agreed
- Matrix structure approved

---

### Main Flow

#### Step 1: Verify Current Reporting

**Actor**: HR Administrator

**Action**: Check current manager setup

**API Call**:
```http
GET /api/v1/employees/{employeeId}/managers
```

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "managers": [
    {
      "manager_id": "emp-uuid-functional-mgr",
      "manager_type": "SOLID_LINE",
      "full_name": "Trần Thị Bình",
      "job_title": "Engineering Manager",
      "time_allocation_pct": 100,
      "effective_date": "2025-01-15"
    }
  ]
}
```

---

#### Step 2: Add Dotted Line Manager

**Actor**: HR Administrator

**Action**: Assign dotted line manager (project manager)

**Input Data**:
```json
{
  "assignment_id": "asg-uuid-001",
  "manager_id": "emp-uuid-project-mgr",
  "manager_type": "DOTTED_LINE",
  "time_allocation_pct": 40,
  "effective_date": "2025-04-01",
  "reason": "Assigned to Project Phoenix"
}
```

**API Call**:
```http
POST /api/v1/assignments/{asgId}/dotted-line-manager
```

**Business Rules Applied**:
- BR-MTX-002: Dotted Line Manager
- BR-MTX-005: Manager Time Allocation

**Expected Output**:
```json
{
  "assignment_id": "asg-uuid-001",
  "manager_id": "emp-uuid-project-mgr",
  "manager_type": "DOTTED_LINE",
  "time_allocation_pct": 40,
  "effective_date": "2025-04-01",
  "created_at": "2025-03-20T10:00:00Z"
}
```

---

#### Step 3: Adjust Time Allocation

**Actor**: HR Administrator

**Action**: Update time allocation percentages

**Input Data**:
```json
{
  "assignment_id": "asg-uuid-001",
  "manager_allocations": [
    {
      "manager_id": "emp-uuid-functional-mgr",
      "manager_type": "SOLID_LINE",
      "time_allocation_pct": 60
    },
    {
      "manager_id": "emp-uuid-project-mgr",
      "manager_type": "DOTTED_LINE",
      "time_allocation_pct": 40
    }
  ]
}
```

**API Call**:
```http
PUT /api/v1/assignments/{asgId}/manager-allocation
```

**Business Rules Applied**:
- BR-MTX-005: Total allocation must equal 100%

**Expected Output**:
```json
{
  "assignment_id": "asg-uuid-001",
  "total_allocation": 100,
  "allocations": [
    {
      "manager_type": "SOLID_LINE",
      "allocation_pct": 60
    },
    {
      "manager_type": "DOTTED_LINE",
      "allocation_pct": 40
    }
  ],
  "updated_at": "2025-03-20T10:05:00Z"
}
```

---

#### Step 4: Verify Matrix Setup

**Actor**: HR Administrator

**Action**: Get complete manager setup

**API Call**:
```http
GET /api/v1/employees/{employeeId}/managers
```

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "employee_number": "EMP-000456",
  "full_name": "Nguyễn Văn An",
  "managers": [
    {
      "manager_id": "emp-uuid-functional-mgr",
      "manager_type": "SOLID_LINE",
      "full_name": "Trần Thị Bình",
      "job_title": "Engineering Manager",
      "department": "Backend Engineering",
      "time_allocation_pct": 60,
      "has_approval_authority": true
    },
    {
      "manager_id": "emp-uuid-project-mgr",
      "manager_type": "DOTTED_LINE",
      "full_name": "Lê Văn Cường",
      "job_title": "Project Manager",
      "department": "Project Phoenix",
      "time_allocation_pct": 40,
      "has_approval_authority": false
    }
  ],
  "total_allocation": 100
}
```

---

#### Step 5: View Matrix Organization

**Actor**: HR Administrator

**Action**: View matrix organization structure

**API Call**:
```http
GET /api/v1/org-structure/matrix-view?business_unit_id=bu-uuid-engineering
```

**Expected Output**:
```json
{
  "business_unit": "Engineering",
  "matrix_employees": [
    {
      "employee_number": "EMP-000456",
      "full_name": "Nguyễn Văn An",
      "solid_line_manager": "Trần Thị Bình (60%)",
      "dotted_line_managers": [
        "Lê Văn Cường (40%) - Project Phoenix"
      ],
      "total_managers": 2
    }
  ]
}
```

---

#### Step 6: Notifications

**Notifications Sent**:

1. **To Employee**:
   - Subject: "Matrix Reporting Setup"
   - Content: Dual reporting structure, time allocation, expectations

2. **To Solid Line Manager**:
   - Subject: "Matrix Reporting: Nguyễn Văn An"
   - Content: Dotted line manager added, time allocation 60%

3. **To Dotted Line Manager**:
   - Subject: "New Project Team Member: Nguyễn Văn An"
   - Content: Employee details, time allocation 40%, coordination role

---

### Postconditions

**System State**:
- ✅ Solid line manager: Functional manager (60%)
- ✅ Dotted line manager: Project manager (40%)
- ✅ Total time allocation: 100%
- ✅ Approval authority: Solid line only
- ✅ Matrix structure documented
- ✅ Both managers notified

**Data Summary**:
- Assignments: 1 updated (manager relationships)
- Manager Allocations: 2 records
- Audit Logs: +2
- Notifications: +3

---

### Alternative Flows

#### A1: Multiple Dotted Line Managers

**Condition**: Employee reports to multiple project managers

**Example**:
- Solid Line: 50%
- Dotted Line 1: 30%
- Dotted Line 2: 20%
- Total: 100%

---

#### A2: Remove Dotted Line Manager

**Condition**: Project completed, remove dotted line reporting

**API Call**:
```http
DELETE /api/v1/assignments/{asgId}/dotted-line-manager/{managerId}
```

**Result**:
- Dotted line manager removed
- Solid line allocation returns to 100%

---

## 📊 Scenario 5: Span of Control Analysis

### Overview

**Scenario**: Analyze manager span of control for organizational optimization

**Actors**:
- HR Manager
- Senior Leadership

**Preconditions**:
- Organization structure exists
- Managers have direct reports
- Analysis criteria defined

---

### Main Flow

#### Step 1: Get Span of Control Report

**Actor**: HR Manager

**Action**: Generate span of control analysis

**API Call**:
```http
GET /api/v1/reports/span-of-control?business_unit_id=bu-uuid-engineering
```

**Expected Output**:
```json
{
  "business_unit": "Engineering",
  "analysis_date": "2025-12-03",
  "summary": {
    "total_managers": 25,
    "average_span": 6.2,
    "median_span": 6,
    "min_span": 2,
    "max_span": 15
  },
  "managers": [
    {
      "employee_number": "EMP-000100",
      "full_name": "Trần Thị Bình",
      "job_title": "Engineering Manager",
      "direct_reports_count": 8,
      "span_status": "OPTIMAL",
      "recommendation": "None"
    },
    {
      "employee_number": "EMP-000200",
      "full_name": "Lê Văn Cường",
      "job_title": "Senior Engineering Manager",
      "direct_reports_count": 15,
      "span_status": "TOO_WIDE",
      "recommendation": "Consider adding team lead or splitting team"
    },
    {
      "employee_number": "EMP-000300",
      "full_name": "Phạm Thị Dung",
      "job_title": "Engineering Manager",
      "direct_reports_count": 2,
      "span_status": "TOO_NARROW",
      "recommendation": "Consider consolidating with another team"
    }
  ],
  "recommendations": {
    "too_wide": 3,
    "too_narrow": 2,
    "optimal": 20
  }
}
```

---

#### Step 2: Analyze Outliers

**Actor**: HR Manager

**Action**: Identify managers needing intervention

**Criteria**:
- Too Wide: > 12 direct reports
- Too Narrow: < 3 direct reports
- Optimal: 5-10 direct reports

---

#### Step 3: Action Planning

**Actor**: HR Manager

**Actions for Too Wide Span**:
1. Add team lead positions
2. Split team into sub-teams
3. Redistribute direct reports

**Actions for Too Narrow Span**:
1. Merge teams
2. Reassign manager to IC role
3. Add more direct reports

---

### Postconditions

**System State**:
- ✅ Span of control analyzed
- ✅ Outliers identified
- ✅ Recommendations generated
- ✅ Action plan created

---

## 📊 Scenario Summary

### Scenarios Covered

| Scenario | Complexity | Actors | Steps | Business Rules |
|----------|------------|--------|-------|----------------|
| **Create Business Unit Hierarchy** | Medium | 3 | 3 | 2 |
| **Department Reorganization** | High | 4 | 7 | 3 |
| **Manager Change (Solid Line)** | Medium | 4 | 5 | 3 |
| **Matrix Organization Setup** | High | 4 | 6 | 3 |
| **Span of Control Analysis** | Low | 2 | 3 | 0 |

### Common Patterns

**All scenarios follow**:
1. ✅ Current state verification
2. ✅ Business rule enforcement
3. ✅ Hierarchy recalculation
4. ✅ Data integrity maintenance
5. ✅ Audit trail creation
6. ✅ Stakeholder notification

---

## 🎯 Key Organizational Operations

### Business Unit Operations
- ✅ Create hierarchy
- ✅ Move units (reorganization)
- ✅ Merge units
- ✅ Split units
- ✅ Deactivate units

### Manager Operations
- ✅ Change solid line manager
- ✅ Add dotted line manager
- ✅ Remove dotted line manager
- ✅ Adjust time allocation
- ✅ Verify reporting chains

### Matrix Organization
- ✅ Dual reporting setup
- ✅ Time allocation management
- ✅ Approval authority definition
- ✅ Matrix view reporting

### Analysis & Reporting
- ✅ Span of control analysis
- ✅ Headcount by unit
- ✅ Hierarchy visualization
- ✅ Organizational metrics

---

## 🔗 Related Documentation

- [Functional Requirements](../01-functional-requirements.md) - BU, Matrix FRs
- [Business Rules](../04-business-rules.md) - BR-BU, BR-MTX rules
- [API Specification](../02-api-specification.md) - Organization APIs
- [Matrix Organizations Guide](../../01-concept/07-matrix-organizations-guide.md) - Concepts

---

**Document Version**: 2.0  
**Created**: 2025-12-03  
**Scenarios**: 5 detailed organizational workflows  
**Maintained By**: Product Team + Business Analysts  
**Status**: Complete - Ready for Implementation
