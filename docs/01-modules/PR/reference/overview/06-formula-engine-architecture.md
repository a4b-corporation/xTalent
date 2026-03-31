# Formula Engine Architecture — Kiến trúc Kỹ thuật

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-06  
**Đối tượng**: Developer, Architect, Tech Lead  
**Thời gian đọc**: ~25 phút

---

## Tổng quan

Đây là tài liệu kiến trúc cho công nghệ **trái tim** của PR module — hệ thống thực thi tính lương. Sau khi phân tích 11 scripting engine candidates và 4 hybrid architectures với 8 KPIs có trọng số, xTalent Payroll Engine được xây dựng trên kiến trúc **H4: Drools 8 + Restricted MVEL + Business DSL Layer** với weighted score **4.30/5**.

---

## 1. Tại sao cần Formula Engine riêng?

### Expression Engine đơn thuần không đủ

Expression engines như JEXL, SpEL, CEL chỉ giải quyết "tính một công thức đơn lẻ". Payroll thực sự cần:

```
Bài toán Expression Engine: result = baseSalary * 0.08    ← Đơn giản

Bài toán Payroll thực tế:
  1. ATTENDANCE_DAYS  ← từ T&A import
  2. GROSS_SALARY     ← phụ thuộc ATTENDANCE_DAYS + BASE + ALLOWANCES
  3. BHXH_BASE        ← min(GROSS, ceiling)
  4. BHXH_EMP         ← phụ thuộc BHXH_BASE
  5. TAXABLE_INCOME   ← phụ thuộc GROSS − BHXH − DEDUCTIONS
  6. PIT_TAX          ← progressiveTax(TAXABLE_INCOME, 7-bracket table)
  7. NET_SALARY       ← GROSS − tổng khấu trừ
```

Đây là **dependency graph 12–18 nodes** cần: Working Memory, Forward Chaining, Dependency Resolution, Conflict Resolution — không thể đơn giản dùng expression engine.

### Tại sao không Custom Rule Engine?

Tự xây custom engine = phải implement từ đầu: topological sort, working memory, forward chaining, agenda control, conflict resolution, version isolation, dry-run mode, session management, concurrency safety — **tương đương rebuild Drools từ đầu**.

Mọi bug trong custom engine là **payroll bug** — ảnh hưởng trực tiếp đến thu nhập nhân viên và compliance pháp lý.

---

## 2. Kiến trúc H4 — Lựa chọn được Adopt

### Ma trận Quyết định

| KPI | Trọng số | H1 Drools+MVEL | H2 Drools+JEXL | H3 CEL+Custom | **H4 Drools+MVEL+DSL** |
|-----|:--------:|:--------------:|:--------------:|:-------------:|:----------------------:|
| K1 Security | 20% | 0.60 | 0.80 | 1.00 | **0.80** |
| K2 Rule Orchestration | 20% | 1.00 | 0.80 | 0.40 | **1.00** |
| K3 Performance | 15% | 0.75 | 0.60 | 0.75 | **0.75** |
| K4 Simulation | 10% | 0.40 | 0.30 | 0.20 | **0.40** |
| K5 Business Friendly | 10% | 0.20 | 0.20 | 0.30 | **0.40** |
| K6 Engineering Effort | 10% | 0.30 | 0.20 | 0.20 | **0.30** |
| K7 Ecosystem | 10% | 0.40 | 0.40 | 0.30 | **0.40** |
| K8 Global Fit | 5% | 0.25 | 0.20 | 0.10 | **0.25** |
| **TỔNG** | **100%** | 3.90 | 3.50 | 3.25 | **🏆 4.30** |

> H4 thắng nhờ cải thiện vượt trội ở K5 (Business Friendly: 2→4) so với H1, trong khi giữ nguyên Rule Orchestration và Performance.

---

## 3. Kiến trúc 3 Tầng

```
┌─────────────────────────────────────────────────────────────────────┐
│                     TẦNG 1: BUSINESS DSL LAYER                      │
│                                                                       │
│  [Formula Studio UI]  →  [DSL Compiler]  →  [Formula Validator]     │
│      HR users              ↓                     ↓                  │
│  viết công thức        Restricted MVEL      Dry-run sandbox          │
│  Excel-like syntax         formula               check               │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ Compiled Restricted MVEL DSL
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   TẦNG 2: DROOLS 8 RULE ENGINE                      │
│                                                                       │
│  [Rule Units]         [Working Memory]      [Agenda / Phreak]       │
│  Country VN Module  ← Facts: Employee,   → Rule activation          │
│  Country SG Module    Period, Attendance    Conflict resolution      │
│                                                                       │
│  [Simulation Engine]  [Audit Logger]    [Dry-Run Engine]            │
│  Historical replay    Rule firing log   Non-persistent exec         │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ Calculation Results
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   TẦNG 3: PAYROLL EXECUTION CORE                    │
│                                                                       │
│  [Batch Processor]  [Transaction Mgr]  [Versioning Store]           │
│  10K employees/run   Commit/Rollback    Formula history              │
│  Parallel partitions All-or-nothing     Immutable audit trail        │
│                                                                       │
│  [Retroactive Engine]  [Approval Workflow]  [Reporting]             │
│  Delta calculation      Multi-level sign-off  Impact reports         │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 4. Tầng 1 — Business DSL Layer

### DSL Compiler Pipeline

```
HR user input (text)
      ↓
[ANTLR4 Parser]
  Grammar chỉ allow: arithmetic, comparison, when/then/else, whitelisted functions
  Reject ngay: Java class access, loops, import statements
      ↓
[AST (Abstract Syntax Tree)]
      ↓
[Semantic Analyzer]
  Type check, reference resolution (element tham chiếu có tồn tại không?)
  Dependency detection (tạo dependency graph)
      ↓
[Security Enforcer]
  Class whitelist check: chỉ BigDecimal, Math, BuiltinFunctions
      ↓
[Code Generator]
  AST → Restricted MVEL string (format Drools hiểu được)
      ↓
Compiled formula (ready for storage)
```

### Formula Studio Components

```
Formula Studio (Web UI)
├── Formula Editor
│   ├── Syntax highlighting (custom DSL)
│   ├── Auto-complete (functions + element references)
│   ├── Real-time validation (compile errors inline)
│   └── Preview panel (dry-run với sample data)
│
├── DSL Compiler (Java/Kotlin service)
│   ├── Parser: ANTLR4 grammar → AST
│   ├── Semantic analyzer: type check, reference resolution
│   ├── Code generator: AST → Restricted MVEL string
│   └── Security enforcer: whitelist check at compile time
│
└── Formula Validator
    ├── Syntax validation (trước khi save)
    ├── Dependency cycle detection
    ├── Dry-run execution (test với sample data)
    └── Formula diff viewer (so sánh 2 versions)
```

---

## 5. Tầng 2 — Drools 8 Rule Engine

### Drools Rule Units — Tổ chức theo Country & Stage

```
Payroll Rule Units (Drools 8)
├── VN_PrePayroll_Unit
│   ├── validate-attendance.drl
│   ├── prepare-employee-facts.drl
│   └── early-termination-check.drl
│
├── VN_GrossCalculation_Unit
│   ├── base-salary.drl
│   ├── allowances.drl
│   └── overtime.drl
│
├── VN_InsuranceCalc_Unit
│   ├── bhxh-employee.drl       ← Calls MVEL: min(GROSS, CEILING) * 0.08
│   ├── bhyt-employee.drl
│   ├── bhtn-employee.drl
│   └── bhxh-employer.drl
│
├── VN_TaxCalculation_Unit
│   ├── taxable-income.drl
│   ├── pit-tax-progressive.drl ← Calls MVEL: progressiveTax(TAXABLE, BRACKETS)
│   └── deductions.drl
│
├── VN_NetCalculation_Unit
│   └── net-salary.drl
│
├── VN_PostProcessing_Unit
│   ├── rounding.drl
│   └── retroactive-delta.drl
│
└── SG_*.Unit / US_*.Unit      ← Country-specific Rule Units (future)
```

### Intermediate Fact Insertion — Điểm mạnh của Drools

```java
// Ví dụ: Hazard allowance phải tách ra 2 phần với tax treatment khác nhau
rule "Split Hazard Allowance"
   agenda-group "pre-gross"
   when
      $emp: Employee(hasHazardRole == true)
      $hazard: PayrollElement(code == "HAZARD_ALLOWANCE", emp == $emp.id)
   then
      // Insert 2 intermediate facts vào Working Memory
      insert(new PayrollElement("HAZARD_TAX_EXEMPT", $emp.id, $hazard.value * 0.7));
      insert(new PayrollElement("HAZARD_TAXABLE", $emp.id, $hazard.value * 0.3));
      // Express Engine KHÔNG thể làm điều này
end
```

Cơ chế `insert()` intermediate facts vào Working Memory là lý do **Drools là lựa chọn duy nhất** cho bài toán VN payroll phức tạp (hazard tax split, night shift premium...).

### Rete/Phreak Algorithm

Drools dùng **Phreak algorithm** (kế thừa từ Rete):
- **Incremental evaluation**: Chỉ re-evaluate rule khi fact liên quan thay đổi
- Không re-compute toàn bộ rule network mỗi lần
- Trực tiếp đảm bảo SLA: 10,000 nhân viên < 5 phút

---

## 6. Tầng 3 — Payroll Execution Core

### Execution Modes Implementation

```
Dry Run Mode:
  KieSession (STATEFUL) → non-transactional
  Working memory → in-memory only (không persist)
  Output → DryRunResult (intermediate values + rule log)
  Side effect → NONE

Simulation Mode:
  Load historical facts từ read-only snapshot
  KieSession → run với formula version mới
  Compare với baseline results
  Output → SimulationResult (side-by-side deltas)
  Lưu → simulation_result table (có thể xóa)

Production Run Mode:
  KieSession → transactional wrapping
  Batch partition → parallel KieSessions (thread-safe)
  Write → payroll_result table (IMMUTABLE)
  Audit → audit_log table (APPEND-ONLY)
  Lock → PayrollPeriod.status = LOCKED sau approval
```

### Data Model Chính

```
PayrollFormula (công thức versioned)
  id, elementCode, version
  dslSource        // Business DSL — what HR writes
  compiledMvel     // Output of DSL Compiler
  status           // DRAFT | REVIEWED | APPROVED | ACTIVE | DEPRECATED
  approvedBy, approvedAt, activatedAt, effectiveDate

PayrollRun (kỳ tính lương)
  id, period, payrollGroupId
  mode             // DRY_RUN | SIMULATION | PRODUCTION
  formulaVersionSnapshot  // Map<elementCode, versionId> — snapshot tại thời điểm run
  status, startedAt, completedAt

PayrollResult (kết quả — IMMUTABLE)
  runId, employeeId
  elementResults   // [{code, value, formulaVersion, inputs, executionOrder}]
  resultHash       // SHA-256 để verify integrity

AuditLog (APPEND-ONLY)
  id, timestamp, userId, action
  entityType, entityId
  inputSnapshot, formulaVersion, resultHash
```

---

## 7. Security Model — 5 Lớp Bảo vệ

```
Mối đe dọa: HR user nhập formula: baseSalary * (Runtime.exec("rm -rf /"))

Layer 1 — ANTLR Grammar (Compile-time)
  "Runtime" không phải token hợp lệ → Parse error ngay lập tức
  Không cho phép: Java class names, import, loops, method invocation

Layer 2 — MVEL Class Whitelist (Compile-time)
  ParserContext chỉ expose: BigDecimal, Math, BuiltinFunctions
  Không có JVM class nào khác accessible

Layer 3 — Offline Compile (Architecture)
  Formula compile khi chuyển DRAFT → APPROVED
  KHÔNG compile từ user input at runtime → loại bỏ runtime injection surface

Layer 4 — ClassLoader Isolation (Runtime)
  Custom ClassLoader không expose java.lang.Runtime hay reflection
  Timeout: 30 giây/execution context

Layer 5 — Finance Lead Approval (Process)
  Formula không ACTIVE khi chưa qua approval
  Nếu cả 4 layers kỹ thuật bị bypass → chỉ xảy ra khi insider threat từ Finance Lead

→ Residual risk: VERY LOW
```

---

## 8. Tại sao không chọn SpEL + Temporal?

SpEL + Temporal Workflow là một alternative được phân tích kỹ:

| Tiêu chí | MVEL + Drools | SpEL + Temporal |
|---------|:---:|:---:|
| Rule Orchestration (working memory, chaining) | ✅ Native | ❌ Phải tự xây |
| Intermediate fact computation | ✅ Native (`insert()`) | ❌ Cần state object workaround |
| Security sandbox | ✅ 5-layer defense | ⚠️ SimpleEvaluationContext yếu |
| Batch throughput 10K employees | ✅ In-process | ❌ Network overhead per-activity |
| Business user authoring | ✅ Business DSL Layer | ❌ Java/Go code — HR không tự làm |
| Durable execution/retry | ⚠️ Cần tự xây | ✅ Native |
| Infrastructure overhead | ✅ Thấp (in-process) | ⚠️ Cao (Temporal Server riêng) |

**SpEL + Temporal thất bại ở 3 điểm không thể thỏa hiệp**: (1) không có working memory cho intermediate computation, (2) batch throughput không đạt SLA do network overhead, (3) HR users không thể self-author formula.

---

## 9. Global Extensibility

Kiến trúc Rule Units cho phép mở rộng multi-country mà **không cần sửa engine core**:

```
Thêm Singapore Payroll:
  1. Tạo SG_*.Unit rule files (CPF, income tax SG...)
  2. Tạo StatutoryRule entities cho SG
  3. Tạo PayProfile SG với SG-specific elements
  → Engine VN không bị ảnh hưởng gì

Fallback Strategy (nếu Drools gặp vấn đề):
  Option A: Migration to Kogito (~2 sprint)
    Kogito = cloud-native evolution của Drools
    Rule files (DRL) tương thích hoàn toàn
  Option B: Custom dependency graph executor (last resort, ~3-4 months)
    Giữ nguyên MVEL formulas + Business DSL
    Replace Drools bằng custom topological sort executor
```

---

## 10. Implementation Roadmap

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| **Phase 0** — Foundation | 4 tuần | Drools 8 setup, MVEL sandbox, formula registry, dry-run |
| **Phase 1** — VN Payroll MVP | 8 tuần | VN rule set đầy đủ (BHXH, PIT), production batch |
| **Phase 2** — Simulation & Governance | 8 tuần | Simulation engine, retroactive, approval workflow |
| **Phase 3** — Business DSL Layer | 8 tuần | ANTLR4 DSL, Formula Studio UI, diff viewer |
| **Phase 4** — Hardening | 4 tuần | Performance 10K, global-ready, security pentest |

> **MVP Go-live**: Sau Phase 1 (12 tuần) — chạy lương VN cơ bản  
> **Full Feature**: Sau Phase 3 (28 tuần) — HR users tự cấu hình công thức

---

*← [05 Payroll Execution Lifecycle](./05-payroll-execution-lifecycle.md) · [07 Accounting & Reporting →](./07-accounting-reporting.md)*
