# Total Rewards — Tài liệu Yêu cầu Nghiệp vụ (BRD)

> **Module**: Total Rewards (TR)
> **Giải pháp**: xTalent — HCM
> **Phiên bản**: 1.0.0
> **Ngày**: 2026-03-26
> **Tác giả**: Business Analyst Agent (ODSA Step 2)
> **Trạng thái**: DRAFT — Chờ Gate G2 Review
> **Ambiguity Score**: 0.12 (đã giải quyết tất cả P0/P1 hot spots)

---

## 1. Tóm tắt điều hành (Executive Summary)

Các doanh nghiệp đa quốc gia tại Đông Nam Á đang quản lý đãi ngộ nhân viên qua các hệ thống rời rạc: HRIS cũ, Excel, email — không có cái nhìn tổng thể. Chu kỳ merit review kéo dài 6–8 tuần, tỷ lệ lỗi tính lương 10–15%, rủi ro tuân thủ cao tại 6 quốc gia, và nhân viên không biết tổng giá trị đãi ngộ thực — dẫn đến 25–30% voluntary turnover liên quan đến lương.

**xTalent Total Rewards** là module HCM tổng hợp, tích hợp 11 sub-module trên một nền tảng duy nhất, thay thế Excel và quy trình thủ công bằng automation, real-time visibility và compliance tự động cho 6 quốc gia SEA (VN, TH, ID, SG, MY, PH).

**Meta-principle nền tảng**: xTalent TR là một **platform**, không phải single-customer solution. Mọi calculation, workflow, và validation phải được hỗ trợ qua configuration/plugin/engine — không được hardcode. Đây là quyết định kiến trúc không thể thỏa hiệp.

**Phạm vi Phase 1**: Vietnam-first với đầy đủ 11 sub-module, sau đó mở rộng 5 quốc gia SEA còn lại.

**Drivers thời điểm**:
- Vietnam SI Law 2024 (hiệu lực 7/2025) — phạt VND 50–100M/vụ nếu không tuân thủ
- Mở rộng khu vực SEA (Q2 2026)
- Chuẩn bị IPO (2027) — audit-ready records bắt buộc

---

## 2. Mục tiêu nghiệp vụ (Business Objectives — SMART)

### OBJ-01: Giảm thời gian merit review cycle

- **Cụ thể**: Rút ngắn thời gian merit review từ 6–8 tuần xuống còn ≤ 2 tuần
- **Đo lường**: Thời gian từ khi mở cycle đến khi publish kết quả
- **Có thể đạt được**: Tự động hóa approval workflow, loại bỏ offline Excel
- **Liên quan**: OKR giữ chân nhân tài, cạnh tranh với Workday
- **Thời hạn**: Pilot với enterprise customer đầu tiên Q3 2026

### OBJ-02: Giảm tỷ lệ lỗi tính lương

- **Cụ thể**: Giảm tỷ lệ lỗi payroll từ 10–15% xuống < 0.5%
- **Đo lường**: Số paycheck bị sai / tổng paycheck mỗi chu kỳ
- **Có thể đạt được**: Calculation engine tự động, audit trail 100%
- **Liên quan**: Tin tưởng của nhân viên, tuân thủ pháp luật
- **Thời hạn**: Sau 3 chu kỳ payroll đầu tiên với production data

### OBJ-03: Đảm bảo tuân thủ pháp luật 6 quốc gia SEA

- **Cụ thể**: Zero compliance violation tại Vietnam (SI Law 2024) từ go-live
- **Đo lường**: Số lần bị cơ quan nhà nước phạt / kiểm tra
- **Có thể đạt được**: Pluggable statutory calculation engine per country
- **Liên quan**: Risk management, IPO readiness
- **Thời hạn**: Vietnam go-live trước 7/2025; 5 nước còn lại Q2 2026

### OBJ-04: Tăng tỷ lệ nhân viên hiểu giá trị đãi ngộ toàn diện

- **Cụ thể**: 80%+ nhân viên xem Total Rewards Statement ít nhất 1 lần/năm
- **Đo lường**: Tỷ lệ mở statement (email + portal analytics)
- **Có thể đạt được**: Multi-channel delivery, mobile-friendly, PDF branding
- **Liên quan**: Giảm voluntary turnover liên quan đến lương từ 25–30% xuống ≤ 15%
- **Thời hạn**: Năm 1 sau go-live

### OBJ-05: Đạt 50% adoption AI recommendation trong compensation

- **Cụ thể**: 50% HR Admin sử dụng AI salary recommendation trong ít nhất 1 cycle
- **Đo lường**: % offer/salary change có AI recommendation được xem xét
- **Có thể đạt được**: Phase 2 — sau khi đủ historical data (≥ 12 tháng)
- **Liên quan**: Cạnh tranh với Workday AI features
- **Thời hạn**: Q2 2027 (Phase 2)

---

## 3. Actor và Ma trận phân quyền

### 3.1 Danh sách Actor (sử dụng xTalent naming)

| Actor | Vai trò trong TR | Sub-module chính |
|-------|-----------------|------------------|
| **HR Administrator** | Quản trị toàn bộ hệ thống TR, hỗ trợ compliance | Tất cả |
| **Compensation Manager** | Thiết kế pay plan, phân tích equity, quản lý ngân sách cycle | Core Comp, Variable Pay |
| **Compensation Administrator** | Cấu trúc lương, vận hành chu kỳ, eligibility | Core Comp, Variable Pay |
| **Benefits Administrator** | Quản lý enrollment, carrier liaison, compliance | Benefits, TR Statement |
| **Payroll Administrator** | Thực thi payroll, reconciliation, deductions | Calculation, Tax, Deductions |
| **Tax Administrator** | Cấu hình thuế, nộp hồ sơ, compliance | Tax Withholding, Taxable Bridge |
| **Recognition Administrator** | Cấu hình chương trình, quản lý catalog phần thưởng | Recognition |
| **People Manager** | Đề xuất thay đổi lương, ghi nhận team, approve bonus | Core Comp, Variable Pay, Recognition |
| **Budget Approver** | Phê duyệt phân bổ ngân sách theo ngưỡng | Core Comp, Variable Pay |
| **Worker (Self-Service)** | Xem dữ liệu cá nhân, enroll benefits, redeem points | Tất cả |
| **Compliance Officer** | Báo cáo compliance, ứng phó kiểm toán | Audit, Tax, Benefits |
| **External Auditor** | Đọc audit log (read-only), review compliance | Audit |
| **Hiring Manager** | Tạo offer, phê duyệt compensation cho candidate | Offer Management |
| **Candidate** | Nhận, chấp nhận, hoặc từ chối offer | Offer Management |
| **Sales Operations** | Thiết lập commission plan, import sales data | Variable Pay (Commission) |
| **Finance Approver** | Phê duyệt ngân sách, garnishment, high-value awards | Core Comp, Benefits, Deductions |
| **System (Automated)** | Validation, notification, milestone detection, bridging | Tất cả |

> **Lưu ý xTalent naming**: "Worker" thay cho "Employee"; "Working Relationship" thay cho employment contract.

### 3.2 Ma trận phân quyền theo sub-module

| Actor | Core Comp | Calc Rules | Variable Pay | Benefits | Recognition | Offer Mgmt | TR Statement | Deductions | Tax | Taxable Bridge | Audit |
|-------|-----------|------------|-------------|---------|-------------|------------|-------------|------------|-----|----------------|-------|
| HR Administrator | CRUD | CRUD | CRUD | CRUD | CRUD | CRUD | R+Generate | CRUD | CRUD | R | Read |
| Compensation Manager | CRUD | Read | CRUD | Read | Read | Approve | Read | Read | Read | Read | Read |
| Compensation Administrator | CRUD | Read | CRUD | Read | — | Read | Read | Read | Read | Read | Read |
| Benefits Administrator | Read | Read | Read | CRUD | Read | Read | Read | Read | Read | Read | Read |
| Payroll Administrator | Read | CRUD | Read | Read | — | — | — | CRUD | CRUD | Read | Read |
| Tax Administrator | Read | CRUD | Read | Read | — | — | — | Read | CRUD | CRUD | Read |
| People Manager | Propose | — | Approve | — | CRUD | Create | — | — | — | — | — |
| Budget Approver | Approve | — | Approve | — | — | Approve | — | — | — | — | — |
| Worker (Self-Service) | View own | — | View own | Enroll | Send/View | View offer | View own | View own | Update profile | — | — |
| Compliance Officer | Read | Read | Read | Read | Read | Read | Read | Read | Read | Read | Read |
| External Auditor | — | — | — | — | — | — | — | — | — | — | Read-only |
| Finance Approver | Approve | — | Approve | — | Approve | Approve | — | Approve | — | — | Read |
| Hiring Manager | Read | — | — | — | — | Create/Submit | — | — | — | — | — |
| Sales Operations | — | — | Commission CRUD | — | — | — | — | — | — | — | Read |
| System (Automated) | Validate/Update | Execute | Calculate | Verify/Sync | Notify/Expire | Generate | Generate | Process | Calculate/File | Bridge | Capture |

---

## 4. Yêu cầu chức năng (Functional Requirements)

### 4.1 Core Compensation (P0)

**Mục tiêu**: Quản lý toàn bộ vòng đời lương cơ bản — từ cấu trúc đến chu kỳ điều chỉnh.

| ID | Yêu cầu | Mức độ | Ghi chú |
|----|---------|--------|---------|
| FR-CC-001 | Quản lý Salary Basis (HOURLY, MONTHLY, ANNUAL) với Pay Components tái sử dụng được trên nhiều Working Relationship | P0 | — |
| FR-CC-002 | Quản lý Grade với SCD Type 2 — mọi thay đổi tạo version mới, không mất lịch sử thăng tiến | P0 | effective_start_date / effective_end_date |
| FR-CC-003 | Pay Range đa cấp (Global → Legal Entity → Business Unit → Position) — áp dụng cấp cụ thể nhất (most-specific wins) | P0 | — |
| FR-CC-004 | Compensation Cycle (Merit, Promotion, Market Adjustment, New Hire, Equity Correction) với budget tracking real-time | P0 | Budget remaining cập nhật khi proposal submit |
| FR-CC-005 | Approval workflow tự động theo ngưỡng tăng lương: configurable per enterprise (default: <5% auto, 5–10% Director, >10% VP) | P0 | Template mặc định, enterprise có thể override |
| FR-CC-006 | Compa-Ratio tracking (ActualSalary / MidpointSalary) và pay equity analytics với configurable visibility | P1 | Default: anonymous distribution chart |
| FR-CC-007 | Validation minimum wage theo 4 vùng lương Vietnam; vùng = workplace location của Working Relationship | P0 | Hard block + configurable exception workflow |
| FR-CC-008 | Multi-country scoping qua Config Scope (Phase 1: inline country_code; Phase 2: config_scope_id migration) | P0 | Inheritance: Country → LE → BU |

### 4.2 Calculation Rules Engine (P0)

**Mục tiêu**: Engine tính toán pluggable, versioned, hỗ trợ mọi quy tắc quốc gia.

| ID | Yêu cầu | Mức độ | Ghi chú |
|----|---------|--------|---------|
| FR-CR-001 | Engine tính Social Insurance Vietnam: BHXH (employer 17.5%, employee 8%), BHYT (3%/1.5%), BHTN (1%/1%), cap = 20× lương tối thiểu vùng | P0 | Pluggable — HR SME cấu hình, không hardcode |
| FR-CR-002 | Proration tự động: hỗ trợ calendar days, working days, 30-day fixed — configurable per component per country/LE | P0 | Công thức: ActualDays / TotalDays |
| FR-CR-003 | Versioning calculation rule — lưu lịch sử toàn bộ công thức, đảm bảo tính đúng kỳ lịch sử khi rule thay đổi | P0 | Effective-date versioning |
| FR-CR-004 | Framework mở rộng cho country-specific rules: VN SI, TH SSF, SG CPF, MY EPF, ID BPJS, PH SSS/PhilHealth/Pag-IBIG | P0 | Plugin pattern per country |
| FR-CR-005 | FX Rate Engine: configurable nguồn (OANDA, Reuters, manual), daily update, workflow xử lý biến động >5% | P0 | Provider-agnostic |

### 4.3 Variable Pay (P0)

**Mục tiêu**: Quản lý toàn bộ phần thưởng biến động — bonus, hoa hồng, equity.

| ID | Yêu cầu | Mức độ | Ghi chú |
|----|---------|--------|---------|
| FR-VP-001 | Bonus engine: formula configurable `Bonus = BaseSalary × Target% × PerformanceMultiplier × CompanyMultiplier` | P0 | JSON formula engine |
| FR-VP-002 | 13th month / THR / PD 851: implement như selectable plugin per enterprise. VN: configurable; PH: PD 851 mandatory formula | P0 | Không hardcode quốc gia |
| FR-VP-003 | Commission: tiered rates, accelerator khi vượt quota, quota tracking, monthly cycle | P0 | Real-time dashboard < 5 giây (Phase 2: Kafka) |
| FR-VP-004 | Equity (RSU/Stock Options/ESPP): vesting schedule tự động, tax event khi vest, bridge sang Taxable Bridge | P1 | — |
| FR-VP-005 | Budget pool management với real-time remaining balance | P0 | Cập nhật mỗi proposal submit |
| FR-VP-006 | Commission dispute workflow: default = freeze partial (chỉ đóng băng phần tranh chấp), configurable per enterprise | P0 | ✅ Confirmed default |

### 4.4 Benefits Administration (P0)

**Mục tiêu**: Quản lý toàn bộ phúc lợi từ cấu hình đến enrollment và carrier sync.

| ID | Yêu cầu | Mức độ | Ghi chú |
|----|---------|--------|---------|
| FR-BA-001 | Eligibility Engine với EligibilityProfile tái sử dụng cho nhiều plan | P0 | — |
| FR-BA-002 | 3 loại enrollment period: Open Enrollment (annual), New Hire (30 ngày), Qualifying Life Event (QLE: kết hôn, sinh con, v.v.) | P0 | — |
| FR-BA-003 | 8 loại benefit plan: Medical, Dental, Vision, Life, Disability, Retirement, Wellness, Perk | P0 | — |
| FR-BA-004 | EDI 834 carrier integration — tự động sync enrollment với carrier | P0 | Dual confirm: webhook + 15-min polling fallback |
| FR-BA-005 | Self-service enrollment portal cho Worker | P0 | Mobile-friendly |
| FR-BA-006 | Dependent verification workflow với document upload | P1 | Configurable: auto/document/carrier verify |
| FR-BA-007 | Flex credit allocation (Worker phân bổ credit cho benefit khác nhau) | P2 | Architecture planning Phase 1, delivery Phase 2 |

### 4.5 Recognition Programs (P1)

**Mục tiêu**: Tăng engagement và văn hóa ghi nhận thông qua hệ thống điểm thưởng.

| ID | Yêu cầu | Mức độ | Ghi chú |
|----|---------|--------|---------|
| FR-REC-001 | Point-based recognition với FIFO expiration 12 tháng (điểm vào trước hết hạn trước) | P1 | — |
| FR-REC-002 | Peer-to-peer recognition và manager awards với giới hạn giving/tháng | P1 | — |
| FR-REC-003 | Social recognition feed (public posts) với content moderation configurable (auto/hybrid/human) | P1 | ⭐ USP |
| FR-REC-004 | Perks catalog (gift cards, experiences, merchandise) với redeem tracking | P1 | — |
| FR-REC-005 | Perk có giá trị tiền tệ → tự động tạo Taxable Item sang Payroll | P1 | Kết nối Taxable Bridge |
| FR-REC-006 | AI recognition suggestion (gợi ý thời điểm và nội dung ghi nhận) | P2 | Cần historical data ≥ 12 tháng |

### 4.6 Offer Management (P1)

**Mục tiêu**: Chuẩn hóa và tự động hóa quy trình tạo và gửi offer cho candidate.

| ID | Yêu cầu | Mức độ | Ghi chú |
|----|---------|--------|---------|
| FR-OM-001 | Offer templates linh hoạt với merge fields từ CO module (Worker, Working Relationship data) | P1 | — |
| FR-OM-002 | Approval workflow cho offer trước khi gửi candidate | P1 | Configurable threshold |
| FR-OM-003 | E-signature integration (multi-provider: DocuSign, HelloSign, v.v.) | P1 | Dual confirm: webhook + 15-min polling |
| FR-OM-004 | Counter-offer workflow: candidate đề xuất điều chỉnh, HR phản hồi | P1 | — |
| FR-OM-005 | Offer competitiveness scoring (AI đánh giá cạnh tranh so thị trường) | P2 | ⭐ USP |
| FR-OM-006 | Offer analytics: acceptance rate, time-to-accept, decline reasons | P1 | — |

### 4.7 Total Rewards Statement (P1)

**Mục tiêu**: Cung cấp bức tranh toàn diện về giá trị đãi ngộ để tăng retention.

| ID | Yêu cầu | Mức độ | Ghi chú |
|----|---------|--------|---------|
| FR-TRS-001 | Statement on-demand + annual auto-generate, tổng hợp: lương + bonus + equity + benefits + recognition | P1 | On-demand + annual auto |
| FR-TRS-002 | Xuất PDF với enterprise branding (logo, màu sắc, template) | P1 | < 5 giây/statement |
| FR-TRS-003 | Multi-channel delivery: email, self-service portal, mobile notification | P1 | — |
| FR-TRS-004 | Archival 7 năm với versioning (không thể xóa) | P1 | Immutable storage |
| FR-TRS-005 | Tax optimization recommendation trên statement (AI, opt-in) | P2 | ⭐ USP |

### 4.8 Deductions (P0)

**Mục tiêu**: Quản lý tự động các khoản khấu trừ theo đúng thứ tự ưu tiên.

| ID | Yêu cầu | Mức độ | Ghi chú |
|----|---------|--------|---------|
| FR-DED-001 | Quản lý deduction types: loan (vay lương), garnishment (lệnh tòa), salary advance, voluntary | P0 | — |
| FR-DED-002 | Voluntary deductions tự khai báo (Worker self-service): đóng góp phúc lợi tự nguyện | P0 | — |
| FR-DED-003 | Lịch khấu trừ tự động theo payroll cycle | P0 | — |
| FR-DED-004 | Priority ordering khi nhiều deductions cùng kỳ (configurable per enterprise) | P0 | — |

### 4.9 Tax Withholding (P0)

**Mục tiêu**: Tự động tính và khai báo thuế thu nhập cá nhân đa quốc gia.

| ID | Yêu cầu | Mức độ | Ghi chú |
|----|---------|--------|---------|
| FR-TAX-001 | Cấu hình tax bracket theo quốc gia với effective dating (SCD Type 2) | P0 | Không hardcode |
| FR-TAX-002 | Worker self-service: khai báo tax profile (số người phụ thuộc, giảm trừ) | P0 | — |
| FR-TAX-003 | e-Filing tích hợp Tax Authority APIs với dual-path: API + file export song song | P0 | Không sequential fallback |
| FR-TAX-004 | SLA Tax API: alert 15 phút → escalate 1 giờ → switch to file fallback 2 giờ | P0 | ✅ Confirmed SLA |
| FR-TAX-005 | AI tax optimization recommendation (opt-in, explicit consent) | P2 | Tránh rủi ro regulatory "financial advice" |

### 4.10 Taxable Bridge (P0)

**Mục tiêu**: Đảm bảo mọi sự kiện có giá trị chịu thuế được capture và chuyển đúng sang Payroll.

| ID | Yêu cầu | Mức độ | Ghi chú |
|----|---------|--------|---------|
| FR-TXB-001 | Tự động tạo Taxable Item từ: equity vest, perk redemption, benefit in-kind, spot bonus | P0 | Zero-miss requirement |
| FR-TXB-002 | Bridge sang Payroll module đúng kỳ — idempotency key + dedup window + at-least-once delivery | P0 | ✅ Confirmed pattern |
| FR-TXB-003 | Compliance reporting cho từng loại taxable item (per country, per type) | P0 | — |

### 4.11 Audit (P0)

**Mục tiêu**: Đảm bảo tính minh bạch, truy xuất nguồn gốc và sẵn sàng kiểm toán.

| ID | Yêu cầu | Mức độ | Ghi chú |
|----|---------|--------|---------|
| FR-AUD-001 | 100% capture mọi thay đổi TR entity với before/after values, actor, timestamp | P0 | Zero-miss requirement |
| FR-AUD-002 | Audit records immutable — không ai có thể modify hoặc delete, kể cả System Admin | P0 | ✅ Hard rule |
| FR-AUD-003 | 7-year data retention tối thiểu; indefinite cho executive compensation và equity | P0 | — |
| FR-AUD-004 | Compliance report generation on-demand | P0 | — |
| FR-AUD-005 | Anomaly detection tự động (phát hiện thay đổi lương bất thường, unauthorized access) | P1 | — |
| FR-AUD-006 | External auditor read-only access — scoped per Legal Entity, không cross-LE | P0 | — |

---

## 5. Yêu cầu phi chức năng (Non-Functional Requirements)

### 5.1 Hiệu năng (Performance)

| Metric | Target | Ghi chú |
|--------|--------|---------|
| Compensation cycle processing (15K workers) | < 2 giờ | Batch mode |
| Commission dashboard latency | < 5 giây | Near real-time, Kafka streaming |
| TR Statement PDF generation | < 5 giây/statement | On-demand |
| Payroll bridge delay tối đa | 15 phút | Sau đó escalate alert |
| Tax Authority API SLA | Alert 15min → Escalate 1h → Fallback 2h | Dual-path không sequential |

### 5.2 Độ chính xác (Accuracy)

| Metric | Target |
|--------|--------|
| Payroll calculation error rate | < 0.5% |
| Commission accuracy | ≥ 99.5% (dispute rate < 0.5%) |
| SI contribution calculation | 100% accurate vs statutory rule |

### 5.3 Khả dụng (Availability)

| Service | Target |
|---------|--------|
| Core calculation services | 99.9% uptime |
| Self-service portal (Worker) | 99.5% uptime |
| Tax e-Filing APIs | Dual-path (không single point of failure) |

### 5.4 Khả năng mở rộng (Scalability)

| Dimension | Phase 1 | Scale Target |
|-----------|---------|-------------|
| Workers | 15,000 | 100,000+ |
| Countries | 1 (VN) → 6 (SEA) | Unlimited via Config Scope |
| Concurrent users | 500 | 5,000+ |

### 5.5 Bảo mật & Quyền riêng tư (Security & Privacy)

| Requirement | Specification |
|-------------|---------------|
| PII encryption | At-rest AES-256 + in-transit TLS 1.3 |
| Access logging | 100% access to sensitive data (salary, tax ID, PII) |
| Data residency | PII local per country, KHÔNG cross-border; aggregated analytics = central |
| PDPA compliance | Singapore, Malaysia (PDP Indonesia) |
| Vietnam PDP | Luật An ninh mạng 2018 + NĐ 13/2023 |

### 5.6 Tích hợp (Integration)

| Integration Point | Pattern | Fallback |
|-------------------|---------|---------|
| TR → Payroll | Hybrid: Kafka events + daily batch reconciliation | Batch-only mode |
| Tax Authority APIs | Dual-path: API + file export song song | File export luôn sẵn sàng |
| Benefits Carriers (EDI 834) | Webhook primary + 15-min polling fallback | Manual trigger |
| E-Signature Providers | Multi-provider, webhook + polling fallback | — |
| FX Rate Providers | Configurable (OANDA/Reuters/manual) | Manual override |

---

## 6. Business Rules

### 6.1 Compliance Rules (Statutory — Confirmed)

> **Nguyên tắc platform**: Tất cả statutory rates được implement như **configurable parameters** — HR SME cấu hình qua admin UI. Bảng dưới là dữ liệu mẫu seed khi go-live.

| ID | Rule | Quốc gia | Trạng thái |
|----|------|----------|------------|
| BR-C01 | BHXH: employer 17.5%, employee 8%; BHYT: employer 3%, employee 1.5%; BHTN: employer 1%, employee 1% | VN | ✅ Confirmed (SI Law 2024) |
| BR-C02 | Minimum wage 4 vùng: Vùng 1 = 4.68M, Vùng 2 = 4.16M, Vùng 3 = 3.64M, Vùng 4 = 3.25M (VND/tháng) | VN | ✅ Confirmed (NĐ 74/2024) |
| BR-C03 | Cap SI = 20× lương tối thiểu vùng; vùng = **workplace location** của Working Relationship (không phải địa chỉ thường trú) | VN | ✅ Hard Rule |
| BR-C04 | Khi Worker chuyển vùng: SI cap mới áp dụng từ **tháng tiếp theo** sau effective date của Working Relationship change | VN | ✅ Hard Rule |
| BR-C05 | Minimum wage violation → configurable workflow: Block / Warning + exception approval / Warning only — default = Block | VN + All | ✅ Confirmed |
| BR-C06 | 13th month / THR / PD 851 → selectable plugin per enterprise. Vietnam: configurable. Philippines: PD 851 mandatory | VN, PH, ID | ✅ Confirmed |
| BR-C07 | CPF: employee max 20%, employer 17% (cap tại monthly wage SGD 6,000) | SG | Configurable |
| BR-C08 | EPF: employee 11%, employer 13% (income ≤ MYR 5K) hoặc 12% (>MYR 5K) | MY | Configurable |
| BR-C09 | BPJS Ketenagakerjaan: JKK 0.24–1.74%, JKM 0.3%, JHT 3.7%+2%, JP 2%+1% | ID | Configurable |
| BR-C10 | Thailand SSF: 5%, capped THB 750/tháng | TH | Configurable |
| BR-C11 | Philippines: SSS + PhilHealth + Pag-IBIG theo tier | PH | Configurable |

### 6.2 Authorization Rules (Phân quyền)

> **Nguyên tắc platform**: Authorization được implement qua **configurable workflow engine** — enterprise tự định nghĩa threshold, approver role, và escalation path.

| ID | Rule | Loại |
|----|------|------|
| BR-A01 | Tăng lương < 5%: auto-approve (default, configurable threshold) | Template default |
| BR-A02 | Tăng lương 5–10%: cần Director approval (default, configurable) | Template default |
| BR-A03 | Tăng lương > 10%: cần VP approval (default, configurable) | Template default |
| BR-A04 | Salary change ngoài pay range: exception approval bổ sung (configurable) | Template default |
| BR-A05 | Offer vượt ngưỡng ngân sách: Finance Approver (configurable threshold) | Template default |
| BR-A06 | Audit records: không ai được modify hoặc delete — kể cả System Admin | ✅ Hard Rule |
| BR-A07 | Bonus budget reallocation: configurable (locked / self-service / approval) | Configurable |
| BR-A08 | Commission dispute: default = freeze partial (chỉ phần tranh chấp), trả phần không tranh chấp | ✅ Confirmed default |
| BR-A09 | Compa-ratio visibility cho manager: default = anonymous distribution chart, configurable per enterprise | ✅ Confirmed default |

### 6.3 Data Rules (Dữ liệu)

| ID | Rule |
|----|------|
| BR-D01 | SCD Type 2 bắt buộc cho: Grade, Pay Range, Tax Bracket — mọi thay đổi tạo version mới, không xóa |
| BR-D02 | Mọi compensation change phải có audit record: actor, timestamp, before_value, after_value, reason |
| BR-D03 | Retention tối thiểu 7 năm cho mọi TR audit record; executive comp và equity = indefinite |
| BR-D04 | PII (salary, tax ID, CMND/CCCD) phải encrypted at-rest và in-transit |
| BR-D05 | Integration data phải validated trước khi xử lý (schema validation + contract enforcement) |
| BR-D06 | PII không được cross-border; chỉ aggregated, anonymized metrics được phép cross-border |
| BR-D07 | Idempotency: mọi event sang Payroll phải có idempotency key + dedup window |

### 6.4 Calculation Rules (Tính toán)

| ID | Rule |
|----|------|
| BR-K01 | Proration = ActualDays / TotalDays trong kỳ (calendar hoặc working days theo config của component) |
| BR-K02 | Bonus = BaseSalary × Target% × PerformanceMultiplier × CompanyMultiplier (formula_json configurable) |
| BR-K03 | Commission = SUM(Tier × Rate) với accelerator khi vượt quota, theo monthly cycle |
| BR-K04 | Compa-Ratio = ActualSalary / MidpointSalary (midpoint của pay range grade hiện tại) |
| BR-K05 | FIFO point expiration: điểm earn trước hết hạn trước (12 tháng default, configurable) |
| BR-K06 | SI cap = 20 × MinimumWage(workplace_zone); zone = workplace location của Working Relationship |
| BR-K07 | Tax bracket versioning: hỗ trợ split transaction / effective-date change / annualization — configurable per LE |

### 6.5 Integration Rules (Tích hợp — Confirmed patterns)

| ID | Rule |
|----|------|
| BR-I01 | TR → Payroll: Hybrid — real-time Kafka event cho salary change/bonus approval/deduction create + daily batch reconciliation |
| BR-I02 | Idempotency key bắt buộc cho mọi event gửi sang Payroll (dedup window = 24 giờ) |
| BR-I03 | Tax Authority API: dual-path song song (không sequential fallback) — API + file export cùng lúc |
| BR-I04 | E-Signature callback: dual confirm — webhook primary + polling mỗi 15 phút |
| BR-I05 | Benefits Carrier (EDI 834): sync tự động + alert khi carrier sync fail (configurable: retry/alert/auto-fix) |
| BR-I06 | Payroll bridge delay > 15 phút → alert escalation; at-least-once delivery guarantee |
| BR-I07 | FX rate: configurable provider, daily update, workflow riêng khi biến động >5% trong cycle |

---

## 7. Nguyên tắc kiến trúc nền tảng (Platform Architecture Principles)

### 7.1 Plugin/Engine Architecture

Mọi calculation trong TR phải được implement qua **pluggable engine pattern** — không hardcode business logic:

| Domain | Engine | Interface |
|--------|--------|-----------|
| Statutory Contributions (SI, CPF, BPJS...) | CountryContributionEngine | `calculate(worker, period) → ContributionResult` |
| Tax Withholding | TaxBracketEngine | `calculate(taxable_income, period, profile) → TaxResult` |
| Proration | ProrationEngine | `prorate(amount, method, period) → ProratedAmount` |
| Bonus/Variable Pay | FormulaEngine | `evaluate(formula_json, context) → Amount` |
| Pay Equity Analysis | EquityAnalysisEngine | `analyze(cohort, method) → EquityReport` |
| Tax Bracket Versioning | VersioningStrategy | Pluggable: split / effective-date / annualization |

**Deployment constraint**: Mỗi CountryContributionEngine instance được cấu hình bởi HR SME (không phải developer) qua Admin UI. Rates, caps, bases — tất cả là configurable parameters.

### 7.2 Configurable Workflow Engine

Tất cả approval flows trong TR phải được định nghĩa qua **configurable workflow engine** — enterprise tự cấu hình, không cần code change:

| Workflow | Options được hỗ trợ |
|----------|---------------------|
| Salary below minimum wage | Block / Warning + exception approval / Warning only |
| Compensation change approval | Threshold-based routing (configurable threshold + approver role) |
| FX rate change >5% | Lock rate / Recompute report / Alert Finance |
| Bonus budget reallocation | Locked / Manager self-service / Approval required |
| Commission dispute | Freeze all / Freeze partial / Pay all then adjust |
| Benefits carrier sync failure | Auto-fix + retry / Alert HR / Configurable combination |
| Recognition moderation | Auto-approve / Human review / Hybrid |
| Dependent verification | Auto-approve / Document required / Carrier verify |

### 7.3 Hybrid Deployment & Data Residency

```
┌─────────────────────────────────────────────────────────────┐
│                    xTalent Platform                          │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  VN Region   │  │  SG Region   │  │  ID Region   │     │
│  │ (PII local)  │  │ (PII local)  │  │ (PII local)  │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                 │                 │               │
│         └─────────────────┼─────────────────┘               │
│                           │                                  │
│              ┌────────────▼────────────┐                    │
│              │  Central Analytics      │                    │
│              │ (Aggregated, Anonymized)│                    │
│              └─────────────────────────┘                    │
└─────────────────────────────────────────────────────────────┘
```

**Rules**:
- PII (salary, tax ID, CMND): local per country — không cross-border
- Aggregated metrics (avg salary by grade, % bonus): central — được phép cross-border
- Grade/Level/Title: configurable per field (local hoặc central)

---

## 8. Ràng buộc và Giả định

### 8.1 Ràng buộc kỹ thuật

| Ràng buộc | Mô tả |
|-----------|-------|
| Upstream dependency | TR phụ thuộc CO module: Worker, Working Relationship, Job, Grade, Legal Entity phải tồn tại trước |
| Downstream feeding | TR đẩy sang PR (Payroll): PayComponent, TaxableItem, Deduction, TaxWithholding |
| UUID primary keys | Nhất quán với xTalent platform convention |
| SCD Type 2 pattern | Grade, Pay Range, Tax Bracket — bắt buộc effective_start_date/end_date/is_current |
| formula_json | Configurable formula via JSON — không hardcode business logic trong code |

### 8.2 Ràng buộc kinh doanh

| Ràng buộc | Mô tả |
|-----------|-------|
| Vietnam SI Law 2024 | Hiệu lực 7/2025 — must go-live trước deadline |
| IPO readiness 2027 | Audit trail 7-year retention bắt buộc từ ngày go-live đầu tiên |
| Multi-language Phase 1 | English + Vietnamese (mở rộng Phase 3) |
| Phase 1 country focus | Vietnam P0 — các nước SEA còn lại Phase 2 |

### 8.3 Giả định (Assumptions)

| ID | Giả định | Confidence | Impact nếu sai |
|----|----------|:----------:|----------------|
| A-01 | CO module cung cấp đầy đủ Worker và Working Relationship trước khi TR go-live | 0.95 | TR không thể hoạt động — cần CO go-live trước |
| A-02 | Payroll module (PR) sẽ tiêu thụ events từ TR theo Hybrid pattern | 0.95 | Cần redesign integration layer |
| A-03 | Worker self-service adoption ≥ 80% sau 1 năm | 0.75 | TR Statement KPI không đạt |
| A-04 | EDI 834 đủ cho carrier integration Phase 1 | 0.75 | Cần custom integration per carrier |
| A-05 | Market benchmark data Phase 1 = manual upload (AI Phase 2) | 0.98 | AI recommendation không hoạt động |
| A-06 | Vietnam SI Law 2024 rates không thay đổi trong Phase 1 (đến 12/2026) | 0.80 | Cần re-configure — không cần code change (pluggable) |

---

## 9. Ngoài phạm vi (Out of Scope)

| Item | Lý do |
|------|-------|
| Work-Life Effectiveness (WorldatWork Pillar 3) | Separate module, không thuộc TR scope |
| Performance Management | Separate module — cung cấp PerformanceMultiplier sang TR, không quản lý trong TR |
| Payroll execution (tính payslip, phát lương) | PR module — TR chỉ cung cấp input |
| Recruiting workflow (JD, interview) | TA module — Offer Management trong TR bắt đầu từ offer creation |
| Core HR (worker onboarding, org chart) | CO module |
| Time & Attendance (OT, leave) | Separate module — cung cấp input cho Proration và OT calculation |
| Stock plan administration (vesting mechanics) | Third-party provider (E*TRADE, Fidelity) — TR chỉ capture taxable events |
| Financial advice (tax optimization execution) | Regulatory risk — chỉ "recommendation" với explicit opt-in, không "advice" |

---

## 10. Chỉ số thành công (Success Metrics)

| Metric | Baseline | Target Phase 1 | Target Phase 2 | Measurement |
|--------|----------|----------------|----------------|-------------|
| Merit review cycle time | 6–8 tuần | ≤ 2 tuần | ≤ 1 tuần | Cycle open to publish |
| Payroll calculation error rate | 10–15% | < 0.5% | < 0.1% | Errors/total paychecks |
| Vietnam SI compliance violations | N/A | 0 violations | 0 violations | Audit findings |
| Worker self-service adoption | 0% | ≥ 60% (Year 1) | ≥ 80% (Year 2) | Portal logins |
| TR Statement view rate | 0% | ≥ 60% | ≥ 80% | Email open + portal |
| Commission dispute rate | N/A | < 0.5% | < 0.2% | Disputes/calculations |
| Audit trail coverage | ~20% (manual) | 100% automated | 100% | Capture rate |
| Time to detect pay equity gap | Weeks/manual | ≤ 24 hours (auto) | Real-time alert | Detection lag |

---

*BRD Version 1.0.0 — ODSA Step 2 (Reality) Output*
*Business Analyst Agent — 2026-03-26*
