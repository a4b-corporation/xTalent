# CO Module - Feature List

**Phiên bản**: 1.0
**Cập nhật**: 2026-03-06
**Module**: Core HR (CO)
**Target Audience**: Business Stakeholders, Technical Team

---

## 1. Giới thiệu

**Core Module (CO)** là nền tảng dữ liệu của toàn bộ hệ thống xTalent HCM. Module này định nghĩa và quản lý những thực thể trung tâm nhất của một tổ chức: **con người, tổ chức, công việc và mối quan hệ giữa chúng**.

### Thống kê Module

| Thông số | Giá trị |
|---------|---------|
| Tổng số entities | **68 entities** |
| Tổng số features | **40+ features** |
| Aggregate Roots | **12** |
| Sub-modules | **7** |

### Modules phụ thuộc

```
CO Module (Core)
    ├── TA (Chấm công) - sử dụng Worker + Org data
    ├── TR (Đãi ngộ) - sử dụng Worker + Position data
    ├── PR (Lương) - sử dụng Worker + Assignment data
    └── RC (Tuyển dụng) - sử dụng Worker data
```

---

## 2. Feature List

### 2.1 Quản lý Nhân sự (Person Management)

**Mô tả**: Quản lý hồ sơ cá nhân của người lao động bao gồm thông tin nhân thân, kỹ năng, bằng cấp, giấy tờ và người phụ thuộc.

| ID | Feature | Mô tả | Priority | User Story | Related Entities |
|----|---------|--------|----------|------------|-----------------|
| FR-CO-001 | **Create Worker Profile** | Tạo hồ sơ nhân viên mới trong hệ thống | MUST | As an HR Admin, I want to create a new worker profile so that I can onboard a new person into system | Worker, Contact, Address |
| FR-CO-002 | **Update Worker Profile** | Nhân viên tự cập nhật thông tin cá nhân | MUST | As an Employee, I want to update my personal information so that my records are current | Worker |
| FR-CO-003 | **Manage Worker Documents** | Lưu trữ và quản lý giấy tờ tùy thân | MUST | As an HR Admin, I want to store and manage worker identity documents so that compliance records are maintained | Worker, Document |
| FR-CO-004 | **Manage Worker Skills** | Theo dõi kỹ năng và trình độ của nhân viên | SHOULD | As an HR Manager, I want to track worker skills and proficiency levels so that I can plan talent development | Worker, SkillAssignment, Skill |
| FR-CO-005 | **View Education History** | Xem và quản lý lịch sử học vấn | SHOULD | As an HR Admin, I want to view and record worker education history for qualification tracking | Worker, EducationRecord |
| FR-CO-006 | **Manage Dependents** | Quản lý người phụ thuộc | MUST | As an Employee, I want to add my dependents so that they can be enrolled in benefits | Worker, Dependent |
| FR-CO-007 | **Worker Types Management** | Quản lý các loại Person (EMPLOYEE, CONTRACTOR, CONSULTANT, APPLICANT, ALUMNUS, DEPENDENT) | COULD | As an HR Admin, I want to manage worker types so that different work relationships can be tracked | Worker |
| FR-CO-008 | **Contact Information Management** | Quản lý nhiều loại thông tin liên lạc (phone, email, social) | COULD | As an HR Admin, I want to manage multiple contact types so that worker communication is flexible | Worker, Contact |

---

### 2.2 Quản lý Lao động (Employment Management)

**Mô tả**: Quản lý vòng đời lao động với mô hình 4-level hierarchy: Worker → Work Relationship → Employee → Assignment.

| ID | Feature | Mô tả | Priority | User Story | Related Entities |
|----|---------|--------|----------|------------|-----------------|
| FR-CO-010 | **Hire Employee** | Chuyển đổi worker thành nhân viên chính thức | MUST | As an HR Admin, I want to convert a worker to employee so that they can start their employment | Worker, Employee, Contract, Assignment |
| FR-CO-011 | **Create Employment Contract** | Tạo hợp đồng lao động với các điều khoản | MUST | As an HR Admin, I want to create an employment contract with terms and conditions | Employee, Contract |
| FR-CO-012 | **Assign to Position** | Gán nhân viên vào vị trí công việc | MUST | As an HR Admin, I want to assign an employee to a position so that org structure is accurate | Employee, Assignment, Position |
| FR-CO-013 | **Transfer Employee** | Thuyên chuyển nhân viên sang vị trí/phòng ban khác | MUST | As an HR Admin, I want to transfer an employee to a new position/department | Employee, Assignment, Position |
| FR-CO-014 | **Terminate Employment** | Xử lý quy trình nghỉ việc | MUST | As an HR Admin, I want to process employee termination so that offboarding is complete | Employee, Contract |
| FR-CO-015 | **Renew Contract** | Gia hạn hợp đồng sắp hết hạn | MUST | As an HR Admin, I want to renew an expiring contract so that employment continues | Employee, Contract |
| FR-CO-016 | **Work Relationship Management** | Quản lý các loại quan hệ lao động (EMPLOYEE, CONTRACTOR, CONSULTANT, INTERN, VOLUNTEER) | COULD | As an HR Admin, I want to manage work relationships so that non-employee workers can be tracked | Worker, WorkRelationship |
| FR-CO-017 | **Contract Lifecycle Management** | Quản lý vòng đời hợp đồng (AMENDMENT, ADDENDUM, RENEWAL, SUPERSESSION) | COULD | As an HR Admin, I want to manage contract lifecycle so that contract history is preserved | Contract |
| FR-CO-018 | **Contract Templates** | Tạo và sử dụng mẫu hợp đồng tiêu chuẩn theo quốc gia | COULD | As an HR Admin, I want to create contract templates so that contract creation is consistent and compliant | Contract |
| FR-CO-019 | **Rehire Management** | Quản lý nhân viên tái gia nhập với việc giữ nguyên lịch sử cũ | COULD | As an HR Admin, I want to manage rehires so that employment history is preserved | Worker, Employee |
| FR-CO-020 | **Assignment Reasons** | Định nghĩa lý do thay đổi phân công (HIRE, TRANSFER, PROMOTION, DEMOTION, RETURN, RESTRUCTURE, LATERAL_MOVE) | COULD | As an HR Admin, I want to track assignment reasons so that employment analytics are accurate | Assignment |

---

### 2.3 Cấu trúc Tổ chức (Organization Structure)

**Mô tả**: Quản lý cơ cấu tổ chức với Dual Structure (Operational và Supervisory), Legal Entity, và Matrix Organization.

| ID | Feature | Mô tả | Priority | User Story | Related Entities |
|----|---------|--------|----------|------------|-----------------|
| FR-CO-030 | **Manage Legal Entities** | Cấu hình pháp nhân đa công ty | MUST | As a System Admin, I want to configure legal entities so that multi-company setup is supported | LegalEntity |
| FR-CO-031 | **Manage Business Units** | Tạo và quản lý business units theo phân cấp | MUST | As an HR Admin, I want to create and organize business units so that org structure is defined | BusinessUnit, LegalEntity |
| FR-CO-032 | **View Organization Chart** | Xem sơ đồ tổ chức tương tác | MUST | As an Employee, I want to view organization chart so that I understand reporting structure | BusinessUnit, Position, Employee |
| FR-CO-033 | **Manage Cost Centers** | Định nghĩa cost centers cho phân bổ chi phí | SHOULD | As a Finance Admin, I want to define cost centers for expense allocation | CostCenter, LegalEntity |
| FR-CO-034 | **Manage Locations** | Định nghĩa địa điểm làm việc | SHOULD | As an HR Admin, I want to define work locations for facility management | Location |
| FR-CO-035 | **Operational Structure** | Quản lý cơ cấu vận hành (DIVISION, DEPARTMENT, TEAM, PROJECT) | COULD | As an HR Admin, I want to manage operational structure so that work assignment is organized | BusinessUnit |
| FR-CO-036 | **Supervisory Structure** | Quản lý cơ cấu báo cáo và phê duyệt | COULD | As an HR Admin, I want to manage supervisory structure so that approval workflows are defined | BusinessUnit |
| FR-CO-037 | **Dual Structure Independence** | Tách biệt hoàn toàn Operational và Supervisory structure | COULD | As an HR Admin, I want to maintain independent structures so that org changes don't break approvals | BusinessUnit |
| FR-CO-038 | **Matrix Organization** | Hỗ trợ Solid Line (primary reporting) và Dotted Line (secondary/project reporting) | COULD | As an HR Admin, I want to support matrix reporting so that complex org structures are handled | BusinessUnit, Assignment |

---

### 2.4 Quản lý Công việc & Vị trí (Job & Position)

**Mô tả**: Quản lý Job Taxonomy, Job Profiles, Positions, Career Paths và hỗ trợ hai mô hình staffing (Position-Based và Job-Based).

| ID | Feature | Mô tả | Priority | User Story | Related Entities |
|----|---------|--------|----------|------------|-----------------|
| FR-CO-040 | **Manage Job Catalog** | Định nghĩa jobs trong catalog | MUST | As an HR Admin, I want to define jobs in the catalog so that positions can be created | Job, JobFamily |
| FR-CO-041 | **Create Position** | Tạo position để quản lý headcount | MUST | As an HR Manager, I want to create a position so that I can hire or assign employees | Position, Job, BusinessUnit |
| FR-CO-042 | **Manage Position Hierarchy** | Định nghĩa quan hệ báo cáo giữa các positions | MUST | As an HR Admin, I want to define reporting relationships between positions | Position |
| FR-CO-043 | **Define Career Paths** | Định nghĩa lộ trình thăng tiến nghề nghiệp | SHOULD | As an HR Admin, I want to define career progression paths so that employees can plan development | CareerPath, Job |
| FR-CO-044 | **Job Taxonomy** | Phân loại công việc theo cây 3 cấp (Family → Sub-family → Function) | COULD | As an HR Admin, I want to manage job taxonomy so that jobs are properly classified | Job, JobFamily |
| FR-CO-045 | **Job Profiles** | Mô tả yêu cầu chi tiết cho mỗi job (skills, competencies, education) | COULD | As an HR Admin, I want to create job profiles so that position requirements are defined | Job, JobCompetency, Skill |
| FR-CO-046 | **Job Level & Grade** | Gán Job Level (seniority) và Job Grade (salary band) cho mỗi job | COULD | As an HR Admin, I want to manage job levels and grades so that compensation is structured | Job |
| FR-CO-047 | **Position-Based Staffing** | Quản lý headcount thông qua positions được phê duyệt trước | COULD | As an HR Manager, I want to use position-based staffing so that headcount is tightly controlled | Position |
| FR-CO-048 | **Job-Based Staffing** | Gán nhân viên trực tiếp vào job mà không cần position | COULD | As an HR Manager, I want to use job-based staffing so that hiring is flexible | Assignment, Job |
| FR-CO-049 | **Hybrid Staffing Model** | Kết hợp cả Position-Based và Job-Based cho các tầng khác nhau | COULD | As an HR Manager, I want to use hybrid staffing so that different workforce segments are managed appropriately | Position, Assignment |
| FR-CO-050 | **Multi-tree Taxonomy** | Hỗ trợ taxonomy riêng cho từng Business Unit | COULD | As an HR Admin, I want to create BU-specific taxonomies so that organizational needs are met | Job, JobFamily |
| FR-CO-051 | **Career Path Cross-over** | Hỗ trợ lateral moves và track switching | COULD | As an HR Admin, I want to define cross-over paths so that career mobility is enabled | CareerPath, Job |

---

### 2.5 Master Data & Dữ liệu Tham chiếu

**Mô tả**: Quản lý các dữ liệu kho dùng chung toàn hệ thống.

| ID | Feature | Mô tả | Priority | User Story | Related Entities |
|----|---------|--------|----------|------------|-----------------|
| FR-CO-060 | **Manage Skill Dictionary** | Định nghĩa skills trong dictionary | SHOULD | As an HR Admin, I want to define skills in dictionary for use across system | Skill |
| FR-CO-061 | **Manage Competency Model** | Định nghĩa competencies cho performance management | SHOULD | As an HR Admin, I want to define competencies for performance management | Competency |
| FR-CO-062 | **Manage Geographic Data** | Cấu hình countries và regions cho localization | MUST | As a System Admin, I want to configure countries and regions for localization | Country, AdminArea |
| FR-CO-063 | **Manage Code Lists** | Quản lý các bảng mã đa mục đích (status codes, reason codes) | COULD | As an HR Admin, I want to manage code lists so that system lookups are centralized | CodeList |
| FR-CO-064 | **Currency & Timezone Management** | Quản lý tiền tệ và múi giờ chuẩn ISO | COULD | As an HR Admin, I want to manage currencies and timezones so that global operations are supported | Currency, TimeZone |
| FR-CO-065 | **Industry Classification** | Phân loại ngành nghề | COULD | As an HR Admin, I want to manage industry classification so that organizational data is categorized | Industry |

---

### 2.6 Eligibility Engine

**Mô tả**: Quản lý điều kiện hưởng lợi tập trung, tái sử dụng cho tất cả các module.

| ID | Feature | Mô tả | Priority | User Story | Related Entities |
|----|---------|--------|----------|------------|-----------------|
| FR-CO-070 | **Create Eligibility Profile** | Tạo eligibility profiles để target benefits/programs | MUST | As an HR Admin, I want to create eligibility profiles so that benefits/programs can be targeted | EligibilityProfile, EligibilityRule |
| FR-CO-071 | **Evaluate Eligibility** | Đánh giá real-time nếu worker đủ điều kiện cho một program | MUST | As a System, I want to evaluate if a worker is eligible for a program | EligibilityProfile, Worker |
| FR-CO-072 | **Hybrid Model (Default + Override)** | Hỗ trợ mô hình phân cấp: Class default → Type override → Rule override | COULD | As an HR Admin, I want to configure eligibility at multiple levels so that policies are flexible yet consistent | EligibilityProfile, EligibilityRule |
| FR-CO-073 | **Cross-module Eligibility** | Sử dụng eligibility profiles cho leave, benefits, compensation, payroll | COULD | As an HR Admin, I want to reuse eligibility across modules so that policies are consistent | EligibilityProfile |

---

### 2.7 Quản lý Địa điểm Làm việc (Facility Management)

**Mô tả**: Quản lý địa điểm làm việc theo 3 cấp phân tầng phục vụ chính sách và phụ cấp.

| ID | Feature | Mô tả | Priority | User Story | Related Entities |
|----|---------|--------|----------|------------|-----------------|
| FR-CO-080 | **Manage Places** | Quản lý cơ sở kinh doanh (văn phòng, nhà máy) với địa chỉ | COULD | As an HR Admin, I want to manage places so that business facilities are tracked | Place |
| FR-CO-081 | **Manage Locations** | Quản lý khu vực trong Place cho indoor mapping | COULD | As an HR Admin, I want to manage locations so that detailed facility mapping is supported | Location, Place |
| FR-CO-082 | **Manage Work Locations** | Quản lý địa điểm làm việc cụ thể gắn với Business Unit | COULD | As an HR Admin, I want to manage work locations so that teams are assigned to specific areas | WorkLocation, Location, BusinessUnit |
| FR-CO-083 | **Location-Based Policies** | Áp dụng chính sách và phụ cấp theo Place/Location/WorkLocation | COULD | As an HR Manager, I want to configure location-based policies so that allowances are automated | WorkLocation, Assignment |
| FR-CO-084 | **Remote Work Management** | Quản lý WorkLocation "Remote/Virtual" | COULD | As an HR Admin, I want to support remote work locations so that distributed teams are managed | WorkLocation |

---

### 2.8 Sàn Cơ hội Nội bộ (Talent Marketplace)

**Mô tả**: Cho phép nhân viên tìm kiếm và ứng tuyển vào các cơ hội nội bộ.

| ID | Feature | Mô tả | Priority | User Story | Related Entities |
|----|---------|--------|----------|------------|-----------------|
| FR-CO-090 | **Create Internal Opportunity** | Tạo cơ hội nội bộ (position, project, rotation, mentorship) | COULD | As an HR Manager, I want to create internal opportunities so that employees can develop internally | Opportunity, Job |
| FR-CO-091 | **Search Opportunities** | Nhân viên tìm kiếm cơ hội phù hợp với skill của họ | COULD | As an Employee, I want to search opportunities so that I can find internal growth options | Opportunity, SkillAssignment |
| FR-CO-092 | **Apply to Opportunity** | Nhân viên ứng tuyển vào cơ hội nội bộ | COULD | As an Employee, I want to apply to opportunities so that I can advance my career | Opportunity, Worker |
| FR-CO-093 | **Skill Match Analysis** | Xem mức độ match giữa skill của nhân viên và yêu cầu cơ hội | COULD | As an Employee, I want to see skill match percentage so that I can assess my fit | Opportunity, SkillAssignment |
| FR-CO-094 | **Opportunity Types** | Hỗ trợ nhiều loại: Internal Posting, Project Assignment, Cross-BU Rotation, Mentorship | COULD | As an HR Manager, I want to create different opportunity types so that various internal mobility scenarios are supported | Opportunity |

---

### 2.9 Bảo mật & Tuân thủ (Data Security & Compliance)

**Mô tả**: Bảo vệ dữ liệu nhân sự với phân loại 4 cấp, kiểm soát truy cập, và tuân thủ GDPR/PDPA.

| ID | Feature | Mô tả | Priority | User Story | Related Entities |
|----|---------|--------|----------|------------|-----------------|
| FR-CO-100 | **Data Classification** | Phân loại dữ liệu 4 cấp (PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED) | COULD | As an HR Admin, I want to classify data so that access is properly controlled | All Entities |
| FR-CO-101 | **Role-Based Access Control** | Kiểm soát truy cập theo vai trò | COULD | As an HR Admin, I want to configure role-based access so that users only see data they're allowed to | Permission, Role |
| FR-CO-102 | **Audit Trail** | Ghi lại toàn bộ lịch sử truy cập dữ liệu nhạy cảm | COULD | As a Compliance Officer, I want to view audit logs so that data access is monitored | AuditLog |
| FR-CO-103 | **GDPR/PDPA Compliance** | Hỗ trợ quyền người lao động theo GDPR/PDPA | COULD | As an HR Admin, I want to support GDPR/PDPA requirements so that privacy regulations are met | Worker, DataRequest |
| FR-CO-104 | **Field-Level Access Control** | Kiểm soát truy cập ở mức field | COULD | As an HR Admin, I want to restrict specific fields so that sensitive data is protected | All Entities |
| FR-CO-105 | **Data Anonymization** | Anonymize dữ liệu khi xóa (Right to be Forgotten) | COULD | As an HR Admin, I want to anonymize worker data so that GDPR right to be forgotten is respected | Worker |

---

### 2.10 Báo cáo & Lịch sử (Reporting & History)

**Mô tả**: Lưu lịch sử đầy đủ (SCD Type 2) và hỗ trợ point-in-time reporting.

| ID | Feature | Mô tả | Priority | User Story | Related Entities |
|----|---------|--------|----------|------------|-----------------|
| FR-CO-110 | **Point-in-Time Reporting** | Trả lời câu hỏi "Vào ngày X, nhân viên Y thuộc phòng ban nào?" | COULD | As a Business Analyst, I want to see org structure at a specific date so that historical analysis is possible | All Entities (with effective dates) |
| FR-CO-111 | **SCD Type 2 History** | Mọi thay đổi dữ liệu đều được lưu với effective dates | COULD | As an HR Admin, I want full change history so that audit trails are complete | All Entities |
| FR-CO-112 | **Skill Gap Analysis** | So sánh skill của nhân viên với yêu cầu vị trí | COULD | As an HR Manager, I want to analyze skill gaps so that training needs are identified | Worker, SkillAssignment, Job |
| FR-CO-113 | **Organizational Analytics** | Báo cáo workforce theo tổ chức, headcount, turnover | COULD | As a Business Leader, I want to view org analytics so that workforce decisions are data-driven | Worker, Assignment, BusinessUnit |
| FR-CO-114 | **Employment Lifecycle Reports** | Báo cáo về contracts, assignments, rehires | COULD | As an HR Manager, I want to track employment lifecycle so that compliance is ensured | Employee, Contract, Assignment |
| FR-CO-115 | **Talent Analytics** | Báo cáo về skills, competency, internal mobility | COULD | As a Talent Manager, I want to view talent analytics so that workforce planning is optimized | Worker, SkillAssignment, Opportunity |

---

## 3. Feature Summary

### 3.1 Theo Priority

| Priority | Số lượng | Percentage |
|----------|----------|------------|
| MUST | 19 | 43% |
| SHOULD | 6 | 14% |
| COULD | 19 | 43% |
| **Tổng cộng** | **44** | **100%** |

### 3.2 Theo Type

| Type | Số lượng |
|------|----------|
| Functional | 24 |
| Configuration | 8 |
| Workflow | 6 |
| Calculation | 2 |
| UI/UX | 4 |
| **Tổng cộng** | **44** |

### 3.3 Theo Capability Group

| Capability Group | Số lượng Features |
|-----------------|-------------------|
| Quản lý Nhân sự (Person Management) | 8 |
| Quản lý Lao động (Employment Management) | 11 |
| Cấu trúc Tổ chức (Organization Structure) | 9 |
| Quản lý Công việc & Vị trí (Job & Position) | 12 |
| Master Data & Dữ liệu Tham chiếu | 6 |
| Eligibility Engine | 4 |
| Quản lý Địa điểm Làm việc (Facility Management) | 5 |
| Sàn Cơ hội Nội bộ (Talent Marketplace) | 5 |
| Bảo mật & Tuân thủ (Data Security & Compliance) | 6 |
| Báo cáo & Lịch sử (Reporting & History) | 6 |
| **Tổng cộng** | **72** |

---

## 4. Legend & Glossary

### 4.1 Priority Levels

| Priority | Mô tả |
|----------|-------|
| MUST | Bắt buộc có trong Phase 1 - Core functionality |
| SHOULD | Nên có trong Phase 1 hoặc đầu Phase 2 - Important but not critical |
| COULD | Có thể có trong Phase 2 hoặc sau - Nice to have, future enhancement |

### 4.2 Feature Types

| Type | Mô tả |
|------|-------|
| Functional | Chức năng nghiệp vụ chính |
| Configuration | Thiết lập và cấu hình hệ thống |
| Workflow | Quy trình nghiệp vụ có nhiều bước |
| Calculation | Tính toán tự động của hệ thống |
| UI/UX | Giao diện và trải nghiệm người dùng |

### 4.3 Technical Terms

| Term | Định nghĩa |
|------|------------|
| **SCD Type 2** | Slowly Changing Dimension Type 2 - Lưu lịch sử đầy đủ với effective dates |
| **Position-Based Staffing** | Mô hình staffing mỗi nhân viên gán vào một position đã được phê duyệt |
| **Job-Based Staffing** | Mô hình staffing nhân viên gán trực tiếp vào job description |
| **Dual Structure** | Cấu trúc tổ chức tách biệt Operational và Supervisory |
| **Matrix Organization** | Tổ chức với Solid Line (primary reporting) và Dotted Line (secondary reporting) |
| **Solid Line** | Báo cáo chính thức - ảnh hưởng đến phê duyệt và lương thưởng |
| **Dotted Line** | Báo cáo chức năng/dự án - không ảnh hưởng phê duyệt |
| **Job Taxonomy** | Phân loại công việc theo cây phân cấp chuẩn hóa |
| **Job Profile** | Mô tả chi tiết yêu cầu của một job (skills, competencies, education) |
| **Career Path** | Lộ trình thăng tiến nghề nghiệp từ job này sang job khác |
| **Skill Gap Analysis** | Phân tích khoảng cách kỹ năng giữa worker profile và job requirements |
| **Eligibility Profile** | Định nghĩa ai đủ điều kiện hưởng lợi/sử dụng một policy |
| **GDPR** | General Data Protection Regulation - Luật bảo vệ dữ liệu EU |
| **PDPA** | Personal Data Protection Act - Luật bảo vệ dữ liệu Đông Nam Á |
| **Point-in-Time Reporting** | Báo cáo trạng thái tại một thời điểm cụ thể trong quá khứ |

---

## 5. References

- **Feature Catalog**: `/_research/feature-catalog.md`
- **Entity Catalog**: `/_research/entity-catalog.md`
- **Overview Documents**: `/_research/overview/`
  - 01 - Executive Summary
  - 02 - Employment Model
  - 03 - Organization Model
  - 04 - Job & Position Model
  - 05 - People & Skills Data
  - 06 - Cross-Module Capabilities

---

## 6. Change Log

| Phiên bản | Ngày | Người thực hiện | Thay đổi |
|----------|------|-----------------|----------|
| 1.0 | 2026-03-06 | AI Assistant | Tạo bản đầu tiên - Tổng hợp từ overview documents và feature/entity catalogs |

---

*Bản tài liệu này thuộc bộ research summary của CO module.*
