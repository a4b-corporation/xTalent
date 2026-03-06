# CO Module - Menu Structure

**Phiên bản**: 1.0
**Cập nhật**: 2026-03-06
**Module**: Core HR (CO)
**Target Audience**: Business Stakeholders, Technical Team, UI/UX Designers

---

## 1. Giới thiệu

### 1.1 Menu Design Philosophy

Menu UI của CO Module được thiết kế với các nguyên tắc:

1. **Task-Oriented**: Menu được tổ chức theo nhiệm vụ nghiệp vụ, không chỉ theo dữ liệu
2. **Role-Based**: Mỗi persona (HR Admin, Manager, Employee, Finance) nhìn thấy menu khác nhau
3. **Scalable**: Cấu trúc hỗ trợ tổ chức lớn, đa quốc gia, đa pháp nhân
4. **Intuitive**: Đường dẫn ngắn gọn, tối đa 4 cấp độ
5. **Consistent**: Cách đặt tên và tổ chức nhất quán xuyên suốt module

### 1.2 User Personas

| Persona | Vai trò | Mục tiêu chính | Menu chính |
|---------|--------|---------------|------------|
| **HR Administrator** | Quản lý toàn bộ dữ liệu nhân sự và tổ chức | Setup, configure, maintain CO data | Tất cả menu |
| **Employee** | Xem và cập nhật thông tin cá nhân | Self-service, view org info | Dashboard, Nhân sự (partial) |
| **Manager** | Phê duyệt, review, manage team members | Team management, approvals | Dashboard, Nhân sự (team), Tổ chức (partial) |
| **Finance Admin** | Quản lý cost centers, budgets | Financial planning & allocation | Quản trị → Tài chính |
| **Compliance Officer** | Đảm bảo tuân thủ pháp luật | Data security, audit reports | Quản trị → Security & Compliance, Báo cáo |

### 1.3 Navigation Principles

- **Cấp độ 1**: Menu chính - 6 mục, luôn hiển thị ở sidebar
- **Cấp độ 2**: Nhóm chức năng chính - Mở rộng khi click menu cấp 1
- **Cấp độ 3**: Chức năng cụ thể - Tabs trong trang
- **Cấp độ 4**: Actions hoặc Sub-items - Trong các dropdown hoặc tabs con

---

## 2. Cấu trúc Menu Chi tiết

---

## 2.1 Dashboard

**Mục đích**: Cung cấp cái nhìn tổng quan về workforce và hệ thống, cho phép truy cập nhanh các actions phổ biến.

**Persona chính**: Tất cả users (tùy hiển thị theo role)

---

### 2.1.1 Tổng quan nhân sự (Workforce Overview)

**Chức năng**: Hiển thị summary statistics về workforce organization

**Tính năng chính**:
- Tổng số nhân viên theo status (Active, On Leave, Terminated)
- Headcount theo Business Units
- Distribution theo Work Relationships (Employee vs Contractor)
- Vacancy rate (positions trống)

**Quyền truy cập**:
- HR Admin: Full access với breakdown chi tiết
- Manager: Chỉ xem data trong scope của mình
- Employee: Chỉ xem tổng quan mức độ company-level (ẩn sensitive data)

**Related Features**:
- FR-CO-032 (View Organization Chart)
- FR-CO-113 (Organizational Analytics)

---

### 2.1.2 Chỉ số tổ chức (Org Metrics)

**Chức năng**: Hiển thị KPIs về tổ chức và employment

**Tính năng chính**:
- Turnover rate (so với tháng trước, năm trước)
- Average tenure
- Diversity metrics (nếu được cấu hình)
- Time-to-fill (thời gian để fill một position)
- Contract expiration alerts

**Quyền truy cập**:
- HR Admin: Full access
- Manager: Chỉ xem metrics liên quan đến team của mình
- Finance: View headcount và cost-related metrics
- Employee: Không có quyền truy cập (ẩn)

**Related Features**:
- FR-CO-017 (Contract Lifecycle Management)
- FR-CO-114 (Employment Lifecycle Reports)

---

### 2.1.3 Cảnh báo & Thông báo (Alerts & Notifications)

**Chức năng**: Hiển thị alerts cần hành động

**Tính năng chính**:
- Contracts expiring trong 30/60/90 ngày
- Documents expiring (CCCD, Passport, Work Permit)
- Assignments cần approval
- Worker profiles chưa hoàn tất
- Skill gaps đã được xác định

**Quyền truy cập**:
- HR Admin: Xem tất cả alerts
- Manager: Xem alerts về team của mình
- Employee: Xem alerts cá nhân (contracts, documents)
- Finance: Không có quyền truy cập

**Related Features**:
- FR-CO-003 (Manage Worker Documents)
- FR-CO-015 (Renew Contract)
- FR-CO-112 (Skill Gap Analysis)

---

### 2.1.4 Quick Actions

**Chức năng**: Truy cập nhanh các actions phổ biến

**Tính năng chính**:
- **Hire Employee**: Mở form onboarding
- **Create Position**: Mở form tạo position
- **Add Skill**: Mở form thêm skill cho worker
- **Transfer Employee**: Mở form thuyên chuyển
- **View My Profile**: Mở profile của user hiện tại

**Quyền truy cập**:
- HR Admin: Tất cả actions
- Manager: Chỉ "Transfer Employee" (cho team members)
- Employee: Chỉ "View My Profile"
- Finance: Không có quyền truy cập

**Related Features**:
- FR-CO-010 (Hire Employee)
- FR-CO-041 (Create Position)
- FR-CO-004 (Manage Worker Skills)
- FR-CO-013 (Transfer Employee)

---

## 2.2 Nhân sự (People)

**Mục đích**: Quản lý toàn bộ thông tin về người lao động - từ hồ sơ cá nhân đến employment lifecycle.

**Persona chính**: HR Admin, Manager (limited), Employee (self-service)

---

### 2.2.1 Hồ sơ nhân viên (Worker Profiles)

**Chức năng**: Quản lý hồ sơ cá nhân của workers

**Tính năng chính**:
- **Danh sách nhân viên**: Table view với filters (name, BU, status, type)
- **Chi tiết nhân viên**: View chi tiết worker profile với các tabs:
  - Personal Information (tên, ngày sinh, CCCD)
  - Contact Information (email, phone)
  - Employment History (Work Relationships, Contracts, Assignments)
  - Skills & Competencies
  - Qualifications (Education, Certifications)
  - Dependents
- **Edit Profile**: Cập nhật thông tin (với approval workflow nếu cần)

**Quyền truy cập**:
- HR Admin: Full CRUD (Create, Read, Update, Delete)
- Manager: Read cho team members, Edit limited (skills, assignments)
- Employee: Read/Edit thông tin cá nhân của chính mình

**Related Features**:
- FR-CO-001 (Create Worker Profile)
- FR-CO-002 (Update Worker Profile)
- FR-CO-007 (Worker Types Management)

---

### 2.2.2 Documents & Bằng cấp (Documents & Qualifications)

**Chức năng**: Lưu trữ và quản lý giấy tờ tùy thân, bằng cấp

**Tính năng chính**:
- **Upload Documents**: Upload và lưu trữ files (CCCD, Passport, Work Permit, Visa)
- **Document Tracking**: Theo dõi expiry dates với alerts
- **Education Records**: Quản lý bằng cấp, chứng chỉ
- **View History**: Xem lịch sử uploads và approvals

**Quyền truy cập**:
- HR Admin: Full access, có thể upload documents cho mọi worker
- Manager: Read-only cho team members
- Employee: Upload documents cho chính mình

**Related Features**:
- FR-CO-003 (Manage Worker Documents)
- FR-CO-005 (View Education History)
- FR-CO-102 (Audit Trail)

---

### 2.2.3 Employment (Quản lý Lao động)

**Chức năng**: Quản lý vòng đời employment với 4-level hierarchy

**Tính năng chính**:

#### Work Relationships
- Tạo và quản lý Work Relationships (EMPLOYEE, CONTRACTOR, CONSULTANT, INTERN)
- Xem timeline của tất cả relationships cho một worker

#### Contracts
- Tạo, edit, renew contracts
- Theo dõi contract lifecycle (Draft → Active → Expired → Renewed)
- Sử dụng contract templates
- Xem contract history (AMENDMENT, ADDENDUM, RENEWAL, SUPERSESSION)

#### Assignments
- Gán nhân viên vào positions
- Xem assignment history với reasons (HIRE, TRANSFER, PROMOTION, etc.)
- Quản lý multiple assignments (primary + secondary)

#### Employment Actions
- **Hire**: Onboarding workflow mới
- **Transfer**: Thuyên chuyển nội bộ
- **Promotion**: Thăng chức
- **Terminate**: Offboarding workflow
- **Rehire**: Tái gia nhập với history được giữ

**Quyền truy cập**:
- HR Admin: Full access
- Manager: View assignments cho team members, request transfers/promotions
- Employee: View employment history của chính mình
- Finance: Read-only access cho contract và assignment data

**Related Features**:
- FR-CO-010 (Hire Employee)
- FR-CO-011 (Create Employment Contract)
- FR-CO-012 (Assign to Position)
- FR-CO-013 (Transfer Employee)
- FR-CO-014 (Terminate Employment)
- FR-CO-015 (Renew Contract)
- FR-CO-016 (Work Relationship Management)

---

### 2.2.4 Skills & Competencies (Kỹ năng & Năng lực)

**Chức năng**: Quản lý skills, competencies và phân tích skill gaps

**Tính năng chính**:

#### Skill Dictionary
- Xem và tìm kiếm skills trong dictionary
- Thêm skills mới (nếu được cấu hình)

#### Competency Model
- Xem competency framework
- Tìm kiếm competencies theo type (CORE, FUNCTIONAL, LEADERSHIP)

#### Worker Skills
- Thêm/edit skills cho workers
- Set proficiency levels (1-5)
- Add years of experience

#### Skill Gap Analysis
- So sánh skill của worker với requirements của một job/position
- Hiển thị:
  - ✅ EXCEEDS (thừa yêu cầu)
  - ✅ MATCHES (đáp ứng yêu cầu)
  - ⚠️ GAP (thiếu kỹ năng)
  - ℹ️ EXTRA (có kỹ năng nhưng không yêu cầu)
- Recommend training dựa trên gaps

**Quyền truy cập**:
- HR Admin: Full access
- Manager: View và add skills cho team members
- Employee: View và add skills cho chính mình
- Finance: Read-only access

**Related Features**:
- FR-CO-004 (Manage Worker Skills)
- FR-CO-060 (Manage Skill Dictionary)
- FR-CO-061 (Manage Competency Model)
- FR-CO-112 (Skill Gap Analysis)

---

### 2.2.5 Cơ hội Nội bộ (Talent Marketplace)

**Chức năng**: Internal job marketplace cho career development

**Tính năng chính**:

#### Internal Opportunities
- View danh sách internal opportunities (positions, projects, rotations)
- Filter theo type, location, skill requirements
- Xem chi tiết opportunity với requirements

#### Project Assignments
- View và apply vào project assignments ngắn hạn
- Xem allocation (% thời gian)

#### Cross-BU Rotation
- View rotation opportunities sang các Business Units khác
- Apply cho cross-functional experience

#### Mentorship Programs
- View và apply vào mentorship programs
- Chọn mentor hoặc mentee

#### Applications
- View status của các applications đã nộp
- Xem feedback từ hiring managers

#### Career Development
- View career paths cho current job
- See recommended skills needed for next role
- Xem skill gaps để tiến bộ

**Quyền truy cập**:
- HR Admin: Create opportunities, view all applications
- Manager: Create opportunities, review applications cho projects của mình
- Employee: View opportunities, apply, view application status
- Finance: Không có quyền truy cập

**Related Features**:
- FR-CO-090 (Create Internal Opportunity)
- FR-CO-091 (Search Opportunities)
- FR-CO-092 (Apply to Opportunity)
- FR-CO-093 (Skill Match Analysis)
- FR-CO-094 (Opportunity Types)
- FR-CO-043 (Define Career Paths)

---

## 2.3 Tổ chức (Organization)

**Mục đích**: Quản lý cơ cấu tổ chức, legal entities, jobs, positions và work locations.

**Persona chính**: HR Admin, Finance (limited), Manager (read-only)

---

### 2.3.1 Legal Entities

**Chức năng**: Quản lý pháp nhân công ty

**Tính năng chính**:
- Tạo, edit legal entities (cong ty mẹ, công ty con, liên doanh)
- Định nghĩa: tax ID, currency, country, registration number
- Link legal entities với Business Units và Employees

**Quyền truy cập**:
- HR Admin: Full access
- Finance: Read-only access cho tax và financial info
- Manager: Read-only access
- Employee: Không có quyền truy cập

**Related Features**:
- FR-CO-030 (Manage Legal Entities)

---

### 2.3.2 Cơ cấu Tổ chức (Org Structure)

**Chức năng**: Quản lý dual structure (Operational và Supervisory)

**Tính năng chính**:

#### Business Units (Operational Structure)
- Tạo và quản lý Business Units theo phân cấp:
  - DIVISION
  - DEPARTMENT
  - TEAM
  - PROJECT
- Set hierarchy (parent-child relationships)
- Assign manager cho mỗi BU

#### Org Charts (Operational)
- Xem org chart của Operational Structure
- Interactively navigate hierarchy
- View headcount cho mỗi BU
- Drill-down đến team level

#### Supervisory Structure
- Tạo và quản lý Supervisory Organization units
- Set reporting lines (solid line)
- Assign supervisors cho employees

#### Matrix Relationships
- Cấu hình dotted line relationships (secondary reporting)
- Gán % thời gian cho mỗi dotted line
- View matrix view cho một employee

#### Org Reorganization
- Drag-and-drop để restructure hierarchy
- Bulk actions để transfer teams/units
- Preview impacts trước khi apply changes

**Quyền truy cập**:
- HR Admin: Full CRUD
- Manager: Read-only cho scope của mình, có thể request org changes
- Finance: Read-only cho cost center và BU info
- Employee: Read-only org chart (limited scope)

**Related Features**:
- FR-CO-031 (Manage Business Units)
- FR-CO-032 (View Organization Chart)
- FR-CO-035 (Operational Structure)
- FR-CO-036 (Supervisory Structure)
- FR-CO-037 (Dual Structure Independence)
- FR-CO-038 (Matrix Organization)

---

### 2.3.3 Vị trí & Công việc (Jobs & Positions)

**Chức năng**: Quản lý Job Catalog, Job Profiles, Positions và Career Paths

**Tính năng chính**:

#### Job Catalog
- Xem Job Taxonomy (Family → Sub-family → Function)
- Tạo/edit jobs với:
  - Job code và title
  - Job Level (Junior, Mid, Senior, Principal)
  - Job Grade (salary band)
  - Salary range
- Link jobs với Job Families

#### Job Profiles
- Tạo detailed job profiles với:
  - Job description
  - Responsibilities
  - Education requirements
  - Skills requirements (với proficiency levels)
  - Competency requirements
- Link profiles với jobs

#### Positions
- Tạo positions (headcount slots)
- Link position với Job và Business Unit
- Set reporting relationships (reports-to position)
- Manage position lifecycle:
  - Proposed → Approved → Open → Filled → Frozen → Eliminated
- Track headcount và vacancy status
- View position hierarchy

#### Position Hierarchy
- Xem reporting chain của một position
- View all positions trong một BU
- Navigate up/down hierarchy

#### Career Paths
- Xem career paths cho jobs
- Tạo custom paths (lateral moves, track switching)
- Define conditions cho mỗi path step
- View career progression timeline

#### Staffing Models Configuration
- Chọn staffing model cho mỗi BU (Position-Based, Job-Based, Hybrid)
- Configure hybrid model (mix cả 2)

**Quyền truy cập**:
- HR Admin: Full access
- Manager: Read-only access cho jobs/positions, có thể tạo positions (với approval workflow)
- Finance: Read-only access cho salary range và headcount
- Employee: Read-only access cho job descriptions và career paths

**Related Features**:
- FR-CO-040 (Manage Job Catalog)
- FR-CO-041 (Create Position)
- FR-CO-042 (Manage Position Hierarchy)
- FR-CO-043 (Define Career Paths)
- FR-CO-044 (Job Taxonomy)
- FR-CO-045 (Job Profiles)
- FR-CO-046 (Job Level & Grade)
- FR-CO-047 (Position-Based Staffing)
- FR-CO-048 (Job-Based Staffing)
- FR-CO-049 (Hybrid Staffing Model)
- FR-CO-050 (Multi-tree Taxonomy)
- FR-CO-051 (Career Path Cross-over)

---

### 2.3.4 Địa điểm Làm việc (Facility Management)

**Chức năng**: Quản lý work locations theo 3-level hierarchy

**Tính năng chính**:

#### Places (Cơ sở kinh doanh)
- Tạo và quản lý Places (văn phòng, nhà máy)
- Định nghĩa địa chỉ và coordinates
- Link với legal entities

#### Locations (Khu vực)
- Tạo Locations trong mỗi Place
- Định nghĩa floor/building/zone info
- Indoor mapping integration

#### Work Locations (Địa điểm làm việc cụ thể)
- Tạo Work Locations gắn với Business Units
- Assign teams/units đến specific work locations
- Configure location-based policies:
  - Allowances (travel, meal, phone)
  - Working hours
  - Remote work policies

#### Remote Work Locations
- Create "Remote/Virtual" work location
- Configure remote work policies
- Track remote workforce distribution

**Quyền truy cập**:
- HR Admin: Full access
- Manager: Read-only access, có thể request work location changes
- Employee: Read-only access
- Finance: Read-only access cho policy và allowance configuration

**Related Features**:
- FR-CO-034 (Manage Locations)
- FR-CO-080 (Manage Places)
- FR-CO-081 (Manage Locations)
- FR-CO-082 (Manage Work Locations)
- FR-CO-083 (Location-Based Policies)
- FR-CO-084 (Remote Work Management)

---

## 2.4 Quản trị (Administration)

**Mục đích**: Cấu hình hệ thống, quản lý master data, eligibility rules, security và financial aspects.

**Persona chính**: HR Admin, Finance Admin, System Admin

---

### 2.4.1 Tài chính (Finance)

**Chức năng**: Quản lý cost centers, budgets và headcount planning

**Tính năng chính**:

#### Cost Centers
- Tạo và quản lý cost centers
- Link cost centers với legal entities và business units
- Set budget owners
- Define cost allocation rules

#### Budget Allocation
- Allocate budgets cho cost centers
- Track budget utilization
- Approve budget requests

#### Headcount Budgeting
- Define headcount budgets cho BU/positions
- Track headcount vs budget
- Alert khi approaching limits
- Approve headcount requests

**Quyền truy cập**:
- Finance Admin: Full access
- HR Admin: Read-only access, có thể submit budget requests
- Manager: View budget cho scope của mình
- Employee: Không có quyền truy cập

**Related Features**:
- FR-CO-033 (Manage Cost Centers)
- FR-CO-041 (Create Position) - với budget tracking
- FR-CO-047 (Position-Based Staffing) - với headcount control

---

### 2.4.2 Eligibility Rules (Điều kiện Hưởng lợi)

**Chức năng**: Định nghĩa và quản lý eligibility profiles cho cross-module policies

**Tính năng chính**:

#### Eligibility Profiles
- Tạo eligibility profiles
- Define criteria:
  - Job level/grade
  - Employment type
  - Tenure
  - Department/BU
  - Location
  - Contract type
- Combine multiple rules với AND/OR logic

#### Rule Configuration
- Define individual eligibility rules
- Set operators (EQUALS, IN, GREATER_THAN, LESS_THAN, BETWEEN)
- Configure rule priority

#### Cross-module Mapping
- Map eligibility profiles với modules:
  - Leave (TA Module)
  - Benefits (TR Module)
  - Compensation (TR Module)
  - Payroll (PR Module)
- Configure hybrid model:
  - Class-level default
  - Type-level override
  - Rule-level override

#### Eligibility Testing
- Test eligibility rules với sample workers
- Preview affected workers trước khi apply policy changes
- Bulk evaluation cho mass changes

**Quyền truy cập**:
- HR Admin: Full access
- Finance Admin: Read-only access cho compensation-related rules
- Manager: Không có quyền truy cập
- Employee: Không có quyền truy cập

**Related Features**:
- FR-CO-070 (Create Eligibility Profile)
- FR-CO-071 (Evaluate Eligibility)
- FR-CO-072 (Hybrid Model)
- FR-CO-073 (Cross-module Eligibility)

---

### 2.4.3 Master Data

**Chức năng**: Quản lý reference data dùng chung toàn hệ thống

**Tính năng chính**:

#### Code Lists
- Manage status codes, reason codes, lookup values
- Configure dropdown options cho system fields
- Add/edit/delete codes

#### Geographic Data
- Manage countries và admin areas (provinces, districts)
- Configure timezones
- Link với legal entities

#### Currency & Timezone
- Manage currency codes, symbols, decimal places
- Configure exchange rates
- Set default timezone per location

#### Industry Classification
- Manage industry codes
- Categorize business units theo industry

**Quyền truy cập**:
- System Admin: Full access
- HR Admin: Read-only access, có thể submit requests
- Finance Admin: Full access cho currency-related data
- Manager: Không có quyền truy cập
- Employee: Không có quyền truy cập

**Related Features**:
- FR-CO-062 (Manage Geographic Data)
- FR-CO-063 (Manage Code Lists)
- FR-CO-064 (Currency & Timezone Management)
- FR-CO-065 (Industry Classification)

---

### 2.4.4 Security & Compliance

**Chức năng**: Cấu hình security, access control và compliance

**Tính năng chính**:

#### Data Classification
- Classify data entities theo 4 levels:
  - PUBLIC
  - INTERNAL
  - CONFIDENTIAL
  - RESTRICTED
- Set default classification cho entity types
- Override classification cho specific fields

#### Role Permissions
- Define roles (HR Admin, Manager, Employee, Finance, etc.)
- Configure permissions:
  - Read access (entity/field level)
  - Write access
  - Delete access
- Assign roles to users

#### Audit Logs
- View audit trail cho all RESTRICTED data access
- Filter logs by:
  - User
  - Date range
  - Entity/field
  - Action type
- Export logs cho compliance reporting

#### GDPR/PDPA Compliance Tools
- **Data Export**: Export toàn bộ data của một worker (Right to Access)
- **Data Rectification**: Request corrections to personal data (Right to Rectification)
- **Data Deletion**: Anonymize worker data (Right to be Forgotten)
- **Consent Management**: Track consent records

**Quyền truy cập**:
- Compliance Officer: Full access cho all security features
- HR Admin: Limited access (view audit logs, manage role assignments)
- Finance Admin: Read-only access cho audit logs
- Manager/Employee: Không có quyền truy cập

**Related Features**:
- FR-CO-100 (Data Classification)
- FR-CO-101 (Role-Based Access Control)
- FR-CO-102 (Audit Trail)
- FR-CO-103 (GDPR/PDPA Compliance)
- FR-CO-104 (Field-Level Access Control)
- FR-CO-105 (Data Anonymization)

---

## 2.5 Báo cáo (Reports)

**Mục đích**: Cung cấp analytics và reporting cho workforce, employment, talent và compliance.

**Persona chính**: HR Admin, Manager, Finance Admin, Business Leaders

---

### 2.5.1 Workforce Reports (Báo cáo Nhân sự)

**Chức năng**: Analytics về workforce organization

**Tính năng chính**:

#### Organization Reports
- Headcount by BU, Department, Team
- Org structure changes over time
- Distribution by location, legal entity
- Employee vs Contractor ratio

#### Headcount Analysis
- Current headcount vs budget
- Vacancy analysis
- Hiring velocity
- Attrition rate by department

#### Turnover Analysis
- Turnover rate by department, level, tenure
- Voluntary vs Involuntary turnover
- Reasons for leaving
- Retention analysis

**Quyền truy cập**:
- HR Admin: Full access
- Manager: Read-only cho scope của mình
- Finance: Read-only cho budget và headcount reports
- Employee: Không có quyền truy cập

**Related Features**:
- FR-CO-113 (Organizational Analytics)

---

### 2.5.2 Employment Reports (Báo cáo Lao động)

**Chức năng**: Báo cáo về contracts, assignments và employment lifecycle

**Tính năng chính**:

#### Contract Status Reports
- Active contracts by type
- Contracts expiring trong X days/months
- Contract renewal tracking
- Contract history analysis

#### Assignment History
- Assignment changes over time
- Transfer/Promotion statistics
- Assignment reasons distribution
- Multiple assignment tracking

#### Rehire Analysis
- Rehire rate
- Time between employment periods
- Rehire performance comparison
- Alumni database reports

**Quyền truy cập**:
- HR Admin: Full access
- Manager: Read-only cho scope của mình
- Finance: Read-only cho contract và assignment reports
- Employee: Không có quyền truy cập

**Related Features**:
- FR-CO-114 (Employment Lifecycle Reports)
- FR-CO-017 (Contract Lifecycle Management)
- FR-CO-019 (Rehire Management)

---

### 2.5.3 Talent Reports (Báo cáo Talent)

**Chức năng**: Analytics về skills, competency và internal mobility

**Tính năng chính**:

#### Skill Gap Reports
- Organization-wide skill gaps
- Skill distribution by department
- Critical skill shortages
- Training recommendations

#### Competency Assessment
- Competency levels by team/department
- Competency gaps for leadership roles
- Performance vs competency correlation
- 360-degree feedback summaries

#### Internal Mobility
- Internal promotion rate
- Cross-BU transfer rate
- Talent marketplace analytics
- Career path progression tracking
- Skill match analysis

**Quyền truy cập**:
- HR Admin: Full access
- Manager: Read-only cho scope của mình
- Finance: Không có quyền truy cập
- Employee: View skill gap analysis cho chính mình

**Related Features**:
- FR-CO-112 (Skill Gap Analysis)
- FR-CO-115 (Talent Analytics)

---

### 2.5.4 Audit & Compliance Reports

**Chức năng**: Báo cáo về data access, changes và compliance

**Tính năng chính**:

#### Data Access Logs
- Who accessed RESTRICTED data
- When and what data was accessed
- Access patterns analysis
- Suspicious activity alerts

#### Change History
- All changes to worker/org data
- Point-in-time state for any date
- Change approval workflow tracking
- Reversion capabilities

#### Compliance Reports
- GDPR/PDPA compliance status
- Data subject requests tracking
- Consent management reports
- Audit trail summary reports

**Quyền truy cập**:
- Compliance Officer: Full access
- HR Admin: Read-only cho change history
- Finance: Read-only cho compliance reports
- Manager/Employee: Không có quyền truy cập

**Related Features**:
- FR-CO-102 (Audit Trail)
- FR-CO-103 (GDPR/PDPA Compliance)
- FR-CO-110 (Point-in-Time Reporting)
- FR-CO-111 (SCD Type 2 History)

---

## 3. Best Practices

### 3.1 Menu Organization

1. **Group Related Features**: Chức năng liên quan nên ở gần nhau
2. **Logical Flow**: Từ overview → detailed configuration → reports
3. **Role-Based Display**: Ẩn menu items không relevant cho user's role
4. **Consistent Naming**: Dùng consistent terminology xuyên suốt

### 3.2 Navigation Depth

- **Cấp 1**: Menu chính (6 items) - Always visible in sidebar
- **Cấp 2**: Nhóm chức năng (20+ items) - Expandable submenu
- **Cấp 3**: Chức năng cụ thể (50+ items) - Tabs trong trang
- **Cấp 4**: Actions/Sub-items (100+ items) - Dropdowns hoặc nested tabs

**Rule**: Không vượt quá 4 cấp độ. Nếu cần sâu hơn, hãy xem lại grouping.

### 3.3 Responsive Design

- **Desktop**: Sidebar với full menu expansion
- **Tablet**: Collapsible sidebar với hamburger menu
- **Mobile**: Bottom navigation bar với top-level menu only

### 3.4 Accessibility

- Keyboard navigation (Tab, Arrow keys)
- Screen reader compatible labels
- High contrast mode support
- Font size adjustments

---

## 4. Implementation Considerations

### 4.1 Technical

- **Menu Configuration**: Menu items should be configurable (enable/disable per module)
- **Permission Checks**: Apply permission checks at menu rendering time (not just at page load)
- **Performance**: Lazy-load menu items and sub-menus to improve initial load time
- **Caching**: Cache menu structure per role/user to avoid repeated DB queries

### 4.2 Internationalization (i18n)

- Menu labels translatable
- Support RTL (Right-to-Left) languages
- Date/time formatting per locale
- Currency formatting per locale

### 4.3 Analytics

- Track menu usage analytics to optimize structure
- Identify rarely-used menu items for potential removal
- Monitor user navigation paths to improve UX

---

## 5. References

- **Feature List**: `/summary/01-feature-list.md`
- **Feature Catalog**: `/_research/feature-catalog.md`
- **Entity Catalog**: `/_research/entity-catalog.md`
- **Overview Documents**: `/_research/overview/`

---

## 6. Change Log

| Phiên bản | Ngày | Người thực hiện | Thay đổi |
|----------|------|-----------------|----------|
| 1.0 | 2026-03-06 | AI Assistant | Tạo bản đầu tiên - Thiết kế menu structure dựa trên features và user personas |

---

*Bản tài liệu này thuộc bộ research summary của CO Module.*
