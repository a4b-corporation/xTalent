# Core HR (CO) — Menu Structure

**Module**: Core HR (CO)  
**Version**: 1.0 (aligned with deep analysis)  
**Ngày**: 2026-03-17

---

## Tổng quan

Core HR là **nền tảng** (foundation) của xTalent — quản lý master data, cấu trúc tổ chức, nhân viên, hợp đồng, vị trí, và cung cấp shared services cho các module khác. Sau deep analysis, Core tiếp nhận thêm:

| Chức năng mới | Từ module | Lý do (ref) |
|---------------|:---------:|-------------|
| Eligibility Engine (cross-module) | Was fragmented | Single engine for all modules (Doc 05) |
| Country Configuration | TR `comp_core.country_config` | Unified source (Doc 06) |
| Holiday Calendar | TR + TA (3 copies) | Consolidated single source (Doc 06) |

Core gồm **16 schemas, ~60 tables** phục vụ 4 module: CO, TA, TR, PR.

---

## Menu Tree

```
Core HR
│
├── 1. Organization                          ─── Cấu trúc tổ chức
│   ├── 1.1 Legal Entities                   ─── Pháp nhân
│   │   ├── Legal Entity List                Danh sách pháp nhân (công ty thành viên)
│   │   ├── Create/Edit Entity               Tạo/sửa: tên, mã số thuế, country, currency, staffing model
│   │   ├── Entity Classification            Phân loại: Corporation, LLC, Branch, Non-Profit...
│   │   ├── Entity Divisions                 Phân khu pháp nhân (nếu có)
│   │   └── Entity Parameters                Tham số riêng per entity: min wage zone, SI caps
│   │
│   ├── 1.2 Business Units                   ─── Đơn vị kinh doanh
│   │   ├── Business Unit List               Danh sách BU (phòng ban, bộ phận)
│   │   ├── Create/Edit BU                   Tạo/sửa: name, parent BU, legal entity, head
│   │   ├── BU Hierarchy                     Tree view cấu trúc tổ chức (unlimited depth)
│   │   ├── Cross-References                 Liên kết BU → external: cost center, GL account
│   │   └── BU Tags                          Gắn tags phân loại: region, function, project
│   │
│   ├── 1.3 Org Relationships                ─── Quan hệ tổ chức
│   │   ├── Org Relations                    Quan hệ giữa entities: parent-child, shared services
│   │   ├── Matrix Assignments               Gắn NV vào nhiều BU (matrix org: solid + dotted line)
│   │   └── Org Snapshots                    Snapshots cấu trúc tổ chức tại thời điểm (point-in-time)
│   │
│   └── 1.4 Org Chart                        ─── Sơ đồ tổ chức
│       ├── Visual Org Chart                 Interactive tree: by BU, by legal entity, by manager
│       └── Headcount Overview               Tổng quan nhân sự per node: active, vacant positions
│
├── 2. Workforce                             ─── Nhân sự
│   ├── 2.1 Worker & Person                  ─── Hồ sơ cá nhân
│   │   ├── Worker Directory                 Danh sách tất cả workers (employees, contractors, contingent)
│   │   ├── Personal Information             Thông tin cá nhân: name, DOB, gender, nationality, IDs
│   │   ├── Contact Information              Liên lạc: phone, email, address (multi-type)
│   │   ├── Documents                        Tài liệu: CMND/CCCD, passport, bằng cấp, CV
│   │   ├── Emergency Contacts               Liên hệ khẩn cấp (P1 — new entity)
│   │   └── Worker Relationships             Quan hệ gia đình: vợ/chồng, con (cho BHXH, thuế)
│   │
│   ├── 2.2 Employment                       ─── Thông tin việc làm
│   │   ├── Employee List                    Danh sách NV active: status, hire date, department
│   │   ├── Assignment Management            Gắn NV vào position/job: BU, supervisor, location, FTE
│   │   ├── Assignment History               Lịch sử assignment (SCD-2): transfers, promotions, demotions
│   │   ├── Staffing Model                   Chế độ: POSITION_BASED, JOB_BASED, HYBRID (per Legal Entity)
│   │   └── Global Assignments               NV làm việc cross-entity/cross-country
│   │
│   ├── 2.3 Contracts                        ─── Hợp đồng lao động
│   │   ├── Contract List                    Danh sách hợp đồng: active, expired, terminated
│   │   ├── Create/Edit Contract             Tạo/sửa: template-based, type, dates, terms
│   │   ├── Contract Templates               Quản lý templates: Definite, Indefinite, Seasonal, Probation
│   │   ├── Contract History                 Lịch sử: amendments, addendums, renewals, supersessions
│   │   └── Contract Alerts                  Cảnh báo: sắp hết hạn, cần gia hạn, probation ending
│   │
│   ├── 2.4 Onboarding                       ─── Nhập việc
│   │   ├── New Hire Checklist               Checklist: tài liệu, đào tạo, thiết bị, accounts
│   │   ├── Probation Tracking               Theo dõi thử việc: dates, review, extend, convert (P1)
│   │   └── Employee Identifiers             Mã số NV, payroll ID, badge number
│   │
│   └── 2.5 Separation                       ─── Nghỉ việc
│       ├── Termination                      Ghi nhận nghỉ việc: reason, type, last day (P1 — new entity)
│       ├── Clearance Process                Checklist trả đồ, close accounts, exit interview
│       └── Rehire Management                Tuyển lại NV cũ: link to previous record
│
├── 3. Job & Position                        ─── Công việc & vị trí
│   ├── 3.1 Job Architecture                 ─── Kiến trúc công việc
│   │   ├── Taxonomy Trees                   Cây phân loại: Job Family → Sub-Family → Specialization
│   │   ├── Taxonomy Management              Tạo/sửa taxonomies: owner scope (CORP/LE/BU), override rules
│   │   ├── Cross-Tree Mapping               Mapping giữa các taxonomy trees
│   │   └── Job Tree                         Cây job: hierarchy with parent/child relationships
│   │
│   ├── 3.2 Job Definitions                  ─── Định nghĩa công việc
│   │   ├── Job List                         Danh sách jobs: code, title, family, level, grade
│   │   ├── Create/Edit Job                  Tạo/sửa: title, description, qualifications, scope
│   │   ├── Job Profiles                     Profile: skills, competencies, certifications required
│   │   └── Job Cross-References             Job mapping → external systems
│   │
│   ├── 3.3 Grade & Level                    ─── Cấp bậc & mức độ
│   │   ├── Job Levels                       Levels: L1-L10, per scope (CORP/LE/BU)
│   │   ├── Job Grades                       Grades: pay band assignment, per scope
│   │   └── Level Policies                   Chính sách per level: benefits, leave, approval thresholds
│   │
│   └── 3.4 Position Management              ─── Quản lý vị trí
│       ├── Position List                    Danh sách positions: filled, vacant, frozen
│       ├── Create/Edit Position             Tạo/sửa: title, job link, BU, location, headcount
│       ├── Position Tags                    Gắn tags: critical, hard-to-fill, key-person
│       ├── Position Locations               Location assignment: primary, secondary, remote
│       └── Vacancy Management               Quản lý vị trí trống: budget approval, posting
│
├── 4. Career                                ─── Phát triển sự nghiệp
│   ├── 4.1 Career Paths                     ─── Lộ trình sự nghiệp
│   │   ├── Career Path List                 Danh sách paths: Technical, Management, Specialist
│   │   ├── Create/Edit Path                 Tạo/sửa: name, description, entry/exit criteria
│   │   └── Career Steps                     Các bước trong path: required skills, duration, milestones
│   │
│   └── 4.2 Job Progression                  ─── Lịch sử thăng tiến
│       ├── Employee Progression             Lịch sử job/level/grade changes per NV
│       └── Progression Analytics            Phân tích: avg time per level, promotion rates by dept
│
├── 5. Employee Compensation                 ─── Lương NV (operational data)
│   │
│   │   Note: Đây là OPERATIONAL data — lương thực tế NV hiện hưởng
│   │         Policy/config (salary basis, pay components, grades) thuộc TR module
│   │         Schema sẽ rename compensation → emp_comp (per deep analysis)
│   │
│   ├── 5.1 Compensation Basis               ─── Cơ sở lương
│   │   ├── Employee Comp Overview           Tổng quan lương NV: basis, lines, effective dates
│   │   ├── Compensation History             Lịch sử: SCD-2 trail, approval status, version tracking
│   │   └── Comp Basis Lines                 Chi tiết thành phần: base + allowances → total
│   │
│   └── 5.2 Tax Dependents                   ─── Người phụ thuộc thuế
│       └── Dependent Registration           Đăng ký cho giảm trừ thuế TNCN (VN: 4.4M/dependent/month)
│
├── 6. Location & Facility                   ─── Địa điểm & cơ sở
│   ├── 6.1 Facilities                       ─── Cơ sở
│   │   ├── Place List                       Danh sách places: offices, campuses, sites
│   │   ├── Location Management              Quản lý locations trong place: floors, rooms, areas
│   │   └── Work Locations                   Work locations: đặt tên, link to geo, capacity
│   │
│   └── 6.2 Vendor/Supplier                  ─── Nhà cung cấp
│       └── Vendor Companies                 Danh sách vendors: outsourcing, staffing agencies
│
├── 7. Shared Services                       ─── Dịch vụ dùng chung (cross-module)
│   ├── 7.1 Eligibility Engine               ─── Engine đủ điều kiện (single source of truth)
│   │   ├── Eligibility Profiles             Danh sách profiles: domain (ABSENCE, BENEFITS, COMPENSATION,
│   │   │                                    TIME_ATTENDANCE, RECOGNITION, PAYROLL, CORE), rule_json, priority
│   │   ├── Create/Edit Profile              Tạo/sửa: grades, countries, tenure, worker_category, age_range,
│   │   │                                    custom attributes — JSON rule-based
│   │   ├── Profile Members                  Cached membership: auto-evaluated, manual override
│   │   ├── Evaluation Log                   Immutable audit: result, reason, triggered_by
│   │   ├── Batch Evaluation                 Schedule batch re-evaluation (e.g. nightly, on-change)
│   │   └── Profile Analytics                Thống kê: members per profile, evaluation hit rate
│   │
│   ├── 7.2 Country Configuration            ─── Cấu hình quốc gia (consolidated — Doc 06)
│   │   ├── Country Config                   Per country: currency, tax_system, si_system,
│   │   │                                    working hours/days (standard_working_hours_per_day = 8)
│   │   └── Talent Market Parameters         Per market: min_wage, max_si_basis, zone-specific settings
│   │
│   │   Note: Country = 1 config. Market = N per country (VN_HCM, VN_HN, VN_RURAL)
│   │
│   └── 7.3 Holiday Calendar                 ─── Lịch ngày lễ (consolidated — Doc 06)
│       ├── Holiday Calendar                 Per country + jurisdiction: date, name, type, OT multiplier
│       ├── Manage Holidays                  Thêm/sửa holidays: NATIONAL, REGIONAL, BANK, OPTIONAL
│       └── Calendar Import                  Import holidays: per year, per country (bulk)
│
├── 8. Master Data                           ─── Dữ liệu chủ
│   ├── 8.1 Code Lists                       ─── Danh mục mã
│   │   ├── Code List Management             Quản lý lookup tables: type, code, name, display_order
│   │   └── Code List Categories             Categories: EMPLOYEE_TYPE, CONTRACT_TYPE, TERMINATION_REASON...
│   │
│   ├── 8.2 Geography                        ─── Dữ liệu địa lý
│   │   ├── Countries                        ISO-3166 country master: code, name, region, sub-region
│   │   ├── Administrative Areas             Tỉnh/thành, quận/huyện (for address + SI reporting)
│   │   └── Country Locales                  Locale settings: language, date format, number format
│   │
│   ├── 8.3 Currency & Timezone              ─── Tiền tệ & múi giờ
│   │   ├── Currencies                       ISO-4217: code, name, decimal places, symbol
│   │   └── Timezones                        Timezone management: UTC offsets, DST rules
│   │
│   └── 8.4 Skills & Industries              ─── Kỹ năng & ngành nghề
│       ├── Skill Catalog                    Danh mục kỹ năng: technical, soft skills, certifications
│       └── Industry Codes                   Mã ngành nghề (ISIC/VSIC)
│
└── 9. Settings & Administration             ─── Cài đặt & quản trị
    ├── 9.1 System Configuration             ─── Cấu hình hệ thống
    │   ├── Scope Management                 Owner scope rules: CORP, LE, BU — override/inherit policy
    │   └── Naming Conventions               Standard: timestamps, booleans, status codes (Doc 09)
    │
    ├── 9.2 Audit                            ─── Kiểm toán
    │   └── Change Audit Log                 Mọi thay đổi master data: who, when, before/after
    │
    └── 9.3 Integration                      ─── Tích hợp
        ├── TA Integration                   Cung cấp → TA: employee, assignment, eligibility, holidays
        ├── TR Integration                   Cung cấp → TR: employee, grade, position, eligibility
        └── PR Integration                   Cung cấp → PR: employee, assignment, legal entity, country config
```

---

## Schema → Menu Mapping

| # | Schema | Tables | Menu Section |
|:-:|--------|:------:|:------------:|
| 1 | `common` | 9 | 8. Master Data |
| 2 | `geo` | 3 | 8.2 Geography |
| 3 | `org_legal` | 4 | 1.1 Legal Entities |
| 4 | `org_bu` | 3 | 1.2 Business Units |
| 5 | `org_relation` | 1 | 1.3 Org Relationships |
| 6 | `org_assignment` | 1 | 1.3 Matrix Assignments |
| 7 | `org_snapshot` | 1 | 1.3 Org Snapshots |
| 8 | `person` | 5 | 2.1 Worker & Person |
| 9 | `employment` | 7 | 2.2-2.5 Employment lifecycle |
| 10 | `jobpos` | 14 | 3. Job & Position |
| 11 | `career` | 3 | 4. Career |
| 12 | `facility` | 3 | 6. Location & Facility |
| 13 | `vendor` | 1 | 6.2 Vendor |
| 14 | `tax` | 1 | 5.2 Tax Dependents |
| 15 | `eligibility` | 3 | 7.1 Eligibility Engine (shared) |
| 16 | `compensation` | 2 | 5. Employee Compensation |
| — | `common.country_config` | NEW | 7.2 Country Config (from TR) |
| — | `common.holiday_calendar` | NEW | 7.3 Holiday Calendar (consolidated) |

---

## Menu by User Role

### HR Administrator
```
1. Organization > Legal Entities, BU, Org Chart
2. Workforce > Worker Directory, Employment, Contracts, Onboarding, Separation
3. Job & Position > Job Architecture, Definitions, Positions
5. Employee Compensation > Overview, History
7. Shared Services > Eligibility, Country Config, Holidays
8. Master Data > Code Lists, Geography, Currency
9. Settings > All
```

### HR Manager
```
1.4 Org Chart > Visual, Headcount
2.1 Worker > Directory, Personal Info
2.2 Employment > Assignments, History
3.4 Position > Vacancy Management
4. Career > Progression Analytics
```

### Employee (Self-Service)
```
2.1 Worker > My Personal Info, My Contacts, My Documents
2.2 Employment > My Assignment, My History
2.3 Contracts > My Contracts
4.2 Career > My Job Progression
5.1 Employee Comp > My Compensation Overview
5.2 Tax Dependents > My Dependent Registration
```

### System Administrator
```
7. Shared Services > Eligibility Engine, Country Config, Holiday Calendar
8. Master Data > All (Code Lists, Geography, Currency, Skills)
9. Settings > Scope Management, Audit, Integration
```

### Compensation Manager
```
3.3 Grade & Level > Job Levels, Grades, Level Policies
5. Employee Compensation > Overview, History, Basis Lines
7.2 Country Config > Working hours, tax/SI system
```
