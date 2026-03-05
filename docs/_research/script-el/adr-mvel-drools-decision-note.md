# ADR Note: Quyết Định Chọn MVEL + Drools 8 cho Payroll Engine

> **Loại tài liệu:** Architecture Decision Note  
> **Module:** Payroll Engine — xTalent HCM  
> **Ngày:** 2026-03-05  
> **Trạng thái:** ADOPTED  
> **Tham chiếu:** `01-problem-statement.md` · `02-detailed-analysis.md` · `03-proposal.md` · `sample-payroll/`

---

## Quyết Định

**Adopt Hybrid Architecture H4:**  
**Drools 8 (Rule Orchestration) + MVEL (Formula DSL) + Business DSL Layer (HR-facing)**  
Weighted KPI Score: **4.30 / 5** — cao nhất trong tất cả 11 candidates và 4 hybrid architectures được phân tích.

---

## I. Lý Do Kỹ Thuật & Kiến Trúc

### 1. Rule Orchestration là yêu cầu bắt buộc — không thể giải quyết bằng expression engine đơn thuần

- Payroll VN không phải "áp công thức đơn lẻ" mà là **dependency graph 12–18 nodes** cần thực thi đúng thứ tự, phát hiện circular dependency, và re-evaluate incremental khi facts thay đổi.
- **Drools là BRMS duy nhất** trong 11 candidates có đủ cả ba thành phần: Working Memory · Forward Chaining · Conflict Resolution — không cần tự xây orchestration layer.
- **Rete/Phreak algorithm** đảm bảo incremental evaluation: chỉ re-evaluate rule khi fact liên quan thay đổi. Trực tiếp đáp ứng SLA batch 10,000 nhân viên < 5 phút.

### 2. Intermediate Fact Insertion — yêu cầu kiến trúc xuất hiện từ sample data

- Bài toán **hazard tax split** (phụ cấp độc hại y tế) đòi hỏi tách 1 element thành 2 sub-facts (`HAZARD_TAX_EXEMPT` + `HAZARD_TAXABLE`) với tax treatment khác nhau, trước khi tính GROSS và TAXABLE_INCOME.
- **Chỉ Drools** có cơ chế `insert()` intermediate facts vào working memory giữa các rule chains. Expression engine (JEXL, CEL, SpEL) không thể làm điều này mà không cần build thêm một state-management layer riêng.
- Tương tự với pre-processing rule đếm `nightShiftCount` từ lịch ca tháng — cần chạy trước toàn bộ calculation stage, Drools giải quyết qua `agenda-group` + `salience`.

### 3. MVEL là native dialect của Drools — không phải integration rời rạc

- MVEL là **default dialect**; Rete network được optimize nội tại cho MVEL expressions, compilation được cache, expression dependency được engine hiểu trực tiếp.
- **Compiled bytecode mode**: formula chỉ compile một lần khi chuyển trạng thái DRAFT → APPROVED; mọi lần chạy production reuse bytecode đã compiled → latency ≈ native Java.
- **BigDecimal arithmetic native**: MVEL handle `BigDecimal` tự nhiên — bắt buộc cho financial systems vì `double` / `float` gây sai số tiền tệ không được phép trong payroll.
- `progressiveTax()` (7 bậc lũy tiến) phải là `BuiltinFunction` được whitelist — MVEL cho phép đăng ký custom function tường minh và an toàn, không cần inline loop (bị cấm bởi DSL grammar restriction).

### 4. Security Model đạt được qua 5 lớp kiểm soát

- **Layer 1 — ANTLR Grammar**: Chỉ allow arithmetic, comparison, `when/then/else`, whitelisted functions. "Runtime", "exec", import statements bị reject ngay lúc parse.
- **Layer 2 — MVEL Class Whitelist**: `ParserContext` chỉ expose `BigDecimal`, `Math`, `BuiltinFunctions` — không có JVM class nào khác accessible.
- **Layer 3 — Offline Compile**: Formula compile khi APPROVED, không compile từ user input at runtime — loại bỏ runtime injection surface.
- **Layer 4 — ClassLoader Isolation**: Custom ClassLoader không expose `java.lang.Runtime` hay reflection.
- **Layer 5 — Finance Lead Approval**: Formula không active được nếu chưa qua approval workflow.
- Pattern này đã được **Oracle HCM Fast Formula** và **SAP ECP** áp dụng thành công ở enterprise scale.

---

## II. Lý Do Versioning & Rule Lifecycle

### 5. Formula Versioning là bắt buộc — không phải optional feature

- Mỗi `PayrollFormula` có `version`, `effectiveDate`, `status` (DRAFT → REVIEWED → APPROVED → ACTIVE → DEPRECATED). Formula ACTIVE không được sửa trực tiếp — phải tạo version mới.
- **Drools Rule Units** cho phép load đúng version formula set ứng với kỳ tính lương. Engine nhận vào `formulaVersionSnapshot: Map<elementCode, versionId>` tại thời điểm khởi tạo `KieSession`.
- **Version comparison**: Khi tạo version mới, hệ thống có thể diff `dslSource` (Business DSL) giữa các version → hiển thị thay đổi rõ ràng cho Finance Lead review trước khi approve. Drools rule files được quản lý trong Git, linked với formula version ID → toàn bộ change history traceable.

### 6. Retroactive Calculation đòi hỏi đúng rule version tại thời điểm đó

- Khi lương tháng 1 cần tính lại (do phát hiện sai, hoặc nâng lương hồi tố), engine **phải dùng đúng formula version đang ACTIVE tại tháng 1**, không phải version hiện tại.
- Drools architecture cho phép load `KieBase` với bộ rule cụ thể theo version snapshot, isolated hoàn toàn với production session đang chạy cho tháng hiện tại.
- **Immutable result store**: Kết quả của mỗi lần tính được lưu kèm `formulaVersionSnapshot` + `resultHash` (SHA-256) → có thể verify bất kỳ lúc nào rằng kết quả đó được tính bởi đúng version rule nào, với input gì.
- Nếu dùng custom rule engine tự xây, toàn bộ cơ chế này phải implement từ đầu: version loading, isolation between sessions, snapshot management — effort rất cao và error-prone.

### 7. Custom Rule Engine là rủi ro không đáng chấp nhận

- Xây custom engine = tự implement: dependency resolution (topological sort), working memory, forward chaining, agenda control, conflict resolution, version isolation, dry-run mode, session management, concurrency safety — **tương đương rebuild Drools từ đầu, không có battle-tested codebase, không có community**.
- Drools đã được validate qua hàng thập kỷ trong insurance, banking, healthcare payroll — những domain có độ phức tạp tương đương hoặc cao hơn payroll VN.
- Mọi bug trong custom engine là **payroll bug** — ảnh hưởng trực tiếp đến thu nhập nhân viên và compliance pháp lý.
- Fallback strategy đã thiết kế sẵn: nếu Drools gặp vấn đề nghiêm trọng, **Kogito** (cloud-native evolution của Drools, tương thích DRL/DMN) có thể migrate trong ~2 sprint mà không thay đổi business rules.

---

## III. Phân Tích Đối Chiếu: SpEL + Temporal Workflow

### Kiến Trúc SpEL + Temporal

```
[HR Formula] → [SpEL Expression Evaluator] → [Temporal Workflow Orchestration]
                    (formula eval)                  (staging, retry, audit)
```

**Temporal** là durable workflow engine (durable execution model), thiết kế cho long-running workflows với retry, timeout, và deterministic replay. Kết hợp với SpEL để evaluate formula.

---

### ✅ PROS của SpEL + Temporal

| # | Ưu điểm | Chi tiết |
|---|---------|---------|
| P1 | **Workflow versioning native** | `Workflow.getVersion()` API của Temporal cho phép branch logic theo version ngay trong workflow code. Retroactive calculation có thể chỉ định chạy version cụ thể. |
| P2 | **Audit trail qua Workflow History** | Temporal lưu toàn bộ event history của mỗi workflow execution — mỗi activity input/output đều được persist. Đây là audit log tự nhiên không cần implement riêng. |
| P3 | **Durable execution + retry** | Nếu một bước tính lương fail (DB timeout, service down), Temporal tự retry từ đúng checkpoint. Drools batch cần tự xây retry mechanism. |
| P4 | **Fault tolerance** | Workflow state được persist vào Temporal Server — server restart không mất trạng thái giữa chừng. Phù hợp cho long-running batch. |
| P5 | **Spring ecosystem fit** | SpEL tích hợp sâu vào Spring — nếu codebase đã full Spring, không cần thêm Drools dependency. |
| P6 | **Horizontal scaling** | Temporal Workers scale ngang tự nhiên — thêm worker = tăng throughput batch không cần refactor. |

---

### ❌ CONS của SpEL + Temporal — Lý Do Không Chọn

| # | Nhược điểm | Mức độ | Chi tiết |
|---|-----------|--------|---------|
| C1 | **SpEL không có working memory** | 🔴 Blocker | Mỗi SpEL expression chỉ evaluate một biểu thức đơn lẻ — không có state giữa các bước. `HAZARD_TAX_EXEMPT` → `TAXABLE_INCOME` chain cần lưu intermediate result; phải build state object riêng truyền qua Temporal activity context. |
| C2 | **Dependency ordering phải tự xây** | 🔴 Blocker | Temporal orchestrates workflow steps, không tự resolve dependency giữa payroll elements. Topological sort, circular dependency detection, conditional dependencies phải implement bằng tay trong workflow code — tái phát minh lõi của Drools. |
| C3 | **SpEL security model yếu** | 🔴 Blocker | `StandardEvaluationContext` expose toàn bộ Java reflection. `SimpleEvaluationContext` restrict nhưng vẫn không có sandbox cấp class whitelist như MVEL. Không có ANTLR grammar layer. Risk injection nếu HR nhập formula trực tiếp. |
| C4 | **Temporal overhead không phù hợp batch** | 🟠 Cao | Mỗi Temporal Activity là một network round-trip đến Temporal Server (gRPC). Với dependency chain 18 nodes × 10,000 employees = 180,000 activity calls → latency không thể đạt SLA 5 phút. Temporal tối ưu cho workflow duration theo giờ/ngày, không phải millisecond per-formula. |
| C5 | **Workflow = Java/Go code — không phải formula** | 🟠 Cao | Workflow logic viết trong Java/Go — HR users không thể tự cấu hình. Mất hoàn toàn mục tiêu "Business User tự authoring formula" (BR-001, BR-002). Mọi thay đổi công thức đều cần developer viết code và deploy workflow mới. |
| C6 | **Conflict resolution không có** | 🟠 Cao | Khi policy công ty vs policy cá nhân cùng ảnh hưởng một element, Temporal không có cơ chế conflict resolution — phải code if/else thủ công trong workflow activity. |
| C7 | **Temporal là infrastructure phức tạp** | 🟡 Trung bình | Temporal Server cần maintain riêng (hoặc dùng Temporal Cloud — paid). Thêm dependency infrastructure ngoài engine itself. Drools chạy in-process, không cần external server. |
| C8 | **Versioning ở workflow level, không phải formula level** | 🟡 Trung bình | `Workflow.getVersion()` version cả workflow, không version từng formula element riêng lẻ. Retroactive calc cho 1 element cụ thể thay đổi version cần custom mapping phức tạp. Drools version từng formula element độc lập, granular hơn. |
| C9 | **Không có Rule Unit / Country Module** | 🟡 Trung bình | Không có cơ chế tổ chức rules theo country như Drools Rule Units. Global payroll multi-country sẽ cần tự build routing + isolation logic trong workflow code. |

---

### Tổng Hợp So Sánh

| Tiêu chí | MVEL + Drools | SpEL + Temporal |
|---------|:---:|:---:|
| Rule Orchestration (working memory, chaining) | ✅ Native | ❌ Phải tự xây |
| Intermediate fact computation | ✅ Native (`insert()`) | ❌ Cần state object workaround |
| Security sandbox | ✅ 5-layer defense | ⚠️ Yếu (SimpleEvaluationContext) |
| Formula granular versioning | ✅ Element-level | ⚠️ Workflow-level (coarse) |
| Retroactive với exact version | ✅ KieBase snapshot | ✅ Workflow versioning (nhưng coarse) |
| Batch throughput 10K employees | ✅ In-process, fast | ❌ Network per-activity overhead |
| Business user authoring | ⚠️ Cần DSL layer thêm | ❌ Không thể (Java/Go code) |
| Audit trail | ✅ Rule firing log | ✅ Workflow event history |
| Durable execution / retry | ⚠️ Cần tự xây | ✅ Native |
| Infrastructure overhead | ✅ Thấp (in-process) | ⚠️ Cao (Temporal Server) |
| Global payroll extensibility | ✅ Rule Units | ❌ Cần tự build routing |

**Nhận xét:** SpEL + Temporal mạnh ở fault-tolerance và workflow versioning, nhưng thất bại ở 3 điểm không thể thỏa hiệp: (1) không có working memory cho intermediate computation, (2) batch throughput không đạt SLA do network overhead, (3) HR users không thể tự authoring — mất đi giá trị cốt lõi của hệ thống.

---

## IV. Kết Luận

> **MVEL + Drools 8 là lựa chọn duy nhất đáp ứng đồng thời 6 yêu cầu không thể thỏa hiệp:**
>
> 1. **Dependency chain management** — Rete/Phreak, topological sort tự động
> 2. **Intermediate fact computation** — Working memory, `insert()` native
> 3. **Partial tax exemption logic** — Multi-node split (hazard case)
> 4. **Formula version isolation** — Element-level versioning, KieBase snapshot per period
> 5. **Retroactive recalculation bằng đúng rule version** — Load exact formula snapshot
> 6. **Performance SLA** — In-process, bytecode compiled, không có network overhead
>
> SpEL + Temporal giải quyết tốt fault-tolerance và audit trail, nhưng không giải quyết được orchestration, intermediate state, và throughput — ba vấn đề core của bài toán payroll.
>
> Custom rule engine: **không khuyến nghị** — effort tương đương rebuild Drools, không có battle-tested foundation, mọi bug là payroll correctness bug.

---

*Tài liệu liên quan: `01-problem-statement.md` · `02-detailed-analysis.md` · `03-proposal.md` · `sample-payroll/formulas/dependency-chain.md`*
