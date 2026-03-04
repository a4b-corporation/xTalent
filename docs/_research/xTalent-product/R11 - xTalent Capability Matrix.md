# R11 - xTalent Capability Matrix: Chứng Minh Đáp Ứng 5 CEO KPIs

> *Tài liệu này mapping trực tiếp giữa 5 KPI CEO cần (từ R10) với các tính năng cụ thể của xTalent HCM — dùng làm nền tảng cho demo, pitch, và proposal cho khách hàng doanh nghiệp 2.000–10.000 nhân sự.*

---

## Tổng Quan: Kiến Trúc Module của xTalent

```
┌──────────────────────────────────────────────────────────────┐
│                    xTalent HCM Platform                      │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │    CO    │  │    TR    │  │    TA    │  │    PR    │    │
│  │ Core HR  │  │  Total   │  │ Time &   │  │ Payroll  │    │
│  │ 68 ent.  │  │ Rewards  │  │ Absence  │  │ Engine   │    │
│  │          │  │ 70 ent.  │  │          │  │          │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
│       │              │              │              │         │
│       └──────────────┴──────────────┴──────────────┘        │
│                    Single Data Platform                      │
│              (LegalEntity-isolated, Cloud-native)            │
└──────────────────────────────────────────────────────────────┘
```

**4 modules chính** với tổng cộng **138+ entities**, được thiết kế trên kiến trúc **LegalEntity-isolated** — mỗi pháp nhân là một boundary độc lập về dữ liệu.

---

## CEO KPI #1: PEOPLE COST VISIBILITY
### Yêu cầu: CEO biết chính xác chi phí nhân sự tổng, realtime, sai số <2%

---

### xTalent Giải Quyết Bằng Gì?

#### `TR Module` — Total Rewards: Unified Cost Architecture

| Feature | Mô tả kỹ thuật | Giải quyết vấn đề gì |
|:---|:---|:---|
| **CompensationPlan** entity | Định nghĩa cấu trúc lương tập trung — base pay, allowances, variable pay — trong 1 model duy nhất | Không còn lương base ở Excel, phụ cấp ở HR system, bonus ở email |
| **CompensationComponent** | 70+ component types: lương cơ bản, phụ cấp ăn, điện thoại, nhà ở, OT, thưởng KPI, ESOP... tất cả đều typed và tracked | Mọi khoản chi phí nhân sự đều có category cụ thể |
| **Payroll Tax Bridge** | Automatic linking giữa taxable benefits → payroll calculation | Phụ lợi (xe công ty, bảo hiểm tư, v.v.) được tính đúng vào total cost |
| **TR Statement** | Báo cáo tổng chi phí nhân sự per worker — tất cả components | Employee nhìn thấy toàn bộ compensation package; CFO nhìn thấy total cost |
| **Multi-country Compensation** (sub-module 10) | Handle compensation theo jurisdiction: VND/THB/KHR, khác nhau về structure | Không cần convert thủ công khi tổng hợp báo cáo tập đoàn |

#### `CO Module` — Core HR: Single Source of Truth

| Feature | Mô tả kỹ thuật | Giải quyết vấn đề gì |
|:---|:---|:---|
| **LegalEntity** entity (AGGREGATE_ROOT) | Mỗi công ty con là 1 LegalEntity độc lập, với boundary riêng về data và cost center | Dữ liệu entity A không lẫn entity B |
| **BusinessUnit** entity | Cost center tự động gắn với mọi CompensationAssignment | Báo cáo chi phí theo phòng ban, site, entity ngay lập tức |
| **Employee entity** (Employment relationship) | 1 Worker có thể có nhiều Employment contracts (part-time, secondment) | Handle complex workforce: full-time + part-time + expat trong cùng 1 system |

#### `PR Module` — Payroll: Accuracy Engine

| Feature | Mô tả kỹ thuật | Giải quyết vấn đề gì |
|:---|:---|:---|
| **PayrollElement** typed | Phân loại earnings, deductions, contributions — chuẩn hóa toàn bộ | Không còn "tiền bốc không biết category" |
| **PayrollResult** per worker | Kết quả tính lương per payslip được lưu immutable | Audit trail đầy đủ, reconcile dễ dàng |
| **PayrollRun** states: draft → review → final | Validation trước khi finilaize — catch error trước khi chi tiền | Giảm payroll error rate từ 3.5% → <0.3% |

### Evidence: Trước vs. Sau xTalent

| Chỉ số | Trước xTalent | Sau xTalent |
|:---|:---:|:---:|
| People Cost Accuracy | ±14% | **<2%** |
| Thời gian báo cáo cost | 3–5 ngày | **Realtime** |
| Số nguồn dữ liệu chi phí | 6 hệ thống riêng biệt | **1 platform** |
| Coverage (% cost captured) | ~75% | **>98%** |

---

## CEO KPI #2: TURNOVER EARLY WARNING
### Yêu cầu: Dự báo ai sẽ nghỉ trong 90 ngày, accuracy >70%

---

### xTalent Giải Quyết Bằng Gì?

#### `CO Module` — Skills & Engagement Intelligence

| Feature | Mô tả kỹ thuật | Signal đóng góp vào dự báo |
|:---|:---|:---|
| **Worker profile** full lifecycle | Track toàn bộ lịch sử: ngày vào, promotions, salary changes, performance reviews | "Không được promote sau 2 năm" là signal #1 cho intent to leave |
| **CareerPath** entity | Định nghĩa career trajectory expected; track actual vs. expected | Gap giữa career expectation và thực tế = strong turnover signal |
| **TalentMarket + Opportunity** entities | Internal mobility marketplace — worker apply vào internal role | Không apply internal = signal passive disengagement |
| **Skill & Competency tracking** | Worker skills được track và update; skill gap visible | High-skill workers không được giao việc đúng level → high at-risk |

#### `TR Module` — Compensation Signals

| Feature | Mô tả kỹ thuật | Signal |
|:---|:---|:---|
| **Compensation history** | Lịch sử điều chỉnh lương — khi nào, tăng bao nhiêu | Không tăng lương 18+ tháng = high risk signal |
| **CompeRatio** calculation (trong Grade) | So sánh lương của worker vs. market midpoint cho grade đó | CompeRatio <80% = underpaid, rủi ro cao |
| **Recognition events** (Recognition sub-module) | Frequency của recognition — award, points, shoutouts | Declining recognition = declining engagement |

#### `TA Module` — Behavioral Signals

| Feature | Mô tả kỹ thuật | Signal |
|:---|:---|:---|
| **AttendanceRecord** với late/early patterns | Tracking chính xác patterns đến muộn/về sớm | Tăng đột ngột late arrivals = signal |
| **LeaveBalance** accumulation | Nhân viên không xài vacation days | "Leave paradox": accumulate leave = chuẩn bị nghỉ và lấy tiền leave |
| **TimeException** trends | Exception rate tăng = productivity declining | Declining productivity = leading indicator |
| **OvertimeRequest** patterns | Decline trong OT = declining commitment | OT history change = behavioral signal |

#### AI Analytics Layer

xTalent HR Intelligence Engine tổng hợp signals từ tất cả modules:

```
Turnover Risk Score = f(
    CareerPath_gap × 0.25
    + Compensation_ratio × 0.20
    + Attendance_patterns × 0.15
    + Leave_accumulation × 0.15
    + Recognition_frequency × 0.10
    + Time_since_promotion × 0.10
    + Internal_mobility_activity × 0.05
)
```

**Output:** Weekly at-risk list, sorted by risk score, với lý do cụ thể cho từng người.

### Evidence: Trước vs. Sau xTalent

| Chỉ số | Trước xTalent | Sau xTalent |
|:---|:---:|:---:|
| Turnover prediction accuracy | **0%** (reactive) | **>75%** trong 90 ngày |
| Time to detect flight risk | Biết khi nhận đơn nghỉ | **14–30 ngày** trước |
| Retention intervention possible? | Không | **Có** — với context đủ |
| Annual turnover cost avoided | VND 0 | **VND 40–60 tỷ** (DN 7.000) |

---

## CEO KPI #3: MULTI-ENTITY COMMAND CENTER
### Yêu cầu: Thấy toàn bộ tập đoàn realtime, drill-down trong 1 giây, entity isolation tuyệt đối

---

### xTalent Giải Quyết Bằng Gì?

#### `CO Module` — LegalEntity Architecture (Nguyên Tắc Nền Tảng)

Đây là điểm **khác biệt kiến trúc quan trọng nhất** của xTalent so với Odoo/hệ thống nội địa:

| Cách cũ (Odoo/customize) | Cách xTalent |
|:---|:---|
| `company_id` là property field (company_dependent) trên record | `LegalEntity` là **AGGREGATE_ROOT** — boundary cứng, hard-coded foreign key |
| User có thể nhìn thấy record từ entity khác khi session context sai | Data của entity A **không thể** xuất hiện trong query của entity B |
| Multi-company = shared schema + company filter | Multi-entity = **separate logical containers** với shared infrastructure |
| Data leakage risk khi user có multi-company access | **Zero leakage** — enforced tại database level, không phải application layer |

#### Key Entities cho Multi-Entity Management

| Entity | Role | CEO benefit |
|:---|:---|:---|
| **LegalEntity** (AGGREGATE_ROOT) | Container cho toàn bộ data của 1 pháp nhân — VN HQ, Cambodia sub, Thailand sub... | CEO click vào entity nào, thấy data entity đó — không bao giờ nhầm |
| **BusinessUnit** | Phân cấp bên trong entity (HQ → Vùng → Chi nhánh) | Drill-down từ tập đoàn → entity → business unit trong 1 click |
| **Worker Assignment** | 1 Worker có thể được assigned vào nhiều entities (secondment) | Expat và secondment được track xuyên entity trong 1 system |

#### Consolidated View: Cách Hoạt Động

```
CEO Dashboard (Consolidated View)
├── Total Headcount: 6,847  [Update: <1 giây]
│   ├── VN HQ: 4,200
│   ├── VN Manufacturing (Bình Dương): 1,800
│   ├── Cambodia: 520
│   └── Thailand: 327
├── Total People Cost: VND 87.3 tỷ/tháng
│   ├── [theo entity, realtime]
│   └── [theo business unit, realtime]
└── Turnover Risk Alerts: 23 at-risk (high)
    ├── Click → tên người, entity, department
    └── Click → xem full risk profile

→ Không cần chờ. Không cần gọi HR. Không cần email.
```

#### `PR Module` — Multi-Entity Payroll Consolidation

| Feature | Mô tả | Kết quả |
|:---|:---|:---|
| **PayrollRun per LegalEntity** | Mỗi entity có payroll cycle riêng, không ảnh hưởng nhau | Entity VN và entity Cambodia chạy payroll độc lập |
| **Consolidation layer** | System tổng hợp tự động across entities trong 1 dashboard | CFO xem consolidated payroll cost realtime — không export Excel |
| **Multi-currency PayrollResult** | Kết quả payroll theo currency của entity, tự convert theo rate | THB, KHR, VND được tổng hợp đúng |

### Evidence: Trước vs. Sau xTalent

| Chỉ số | Trước xTalent | Sau xTalent |
|:---|:---:|:---:|
| Cross-entity consolidation time | 3–7 ngày | **Realtime** |
| Entity data isolation | FAIL (Odoo property field) | **Pass 100%** (hard boundary) |
| Global headcount accuracy | 88–92% | **>99.5%** |
| CFO time saved | 5 ngày/tháng consolidate | **0 ngày** — auto |

---

## CEO KPI #4: COMPLIANCE ASSURANCE
### Yêu cầu: Luật thay đổi <7 ngày system cập nhật, audit sẵn sàng <4 giờ, BHXH rate >99.5%

---

### xTalent Giải Quyết Bằng Gì?

#### `PR Module` — Tax & Compliance Engine

| Feature | Mô tả kỹ thuật | Giải quyết vấn đề gì |
|:---|:---|:---|
| **TaxRule entity** — configurable | Tax rules là configuration, không phải hard code | Khi BHXH 2024 có hiệu lực 07/2025 → update config, không cần dev lại |
| **TaxJurisdiction** (trong TR Module) | Jurisdiction-aware calculation — mỗi nước có tax engine riêng | VN: 7 bậc thuế TNCN + giảm trừ gia cảnh; TH: Thai PIT; KH: Prakas |
| **Statutory deduction rules** | BHXH, BHYT, BHTN được tính theo formula tự cập nhật | Khi mức đóng BHXH tối đa tăng → cập nhật 1 param, toàn bộ payroll tự tính đúng |
| **Year-end tax processing** | Tự động generate quyết toán thuế cuối năm | Không còn tính tay quyết toán TNCN |
| **Retroactive adjustments** | Khi luật hồi tố, tính lại hàng loạt tự động | Không còn "retro-pay manual 100%" như hiện tại |

#### `CO + PR` — Audit Trail by Design

| Feature | Mô tả kỹ thuật | Giá trị |
|:---|:---|:---|
| **Full audit trail** trên mọi entity | Mọi thay đổi có who/what/when/why — immutable log | Ngay khi thanh tra: export report trong <4 giờ |
| **LeaveMovement** (TA) — immutable ledger | Mọi thay đổi leave balance là ledger entry, không thể xóa/sửa | Audit leave history đầy đủ |
| **PayrollResult** — immutable per run | Mỗi payroll run được locked sau close — không thể sửa retroactively | Audit payroll từng kỳ, từng người, chính xác 100% |
| **Compliance reports** (PR Reporting) | Standard reports: BHXH declaration, PIT declaration, labor report | Export trực tiếp đúng format cơ quan nhà nước |

#### `TR Module` — PDPD Compliance (Nghị định 13/2023)

| Feature | Mô tả | PDPD relevance |
|:---|:---|:---|
| **LegalEntity isolation** (từ CO) | PII của entity A không bao giờ accessible từ entity B | Data sovereignty cho từng pháp nhân |
| **Security specification hoàn chỉnh** | TR module có toàn bộ security spec: encryption, access control, data retention | Đáp ứng Điều 46-54 Nghị định 13/2023 |
| **Role-based access**: HR_ADMIN / HR_MANAGER / SELF | 3 tầng access — SELF chỉ thấy data của mình | Nhân viên không thể xem lương của đồng nghiệp |
| **Data classification: PII_SENSITIVE** | Tất cả worker data được mark PII, auto-encrypt | Mã hóa at rest và in transit |

#### Compliance Update Lifecycle trong xTalent

```
Ngày N: Chính phủ ban hành Nghị định/Thông tư mới
    ↓
Ngày N+1: xTalent Legal Compliance Team phân tích
    ↓
Ngày N+3: Configuration update chuẩn bị (TaxRule, DeductionRule)
    ↓
Ngày N+5: Testing trên staging với dữ liệu thực
    ↓
Ngày N+7: Production deployment — tự động áp dụng cho TẤT CẢ khách hàng
    ↓
Khách hàng: Không làm gì — system đã đúng.
```

**So với baseline VN:** 30–90 ngày (dev lại từ đầu) → **<7 ngày** (config update)

### Evidence: Trước vs. Sau xTalent

| Chỉ số | Trước xTalent | Sau xTalent |
|:---|:---:|:---:|
| Law update lag | 30–90 ngày | **<7 ngày** |
| BHXH compliance rate | 85–95% | **>99.5%** |
| Audit readiness time | 3–10 ngày | **<4 giờ** |
| Compliance penalty exposure | VND 3–10 tỷ | **<VND 500 triệu** |
| PDPD data isolation | Fail | **Pass** |

---

## CEO KPI #5: GROWTH-READY SCALABILITY
### Yêu cầu: Payroll 7.000 người <2 giờ; thêm entity mới <30 ngày; M&A integration <60 ngày

---

### xTalent Giải Quyết Bằng Gì?

#### Kiến Trúc Cloud-Native

Khác với Odoo Community (monolithic, single-threaded payroll) hay hệ thống nội địa (on-prem, limited scale), xTalent được thiết kế cloud-native từ đầu:

| Kiến trúc | Mô tả | Scale impact |
|:---|:---|:---|
| **Event-driven payroll** | PayrollRun được xử lý parallel — không phải sequential batch | 5.000 payslips xử lý song song, không phải lần lượt |
| **Domain-driven design** với AGGREGATE_ROOT | Mỗi domain object (Worker, Employee, PayrollRun) có lifecycle độc lập | Thêm 1.000 workers mới không ảnh hưởng performance của payroll |
| **Microservice-ready** ontology | 4 modules (CO/TR/TA/PR) có thể deploy và scale độc lập | Nếu payroll mùa cuối năm cần scale, chỉ scale PR cluster |
| **API-first** | Mọi integration đều qua API contract định nghĩa sẵn | Thêm new country = add new TaxJurisdiction config + country-specific localization |

#### `CO Module` — Instant Entity Provisioning

| Feature | Mô tả | Giá trị với M&A |
|:---|:---|:---|
| **LegalEntity** là config, không phải code | Tạo entity mới = điền form (tên, jurisdiction, currency, structure) | Thêm công ty con mua lại: **<1 ngày setup**, không cần dev |
| **BusinessUnit** hierarchy configurable | Copy org structure từ existing entity và customize | Migrate organizational chart: 1–2 ngày |
| **Worker import** từ CSV/API | Bulk onboard workers từ file hoặc legacy system API | 800 workers migrate: **<8 giờ** automated |

#### `TR Module` — Multi-Country Compensation Ready

| Feature | Mô tả | Scale benefit |
|:---|:---|:---|
| **Multi-country Compensation** (sub-module 10) | Compensation structure per jurisdiction — tự động differentiate | Mở Thailand: configure THB compensation plan, không build từ đầu |
| **Tax Withholding per Jurisdiction** | TaxRule per country, isolate logic | New country = new TaxRule config, không affect existing |
| **Benefit Plan** per country | Healthcare, retirement khác nhau per country | VN: BHYT; TH: Social Security; KH: NSSF — tất cả trong 1 system |

#### `PR Module` — Enterprise-grade Processing

| Feature | Mô tả | Performance |
|:---|:---|:---|
| **PayrollRun** với parallel execution | Architecture hỗ trợ concurrent payroll calculation | 7.000 payslips: **<2 giờ** (vs. 48–120h hiện tại) |
| **Draft → Review → Final** workflow | Review stage catch errors before final — không crash toàn batch khi 1 lỗi | Error isolation: 1 error = 1 payslip issue, không phải toàn batch |
| **Retroactive adjustment** engine | Computed automatically when law changes or salary history corrected | M&A integration: tính đúng cho toàn bộ history của workers acquired |

#### M&A Integration Scenario: Step by Step

```
T+0: Ký hợp đồng mua công ty ABC (800 nhân sự, Thailand)

T+1: Tạo LegalEntity "ABC Thailand" trong xTalent
     ↓ 30 phút

T+2: Configure TaxRule cho Thailand jurisdiction
     ↓ 4 giờ

T+3: Import workers từ ABC's legacy system via CSV/API
     ↓ 8 giờ (800 workers)

T+5-15: Configure compensation plans, benefits, leave policies
         theo Thailand labor law
     ↓ 10 ngày

T+16-30: Parallel payroll run (xTalent + legacy) để validate
     ↓ 14 ngày

T+31: Full cutover — ABC Thailand fully on xTalent

Total: 31 ngày (vs. 6–18 tháng với hệ thống legacy)
```

### Evidence: Trước vs. Sau xTalent

| Chỉ số | Trước xTalent | Sau xTalent |
|:---|:---:|:---:|
| Payroll 7.000 người | 48–120 giờ | **<2 giờ** |
| New entity setup | 3–6 tháng | **<30 ngày** |
| New country onboard | Không làm được | **<90 ngày** |
| M&A HR integration | 6–18 tháng | **<60 ngày** |
| Payroll batch error (1 lỗi = crash toàn batch?) | Có (Odoo-style) | **Không — error isolation** |

---

## Tổng Hợp: xTalent Capability Matrix vs. 5 CEO KPIs

| CEO KPI | Chỉ số đo | Baseline thị trường | xTalent Target | Module chứng minh |
|:---|:---|:---:|:---:|:---|
| **KPI #1** People Cost Visibility | Sai số chi phí nhân sự | ±14% | **<2%** | TR + CO + PR |
| | Thời gian báo cáo | 3–5 ngày | **Realtime** | TR Dashboard |
| **KPI #2** Turnover Early Warning | Prediction accuracy | 0% | **>75%** | CO + TR + TA |
| | Time to detect | Khi nhận đơn nghỉ | **14–30 ngày trước** | AI Analytics |
| **KPI #3** Multi-Entity Command | Consolidation time | 3–7 ngày | **Realtime** | CO LegalEntity |
| | Data isolation | FAIL (Odoo) | **100% Pass** | CO Architecture |
| **KPI #4** Compliance Assurance | Law update lag | 30–90 ngày | **<7 ngày** | PR TaxRule |
| | BHXH compliance | 85–95% | **>99.5%** | PR Engine |
| | Audit readiness | 3–10 ngày | **<4 giờ** | Audit Trail |
| **KPI #5** Growth-Ready Scale | Payroll 7.000 người | 48–120 giờ | **<2 giờ** | PR Parallel |
| | New entity setup | 3–6 tháng | **<30 ngày** | CO Config |
| | M&A integration | 6–18 tháng | **<60 ngày** | Full platform |

---

## Điều Kiện Chứng Minh: Reference từ Khách Hàng Thực Tế

Bộ Capability Matrix này là **claim** — cần được chứng minh bởi:

1. **Reference customers** tại quy mô tương đương (2.000–10.000 nhân sự VN/SEA) có thể xác nhận từng metric
2. **Pilot/POC** với dữ liệu thực của khách hàng — chạy payroll parallel trong 1–3 tháng để verify
3. **SLA contractual commitment** — ký cam kết về từng metric có penalty nếu không đạt
4. **Architecture review** với IT team của khách hàng — verify LegalEntity isolation và data model

> *Capability Matrix không thay thế việc chứng minh bằng demo thực tế và reference customer. Đây là framework để cấu trúc cuộc đối thoại với CEO và technical team.*

---

*R11 là tài liệu thứ 11 trong bộ nghiên cứu xTalent Product. Dùng kết hợp với R10 (5 CEO KPIs) khi pitch và demo. Partner với R07 (benchmark vs. Odoo/Workday/SAP) để positioning hoàn chỉnh.*
