# Total Rewards — Stakeholder Q&A Document

> **Mục đích**: Tài liệu này tổng hợp toàn bộ câu hỏi cần giải đáp trước khi thiết kế và implement module Total Rewards. Mỗi câu hỏi có ghi chú các option trả lời, gợi ý của product team, và ô để ghi kết quả sau khi review với stakeholder.
>
> **Ngày tạo**: 2026-03-26 · Cập nhật: 2026-03-26
> **Trạng thái**: ✅ Round 1 Complete — P0 + P1 Resolved | P2 Deferred
> **Tổng câu hỏi**: 28 hot spots + 3 quyết định kiến trúc
> **Ambiguity Score**: 0.35 → **0.12** (dưới ngưỡng 0.20 → Gate G1 approved)

---

## Hướng dẫn sử dụng

- **[✅ DECIDED]** — Đã có quyết định, ghi rõ kết quả
- **[⏳ PENDING]** — Chờ review với stakeholder
- **[🔴 BLOCKER]** — Chặn design/dev nếu chưa giải quyết
- **[⭐ USP]** — Liên quan đến tính năng differentiator của xTalent

---

## PHẦN A — Kiến trúc & Quyết định nền tảng

> Những mục này KHÔNG phải hot spot nhưng là quyết định đã được identify trong quá trình research — cần confirm lại với stakeholder trước khi bước vào Step 2.

---

### A-01 — Vietnam SI Law 2024 là BLOCKER #1 🔴

**Bối cảnh**: Vietnam SI Law 2024 có hiệu lực từ tháng 7/2025 — chỉ còn ~3 tháng tính từ thời điểm planning. Nếu xTalent không implement đúng, doanh nghiệp sử dụng xTalent sẽ bị phạt **VND 50–100M mỗi vụ vi phạm**.

**Rates hiện tại đã xác định** (cần confirm lần cuối với Legal):

| Loại bảo hiểm | Employer | Employee | Cap tính SI |
|---------------|:--------:|:--------:|-------------|
| BHXH (Xã hội) | 17.5% | 8% | 20× lương tối thiểu vùng |
| BHYT (Y tế) | 3% | 1.5% | 20× lương tối thiểu vùng |
| BHTN (Thất nghiệp) | 1% | 1% | 20× lương tối thiểu vùng |

**Lương tối thiểu vùng hiện tại** (Decree 74/2024):

| Vùng | Mức lương tối thiểu/tháng | Tỉnh/TP tiêu biểu |
|------|:-------------------------:|-------------------|
| Vùng 1 | VND 4,680,000 | Hà Nội, TP.HCM |
| Vùng 2 | VND 4,160,000 | Hải Phòng, Đà Nẵng |
| Vùng 3 | VND 3,640,000 | Hầu hết tỉnh lớn |
| Vùng 4 | VND 3,250,000 | Tỉnh vùng sâu |

**Câu hỏi cần quyết định**:

> **A-01a**: Nhân viên xác định thuộc vùng lương nào — dựa trên **địa chỉ nơi làm việc** hay **địa chỉ cư trú**?
>
> | Option | Mô tả | Gợi ý |
> |--------|-------|-------|
> | A | Địa chỉ nơi làm việc (workplace location) | ⭐ **Khuyến nghị** — phổ biến nhất, đúng luật lao động VN |
> | B | Địa chỉ đăng ký hộ khẩu thường trú | Phức tạp hơn, không phổ biến |
> | C | Do HR cấu hình thủ công per employee | Linh hoạt nhưng dễ sai |
>
> **Quyết định**: option A địa chỉ nơi làm việc (workplace location)

> **A-01b**: Khi nhân viên đổi workplace giữa vùng (ví dụ từ HCM về tỉnh) — SI cap thay đổi từ tháng nào?
>
> | Option | Mô tả |
> |--------|-------|
> | A | Tháng tiếp theo sau ngày effective của working relationship change |
> | B | Tháng hiện tại luôn nếu effective trước ngày 15 |
> | C | Áp dụng ngay ngày effective (pro-rata trong tháng) |
>
> **Quyết định**: option A, tháng tiếp theo sau ngày effective của working relationship change, nguyên nhân vì các thông tin thay đổi chỉ báo tăng báo giảm vào cuối tháng nên áp dụng tháng tiếp theo sẽ hợp lý.

> **A-01c**: Khi lương cơ sở vượt 20× mức tối thiểu vùng — phần vượt có hiển thị rõ ràng trên payslip không?
>
> **Quyết định**: hiển thị rõ ràng trên payslip, giải pháp cần có khả năng để config việc hiển thị hay không hiển thị, và hiển thị ở đâu trên payslip.

**Stakeholder cần confirm**: Legal/Compliance + Vietnam HR Head
**Deadline**: Trước 2026-04-15

---

### A-02 — Config Scope Hierarchy (Đã implement, cần confirm strategy)

**Bối cảnh**: DBML TR V5 (26Mar2026) đã thêm `comp_core.config_scope` — abstraction để group country + legal entity + business unit thành named scope. Đây là kiến trúc **ĐÚNG HƯỚNG** cho multi-country.

**Approach đã design**:

```
Phase 1 (Light Touch — 1-3 quốc gia):
  → Dùng inline country_code + legal_entity_id trực tiếp trên definition tables
  → Đơn giản, backward compatible

Phase 2 (Config Scope Group — 5+ quốc gia):
  → Dùng config_scope_id thay cho inline fields
  → Hỗ trợ scope hierarchy + inheritance
  → Priority: GLOBAL(0) < COUNTRY(10) < LEGAL_ENTITY(20) < BUSINESS_UNIT(30)
```

**Câu hỏi cần quyết định**:

> **A-02a**: Phase 1 MVP — xTalent sẽ launch ở bao nhiêu quốc gia cùng lúc?
>
> | Option | Mô tả | Ảnh hưởng |
> |--------|-------|-----------|
> | A | Chỉ Vietnam trước (1 quốc gia) | Phase 1 inline đủ, Config Scope defer sang Phase 2 |
> | B | Vietnam + Singapore + Thailand (3 quốc gia) | Phase 1 inline vẫn đủ với một ít phức tạp hơn |
> | C | Cả 6 quốc gia từ đầu | Cần Config Scope ngay từ Phase 1 |
>
> **Quyết định**: giải pháp cần khả năng cấu hình dùng theo phương án nào, và có thể thay đổi trong tương lai.

> **A-02b**: Khi một doanh nghiệp có nhiều Legal Entity ở cùng quốc gia (VD: VNG Corp + VNG Cloud + VNG Singapore) — compensation rules có khác nhau giữa các entity không?
>
> | Option | Mô tả |
> |--------|-------|
> | A | Có — cần LE-level scoping (cần Config Scope Phase 2) |
> | B | Không — chỉ khác theo country (inline đủ) |
> | C | Tùy khách hàng — cần cả hai option |
>
> **Quyết định**: C tuỳ khách hàng.

**Stakeholder cần confirm**: Architecture Review Board + Product Owner
**Đây là quyết định kiến trúc, ảnh hưởng Phase 1 scope.**

---

### A-03 — 8 USP Innovation Features — Quyết định thứ tự launch ⭐

**Bối cảnh**: Đã identify 8 USP events là differentiators của xTalent so với Excel và legacy HRIS. Cần quyết định feature nào vào Phase nào.

| USP Event | Mô tả | Phase đề xuất | Cần quyết định? |
|-----------|-------|:-------------:|:---------------:|
| ⭐ `PayEquityGapDetected` | AI phát hiện chênh lệch lương theo giới tính/dân tộc | Phase 2 | Phương pháp thống kê nào? |
| ⭐ `AICompensationRecommended` | Gợi ý điều chỉnh lương từ AI | Phase 3 | Confidence threshold? |
| ⭐ `RealTimeCommissionCalculated` | Dashboard commission real-time | Phase 2 | Latency SLA? |
| ⭐ `FlexCreditAllocated` | Nhân viên tự phân bổ flex credit cho benefits | Phase 2 | Số lượng carriers tối thiểu? |
| ⭐ `SocialRecognitionPosted` | Peer-to-peer recognition public feed | Phase 2 | Content moderation policy? |
| ⭐ `AIRecognitionSuggested` | AI gợi ý khi nào và ai cần được ghi nhận | Phase 3 | — |
| ⭐ `TaxOptimizationRecommended` | AI gợi ý tối ưu thuế cho nhân viên | Phase 3 | Opt-in hay auto? |
| ⭐ `OfferCompetitivenessScored` | AI đánh giá mức độ cạnh tranh của offer | Phase 2 | Data source? |

**Câu hỏi**:

> **A-03a**: USP nào là **must-have** cho Phase 1 MVP (nếu thiếu khách hàng sẽ không mua)?
>
> **Gợi ý**: Không có USP nào là P0 cho Phase 1 thuần — MVP chỉ cần Core Compensation + SI compliance. USPs là selling point cho Phase 2.
>
> **Quyết định**: Không có USP nào là P0 cho Phase 1 thuần — MVP chỉ cần Core Compensation + SI compliance. USPs là selling point cho Phase 2.

> **A-03b**: `PayEquityGapDetected` — dùng phương pháp thống kê nào?
>
> | Option | Mô tả | Độ phức tạp |
> |--------|-------|:-----------:|
> | A | Compa-ratio comparison đơn giản (group average vs total average) | Thấp |
> | B | Regression analysis (control for job level, tenure, performance) | Trung bình |
> | C | Full statistical gap analysis (p-value, confidence interval per demographic) | Cao |
>
> **Quyết định**: cần support cả 3 option, tuỳ khách hàng; giải pháp cho phép cấu hình các phương án chạy -> có thể externalize ra thành plugins/engine để thực hiện.

> **A-03c**: `RealTimeCommissionCalculated` — latency SLA chấp nhận được?
>
> | Option | Mô tả |
> |--------|-------|
> | A | < 5 giây (near real-time) |
> | B | < 30 giây (sub-minute) |
> | C | 5-15 phút (micro-batch) |
>
> **Quyết định**: Chọn A, < 5 giây (near real-time).

**Stakeholder cần confirm**: Product Owner + Sales Ops (cho commission) + HRBP (cho pay equity)

---

## PHẦN B — P0 Hot Spots (Blocks Design)

> Không giải quyết 6 hot spots này → **không thể sign-off architecture**.

---

### H01 — Vietnam SI Law 2024 🔴 BLOCKER

*Liên quan: A-01 ở trên — xem chi tiết tại mục A-01.*

**Related events**: `SIContributionCalculated`, `SIContributionUpdated`
**Related questions**: Q01, Q06, Q07, Q13 (từ discovery questions)

**Câu hỏi bổ sung**:

> **H01a**: Ngoài VN, 5 quốc gia còn lại — SI/statutory contribution nào cần implement trong Phase 1?
>
> | Quốc gia | Statutory Contributions | Phức tạp | Đề xuất Phase |
> |----------|------------------------|:--------:|:-------------:|
> | Vietnam | BHXH/BHYT/BHTN (đã xác định) | Cao | Phase 1 |
> | Singapore | CPF (employee 20%, employer 17%, wage ceiling S$6K) | Trung bình | Phase 1 hoặc 2 |
> | Indonesia | BPJS (JKK, JKM, JHT, JP) | Cao | Phase 2 |
> | Malaysia | EPF + SOCSO + EIS | Trung bình | Phase 2 |
> | Philippines | SSS + PhilHealth + Pag-IBIG | Trung bình | Phase 2 |
> | Thailand | Social Security Fund (5% capped THB 750/month) | Thấp | Phase 2 |
>
> **Quyết định**: giải pháp cần cho phép cấu hình động để đáp ứng mọi quốc gia, không hardcode bất kỳ quốc gia nào. Tất cả các quy định này sẽ phải implement để có thể flexible và điều chỉnh, cấu hình dễ dàng theo quốc gia. Các HR SME sẽ được huy động để cấu hình các thông số này theo luật của từng quốc gia, vấn đề của giải pháp là cho phép việc này.

**Stakeholder**: Legal/Compliance + Country HR Heads
**Deadline**: 2026-04-15

---

### H02 — FX Rate Source 🔴 BLOCKER

**Vấn đề**: Compensation của 15K+ workers cần convert đa tiền tệ cho consolidated reporting. Nguồn tỷ giá không nhất quán → sai lệch P&L.

**Options**:

> **H02a**: Nguồn tỷ giá chính thức là gì?
>
> | Option | Mô tả | Pros | Cons |
> |--------|-------|------|------|
> | A | Ngân hàng Nhà nước Việt Nam (NHNN) | Chính thức cho VN entities | Chỉ có VND rates, không đầy đủ cho 6 nước |
> | B | Ngân hàng thương mại (VCB, DBS, CIMB...) | Thực tế hơn cho transactions | Khác nhau giữa các ngân hàng |
> | C | Reuters/OANDA/XE.com API | Standard market rate, tự động | Chi phí API license (~$5K-20K/năm) |
> | D | ECB + regional central banks per country | Chính thức theo từng nước | Cần aggregate từ nhiều nguồn |
>
> **Gợi ý**: Option C (Reuters/OANDA) là standard cho enterprise HCM (Workday, Oracle đều dùng). Cho Phase 1 VN-only có thể dùng NHNN.
>
> **Quyết định**: này cho phép cấu hình, chọn nguồn tỷ giá, tần suất update, xử lý khi tỷ giá thay đổi >5% trong một chu kỳ compensation. Có thể config một nguồn tỷ giá tự động hoặc có tính năng cho phép input vào chu kỳ lương.

> **H02b**: Tần suất update tỷ giá?
>
> | Option | Mô tả |
> |--------|-------|
> | A | Daily (cuối ngày giao dịch) |
> | B | Hourly |
> | C | Real-time (intraday) |
>
> **Gợi ý**: Daily là đủ cho payroll/compensation. Real-time chỉ cần nếu có forex trading feature.
>
> **Quyết định**: daily

> **H02c**: Khi tỷ giá thay đổi >5% trong một chu kỳ compensation — xử lý thế nào?
>
> | Option | Mô tả |
> |--------|-------|
> | A | Lock tỷ giá tại ngày mở cycle, không điều chỉnh |
> | B | Cập nhật tỷ giá, recompute consolidated report (không thay đổi local amount) |
> | C | Alert Finance, chờ manual decision |
>
> **Quyết định**: cho phép cấu hình workflow để xử lý; enterprise có thể chọn đơn giản lock tỷ giá hoặc update, hoặc alert Finance, chờ manual decision hoặc một quy trình kết hợp.

**Stakeholder**: Finance Director + Architecture Review Board

---

### H03 — Data Residency & Privacy 🔴 BLOCKER

**Vấn đề**: PDPA (Singapore, Malaysia), PDP Law Indonesia, Nghị định 13/2023 Vietnam về bảo vệ dữ liệu cá nhân — mỗi nước có quy định khác nhau về cross-border data transfer.

**Options**:

> **H03a**: Architecture deployment model?
>
> | Option | Mô tả | Pros | Cons |
> |--------|-------|------|------|
> | A | **Single region** (VD: Singapore) — tất cả nước dùng chung | Đơn giản, rẻ hơn | Vi phạm data residency VN/ID có thể |
> | B | **Multi-region** — mỗi quốc gia một regional deployment | Compliant hoàn toàn | Chi phí infra x3-6 lần |
> | C | **Hybrid** — PII ở region local, aggregated analytics ở central | Balance giữa compliance và cost | Phức tạp về architecture |
>
> **Gợi ý**: Option C là pragmatic nhất. PII/salary data ở local, anonymized metrics ở central dashboard.
>
> **Quyết định**: option C

> **H03b**: Dữ liệu nào được phép cross-border?
>
> | Data Category | Cross-border allowed? | Gợi ý |
> |---------------|:---------------------:|-------|
> | Họ tên, CMND/Passport | Không | Lưu local |
> | Mức lương tuyệt đối | Cần xác nhận Legal | Lưu local, chỉ gửi aggregate |
> | Grade/Level/Title | Có thể | Ít nhạy cảm hơn |
> | Percentage (% bonus) | Có thể | Không reveal exact amount |
> | Aggregated metrics (avg salary by grade) | Thường được phép | OK cho regional reporting |
>
> **Quyết định**: giải pháp cần cho phép cấu hình 
  . dữ liệu nào được phép cross-border, dữ liệu nào không được phép cross-border, 
  . dữ liệu nào được phép cross-border với điều kiện được mã hóa, 
  . dữ liệu nào được phép cross-border với điều kiện được ẩn danh, 
  . dữ liệu nào được phép cross-border với điều kiện được nén, 
  . dữ liệu nào được phép cross-border với điều kiện được mã hóa và ẩn danh và nén.

**Stakeholder**: Legal Counsel + IT Security + Architecture Review Board

---

### H04 — Tax Authority API Failure 🔴 BLOCKER

**Vấn đề**: Khi e-Filing API của Tổng cục Thuế (hoặc tương đương các nước) bị down vào ngày deadline cuối tháng → phạt nộp chậm lên đến 100% số thuế thiếu.

**Options**:

> **H04a**: Fallback mechanism khi Tax API down?
>
> | Option | Mô tả | Rủi ro |
> |--------|-------|--------|
> | A | **Manual file export** — generate XML/PDF, HR nộp tay qua web portal của thuế | Phụ thuộc người, dễ quên | Thấp nếu có process |
> | B | **Queue + retry** — lưu vào queue, retry mỗi 15 phút, alert sau 2 giờ | Tự động hơn | Vẫn có thể miss deadline |
> | C | **Dual-path** — vừa API vừa chuẩn bị file backup song song | An toàn nhất | Phức tạp hơn |
>
> **Gợi ý**: Option C cho Tax Authority quan trọng (VN, SG). Option B đủ cho countries ít critical hơn.
>
> **Quyết định**: option C

> **H04b**: SLA nội bộ khi Tax API down?
>
> | Option | Alert sau | Escalate sau | Trigger manual fallback sau |
> |--------|:---------:|:------------:|:---------------------------:|
> | A | 30 phút | 2 giờ | 4 giờ |
> | B | 1 giờ | 4 giờ | 8 giờ |
> | C | 15 phút | 1 giờ | 2 giờ |
>
> **Quyết định**: Option C

**Stakeholder**: Tax Administrator + Architecture Review Board

---

### H05 — Payroll Bridge Failure 🔴 BLOCKER

**Vấn đề**: Nếu bridge TR → Payroll fail trong pay cycle → nhân viên không nhận được lương đúng hạn → mất tin tưởng nghiêm trọng.

**Options**:

> **H05a**: Integration pattern giữa TR và Payroll?
>
> | Option | Mô tả | Pros | Cons |
> |--------|-------|------|------|
> | A | **Real-time API push** — TR push sang Payroll khi có thay đổi | Realtime | Tight coupling, single point of failure |
> | B | **Event-driven** — TR publish events, Payroll subscribe | Decoupled | Cần message broker (Kafka/RabbitMQ) |
> | C | **Batch file** — TR generate file (CSV/XML) theo schedule, Payroll pull | Đơn giản, proven | Latency, không real-time |
> | D | **Hybrid** — real-time cho critical changes, batch cho daily reconciliation | Best of both | Phức tạp nhất |
>
> **Gợi ý**: Option B hoặc D. Event-driven là direction đúng cho long-term; file batch là fallback.
>
> **Quyết định**: Option D

> **H05b**: Idempotency strategy?
>
> | Option | Mô tả |
> |--------|-------|
> | A | Idempotency key per transaction — duplicate safe |
> | B | Event deduplication window (15 phút) |
> | C | At-least-once delivery + idempotent receivers |
>
> **Gợi ý**: Option A + C là production-grade standard.
>
> **Quyết định**: A + B + C

> **H05c**: Maximum tolerable delay trước khi escalate?
>
> **Quyết định**: 15 phút

**Stakeholder**: Payroll Administrator + Architecture Review Board

---

### H06 — 4-Region Minimum Wage Validation Vietnam 🔴 BLOCKER

*(Đã cover phần lớn ở A-01 — xem thêm chi tiết)*

**Câu hỏi bổ sung**:

> **H06a**: Validation xảy ra ở bước nào?
>
> | Option | Mô tả |
> |--------|-------|
> | A | Chỉ validate khi **create/update salary** (soft block, warning) |
> | B | Validate khi **create offer** + **salary change** (hard block nếu dưới min) |
> | C | Validate cả lúc **tạo employee** nếu có salary component |
>
> **Gợi ý**: Option B là standard. Hard block để tránh compliance violations.
>
> **Quyết định**: option B

> **H06b**: Nếu lương < mức tối thiểu vùng — hệ thống xử lý thế nào?
>
> | Option | Mô tả |
> |--------|-------|
> | A | Block hoàn toàn, không cho save |
> | B | Warning + require approval exception |
> | C | Warning only, cho phép save với note |
>
> **Quyết định**: Cho phép cấu hình workflow xử lý

**Stakeholder**: Compliance + Vietnam HR Head + Architecture Review Board

---

## PHẦN C — P1 Hot Spots (Blocks Implementation)

---

### H07 — Proration (Partial Month Salary)

**Related question**: Q26

> **H07**: Phương thức tính pro-rata theo country?
>
> | Country | Option A (Calendar days) | Option B (Working days) | Option C (30-day fixed) | Gợi ý |
> |---------|:------------------------:|:-----------------------:|:-----------------------:|-------|
> | Vietnam | ✓ | ✓ | ✓ | Calendar days (phổ biến nhất) |
> | Singapore | ✓ | ✓ | | Working days (MOM guideline) |
> | Indonesia | | | ✓ | 30-day fixed (Manpower Act) |
> | Malaysia | ✓ | | | Calendar days |
> | Philippines | | ✓ | | Working days |
> | Thailand | ✓ | | | Calendar days |
>
> **Câu hỏi**: Có đồng ý với gợi ý trên không, hay cần điều chỉnh?
>
> **Quyết định**: giải pháp phải hỗ trợ tất cả các phương thức tính pro-rata, user chọn cấu hình tuỳ theo quyết định theo legal entity hay theo country.

**Stakeholder**: Payroll Admin + Country HR Heads

---

### H08 — Bonus Budget Pool Reallocation

> **H08**: Sau khi compensation cycle mở, manager có thể reallocate unspent budget không?
>
> | Option | Mô tả |
> |--------|-------|
> | A | **Không** — budget locked khi cycle mở |
> | B | **Có, tự do** — manager tự reallocate trong team |
> | C | **Có, có kiểm soát** — cần approval từ cấp trên (Department Head/Finance) |
>
> Nếu chọn C — approval threshold: _______________
>
> **Quyết định**: cấu hình workflow để đáp ứng cả 3 option, tuỳ theo yêu cầu của enterprise

**Stakeholder**: Product Owner + HR Director

---

### H09 — Commission Dispute Resolution

> **H09a**: Khi sales rep dispute commission — xử lý phần bị dispute thế nào?
>
> | Option | Mô tả |
> |--------|-------|
> | A | Freeze **toàn bộ** commission của tháng đó đến khi giải quyết |
> | B | Freeze **chỉ phần bị dispute**, trả phần không bị dispute ngay |
> | C | Trả toàn bộ trước, điều chỉnh tháng sau nếu dispute thắng |
>
> **Gợi ý**: Option B là best practice (không ảnh hưởng đến phần không tranh chấp).
>
> **Quyết định**: chọn option B, nhưng giải pháp cần cho phép cấu hình tuỳ theo enterprise

> **H09b**: SLA resolution cho dispute?
>
> | Option | SLA |
> |--------|-----|
> | A | 7 ngày làm việc |
> | B | 14 ngày làm việc |
> | C | 30 ngày |
>
> **Quyết định**: giải pháp cho phép cấu hình SLA resolution cho dispute

**Stakeholder**: Sales Operations Manager + Finance

---

### H10 — 13th Month Pro-rata

> **H10**: Eligibility và cách tính 13th month?
>
> **Vietnam (Tết bonus — không bắt buộc luật, nhưng thị trường expectation)**:
>
> | Option | Tính toán |
> |--------|-----------|
> | A | `(Lương tháng × Số tháng làm việc trong năm) / 12` |
> | B | Full 1 tháng nếu làm đủ 12 tháng; pro-rata nếu dưới 12 tháng |
> | C | Tùy chính sách từng doanh nghiệp (configurable) |
>
> **Gợi ý**: Option C — vì Tết bonus không bắt buộc theo luật VN, nên linh hoạt theo policy.
>
> **Philippines (PD 851 — bắt buộc)**:
> - Bắt buộc: `(BasicSalary × Months Worked) / 12`
> - Tối thiểu 1 tháng làm việc để được pro-rata
>
> **Quyết định VN**: phải có tính năng cấu hình, chọn các rule/engine/plugin tuỳ theo enterprise | **Philippines**: PD 851 (confirm) -> xem như 1 rule để chọn

**Stakeholder**: Compliance + Country HR Heads

---

### H11 — Benefits Carrier Sync Failure

> **H11a**: Khi carrier từ chối enrollment file (format error, duplicate) — xử lý thế nào?
>
> | Option | Mô tả |
> |--------|-------|
> | A | Auto-retry 3 lần, sau đó alert HR Admin |
> | B | Alert ngay, chờ HR manual fix và resubmit |
> | C | Auto-fix common errors (trailing spaces, format), retry once |
>
> **Gợi ý**: Option A + C — tự động fix common errors trước, retry, rồi alert.
>
> **Quyết định**: cho phép cấu hình cả 3 option

> **H11b**: Coverage gap liability trong thời gian carrier processing?
>
> | Option | Policy |
> |--------|--------|
> | A | Coverage effective từ ngày enrollment submit (không phải ngày carrier confirm) |
> | B | Coverage effective từ ngày carrier confirm — employee chịu gap |
> | C | Retroactive coverage sau khi carrier confirm |
>
> **Quyết định**: cho phép cấu hình cả 3 option

**Stakeholder**: Benefits Administrator + Legal

---

### H12 — Tax Bracket Versioning Mid-year

> **H12**: Khi tax bracket thay đổi giữa năm (ví dụ VN PIT bracket thay đổi từ tháng 7) — nhân viên đã làm việc dưới cả bracket cũ và mới?
>
> | Option | Cách tính |
> |--------|-----------|
> | A | **Split calculation** — tính 6 tháng đầu theo bracket cũ, 6 tháng sau theo bracket mới |
> | B | **Effective date** — áp dụng bracket mới từ tháng hiệu lực trở đi |
> | C | **Annualization** — estimate annual income, tính tax rate, apply đều các tháng |
>
> **Gợi ý**: Option B là đơn giản nhất và phổ biến. Cần có SCD Type 2 cho tax bracket.
>
> **Quyết định**: cho phép cấu hình cả 3 option, nguyên nhân là vì mỗi quốc gia có quy định khác nhau, và mỗi enterprise có thể có quy định khác nhau; 

**Stakeholder**: Tax Administrator + Compliance

---

### H13 — Social Recognition Feed Content Moderation ⭐ USP

> **H13a**: Policy moderation cho recognition posts?
>
> | Option | Mô tả | Pros | Cons |
> |--------|-------|------|------|
> | A | **Auto-approve** — post ngay, AI moderation detect sau | Nhanh, frictionless | Risktừ nội dung xấu thoáng qua |
> | B | **Human review** — mọi post phải HR approve trước khi publish | An toàn | Chậm, giết UX |
> | C | **Hybrid** — auto-approve từ trusted senders, flag suspicious content cho review | Balance | Cần định nghĩa "trusted" |
>
> **Gợi ý**: Option A với AI toxicity filter + report button là standard (LinkedIn, Workday). Option C nếu muốn thận trọng hơn.
>
> **Quyết định**: cho phép cấu hình tuỳ theo enterprise.

> **H13b**: SLA xử lý reported content?
>
> | Option | SLA |
> |--------|-----|
> | A | < 2 giờ trong giờ hành chính |
> | B | < 24 giờ |
> | C | < 4 giờ mọi lúc |
>
> **Quyết định**: cho phép cấu hình tuỳ theo enterprise

**Stakeholder**: Product Owner + Legal + HRBP

---

### H14 — Compa-Ratio Visibility cho Manager ⭐ USP (PayEquity)

> **H14**: Manager có được xem compa-ratio distribution của team khi làm compensation worksheet?
>
> | Option | Mô tả |
> |--------|-------|
> | A | **Không** — chỉ HR/Compensation Manager thấy |
> | B | **Có, đầy đủ** — manager thấy từng người trong team |
> | C | **Có, ẩn danh** — manager thấy distribution chart nhưng không thấy tên cụ thể |
> | D | **Configurable** — doanh nghiệp tự set policy |
>
> **Gợi ý**: Option D để linh hoạt cho từng khách hàng. Default = Option C.
>
> **Quyết định**: Option D

**Stakeholder**: Product Owner + HRBP + Compensation Manager

---

### H15 — AI Compensation Advisor Cold Start ⭐ USP

> **H15**: AI có đủ data cho new employees (< 6 tháng)?
>
> | Option | Xử lý |
> |--------|-------|
> | A | Không hiển thị recommendation — chỉ show khi có đủ data |
> | B | Dùng market benchmark data thay cho historical employee data |
> | C | Flag as "limited data" recommendation, show với disclaimer |
>
> **Gợi ý**: Option B + C — dùng market data fallback, label rõ ràng.
>
> **Quyết định**: option B + C

> **H15b**: Minimum data points để AI show recommendation?
>
> | Option | Threshold |
> |--------|-----------|
> | A | ≥ 30 comparable employees trong same grade/country |
> | B | ≥ 15 comparable employees |
> | C | ≥ 1 market benchmark data point (always show) |
>
> **Quyết định**: C

**Stakeholder**: Product Owner + Architecture Review Board (AI/ML)

---

### H16 — Real-time Commission Dashboard Performance ⭐ USP

> **H16**: Acceptable latency cho commission dashboard?
>
> | Option | Latency | Technical approach |
> |--------|:-------:|-------------------|
> | A | < 5 giây | Streaming (Kafka + materialized view) |
> | B | < 30 giây | Micro-batch + cache |
> | C | 5-15 phút | Scheduled batch |
>
> **Gợi ý**: Option B cho Phase 2 MVP (ít phức tạp hơn A). Option A khi scale lên 500+ reps.
>
> **Scale estimate**: 200 reps × 10K transactions/month = 200K events/month → manageable với micro-batch.
>
> **Quyết định**: option A

**Stakeholder**: Sales Operations Manager + Architecture Review Board

---

### H17 — Offer Letter E-Signature Failure

> **H17**: Khi e-signature callback fail (DocuSign/Adobe webhook unreliable)?
>
> | Option | Mô tả |
> |--------|-------|
> | A | Poll signature status mỗi 15 phút, update tự động |
> | B | Alert HR sau 24 giờ không nhận được callback |
> | C | Dual confirm — webhook + scheduled polling as fallback |
>
> **Gợi ý**: Option C là robust nhất (webhook primary, polling fallback).
>
> **Quyết định**: Option C

> **H17b**: Provider e-signature ưu tiên?
>
> | Option | Provider | Chi phí ước tính |
> |--------|----------|:----------------:|
> | A | DocuSign | Cao (~$30/user/tháng) |
> | B | Adobe Sign | Trung bình |
> | C | Signify / regional provider | Thấp hơn |
> | D | Tự build (PDF + OTP confirmation) | Thấp nhưng không có legal weight |
>
> **Quyết định**: cho phép cấu hình và tích hợp

**Stakeholder**: Talent Acquisition + Legal + Architecture Review Board

---

### H18 — Dependent Eligibility Verification

> **H18**: Verification process cho dependents (vợ/chồng, con) khi enroll health insurance?
>
> | Option | Mô tả |
> |--------|-------|
> | A | **Auto-approve** — employee self-declare, document upload không bắt buộc |
> | B | **Document required** — phải upload hôn thú/birth cert, HR verify trong 48h |
> | C | **Carrier verification** — send to carrier, họ verify và confirm coverage |
>
> **Gợi ý**: Option B là balance giữa compliance và UX. Auto-approve (A) rủi ro carrier từ chối khi audit.
>
> **Quyết định**: cho phép cấu hình như workflow tuỳ theo enterprise/country/legal entity

**Stakeholder**: Benefits Administrator + Compliance

---

## PHẦN D — P2 Hot Spots (Nice to Clarify)

> Có thể quyết định trong quá trình implementation. Ghi nhận để không bị bỏ sót.

---

| ID | Hot Spot | Options tóm tắt | Gợi ý | Quyết định |
|----|----------|-----------------|-------|------------|
| **H19** | Manager compensation literacy tooltips | A: Không; B: Show market rate; C: Show compa-ratio + market | C là giá trị nhất cho manager | ___ |
| **H20** | Employee bonus simulation | A: Không cho phép; B: Cho phép read-only what-if | B với disclaimer "ước tính, không cam kết" | ___ |
| **H21** | Recognition point expiration | A: 12 tháng; B: 24 tháng; C: Không hết hạn | 12 tháng (FIFO) — tạo urgency để redeem | ___ |
| **H22** | TR Statement frequency | A: Chỉ hàng năm; B: On-demand; C: Sau mỗi comp event | B — on-demand + annual auto là tốt nhất | ___ |
| **H23** | Multi-language support | A: EN only; B: EN + VI; C: Cả 6 ngôn ngữ SEA | B cho Phase 1, C cho Phase 3 | ___ |
| **H24** | Notification channels | A: Email only; B: Email + In-app; C: All channels | B cho Phase 1, C sau | ___ |
| **H25** | Market benchmarking integration | A: Manual upload; B: Radford/Mercer API | A trước, B khi có budget | ___ |
| **H26** | Off-cycle bonus workflow | A: Same as cycle (strict); B: Simplified fast track | B — spot bonus cần nhanh để có tác dụng | ___ |
| **H27** | Tax optimization opt-in ⭐ | A: Auto-enable; B: Explicit opt-in | B — opt-in tránh regulatory risk (financial advice) | ___ |
| **H28** | Audit log > 7 years | A: Delete sau 7 năm; B: Indefinite for exec comp | B cho executive comp, A cho regular | ___ |

---

## PHẦN E — Tracking Quyết định

> Round 1 (2026-03-26): Tất cả P0 + P1 đã có quyết định. P2 defer to implementation.

| ID | Câu hỏi | Ngày review | Quyết định tóm tắt | Status |
|----|---------|:-----------:|--------------------|:------:|
| A-01a | Vietnam vùng lương theo workplace | 2026-03-26 | **Workplace location** (nơi làm việc) | ✅ |
| A-01b | Timing thay đổi SI cap | 2026-03-26 | **Tháng tiếp theo** sau effective date working rel. change | ✅ |
| A-01c | Hiển thị SI cap trên payslip | 2026-03-26 | **Hiển thị rõ, configurable** vị trí/format | ✅ |
| A-02a | Số quốc gia Phase 1 | 2026-03-26 | **Configurable phased approach** — platform tự handle | ✅ |
| A-02b | LE-level scoping cần thiết? | 2026-03-26 | **Option C**: tùy khách hàng — cần cả hai | ✅ |
| A-03a | USP nào vào Phase 1 MVP | 2026-03-26 | **Không có** — MVP = Core Comp + SI compliance | ✅ |
| A-03b | Pay equity method | 2026-03-26 | **Hỗ trợ cả 3** (plugin-based, configurable) | ✅ |
| A-03c | Commission dashboard latency | 2026-03-26 | **< 5 giây** (near real-time, Kafka streaming) | ✅ |
| H01a | Statutory contribution strategy | 2026-03-26 | **Configurable engine** — không hardcode quốc gia nào | ✅ |
| H02a | FX rate source | 2026-03-26 | **Configurable** (auto API hoặc manual input per cycle) | ✅ |
| H02b | FX update frequency | 2026-03-26 | **Daily** | ✅ |
| H02c | FX change >5% handling | 2026-03-26 | **Configurable workflow** (lock/recompute/alert) | ✅ |
| H03a | Deployment model | 2026-03-26 | **Hybrid (C)**: PII local + analytics central | ✅ |
| H03b | Cross-border data policy | 2026-03-26 | **Configurable per field** (plain/encrypted/anon/compressed) | ✅ |
| H04a | Tax API fallback mechanism | 2026-03-26 | **Dual-path (C)**: API + file song song | ✅ |
| H04b | Tax API SLA | 2026-03-26 | **Alert 15min → Escalate 1h → Fallback 2h** | ✅ |
| H05a | TR-Payroll integration pattern | 2026-03-26 | **Hybrid (D)**: events + daily batch reconciliation | ✅ |
| H05b | Idempotency strategy | 2026-03-26 | **A+B+C combined**: key + dedup window + at-least-once | ✅ |
| H05c | Max tolerable delay | 2026-03-26 | **15 phút** | ✅ |
| H06a | Minimum wage validation trigger | 2026-03-26 | **Option B**: create offer + salary change (hard validate) | ✅ |
| H06b | Salary below min wage handling | 2026-03-26 | **Configurable workflow** per enterprise | ✅ |
| H07 | Proration method per country | 2026-03-26 | **Configurable** per country/LE (all methods supported) | ✅ |
| H08 | Budget pool reallocation | 2026-03-26 | **Configurable workflow** (locked/self-service/approval) | ✅ |
| H09a | Commission dispute freeze | 2026-03-26 | **Default: freeze partial only.** Configurable per enterprise | ✅ |
| H09b | Dispute SLA | 2026-03-26 | **Configurable SLA** per enterprise | ✅ |
| H10 | 13th month calculation | 2026-03-26 | **Configurable rules/plugins** (VN flexible, PH = PD 851 rule) | ✅ |
| H11a | Carrier sync failure | 2026-03-26 | **Configurable** (auto-fix/retry/alert combination) | ✅ |
| H11b | Coverage effective date | 2026-03-26 | **Configurable** per enterprise/carrier | ✅ |
| H12 | Tax bracket mid-year versioning | 2026-03-26 | **Configurable**: split/effective-date/annualization | ✅ |
| H13a | Recognition moderation | 2026-03-26 | **Configurable** per enterprise | ✅ |
| H13b | Moderation SLA | 2026-03-26 | **Configurable** per enterprise | ✅ |
| H14 | Compa-ratio visibility | 2026-03-26 | **Configurable (D)**, default = anonymous distribution | ✅ |
| H15 | AI cold start handling | 2026-03-26 | **B+C**: Market benchmark fallback + disclaimer | ✅ |
| H15b | AI minimum data threshold | 2026-03-26 | **Option C**: ≥ 1 market data point (always show) | ✅ |
| H16 | Commission dashboard latency | 2026-03-26 | **< 5 giây** (Kafka streaming required) | ✅ |
| H17 | E-signature callback failure | 2026-03-26 | **Dual confirm (C)**: webhook + 15-min polling fallback | ✅ |
| H17b | E-signature provider | 2026-03-26 | **Configurable + integrable** (multi-provider) | ✅ |
| H18 | Dependent verification | 2026-03-26 | **Configurable workflow** per enterprise/country/LE | ✅ |
| H19-H28 | P2 items | — | Defer to implementation phase (gợi ý mặc định đã có) | ⏳ |

---

## Ambiguity Score Tracker

| Milestone | Ambiguity Score | Status |
|-----------|:--------------:|:------:|
| Trước review (v1.0) | **0.35** | — |
| Sau Round 1 — P0+P1 resolved (v1.1) | **0.12** | ✅ CURRENT |
| Sau P2 resolved (nếu cần) | ~0.08 | ⏳ Defer |
| **Target để proceed to Step 2** | **≤ 0.20** | ✅ **ĐÃ ĐẠT** |

**Gate G1: APPROVED** — Sẵn sàng chạy `/odsa reality` (Step 2).

---

*Tài liệu này sẽ được cập nhật sau mỗi stakeholder interview session. Khi tất cả P0 và P1 đã có quyết định → proceed to `/odsa reality` (Step 2).*

*Phiên bản: 1.0.0 — 2026-03-26*

Lưu ý chúng ta đang xây dựng giải pháp, không phải cấu hình giải pháp cho 1 khách hàng cụ thể; nên câu trả lời hợp lý nhất cho tất cả các câu hỏi ở đây là chúng ta đáp ứng toàn bộ thông qua việc cấu hình/ workflow/plugin/engine/... 
