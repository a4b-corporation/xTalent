# Total Rewards — Yêu cầu Pre-Reality (Step 1)

> **Module**: Total Rewards (TR)
> **Giải pháp**: xTalent — HCM
> **Ngày**: 2026-03-26 · Cập nhật: 2026-03-26 (sau Stakeholder Review Round 1)
> **Trạng thái**: UPDATED — Ambiguity Score 0.12 → Sẵn sàng Gate G1
> **Phạm vi địa lý**: 6 quốc gia Đông Nam Á (VN, TH, ID, SG, MY, PH)

---

## 1. Tuyên bố vấn đề

Các doanh nghiệp đa quốc gia hoạt động tại Đông Nam Á đang quản lý đãi ngộ nhân viên (compensation, benefits, recognition) qua các hệ thống rời rạc: HRIS cũ, Excel, email — không có cái nhìn tổng thể. Hậu quả:

- **Chu kỳ merit review** mất 6–8 tuần, lỗi phổ biến, mất lòng tin quản lý
- **Tỷ lệ lỗi tính lương** 10–15%, 25% paycheck có sai sót
- **Rủi ro tuân thủ** tại 6 quốc gia với luật lao động / thuế khác nhau (Vietnam SI Law 2024, BPJS Indonesia, CPF Singapore, EPF Malaysia, SSS Philippines...)
- **Không có audit trail** → không thể giải quyết tranh chấp, không sẵn sàng kiểm toán
- **Nhân viên không biết tổng giá trị đãi ngộ thực** → tỷ lệ nghỉ việc liên quan đến lương chiếm 25–30% voluntary turnover

xTalent cần một module **Total Rewards thống nhất**, tích hợp 11 sub-module, đưa tất cả vào một nền tảng duy nhất — thay thế Excel và quy trình thủ công bằng automation, real-time visibility và compliance tự động.

---

## 2. Bối cảnh chiến lược

### 2.1 Vị trí trong xTalent HCM

Total Rewards là module **tạo ra tác động tài chính lớn nhất** trong xTalent — chi phí nhân sự chiếm 60–70% tổng chi phí vận hành doanh nghiệp. Module này:

- **Phụ thuộc upstream**: CO (Core HR) cung cấp worker, working_relationship, job, grade, legal_entity, business_unit
- **Cung cấp downstream**: Payroll (PR) nhận TaxableItems, Deductions, PayComponents, TaxWithholding
- **Tích hợp ngoài**: Benefits Carriers (EDI 834), Tax Authorities, Stock Plan Admin, E-Signature

### 2.2 Khung tham chiếu toàn cầu (WorldatWork 5-pillar)

| Pillar | Sub-module xTalent |
|--------|--------------------|
| Compensation | Core Compensation, Variable Pay |
| Benefits | Benefits Administration |
| Work-Life Effectiveness | (ngoài scope Phase 1) |
| Recognition | Recognition Programs |
| Performance & Development | (tích hợp từ Performance module) |

### 2.3 Định vị so với thị trường

| Hệ thống | Tương đương | Độ tương đồng |
|----------|-------------|:-------------:|
| Workday HCM | Compensation, Benefits, Equity | ~90% |
| Oracle HCM Cloud | Total Compensation, Benefits | ~90% |
| SAP SuccessFactors | Compensation, Benefits, LTI | ~85% |

### 2.4 Drivers thời điểm

| Driver | Mức độ | Hệ quả nếu trì hoãn |
|--------|--------|---------------------|
| Vietnam SI Law 2024 (hiệu lực 7/2025) | CRITICAL | Phạt VND 50–100M/vụ |
| Mở rộng khu vực SEA (Q2 2026) | HIGH | Không thể scale |
| Cạnh tranh với Oracle/SAP/Workday | HIGH | Mất cơ hội thị trường |
| Chuẩn bị IPO (2027) | HIGH | Audit-ready records bắt buộc |

---

## 2b. Nguyên tắc kiến trúc nền tảng ✅ (Confirmed sau Stakeholder Review)

> **Meta-decision quan trọng nhất**: xTalent Total Rewards là một **platform/giải pháp** phục vụ nhiều doanh nghiệp với các chính sách, luật lao động, và quy trình khác nhau — **không phải** một hệ thống được cấu hình cứng cho một khách hàng cụ thể. Do đó, câu trả lời kiến trúc cho hầu hết các câu hỏi về business rules là: **"hệ thống hỗ trợ tất cả các option thông qua configuration/workflow/plugin/engine."**

### 2b.1 Kiến trúc tính toán: Plugin/Engine-first

| Domain | Yêu cầu | Implication |
|--------|---------|-------------|
| **SI / Statutory Contributions** | Không hardcode bất kỳ quốc gia nào. HR SME cấu hình rates, caps, bases | Pluggable calculation engine per country |
| **Tax Withholding** | Multi-country tax engine, SCD Type 2 brackets | Rules engine + effective-date versioning |
| **Proration** | Calendar days / working days / 30-day fixed — chọn theo country/LE | Configurable proration method per component |
| **Variable Pay** | 13th month, THR, PD 851 → chọn rule/engine theo quốc gia | Selectable bonus rule per enterprise |
| **Pay Equity Analysis** | Compa-ratio simple / regression / full statistical — configurable | Plugin-based analysis engine |
| **Tax Bracket Versioning** | Split / effective-date / annualization — tùy quốc gia/enterprise | All 3 strategies supported, config per LE |

### 2b.2 Kiến trúc quy trình: Configurable Workflow Engine

| Quy trình | Các option được hỗ trợ |
|-----------|------------------------|
| Salary below minimum wage | Block / Warning + exception approval / Warning only (config per enterprise) |
| FX rate change >5% | Lock rate / Recompute report / Alert Finance — configurable workflow |
| Bonus budget reallocation | Locked / Manager self-service / Approval required — configurable |
| Commission dispute | Freeze all / Freeze partial / Pay all then adjust — configurable |
| Carrier sync failure | Auto-fix + retry / Alert HR / Configurable combination |
| Dependent verification | Auto-approve / Document required / Carrier verify — configurable per LE |
| Recognition moderation | Auto-approve / Human review / Hybrid — configurable per enterprise |

### 2b.3 Kiến trúc tích hợp: Hybrid + Dual-path

| Concern | Quyết định | Pattern |
|---------|-----------|---------|
| **TR → Payroll** | **Hybrid (D)** — real-time events cho critical changes + daily batch reconciliation | Event-driven (Kafka) + File batch fallback |
| **Idempotency** | **A + B + C combined** — idempotency key + dedup window + at-least-once delivery | Robust delivery guarantee |
| **Tax Authority API** | **Dual-path (C)** — API + file export song song, không phải sequential fallback | Both paths prepared in parallel |
| **E-Signature** | **Dual confirm (C)** — webhook primary + polling fallback mỗi 15 phút | Resilient callback handling |
| **FX Rate Source** | **Configurable** — auto API (OANDA/Reuters) hoặc manual input per cycle | Provider-agnostic FX module |

### 2b.4 Kiến trúc dữ liệu: Hybrid Deployment + Configurable Privacy

| Layer | Data | Deployment |
|-------|------|-----------|
| PII (họ tên, CMND, lương tuyệt đối) | Local region per country | KHÔNG cross-border |
| Aggregated metrics (avg salary by grade, % bonus) | Central analytics | ĐƯỢC phép cross-border |
| Grade/Level/Title | Central or local | Configurable per field |
| Cross-border policy | **Fully configurable**: plain / encrypted / anonymized / compressed / combined | Per data field |

### 2b.5 Quyết định cứng (Non-configurable)

| Decision | Giá trị | Lý do |
|----------|---------|-------|
| Vietnam wage zone determination | **Workplace location** (địa chỉ nơi làm việc) | Đúng luật lao động VN |
| SI cap timing khi đổi vùng | **Tháng tiếp theo** sau effective date của working relationship change | Phù hợp quy trình báo tăng/giảm cuối tháng |
| Minimum wage validation trigger | **Hard block** khi create offer + salary change | Compliance-first |
| Tax API SLA | **Alert 15min → Escalate 1h → Fallback 2h** | Đủ thời gian xử lý trước deadline |
| Payroll bridge escalation | **15 phút** max tolerable delay | Employee payment critical |
| Commission dashboard latency | **< 5 giây** (near real-time, Kafka streaming) | Sales rep trust requirement |
| TR Statement | **On-demand + annual auto-generate** | Best UX + storage balance |
| AI cold start | **B+C**: Market benchmark fallback + "limited data" disclaimer | Always show recommendation |

---

## 3. Các bên liên quan & Actor chính

### 3.1 Ma trận Actor

| Actor | Sub-module liên quan | Trách nhiệm chính |
|-------|---------------------|-------------------|
| HR Administrator | Tất cả | Cấu hình hệ thống, hỗ trợ nhân viên, compliance |
| Compensation Manager | Core Comp, Variable Pay | Thiết kế plan, phân bổ ngân sách, phân tích equity |
| Compensation Administrator | Core Comp, Variable Pay | Cấu trúc lương, chu kỳ, eligibility |
| Benefits Administrator | Benefits, TR Statement | Enrollment, carrier liaison, compliance |
| Payroll Administrator | Calculation Rules, Tax, Deductions | Thực thi payroll, reconciliation |
| Tax Administrator | Tax Withholding, Taxable Bridge | Cấu hình thuế, nộp hồ sơ, compliance |
| Recognition Administrator | Recognition | Cấu hình chương trình, quản lý catalog |
| People Manager | Core Comp, Variable Pay, Recognition | Đề xuất thay đổi lương, ghi nhận team |
| Budget Approver | Core Comp, Variable Pay | Phê duyệt phân bổ theo ngưỡng |
| Employee (Self-Service) | Tất cả | Xem dữ liệu cá nhân, enroll benefits, redeem points |
| Compliance Officer | Audit, Tax, Benefits | Báo cáo compliance, ứng phó kiểm toán |
| External Auditor | Audit | Đọc audit log, review compliance |
| System (Automated) | Tất cả | Validation, notification, milestone detection |

### 3.2 Khái niệm đặc thù xTalent

- **Worker** = Person/Employee (không phải "Employee" như hệ thống truyền thống)
- **Working Relationship** = Mối quan hệ làm việc giữa Worker và Legal Entity (thay cho hợp đồng lao động truyền thống)
- **Config Scope** = Nhóm phạm vi cấu hình (Country → Legal Entity → Business Unit), cho phép inherit và override rule

---

## 4. Yêu cầu chức năng

### 4.1 Core Compensation (P0)

| ID | Yêu cầu | Mức độ |
|----|---------|--------|
| FR-CC-001 | Quản lý Salary Basis (HOURLY, MONTHLY, ANNUAL) với Pay Components tái sử dụng | P0 |
| FR-CC-002 | Quản lý Grade với SCD Type 2 — lưu lịch sử đầy đủ, không mất dữ liệu thăng tiến | P0 |
| FR-CC-003 | Pay Range đa cấp (Global → Legal Entity → Business Unit → Position), áp dụng cấp cụ thể nhất | P0 |
| FR-CC-004 | Compensation Cycle (Merit, Promotion, Market Adjustment, New Hire, Equity Correction) với budget tracking real-time | P0 |
| FR-CC-005 | Approval workflow tự động theo ngưỡng tăng lương (<5% → auto, 5-10% → Director, >10% → VP) | P0 |
| FR-CC-006 | Compa-Ratio tracking và pay equity analytics | P1 |
| FR-CC-007 | Validation minimum wage theo 4 vùng lương Vietnam (VND 3.25M–4.68M) | P0 |
| FR-CC-008 | Multi-country scoping qua Config Scope (Phase 1: inline country_code; Phase 2: config_scope_id) | P0 |

### 4.2 Calculation Rules Engine (P0)

| ID | Yêu cầu | Mức độ |
|----|---------|--------|
| FR-CR-001 | Engine tính Social Insurance Vietnam: BHXH 17.5%+8%, BHYT 3%+1.5%, BHTN 1%+1%, cap 20× lương tối thiểu vùng | P0 |
| FR-CR-002 | Proration tự động theo calendar days / working days / none per component | P0 |
| FR-CR-003 | Versioning calculation rule — lưu lịch sử công thức, đảm bảo tính đúng kỳ lịch sử | P0 |
| FR-CR-004 | Framework mở rộng cho country-specific rules (VN, TH, ID, SG, MY, PH) | P0 |

### 4.3 Variable Pay (P0)

| ID | Yêu cầu | Mức độ |
|----|---------|--------|
| FR-VP-001 | Bonus (STI/LTI/Spot): Formula engine `Bonus = BaseSalary × Target% × PerformanceMultiplier × CompanyMultiplier` | P0 |
| FR-VP-002 | 13th month pro-rata: Vietnam (Tết), Philippines (PD 851), Indonesia (THR) | P0 |
| FR-VP-003 | Commission: Tiered rates, accelerator, quota tracking, monthly cycle | P0 |
| FR-VP-004 | Equity (RSU/Stock Options/ESPP): Vesting schedule tự động, tax event khi vest, bridge sang Taxable Bridge | P1 |
| FR-VP-005 | Budget pool management với real-time remaining balance | P0 |
| FR-VP-006 | Off-cycle bonus (spot, retention) với approval path riêng | P1 |

### 4.4 Benefits Administration (P0)

| ID | Yêu cầu | Mức độ |
|----|---------|--------|
| FR-BA-001 | Eligibility Engine với EligibilityProfile tái sử dụng cho nhiều plan | P0 |
| FR-BA-002 | 3 enrollment period types: Open Enrollment, New Hire (30 ngày), Qualifying Life Event (kết hôn, sinh con) | P0 |
| FR-BA-003 | 8 loại benefit plan: Medical, Dental, Vision, Life, Disability, Retirement, Wellness, Perk | P0 |
| FR-BA-004 | EDI 834 carrier integration (tự động sync enrollment với carrier) | P0 |
| FR-BA-005 | Self-service enrollment portal cho nhân viên | P0 |
| FR-BA-006 | Dependent verification workflow với document upload | P1 |
| FR-BA-007 | Flex credit allocation (nhân viên tự phân bổ credit cho benefit khác nhau) | P2 |

### 4.5 Recognition Programs (P1)

| ID | Yêu cầu | Mức độ |
|----|---------|--------|
| FR-REC-001 | Point-based recognition với FIFO expiration (khuyến khích redeem thường xuyên) | P1 |
| FR-REC-002 | Peer-to-peer recognition và manager awards | P1 |
| FR-REC-003 | Social recognition feed (public posts) với content moderation workflow | P1 |
| FR-REC-004 | Perks catalog (gift cards, experiences, merchandise) với redeem tracking | P1 |
| FR-REC-005 | Perk có giá trị tiền tệ → tự động tạo Taxable Item sang Payroll | P1 |
| FR-REC-006 | AI recognition suggestion (gợi ý thời điểm và nội dung ghi nhận) | P2 |

### 4.6 Offer Management (P1)

| ID | Yêu cầu | Mức độ |
|----|---------|--------|
| FR-OM-001 | Offer templates linh hoạt với merge fields từ CO module | P1 |
| FR-OM-002 | Approval workflow cho offer trước khi gửi ứng viên | P1 |
| FR-OM-003 | E-signature integration (DocuSign hoặc tương đương) | P1 |
| FR-OM-004 | Counter-offer workflow: ứng viên đề xuất điều chỉnh, HR phản hồi | P1 |
| FR-OM-005 | Offer competitiveness scoring (AI đánh giá cạnh tranh so thị trường) | P2 |
| FR-OM-006 | Offer analytics: acceptance rate, time-to-accept, decline reasons | P1 |

### 4.7 Total Rewards Statement (P1)

| ID | Yêu cầu | Mức độ |
|----|---------|--------|
| FR-TRS-001 | Statement hàng năm (on-demand) tổng hợp: lương + bonus + equity + benefits + recognition | P1 |
| FR-TRS-002 | Xuất PDF với branding doanh nghiệp | P1 |
| FR-TRS-003 | Multi-channel delivery: email, self-service portal, mobile | P1 |
| FR-TRS-004 | Archival 7 năm với versioning | P1 |
| FR-TRS-005 | Tax optimization recommendation trên statement (P2) | P2 |

### 4.8 Deductions (P0)

| ID | Yêu cầu | Mức độ |
|----|---------|--------|
| FR-DED-001 | Quản lý khoản khấu trừ: vay lương (loan), garnishment, salary advance | P0 |
| FR-DED-002 | Voluntary deductions (đóng góp phúc lợi tự nguyện) | P0 |
| FR-DED-003 | Lịch khấu trừ tự động theo payroll cycle | P0 |
| FR-DED-004 | Priority ordering khi nhiều deductions cùng kỳ | P0 |

### 4.9 Tax Withholding (P0)

| ID | Yêu cầu | Mức độ |
|----|---------|--------|
| FR-TAX-001 | Cấu hình tax bracket theo quốc gia với effective dating | P0 |
| FR-TAX-002 | Employee tax profile tự khai báo (self-service) | P0 |
| FR-TAX-003 | e-Filing tích hợp với Tax Authority APIs | P0 |
| FR-TAX-004 | Fallback manual filing khi Tax Authority API down | P0 |
| FR-TAX-005 | AI tax optimization recommendation (opt-in) | P2 |

### 4.10 Taxable Bridge (P0)

| ID | Yêu cầu | Mức độ |
|----|---------|--------|
| FR-TXB-001 | Tự động tạo Taxable Item từ equity vest, perk redemption, benefit in-kind | P0 |
| FR-TXB-002 | Bridge sang Payroll module đúng kỳ (không bỏ sót event) | P0 |
| FR-TXB-003 | Compliance reporting cho từng loại taxable item | P0 |

### 4.11 Audit (P0)

| ID | Yêu cầu | Mức độ |
|----|---------|--------|
| FR-AUD-001 | 100% capture mọi thay đổi TR entity với before/after values | P0 |
| FR-AUD-002 | Audit records immutable (không thể sửa/xóa) | P0 |
| FR-AUD-003 | 7-year data retention | P0 |
| FR-AUD-004 | Compliance report generation on-demand | P0 |
| FR-AUD-005 | Anomaly detection (phát hiện thay đổi bất thường) | P1 |
| FR-AUD-006 | External auditor read-only access | P0 |

---

## 5. Yêu cầu phi chức năng

| Category | Yêu cầu | Target |
|----------|---------|--------|
| **Performance** | Compensation cycle processing | < 2 giờ cho 15K workers |
| **Performance** | Real-time commission dashboard | < 2 giây latency |
| **Performance** | TR Statement PDF generation | < 5 giây/statement |
| **Accuracy** | Payroll calculation error rate | < 0.5% |
| **Accuracy** | Commission accuracy | ≥ 99.5% (dispute rate < 0.5%) |
| **Availability** | Core calculation services | 99.9% uptime |
| **Scalability** | Workers hỗ trợ | 15K+ (scale to 100K+) |
| **Security** | PII encryption | At-rest + in-transit |
| **Security** | Access logging | 100% access to sensitive data |
| **Compliance** | Audit trail retention | 7 năm minimum |
| **Compliance** | Multi-country tax | 6 quốc gia SEA |
| **Data Privacy** | PDPA (SG, MY) / PDP (ID) | Data residency compliance |

---

## 6. Business Rules & Ràng buộc

### 6.1 Rules tuân thủ (Compliance Rules)

> **Nguyên tắc platform**: Tất cả statutory contribution rules được implement như **configurable parameters** — không hardcode. HR SME của từng quốc gia sẽ cấu hình qua admin UI. Bảng dưới là **dữ liệu mẫu seed** cần pre-populate khi go-live.

| ID | Rule | Quốc gia | Cơ sở pháp lý | Loại |
|----|------|----------|----------------|------|
| BR-C01 | BHXH employer: 17.5%, employee: 8%; BHYT employer: 3%, employee: 1.5%; BHTN employer: 1%, employee: 1% | VN | SI Law 2024 | Statutory (configurable rate) |
| BR-C02 | Lương tối thiểu theo 4 vùng: Vùng 1: 4.68M, Vùng 2: 4.16M, Vùng 3: 3.64M, Vùng 4: 3.25M (VND/tháng) | VN | Decree 74/2024 | Statutory (configurable table) |
| BR-C03 | Cơ sở tính SI không vượt quá 20× lương tối thiểu vùng. Vùng = **workplace location** của worker | VN | SI Law 2024 | ✅ CONFIRMED |
| BR-C04 | SI cap thay đổi vùng → áp dụng **tháng tiếp theo** sau ngày effective của working relationship change | VN | SI Law 2024 | ✅ CONFIRMED |
| BR-C05 | Minimum wage validate tại: create offer + salary change. Nếu vi phạm → configurable workflow (block/warning/exception) | VN + all | Labor Law | ✅ CONFIRMED |
| BR-C06 | 13th month / THR / PD 851 → implement như selectable rule/plugin per enterprise. VN: configurable. PH: PD 851 mandatory formula | VN, PH, ID | PD 851 (PH) | ✅ CONFIRMED |
| BR-C07 | CPF contribution rate: employee max 20%, employer 17% (capped at monthly wage S$6,000) | SG | CPF Act | Statutory (configurable) |
| BR-C08 | EPF: employee 11%, employer 13% (income ≤ RM5K) hoặc 12% (>RM5K) | MY | EPF Act | Statutory (configurable) |
| BR-C09 | BPJS Ketenagakerjaan: JKK 0.24-1.74%, JKM 0.3%, JHT 3.7%+2%, JP 2%+1% | ID | BPJS Law | Statutory (configurable) |
| BR-C10 | Thailand Social Security Fund: 5%, capped THB 750/month | TH | Social Security Act | Statutory (configurable) |
| BR-C11 | Philippines: SSS + PhilHealth + Pag-IBIG — rates per tier | PH | Labor Code | Statutory (configurable) |

### 6.2 Rules thẩm quyền (Authorization Rules)

> **Nguyên tắc platform**: Authorization rules được implement qua **configurable workflow engine** — enterprise tự định nghĩa threshold, approver role, và path. Giá trị dưới là default template.

| ID | Rule | Loại |
|----|------|------|
| BR-A01 | Tăng lương < 5%: auto-approve (default, configurable threshold) | Template |
| BR-A02 | Tăng lương 5–10%: cần Director approval (default, configurable) | Template |
| BR-A03 | Tăng lương > 10%: cần VP approval (default, configurable) | Template |
| BR-A04 | Salary change ngoài pay range: cần exception approval thêm (configurable) | Template |
| BR-A05 | Offer vượt ngưỡng ngân sách: cần Finance Approver (configurable) | Template |
| BR-A06 | Audit records: không ai có thể modify hoặc delete | ✅ HARD RULE |
| BR-A07 | Bonus budget reallocation: configurable workflow (locked / self-service / approval) | Configurable |
| BR-A08 | Commission dispute: default = freeze partial, pay undisputed. Configurable per enterprise | ✅ CONFIRMED default |
| BR-A09 | Compa-ratio visibility cho manager: configurable per enterprise, default = anonymous distribution | ✅ CONFIRMED |

### 6.3 Rules dữ liệu (Data Rules)

| ID | Rule |
|----|------|
| BR-D01 | SCD Type 2 cho: Grade, Pay Range, Tax Bracket — mọi thay đổi tạo version mới |
| BR-D02 | Mọi compensation change phải có audit record với actor, timestamp, before/after |
| BR-D03 | 7-year retention cho tất cả TR audit records |
| BR-D04 | PII (salary, tax ID) phải được mã hóa at-rest và in-transit |
| BR-D05 | Integration data phải validated trước khi xử lý (contract enforcement) |

### 6.4 Rules tính toán (Calculation Rules)

| ID | Rule |
|----|------|
| BR-K01 | Proration = ActualDays / TotalDays trong kỳ (calendar hoặc working days theo component config) |
| BR-K02 | Bonus = BaseSalary × Target% × PerformanceMultiplier × CompanyMultiplier |
| BR-K03 | Commission = SUM(Tier × Rate) với accelerator khi vượt quota |
| BR-K04 | Compa-Ratio = ActualSalary / MidpointSalary (range của grade) |
| BR-K05 | FIFO point expiration cho recognition: điểm vào trước hết hạn trước |

---

## 7. Hypotheses (Giả thuyết) — Cập nhật sau Review

| ID | Giả thuyết | Confidence | Status | Rationale |
|----|------------|:----------:|:------:|-----------|
| H-01 | Vietnam là market chính cần ưu tiên compliance trước (SI Law 2024) | 0.98 | ✅ CONFIRMED | Confirmed: Vietnam P0, si engine không hardcode, configurable cho mọi nước |
| H-02 | Formula engine dạng JSON-configurable (formula_json) đủ linh hoạt cho 90% use cases | 0.85 | ✅ CONFIRMED | Confirmed: Plugin/engine architecture là quyết định kiến trúc cốt lõi |
| H-03 | Config Scope hierarchy (Country → LE → BU) là đúng abstraction cho multi-country | 0.95 | ✅ CONFIRMED | Confirmed: A-02b → Option C (tùy khách hàng, cần cả hai) → Config Scope là đúng |
| H-04 | Payroll module (PR) là downstream consumer — TR đẩy dữ liệu sang | 0.95 | ✅ CONFIRMED | Confirmed: Hybrid event-driven + batch. TR không nhận từ PR |
| H-05 | Self-service cho nhân viên cần 80%+ adoption để business case có giá trị | 0.75 | ⏳ Pending | Chưa validate với customer HR teams |
| H-06 | EDI 834 là standard đủ cho carrier integration giai đoạn đầu | 0.75 | ✅ CONFIRMED | H11: configurable carrier sync. EDI 834 là default, extensible |
| H-07 | AI recommendation là Phase 2-3, không block Phase 1 MVP | 0.98 | ✅ CONFIRMED | A-03a: Không có USP nào là P0 cho Phase 1 |
| H-08 | Recognition launch sau Core Comp 3-4 tháng mà không ảnh hưởng MVP | 0.90 | ✅ CONFIRMED | P1 priority, confirmed không block |
| H-09 | 13th month có thể xử lý bằng Variable Pay formula engine hiện tại | 0.90 | ✅ CONFIRMED | H10: implement như selectable rule/plugin. VN configurable, PH = PD 851 rule |
| H-10 | Data residency sẽ yêu cầu regional deployment | 0.95 | ✅ CONFIRMED | H03a: Hybrid deployment confirmed. PII local, analytics central |
| H-11 | **[NEW]** Plugin/engine architecture là core pattern cho mọi calculation trong TR | 0.95 | ✅ CONFIRMED | Meta-decision từ stakeholder: platform, không phải single-customer solution |
| H-12 | **[NEW]** Commission dashboard yêu cầu Kafka streaming (< 5 giây) từ Phase 2 | 0.90 | ✅ CONFIRMED | A-03c + H16: Option A (<5 giây) đã chọn |

---

## 8. Câu hỏi mở & Điểm mơ hồ — Cập nhật sau Stakeholder Review Round 1

### 8.1 P0 — ĐÃ GIẢI QUYẾT ✅

| ID | Câu hỏi | Mức độ mơ hồ ban đầu | Quyết định |
|----|---------|:--------------------:|-----------|
| Q-01 | Vietnam SI Law 2024 — cách tính cap 20× vùng | 0.8 | ✅ Workplace location xác định vùng. Cap thay đổi tháng tiếp theo |
| Q-02 | FX Rate Source | 0.7 | ✅ Configurable: hỗ trợ mọi nguồn, daily update, workflow xử lý >5% change |
| Q-03 | Data Residency cross-border | 0.8 | ✅ Hybrid deployment: PII local, analytics central. Data classification configurable |
| Q-04 | Tax Authority API Fallback | 0.6 | ✅ Dual-path: API + file song song. SLA: alert 15min, escalate 1h, fallback 2h |
| Q-05 | Payroll Bridge Failure | 0.7 | ✅ Hybrid integration + idempotency A+B+C. Escalate sau 15 phút |
| Q-06 | 4-Region Min Wage validation | 0.6 | ✅ Workplace location. Hard block khi create offer + salary change. Configurable workflow |

### 8.2 P1 — ĐÃ GIẢI QUYẾT ✅

| ID | Câu hỏi | Mức độ mơ hồ ban đầu | Quyết định |
|----|---------|:--------------------:|-----------|
| Q-07 | Proration method per country | 0.5 | ✅ Configurable per country/LE. Hỗ trợ calendar/working days/30-day fixed |
| Q-08 | Commission dispute handling | 0.5 | ✅ Default: freeze partial only. Configurable per enterprise |
| Q-09 | Tax bracket mid-year versioning | 0.5 | ✅ Configurable: split/effective-date/annualization. Tùy quốc gia/enterprise |
| Q-10 | Recognition moderation | 0.4 | ✅ Configurable per enterprise (auto/hybrid/human). SLA configurable |
| Q-11 | Compa-ratio visibility | 0.4 | ✅ Configurable per enterprise. Default = anonymous distribution chart |
| Q-12 | Carrier sync failure | 0.5 | ✅ Configurable (retry/alert/auto-fix). Coverage effective date: configurable |

### 8.3 Còn mở — P2 (Defer to Implementation)

| ID | Câu hỏi | Mức độ mơ hồ | Gợi ý mặc định |
|----|---------|:------------:|----------------|
| H19 | Manager tooltips (market rate, compa-ratio) | 0.2 | Show compa-ratio + market rate (Option C) |
| H20 | Employee bonus simulation | 0.2 | Cho phép, có disclaimer |
| H21 | Recognition point expiration | 0.2 | 12 tháng FIFO |
| H23 | Multi-language scope | 0.15 | EN + VI Phase 1, mở rộng Phase 3 |
| H24 | Notification channels | 0.15 | Email + In-app Phase 1 |
| H25 | Market benchmarking data source | 0.15 | Manual upload Phase 1 |
| H26 | Off-cycle bonus workflow | 0.15 | Fast track path (simplified) |
| H27 | Tax optimization opt-in | 0.2 | Explicit opt-in (avoid financial advice regulatory risk) |
| H28 | Audit retention > 7 years | 0.1 | Indefinite cho exec comp/equity |

### 8.4 Ambiguity còn lại — Technical Architecture

| Vấn đề | Mức độ mơ hồ | Ghi chú |
|--------|:------------:|---------|
| HOW của plugin architecture: interface contract, versioning, deployment | 0.15 | Cần Step 3 (Domain Architecture) để specify |
| HOW của configurable workflow engine: BPMN? Custom DSL? | 0.10 | Cần Step 4 (Solution Architecture) |
| Data classification engine: HOW config cross-border policy per field | 0.08 | Cần security architecture review |

---

## 9. Phát hiện từ nghiên cứu (Research Findings)

### 9.1 Từ BRD Reference (11 sub-BRD)

**Phát hiện chính:**
- **416 business rules** đã được định nghĩa, phân bổ trên 11 sub-module (từ 22 rules [TR Statement] đến 67 rules [Offer Management])
- **Offer Management có nhiều rules nhất** (67) → phức tạp nhất về workflow và compliance
- **Recognition có nhiều rules thứ hai** (62) → phức tạp về validation và authorization

**Cấu trúc sub-module priority:**
```
P0 (Foundation Phase 1): Core Comp → Calculation Rules → Benefits → Deductions → Tax → Taxable Bridge → Audit
P1 (Innovation Phase 2): Variable Pay → Recognition → Offer Management → TR Statement
P2 (Leadership Phase 3): AI/ML Suite → Equity Compensation → Advanced Analytics
```

### 9.2 Từ Event Storming (9 documents, ~137KB)

- **150 domain events**, **80 commands**, **40+ actors** đã được capture
- **8 USP events** nổi bật (innovation differentiators):
  - `SocialRecognitionPosted` → employee engagement
  - `PayEquityGapDetected` → DEI compliance
  - `AICompensationRecommended` → 50% AI adoption target
  - `RealTimeCommissionCalculated` → sales rep trust
  - `FlexCreditAllocated` → personalized benefits
  - `AIRecognitionSuggested` → recognition frequency
  - `TaxOptimizationRecommended` → financial wellness
  - `OfferCompetitivenessScored` → offer acceptance rate
- **28 hot spots** đã được xác định (6 P0, 12 P1, 10 P2)

### 9.3 Từ DBML xTalent (4.TotalReward.V5.dbml)

**Data model hiện tại đã implement:**
- `comp_core.config_scope` — Multi-country scoping abstraction (thêm 26Mar2026)
- `comp_core.salary_basis` + `comp_core.pay_component_def` — Component-based compensation
- `comp_core.grade_v` — Grade với SCD Type 2 versioning
- `comp_core.grade_ladder` — Career ladder (Management, Technical, Specialist...)
- Schema schemas: `comp_core`, và các schema khác trong TR module

**Đặc điểm kỹ thuật quan trọng:**
- UUID làm primary key (không phải integer)
- `effective_start_date` / `effective_end_date` / `is_current_flag` — pattern SCD Type 2
- `formula_json` / `metadata jsonb` — linh hoạt cấu hình không cần migration
- Phase 1 (inline country_code) → Phase 2 (config_scope_id) — migration path đã lên kế hoạch

### 9.4 Từ Research Overview

| Insight | Ý nghĩa |
|---------|---------|
| Merit review từ 6-8 tuần → 2 tuần | ROI rõ ràng, measurable |
| 70 entities trong domain model | Scope lớn, cần phân phase kỹ |
| 99.9% calculation accuracy target | Không thể có rounding error hay edge case bỏ qua |
| Nhân viên không biết total comp value (lương tay vs. true value chênh 40-60%) | TR Statement là killer feature để retention |

---

## 10. Tích hợp với xTalent CO Module

### 10.1 Phụ thuộc upstream (TR nhận từ CO)

| Dữ liệu | Entity xTalent | Ghi chú |
|---------|----------------|---------|
| Nhân viên | `Worker` (≠ Employee) | Định danh duy nhất trong hệ thống |
| Mối quan hệ làm việc | `Working Relationship` | Thay cho employment contract |
| Vị trí/Chức vụ | `Job`, `Position` | Gắn với Grade và Pay Range |
| Cấp bậc | `Grade` | SCD Type 2 trong CO module |
| Đơn vị pháp lý | `Legal Entity` | Xác định country và regulatory context |
| Đơn vị kinh doanh | `Business Unit` | Level scoping của compensation |
| Tổ chức | Org Hierarchy | Budget rollup, approval chain |

### 10.2 Cung cấp downstream (TR đẩy sang PR Payroll)

| Dữ liệu | Entity | Mục đích |
|---------|--------|----------|
| Thành phần lương | PayComponent + Amount | Tính payslip |
| Taxable items | TaxableItem | Tính PIT |
| Khấu trừ | Deduction | Giảm lương thực nhận |
| Thuế đã khấu trừ | TaxWithholding | Reconciliation |

### 10.3 Pattern tích hợp đặc thù ✅ (Confirmed)

**TR → Payroll Integration Pattern: Hybrid (Option D — CONFIRMED)**
- **Real-time events** (Kafka): salary change, bonus approved, deduction created → Payroll nhận ngay
- **Daily batch reconciliation**: full data sync cuối ngày để đảm bảo consistency
- **Idempotency**: Idempotency key per transaction + 15-phút dedup window + at-least-once delivery
- **Escalation**: 15 phút max delay → alert + manual intervention

**Tax Authority Integration: Dual-path (Option C — CONFIRMED)**
- API call + file export chuẩn bị **song song** (không sequential fallback)
- SLA: Alert 15min → Escalate 1h → Trigger manual file submission 2h

**E-Signature: Dual confirm (Option C — CONFIRMED)**
- Webhook primary + scheduled polling mỗi 15 phút làm fallback
- Provider-agnostic: configurable (DocuSign, Adobe Sign, regional providers)

**FX Rate: Configurable (CONFIRMED)**
- Hỗ trợ auto-source API (OANDA/Reuters/central bank) hoặc manual input per compensation cycle
- Update frequency: daily (confirmed)
- Rate change >5%: configurable workflow (lock / recompute / alert Finance)

**Taxable Bridge**: Equity vest / Perk redeem → tự động tạo TaxableItem → push sang Payroll via events đúng kỳ

**Config Scope**: `Legal Entity.country_code` → resolve calculation rules, tax brackets, benefit eligibility. Config Scope abstraction cho phép enterprise chọn Phase 1 (inline) hoặc Phase 2 (scope groups) theo nhu cầu.

---

## Điểm mơ hồ tổng thể

**Ambiguity Score: 0.12/1.0** ✅ (Giảm từ 0.35 → 0.12 sau Stakeholder Review Round 1)

> **Dưới ngưỡng 0.20** → Sẵn sàng proceed to Step 2 (Reality).

**Breakdown sau review:**

| Nguồn mơ hồ | Score trước | Score sau | Ghi chú |
|-------------|:-----------:|:---------:|---------|
| P0 Compliance/Legal (6 questions) | 0.15 | 0.02 | Còn: detail data classification per field |
| P0 Technical architecture (6 questions) | 0.12 | 0.02 | Còn: HOW plugin/workflow engine spec |
| P1 Policy decisions (12 questions) | 0.08 | 0.01 | Tất cả resolved qua "configurable" pattern |
| P2 (H19-H28, defer) | — | 0.04 | Chủ ý defer, gợi ý mặc định đã có |
| Technical HOW (plugin, workflow DSL) | — | 0.03 | Cần Step 3-4 architecture |
| **Tổng** | **0.35** | **0.12** | |

**Lý do giảm mạnh**: Meta-decision "configurable platform" giải quyết hầu hết P0/P1 ambiguities vì:
- Thay vì phải chọn 1 option → yêu cầu hỗ trợ tất cả option qua configuration
- Đây là requirement rõ ràng và actionable cho architecture
- Không còn uncertainty về WHAT → chỉ còn HOW (thuộc về Step 3-4)

---

**Changelog:**
- v1.0.0 (2026-03-26): Initial draft — Ambiguity 0.35
- v1.1.0 (2026-03-26): Updated after Stakeholder Review Round 1 — Ambiguity 0.12

*Tài liệu này tổng hợp từ: 11 BRD sub-modules, 9 Event Storming documents (~137KB), Research Overview (7 documents), 11 Concept Guides, DBML xTalent TR V5 (26Mar2026), Stakeholder Q&A Review.*
