# Employment Scenarios - Core Module

**Version**: 2.0  
**Last Updated**: 2025-12-03  
**Module**: Core (CO)  
**Status**: Complete - End-to-End Workflows

---

## 📋 Overview

This document defines detailed end-to-end scenarios for employment lifecycle events in the Core Module. Each scenario provides step-by-step workflows, data requirements, business rules, and expected outcomes.

### Scenario Categories

1. **Hiring Scenarios** - New employee onboarding
2. **Transfer Scenarios** - Internal mobility
3. **Promotion Scenarios** - Career advancement
4. **Termination Scenarios** - Employment ending
5. **Special Scenarios** - Edge cases and exceptions

---

## 🎯 Scenario 1: New Employee Hire (Position-Based)

### Overview

**Scenario**: Hire a new employee for an approved vacant position

**Actors**:
- HR Administrator
- Hiring Manager
- New Employee
- IT Department
- Facilities

**Preconditions**:
- Position is approved and vacant
- Offer letter signed by candidate
- Background check completed
- Start date confirmed

---

### Main Flow

#### Step 1: Create Worker Record

**Actor**: HR Administrator

**Action**: Create worker record for new hire

**Input Data**:
```json
{
  "full_name": "Nguyễn Văn An",
  "preferred_name": "An",
  "date_of_birth": "1990-01-15",
  "gender_code": "M",
  "person_type": "EMPLOYEE",
  "national_id": "001234567890",
  "email": "an.nguyen@company.com",
  "phone": "+84901234567",
  "address": {
    "street": "123 Nguyễn Huệ",
    "city": "Ho Chi Minh City",
    "country": "Vietnam"
  }
}
```

**API Call**:
```http
POST /api/v1/workers
Authorization: Bearer {token}
Content-Type: application/json
```

**Business Rules Applied**:
- BR-WRK-001: Worker Creation Validation
- BR-WRK-002: Worker Code Generation
- BR-WRK-004: Data Classification Enforcement

**Expected Output**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "code": "WORKER-000123",
  "full_name": "Nguyễn Văn An",
  "person_type": "EMPLOYEE",
  "created_at": "2025-01-01T09:00:00Z"
}
```

**Data Changes**:
- `workers` table: INSERT 1 row
- `audit_logs` table: INSERT 1 row

---

#### Step 2: Create Work Relationship

**Actor**: HR Administrator

**Action**: Create EMPLOYEE work relationship

**Input Data**:
```json
{
  "worker_id": "550e8400-e29b-41d4-a716-446655440001",
  "relationship_type": "EMPLOYEE",
  "legal_entity_id": "legal-entity-uuid",
  "start_date": "2025-01-15",
  "end_date": null,
  "employment_type": "FULL_TIME",
  "contract_type": "PERMANENT",
  "probation_period_days": 90
}
```

**API Call**:
```http
POST /api/v1/work-relationships
```

**Business Rules Applied**:
- BR-WR-001: Work Relationship Creation
- BR-WR-002: Work Relationship Type Validation
- BR-WR-032: Probation Period Validation

**Expected Output**:
```json
{
  "id": "wr-uuid-001",
  "worker_id": "550e8400-e29b-41d4-a716-446655440001",
  "relationship_type": "EMPLOYEE",
  "status": "ACTIVE",
  "start_date": "2025-01-15",
  "probation_end_date": "2025-04-15",
  "created_at": "2025-01-01T09:05:00Z"
}
```

**Data Changes**:
- `work_relationships` table: INSERT 1 row
- `audit_logs` table: INSERT 1 row

---

#### Step 3: Create Employee Record

**Actor**: HR Administrator

**Action**: Create employee record

**Input Data**:
```json
{
  "worker_id": "550e8400-e29b-41d4-a716-446655440001",
  "work_relationship_id": "wr-uuid-001",
  "employee_number": null,
  "hire_date": "2025-01-15",
  "probation_end_date": "2025-04-15",
  "original_hire_date": "2025-01-15"
}
```

**API Call**:
```http
POST /api/v1/employees
```

**Business Rules Applied**:
- BR-EMP-001: Employee Creation Validation
- BR-EMP-002: Employee Number Generation

**Expected Output**:
```json
{
  "id": "emp-uuid-001",
  "employee_number": "EMP-000456",
  "hire_date": "2025-01-15",
  "status": "ACTIVE",
  "probation_status": "ON_PROBATION",
  "created_at": "2025-01-01T09:10:00Z"
}
```

**Data Changes**:
- `employees` table: INSERT 1 row
- `audit_logs` table: INSERT 1 row

---

#### Step 4: Create Assignment

**Actor**: HR Administrator

**Action**: Create primary assignment to position

**Input Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "assignment_type": "PRIMARY",
  "staffing_model": "POSITION_BASED",
  "position_id": "pos-uuid-eng-001",
  "job_id": "job-uuid-swe-sr",
  "business_unit_id": "bu-uuid-engineering",
  "location_id": "loc-uuid-hcm",
  "manager_id": "emp-uuid-manager",
  "start_date": "2025-01-15",
  "fte": 1.0
}
```

**API Call**:
```http
POST /api/v1/assignments
```

**Business Rules Applied**:
- BR-ASG-001: Assignment Creation Validation
- BR-ASG-002: Staffing Model Validation
- BR-ASG-004: Manager Assignment Validation

**Expected Output**:
```json
{
  "id": "asg-uuid-001",
  "employee_id": "emp-uuid-001",
  "assignment_type": "PRIMARY",
  "position_code": "POS-ENG-001",
  "job_title": "Senior Software Engineer",
  "status": "ACTIVE",
  "created_at": "2025-01-01T09:15:00Z"
}
```

**Data Changes**:
- `assignments` table: INSERT 1 row
- `positions` table: UPDATE 1 row (status → FILLED)
- `audit_logs` table: INSERT 2 rows

---

#### Step 5: System Notifications

**Actor**: System

**Action**: Send automated notifications

**Notifications Sent**:

1. **To New Employee**:
   - Subject: "Welcome to Company!"
   - Content: Welcome email, onboarding checklist, first day information
   - Attachments: Employee handbook, IT setup guide

2. **To Manager**:
   - Subject: "New Team Member: Nguyễn Văn An"
   - Content: New hire details, start date, onboarding responsibilities

3. **To IT Department**:
   - Subject: "IT Setup Required: EMP-000456"
   - Content: Employee details, equipment needs, account creation

4. **To Facilities**:
   - Subject: "Workspace Setup: New Hire"
   - Content: Desk assignment, access cards, parking

**API Call**:
```http
POST /api/v1/notifications/bulk
```

**Data Changes**:
- `notifications` table: INSERT 4 rows

---

### Postconditions

**System State**:
- ✅ Worker record created (WORKER-000123)
- ✅ Work relationship active (EMPLOYEE, PERMANENT)
- ✅ Employee record active (EMP-000456)
- ✅ Assignment active (PRIMARY, POSITION_BASED)
- ✅ Position status updated (VACANT → FILLED)
- ✅ Probation tracking enabled (ends 2025-04-15)
- ✅ Notifications sent to all stakeholders

**Data Summary**:
- Workers: +1
- Work Relationships: +1
- Employees: +1
- Assignments: +1
- Positions: 1 updated
- Audit Logs: +6
- Notifications: +4

---

### Alternative Flows

#### A1: Worker Already Exists (Rehire)

**Condition**: Worker record exists from previous employment

**Flow**:
1. Skip Step 1 (Worker creation)
2. Verify previous employment is terminated
3. Check rehire eligibility (BR-EMP-015)
4. Continue from Step 2

**Business Rules**:
- BR-EMP-015: Rehire Validation

---

#### A2: Job-Based Staffing (No Position)

**Condition**: Organization uses job-based staffing

**Flow**:
1. Steps 1-3 remain the same
2. Step 4: Modified assignment creation
   - No position_id
   - staffing_model: "JOB_BASED"
   - Position status not updated

**Business Rules**:
- BR-ASG-002: Staffing Model Validation

---

### Exception Flows

#### E1: Validation Error

**Condition**: Data validation fails

**Flow**:
1. System returns validation error
2. HR Admin corrects data
3. Retry operation

**Example Error**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid date of birth",
    "details": [
      {
        "field": "date_of_birth",
        "message": "Must be a past date"
      }
    ]
  }
}
```

---

#### E2: Duplicate Employee Number

**Condition**: Auto-generated employee number conflicts

**Flow**:
1. System detects duplicate
2. Auto-generate new number
3. Continue process

**Business Rules**:
- BR-EMP-002: Employee Number Generation

---

#### E3: Position Not Vacant

**Condition**: Position is already filled

**Flow**:
1. System returns error
2. HR Admin verifies position status
3. Either:
   - Select different position
   - End current assignment first
   - Use job-based staffing

**Error Message**:
```json
{
  "error": {
    "code": "ASG_POSITION_NOT_VACANT",
    "message": "Position POS-ENG-001 is not vacant"
  }
}
```

---

## 🔄 Scenario 2: Internal Transfer (Lateral Move)

### Overview

**Scenario**: Transfer employee to different department (same level)

**Actors**:
- HR Administrator
- Current Manager
- New Manager
- Employee

**Preconditions**:
- Employee has active assignment
- Target position/job is available
- Transfer approved by both managers
- Effective date confirmed

---

### Main Flow

#### Step 1: Verify Current Assignment

**Actor**: HR Administrator

**Action**: Get employee's current assignment

**API Call**:
```http
GET /api/v1/employees/{employeeId}/assignments/current
```

**Expected Output**:
```json
{
  "id": "asg-uuid-001",
  "employee_id": "emp-uuid-001",
  "assignment_type": "PRIMARY",
  "position_code": "POS-ENG-001",
  "job_title": "Senior Software Engineer",
  "business_unit": "Engineering - Backend",
  "manager": "Trần Thị Bình",
  "start_date": "2025-01-15",
  "status": "ACTIVE"
}
```

---

#### Step 2: Create Transfer Request

**Actor**: HR Administrator

**Action**: Execute transfer

**Input Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "from_assignment_id": "asg-uuid-001",
  "to_business_unit_id": "bu-uuid-product",
  "to_job_id": "job-uuid-product-manager",
  "to_position_id": "pos-uuid-pm-001",
  "to_manager_id": "emp-uuid-new-manager",
  "effective_date": "2025-02-01",
  "transfer_type": "LATERAL",
  "reason": "Career development - moving to product management",
  "requires_approval": true
}
```

**API Call**:
```http
POST /api/v1/assignments/transfer
```

**Business Rules Applied**:
- BR-ASG-015: Transfer Validation

**Expected Output**:
```json
{
  "transfer_id": "transfer-uuid-001",
  "old_assignment_id": "asg-uuid-001",
  "new_assignment_id": "asg-uuid-002",
  "transfer_type": "LATERAL",
  "effective_date": "2025-02-01",
  "status": "APPROVED",
  "created_at": "2025-01-20T10:00:00Z"
}
```

---

#### Step 3: End Current Assignment

**Actor**: System (Automated)

**Action**: End current assignment on effective date

**Data Changes**:
```json
{
  "assignment_id": "asg-uuid-001",
  "end_date": "2025-01-31",
  "status": "ENDED",
  "end_reason": "TRANSFER"
}
```

**Business Rules Applied**:
- SCD Type 2: Previous assignment retained with end date

**Data Changes**:
- `assignments` table: UPDATE 1 row (set end_date, is_current_flag = false)
- `positions` table: UPDATE 1 row (status → VACANT)

---

#### Step 4: Create New Assignment

**Actor**: System (Automated)

**Action**: Create new assignment

**Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "assignment_type": "PRIMARY",
  "staffing_model": "POSITION_BASED",
  "position_id": "pos-uuid-pm-001",
  "job_id": "job-uuid-product-manager",
  "business_unit_id": "bu-uuid-product",
  "manager_id": "emp-uuid-new-manager",
  "start_date": "2025-02-01",
  "fte": 1.0,
  "previous_assignment_id": "asg-uuid-001"
}
```

**Data Changes**:
- `assignments` table: INSERT 1 row
- `positions` table: UPDATE 1 row (status → FILLED)

---

#### Step 5: Notifications

**Notifications Sent**:

1. **To Employee**:
   - Subject: "Transfer Confirmation"
   - Content: New role details, start date, new manager

2. **To Current Manager**:
   - Subject: "Team Member Transfer: Nguyễn Văn An"
   - Content: Transfer details, last day, handover

3. **To New Manager**:
   - Subject: "New Team Member: Nguyễn Văn An"
   - Content: Transfer details, start date, background

4. **To IT/Facilities**:
   - Subject: "Employee Transfer: Access Updates"
   - Content: New location, access changes

---

### Postconditions

**System State**:
- ✅ Old assignment ended (2025-01-31)
- ✅ New assignment active (2025-02-01)
- ✅ Old position vacant
- ✅ New position filled
- ✅ Manager changed
- ✅ Business unit changed
- ✅ Transfer history recorded

**Data Summary**:
- Assignments: 1 updated, 1 inserted
- Positions: 2 updated
- Audit Logs: +4
- Notifications: +4

---

### Alternative Flows

#### A1: Job-Based Transfer

**Condition**: No positions involved

**Flow**:
- No position status updates
- Only job and business unit change

---

#### A2: Transfer with Approval Workflow

**Condition**: Transfer requires multi-level approval

**Flow**:
1. Create transfer request (status: PENDING)
2. Current manager approves
3. New manager approves
4. HR approves
5. Execute transfer on effective date

---

## 📈 Scenario 3: Promotion

### Overview

**Scenario**: Promote employee to higher-level position

**Actors**:
- HR Administrator
- Current Manager
- Employee

**Preconditions**:
- Employee meets promotion criteria
- Higher-level position available
- Promotion approved
- Effective date confirmed

---

### Main Flow

#### Step 1: Verify Promotion Eligibility

**Actor**: HR Administrator

**Action**: Check employee's current level and target level

**API Call**:
```http
GET /api/v1/employees/{employeeId}/promotion-eligibility
```

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "current_job": {
    "code": "SWE-SR",
    "title": "Senior Software Engineer",
    "level": "SENIOR",
    "grade": "G7"
  },
  "eligible_promotions": [
    {
      "job_code": "SWE-LEAD",
      "job_title": "Lead Software Engineer",
      "level": "LEAD",
      "grade": "G8",
      "requirements_met": true
    }
  ]
}
```

---

#### Step 2: Create Promotion

**Actor**: HR Administrator

**Action**: Execute promotion

**Input Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "from_assignment_id": "asg-uuid-001",
  "to_job_id": "job-uuid-swe-lead",
  "to_position_id": "pos-uuid-lead-001",
  "effective_date": "2025-03-01",
  "promotion_reason": "Exceptional performance and leadership",
  "salary_change_pct": 15.0
}
```

**API Call**:
```http
POST /api/v1/assignments/promote
```

**Business Rules Applied**:
- BR-ASG-016: Promotion Validation

**Expected Output**:
```json
{
  "promotion_id": "promo-uuid-001",
  "old_assignment_id": "asg-uuid-001",
  "new_assignment_id": "asg-uuid-003",
  "from_job": "Senior Software Engineer",
  "to_job": "Lead Software Engineer",
  "effective_date": "2025-03-01",
  "status": "APPROVED"
}
```

---

#### Step 3: End Current Assignment

**Data Changes**:
- `assignments` table: UPDATE 1 row (end_date = 2025-02-29)
- `positions` table: UPDATE 1 row (status → VACANT)

---

#### Step 4: Create New Assignment

**Data Changes**:
- `assignments` table: INSERT 1 row (new level, new grade)
- `positions` table: UPDATE 1 row (status → FILLED)

---

#### Step 5: Update Compensation (If Applicable)

**Note**: Compensation changes handled by Compensation module

**API Call**:
```http
POST /api/v1/compensation/salary-change
```

---

### Postconditions

**System State**:
- ✅ Old assignment ended
- ✅ New assignment active (higher level)
- ✅ Job level increased
- ✅ Job grade increased
- ✅ Promotion history recorded
- ✅ Compensation updated (if applicable)

---

## 🚪 Scenario 4: Employee Termination (Voluntary Resignation)

### Overview

**Scenario**: Employee resigns voluntarily

**Actors**:
- HR Administrator
- Manager
- Employee
- IT Department
- Facilities

**Preconditions**:
- Resignation letter received
- Notice period confirmed
- Last working day confirmed
- Exit interview scheduled

---

### Main Flow

#### Step 1: Initiate Termination

**Actor**: HR Administrator

**Action**: Create termination record

**Input Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "termination_date": "2025-12-31",
  "last_working_day": "2025-12-31",
  "termination_reason": "RESIGNATION",
  "termination_type": "VOLUNTARY",
  "notice_period_days": 30,
  "notice_given_date": "2025-12-01",
  "exit_interview_date": "2025-12-30",
  "rehire_eligible": true,
  "comments": "Leaving for career opportunity abroad"
}
```

**API Call**:
```http
POST /api/v1/employees/{employeeId}/terminate
```

**Business Rules Applied**:
- BR-EMP-010: Employee Termination Validation

---

#### Step 2: End All Active Assignments

**Actor**: System (Automated)

**Action**: End all active assignments

**Data Changes**:
- `assignments` table: UPDATE all active assignments (set end_date)
- `positions` table: UPDATE positions (status → VACANT)

---

#### Step 3: Terminate Work Relationship

**Actor**: System (Automated)

**Action**: End work relationship

**API Call**:
```http
POST /api/v1/work-relationships/{wrId}/terminate
```

**Data Changes**:
- `work_relationships` table: UPDATE 1 row (set end_date, status → TERMINATED)

---

#### Step 4: Update Employee Status

**Data Changes**:
- `employees` table: UPDATE 1 row (status → TERMINATED)

---

#### Step 5: Offboarding Tasks

**Actor**: System (Automated)

**Action**: Create offboarding checklist

**Tasks Created**:
1. Exit interview (HR)
2. Equipment return (IT)
3. Access revocation (IT)
4. Final payroll (Payroll)
5. Benefits termination (Benefits)
6. Badge return (Facilities)

---

#### Step 6: Notifications

**Notifications Sent**:

1. **To Employee**:
   - Subject: "Employment Termination Confirmation"
   - Content: Last day, offboarding checklist, final pay details

2. **To Manager**:
   - Subject: "Team Member Departure: Nguyễn Văn An"
   - Content: Last day, knowledge transfer, replacement planning

3. **To IT**:
   - Subject: "Employee Offboarding: EMP-000456"
   - Content: Access revocation schedule, equipment return

4. **To Payroll**:
   - Subject: "Final Pay Processing: EMP-000456"
   - Content: Last working day, accrued leave, final pay calculation

---

### Postconditions

**System State**:
- ✅ Employee status: TERMINATED
- ✅ Work relationship: TERMINATED
- ✅ All assignments: ENDED
- ✅ All positions: VACANT
- ✅ Offboarding tasks created
- ✅ Termination history recorded
- ✅ Rehire eligibility documented

**Data Summary**:
- Employees: 1 updated (status → TERMINATED)
- Work Relationships: 1 updated (status → TERMINATED)
- Assignments: N updated (all ended)
- Positions: N updated (all vacant)
- Offboarding Tasks: 6 created
- Audit Logs: +10+
- Notifications: +4

---

### Alternative Flows

#### A1: Involuntary Termination

**Condition**: Employee terminated by company

**Differences**:
- termination_type: "INVOLUNTARY"
- termination_reason: "PERFORMANCE" / "MISCONDUCT" / "REDUNDANCY"
- No notice period required
- Immediate access revocation
- rehire_eligible: false (usually)

---

#### A2: Termination During Probation

**Condition**: Employee on probation

**Differences**:
- Shorter/no notice period
- Simplified offboarding
- probation_status: "FAILED"

---

## 🔄 Scenario 5: Concurrent Assignment

### Overview

**Scenario**: Employee takes on additional role (concurrent assignment)

**Actors**:
- HR Administrator
- Primary Manager
- Secondary Manager
- Employee

**Preconditions**:
- Employee has active primary assignment
- Additional capacity available (FTE < 1.0)
- Both managers approve
- Concurrent role defined

---

### Main Flow

#### Step 1: Verify FTE Availability

**Actor**: HR Administrator

**Action**: Check employee's current FTE

**API Call**:
```http
GET /api/v1/employees/{employeeId}/fte-summary
```

**Expected Output**:
```json
{
  "employee_id": "emp-uuid-001",
  "total_fte": 1.0,
  "assignments": [
    {
      "assignment_type": "PRIMARY",
      "fte": 1.0,
      "job_title": "Senior Software Engineer"
    }
  ],
  "available_fte": 0.0
}
```

**Note**: If total_fte = 1.0, need to reduce primary FTE first

---

#### Step 2: Adjust Primary Assignment FTE

**Actor**: HR Administrator

**Action**: Reduce primary assignment FTE

**Input Data**:
```json
{
  "assignment_id": "asg-uuid-001",
  "new_fte": 0.7,
  "effective_date": "2025-04-01",
  "reason": "Taking on concurrent assignment"
}
```

**API Call**:
```http
PUT /api/v1/assignments/{asgId}/fte
```

**Business Rules Applied**:
- BR-ASG-010: FTE Validation

---

#### Step 3: Create Concurrent Assignment

**Actor**: HR Administrator

**Action**: Create concurrent assignment

**Input Data**:
```json
{
  "employee_id": "emp-uuid-001",
  "assignment_type": "CONCURRENT",
  "staffing_model": "JOB_BASED",
  "job_id": "job-uuid-tech-lead",
  "business_unit_id": "bu-uuid-platform",
  "manager_id": "emp-uuid-platform-manager",
  "start_date": "2025-04-01",
  "fte": 0.3,
  "concurrent_reason": "Technical leadership for platform team"
}
```

**API Call**:
```http
POST /api/v1/assignments
```

**Business Rules Applied**:
- BR-ASG-001: Assignment Creation Validation
- BR-ASG-010: FTE Validation (total must not exceed 1.0)

---

### Postconditions

**System State**:
- ✅ Primary assignment FTE reduced (1.0 → 0.7)
- ✅ Concurrent assignment created (FTE: 0.3)
- ✅ Total FTE = 1.0
- ✅ Employee has 2 active assignments
- ✅ Employee has 2 managers (solid line + dotted line)

---

## 📊 Scenario Summary

### Scenarios Covered

| Scenario | Complexity | Actors | Steps | Business Rules |
|----------|------------|--------|-------|----------------|
| **New Hire (Position-Based)** | Medium | 5 | 5 | 8 |
| **Internal Transfer** | Medium | 4 | 5 | 3 |
| **Promotion** | Medium | 3 | 5 | 2 |
| **Termination (Voluntary)** | High | 5 | 6 | 5 |
| **Concurrent Assignment** | Low | 4 | 3 | 3 |

### Common Patterns

**All scenarios follow**:
1. ✅ Validation of preconditions
2. ✅ Business rule enforcement
3. ✅ Data integrity maintenance
4. ✅ Audit trail creation
5. ✅ Notification dispatch
6. ✅ Postcondition verification

---

## 🔗 Related Documentation

- [Functional Requirements](../01-functional-requirements.md) - Detailed requirements
- [Business Rules](../04-business-rules.md) - Validation rules
- [API Specification](../02-api-specification.md) - API endpoints
- [Employment Lifecycle Guide](../../01-concept/01-employment-lifecycle-guide.md) - Concepts

---

**Document Version**: 2.0  
**Created**: 2025-12-03  
**Scenarios**: 5 detailed end-to-end workflows  
**Maintained By**: Product Team + Business Analysts  
**Status**: Complete - Ready for Implementation
