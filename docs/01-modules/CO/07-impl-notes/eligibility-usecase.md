# HCM Eligibility Rules - Comprehensive Specification

## 1. Executive Summary

Tài liệu này định nghĩa **42 Eligibility Rules** cho hệ thống HCM, bao phủ 4 modules chính: **Core HR**, **Time & Absence**, **Total Rewards**, và **Payroll**. Mỗi rule được thiết kế để xác định tập hợp employees đủ điều kiện cho các chính sách, benefits, hoặc processes cụ thể.

Eligibility Rules sử dụng **Apache TinkerPop/Gremlin Query Language**, cho phép traverse qua Employee Data Graph một cách linh hoạt và mạnh mẽ. Rules được **validate tại thời điểm save** và execute trực tiếp tại runtime mà không cần re-validation.

---

## 2. Module Overview

| Module | Rules Count | Scope |
|--------|-------------|-------|
| **Core HR** | 10 | Employee lifecycle, org structure, compliance, workforce planning |
| **Time & Absence** | 12 | Leave policies, time tracking, absence management, carryover rules |
| **Total Rewards** | 10 | Benefits enrollment, compensation, stock plans, wellness programs |
| **Payroll** | 10 | Payment processing, tax handling, deductions, garnishments |

---

## 3. Core HR Module

Core HR module chứa các eligibility rules liên quan đến employee lifecycle, organizational structure, compliance requirements, và workforce planning.

---

### CORE-001: Active Regular Employees

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | CORE-001 |
| **Purpose** | Xác định tất cả employees đang active với employment type là regular (full-time hoặc part-time). Đây là **base rule** được nhiều rules khác reference. |
| **Use Cases** | • Base eligibility cho hầu hết HR policies<br>• Headcount reporting và workforce analytics<br>• Default population cho annual processes (reviews, surveys) |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', within('full-time', 'part-time'))` |
| **Conditions** | • status = 'active'<br>• employment_type IN ('full-time', 'part-time')<br>• Excludes: contractors, interns, terminated employees |

---

### CORE-002: Management Tier Employees

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | CORE-002 |
| **Purpose** | Xác định employees có position thuộc management tier (có direct reports hoặc grade level >= 7). Dùng cho management-specific policies và reporting. |
| **Use Cases** | • Management training programs enrollment<br>• Leadership development initiatives<br>• Executive compensation reviews<br>• Management-only communications và town halls |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').or(where(in('reports_to').hasLabel('employee')), where(out('has_position').out('has_grade').has('level', gte(7))))` |
| **Conditions** | • status = 'active'<br>• Has at least one direct report OR grade level >= 7<br>• Position typically includes: Manager, Director, VP, C-level |

---

### CORE-003: Tenure-based Senior Employees

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | CORE-003 |
| **Purpose** | Xác định employees có tenure >= 5 năm. Senior employees thường eligible cho enhanced benefits, sabbatical, hoặc special recognition programs. |
| **Use Cases** | • Sabbatical leave eligibility<br>• Service awards (5, 10, 15, 20 year milestones)<br>• Enhanced retirement contributions<br>• Mentorship program participation as mentors |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('hire_date', lt(yearsAgo(5)))` |
| **Conditions** | • status = 'active'<br>• hire_date < (today - 5 years)<br>• Continuous employment (no breaks > 30 days) |

---

### CORE-004: Location-specific Compliance

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | CORE-004 |
| **Purpose** | Xác định employees làm việc tại locations có yêu cầu compliance đặc biệt (EU GDPR, California CCPA, etc.). Dùng cho training requirements và policy enforcement. |
| **Use Cases** | • GDPR compliance training (EU employees)<br>• CCPA privacy training (California employees)<br>• Local labor law compliance<br>• Region-specific policy acknowledgments |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').where(out('works_at').has('country', within('DE', 'FR', 'GB', 'NL', 'ES', 'IT')))` |
| **Conditions** | • status = 'active'<br>• work_location.country IN (EU countries list)<br>• Parameterizable for different compliance regions |

---

### CORE-005: New Hire Onboarding Window

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | CORE-005 |
| **Purpose** | Xác định employees trong 90-day onboarding period. Dùng để trigger onboarding tasks, buddy assignments, và probation reviews. |
| **Use Cases** | • Onboarding checklist assignments<br>• New hire orientation scheduling<br>• 30-60-90 day check-in reminders<br>• Probation period tracking<br>• Buddy/mentor auto-assignment |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('hire_date', gte(daysAgo(90)))` |
| **Conditions** | • status = 'active'<br>• hire_date >= (today - 90 days)<br>• Configurable window (30, 60, 90, 180 days) |

---

### CORE-006: Department Transfer Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | CORE-006 |
| **Purpose** | Xác định employees đủ điều kiện apply internal transfer. Thường yêu cầu minimum tenure trong current position và good standing. |
| **Use Cases** | • Internal job posting eligibility<br>• Lateral move approvals<br>• Cross-functional project assignments<br>• Talent mobility programs |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('position_start_date', lt(yearsAgo(1))).has('performance_rating', gte(3)).hasNot('active_pip')` |
| **Conditions** | • status = 'active'<br>• Time in current position >= 1 year<br>• Performance rating >= 3 (Meets Expectations)<br>• Not on Performance Improvement Plan (PIP) |

---

### CORE-007: Promotion Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | CORE-007 |
| **Purpose** | Xác định employees đủ điều kiện được xem xét promotion trong next review cycle. Based on tenure, performance, và readiness assessment. |
| **Use Cases** | • Annual promotion cycle nominations<br>• Succession planning candidates<br>• Leadership pipeline identification<br>• Compensation review inclusions |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('hire_date', lt(yearsAgo(2))).has('performance_rating', gte(4)).where(out('has_position').out('has_grade').has('level', lt(10)))` |
| **Conditions** | • status = 'active'<br>• tenure >= 2 years<br>• performance_rating >= 4 (Exceeds Expectations)<br>• Current grade < 10 (not at max level) |

---

### CORE-008: Remote Work Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | CORE-008 |
| **Purpose** | Xác định employees eligible cho remote work arrangement. Based on role type, tenure, performance, và department policy. |
| **Use Cases** | • Remote work request approval workflow<br>• Work-from-home equipment provisioning<br>• Hybrid schedule assignments<br>• Remote work policy enforcement |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('hire_date', lt(monthsAgo(6))).has('performance_rating', gte(3)).where(out('has_position').has('remote_eligible', true)).where(out('works_in').has('allows_remote', true))` |
| **Conditions** | • status = 'active'<br>• tenure >= 6 months<br>• performance_rating >= 3<br>• position.remote_eligible = true<br>• department.allows_remote = true |

---

### CORE-009: Contractor Conversion Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | CORE-009 |
| **Purpose** | Xác định contractors đủ điều kiện được convert thành regular employees. Important cho compliance (avoid misclassification) và talent retention. |
| **Use Cases** | • Contractor-to-FTE conversion pipeline<br>• Headcount planning for conversions<br>• Budget allocation for conversions<br>• Compliance monitoring (tenure limits) |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', 'contractor').has('hire_date', lt(monthsAgo(6))).has('hire_date', gte(monthsAgo(18))).has('contractor_performance', gte(4))` |
| **Conditions** | • status = 'active'<br>• employment_type = 'contractor'<br>• tenure between 6 and 18 months<br>• contractor_performance >= 4<br>• No compliance violations |

---

### CORE-010: Exit Interview Requirement

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | CORE-010 |
| **Purpose** | Xác định employees cần conduct exit interview khi termination. Thường áp dụng cho regular employees với minimum tenure. |
| **Use Cases** | • Exit interview scheduling automation<br>• Turnover analysis data collection<br>• Knowledge transfer requirements<br>• Off-boarding checklist triggers |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'pending_termination').has('employment_type', within('full-time', 'part-time')).has('hire_date', lt(monthsAgo(3))).has('termination_type', 'voluntary')` |
| **Conditions** | • status = 'pending_termination'<br>• employment_type IN ('full-time', 'part-time')<br>• tenure >= 3 months<br>• termination_type = 'voluntary' |

---

## 4. Time & Absence Module

Time & Absence module định nghĩa eligibility rules cho các leave policies, time tracking requirements, và absence management. Rules này quyết định employees nào được access các loại leave khác nhau và các điều kiện accrual.

---

### TIME-001: PTO Accrual Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-001 |
| **Purpose** | Xác định employees eligible cho PTO accrual. Regular employees bắt đầu accrue PTO sau probation period hoàn thành. |
| **Use Cases** | • Monthly PTO accrual calculation<br>• PTO balance reporting<br>• Leave request validation<br>• Accrual rate tier assignment |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', within('full-time', 'part-time')).has('hire_date', lt(daysAgo(90)))` |
| **Conditions** | • status = 'active'<br>• employment_type IN ('full-time', 'part-time')<br>• tenure >= 90 days (probation complete)<br>• Part-time accrues pro-rata based on FTE% |

---

### TIME-002: Enhanced PTO (Senior Tier)

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-002 |
| **Purpose** | Xác định employees eligible cho enhanced PTO accrual rate (25 days/year vs standard 15 days). Based on tenure hoặc grade level. |
| **Use Cases** | • Tiered PTO accrual rate assignment<br>• Senior employee retention incentive<br>• Automatic tier upgrade notifications<br>• PTO liability forecasting |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', 'full-time').or(has('hire_date', lt(yearsAgo(5))), where(out('has_position').out('has_grade').has('level', gte(7))))` |
| **Conditions** | • status = 'active'<br>• employment_type = 'full-time'<br>• tenure >= 5 years OR grade >= 7<br>• Accrual: 25 days/year vs 15 days standard |

---

### TIME-003: PTO Carryover Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-003 |
| **Purpose** | Xác định employees có thể carryover unused PTO sang năm mới. Important cho year-end PTO balance processing. |
| **Use Cases** | • Year-end carryover calculation<br>• Carryover cap enforcement<br>• Use-it-or-lose-it notifications<br>• PTO liability management |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', within('full-time', 'part-time')).where(out('works_at').has('country', within('US', 'CA', 'GB')))` |
| **Conditions** | • status = 'active'<br>• employment_type IN ('full-time', 'part-time')<br>• work_location.country IN (countries allowing carryover)<br>• Carryover cap: typically 5-10 days max |

---

### TIME-004: Sick Leave Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-004 |
| **Purpose** | Xác định employees eligible cho paid sick leave. Varies by location do local labor laws (e.g., California mandates). |
| **Use Cases** | • Sick leave request validation<br>• Sick leave balance calculation<br>• Compliance với local sick leave laws<br>• Sick leave accrual processing |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', neq('contractor'))` |
| **Conditions** | • status = 'active'<br>• employment_type != 'contractor'<br>• No minimum tenure (available from day 1)<br>• Accrual rate varies by location |

---

### TIME-005: FMLA Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-005 |
| **Purpose** | Xác định employees eligible cho Family and Medical Leave Act (FMLA) protection. US-specific với strict eligibility requirements. |
| **Use Cases** | • FMLA leave request validation<br>• FMLA eligibility notifications<br>• Job protection tracking<br>• FMLA usage reporting cho compliance |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('hire_date', lt(yearsAgo(1))).has('hours_worked_12mo', gte(1250)).where(out('works_at').has('country', 'US')).where(out('works_at').has('employees_at_location', gte(50)))` |
| **Conditions** | • status = 'active'<br>• tenure >= 12 months<br>• hours_worked_12mo >= 1,250 hours<br>• work_location.country = 'US'<br>• work_location.employees_at_location >= 50 |

---

### TIME-006: Parental Leave Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-006 |
| **Purpose** | Xác định employees eligible cho paid parental leave (birth, adoption, foster). Enhanced benefit beyond FMLA. |
| **Use Cases** | • Parental leave request processing<br>• Parental leave planning và scheduling<br>• Benefits continuation during leave<br>• Return-to-work planning |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', within('full-time', 'part-time')).has('hire_date', lt(yearsAgo(1)))` |
| **Conditions** | • status = 'active'<br>• employment_type IN ('full-time', 'part-time')<br>• tenure >= 1 year<br>• Benefit: 12 weeks paid (birth parent), 4 weeks (non-birth parent) |

---

### TIME-007: Sabbatical Leave Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-007 |
| **Purpose** | Xác định employees eligible cho paid sabbatical leave. Premium benefit cho long-tenured employees để recharge hoặc pursue personal projects. |
| **Use Cases** | • Sabbatical request approval workflow<br>• Long-term coverage planning<br>• Retention program for senior employees<br>• Sabbatical return planning |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', 'full-time').has('hire_date', lt(yearsAgo(7))).has('last_sabbatical', lt(yearsAgo(7))).has('performance_rating', gte(3))` |
| **Conditions** | • status = 'active'<br>• employment_type = 'full-time'<br>• tenure >= 7 years<br>• last_sabbatical > 7 years ago OR never taken<br>• performance_rating >= 3<br>• Benefit: 4-6 weeks paid |

---

### TIME-008: Bereavement Leave Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-008 |
| **Purpose** | Xác định employees eligible cho paid bereavement leave. Typically all employees eligible với varying days based on relationship. |
| **Use Cases** | • Bereavement leave request processing<br>• Automatic approval workflow<br>• Grief support resource provisioning<br>• Extended bereavement options |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', neq('contractor'))` |
| **Conditions** | • status = 'active'<br>• employment_type != 'contractor'<br>• No tenure requirement<br>• Days: 5 (immediate family), 3 (extended family) |

---

### TIME-009: Jury Duty Leave

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-009 |
| **Purpose** | Xác định employees eligible cho paid jury duty leave. Legal requirement với full pay continuation. |
| **Use Cases** | • Jury duty leave request processing<br>• Pay continuation during jury service<br>• Documentation collection<br>• Workload reallocation |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active')` |
| **Conditions** | • status = 'active'<br>• All employees eligible<br>• Requires court summons documentation<br>• Full pay for duration of service |

---

### TIME-010: Overtime Eligibility (Non-Exempt)

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-010 |
| **Purpose** | Xác định employees eligible cho overtime pay (1.5x rate). Based on FLSA exempt/non-exempt status. |
| **Use Cases** | • Overtime calculation processing<br>• Time entry validation<br>• FLSA compliance reporting<br>• Labor cost forecasting |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').where(out('has_position').has('flsa_status', 'non-exempt'))` |
| **Conditions** | • status = 'active'<br>• position.flsa_status = 'non-exempt'<br>• Overtime triggers: >40 hours/week (federal)<br>• California: >8 hours/day also triggers OT |

---

### TIME-011: Flexible Schedule Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-011 |
| **Purpose** | Xác định employees có thể request flexible work schedule (compressed work week, flex hours, etc.). |
| **Use Cases** | • Flexible schedule request processing<br>• 9/80 or 4/10 schedule enrollment<br>• Core hours compliance checking<br>• Work-life balance initiatives |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', 'full-time').has('hire_date', lt(monthsAgo(6))).has('performance_rating', gte(3)).where(out('works_in').has('flex_schedule_allowed', true))` |
| **Conditions** | • status = 'active'<br>• employment_type = 'full-time'<br>• tenure >= 6 months<br>• performance_rating >= 3<br>• department.flex_schedule_allowed = true |

---

### TIME-012: Comp Time Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | TIME-012 |
| **Purpose** | Xác định employees eligible cho compensatory time off thay vì overtime pay. Typically cho exempt employees hoặc public sector. |
| **Use Cases** | • Comp time accrual tracking<br>• Comp time vs OT pay election<br>• Comp time balance management<br>• Public sector compliance |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').where(out('has_position').has('flsa_status', 'exempt')).where(out('works_in').has('comp_time_allowed', true))` |
| **Conditions** | • status = 'active'<br>• position.flsa_status = 'exempt'<br>• department.comp_time_allowed = true<br>• Comp time rate: 1:1 (not 1.5x) |

---

## 5. Total Rewards Module

Total Rewards module bao gồm eligibility rules cho benefits enrollment, compensation programs, stock/equity plans, và wellness initiatives. Rules này quyết định ai được access các benefits packages khác nhau.

---

### REWARD-001: Medical Benefits Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | REWARD-001 |
| **Purpose** | Xác định employees eligible cho medical/health insurance enrollment. Core benefit với waiting period. |
| **Use Cases** | • Open enrollment eligibility<br>• New hire benefits enrollment<br>• Qualifying life event processing<br>• Benefits cost forecasting |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', within('full-time', 'part-time')).has('scheduled_hours', gte(30)).has('hire_date', lt(daysAgo(30)))` |
| **Conditions** | • status = 'active'<br>• employment_type IN ('full-time', 'part-time')<br>• scheduled_hours >= 30 per week (ACA requirement)<br>• tenure >= 30 days (waiting period)<br>• Includes dependent coverage option |

---

### REWARD-002: 401(k) Plan Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | REWARD-002 |
| **Purpose** | Xác định employees eligible cho 401(k) retirement plan enrollment và company matching. |
| **Use Cases** | • 401(k) enrollment processing<br>• Company match calculation<br>• Vesting schedule tracking<br>• Retirement planning eligibility |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', within('full-time', 'part-time')).has('age', gte(21)).has('hire_date', lt(daysAgo(90)))` |
| **Conditions** | • status = 'active'<br>• employment_type IN ('full-time', 'part-time')<br>• age >= 21 (ERISA requirement)<br>• tenure >= 90 days<br>• Company match: 50% up to 6% contribution |

---

### REWARD-003: Stock Option Grant Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | REWARD-003 |
| **Purpose** | Xác định employees eligible cho annual stock option grants. Typically limited to certain grades hoặc performance tiers. |
| **Use Cases** | • Annual equity grant planning<br>• New hire equity packages<br>• Promotion equity adjustments<br>• Retention grant targeting |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', 'full-time').has('hire_date', lt(yearsAgo(1))).where(out('has_position').out('has_grade').has('level', gte(5))).has('performance_rating', gte(3))` |
| **Conditions** | • status = 'active'<br>• employment_type = 'full-time'<br>• tenure >= 1 year<br>• grade >= 5<br>• performance_rating >= 3<br>• Vesting: 4-year với 1-year cliff |

---

### REWARD-004: ESPP (Employee Stock Purchase Plan)

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | REWARD-004 |
| **Purpose** | Xác định employees eligible cho Employee Stock Purchase Plan. Allows purchasing company stock at discount. |
| **Use Cases** | • ESPP enrollment periods<br>• Contribution rate changes<br>• Purchase date processing<br>• ESPP communication targeting |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', within('full-time', 'part-time')).has('scheduled_hours', gte(20)).has('hire_date', lt(daysAgo(90))).has('owns_5pct_stock', false)` |
| **Conditions** | • status = 'active'<br>• employment_type IN ('full-time', 'part-time')<br>• scheduled_hours >= 20 per week<br>• tenure >= 90 days<br>• owns_5pct_stock = false (Section 423 requirement)<br>• Discount: 15% off lower of offer/purchase price |

---

### REWARD-005: Annual Bonus Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | REWARD-005 |
| **Purpose** | Xác định employees eligible cho annual performance bonus. Based on tenure, employment type, và performance. |
| **Use Cases** | • Bonus pool allocation<br>• Bonus calculation processing<br>• Performance-to-bonus mapping<br>• Compensation planning |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', 'full-time').has('hire_date', lt(monthsAgo(6))).has('performance_rating', gte(2)).hasNot('active_pip')` |
| **Conditions** | • status = 'active'<br>• employment_type = 'full-time'<br>• tenure >= 6 months (pro-rated if < 12 months)<br>• performance_rating >= 2<br>• Not on active PIP<br>• Target: 10-20% of base salary based on grade |

---

### REWARD-006: Executive Compensation Plan

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | REWARD-006 |
| **Purpose** | Xác định employees eligible cho executive compensation package (enhanced bonus, deferred comp, executive benefits). |
| **Use Cases** | • Executive benefits enrollment<br>• Deferred compensation plan<br>• Executive health benefits<br>• Supplemental life insurance |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').where(out('has_position').out('has_grade').has('level', gte(10))).or(where(out('has_position').has('title', containing('VP'))), where(out('has_position').has('title', containing('Director'))), where(out('has_position').has('executive_level', true)))` |
| **Conditions** | • status = 'active'<br>• grade >= 10 OR<br>• title contains 'VP', 'Director', 'Chief' OR<br>• position.executive_level = true<br>• Enhanced benefits: car allowance, financial planning, executive physical |

---

### REWARD-007: Tuition Reimbursement

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | REWARD-007 |
| **Purpose** | Xác định employees eligible cho tuition reimbursement program. Supports continuing education aligned với job role. |
| **Use Cases** | • Education assistance requests<br>• Pre-approval workflow<br>• Reimbursement processing<br>• Tax reporting (over $5,250) |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', 'full-time').has('hire_date', lt(yearsAgo(1))).has('performance_rating', gte(3))` |
| **Conditions** | • status = 'active'<br>• employment_type = 'full-time'<br>• tenure >= 1 year<br>• performance_rating >= 3<br>• Annual cap: $5,250 (tax-free), up to $10,000 total<br>• Service agreement: 2 years post-completion |

---

### REWARD-008: Wellness Program Incentive

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | REWARD-008 |
| **Purpose** | Xác định employees eligible cho wellness program incentives (gym reimbursement, health screenings, etc.). |
| **Use Cases** | • Wellness program enrollment<br>• Incentive payout processing<br>• Health screening scheduling<br>• Fitness challenge participation |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', within('full-time', 'part-time')).where(out('enrolled_in').has('plan_type', 'health'))` |
| **Conditions** | • status = 'active'<br>• employment_type IN ('full-time', 'part-time')<br>• Enrolled in company health plan<br>• Incentive: $500/year for completing wellness activities |

---

### REWARD-009: HSA Contribution Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | REWARD-009 |
| **Purpose** | Xác định employees eligible cho Health Savings Account (HSA) contributions. Requires enrollment in HDHP. |
| **Use Cases** | • HSA enrollment processing<br>• Employer HSA contribution<br>• HSA contribution limit tracking<br>• HDHP-HSA coordination |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').where(out('enrolled_in').has('plan_type', 'HDHP')).has('has_other_health_coverage', false).has('medicare_enrolled', false)` |
| **Conditions** | • status = 'active'<br>• Enrolled in High Deductible Health Plan (HDHP)<br>• has_other_health_coverage = false<br>• medicare_enrolled = false<br>• 2025 limits: $4,150 individual, $8,300 family |

---

### REWARD-010: Dependent Care FSA

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | REWARD-010 |
| **Purpose** | Xác định employees eligible cho Dependent Care FSA enrollment. Pre-tax dollars for childcare/eldercare. |
| **Use Cases** | • FSA enrollment processing<br>• Contribution election<br>• Claim reimbursement<br>• Year-end forfeiture processing |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').has('employment_type', within('full-time', 'part-time')).has('scheduled_hours', gte(20))` |
| **Conditions** | • status = 'active'<br>• employment_type IN ('full-time', 'part-time')<br>• scheduled_hours >= 20 per week<br>• Annual limit: $5,000 (married filing jointly) |

---

## 6. Payroll Module

Payroll module định nghĩa eligibility rules cho payment processing, tax handling, deductions, và garnishments. Rules này đảm bảo correct payroll calculations và compliance với regulations.

---

### PAY-001: Direct Deposit Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | PAY-001 |
| **Purpose** | Xác định employees eligible cho direct deposit payment method. All paid employees typically eligible. |
| **Use Cases** | • Direct deposit enrollment<br>• Bank account verification<br>• Payment method assignment<br>• ACH processing eligibility |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', within('active', 'leave')).has('pay_type', within('salary', 'hourly'))` |
| **Conditions** | • status IN ('active', 'leave')<br>• pay_type IN ('salary', 'hourly')<br>• Valid bank account required<br>• Supports split deposits to multiple accounts |

---

### PAY-002: Biweekly Pay Cycle

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | PAY-002 |
| **Purpose** | Xác định employees processed trong biweekly pay cycle. Separates from semi-monthly or monthly cycles. |
| **Use Cases** | • Pay cycle assignment<br>• Payroll processing scheduling<br>• Pay calendar generation<br>• Deduction timing calculations |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', within('active', 'leave')).has('pay_frequency', 'biweekly')` |
| **Conditions** | • status IN ('active', 'leave')<br>• pay_frequency = 'biweekly'<br>• Typically hourly/non-exempt employees<br>• 26 pay periods per year |

---

### PAY-003: State Tax Withholding

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | PAY-003 |
| **Purpose** | Xác định employees subject to state income tax withholding based on work location. Handles no-tax states (TX, FL, etc.). |
| **Use Cases** | • State tax calculation<br>• Multi-state taxation handling<br>• Tax form generation (W-2)<br>• Reciprocity agreement processing |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', within('active', 'leave')).where(out('works_at').has('state', without('TX', 'FL', 'NV', 'WA', 'WY', 'SD', 'AK', 'NH', 'TN')))` |
| **Conditions** | • status IN ('active', 'leave')<br>• work_location.state NOT IN (no-income-tax states)<br>• Excludes: TX, FL, NV, WA, WY, SD, AK, NH, TN<br>• Handles remote work location differences |

---

### PAY-004: Local Tax Withholding

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | PAY-004 |
| **Purpose** | Xác định employees subject to local/city income tax. Common in PA, OH, NY, and certain cities. |
| **Use Cases** | • Local tax calculation<br>• City tax withholding<br>• School district tax (PA/OH)<br>• Local tax form generation |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', within('active', 'leave')).where(out('works_at').has('local_tax_required', true))` |
| **Conditions** | • status IN ('active', 'leave')<br>• work_location.local_tax_required = true<br>• Examples: NYC, Philadelphia, Columbus, Detroit<br>• May require resident vs non-resident rates |

---

### PAY-005: Garnishment Processing

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | PAY-005 |
| **Purpose** | Xác định employees với active garnishment orders. Ensures proper deduction và remittance to agencies. |
| **Use Cases** | • Garnishment deduction calculation<br>• Priority ordering (child support first)<br>• Disposable income calculation<br>• Agency remittance processing |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', within('active', 'leave')).where(out('has_garnishment').has('status', 'active'))` |
| **Conditions** | • status IN ('active', 'leave')<br>• Has active garnishment order<br>• Types: child support, tax levy, creditor, student loan<br>• Priority: child support > tax levy > others<br>• Protected amount limits apply |

---

### PAY-006: Shift Differential Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | PAY-006 |
| **Purpose** | Xác định employees eligible cho shift differential pay. Additional compensation cho off-hours work. |
| **Use Cases** | • Shift differential calculation<br>• Night shift premium<br>• Weekend premium<br>• Holiday premium pay |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').where(out('has_position').has('shift_eligible', true)).where(out('has_schedule').has('shift_type', within('evening', 'night', 'weekend')))` |
| **Conditions** | • status = 'active'<br>• position.shift_eligible = true<br>• schedule.shift_type IN ('evening', 'night', 'weekend')<br>• Differential: +10% evening, +15% night, +20% weekend |

---

### PAY-007: Retroactive Pay Processing

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | PAY-007 |
| **Purpose** | Xác định employees cần retroactive pay adjustment. Triggered by late salary changes, corrections, or union agreements. |
| **Use Cases** | • Retro pay calculation<br>• Salary increase backdating<br>• Union contract retro payments<br>• Error correction payments |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', within('active', 'leave', 'terminated')).where(out('has_pay_change').has('effective_date', lt(today())).has('processed', false))` |
| **Conditions** | • status IN ('active', 'leave', 'terminated')<br>• Has unprocessed pay change với effective date in past<br>• Includes: raises, demotions, corrections<br>• Tax recalculation required |

---

### PAY-008: Final Pay Processing

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | PAY-008 |
| **Purpose** | Xác định terminated employees cần final paycheck processing. Timing varies by state law. |
| **Use Cases** | • Final pay calculation<br>• PTO payout (if applicable)<br>• State-specific timing compliance<br>• Deduction final settlement |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'terminated').has('termination_date', gte(daysAgo(30))).has('final_pay_processed', false)` |
| **Conditions** | • status = 'terminated'<br>• termination_date within last 30 days<br>• final_pay_processed = false<br>• CA: same day (involuntary), 72 hours (voluntary)<br>• Most states: next regular payday |

---

### PAY-009: Multi-State Tax Allocation

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | PAY-009 |
| **Purpose** | Xác định employees working in multiple states requiring tax allocation. Common cho travel-heavy roles. |
| **Use Cases** | • Multi-state tax allocation<br>• Days-worked tracking by state<br>• Reciprocity agreement application<br>• Multiple W-2 generation |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').where(out('worked_in_state').count().is(gt(1)))` |
| **Conditions** | • status = 'active'<br>• Worked in > 1 state during tax year<br>• Includes: business travel, remote work, relocations<br>• Allocation based on days worked in each state |

---

### PAY-010: Commission Payment Eligibility

| Attribute | Description |
|-----------|-------------|
| **Rule ID** | PAY-010 |
| **Purpose** | Xác định employees eligible cho commission payments. Sales và revenue-generating roles với variable compensation. |
| **Use Cases** | • Commission calculation<br>• Quota attainment tracking<br>• Commission plan assignment<br>• Variable compensation forecasting |
| **Gremlin Query** | `g.V().hasLabel('employee').has('status', 'active').where(out('has_position').has('job_family', within('Sales', 'Business Development', 'Account Management'))).where(out('enrolled_in').has('plan_type', 'commission'))` |
| **Conditions** | • status = 'active'<br>• position.job_family IN sales-related families<br>• Enrolled in commission plan<br>• Payment timing: monthly or quarterly<br>• May include accelerators, SPIFs, bonuses |

---

## 7. Implementation Guidelines

### 7.1 Rule Validation

Tất cả Gremlin queries **PHẢI được validate tại thời điểm save rule**. Validation bao gồm:

1. **Syntax validation**: Parse query để ensure valid Gremlin syntax
2. **Security validation**: Whitelist allowed steps, block mutation operations (addV, addE, drop)
3. **Schema validation**: Verify referenced properties và edges exist trong Employee Graph schema
4. **Test execution**: Dry-run query với limit để verify it executes successfully

### 7.2 Rule Execution

Runtime execution **không cần re-validate** vì rules đã được validated khi save. Execution flow:

1. Load rule từ database
2. Bind helper functions (`today()`, `yearsAgo()`, etc.)
3. Execute Gremlin query against Employee Graph
4. Return list of eligible employee IDs

### 7.3 Helper Functions

Các helper functions được bind vào Gremlin engine:

| Function | Description | Example |
|----------|-------------|---------|
| `today()` | Current date | `has('hire_date', lt(today()))` |
| `daysAgo(n)` | Date n days ago | `has('hire_date', lt(daysAgo(90)))` |
| `monthsAgo(n)` | Date n months ago | `has('hire_date', lt(monthsAgo(6)))` |
| `yearsAgo(n)` | Date n years ago | `has('hire_date', lt(yearsAgo(5)))` |

### 7.4 Performance Considerations

1. **Index critical properties**: status, employment_type, hire_date
2. **Cache frequently-used rules**: Rules executed trong batch processes
3. **Limit result sets**: Use `.limit()` cho preview/testing
4. **Monitor query performance**: Log execution time cho optimization

### 7.5 Rule Versioning

Mỗi rule nên có:
- **version**: Semantic versioning (1.0, 1.1, 2.0)
- **effective_date**: When rule becomes active
- **expiry_date**: When rule is deprecated (optional)
- **audit trail**: Who changed, when, why

---

## 8. Employee Graph Schema

### 8.1 Vertex Labels

| Label | Key Properties |
|-------|----------------|
| `employee` | id, name, email, status, employment_type, hire_date, age, performance_rating |
| `department` | id, name, code, allows_remote, flex_schedule_allowed, comp_time_allowed |
| `position` | id, title, job_family, remote_eligible, shift_eligible, flsa_status, executive_level |
| `grade` | id, name, level (1-15) |
| `location` | id, name, city, state, country, local_tax_required, employees_at_location |
| `benefit_plan` | id, name, plan_type (health, HDHP, dental, vision, 401k, commission) |
| `garnishment` | id, type, status, amount |
| `schedule` | id, shift_type (day, evening, night, weekend) |

### 8.2 Edge Labels

| Edge | From → To | Properties |
|------|-----------|------------|
| `works_in` | employee → department | start_date |
| `has_position` | employee → position | start_date |
| `has_grade` | position → grade | - |
| `works_at` | employee → location | - |
| `reports_to` | employee → employee | - |
| `enrolled_in` | employee → benefit_plan | enrollment_date, coverage_level |
| `has_garnishment` | employee → garnishment | - |
| `has_schedule` | employee → schedule | - |
| `worked_in_state` | employee → location | days_worked |
| `has_pay_change` | employee → pay_change | effective_date, processed |

---

## 9. Quick Reference: All Rules

### Core HR (CORE-001 to CORE-010)
| ID | Name | Key Condition |
|----|------|---------------|
| CORE-001 | Active Regular Employees | status=active, type=FT/PT |
| CORE-002 | Management Tier | has reports OR grade>=7 |
| CORE-003 | Senior Employees | tenure>=5 years |
| CORE-004 | Location Compliance | EU locations |
| CORE-005 | New Hire Window | tenure<=90 days |
| CORE-006 | Transfer Eligibility | position tenure>=1yr, perf>=3 |
| CORE-007 | Promotion Eligibility | tenure>=2yr, perf>=4, grade<10 |
| CORE-008 | Remote Work | tenure>=6mo, dept allows |
| CORE-009 | Contractor Conversion | contractor, 6-18mo tenure |
| CORE-010 | Exit Interview | voluntary termination |

### Time & Absence (TIME-001 to TIME-012)
| ID | Name | Key Condition |
|----|------|---------------|
| TIME-001 | PTO Accrual | tenure>=90 days |
| TIME-002 | Enhanced PTO | tenure>=5yr OR grade>=7 |
| TIME-003 | PTO Carryover | location-based |
| TIME-004 | Sick Leave | non-contractor |
| TIME-005 | FMLA | US, tenure>=1yr, 1250hrs |
| TIME-006 | Parental Leave | tenure>=1 year |
| TIME-007 | Sabbatical | tenure>=7 years |
| TIME-008 | Bereavement | non-contractor |
| TIME-009 | Jury Duty | all active |
| TIME-010 | Overtime | non-exempt FLSA |
| TIME-011 | Flex Schedule | tenure>=6mo, dept allows |
| TIME-012 | Comp Time | exempt, dept allows |

### Total Rewards (REWARD-001 to REWARD-010)
| ID | Name | Key Condition |
|----|------|---------------|
| REWARD-001 | Medical Benefits | 30+ hrs/wk, tenure>=30d |
| REWARD-002 | 401(k) | age>=21, tenure>=90d |
| REWARD-003 | Stock Options | tenure>=1yr, grade>=5 |
| REWARD-004 | ESPP | 20+ hrs/wk, <5% owner |
| REWARD-005 | Annual Bonus | tenure>=6mo, no PIP |
| REWARD-006 | Executive Comp | grade>=10 OR VP/Director |
| REWARD-007 | Tuition Reimbursement | tenure>=1yr, perf>=3 |
| REWARD-008 | Wellness | enrolled in health plan |
| REWARD-009 | HSA | enrolled in HDHP |
| REWARD-010 | Dependent Care FSA | 20+ hrs/wk |

### Payroll (PAY-001 to PAY-010)
| ID | Name | Key Condition |
|----|------|---------------|
| PAY-001 | Direct Deposit | salary/hourly employees |
| PAY-002 | Biweekly Pay | pay_frequency=biweekly |
| PAY-003 | State Tax | non-zero tax states |
| PAY-004 | Local Tax | location requires |
| PAY-005 | Garnishment | has active order |
| PAY-006 | Shift Differential | shift eligible position |
| PAY-007 | Retro Pay | unprocessed pay changes |
| PAY-008 | Final Pay | recently terminated |
| PAY-009 | Multi-State Tax | worked in >1 state |
| PAY-010 | Commission | sales job family |

---

*Document Version: 1.0*
*Last Updated: December 2025*